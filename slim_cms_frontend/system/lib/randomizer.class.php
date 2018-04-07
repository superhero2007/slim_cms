<?php
class randomizer {
	private $db;
	
	public function __construct($db) {
		$this->db = $db;
	}

	public function getRandomCompanyName() {
		do {
			$company_name = "";
		
			//First Part of Company Name
			if($result = $this->db->query(sprintf('
				SELECT *
				FROM `%1$s`.`company_name`
				ORDER BY RAND()
				LIMIT 1;
			',
				DB_PREFIX.'randomizer'
			))) {
				while($row = $result->fetch_object()) {
					$company_name .= $row->name;
				}
				$result->close();
			}
		
			//Company Extension
			if($result = $this->db->query(sprintf('
				SELECT *
				FROM `%1$s`.`company_name_extension`
				ORDER BY RAND()
				LIMIT 1;
			',
				DB_PREFIX.'randomizer'
			))) {
				while($row = $result->fetch_object()) {
					$company_name .= " " . $row->name;
				}
				$result->close();
			}
		} while($this->checkRandomCompanyNameDuplicate($company_name));
	
		return $company_name;
	}

	//Take the random company name and check that is doesn't already exist in the database
	private function checkRandomCompanyNameDuplicate($company_name) {
		$match = false;

		//Company Extension
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client`
			WHERE `company_name` = "%2$s";
		',
			DB_PREFIX.'core',
			$company_name
		))) {
			while($row = $result->fetch_object()) {
				$match = true;
			}
			$result->close();
		}

		return $match;
	}

	//Look through all existing clients and get a real address, enable filtering by country or worldwide
	public function getRandomAddress($country = null) {
		$address = null;
		
		if($result = $this->db->query(sprintf('
			SELECT
			`address_line_1`,
			`address_line_2`,
			`suburb`,
			`state`,
			`postcode`,
			`country`
			FROM `%1$s`.`client`
			WHERE `address_line_1` IS NOT NULL
			AND `address_line_1` != ""
			AND `country` IS NOT NULL
			AND `country` != ""
			%2$s
			ORDER BY RAND()
			LIMIT 1;
		',
			DB_PREFIX.'core',
			(!is_null($country) ? "AND `country` = '" . $country . "'" : null)
		))) {
			while($row = $result->fetch_object()) {
				$address = $row;
			}
			$result->close();
		}
		
		return $address;
	}
	
	//Get a random industry
	public function getRandomIndustry($industry_id = null) {
		$industry = null;
		
		//Return the id sent through
		if(!is_null($industry_id) && ($industry_id != '0')) {
			return $industry_id;
		}
		
		if($result = $this->db->query(sprintf('
			SELECT
			`anzsic_id` AS `industry_id`
			FROM `%1$s`.`anzsic`
			ORDER BY RAND()
			LIMIT 1;
		',
			DB_PREFIX.'resources'
		))) {
			while($row = $result->fetch_object()) {
				$industry = $row->industry_id;
			}
			$result->close();
		}
		
		return $industry;
	}
	
	//Get a random client_type
	public function getRandomClientType($client_type_id = null) {
		$client_type = null;
		
		//Return the id sent through
		if(!is_null($client_type_id) && ($client_type_id != '0')) {
			return $client_type_id;
		}
		
		if($result = $this->db->query(sprintf('
			SELECT
			`client_type_id`
			FROM `%1$s`.`client_type`
			ORDER BY RAND()
			LIMIT 1;
		',
			DB_PREFIX.'core'
		))) {
			while($row = $result->fetch_object()) {
				$client_type = $row->client_type_id;
			}
			$result->close();
		}
		
		return $client_type;
	}

}
?>