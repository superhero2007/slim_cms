<?php

$auditDoc = new auditDocument($this->db);
if(isset($_REQUEST['action'])) {
	switch($_REQUEST['action']) {
		case 'audit_save': {
			$this->db->query(sprintf('
				UPDATE `%1$s`.`audit` SET
					`audited` = %3$d,
					`certified` = %4$d,
					`audit_finish_date` = "%5$s",
					`auditor_name` = "%6$s",
					`auditor_email` = "%7$s",
					`auditor_phone` = "%8$s",
					`notes` = "%9$s",
					`status` = %10$d,
					`audit_type` = %11$d
				WHERE `audit_id` = %2$d;
			',
				DB_PREFIX.'audit',
				$this->db->escape_string($_POST['audit_id']),
				$this->db->escape_string(isset($_REQUEST['audited']) ? $_REQUEST['audited'] : 0),
				$this->db->escape_string(isset($_REQUEST['certified']) ? $_REQUEST['certified'] : 0),
				$this->db->escape_string(date("Y-m-d H:i:s")),
				$this->db->escape_string($_POST['auditor_name']),
				$this->db->escape_string($_POST['auditor_email']),
				$this->db->escape_string($_POST['auditor_phone']),
				$this->db->escape_string($_POST['notes']),
				$this->db->escape_string($_POST['status_id']),
				$this->db->escape_string($_POST['audit_type'])
			));

			break;
		}
		case 'download': {
			$auditDoc->downloadAuditDocument($_REQUEST['audit-document-id']);
			die();
			break;
		}
		case 'set_uncosted_audits' : {
			$audit_cost = new auditCost($this->db);
			$audit_cost->setAllUncostedAudits();
			break;
		}
	}
}


//Now get everything

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

//Get all of the clients - first check if we are getting just the searched results
	if($result = $this->db->query($sql = sprintf('
		SELECT 
			`client`.*,
			CONCAT_WS(", ",`city`.`accent_city`,`region`.`region`,`country`.`country`) AS `location`,
			DATE(`client`.`registered`) AS `date_registered`,
			DATE(`client_log`.`timestamp`) AS `last_active`,
			`partner_2_client`.`partner_id` AS `jv_partner_id`
		FROM `%5$s`.`audit`
		LEFT JOIN `%4$s`.`client_checklist` ON `audit`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
		LEFT JOIN `%1$s`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
		LEFT JOIN `%1$s`.`client_log` ON `client`.`client_id` = `client_log`.`client_id`
		LEFT JOIN `%2$s`.`city` ON `client`.`city_id` = `city`.`city_id`
		LEFT JOIN `%2$s`.`region` ON `city`.`region_id` = `region`.`region_id`
		LEFT JOIN `%2$s`.`country` ON `city`.`country_id` = `country`.`country_id`
		LEFT JOIN `%3$s`.`partner_2_client` ON `client`.`client_id` = `partner_2_client`.`client_id`
		WHERE `client`.`client_type_id` != 3
		GROUP BY `client`.`client_id`
		ORDER BY `client`.`company_name` ASC
	',
		DB_PREFIX.'core',
		DB_PREFIX.'resources',
		DB_PREFIX.'billing',
		DB_PREFIX.'checklist',
		DB_PREFIX.'audit'
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'client');
		}
		$result->close();
	}

if($result = $this->db->query(sprintf('
	SELECT `client_contact`.*
	FROM `%1$s`.`client_contact`
	ORDER BY `client_contact`.`sequence` ASC;
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
	 	$row->photo = is_file(PATH_ROOT.'/public_html/_images/partners/business_owner_contact_'.$row->client_contact_id.'.gif') ? 'yes' : 'no';
		$this->row2config($row,'client_contact');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT `checklist`.*
	FROM `%1$s`.`checklist`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'checklist');
	}
	$result->close();
}

$client_checklist_id = null;

