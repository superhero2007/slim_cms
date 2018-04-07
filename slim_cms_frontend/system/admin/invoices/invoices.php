<?php
set_time_limit(0); // Override any maximum execution time.

if(isset($_REQUEST['action'])) {
	switch($_REQUEST['action']) {
		case 'invoice_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`invoice` SET
					`invoice_id` = %2$d,
					`client_id` = %3$d,
					`currency_id` = %4$d,
					`timestamp` = IF("%5$s" != "","%5$s",NOW()),
					`invoice_date` = IF("%6$s" != "","%6$s",CURDATE()),
					`terms` = IF(%7$d != "",%7$d,14),
					`discount` = "%8$f";
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_POST['invoice_id']),
				$this->db->escape_string($_POST['client_id']),
				$this->db->escape_string($_POST['currency_id']),
				$this->db->escape_string($_POST['timestamp']),
				$this->db->escape_string($_POST['invoice_date'] != '' ? date("Y-m-d",strtotime($_POST['invoice_date'])) : null),
				$this->db->escape_string($_POST['terms']),
				$this->db->escape_string($_POST['discount'])
			));
			header('location: ?page=clients&mode=invoice_edit&client_id='.$_POST['client_id'].'&invoice_id='.$this->db->insert_id);
			die();
		}
		case 'invoice_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`invoice` WHERE `invoice_id` = %2$d;
				DELETE FROM `%1$s`.`product_2_invoice` WHERE `invoice_id` = %2$d;
				OPTIMIZE TABLE
					`%1$s`.`invoice`,
					`%1$s`.`product_2_invocie`;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_REQUEST['invoice_id'])
			));
			header('location: ?page=clients&mode=client_edit&client_id='.$_REQUEST['client_id']);
			die();
		}
		case 'product_2_invoice_save': {
		 
		 $product_price = 0;
		 
		 //Added a lookup on product_price before insert
		 if($result = $this->db->query(sprintf('
			SELECT `price`
			FROM `%1$s`.`product_price`
			WHERE `product_id` = %2$d
			LIMIT 1;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($_POST['product_id'])
		))) {
		 	$row = $result->fetch_object();
			$product_price = $row->price;
		}
		 
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`product_2_invoice` SET
					`invoice_id` = %2$d,
					`product_id` = %3$d,
					`quantity` = %4$d,
					`price_per_item` = "%5$f",
					`received` = %6$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_POST['invoice_id']),
				$this->db->escape_string($_POST['product_id']),
				$this->db->escape_string($_POST['quantity']),
				$product_price,
				$this->db->escape_string($_POST['received'])
			));
			header('location: ?page=clients&mode=invoice_edit&client_id='.$_POST['client_id'].'&invoice_id='.$_POST['invoice_id']);
			die();
		}
		case 'product_2_invoice_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`product_2_invoice` WHERE `product_2_invoice_id` = %2$d;
				OPTIMIZE TABLE
					`%1$s`.`product_2_invoice`;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_REQUEST['product_2_invoice_id'])
			));
			header('location: ?page=clients&mode=invoice_edit&client_id='.$_REQUEST['client_id'].'&invoice_id='.$_REQUEST['invoice_id']);
			die();
		}
		case 'send_invoice': {
			$pdfInvoice = new pdfInvoice($this->db);
			$pdfInvoice->build($_POST['invoice_id']);
			$pdfInvoice->output('invoice.pdf');
			die();
		}
		case 'search': {
			header('location: ?page=invoices&mode=all-invoices&q='.$_REQUEST['q']);
			die();
		}
	}
}

//Now get everything
//All of this information below is used for the XSL rendering
//We should try and limit the amount of details coming out for this as there could be a lot of information which could slow down the system

//Get all of the different client types
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`client_type`;
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'client_type');
	}
	$result->close();
}
		
//Get Partner to Client Relationship
if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`partner_2_client`;
		',
		DB_PREFIX.'billing'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'partner_2_client');
	}
	$result->close();
}
		
if($result = $this->db->query(sprintf('
	SELECT
		`country`.`country_id`,
		`country`.`country`
		FROM `%1$s`.`country`;
		',
		DB_PREFIX.'resources'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'country');
	}
	$result->close();
}

if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`transaction`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'transaction');
	}
	$result->close();
}

