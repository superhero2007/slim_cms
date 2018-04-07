<?php
class clientUtils {
	private $db;

	function __construct($db) {
		$this->db = $db;
	}
	
	static function makeNameFilenameSafe($filename) {
		$filename = str_replace("#","_",$filename);
		$filename = str_replace(" ","_",$filename);
		$filename = str_replace("'","",$filename);
		$filename = str_replace('"',"",$filename);
		$filename = str_replace("__","_",$filename);
		$filename = str_replace("&","and",$filename);
		$filename = str_replace("/","_",$filename);
		$filename = str_replace("\"","_",$filename);
		$filename = str_replace("?","",$filename);
		return $filename;
	}
	
	public function getClientByClientId($client_id) {
		return($this->setClient(sprintf('
			SELECT
				NULL AS `client_contact_id`,
				NULL AS `salutation`,
				NULL AS `firstname`,
				NULL AS `lastname`,
				NULL AS `position`,
				NULL AS `email`,
				NULL AS `phone`,
				`client`.`client_id`,
				`client`.`client_type_id`,
				`client_type`.`client_type`,
				`client`.`city_id`,
				`region`.`region_id`,
				`country`.`country_id`,
				`client`.`associate_account_id`,
				`client`.`username`,
				`client`.`password`,
				`client`.`company_name`,
				`client`.`department`,
				`client`.`address_line_1`,
				`client`.`address_line_2`,
				`client`.`suburb`,
				`client`.`postcode`,
				`client`.`complimentary_consult`,
				`client`.`industry`,
				`country`.`currency_id`,
				`city`.`accent_city` AS `city`,
				`region`.`region`,
				`country`.`country`,
				CONCAT_WS(", ",`city`.`accent_city`,`region`.`region`,`country`.`country`) AS `location`
			FROM `%1$s`.`client`
			LEFT JOIN `%1$s`.`client_type` ON `client`.`client_type_id` = `client_type`.`client_type_id`
			LEFT JOIN `%2$s`.`city` ON `client`.`city_id` = `city`.`city_id`
			LEFT JOIN `%2$s`.`region` ON `city`.`region_id` = `region`.`region_id`
			LEFT JOIN `%2$s`.`country` ON `city`.`country_id` = `country`.`country_id`
			WHERE `client`.`client_id` = %3$d;
		',
			DB_PREFIX.'core',
			DB_PREFIX.'resources',
			$this->db->escape_string($client_id)
		)));
	}
	
	public function getClientByContactId($client_contact_id) {
		return($this->setClient(sprintf('
			SELECT
				`client_contact`.`client_contact_id`,
				`client_contact`.`salutation`,
				`client_contact`.`firstname`,
				`client_contact`.`lastname`,
				`client_contact`.`position`,
				`client_contact`.`email`,
				`client_contact`.`password`,
				`client_contact`.`phone`,
				`client`.`client_id`,
				`client`.`client_type_id`,
				`client_type`.`client_type`,
				`client`.`city_id`,
				`region`.`region_id`,
				`country`.`country_id`,
				`client`.`associate_account_id`,
				`client`.`company_name`,
				`client`.`department`,
				`client`.`address_line_1`,
				`client`.`address_line_2`,
				`client`.`suburb`,
				`client`.`postcode`,
				`client`.`industry`,
				`country`.`currency_id`,
				`city`.`accent_city` AS `city`,
				`region`.`region`,
				`country`.`country`,
				CONCAT_WS(", ",`city`.`accent_city`,`region`.`region`,`country`.`country`) AS `location`
			FROM `%1$s`.`client_contact`
			LEFT JOIN `%1$s`.`client` ON `client_contact`.`client_id` = `client`.`client_id`
			LEFT JOIN `%1$s`.`client_type` ON `client`.`client_type_id` = `client_type`.`client_type_id`
			LEFT JOIN `%2$s`.`city` ON `client`.`city_id` = `city`.`city_id`
			LEFT JOIN `%2$s`.`region` ON `city`.`region_id` = `region`.`region_id`
			LEFT JOIN `%2$s`.`country` ON `city`.`country_id` = `country`.`country_id`
			WHERE `client_contact`.`client_contact_id` = %3$d;
		',
			DB_PREFIX.'core',
			DB_PREFIX.'resources',
			$this->db->escape_string($client_contact_id)
		)));
	}
	
