<?php
class csvBuilder {

	/*
	*		Takes in data and outputs a CSV file 
	*/


	private $db;
	private $data;
	private $horizontal;
	private $rowIndex;
	
	
	public function __construct($db) {
		$this->db = $db;
	}
	
	//The main function
	public function buildCSV($data, $horizontal = true) {
		//Override the default memory limit
		ini_set('memory_limit', '-1');
	
		//Set the class data
		$this->data = $data;
		$this->horizontal = $horizontal;
		$this->rowIndex = 0;
	
		//Set the data stream
		$csv = array();
	
		//Start compiling the data
		$header = $this->getHeaderRow();
		
		if(!is_null($header)) {
			$csv[$this->rowIndex] = '"'.implode('","',$header).'"';
			$this->rowIndex++;
		}
		
		//Get the main content 
		if($horizontal) {
			$csv = $this->buildHorizontalData($csv, $header);
		}
		else {
			$csv = $this->buildVerticalData($csv);		
		}
		
		
		//Test for empty data
		if(count($this->data) == 0) {
			$csv[$this->rowIndex] = 'No data to export';
		}
	
		//Create the CSV file with the above information and send it to the requesting page for download
		header("Content-type: text/plain");
		$file_name = "csv-export.csv";
		header('Content-Disposition: attachment; filename=' . $file_name);
		print implode("\r\n",$csv);
		die();
	
		return;
	}
	
	//Set the header row if the data is rendering horizontal
	private function getHeaderRow() {
		$header = array();
		
		//loop through all the data and get the key=>vals, if the direction is set to horizontal;
		if($this->horizontal) {
			foreach($this->data as $key=>$val) {
				foreach($val as $key=>$val) {
					array_push($header,$key);
				}
			}
			
			$header = array_unique($header);
		}
		
		return $header;
	}
	
	//Build the data for horizontal CSV
	private function buildHorizontalData($csv, $header) {
		
		//Loop through each Datarow		
		foreach($this->data as $row) {
			$row = json_decode(json_encode($row), true);
			
			$rowContent = array();
			//Loop through each data element
			foreach($header as $key) {
				if(isset($row[$key])) {
					array_push($rowContent, $row[$key]);
				}
				else {
					array_push($rowContent, '');
				}
			}
			
			$csv[$this->rowIndex] = '"'.implode('","',$rowContent).'"';
			$this->rowIndex++;
		}
	
		return $csv;
	}
	
	//Build the data for vertical CSV
	private function buildVerticalData($csv) {
		
		//Loop through each Datarow		
		foreach($this->data as $row) {
			
			//Loop through each data element
			foreach($row as $key=>$val) {
				$rowContent = array();
				
				//Load the row content with key=>val
				array_push($rowContent, $key);
				array_push($rowContent, $val);
				
				//Add the content to the csv array
				$csv[$this->rowIndex] = '"'.implode('","',$rowContent).'"';
				$this->rowIndex++;
			}
		}
	
		return $csv;
	}
	
	
	
	//Sample Data
	public function exportActions() {
	 	
	 	//Set the header row for the CSV document
		$header = array('Action ID','Action Title','Summary', 'Proposed Measure', 'Comments', 'Weighting');
		$csv[0] = '"'.implode('","',$header).'"';
		
		
		//Loop through all available actions and add them to the CSV document
		$i=1;
		
		foreach($report->actions as $action) {
		
			//If there is no commitment set for this action print the action
			//Otherwise test to see if the commitment merit is greater than or equal to the action demerit
			if($action->commitment_id == 0) {
				$csv[$i] = sprintf(
				'"%s","%s","%s","%s","%s","%s"',
				$action->action_id,
				$action->title,
				str_replace("&#176;"," degrees ",str_replace("\"","",strip_tags($action->summary))),
				str_replace("&#176;"," degrees ",str_replace("\"","",strip_tags($action->proposed_measure))),
				str_replace("&#176;"," degrees ",str_replace("\"","",strip_tags($action->comments))),
				((($action->demerits/$points)*100) . "%")
				);
				$i++;
			}
			else {
				foreach($report->commitments as $commitment) {
					if($commitment->commitment_id == $action->commitment_id) {
						if ($action->demerits > $commitment->merits) {
							$csv[$i] = sprintf(
							'"%s","%s","%s","%s","%s","%s"',
							$action->action_id,
							$action->title,
							str_replace("&#176;"," degrees ",str_replace("\"","",strip_tags($action->summary))),
							str_replace("&#176;"," degrees ",str_replace("\"","",strip_tags($action->proposed_measure))),
							str_replace("&#176;"," degrees ",str_replace("\"","",strip_tags($action->comments))),
							(((($action->demerits - $commitment->merits)/$points)*100) . "%")
							);
							$i++;
						}
					}
				}
			}
		}
		
		//Test to see if there are no actions
		if(count($report->actions) == 0) {
			$csv[1] = 'No actions to complete';
		}
	
		//Create the CSV file with the above information and send it to the requesting page for download
		header("Content-type: text/plain");
		$file_name = str_replace(" ","-","GreenBizCheck-" . $checklist->name . "-" . $checklist->client_checklist_id . "-Actions to complete.csv");
		header('Content-Disposition: attachment; filename=' . $file_name);
		print implode("\r\n",$csv);
		die();
	}

}

?>