//Include client details in the invoice list as we don't need everything from the client table nor all of the clients.
//New Query 20130508
if($result = $this->db->query(sprintf('
	SELECT
	`invoice`.`client_id`,
	`client`.`company_name`,
	`invoice`.`invoice_id`,
	`invoice`.`timestamp`,
	`invoice`.`invoice_date`,
	`invoice`.`terms`,
	`invoice`.`discount`,
	`invoice`.`paid`,
	`invoice`.`archive`,
	DATE_ADD(`invoice`.`invoice_date`, INTERVAL `invoice`.`terms` DAY) AS `due_date`,
	DATEDIFF(NOW(),DATE_ADD(`invoice`.`invoice_date`, INTERVAL `invoice`.`terms` DAY)) AS `days_passed`,
	(
		SELECT
		SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`))
		FROM `%1$s`.`product_2_invoice`
		WHERE `product_2_invoice`.`invoice_id` = `invoice`.`invoice_id`
	) AS `invoice_amount`,
	`associate`.`client_id`	AS `associate_id`,
	`associate`.`company_name` AS `account_owner`,
	(
		SELECT
		IF(SUM(`transaction`.`amount`) IS NULL, 0, SUM(`transaction`.`amount`))
		FROM `%1$s`.`transaction`
		WHERE `transaction`.`client_id` = `client`.`client_id`
	) AS `client_credits`,
	(
		SELECT
		IF(SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`)) IS NULL,0,SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`)))
		FROM `%1$s`.`product_2_invoice`
		WHERE `product_2_invoice`.`invoice_id` IN (
			SELECT
			`invoice`.`invoice_id`
			FROM `%1$s`.`invoice`
			WHERE `invoice`.`client_id` = `client`.`client_id`
		)
	) AS `client_debits`
	FROM `%1$s`.`invoice`
	LEFT JOIN `%2$s`.`client` ON `invoice`.`client_id` = `client`.`client_id`
	LEFT JOIN `%2$s`.`client` AS `associate` ON `client`.`parent_id` = `associate`.`client_id`
	#WHERE `invoice`.`paid` = 0
	WHERE `invoice`.`archive` = 0
	#AND DATEDIFF(NOW(),DATE_ADD(`invoice`.`invoice_date`, INTERVAL `invoice`.`terms` DAY)) > 0
	ORDER BY `invoice_date` ASC;
',
	DB_PREFIX.'pos',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'invoice');
	}		
}

//New Query 20130508
if($result = $this->db->query(sprintf('
	SELECT
		`invoice`.`client_id`,
		`client`.`company_name`,
		`invoice`.`invoice_id`,
		`invoice`.`timestamp`,
		`invoice`.`invoice_date`,
		`invoice`.`terms`,
		`invoice`.`discount`,
		`invoice`.`paid`,
		`invoice`.`archive`,
		DATE_ADD(`invoice`.`invoice_date`, INTERVAL `invoice`.`terms` DAY) AS `due_date`,
		DATEDIFF(NOW(),DATE_ADD(`invoice`.`invoice_date`, INTERVAL `invoice`.`terms` DAY)) AS `days_passed`,
		(
			SELECT
			SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`))
			FROM `%1$s`.`product_2_invoice`
			WHERE `product_2_invoice`.`invoice_id` = `invoice`.`invoice_id`
		) AS `invoice_amount`,
		`associate`.`client_id`	AS `account_owner_id`,
		`associate`.`company_name` AS `account_owner`
		,
	(
		SELECT
		IF(SUM(`transaction`.`amount`) IS NULL, 0, SUM(`transaction`.`amount`))
		FROM `%1$s`.`transaction`
		WHERE `transaction`.`client_id` = `client`.`client_id`
	) AS `client_credits`,
	(
		SELECT
		IF(SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`)) IS NULL,0,SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`)))
		FROM `%1$s`.`product_2_invoice`
		WHERE `product_2_invoice`.`invoice_id` IN (
			SELECT
			`invoice`.`invoice_id`
			FROM `%1$s`.`invoice`
			WHERE `invoice`.`client_id` = `client`.`client_id`
		)
	) AS `client_debits`
	FROM `%1$s`.`invoice`
	LEFT JOIN `%2$s`.`client` ON `invoice`.`client_id` = `client`.`client_id`
	LEFT JOIN `%2$s`.`client` AS `associate` ON `client`.`parent_id` = `associate`.`client_id`
	WHERE `invoice`.`paid` = 0
	AND `invoice`.`archive` = 0
	AND DATEDIFF(NOW(),DATE_ADD(`invoice`.`invoice_date`, INTERVAL `invoice`.`terms` DAY)) > 0
	ORDER BY `days_passed` DESC
