<?php
class timeAndDate {
	private $defaultSeedDate;
	private $dateFormat;
	
	public function __construct() {
		$this->dateFormat = "Y-m-d";
		$this->defaultSeedDate = date($this->dateFormat);
	}

	//Get the Financial Year for Australia
	//iterations: provides the loops back in time eg YEARS
	//offset: the period where we start counting from
	//seedDate: the start date
	public function getFinancialYearAustralia($iterations = 1, $offset = null, $seedDate = null) {
		$iterations = is_null($iterations) ? 1 : $iterations;
		$offset = is_null($offset) ? "-0" : $offset;
		$seedDate = is_null($seedDate) ? date($this->dateFormat, strtotime($this->defaultSeedDate . " " . $offset . " YEAR")) : $seedDate;
		$dates = array();

		$startTime = date("Y-m-d", strtotime("1 JULY " . (date("Y", date("n", strtotime($seedDate)) < 7 ? strtotime($seedDate . " -1 YEAR") : strtotime($seedDate)))));
		for($i = 0; $i < $iterations; $i++) {
			$newStartTime = date("Y-m-d", strtotime($startTime . " - " . $i . " YEAR"));
			$newFinishTime = date("Y-m-d", strtotime("30 JUNE " . date("Y", (strtotime($newStartTime . " + 1 YEAR")))));
			
			$period = new stdClass;
			$period->label = date("Y", strtotime($newStartTime)) . "/" . date("Y", strtoTime($newFinishTime)) . " FY";
			$period->date_range_start = date("Y-m-d 00:00:00", strtotime($newStartTime));
			$period->date_range_finish = date("Y-m-d 23:59:59", strtotime($newFinishTime));
			
			$dates[] = $period;
		}
		
		return $dates;
	}

	//Get the previous months
	//iterations: provides the loops back in time eg Months
	//offset: the period where we start counting from
	//seedDate: the start date
	public function getPreviousMonths($iterations = 1, $offset = "-1", $seedDate = null) {
		$iterations = is_null($iterations) ? 1 : $iterations;
		$offset = is_null($offset) ? "-1" : $offset;
		$seedDate = is_null($seedDate) ? $this->defaultSeedDate : $seedDate;
		$dates = array();
		$startTime = date("Y-m-01", strtotime($seedDate . " " . $offset . " MONTH"));
		for($i = 0; $i < $iterations; $i++) {
			$newStartTime = date("Y-m-d", strtotime($startTime . " - " . $i . " MONTH"));
			$newFinishTime = date("Y-m-t", strtotime($newStartTime));
			
			$period = new stdClass;
			$period->label = date("F", strtotime($newStartTime)) . " " . date("Y", strtoTime($newStartTime));
			$period->date_range_start = date("Y-m-d 00:00:00", strtotime($newStartTime));
			$period->date_range_finish = date("Y-m-d 23:59:59", strtotime($newFinishTime));
			
			$dates[] = $period;
		}
		
		return $dates;
	}

	public function getPreviousYears($iterations = 1, $offset = null, $seedDate = null) {
		$iterations = is_null($iterations) ? 1 : $iterations;
		$offset = is_null($offset) ? "-0" : $offset;
		$seedDate = is_null($seedDate) ? $this->defaultSeedDate : $seedDate;
		$dates = array();
		$startTime = date("Y-01-01", strtotime($seedDate . " " . $offset . " YEAR"));
		for($i = 0; $i < $iterations; $i++) {
			$newStartTime = date("Y-m-d", strtotime($startTime . " - " . $i . " YEAR"));
			$newFinishTime = date("Y-m-d", strtotime("31 DECEMBER " . date("Y", (strtotime($newStartTime)))));
			
			$period = new stdClass;
			$period->label = date("Y", strtoTime($newStartTime));
			$period->date_range_start = date("Y-m-d 00:00:00", strtotime($newStartTime));
			$period->date_range_finish = date("Y-m-d 23:59:59", strtotime($newFinishTime));
			
			$dates[] = $period;
		}
		
		return $dates;
	}

	public function getEndOfPeriod($date, $period = 'month') {
		$endOfPeriod = null;

		switch($period) {

			case 'month':
				$endOfPeriod = date('Y-m-t 23:59:59', strtotime($date));
				break;

			case 'fy_au':
				$endOfPeriod = date("Y-06-30 23:59:59", strtotime(date("Y-m-d", date("n", strtotime($date)) >= 7 ? strtotime($date . " + 1 YEAR") : strtotime($date))));
				break;

		}

		return $endOfPeriod;
	}

}