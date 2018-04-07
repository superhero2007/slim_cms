<?php

//Takes data entered in an assessment and works out the Green House Gas Factor for Australia - Depending on State

class greenHouseGasCalculations {
	private $db;
	private $clientChecklistId;
	
	public function __construct($db) {
		$this->db = $db;
	}

	//We need to find the question - and answer string selected for this exact question in the client results - note that this question must be spelled exactly as show below to work properly	
	private function getStateFromReport($clientReport) {
		$state = "NSW";
		
		foreach($clientReport->questionAnswers as $qaArray) {
		 	foreach($qaArray as $qa) {
				if($qa->question == "In which State of Australia is your main business conducted" || $qa->question == "In which State of Australia is your main business conducted?") {
					$state = $qa->answer_string;
				}
			}
		}
		
		return $state;
	}
	
	//Get the period from the report	
	private function getPeriodFromReport($clientReport) {
		$period = new stdClass;
		
		foreach($clientReport->questionAnswers as $qaArray) {
		 	
		 	
		 	foreach($qaArray as $qa) {
				if($qa->answer_type == "date-month") {
					$period->year = substr($qa->arbitrary_value, 0, 4);
					$period->complete = $qa->arbitrary_value;
					$period->date_dmy = date('d/m/Y', strtotime($period->complete));
					$period->date_stamp = date('Ymd', strtotime($period->complete));
				}
			}
		}

		return $period;
	}
	
	//Figures out what kind of questions the client has answered and calculates a score
	public function calculateGhgScore($clientMetric, $clientReport, $clientChecklistId) {
		
		$this->clientChecklistId = $clientChecklistId;
		$state = $this->getStateFromReport($clientReport);
		$period = $this->getPeriodFromReport($clientReport);
		
		$months = $clientMetric->months;
		$value = $clientMetric->value;
		$description = $clientMetric->description;
		$metric = $clientMetric->metric;
		
		$calculated_value = null;
		
		switch($metric) {
		 
		 //Scope 1
		 
		 	case 'Natural Gas':
				$calculated_value = $this->getStateNaturalGasCalculatedScore($months,$value,$state, $description);
				break;
		 
			case 'LPG':
				$calculated_value = $this->getTotalMetricConsumption($months, $value, $description) * 1.5;
				break;
			
			case 'Diesel':
				$calculated_value = $this->getTotalMetricConsumption($months, $value, $description) * 2.63;
				break;
			
			//Check for any of these metrics as they can be labeled differently
			case 'Unleaded Petrol':
			case 'Petrol':
			case 'ULP':
				$calculated_value = $this->getTotalMetricConsumption($months, $value, $description) * 2.3;
				break;
				
			case 'E10':
				$calculated_value = $this->getTotalMetricConsumption($months, $value, $description) * 1.5;
				break;
				
		 //Scope 2
				
			case 'Electricity':
				$calculated_value = $this->getStateElectricityCalculatedScore($months,$value,$state);
				break;
				
		 //Scope 3
		 
			case 'Food Waste':
				$calculated_value = $this->getTotalMetricConsumptionWeight($months, $value, $description) * 1.60;
				break;
				
			case 'Paper Waste':
				$calculated_value = $this->getTotalMetricConsumptionWeight($months, $value, $description) * 2.5;
				break;		
								
			case 'Co-mingled Waste':
				$calculated_value = $this->getTotalMetricConsumptionWeight($months, $value, $description) * 1.2;
				break;
												
			case 'Commercial and Industrial Waste':
				$calculated_value = $this->getTotalMetricConsumptionWeight($months, $value, $description) * 1.10;
				break;
												
			case 'Road Freight Weight':
				$calculated_value = $this->getTotalMetricConsumptionWeightAndDistance('Road Freight', $months, $value, $description, '0.44');
				break;
				
			case 'Rail Freight Weight':
				$calculated_value = $this->getTotalMetricConsumptionWeightAndDistance('Rail Freight', $months, $value, $description, '0.03');
				break;
				
			case 'Sea Freight Weight':
				$calculated_value = $this->getTotalMetricConsumptionWeightAndDistance('Sea Freight', $months, $value, $description,'0.07');
				break;
				
			case 'Air Freight Weight':
				$calculated_value = $this->getTotalMetricConsumptionWeightAndDistance('Air Freight', $months, $value, $description,'2.23');
				break;
				
			case 'Short Business Travel':
				$calculated_value = $this->getTotalMetricConsumptionDistance($months, $value, $description) * 0.23;
				break;
				
			case 'Long Business Travel':
				$calculated_value = $this->getTotalMetricConsumptionDistance($months, $value, $description) * 0.19;
				break;
				
			//Not rendered in the report - just used for calculations
			case 'Road Freight Distance':
			case 'Rail Freight Distance':
			case 'Sea Freight Distance':
			case 'Air Freight Distance':
				$calculated_value = "ignore";
				break;
		}
		
		//Overide for $ values
		if($clientMetric->description == "dollars") {
			$calculated_value = "ignore";
		}
		
		$clientMetric->ghg_calculation = $calculated_value;
		$clientMetric->period = isset($period->year) ? $period->year : null;
		
		return $clientMetric;
	}
	