',
	DB_PREFIX.'pos',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'overdueInvoice');
	}
	$result->close();
}

/*
if($result = $this->db->query(sprintf('
		SELECT
		    `invoice`.`client_id`,
			`invoice`.`invoice_id`,
		    `invoice`.`timestamp`,
		    `invoice`.`invoice_date`,
		    `invoice`.`terms`,
		    `invoice`.`discount`,
			DATE_ADD(`invoice`.`invoice_date`, INTERVAL `invoice`.`terms` DAY) AS `due_date`,
			DATEDIFF(NOW(),DATE_ADD(`invoice`.`invoice_date`, INTERVAL `invoice`.`terms` DAY)) AS `days_passed`,
			`client`.`company_name`,
		    (
		        SELECT
		        SUM(`transaction`.`amount`)
		        FROM `%1$s`.`transaction`
		        WHERE `transaction`.`client_id` = `invoice`.`client_id`
		    ) AS `payments`,
		    (
		        SELECT
		        SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`))
		        FROM `%1$s`.`product_2_invoice`
		        WHERE `product_2_invoice`.`invoice_id` IN (
		            SELECT
		            `invoice`.`invoice_id`
		            FROM `%1$s`.`invoice`
		            WHERE `invoice`.`client_id` = `client`.`client_id`
		        )
		    ) AS `invoiced_amount`,
		    (
        		SELECT
        		SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`))
        		FROM `%1$s`.`product_2_invoice`
        		WHERE `product_2_invoice`.`invoice_id` = `invoice`.`invoice_id`
    		) AS `current_invoice_amount`,
		    `associate`.`company_name` AS `account_owner`,
		        (
        SELECT
        IF(SUM(`transaction`.`amount`) IS NULL, 0, SUM(`transaction`.`amount`))
        FROM `%1$s`.`transaction`
        WHERE `transaction`.`client_id` = `client`.`client_id`
    ) AS `total_transactions`,
    (
        SELECT
        IF(SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`)) IS NULL,0,SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`)))
        FROM `%1$s`.`product_2_invoice`
        WHERE `product_2_invoice`.`invoice_id` IN (
            SELECT
            `invoice`.`invoice_id`
            FROM `%1$s`.`invoice`
            WHERE `invoice`.`client_id` = `client`.`client_id`
        )
    ) AS `client_total`,
    (
        SELECT
        IF(SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`)) IS NULL, 0, SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`)))
        FROM `%1$s`.`product_2_invoice`
        WHERE `product_2_invoice`.`invoice_id` = `invoice`.`invoice_id`
    ) AS `invoice_amount`
			FROM `%1$s`.`invoice`
			LEFT JOIN `%2$s`.`client` ON `client`.`client_id` = `invoice`.`client_id`
		  	LEFT JOIN `%2$s`.`client` AS `associate` ON `client`.`parent_id` = `associate`.`client_id`
			WHERE `client`.`client_id` IS NOT NULL
			AND `invoice`.`paid` = 0
		  	AND `invoice`.`invoice_id` IN(
		    SELECT
		    MAX(`invoice2`.`invoice_id`)
		    FROM `%1$s`.`invoice` AS `invoice2`
		    WHERE `invoice2`.`client_id` = `invoice`.`client_id`
		  	)
		  	AND
		  	(
		        SELECT
		        IF(SUM(`transaction`.`amount`) IS NULL, 0, SUM(`transaction`.`amount`))
		        FROM `%1$s`.`transaction`
		        WHERE `transaction`.`client_id` = `invoice`.`client_id`
		    ) <
			(
		        SELECT
		        SUM((`product_2_invoice`.`quantity` * `product_2_invoice`.`price_per_item`))
		        FROM `%1$s`.`product_2_invoice`
		        WHERE `product_2_invoice`.`invoice_id` IN (
		            SELECT
		            `invoice`.`invoice_id`
		            FROM `%1$s`.`invoice`
		            WHERE `invoice`.`client_id` = `client`.`client_id`
		        )
		    )
		    ORDER BY `days_passed` DESC
',
	DB_PREFIX.'pos',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'overdueInvoice');
	}
	$result->close();
}
*/

if($result = $this->db->query(sprintf('
	SELECT
		*,
		`quantity` * `price_per_item` AS `total`
	FROM `%1$s`.`product_2_invoice`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'product_2_invoice');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`product`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'product');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`product_price`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'product_price');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`currency`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'currency');
	}
	$result->close();
}

set_time_limit(60); // Return the timeout to 60 seconds

?>