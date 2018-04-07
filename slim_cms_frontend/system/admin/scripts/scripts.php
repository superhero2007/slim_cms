<?php

	//Check to see if an action is set, if so, run the action throught the switch
	if(isset($_REQUEST['action'])) {

		//Set the script processing limits
		set_time_limit(0);
		ini_set('memory_limit', '1024M');


		switch($_REQUEST['action']) {
			
			case 'encryptAllAdminPasswords':

				$password = new password($this->db);
				$password->encryptAllAdminPasswords();

				break;

			case 'encryptAllClientPasswords':
			
				$password = new password($this->db);
				$password->encryptAllPasswords();
	 
				break;

			case 'batchUpdateClientCoordinates':
				$client = new client($this->db);
				$client->batchUpdateClientCoordinates();

				break;

			case 'phpInfo':
				phpinfo();
				die();

				break;

			case 'serverVars':
				echo "<pre>";
				var_dump($_SERVER);
				echo "</pre>";
				die();

				break;

			case 'updateChecklistScores':
				if(isset($_REQUEST['client_checklist_id'])) {
					$clientChecklist = new clientChecklist($this->db);
					$clientChecklist->updateClientChecklistScoresByChecklistId($_REQUEST['client_checklist_id']);
				}

				break;

			case 'updateGdacs':
				$gdacs = new gdacs($this->db);
				$gdacs->updateGdacsFeed();

				break;

			case 'generateRandomAPIKey':
				$clientUtils = new clientUtils($this->db);
				$this->debug->debugOutput($clientUtils->generateRandomAPIKey());

				break;

			case 'processGHGTriggers':
				ghg::db($this->db)->processTriggers();

				break;
		}

		//return the script processing limits
		set_time_limit(30);
		ini_set('memory_limit', '200M');

		return;
	}


?>