//Get the audit and audit document information
if($result = $this->db->query(sprintf('
	SELECT 
		`audit`.*,
		`client_checklist`.`client_id`,
		`client_checklist`.`name`,
		`client_checklist`.`current_score`,
		`client_checklist`.`created`,
		`client_checklist`.`expires`,
		`client`.`company_name`,
		`audit_status`.`status` AS `audit_status`,
		(
			SELECT
				`client_result`.`arbitrary_value`
				FROM `%2$s`.`client_result`
				WHERE `client_result`.`question_id` IN (
    				SELECT `question`.`question_id` 
    				FROM `%2$s`.`question` 
    				WHERE `question`.`question` LIKE "%%number of staff%%")
				AND `client_result`.`arbitrary_value` IS NOT NULL
				AND `client_result`.`arbitrary_value` != ""
				AND `client_result`.`client_checklist_id` = `audit`.`client_checklist_id`
				ORDER BY `client_result`.`timestamp` DESC
				LIMIT 1
		) AS `number_of_staff`
		FROM `%1$s`.`audit`
		LEFT JOIN `%2$s`.`client_checklist` ON `client_checklist`.`client_checklist_id` = `audit`.`client_checklist_id`
		LEFT JOIN `%3$s`.`client` ON `client`.`client_id` = `client_checklist`.`client_id`
		LEFT JOIN `%1$s`.`audit_status` ON `audit_status`.`status_id` = `audit`.`status`;
		',
		DB_PREFIX.'audit',
		DB_PREFIX.'checklist',
		DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		if(isset($_REQUEST['audit_id']) && $row->audit_id == $_REQUEST['audit_id']) {
			$client_checklist_id = $row->client_checklist_id;
		}
		//Check and set the expiry date
		if(!is_null($row->expires) ? $row->expiry = $row->expires : $row->expiry = date("Y-m-d", strtotime(date("Y-m-d", strtotime($row->created)) . " + 365 day")));
		if(!is_null($row->expires) ? $row->expires = $row->expires : $row->expires = date("Y-m-d", strtotime(date("Y-m-d", strtotime($row->created)) . " + 365 day")));
	
		$this->row2config($row,'audit');
	}
	$result->close();
}

if($result = $this->db->query(sprintf('
	SELECT *
		FROM `%1$s`.`document_2_client_checklist`;
		',
		DB_PREFIX.'audit'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'audit_document');
	}
	$result->close();
}

if($result = $this->db->query(sprintf('
			SELECT
				`audit`.`audit_id`,
				`audit`.`answer_id`,
				`audit`.`arbitrary_value`,
				`audit`.`audit_type`,
				`question`.`question`,
				`question`.`question_id`
			FROM `%1$s`.`audit`
			LEFT JOIN `%1$s`.`answer` ON `audit`.`answer_id` = `answer`.`answer_id` 
			LEFT JOIN `%1$s`.`question` ON `answer`.`question_id` = `question`.`question_id`
			WHERE `audit`.`audit_id` IS NOT NULL;
		',
		DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'audit_question');
	}
	$result->close();
}

if(!is_null($client_checklist_id)) {
	$clientChecklist = new clientChecklist($this->db);
	$auditEvidence = $clientChecklist->getAuditEvidence($client_checklist_id);
	foreach($auditEvidence as $evidence) {
		$this->row2config($evidence,'audit_evidence');
	}
}

//Get the audit status list
if($result = $this->db->query(sprintf('
	SELECT *
		FROM `%1$s`.`audit_status`;
		',
		DB_PREFIX.'audit'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'audit_status');
	}
	$result->close();
}

//Get the audit status list
if($result = $this->db->query(sprintf('
	SELECT *
		FROM `%1$s`.`audit_type`;
		',
		DB_PREFIX.'audit'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'audit_type');
	}
	$result->close();
}

//
if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`certification_level`;
		',
		DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'certification_level');
	}
	$result->close();
}

?>