	//Figures out the total for the period the user has input - if litres are selected we need to get the kilolitres value 
	private function getTotalMetricConsumption($months, $value, $description) {
		$score = ($value/$months);
		//If litres was selected we need to convert to kilolitres by dividing by 1000
		if($description == "litres") {
			$score = $score/1000;
		}
		
		return $score;
	}
	
	//Figures out the total for the period the user has input
	private function getTotalMetricConsumptionWeight($months, $value, $description) {
		$score = ($value/$months);

		return $score;
	}
	
	//Figures out the total for the period the user has input
	private function getTotalMetricConsumptionDistance($months, $value, $description) {
		$score = ($value/$months);

		return $score;
	}
	
	//Figures out the total for the period the user has input
	private function getTotalMetricConsumptionWeightAndDistance($metric, $months, $value, $description, $ef) {
		//Get the value for distance as we already have the weight value
		$score = 0;
		
		$metric_distance = $this->getClientMetricFromMetricString($this->clientChecklistId, $metric . ' Distance');
		
		if((isset($months) && $months > 0) && (isset($metric_distance->months) && $metric_distance->months > 0)) {
			$score = $ef * ($value/$months) * ($metric_distance->value/$metric_distance->months);
		}
		
		return $score;
	}
	
	//All states has a different EF for Electricity therefore each of there calculations are different - this switch finds the correct score
	//Note all scores should be returned as either Litres, Kilograms or Kwh
	private function getStateElectricityCalculatedScore($months,$value,$state) {
		$calculated_score = null;
		
		switch($state) {
			case 'NSW':
			case 'ACT':
				$calculated_score = (((($value/$months))* 1.06)/1000);
				break;
			case 'VIC':
				$calculated_score = (((($value/$months))* 1.31)/1000);
				break;
			case 'QLD':
				$calculated_score = (((($value/$months))* 1.04)/1000);
				break;	
			case 'SA':
				$calculated_score = (((($value/$months))* 0.98)/1000);
				break;	
			case 'WA':
				$calculated_score = (((($value/$months))* 0.936)/1000);
				break;	
			case 'TAS':
				$calculated_score = (((($value/$months))* 0)/1000);
				break;	
			case 'NT':
				$calculated_score = (((($value/$months))* 0.95)/1000);
				break;	
		}
		
		return $calculated_score;
	}
	
	
	/*************************************************************************/
	/* The following functions are based on auto calculations */
	
