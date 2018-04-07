<?php

$randomizer = new randomizer($this->db);

//Generate the scripts for insert
if(isset($_REQUEST['action']) && $_REQUEST['action'] == 'generate') {

	//If the client count is set, loop through the insert statements
	if($_REQUEST['client_number'] > 0) {
	
		// Override any maximum execution time.
		set_time_limit(0);
		ini_set('memory_limit', '1024M');
	
			//Update the end user as to the progress
			//echo "<p>Starting the generation process!</p>";
			// Send output to browser immediately
			flush();

			// Sleep one second so we can see the delay
			sleep(1);
	
		for($i = 0; $i < $_REQUEST['client_number']; $i++) {
			
			$company_name = $randomizer->getRandomCompanyName();
			$address = $randomizer->getRandomAddress((isset($_REQUEST['country']) && $_REQUEST['country'] != '0' ? $_REQUEST['country'] : NULL));
			$industry = $randomizer->getRandomIndustry((isset($_REQUEST['industry']) && $_REQUEST['industry'] != '0' ? $_REQUEST['industry'] : NULL));
			$client_type = $randomizer->getRandomClientType((isset($_REQUEST['client_type']) && $_REQUEST['client_type'] != '0' ? $_REQUEST['client_type'] : NULL));
			
			//Insert the client into the database
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`client` SET
					`client_type_id` = %2$d,
					`company_name` = "%3$s",
					`address_line_1` = "%4$s",
					`address_line_2` = "%5$s",
					`suburb` = "%6$s",
					`state` = "%7$s",
					`postcode` = "%8$s",
					`country` = "%9$s",
					`anzsic_id` = %10$d,
					`source` = "%11$s";
			',
				DB_PREFIX.'core',
				$client_type,
				$company_name,
				$address->address_line_1,
				$address->address_line_2,
				$address->suburb,
				$address->state,
				$address->postcode,
				$address->country,
				$industry,
				$_REQUEST['source']
			));
			
			//Get the client_id
			$client_id = $this->db->insert_id;
		
			//Now that we have generated a client account, check to see if we need to generate a clientChecklist
			if($_REQUEST['checklist_number'] > 0) {
				$clientChecklist = new clientChecklist($this->db);
				$assessmentTools = new assessmentTools($this->db);
				$checklistTime = strtotime(time());
				
				for($j = 0; $j < $_REQUEST['checklist_number']; $j++) {
					$clientChecklistId = $clientChecklist->autoIssueChecklist($_REQUEST['checklist_id'], $client_id);
					
					//Update the created time of the clientChecklist so we can have year on year
					//$checklistTime = strtotime("-" . $j . " year", time());
					$seedYear = isset($_REQUEST['seed-year']) ? $_REQUEST['seed-year'] . date("-m-d h:i:s") : date("Y-m-d h:i:s");
					$checklistTime = $j > 0 ? strtotime($seedYear . " - ". $j . " YEAR") : strtotime($seedYear);
					
					$query = sprintf('
						UPDATE `%1$s`.`client_checklist` SET
							`created` = "%3$s"
						WHERE `client_checklist_id` = %2$d;
					',
						DB_PREFIX.'checklist',
						$clientChecklistId,
						date("Y-m-d H:i:s", $checklistTime)
					);

					$this->db->query($query);
					
					//Check to see if auto complete has been chosen
					if($_REQUEST['auto_complete_checklist'] == 'yes') {
						$assessmentTools->autoCompleteChecklist($clientChecklistId, isset($_REQUEST['skew']) ? $_REQUEST['skew'] : null, isset($_REQUEST['skew_multiplier']) ? $_REQUEST['skew_multiplier']: null);
					}
				}
				
				//Now update the client created timestamp to be that of the oldest clientChecklist				
				$this->db->query(sprintf('
					UPDATE `%1$s`.`client` SET
						`registered` = "%3$s"
					WHERE `client_id` = %2$d;
				',
					DB_PREFIX.'core',
					$client_id,
					date("Y-m-d H:i:s", $checklistTime) //oldest client checklist time
				));
				
				//Now put in the current time as the last time that they were active
				$this->db->query(sprintf('
					INSERT INTO `%1$s`.`client_log` SET
						`client_id` = %2$d,
						`timestamp` = "%3$s";
				',
					DB_PREFIX.'core',
					$client_id,
					date("Y-m-d H:i:s") //current time
				));
			}
			
			//Update the end user as to the progress
			//echo "<p>" . ($i + 1) . " of " . $_REQUEST["client_number"] . " completed!</p>";
			// Send output to browser immediately
    		flush();

			// Sleep one second so we can see the delay
    		sleep(1);
		}
		
		// Change the timeout back to 30 seconds after completed.
		set_time_limit(30);
		ini_set('memory_limit', '200M');
		//echo "<p>Finished the generation process!</p>";
	}
}

//Client Type
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

//Industry
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`anzsic`;
',
	DB_PREFIX.'resources'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'anzsic_insdustry');
	}
	$result->close();
}

//Checklists 
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`checklist`
	ORDER BY name;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'checklist');
	}
	$result->close();
}

//Seed year
for($i = (int)date("Y"); $i > (int)date("Y")-100; $i--) {
	$year = new stdClass;
	$year->year = $i;
	$this->row2config($year,'year');
}


?>