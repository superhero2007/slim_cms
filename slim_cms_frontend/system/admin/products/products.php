<?php
if(isset($_REQUEST['action'])) {
	switch($_REQUEST['action']) {
		case 'product_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`product` SET
					`product_id` = %2$d,
					`name` = "%3$s",
					`audit` = "%4$d";
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_POST['product_id']),
				$this->db->escape_string($_POST['name']),
				$this->db->escape_string($_POST['audit'])
			));
			$product_id = $this->db->insert_id;
			foreach($_POST['price'] as $currency_id => $price) {
				if($price == '') {
					$sql = '
						DELETE FROM `%1$s`.`product_price`
						WHERE `product_id` = %2$d
						AND `currency_id` = %3$d;
					';
				} else {
					$sql = '
						REPLACE INTO `%1$s`.`product_price` SET
							`product_id` = %2$d,
							`currency_id` = %3$d,
							`price` = "%4$f";
					';
				}
				$this->db->query(sprintf(
					$sql,
					DB_PREFIX.'pos',
					$this->db->escape_string($product_id),
					$this->db->escape_string($currency_id),
					$this->db->escape_string($price)
				));
			}
			$this->db->query(sprintf('
				OPTIMIZE TABLE `%1$s`.`product_price`
			',
				DB_PREFIX.'pos'
			));
			header('location: ?page=products&mode=product_edit&product_id='.$product_id);
			die();
		}
		case 'product_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`product`
				WHERE `product_id` = %2$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_REQUEST['product_id'])
			));
			header('location: ?page=products');
			die();
		}
		case 'checklist_2_product_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`checklist_2_product` SET
					`checklist_2_product_id` = %2$d,
					`checklist_id` = %3$d,
					`checklist_variation_id` = IF("%4$d" != "",%4$d,NULL),
					`product_id` = %5$d,
					`checklists` = %6$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_POST['checklist_2_product_id']),
				$this->db->escape_string($_POST['checklist_id']),
				$this->db->escape_string($_POST['checklist_variation_id']),
				$this->db->escape_string($_POST['product_id']),
				$this->db->escape_string($_POST['checklists'])
			));
			header('location: ?page=products&mode=checklist_2_product_edit&product_id='.$_POST['product_id'].'&checklist_2_product_id='.$this->db->insert_id);
			die();
		}
		case 'checklist_2_product_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`checklist_2_product`
				WHERE `checklist_2_product_id` = %2$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_REQUEST['checklist_2_product_id'])
			));
			header('location: ?page=products&mode=product_edit&product_id='.$_REQUEST['product_id']);
			die();
		}
		case 'suggestion_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`suggestion` SET
					`suggestion_id` = %2$d,
					`product_id` = %3$d,
					`suggested_product_id` = %4$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_POST['suggestion_id']),
				$this->db->escape_string($_POST['product_id']),
				$this->db->escape_string($_POST['suggested_product_id'])
			));
			header('location: ?page=products&mode=suggestion_edit&product_id='.$_POST['product_id'].'&suggestion_id='.$this->db->insert_id);
			die();
		}
		case 'suggestion_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`suggestion`
				WHERE `suggestion_id` = %2$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_REQUEST['suggestion_id'])
			));
			header('location: ?page=products&mode=product_edit&product_id='.$_REQUEST['product_id']);
			die();
		}
		
		//Save and delete product item details
		case 'product_item_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`product_description` SET
					`product_description_id` = %2$d,
					`product_id` = %3$d,
					`description` = "%4$s";
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_POST['product_item_id']),
				$this->db->escape_string($_POST['product_id']),
				$this->db->escape_string($_POST['description'])
			));
			header('location: ?page=products&mode=product_item_edit&product_id='.$_POST['product_id'].'&product_description_id='.$this->db->insert_id);
			die();
		}
		case 'product_description_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`product_description`
				WHERE `product_description_id` = %2$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_REQUEST['product_description_id'])
			));
			header('location: ?page=products&mode=product_edit&product_id='.$_REQUEST['product_id']);
			die();
		}
		case 'coupon_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`coupon` SET
					`coupon_id` = %2$d,
					`currency_id` = %3$d,
					`active_date` = IF("%4$s" != "","%4$s",CURDATE()),
					`expire_date` = IF("%5$s" != "","%5$s",CURDATE()),
					`coupon` = "%6$s",
					`limit` = %7$d,
					`limit_per_customer` = %8$d,
					`discount_type` = "%9$s",
					`discount` = "%10$s",
					`dollar_limit` = "%11$f";
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_POST['coupon_id']),
				$this->db->escape_string($_POST['currency_id']),
				$this->db->escape_string($_POST['active_date']),
				$this->db->escape_string($_POST['expire_date']),
				$this->db->escape_string($_POST['coupon']),
				$this->db->escape_string($_POST['limit']),
				$this->db->escape_string($_POST['limit_per_customer']),
				$this->db->escape_string($_POST['discount_type']),
				$this->db->escape_string($_POST['discount']),
				$this->db->escape_string($_POST['dollar_limit'])
			));
			header('location: ?page=products&mode=coupon_edit&coupon_id='.$this->db->insert_id);
			die();
		}
		case 'coupon_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`coupon`
				WHERE `coupon_id` = %2$d;
				
				DELETE FROM `%1$s`.`coupon_2_product`
				WHERE `coupon_id` = %2$d;
				
				DELETE FROM `%1$s`.`coupon_redemption`
				WHERE `coupon_id` = %2$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_REQUEST['coupon_id'])
			));
			header('location: ?page=products&mode=coupon_list');
			die();
		}
		case 'coupon_2_product_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`coupon_2_product` SET
					`coupon_2_product_id` = %2$d,
					`coupon_id` = %3$d,
					`product_id` = %4$d,
					`limit_per_transaction` = %5$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_POST['coupon_2_product_id']),
				$this->db->escape_string($_POST['coupon_id']),
				$this->db->escape_string($_POST['product_id']),
				$this->db->escape_string($_POST['limit_per_transaction'])
			));
			header('location: ?page=products&mode=coupon_2_product_edit&coupon_id='.$_POST['coupon_id'].'&coupon_2_product_id='.$this->db->insert_id);
			die();
		}
		case 'coupon_2_product_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`coupon_2_product`
				WHERE `coupon_2_product_id` = %2$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_REQUEST['coupon_2_product_id'])
			));
			header('location: ?page=products&mode=coupon_edit&coupon_id='.$_REQUEST['coupon_id']);
			die();
		}
	}
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
	FROM `%1$s`.`checklist_2_product`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'checklist_2_product');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`suggestion`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'suggestion');
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
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`coupon`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'coupon');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`coupon_2_product`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'coupon_2_product');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`checklist`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'checklist');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`checklist_variation`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'checklist_variation');
	}
	$result->close();
}

//Get the product item deatils
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`product_description`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'product_item');
	}
	$result->close();
}

$ch = curl_init('http://www.palple.net/iphone/currencyconverter/2/values.txt');
curl_setopt($ch,CURLOPT_RETURNTRANSFER,true);
curl_setopt($ch,CURLOPT_HEADER,false);
$xr = curl_exec($ch);
curl_close($ch);
$xr_lines = explode("\n",$xr);
for($i=2;$i<count($xr_lines);$i++) {
	$xr_bits = explode("=",$xr_lines[$i]);
	if(count($xr_bits) == 2) {
		$row->code = $xr_bits[0];
		$row->rate = $xr_bits[1];
	}
	$this->row2config($row,'exchange_rate');
}
?>