	public function getClientByEmail($email) {
		if(($client = $this->setClient(sprintf('
			SELECT
				`client_contact`.`client_contact_id`,
				`client_contact`.`salutation`,
				`client_contact`.`firstname`,
				`client_contact`.`lastname`,
				`client_contact`.`position`,
				`client_contact`.`email`,
				`client_contact`.`password`,
				`client_contact`.`phone`,
				`client`.`client_id`,
				`client`.`client_type_id`,
				`client_type`.`client_type`,
				`client`.`city_id`,
				`region`.`region_id`,
				`country`.`country_id`,
				`client`.`associate_account_id`,
				`client`.`company_name`,
				`client`.`department`,
				`client`.`address_line_1`,
				`client`.`address_line_2`,
				`client`.`suburb`,
				`client`.`postcode`,
				`client`.`industry`,
				`country`.`currency_id`,
				`city`.`accent_city` AS `city`,
				`region`.`region`,
				`country`.`country`,
				CONCAT_WS(", ",`city`.`accent_city`,`region`.`region`,`country`.`country`) AS `location`
			FROM `%1$s`.`client_contact`
			LEFT JOIN `%1$s`.`client` ON `client_contact`.`client_id` = `client`.`client_id`
			LEFT JOIN `%1$s`.`client_type` ON `client`.`client_type_id` = `client_type`.`client_type_id`
			LEFT JOIN `%2$s`.`city` ON `client`.`city_id` = `city`.`city_id`
			LEFT JOIN `%2$s`.`region` ON `city`.`region_id` = `region`.`region_id`
			LEFT JOIN `%2$s`.`country` ON `city`.`country_id` = `country`.`country_id`
			WHERE `client_contact`.`email` = "%3$s";
		',
			DB_PREFIX.'core',
			DB_PREFIX.'resources',
			$this->db->escape_string($email)
		))) != false) {
			return($client);
		}
		/* This is legacy to allow current clients to login with their old passwords */
		if(($client = $this->setClient(sprintf('
			SELECT
				NULL AS `client_contact_id`,
				NULL AS `salutation`,
				NULL AS `firstname`,
				NULL AS `lastname`,
				NULL AS `position`,
				NULL AS `email`,
				NULL AS `phone`,
				`client`.`client_id`,
				`client`.`client_type_id`,
				`client_type`.`client_type`,
				`client`.`city_id`,
				`region`.`region_id`,
				`country`.`country_id`,
				`client`.`associate_account_id`,
				`client`.`username`,
				`client`.`password`,
				`client`.`company_name`,
				`client`.`department`,
				`client`.`address_line_1`,
				`client`.`address_line_2`,
				`client`.`suburb`,
				`client`.`postcode`,
				`client`.`industry`,
				`country`.`currency_id`,
				`city`.`accent_city` AS `city`,
				`region`.`region`,
				`country`.`country`,
				CONCAT_WS(", ",`city`.`accent_city`,`region`.`region`,`country`.`country`) AS `location`
			FROM `%1$s`.`client`
			LEFT JOIN `%1$s`.`client_type` ON `client`.`client_type_id` = `client_type`.`client_type_id`
			LEFT JOIN `%2$s`.`city` ON `client`.`city_id` = `city`.`city_id`
			LEFT JOIN `%2$s`.`region` ON `city`.`region_id` = `region`.`region_id`
			LEFT JOIN `%2$s`.`country` ON `city`.`country_id` = `country`.`country_id`
			WHERE `client`.`username` = "%3$s";
		',
			DB_PREFIX.'core',
			DB_PREFIX.'resources',
			$this->db->escape_string($email)
		))) != false) {
			return($client);
		}
		return(false);
	}
	
	private function setClient($sql) {
		$client = false;
		if($result = $this->db->query($sql)) {
			if($client = $result->fetch_object()) {
				$client->contact = $this->getClientContacts($client->client_id);
			}
			$result->close();
		}
		if($client && $client->client_id != 0) {
			$this->db->query(sprintf('
				REPLACE DELAYED INTO `%1$s`.`client_log` SET
					`client_id` = %2$d,
					`ip_address` = "%3$s";
			',
				DB_PREFIX.'core',
				$client->client_id,
				$_SERVER['REMOTE_ADDR']
			));
		}
		return($client);
	}
	
	public function addClientChecklist($client_id,$checklist_id) {
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`client_checklist` (`client_id`,`checklist_id`,`name`)
				SELECT
					%2$d,
					`checklist`.`checklist_id`,
					`checklist`.`checklist`
				FROM `%1$s`.`checklist`
				WHERE `checklist`.`checklist_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_id),
			$this->db->escape_string($checklist_id)
		));
		return;
	}
	
	private function getClientContacts($client_id) {
		$contact = array();
		if($result = $this->db->query(sprintf('
			SELECT 
				`client_contact`.*
			FROM `%1$s`.`client_contact`
			WHERE `client_contact`.`client_id` = %2$d
			ORDER BY `client_contact`.`sequence` ASC;
		',
			DB_PREFIX.'core',
			$this->db->escape_string($client_id)
		))) {
			while($row = $result->fetch_object()) {
				$contact[] = $row;
			}
			$result->close();
		}
		return($contact);
	}
	
	static function luhn($client_id,$registered) {
		$luhn = sprintf('%s%07s',date("Ymd",$registered),$client_id);
		$sum = 0;
		for($pos=0;$pos<15;$pos++) {
			if(($pos + 1) % 2) {
		 		$t = $luhn{$pos} * 2;
		 		if($t > 9) {
		    		$t -= 9;
		    	}
		 		$sum += $t;
		 	} else {
		 		$sum += $luhn{$pos};
		 	}
		}
		$luhn .= (10 - ($sum % 10)) % 10;
		return($luhn);
	}
	
	static function unluhn($luhn) {
		$luhn = preg_replace("/\D/",'',$luhn);
		$data = array();
		$data['registered'] = substr($luhn,0,4).'-'.substr($luhn,4,2).'-'.substr($luhn,6,2);
		$data['client_id']	= (int) substr($luhn,8,7);
		return($data);
	}
	
	public function getClientContactEmailAddresses($client_id) {
		
		$allClientContacts = $this->getClientContacts($client_id);
		
		for($i=0;$i<count($allClientContacts);$i++) {
			$emailTo[] = sprintf(
				'%1$s',
				$allClientContacts[$i]->email
			);
		}
		
		$emailAddresses = implode(', ',$emailTo);
	
		return $emailAddresses;
	}

	//Generate a random md5 key to identify the checklist publicly
	public function generateRandomAPIKey() {
		$key = null;

		do {
			$key = hash('sha256', SALT . openssl_random_pseudo_bytes(32));
		} while($this->checkRandomAPIKeyExists($key));

		return $key;
	}

	private function checkRandomAPIKeyExists($key) {
		$exists = false;

		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`user`
			WHERE `api_key` = "%2$s";
		',
			DB_PREFIX.'API',
			$key
		))) {
			while($row = $result->fetch_object()) {
				$exists = true;
			}
			$result->close();
		}

		return $exists;
	}
}
?>