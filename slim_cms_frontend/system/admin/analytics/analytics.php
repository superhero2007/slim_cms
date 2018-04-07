<?php
	
	//Get the Checklists
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`checklist`
		LEFT JOIN `%1$s`.`checklist_2_client_type` ON `checklist`.`checklist_id` = `checklist_2_client_type`.`checklist_id`
		WHERE 1
		' . resultFilter::conditional_checklist_filter($this->db, $this->user) . '
		' . resultFilter::conditional_checklist_id_filter($this->db, $this->user) . '
		ORDER BY `name` ASC;
	',
		DB_PREFIX.'checklist'
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'checklist');
		}
		$result->close();
	}

	//When the checklist_id is set we can get the checklist pages and the associated questions
	if(isset($_REQUEST['checklist_id']) && $_REQUEST['checklist_id'] > '0') {
		
		//Get the checklist pages
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`page`
			WHERE `checklist_id` = %2$d
			ORDER BY `page_id` ASC;
		',
			DB_PREFIX.'checklist',
			$_REQUEST['checklist_id']
		))) {
			while($row = $result->fetch_object()) {
				$this->row2config($row,'page');
			}
			$result->close();
		}
		
		//Get the checklist questions
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`question`
			WHERE `checklist_id` = %2$d
			ORDER BY `question_id` ASC;
		',
			DB_PREFIX.'checklist',
			$_REQUEST['checklist_id']
		))) {
			while($row = $result->fetch_object()) {
				$this->row2config($row,'question');
			}
			$result->close();
		}
	}
	
	//When the question_id is set we can get the answers and the client results
	if(isset($_REQUEST['question_id']) && $_REQUEST['question_id'] > '0') {
		
		//Get the answers
		if($result = $this->db->query(sprintf('
			SELECT
			`answer`.*,
			`answer_string`.`string`
			FROM `%1$s`.`answer`
			LEFT JOIN `%1$s`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
			WHERE `question_id` = %2$d
			ORDER BY `sequence` ASC;
		',
			DB_PREFIX.'checklist',
			$_REQUEST['question_id']
		))) {
			while($row = $result->fetch_object()) {			
				$this->row2config($row,'answer');
			}
			$result->close();
		}
		
		//Create a tally for the calculations and divisions
		$result_count = 0;
		$result_sum = 0;
		$answer_type = null;
		
		//Get the client results
		if($result = $this->db->query(sprintf('
			SELECT
			client_result.*,
			answer.answer_type
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id`
			WHERE `client_result`.`question_id` = %2$d
			AND `answer`.`answer_type` IS NOT NULL
			ORDER BY `timestamp` ASC;
		',
			DB_PREFIX.'checklist',
			$_REQUEST['question_id']
		))) {
			while($row = $result->fetch_object()) {
				//Make sure that we return a int or float for particular answers
				if($row->answer_type == 'range' || $row->answer_type == 'int' || $row->answer_type == 'percent') {
					$row->arbitrary_value = intval($row->arbitrary_value);
					if($row->answer_type == 'percent') {
						$answer_type = "%";
					}
				}
				else {
					if($row->answer_type == 'float') {
						$row->arbitrary_value = floatval($row->arbitrary_value);
					}
				}
				
				//Update counters
				$result_count = $result_count + 1;
				$result_sum = $result_sum + $row->arbitrary_value;
				
				$this->row2config($row,'client_result');
			}
			$result->close();
		}
		
		//Add the result counts to the XML
		$result_count_array = array(
									"result_count" => $result_count,
									"result_sum" => $result_sum,
									"result_average" => $result_count > 0 ? $result_sum/$result_count : "0",
									"band_bound" => $result_count > 0 ? round(($result_sum/$result_count)/10,-1) == 0 ? "10" : round(($result_sum/$result_count)/10,-1) : "0",
									"bands" => "10",
									"character" => is_null($answer_type) ? "" : $answer_type,
									);
									
		$this->row2config($result_count_array, 'result_count');
	}
	
	
	//Standard Reports
	
	//Checklist Pivot Tables
	if(isset($_REQUEST['report']) && $_REQUEST['report'] == "checklistPivotTableReport") {
	
		//Check for the checklist_id
		if(isset($_REQUEST['checklist_id']) && in_array($_REQUEST['checklist_id'], resultFilter::accessible_checklists($this->db, $this->user))) {

			//Checklist Data for Pivot Table
			$clientChecklist = new clientChecklist($this->db);
			$data = $clientChecklist->getChecklistResultsPivotTable($_REQUEST['checklist_id'], isset($_REQUEST['from']) ? $_REQUEST['from'] : null, isset($_REQUEST['to']) ? $_REQUEST['to'] : null);
	
			//Pivot Table Class
			$pivotTable = new pivotTable($this->db);	
			$pivotPoint = new stdClass();
			$pivotPoint->point = "client_checklist_id";
			$pivotPoint->column[] = array("question" => "answer");
			$data = $pivotTable->getPivotTable($data, $pivotPoint);
	
			//CSVBuilder Class
			$csvBuilder = new csvBuilder($this->db);
			$csvBuilder->buildCSV($data); 
		}
	
		die();
	}

	//Checklists
	if(isset($_REQUEST['report']) && $_REQUEST['report'] == "clientChecklistReport") {
	
		//Check for the checklist_id
		if(isset($_REQUEST['checklist_id']) && (in_array($_REQUEST['checklist_id'], resultFilter::accessible_checklists($this->db, $this->user))) || $_REQUEST['checklist_id'] == 0) {

			$client_checklist_id = $_REQUEST['checklist_id'] == 0 ? resultFilter::accessible_checklists($this->db, $this->user) : $_REQUEST['checklist_id'];

			//Checklist Data for Pivot Table
			$clientChecklist = new clientChecklist($this->db);
			$data = $clientChecklist->getChecklistResultsWithClientInformation($client_checklist_id, isset($_REQUEST['from']) ? $_REQUEST['from'] : null, isset($_REQUEST['to']) ? $_REQUEST['to'] : null);
	
			//CSVBuilder Class
			$csvBuilder = new csvBuilder($this->db);
			$csvBuilder->buildCSV($data); 
		}
	
		die();
	}



?>