	//public function called from the algorithm section of the assessment
	public function getGhgCalculatedValue($clientChecklistId, $metric, $stateQuestionId) {
		
	//	$this->clientChecklistId = $clientChecklistId;
	//	echo "CCID: " . $this->clientChecklistId;
		$state = $this->getStateFromQuestionId($clientChecklistId, $stateQuestionId);
		$clientMetric = $this->getClientMetricFromMetricString($clientChecklistId, $metric);
		
		$value = $this->getCalculatedGhgScore($clientMetric, $state);
		return $value;
	}
	
	//Take the cient_checklist_id and the metric string to return the complete client metric
	private function getClientMetricFromMetricString($clientChecklistId, $metric) {		
		$clientMetric = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			`client_metric`.`months`,
			`client_metric`.`value`,
			`metric_unit_type`.`description`,
			`metric`.`metric`
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`metric` ON `client_metric`.`metric_id` = `metric`.`metric_id`
			LEFT JOIN `%1$s`.`metric_unit_type` ON `client_metric`.`metric_unit_type_id` = `metric_unit_type`.`metric_unit_type_id`
			WHERE `client_metric`.`client_checklist_id` = %2$d
			AND `metric`.`metric` = "%3$s";
		',
			DB_PREFIX.'checklist',
			$clientChecklistId,
			$metric
		))) {
			while($row = $result->fetch_object()) {
				$clientMetric = $row;
			}
			$result->close();			
		}
		
		return $clientMetric;
	}
	
	//Takes the clientChecklistId and state question_id to locate the state answer string - required for some calculated results
	private function getStateFromQuestionId($clientChecklistId, $stateQuestionId) {
		//Set a default state
		$state = 'NSW';
		
		if($result = $this->db->query(sprintf('
			SELECT
			`answer_string`.`string`
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id`
			LEFT JOIN `%1$s`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
			WHERE `client_result`.`question_id` = %3$d
			AND `client_result`.`client_checklist_id` = %2$d
			LIMIT 1;
		',
			DB_PREFIX.'checklist',
			$clientChecklistId,
			$stateQuestionId
		))) {
			while($row = $result->fetch_object()) {
				$state = $row->answer_string;
			}
			$result->close();			
		}
		
		return $state;
	}
	
	//Each state has a different emmisions factor
	private function getStateNaturalGasCalculatedScore($months,$value,$state,$description) {
		$calculated_score = 0.0;
		
		switch($description) {
			case 'kilowatt hours':
				//Calculate the score and then multiply by the state percentage
				$calculated_score = (($value/$months) * 0.18404);
				switch($state) {
					case 'NSW':
					case 'ACT':
						$calculated_score = ($calculated_score * (111.76/100));
						break;
					case 'VIC':
						$calculated_score = ($calculated_score * (92.13/100));
						break;
					case 'QLD':
						$calculated_score = ($calculated_score * (90.48/100));
						break;	
					case 'SA':
						$calculated_score = ($calculated_score * (107.64/100));
						break;	
					case 'WA':
						$calculated_score = ($calculated_score * (105.81/100));
						break;	
					case 'TAS':
						$calculated_score = ($calculated_score * (100/100));
						break;	
					case 'NT':
						$calculated_score = ($calculated_score * (92.19/100));
						break;
				}
				break;
			case 'therm':
				//Calculate the score and then multiply by the state percentage
				$calculated_score = (($value/$months) * 5.39421);
				switch($state) {
					case 'NSW':
					case 'ACT':
						$calculated_score = ($calculated_score * (111.76/100));
						break;
					case 'VIC':
						$calculated_score = ($calculated_score * (92.13/100));
						break;
					case 'QLD':
						$calculated_score = ($calculated_score * (90.48/100));
						break;	
					case 'SA':
						$calculated_score = ($calculated_score * (107.64/100));
						break;	
					case 'WA':
						$calculated_score = ($calculated_score * (105.81/100));
						break;	
					case 'TAS':
						$calculated_score = ($calculated_score * (100/100));
						break;	
					case 'NT':
						$calculated_score = ($calculated_score * (92.19/100));
						break;
				}
				break;
			case 'kilograms':
				//Calculate the score and then multiply by the state percentage
				$calculated_score = (($value/$months) * 2.82530672268908);
				switch($state) {
					case 'NSW':
					case 'ACT':
						$calculated_score = ($calculated_score * (111.76/100));
						break;
					case 'VIC':
						$calculated_score = ($calculated_score * (92.13/100));
						break;
					case 'QLD':
						$calculated_score = ($calculated_score * (90.48/100));
						break;	
					case 'SA':
						$calculated_score = ($calculated_score * (107.64/100));
						break;	
					case 'WA':
						$calculated_score = ($calculated_score * (105.81/100));
						break;	
					case 'TAS':
						$calculated_score = ($calculated_score * (100/100));
						break;	
					case 'NT':
						$calculated_score = ($calculated_score * (92.19/100));
						break;
				}
				break;
			case 'cubic metres':
				//Calculate the score and then multiply by the state percentage
				$calculated_score = (($value/$months) * 2.017269);
				switch($state) {
					case 'NSW':
					case 'ACT':
						$calculated_score = ($calculated_score * (111.76/100));
						break;
					case 'VIC':
						$calculated_score = ($calculated_score * (92.13/100));
						break;
					case 'QLD':
						$calculated_score = ($calculated_score * (90.48/100));
						break;	
					case 'SA':
						$calculated_score = ($calculated_score * (107.64/100));
						break;	
					case 'WA':
						$calculated_score = ($calculated_score * (105.81/100));
						break;	
					case 'TAS':
						$calculated_score = ($calculated_score * (100/100));
						break;	
					case 'NT':
						$calculated_score = ($calculated_score * (92.19/100));
						break;
				}
				break;
			case 'gigajoule':
				switch($state) {
					case 'NSW':
					case 'ACT':
						$calculated_score = ((($value/$months))* 67.73);
						break;
					case 'VIC':
						$calculated_score = ((($value/$months))* 55.83);
						break;
					case 'QLD':
						$calculated_score = ((($value/$months))* 54.83);
						break;	
					case 'SA':
						$calculated_score = ((($value/$months))* 65.23);
						break;	
					case 'WA':
						$calculated_score = ((($value/$months))* 64.12);
						break;	
					case 'TAS':
						$calculated_score = ((($value/$months))* 0.0);
						break;	
					case 'NT':
						$calculated_score = ((($value/$months))* 55.87);
						break;
				}
				break;	
		}
		
		return ($calculated_score/1000);
	}

	public function getFormatedEntryResults($reports) {
		$dataSeries = new stdClass;
		$dataSeries->data = array();

		foreach($reports as $report) {
			$tonnes = 0;
			$period = $this->getPeriodFromReport($report);

			foreach($report->metricGroups as $metricGroup) {	 	
			 	//Test to see if it is a GHG Assessment - Type 2 with NRA and the like
			 	if($metricGroup->metric_group_type_id = '2') {
					//Attach each metric to the parent metric group
					foreach($report->clientMetrics as $clientMetric) {
					 	if($clientMetric->metric_group_id == $metricGroup->metric_group_id){
					 		//Get the GHG Calculation
					 		$ghg_value = $this->calculateGhgScore($clientMetric, $report, $report->client_checklist_id);
					 		$tonnes += is_numeric($ghg_value->ghg_calculation) ? $ghg_value->ghg_calculation : 0;
						}
					}
				}
			}

			$entryValue = new stdClass;
			$entryValue->value = round($tonnes);
			$entryValue->date = $period->date_dmy;
			$entryValue->date_stamp = $period->date_stamp;
			$dataSeries->data[] = $entryValue;
		}
		
		usort($dataSeries->data, array($this, "formatedEntryResultSort"));

		return $dataSeries;
	}

	private function formatedEntryResultSort($a, $b) {
	    return strcmp($a->date_stamp, $b->date_stamp);
	}
}

?>