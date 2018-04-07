<?php
class contacts extends plugin {
 
	public function contactList() {
		$closestClients = array();
	 
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT
				`client_contact`.`salutation`,
				`client_contact`.`client_contact_id`,
				`client_contact`.`firstname`,
				`client_contact`.`lastname`,
				`client_contact`.`email`,
				`client_contact`.`phone`,
				`client_contact`.`url`,
				`city`.`city_id`,
				`city`.`accent_city` AS `city`,
				`city`.`latitude`,
				`city`.`longitude`,
				`region`.`region_id`,
				`region`.`region`,
				`country`.`country_id`,
				`country`.`country`,
				`client`.`client_id`
			FROM `%1$s`.`client_contact`
			LEFT JOIN `%1$s`.`client` ON `client_contact`.`client_id` = `client`.`client_id`
			LEFT JOIN `%2$s`.`city` ON `client`.`city_id` = `city`.`city_id`
			LEFT JOIN `%2$s`.`region` ON `city`.`region_id` = `region`.`region_id`
			LEFT JOIN `%2$s`.`country` ON `city`.`country_id` = `country`.`country_id`
			WHERE `client`.`client_type_id` IN (2,16)
				AND `display_contact_photo` = 1
				AND `city`.`city_id` IS NOT NULL
			ORDER BY `client_contact`.`lastname` ASC, `client_contact`.`firstname` ASC;
		',
			DB_PREFIX.'core',
			DB_PREFIX.'resources'
		))) {
		 
		 	while($data[] = $result->fetch_object());
		 
		 	//Get the closest clients, returns client_id's
		 	//Get the closest client Id's
		 	if(isset($_REQUEST['city_id']) && $_REQUEST['client_location'] != '') {
		 		$clientCoordinates = $this->getCityCoordinates($_REQUEST['city_id']);
		 		$closestClients = $this->getClosestClients($data, $clientCoordinates);
		 	}
			 		 
			foreach($data as $row) {
				
				if(!is_null($row)) {
					if(empty($closestClients) || in_array($row->client_contact_id, $closestClients)) {
					 	
					 	//Country Node
						if(!isset($countryNode[$row->country_id])) {
							$countryNode[$row->country_id] = $this->node->appendChild($GLOBALS['core']->doc->createElement('country'));
							$countryNode[$row->country_id]->setAttribute('country',$row->country);
						}
						
						//Region Node - Some Cities do not have regions
						if(!isset($regionNode[$row->region_id . $row->country_id])) {
							$regionNode[$row->region_id . $row->country_id] = $countryNode[$row->country_id]->appendChild($GLOBALS['core']->doc->createElement('region'));
							$regionNode[$row->region_id . $row->country_id]->setAttribute('region',$row->region);	
						}
						
						//City Node
						if(!isset($cityNode[$row->city_id])) {
							$cityNode[$row->city_id] = $regionNode[$row->region_id . $row->country_id]->appendChild($GLOBALS['core']->doc->createElement('city'));
							$cityNode[$row->city_id]->setAttribute('city',$row->city);
						}
					
						$associateNode = $cityNode[$row->city_id]->appendChild($GLOBALS['core']->doc->createElement('associate'));
						
						$associateNode->setAttribute('firstname',$row->firstname);
						$associateNode->setAttribute('lastname',$row->lastname);
						$associateNode->setAttribute('email',$row->email);
						$associateNode->setAttribute('phone',$row->phone);
						$associateNode->setAttribute('city',$row->city);
						$associateNode->setAttribute('photo',is_file(PATH_ROOT.'/public_html/_images/partners/business_owner_contact_'.$row->client_contact_id.'.gif') ? 'yes' : 'no');
						$associateNode->setAttribute('client_contact_id',$row->client_contact_id);
						$associateNode->setAttribute('url',$row->url);
					
					}
				}
			}

			$result->close();
		}
		
		//Get the value of the locator search if needed
		if(isset($_REQUEST['city_id'])) {
				
			$queryNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('query'));
			$queryNode->setAttribute('city_id',$_REQUEST['city_id']);
			$queryNode->setAttribute('client_location',$_REQUEST['client_location']);
		}
		
		return;
	}
	
	private function getClosestClients($result, $clientCoordinates) {
		$clients = array();
		$closestClients = array();
		
		foreach($result as $row) {
			if(!is_null($row)) {
				$clients[$row->client_contact_id] = $this->getDistance($clientCoordinates[0]->lat, $clientCoordinates[0]->lon, $row->latitude, $row->longitude);
			}
		}
		
		//Sort array
		asort($clients);
		$count = 0;
		
		foreach($clients as $key => $value) {
		 	if($count == 0) {
				$distance = $value;
			}
		 
			if($value == $distance) {
				$closestClients[] = $key;
			}
			
			$count++;
		}
		
		return $closestClients;
	}
	
	//Takes the object array returned from the business owners query and returns a list of contact_id's of those who are closest to the client 
	private function getCityCoordinates($city_id) {
	 	$coordinates = array();
	 	
	 	//Get the client coordinates
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`city`
			WHERE `city_id` = %2$d
			LIMIT 1;
		',
			DB_PREFIX.'resources',
			$city_id
		))) {
		 	
			while($row = $result->fetch_object()) {
				$coordinates[0]->lat = $row->latitude;
				$coordinates[0]->lon = $row->longitude;
			}
		}
		
		return $coordinates;
	}

	//Get the distance (In Miles) Between two coordinates - Allows us to determine the closest business owner
	//lat1 & lon1 should be the client, lat2 & long2 is the business owner 
	function getDistance($lat1, $lng1, $lat2, $lng2, $miles = false)
	{
		$pi80 = M_PI / 180;
		$lat1 *= $pi80;
		$lng1 *= $pi80;
		$lat2 *= $pi80;
		$lng2 *= $pi80;
	
		$r = 6372.797; // mean radius of Earth in km
		$dlat = $lat2 - $lat1;
		$dlng = $lng2 - $lng1;
		$a = sin($dlat / 2) * sin($dlat / 2) + cos($lat1) * cos($lat2) * sin($dlng / 2) * sin($dlng / 2);
		$c = 2 * atan2(sqrt($a), sqrt(1 - $a));
		$km = $r * $c;
	
		return ($miles ? ($km * 0.621371192) : $km);
	}
}
?>