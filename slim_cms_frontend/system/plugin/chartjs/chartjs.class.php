<?php
class chartjs extends plugin {
	private $clientChecklist;
	private $client_id;
	private $client_checklist_id;
	private $contact;

	public function __construct() {
		$this->contact = clientContact::stGetClientContactById($GLOBALS['core']->db, $GLOBALS['core']->session->get('uid'));
		$this->clientChecklist = new clientChecklist($this->clientChecklist);
	}

	public function drawChart() {
		$params = $this->setParams();
		$this->setClientIdentifiers($params);

		if(isset($params->chart)) {
			switch($params->chart) {

				//AusLSA Charts
				case 'auslsa-emissions-pie-chart': $this->ausLsaEmissionsPieChart();
				break;

				case 'auslsa-electricity-line-chart': $this->ausLsaElectricityLineChart();
				break;

				case 'auslsa-naturalgas-line-chart': $this->ausLsaNaturalGasLineChart();
				break;

				case 'auslsa-domesticairtravel-line-chart': $this->ausLsaDomesticAirTravelLineChart();
				break;

				case 'auslsa-internationalairtravel-line-chart': $this->ausLsaInternationalAirTravelLineChart();
				break;

				case 'auslsa-cartravel-line-chart': $this->ausLsaCarTravelLineChart();
				break;

				case 'auslsa-paper-bar-chart': $this->ausLsaPaperBarChart();
				break;

				case 'auslsa-offsets-bar-chart': $this->ausLsaOffsetsBarChart();
				break;


				//TWE Charts
				case 'twe-site-h2o-useage-chart': $this->tweSiteH2oUseageChart($params);
				break;

				case 'twe-site-energy-useage-chart': $this->tweSiteEnergyUseageChart();
				break;

				case 'twe-site-waste-pie-chart': $this->tweSiteWastePieChart();
				break;

				case 'twe-site-water-efficiency': $this->tweSiteWaterEfficiency();
				break;

				case 'twe-site-energy-efficiency': $this->tweSiteEnergyEfficiency();
				break;

				//Bank Australia Charts
				case 'ba-indigenous-owned-business': $this->bankAustraliaIndigenousOwnedBusiness();
				break;

				case 'ba-yearly-spend': $this->baYearlySpend();
				break;

				case 'ba-carbon-neutrality': $this->baCarbonNeutrality();
				break;


				//Generic Charts
				case 'user-access-30-days': $this->userAccess30Days();
				break;

				case 'average-score-timeline-chart': $this->averageScoreTimelineChart();
				break;

				case 'climate-change-chart': $this->climateChangeChart();
				break;

				case 'child-labour-chart': $this->childLabourChart();
				break;

				case 'indigenous-owned-business': $this->indigenousOwnedBusiness();
				break;

				case 'female-owned-business': $this->femaleOwnedBusiness();
				break;

				case 'australian-owned-business': $this->australianOwnedBusiness();
				break;

				case 'indigenous-gender-owned-business': $this->indigenousGenderOwnedBusiness();
				break;

				case 'australian-owned-business-timeline-chart': $this->australianOwnedBusinessTimelineChart();
				break;

				case 'indigenous-gender-owned-business-timeline-chart': $this->indigenousGenderOwnedBusinessTimelineChart();
				break;
			}

			//Set the chart name on the node
			$this->node->setAttribute('chart',$params->chart);
		}

		return;
	}

	private function setClientIdentifiers($params) {
		if(isset($params->mode) && $params->mode === 'dashboard') {
			$this->client_id = is_array(resultFilter::filtered_client_array($this->db, $this->contact)) ? implode(',', resultFilter::filtered_client_array($this->db, $this->contact)) : resultFilter::filtered_client_array($this->db, $this->contact);

			$this->client_checklist_id = is_array(resultFilter::filtered_client_array($this->db, $this->contact)) ? implode(',', resultFilter::filtered_client_checklist_array($this->db, $this->contact)) : resultFilter::filtered_client_array($this->db, $this->contact);
			
		} else {
			$this->client_id = isset($GLOBALS['core']->plugin->clients->client->client_id) ? $GLOBALS['core']->plugin->clients->client->client_id : null;
		}

		return;
	}

	//
	// AusLSA Chart Queries
	//
	private function ausLsaEmissionsPieChart() {
		$client_checklist_id = $GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) -1]; 

		$query = sprintf('
			SELECT
			`additional_value`.`key` AS `label`,
			ROUND(SUM(`additional_value`.`value`)) AS `data`,
			\"1\" AS `series`
			FROM `%1$s`.`additional_value`
			WHERE 1
			AND `additional_value`.`group` = \"Emmission\"
			%2$s
			GROUP BY `key`
			ORDER BY `series`, `label`;
		',
			DB_PREFIX.'checklist',
			isset($client_checklist_id) && is_numeric($client_checklist_id) ? " AND `additional_value`.`client_checklist_id` = '" . $client_checklist_id . "' " : ""
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function ausLsaElectricityLineChart() {
		$client_checklist_id = $GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) -1]; 

		$query = sprintf('
			SELECT
			`siblings`.`client_checklist_id`,
			DATE_FORMAT(`siblings`.`date_range_finish`, \"%%Y\") AS `label`,
			\"Overall Emissions\" AS `series1`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`),0),2) 
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`key` IN(\"Purchased Electricity\", \"Green Tariff Electricity\")
			) AS `data1`,
			\"Emissions Per Employee\" AS `series2`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`) / `client_result`.`arbitrary_value`,0),4)
			    FROM `%1$s`.`additional_value`
			    LEFT JOIN `%1$s`.`client_result` ON `client_result`.`client_checklist_id` = `additional_value`.`client_checklist_id`
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id`
			    AND `additional_value`.`key` IN(\"Purchased Electricity\", \"Green Tariff Electricity\")
			    AND `client_result`.`answer_id` = \"33160\"
			) AS `data2`,
			\"Emissions Per m2\" AS `series3`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`) / `client_result`.`arbitrary_value`,0),4)
			    FROM `%1$s`.`additional_value`
			    LEFT JOIN `%1$s`.`client_result` ON `client_result`.`client_checklist_id` = `additional_value`.`client_checklist_id`
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id`
			    AND `additional_value`.`key` IN(\"Purchased Electricity\", \"Green Tariff Electricity\")
			    AND `client_result`.`answer_id` = \"33161\"
			) AS `data3`,

				@benchmark_year := IF(DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y\") = \"2017\", DATE_FORMAT(`siblings`.`date_range_finish`,\"2016-%%m-%%d\"), DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y-%%m-%%d\")),
				@year_staff := (SELECT SUM(`client_result`.`arbitrary_value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`client_result` ON `client_checklist`.`client_checklist_id` = `client_result`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `client_result`.`answer_id` = \"33160\"),
				@year_area := (SELECT SUM(`client_result`.`arbitrary_value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`client_result` ON `client_checklist`.`client_checklist_id` = `client_result`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `client_result`.`answer_id` = \"33161\"),
				@year_electricity := (SELECT SUM(`additional_value`.`value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`additional_value` ON `client_checklist`.`client_checklist_id` = `additional_value`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `additional_value`.`key` IN(\"Purchased Electricity\", \"Green Tariff Electricity\")),
				ROUND(IFNULL((@year_electricity / @year_staff),0),4) AS `data4`,
				\"Benchmark Per Employee\" AS `series4`,
				ROUND(IFNULL((@year_electricity / @year_area),0),4) AS `data5`,
				\"Benchmark Per m2\" AS `series5`

			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%1$s`.`client_checklist` `siblings` ON `client_checklist`.`checklist_id` = `siblings`.`checklist_id` AND `client_checklist`.`client_id` = `siblings`.`client_id`
			WHERE 1
			%2$s
			AND `siblings`.`date_range_finish` IS NOT NULL
			GROUP BY `client_checklist_id`
			ORDER BY `siblings`.`date_range_finish`;
		',
			DB_PREFIX.'checklist',
			isset($client_checklist_id) && is_numeric($client_checklist_id) ? " AND `client_checklist`.`client_checklist_id` = '" . $client_checklist_id . "' " : ""
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function ausLsaNaturalGasLineChart() {
		$client_checklist_id = $GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) -1]; 

		$query = sprintf('
			SELECT
			`siblings`.`client_checklist_id`,
			DATE_FORMAT(`siblings`.`date_range_finish`, \"%%Y\") AS `label`,
			\"Overall Emissions\" AS `series1`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`),0),2) 
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`key` IN(\"On-Site Combustion\")
			) AS `data1`,
			\"Emissions Per Employee\" AS `series2`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`) / `client_result`.`arbitrary_value`,0),4)
			    FROM `%1$s`.`additional_value`
			    LEFT JOIN `%1$s`.`client_result` ON `client_result`.`client_checklist_id` = `additional_value`.`client_checklist_id`
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id`
			    AND `additional_value`.`key` IN(\"On-Site Combustion\")
			    AND `client_result`.`answer_id` = \"33160\"
			) AS `data2`,
			\"Emissions Per m2\" AS `series3`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`) / `client_result`.`arbitrary_value`,0),4)
			    FROM `%1$s`.`additional_value`
			    LEFT JOIN `%1$s`.`client_result` ON `client_result`.`client_checklist_id` = `additional_value`.`client_checklist_id`
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id`
			    AND `additional_value`.`key` IN(\"On-Site Combustion\")
			    AND `client_result`.`answer_id` = \"33161\"
			) AS `data3`,

				@benchmark_year := IF(DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y\") = \"2017\", DATE_FORMAT(`siblings`.`date_range_finish`,\"2016-%%m-%%d\"), DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y-%%m-%%d\")),
				@year_staff := (SELECT SUM(`client_result`.`arbitrary_value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`client_result` ON `client_checklist`.`client_checklist_id` = `client_result`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `client_result`.`answer_id` = \"33160\"),
				@year_area := (SELECT SUM(`client_result`.`arbitrary_value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`client_result` ON `client_checklist`.`client_checklist_id` = `client_result`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `client_result`.`answer_id` = \"33161\"),
				@year_electricity := (SELECT SUM(`additional_value`.`value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`additional_value` ON `client_checklist`.`client_checklist_id` = `additional_value`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `additional_value`.`key` IN(\"On-Site Combustion\")),
				ROUND(IFNULL((@year_electricity / @year_staff),0),4) AS `data4`,
				\"Benchmark Per Employee\" AS `series4`,
				ROUND(IFNULL((@year_electricity / @year_area),0),4) AS `data5`,
				\"Benchmark Per m2\" AS `series5`

			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%1$s`.`client_checklist` `siblings` ON `client_checklist`.`checklist_id` = `siblings`.`checklist_id` AND `client_checklist`.`client_id` = `siblings`.`client_id`
			WHERE 1
			%2$s
			AND `siblings`.`date_range_finish` IS NOT NULL
			GROUP BY `client_checklist_id`
			ORDER BY `siblings`.`date_range_finish`;
		',
			DB_PREFIX.'checklist',
			isset($client_checklist_id) && is_numeric($client_checklist_id) ? " AND `client_checklist`.`client_checklist_id` = '" . $client_checklist_id . "' " : ""
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function ausLsaDomesticAirTravelLineChart() {
		$client_checklist_id = $GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) -1]; 

		$query = sprintf('
			SELECT
			`siblings`.`client_checklist_id`,
			DATE_FORMAT(`siblings`.`date_range_finish`, \"%%Y\") AS `label`,
			\"Overall Emissions\" AS `series1`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`),0),2) 
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`key` IN(\"Flights - Short Haul\")
			) AS `data1`,
			\"Emissions Per Employee\" AS `series2`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`) / `client_result`.`arbitrary_value`,0),4)
			    FROM `%1$s`.`additional_value`
			    LEFT JOIN `%1$s`.`client_result` ON `client_result`.`client_checklist_id` = `additional_value`.`client_checklist_id`
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id`
			    AND `additional_value`.`key` IN(\"Flights - Short Haul\")
			    AND `client_result`.`answer_id` = \"33160\"
			) AS `data2`,

				@benchmark_year := IF(DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y\") = \"2017\", DATE_FORMAT(`siblings`.`date_range_finish`,\"2016-%%m-%%d\"), DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y-%%m-%%d\")),
				@year_staff := (SELECT SUM(`client_result`.`arbitrary_value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`client_result` ON `client_checklist`.`client_checklist_id` = `client_result`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `client_result`.`answer_id` = \"33160\"),
				@year_electricity := (SELECT SUM(`additional_value`.`value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`additional_value` ON `client_checklist`.`client_checklist_id` = `additional_value`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `additional_value`.`key` IN(\"Flights - Short Haul\")),
				ROUND(IFNULL((@year_electricity / @year_staff),0),4) AS `data3`,
				\"Benchmark Per Employee\" AS `series3`

			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%1$s`.`client_checklist` `siblings` ON `client_checklist`.`checklist_id` = `siblings`.`checklist_id` AND `client_checklist`.`client_id` = `siblings`.`client_id`
			WHERE 1
			%2$s
			AND `siblings`.`date_range_finish` IS NOT NULL
			GROUP BY `client_checklist_id`
			ORDER BY `siblings`.`date_range_finish`;
		',
			DB_PREFIX.'checklist',
			isset($client_checklist_id) && is_numeric($client_checklist_id) ? " AND `client_checklist`.`client_checklist_id` = '" . $client_checklist_id . "' " : ""
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function ausLsaInternationalAirTravelLineChart() {
		$client_checklist_id = $GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) -1]; 

		$query = sprintf('
			SELECT
			`siblings`.`client_checklist_id`,
			DATE_FORMAT(`siblings`.`date_range_finish`, \"%%Y\") AS `label`,
			\"Overall Emissions\" AS `series1`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`),0),2) 
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`key` IN(\"Flights - International\")
			) AS `data1`,
			\"Emissions Per Employee\" AS `series2`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`) / `client_result`.`arbitrary_value`,0),4)
			    FROM `%1$s`.`additional_value`
			    LEFT JOIN `%1$s`.`client_result` ON `client_result`.`client_checklist_id` = `additional_value`.`client_checklist_id`
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id`
			    AND `additional_value`.`key` IN(\"Flights - International\")
			    AND `client_result`.`answer_id` = \"33160\"
			) AS `data2`,

				@benchmark_year := IF(DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y\") = \"2017\", DATE_FORMAT(`siblings`.`date_range_finish`,\"2016-%%m-%%d\"), DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y-%%m-%%d\")),
				@year_staff := (SELECT SUM(`client_result`.`arbitrary_value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`client_result` ON `client_checklist`.`client_checklist_id` = `client_result`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `client_result`.`answer_id` = \"33160\"),
				@year_electricity := (SELECT SUM(`additional_value`.`value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`additional_value` ON `client_checklist`.`client_checklist_id` = `additional_value`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `additional_value`.`key` IN(\"Flights - International\")),
				ROUND(IFNULL((@year_electricity / @year_staff),0),4) AS `data3`,
				\"Benchmark Per Employee\" AS `series3`

			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%1$s`.`client_checklist` `siblings` ON `client_checklist`.`checklist_id` = `siblings`.`checklist_id` AND `client_checklist`.`client_id` = `siblings`.`client_id`
			WHERE 1
			%2$s
			AND `siblings`.`date_range_finish` IS NOT NULL
			GROUP BY `client_checklist_id`
			ORDER BY `siblings`.`date_range_finish`;
		',
			DB_PREFIX.'checklist',
			isset($client_checklist_id) && is_numeric($client_checklist_id) ? " AND `client_checklist`.`client_checklist_id` = '" . $client_checklist_id . "' " : ""
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function ausLsaCarTravelLineChart() {
		$client_checklist_id = $GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) -1]; 

		$query = sprintf('
			SELECT
			`siblings`.`client_checklist_id`,
			DATE_FORMAT(`siblings`.`date_range_finish`, \"%%Y\") AS `label`,
			\"Overall Emissions\" AS `series1`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`),0),2) 
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`key` IN(\"Company Vehicles\", \"Hire Cars\", \"Personal Vehicles\", \"Taxis\")
			) AS `data1`,
			\"Emissions Per Employee\" AS `series2`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`) / `client_result`.`arbitrary_value`,0),4)
			    FROM `%1$s`.`additional_value`
			    LEFT JOIN `%1$s`.`client_result` ON `client_result`.`client_checklist_id` = `additional_value`.`client_checklist_id`
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id`
			    AND `additional_value`.`key` IN(\"Company Vehicles\", \"Hire Cars\", \"Personal Vehicles\", \"Taxis\")
			    AND `client_result`.`answer_id` = \"33160\"
			) AS `data2`,

				@benchmark_year := IF(DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y\") = \"2017\", DATE_FORMAT(`siblings`.`date_range_finish`,\"2016-%%m-%%d\"), DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y-%%m-%%d\")),
				@year_staff := (SELECT SUM(`client_result`.`arbitrary_value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`client_result` ON `client_checklist`.`client_checklist_id` = `client_result`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `client_result`.`answer_id` = \"33160\"),
				@year_electricity := (SELECT SUM(`additional_value`.`value`)
					FROM `%1$s`.`client_checklist`
				    LEFT JOIN `%1$s`.`additional_value` ON `client_checklist`.`client_checklist_id` = `additional_value`.`client_checklist_id`
				    WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				    AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				    AND `additional_value`.`key` IN(\"Company Vehicles\", \"Hire Cars\", \"Personal Vehicles\", \"Taxis\")),
				ROUND(IFNULL((@year_electricity / @year_staff),0),4) AS `data3`,
				\"Benchmark Per Employee\" AS `series3`

			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%1$s`.`client_checklist` `siblings` ON `client_checklist`.`checklist_id` = `siblings`.`checklist_id` AND `client_checklist`.`client_id` = `siblings`.`client_id`
			WHERE 1
			%2$s
			AND `siblings`.`date_range_finish` IS NOT NULL
			GROUP BY `client_checklist_id`
			ORDER BY `siblings`.`date_range_finish`;
		',
			DB_PREFIX.'checklist',
			isset($client_checklist_id) && is_numeric($client_checklist_id) ? " AND `client_checklist`.`client_checklist_id` = '" . $client_checklist_id . "' " : ""
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function ausLsaPaperBarChart() {
		$client_checklist_id = $GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) -1]; 

		$query = sprintf('
			SELECT
			`siblings`.`client_checklist_id`,
			DATE_FORMAT(`siblings`.`date_range_finish`, \"%%Y\") AS `label`,
			\"Total Paper (kg)\" AS `series1`,
			@gross_weight := (
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`),0),2) 
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`key` IN(\"GrossWeight\") AND `additional_value`.`group` IN(\"Paper\")
			) AS `data1`,
			\"Recycled Paper (%%)\" AS `series2`,
			@outsourced_paper_index := (
				SELECT `additional_value`.`index`
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`key` IN(\"PaperType\") AND `additional_value`.`group` IN(\"Paper\") AND `additional_value`.`value` = \"OUTSOURCED\"
			),
			@inhouse_recycled_weight := (
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`),0),2) 
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`key` IN(\"RecycledWeight\") AND `additional_value`.`group` IN(\"Paper\") AND `additional_value`.`index` != @outsourced_paper_index
			),
			@inhouse_gross_weight := (
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`),0),2) 
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`key` IN(\"GrossWeight\") AND `additional_value`.`group` IN(\"Paper\") AND `additional_value`.`index` != @outsourced_paper_index
			) AS `data1`,
			ROUND((@inhouse_recycled_weight/@inhouse_gross_weight)*100,2) AS `data2`,
			\"Total Paper (kg) per Employee\" AS `series3`,
			(
				SELECT ROUND(IFNULL(SUM(`additional_value`.`value`) / `client_result`.`arbitrary_value`,0),4)
			    FROM `%1$s`.`additional_value`
			    LEFT JOIN `%1$s`.`client_result` ON `client_result`.`client_checklist_id` = `additional_value`.`client_checklist_id`
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id`
			    AND `additional_value`.`key` IN(\"GrossWeight\") AND `additional_value`.`group` IN(\"Paper\")
			    AND `client_result`.`answer_id` = \"33160\"
			) AS `data3`,

			@benchmark_year := IF(DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y\") = \"2017\", DATE_FORMAT(`siblings`.`date_range_finish`,\"2016-%%m-%%d\"), DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y-%%m-%%d\")),
			@benchmark_year_staff := (SELECT SUM(`client_result`.`arbitrary_value`)
				FROM `%1$s`.`client_checklist`
				LEFT JOIN `%1$s`.`client_result` ON `client_checklist`.`client_checklist_id` = `client_result`.`client_checklist_id`
				WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				AND `client_result`.`answer_id` = \"33160\"),
			@benchmark_year_value := (SELECT SUM(`additional_value`.`value`)
				FROM `%1$s`.`client_checklist`
				LEFT JOIN `%1$s`.`additional_value` ON `client_checklist`.`client_checklist_id` = `additional_value`.`client_checklist_id`
				WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				AND `additional_value`.`key` IN(\"GrossWeight\") AND `additional_value`.`group` IN(\"Paper\")),
			@benchmark_year_inhouse_value := (SELECT SUM(`additional_value`.`value`)
				FROM `%1$s`.`client_checklist`
				LEFT JOIN `%1$s`.`additional_value` ON `client_checklist`.`client_checklist_id` = `additional_value`.`client_checklist_id`
				WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				AND `additional_value`.`key` IN(\"GrossWeight\") AND `additional_value`.`group` IN(\"Paper\") AND `additional_value`.`index` != (SELECT `av`.`index` FROM `greenbiz_checklist`.`additional_value` `av` WHERE `av`.`client_checklist_id` = `client_checklist`.`client_checklist_id` AND `av`.`group` IN(\"Paper\") AND `av`.`key` IN(\"PaperType\") AND `av`.`value` = \"OUTSOURCED\" LIMIT 1)),			
			@benchmark_year_inhouse_recycled_value := (SELECT SUM(`additional_value`.`value`)
				FROM `greenbiz_checklist`.`client_checklist`
				LEFT JOIN `greenbiz_checklist`.`additional_value` ON `client_checklist`.`client_checklist_id` = `additional_value`.`client_checklist_id`
				WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				AND `additional_value`.`key` IN(\"RecycledWeight\") AND `additional_value`.`group` IN(\"Paper\") AND `additional_value`.`index` != (SELECT `av`.`index` FROM `greenbiz_checklist`.`additional_value` `av` WHERE `av`.`client_checklist_id` = `client_checklist`.`client_checklist_id` AND `av`.`group` IN(\"Paper\") AND `av`.`key` IN(\"PaperType\") AND `av`.`value` = \"OUTSOURCED\" LIMIT 1)),
			ROUND(IFNULL((@benchmark_year_value / @benchmark_year_staff),0),4) AS `data4`,
			\"Total Paper (kg) per Employee Benchmark\" AS `series4`,
			ROUND(IFNULL(((@benchmark_year_inhouse_recycled_value / @benchmark_year_inhouse_value)*100),0),2) AS `data5`,
			\"Recycled Paper Benchmark (%%)\" AS `series5`

			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%1$s`.`client_checklist` `siblings` ON `client_checklist`.`checklist_id` = `siblings`.`checklist_id` AND `client_checklist`.`client_id` = `siblings`.`client_id`
			WHERE 1
			%2$s
			AND `siblings`.`date_range_finish` IS NOT NULL
			GROUP BY `client_checklist_id`
			ORDER BY `siblings`.`date_range_finish`;
		',
			DB_PREFIX.'checklist',
			isset($client_checklist_id) && is_numeric($client_checklist_id) ? " AND `client_checklist`.`client_checklist_id` = '" . $client_checklist_id . "' " : ""
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function ausLsaOffsetsBarChart() {
		$client_checklist_id = $GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) -1]; 

		$query = sprintf('
			SELECT
			@green_tariff:= (
				SELECT IFNULL(SUM(`additional_value`.`value`),0)
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`key` IN(\"Green Tariff Electricity\") AND `additional_value`.`group` IN(\"Emmission\")
			),
			@offsets:= (
				SELECT IFNULL(`client_result`.`arbitrary_value`,0)
				FROM `%1$s`.`client_result`
			    WHERE `client_result`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `client_result`.`answer_id` = 33162
			),
			@carbon_mitigation:= @green_tariff + @offsets,
			@emissions:= (
				SELECT IFNULL(SUM(`additional_value`.`value`),0)
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`group` IN(\"Emmission\")
			),
			@electricity:= (
				SELECT IFNULL(SUM(`additional_value`.`value`),0)
			    FROM `%1$s`.`additional_value` 
			    WHERE `additional_value`.`client_checklist_id` = `siblings`.`client_checklist_id` AND `additional_value`.`group` IN(\"Emmission\") AND `additional_value`.`key` IN(\"Green Tariff Electricity\", \"Purchased Electricity\")
			),
			@benchmark_year := IF(DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y\") = \"2017\", DATE_FORMAT(`siblings`.`date_range_finish`,\"2016-%%m-%%d\"), DATE_FORMAT(`siblings`.`date_range_finish`,\"%%Y-%%m-%%d\")),
			@benchmark_year_green_tariff := (SELECT SUM(`additional_value`.`value`)
				FROM `%1$s`.`client_checklist`
				LEFT JOIN `%1$s`.`additional_value` ON `client_checklist`.`client_checklist_id` = `additional_value`.`client_checklist_id`
                LEFT JOIN `%1$s`.`client_result` ON `additional_value`.`client_checklist_id` = `client_result`.`client_checklist_id` AND `client_result`.`answer_id` = 33162
				WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				AND `additional_value`.`key` IN(\"Green Tariff Electricity\") AND `additional_value`.`group` IN(\"Emmission\")),
			@benchmark_year_offsets := (SELECT SUM(`client_result`.`arbitrary_value`)
				FROM `%1$s`.`client_checklist`
                LEFT JOIN `%1$s`.`client_result` ON `client_checklist`.`client_checklist_id` = `client_result`.`client_checklist_id`
				WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				AND `client_result`.`answer_id` = 33162),
			@benchmark_year_carbon_mitigation:= @benchmark_year_green_tariff + @benchmark_year_offsets,
			@benchmark_year_emissions := (SELECT SUM(`additional_value`.`value`)
				FROM `%1$s`.`client_checklist`
				LEFT JOIN `%1$s`.`additional_value` ON `client_checklist`.`client_checklist_id` = `additional_value`.`client_checklist_id`
				WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				AND `additional_value`.`group` IN(\"Emmission\")),
			@benchmark_year_electricity := (SELECT SUM(`additional_value`.`value`)
				FROM `%1$s`.`client_checklist`
				LEFT JOIN `%1$s`.`additional_value` ON `client_checklist`.`client_checklist_id` = `additional_value`.`client_checklist_id`
				WHERE `client_checklist`.`checklist_id` = `siblings`.`checklist_id`
				AND DATE_FORMAT(`client_checklist`.`date_range_finish`,\"%%Y-%%m-%%d\") = @benchmark_year
				AND `additional_value`.`group` IN(\"Emmission\") AND `additional_value`.`key` IN(\"Green Tariff Electricity\", \"Purchased Electricity\")),              
                
            `siblings`.`client_checklist_id`,
			DATE_FORMAT(`siblings`.`date_range_finish`, \"%%Y\") AS `label`,
			\"Total Carbon Mitigation\" AS `series1`,
			ROUND(@carbon_mitigation,2) AS `data1`,
			\"Green Tariff Electricity (%%)\" AS `series2`,
			ROUND((@green_tariff/@electricity)*100,2) AS `data2`,
			\"Carbon Offsetting (%%)\" AS `series3`,
			ROUND((@carbon_mitigation/@emissions)*100,2) AS `data3`,
			\"Benchmark Green Tariff Electricity (%%)\" AS `series4`,
			ROUND((@benchmark_year_green_tariff/@benchmark_year_electricity)*100,2) AS `data4`,
			\"Benchmark Carbon Offsetting (%%)\" AS `series5`,
			ROUND((@benchmark_year_carbon_mitigation/@benchmark_year_emissions)*100,2) AS `data5`

			FROM `greenbiz_checklist`.`client_checklist`
			LEFT JOIN `greenbiz_checklist`.`client_checklist` `siblings` ON `client_checklist`.`checklist_id` = `siblings`.`checklist_id` AND `client_checklist`.`client_id` = `siblings`.`client_id`
			WHERE 1
			%2$s
			AND `siblings`.`date_range_finish` IS NOT NULL
			GROUP BY `client_checklist_id`
			ORDER BY `siblings`.`date_range_finish`;
		',
			DB_PREFIX.'checklist',
			isset($client_checklist_id) && is_numeric($client_checklist_id) ? " AND `client_checklist`.`client_checklist_id` = '" . $client_checklist_id . "' " : ""
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	//
	// TWE Chart Queries
	//

	private function tweSiteH2oUseageChart() {

		$query = sprintf('
			SELECT
			`data`.`month`,
			DATE_FORMAT(`data`.`month`, \"%%b %%Y\") AS `label`,
			ROUND(`data`.`data`) AS `data1`,
			\"%4$s\" AS `series1`,
			ROUND(SUM(`rolling_average`.`data`)/12) AS `data2`,
			\"%5$s\" AS `series2`
			FROM (
				SELECT 
				`client_checklist`.`date_range_finish` AS `month`, 
				SUM(
					CASE 
						WHEN `metric_unit_type_2_metric`.`conversion` > 0 
						THEN IF(`output`.`conversion` > 0, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`) / `output`.`conversion`, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`)) 
						ELSE IF(`output`.`conversion` > 0, `client_metric`.`value` / `output`.`conversion`, `client_metric`.`value`) 
					END
				) AS `data`
				FROM `%1$s`.`client_metric`
				LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
				LEFT JOIN `%1$s`.`metric_unit_type_2_metric` ON `client_metric`.`metric_id` = `metric_unit_type_2_metric`.`metric_id` AND `metric_unit_type_2_metric`.`metric_unit_type_id` = `client_metric`.`metric_unit_type_id` 
				LEFT JOIN `%1$s`.`metric_unit_type_2_metric` `output` ON `client_metric`.`metric_id` = `output`.`metric_id` AND `output`.`metric_unit_type_id` = %6$d
				WHERE 1
				#AND `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 3 YEAR) 
				AND LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 3 YEAR)
				AND `client_checklist`.`client_id` IN(%2$s)
				AND client_checklist.status != 4
				AND `client_metric`.`metric_id` IN(%3$s) 
				GROUP BY `client_checklist`.`date_range_finish` 
				ORDER BY `client_checklist`.`date_range_finish` ASC
			) `data`
			JOIN (
				SELECT 
				`client_checklist`.`date_range_finish` AS `month`, 
				CASE 
					WHEN `metric_unit_type_2_metric`.`conversion` > 0 
					THEN IF(`output`.`conversion` > 0, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`) / `output`.`conversion`, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`)) 
					ELSE IF(`output`.`conversion` > 0, `client_metric`.`value` / `output`.`conversion`, `client_metric`.`value`) 
				END AS `data`
				FROM `%1$s`.`client_metric`
				LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
				LEFT JOIN `%1$s`.`metric_unit_type_2_metric` ON `client_metric`.`metric_id` = `metric_unit_type_2_metric`.`metric_id` AND `metric_unit_type_2_metric`.`metric_unit_type_id` = `client_metric`.`metric_unit_type_id` 
				LEFT JOIN `%1$s`.`metric_unit_type_2_metric` `output` ON `client_metric`.`metric_id` = `output`.`metric_id` AND `output`.`metric_unit_type_id` = %6$d 
				WHERE 1
				AND `client_checklist`.`client_id` IN(%2$s)
				AND client_checklist.status != 4
				AND `client_metric`.`metric_id` IN(%3$s)
			) `rolling_average` ON `rolling_average`.`month` BETWEEN `data`.`month` - INTERVAL 12 MONTH AND `data`.`month` 
			GROUP BY `data`.`month`
		',
			DB_PREFIX.'checklist',
			$this->client_id,
			"826,827,828,829,830,831,832,833", //Metric Identifiers
			"Actual Use", //Series 1
			"Rolling Average", //Series 2
			"5" //Common Unit
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function tweSiteEnergyUseageChart() {

		$query = sprintf('
			SELECT
			`data`.`month`,
			DATE_FORMAT(`data`.`month`, \"%%b %%Y\") AS `label`,
			ROUND(`data`.`data`) AS `data1`,
			\"%4$s\" AS `series1`,
			ROUND(SUM(`rolling_average`.`data`)/12) AS `data2`,
			\"%5$s\" AS `series2`
			FROM (
				SELECT 
				`client_checklist`.`date_range_finish` AS `month`, 
				SUM(
					CASE 
						WHEN `metric_unit_type_2_metric`.`conversion` > 0 
						THEN IF(`output`.`conversion` > 0, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`) / `output`.`conversion`, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`)) 
						ELSE IF(`output`.`conversion` > 0, `client_metric`.`value` / `output`.`conversion`, `client_metric`.`value`) 
					END
				) AS `data`
				FROM `%1$s`.`client_metric`
				LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
				LEFT JOIN `%1$s`.`metric_unit_type_2_metric` ON `client_metric`.`metric_id` = `metric_unit_type_2_metric`.`metric_id` AND `metric_unit_type_2_metric`.`metric_unit_type_id` = `client_metric`.`metric_unit_type_id` 
				LEFT JOIN `%1$s`.`metric_unit_type_2_metric` `output` ON `client_metric`.`metric_id` = `output`.`metric_id` AND `output`.`metric_unit_type_id` = %6$d
				WHERE 1
				#AND `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 3 YEAR)
				AND LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 3 YEAR)
				AND `client_checklist`.`client_id` IN(%2$s) 
				AND `client_metric`.`metric_id` IN(%3$s)
				AND client_checklist.status != 4
				GROUP BY `client_checklist`.`date_range_finish` 
				ORDER BY `client_checklist`.`date_range_finish` ASC
			) `data`
			JOIN (
				SELECT 
				`client_checklist`.`date_range_finish` AS `month`, 
				CASE 
					WHEN `metric_unit_type_2_metric`.`conversion` > 0 
					THEN IF(`output`.`conversion` > 0, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`) / `output`.`conversion`, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`)) 
					ELSE IF(`output`.`conversion` > 0, `client_metric`.`value` / `output`.`conversion`, `client_metric`.`value`) 
				END AS `data`
				FROM `%1$s`.`client_metric`
				LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
				LEFT JOIN `%1$s`.`metric_unit_type_2_metric` ON `client_metric`.`metric_id` = `metric_unit_type_2_metric`.`metric_id` AND `metric_unit_type_2_metric`.`metric_unit_type_id` = `client_metric`.`metric_unit_type_id` 
				LEFT JOIN `%1$s`.`metric_unit_type_2_metric` `output` ON `client_metric`.`metric_id` = `output`.`metric_id` AND `output`.`metric_unit_type_id` = %6$d 
				WHERE 1
				AND `client_checklist`.`client_id` IN(%2$s) 
				AND client_checklist.status != 4
				AND `client_metric`.`metric_id` IN(%3$s)
			) `rolling_average` ON `rolling_average`.`month` BETWEEN `data`.`month` - INTERVAL 12 MONTH AND `data`.`month` 
			GROUP BY `data`.`month`
		',
			DB_PREFIX.'checklist',
			$this->client_id,
			"764,780,765,766,767,783,768,769,770,771,773,774,776,777,778,779", //Metric Identifiers
			"Actual Use", //Series 1
			"Rolling Average", //Series 3
			"15" //Common Unit
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function tweSiteWastePieChart() {

		$query = sprintf('
			SELECT
			\"%8$s\" AS `series`,
			`all_data`.`label` AS `label`,
			ROUND(`all_data`.`value`,2) AS `data`
			FROM (

			SELECT
			`client_checklist`.`date_range_finish`,
			SUM(CASE
				WHEN `metric_unit_type_2_metric`.`conversion` > 0
				THEN
					IF(`output`.`conversion` > 0, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`) / `output`.`conversion`, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`))
				ELSE
					IF(`output`.`conversion` > 0, `client_metric`.`value` / `output`.`conversion`, `client_metric`.`value`)
			END) AS `value`,
			\"%6$s\" AS `label`
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` ON `client_metric`.`metric_id` = `metric_unit_type_2_metric`.`metric_id` AND `metric_unit_type_2_metric`.`metric_unit_type_id` = `client_metric`.`metric_unit_type_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` `output` ON `client_metric`.`metric_id` = `output`.`metric_id` AND `output`.`metric_unit_type_id` = %7$s
			WHERE 1
			#AND `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 1 YEAR)
			AND LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 1 YEAR)
			AND client_checklist.status != 4
			AND `client_checklist`.`client_id` IN(%2$s)
			AND `client_metric`.`metric_id` IN(%4$s)

			UNION

			SELECT
			`client_checklist`.`date_range_finish`,
			SUM(CASE
				WHEN `metric_unit_type_2_metric`.`conversion` > 0
				THEN
					IF(`output`.`conversion` > 0, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`) / `output`.`conversion`, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`))
				ELSE
					IF(`output`.`conversion` > 0, `client_metric`.`value` / `output`.`conversion`, `client_metric`.`value`)
			END) AS `value`,
			\"%5$s\" AS `label`
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` ON `client_metric`.`metric_id` = `metric_unit_type_2_metric`.`metric_id` AND `metric_unit_type_2_metric`.`metric_unit_type_id` = `client_metric`.`metric_unit_type_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` `output` ON `client_metric`.`metric_id` = `output`.`metric_id` AND `output`.`metric_unit_type_id` = %7$s
			WHERE 1
			#AND `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 1 YEAR)
			AND LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 1 YEAR)
			AND client_checklist.status != 4
			AND `client_checklist`.`client_id` IN(%2$s)
			AND `client_metric`.`metric_id` IN(%3$s)

			) `all_data`;
		',
			DB_PREFIX.'checklist',
			$this->client_id,
			"785,786,787,788,789,790.791,792,793,794,795,796", //Label 1 Metric Identifiers
			"797,798,799,800,801,802,803,804,805,806,807,808,809,810,811,812,813,814,815,816,817,818,819,820,821,822,823,824", //Label 2 Metric Identifiers
			"Landfill", //Label 1
			"Recycled", //Label 2
			"18", //Common Unit
			"1" //Series
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function tweSiteWaterEfficiency() {

		$query = sprintf('
			SELECT
			`client_checklist`.`client_checklist_id`,
			@production_metric_id := (
				SELECT
					`production`.`metric_id`
				FROM(
					SELECT
						`client_metric`.`metric_id`,
						SUM(`client_metric`.`value`) AS `production`
					FROM `%1$s`.`client_metric`
					LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
					#WHERE `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 3 YEAR)
					WHERE LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 1 YEAR)
					AND `client_metric`.`metric_id` IN(%3$s)
					AND `client_checklist`.`client_id` IN(%2$s)
					AND client_checklist.status != 4
					GROUP BY `client_metric`.`metric_id`
					ORDER BY `production` DESC
					LIMIT 1
				) `production`
			),
			    
			@water := (SELECT
			AVG(CASE
				WHEN `metric_unit_type_2_metric`.`conversion` > 0
				THEN
					IF(`output`.`conversion` > 0, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`) / `output`.`conversion`, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`))
				ELSE
					IF(`output`.`conversion` > 0, `client_metric`.`value` / `output`.`conversion`, `client_metric`.`value`)
			END)
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`client_checklist` `ra_client_checklist` ON `client_metric`.`client_checklist_id` = `ra_client_checklist`.`client_checklist_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` ON `client_metric`.`metric_id` = `metric_unit_type_2_metric`.`metric_id` AND `metric_unit_type_2_metric`.`metric_unit_type_id` = `client_metric`.`metric_unit_type_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` `output` ON `client_metric`.`metric_id` = `output`.`metric_id` AND `output`.`metric_unit_type_id` = %5$d
			WHERE 1
			AND `ra_client_checklist`.`date_range_finish` > (`client_checklist`.`date_range_finish` - INTERVAL 1 YEAR)
			AND `ra_client_checklist`.`date_range_finish` <= (`client_checklist`.`date_range_finish`)
			AND `ra_client_checklist`.`client_id` IN(%2$s)
			AND `client_metric`.`metric_id` IN(%4$s)
			ORDER BY `ra_client_checklist`.`date_range_finish` ASC),

			@number := (SELECT
			AVG(CASE
				WHEN `metric_unit_type_2_metric`.`conversion` > 0
				THEN
					IF(`output`.`conversion` > 0, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`) / `output`.`conversion`, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`))
				ELSE
					IF(`output`.`conversion` > 0, `client_metric`.`value` / `output`.`conversion`, `client_metric`.`value`)
			END)
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`client_checklist` `ra_client_checklist` ON `client_metric`.`client_checklist_id` = `ra_client_checklist`.`client_checklist_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` ON `client_metric`.`metric_id` = `metric_unit_type_2_metric`.`metric_id` AND `metric_unit_type_2_metric`.`metric_unit_type_id` = `client_metric`.`metric_unit_type_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` `output` ON `client_metric`.`metric_id` = `output`.`metric_id` AND `output`.`metric_unit_type_id` = %5$d
			WHERE 1
			AND `ra_client_checklist`.`date_range_finish` > (`client_checklist`.`date_range_finish` - INTERVAL 1 YEAR)
			AND `ra_client_checklist`.`date_range_finish` <= (`client_checklist`.`date_range_finish`)
			AND `ra_client_checklist`.`client_id` IN(%2$s)
			AND `client_metric`.`metric_id` IN(
				SELECT
					`production`.`metric_id`
				FROM(
					SELECT
						`client_metric`.`metric_id`,
						SUM(`client_metric`.`value`) AS `production`
					FROM `%1$s`.`client_metric`
					LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
					#WHERE `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 3 YEAR)
					WHERE LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 3 YEAR)
					AND `client_metric`.`metric_id` IN(%3$s)
					AND `client_checklist`.`client_id` IN(%2$s)
					GROUP BY `client_metric`.`metric_id`
					ORDER BY `production` DESC
					LIMIT 1
				) `production`
			)
			ORDER BY `ra_client_checklist`.`date_range_finish` ASC),

			DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%b %%Y\") AS `label`,
			ROUND(IF(@number > 0, (@water/@number)*1000,0),5) AS `data1`,
			(SELECT
				CONCAT(\"L of water / \",`metric`.`metric`)
			    FROM `%1$s`.`metric`
			    WHERE `metric`.`metric_id` = (
				SELECT
					`production`.`metric_id`
				FROM(
					SELECT
						`client_metric`.`metric_id`,
						SUM(`client_metric`.`value`) AS `production`
					FROM `%1$s`.`client_metric`
					LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
					#WHERE `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 3 YEAR)
					WHERE LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 3 YEAR)
					AND `client_metric`.`metric_id` IN(%3$s)
					AND `client_checklist`.`client_id` IN(%2$s)
					AND client_checklist.status != 4
					GROUP BY `client_metric`.`metric_id`
					ORDER BY `production` DESC
					LIMIT 1
				) `production`
			)
			) AS `series1`

			FROM
			`%1$s`.`client_checklist`
			WHERE `client_checklist`.`client_id` IN(%2$s)
			#AND `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 3 YEAR)
			AND LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 3 YEAR)
			GROUP BY `client_checklist`.`date_range_finish`
			ORDER BY `client_checklist`.`date_range_finish`
		',
			DB_PREFIX.'checklist',
			$this->client_id, //Client ID
			"890,888,891,889,887", //Production Metrics
			"826,827,828,829,830,831,832,833", //Water Metrics
			"5" //Common Unit
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function tweSiteEnergyEfficiency() {

		$query = sprintf('
			SELECT
			`client_checklist`.`client_checklist_id`,
			@production_metric_id := (
				SELECT
					`production`.`metric_id`
				FROM(
					SELECT
						`client_metric`.`metric_id`,
						SUM(`client_metric`.`value`) AS `production`
					FROM `%1$s`.`client_metric`
					LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
					#WHERE `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 3 YEAR)
					WHERE LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 3 YEAR)
					AND `client_metric`.`metric_id` IN(%3$s)
					AND `client_checklist`.`client_id` IN(%2$s)
					AND client_checklist.status != 4
					GROUP BY `client_metric`.`metric_id`
					ORDER BY `production` DESC
					LIMIT 1
				) `production`
			),
			    
			@energy := (SELECT
			AVG(CASE
				WHEN `metric_unit_type_2_metric`.`conversion` > 0
				THEN
					IF(`output`.`conversion` > 0, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`) / `output`.`conversion`, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`))
				ELSE
					IF(`output`.`conversion` > 0, `client_metric`.`value` / `output`.`conversion`, `client_metric`.`value`)
			END)
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`client_checklist` `ra_client_checklist` ON `client_metric`.`client_checklist_id` = `ra_client_checklist`.`client_checklist_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` ON `client_metric`.`metric_id` = `metric_unit_type_2_metric`.`metric_id` AND `metric_unit_type_2_metric`.`metric_unit_type_id` = `client_metric`.`metric_unit_type_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` `output` ON `client_metric`.`metric_id` = `output`.`metric_id` AND `output`.`metric_unit_type_id` = %5$d
			WHERE 1
			AND `ra_client_checklist`.`date_range_finish` > (`client_checklist`.`date_range_finish` - INTERVAL 1 YEAR)
			AND `ra_client_checklist`.`date_range_finish` <= (`client_checklist`.`date_range_finish`)
			AND `ra_client_checklist`.`client_id` IN(%2$s)
			AND `client_metric`.`metric_id` IN(%4$s)
			ORDER BY `ra_client_checklist`.`date_range_finish` ASC),

			@number := (SELECT
			AVG(CASE
				WHEN `metric_unit_type_2_metric`.`conversion` > 0
				THEN
					IF(`output`.`conversion` > 0, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`) / `output`.`conversion`, (`client_metric`.`value` * `metric_unit_type_2_metric`.`conversion`))
				ELSE
					IF(`output`.`conversion` > 0, `client_metric`.`value` / `output`.`conversion`, `client_metric`.`value`)
			END)
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`client_checklist` `ra_client_checklist` ON `client_metric`.`client_checklist_id` = `ra_client_checklist`.`client_checklist_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` ON `client_metric`.`metric_id` = `metric_unit_type_2_metric`.`metric_id` AND `metric_unit_type_2_metric`.`metric_unit_type_id` = `client_metric`.`metric_unit_type_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` `output` ON `client_metric`.`metric_id` = `output`.`metric_id` AND `output`.`metric_unit_type_id` = %5$d
			WHERE 1
			AND `ra_client_checklist`.`date_range_finish` > (`client_checklist`.`date_range_finish` - INTERVAL 1 YEAR)
			AND `ra_client_checklist`.`date_range_finish` <= (`client_checklist`.`date_range_finish`)
			AND `ra_client_checklist`.`client_id` IN(%2$s)
			AND `client_metric`.`metric_id` IN(
				SELECT
					`production`.`metric_id`
				FROM(
					SELECT
						`client_metric`.`metric_id`,
						SUM(`client_metric`.`value`) AS `production`
					FROM `%1$s`.`client_metric`
					LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
					#WHERE `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 3 YEAR)
					WHERE LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 3 YEAR)
					AND `client_metric`.`metric_id` IN(%3$s)
					AND `client_checklist`.`client_id` IN(%2$s)
					AND client_checklist.status != 4
					GROUP BY `client_metric`.`metric_id`
					ORDER BY `production` DESC
					LIMIT 1
				) `production`
			)
			ORDER BY `ra_client_checklist`.`date_range_finish` ASC),

			DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%b %%Y\") AS `label`,
			ROUND(IF(@number > 0, (@energy / @number)*1000,0),5) AS `data1`,
			(SELECT
				CONCAT(\"MJ of energy / \",`metric`.`metric`)
			    FROM `%1$s`.`metric`
			    WHERE `metric`.`metric_id` = (
				SELECT
					`production`.`metric_id`
				FROM(
					SELECT
						`client_metric`.`metric_id`,
						SUM(`client_metric`.`value`) AS `production`
					FROM `%1$s`.`client_metric`
					LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
					#WHERE `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 3 YEAR)
					WHERE LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 3 YEAR)
					AND `client_metric`.`metric_id` IN(%3$s)
					AND `client_checklist`.`client_id` IN(%2$s)
					AND client_checklist.status != 4
					GROUP BY `client_metric`.`metric_id`
					ORDER BY `production` DESC
					LIMIT 1
				) `production`
			)
			) AS `series1`

			FROM
			`%1$s`.`client_checklist`
			WHERE `client_checklist`.`client_id` IN(%2$s)
			#AND `client_checklist`.`date_range_finish` > (CURDATE() - INTERVAL 3 YEAR)
			AND LAST_DAY(`client_checklist`.`date_range_start`) >= (CURDATE() - INTERVAL 3 YEAR)
			GROUP BY `client_checklist`.`date_range_finish`
			ORDER BY `client_checklist`.`date_range_finish`
		',
			DB_PREFIX.'checklist',
			$this->client_id, //Client ID
			"890,888,891,889,887", //Production Metrics
			"764,780,765,766,767,783,768,769,770,771,773,774,776,777,778,779", //Water Metrics
			"15" //Common Unit
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}


	/*
	//
	// Generic Charts 
	//
	*/

	private function userAccess30Days() {
		$client_id = implode(',',resultFilter::filtered_client_array($this->db, $this->contact));
		$query = sprintf('
			SELECT
			\"Hits\" AS series1,
			COUNT(client_contact_log.client_contact_log_id) AS data1,
			DATE_FORMAT(client_contact_log.timestamp, \"%%e/%%c/%%Y\") AS label,
			client_contact_log.timestamp
			FROM %1$s.client_contact_log
			WHERE client_contact_log.timestamp > CURDATE() - INTERVAL 30 DAY
			AND client_contact_log.client_id IN(%2$s)
			GROUP BY label
			ORDER BY client_contact_log.timestamp ASC;
		',
			DB_PREFIX.'core',
			$client_id //Client ID
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}	

	private function averageScoreTimelineChart() {
		$query = sprintf('
			SELECT 
			\"Average Score (%%)\" AS series1, 
			ROUND((AVG(client_checklist.current_score) * 100),2) AS data1,
			DATE_FORMAT(client_checklist.completed, \"%%Y\") AS label
			FROM %1$s.client_checklist
			WHERE 1
			AND client_checklist.client_checklist_id IN(%2$s) 
			AND client_checklist.completed IS NOT NULL
			GROUP BY label 
			ORDER BY label;
		',
			DB_PREFIX.'checklist',
			is_array($this->client_checklist_id) ? implode($this->client_checklist_id) : $this->client_checklist_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function climateChangeChart() {

		$query = sprintf('
			SELECT
			\"pie\" as chart,
			\"1\" as series,
			answer.question_id,
			answer.answer_id,
			answer.answer_type,
			answer_string.string AS label,
			(SELECT COUNT(client_result.answer_id) FROM %1$s.client_result WHERE client_result.answer_id = answer.answer_id AND client_result.client_checklist_id IN(%2$s)) AS data,
			ROUND((SELECT SUM(client_result.arbitrary_value) FROM %1$s.client_result WHERE client_result.answer_id = answer.answer_id AND client_result.client_checklist_id IN(%2$s)),2) AS sum
			FROM %1$s.answer
			LEFT JOIN %1$s.answer_string ON answer.answer_string_id = answer_string.answer_string_id
			WHERE answer.question_id = 10633
			ORDER BY answer.sequence
		',
			DB_PREFIX.'checklist',
			is_array($this->client_checklist_id) ? implode($this->client_checklist_id) : $this->client_checklist_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}	

	private function childLabourChart() {

		$query = sprintf('
			SELECT
			\"pie\" as chart,
			\"1\" as series,
			answer.question_id,
			answer.answer_id,
			answer.answer_type,
			answer_string.string AS label,
			(SELECT COUNT(client_result.answer_id) FROM %1$s.client_result WHERE client_result.answer_id = answer.answer_id AND client_result.client_checklist_id IN(%2$s)) AS data,
			ROUND((SELECT SUM(client_result.arbitrary_value) FROM %1$s.client_result WHERE client_result.answer_id = answer.answer_id AND client_result.client_checklist_id IN(%2$s)),2) AS sum
			FROM %1$s.answer
			LEFT JOIN %1$s.answer_string ON answer.answer_string_id = answer_string.answer_string_id
			WHERE answer.question_id = 10622
			ORDER BY answer.sequence
		',
			DB_PREFIX.'checklist',
			is_array($this->client_checklist_id) ? implode($this->client_checklist_id) : $this->client_checklist_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function indigenousOwnedBusiness() {

		$query = sprintf('
			SELECT
			\'pie\' as chart, 
			\'1\' as series,
			COUNT(*) AS data,
			answer_string.string AS label
			FROM greenbiz_checklist.client_result
			LEFT JOIN greenbiz_checklist.answer ON client_result.answer_id = answer.answer_id
			LEFT JOIN greenbiz_checklist.answer_string ON answer.answer_string_id = answer_string.answer_string_id
			WHERE client_result.question_id IN(%2$s)
			AND client_result.client_checklist_id IN(%3$s)
			GROUP BY client_result.answer_id
			ORDER BY answer.sequence
		',
			DB_PREFIX.'checklist',
			'13463',
			is_array($this->client_checklist_id) ? implode($this->client_checklist_id) : $this->client_checklist_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function femaleOwnedBusiness() {

		$query = sprintf('
			SELECT
			\'pie\' as chart, 
			\'1\' as series,
			COUNT(*) AS data,
			answer_string.string AS label
			FROM greenbiz_checklist.client_result
			LEFT JOIN greenbiz_checklist.answer ON client_result.answer_id = answer.answer_id
			LEFT JOIN greenbiz_checklist.answer_string ON answer.answer_string_id = answer_string.answer_string_id
			WHERE client_result.question_id IN(%2$s)
			AND client_result.client_checklist_id IN(%3$s)
			GROUP BY client_result.answer_id
			ORDER BY answer.sequence
		',
			DB_PREFIX.'checklist',
			'13462',
			is_array($this->client_checklist_id) ? implode($this->client_checklist_id) : $this->client_checklist_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function indigenousGenderOwnedBusiness() {

		$query = sprintf('
			SELECT
			query_1.*,
			COUNT(*) AS data
			FROM(
				SELECT
				\'pie\' as chart, 
				\'1\' as series,
				CASE
					WHEN GROUP_CONCAT(client_result.answer_id) = \'32211,32214\' OR GROUP_CONCAT(client_result.answer_id) = \'32214,32211\' THEN \'Non-Indigenous Female Owned Business\' 
        			WHEN GROUP_CONCAT(client_result.answer_id) = \'32211,32213\' OR GROUP_CONCAT(client_result.answer_id) = \'32213,32211\' THEN \'Indigenous Female Owned Business\' 
        			WHEN GROUP_CONCAT(client_result.answer_id) = \'32212,32214\' OR GROUP_CONCAT(client_result.answer_id) = \'32214,32212\' THEN \'Non-Indigenous Male Owned Business\' 
        			WHEN GROUP_CONCAT(client_result.answer_id) = \'32212,32213\' OR GROUP_CONCAT(client_result.answer_id) = \'32213,32212\' THEN \'Indigenous Male Owned Business\'	
				END AS label
				FROM greenbiz_checklist.client_result
				LEFT JOIN greenbiz_checklist.answer ON client_result.answer_id = answer.answer_id
				LEFT JOIN greenbiz_checklist.answer_string ON answer.answer_string_id = answer_string.answer_string_id
				WHERE client_result.question_id IN(%2$s)
				AND client_result.client_checklist_id IN(%3$s)
				GROUP BY client_result.client_checklist_id
				ORDER BY client_result.question_id, answer.sequence
			) query_1
			GROUP BY query_1.label
		',
			DB_PREFIX.'checklist',
			'13462,13463',
			is_array($this->client_checklist_id) ? implode($this->client_checklist_id) : $this->client_checklist_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function australianOwnedBusiness() {

		$query = sprintf('
			SELECT
			\"pie\" as chart,
			\"1\" as series,
			IF(country IN(\"Australia\", \"AU\"), \"Australian\", \"Non-Australian\") AS label,
			count(*) AS data
			FROM %1$s.client
			WHERE client.client_id IN(%2$s)
			GROUP BY label
			ORDER BY label
		',
			DB_PREFIX.'core',
			is_array($this->client_id) ? implode($this->client_id) : $this->client_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function australianOwnedBusinessTimelineChart() {
		$query = sprintf('
			SELECT 
			\'line\' as chart, 
			@label := DATE_FORMAT(registered,\'%%Y\') AS label,
			\'Australian\' AS series1,
			(SELECT COUNT(*) FROM greenbiz_core.client WHERE country IN(\'Australia\', \'AU\') AND DATE_FORMAT(registered,\'%%Y\') = @label AND client.client_id IN (%2$s)) AS data1,
			\'Non-Australian\' AS series2,
			(SELECT COUNT(*) FROM greenbiz_core.client WHERE country NOT IN(\'Australia\', \'AU\') AND DATE_FORMAT(registered,\'%%Y\') = @label AND client.client_id IN (%2$s)) AS data2
			FROM greenbiz_core.client 
			WHERE client.client_id IN(%2$s) 
			GROUP BY label
			ORDER BY label
		',
			DB_PREFIX.'checklist',
			is_array($this->client_id) ? implode($this->client_id) : $this->client_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function indigenousGenderOwnedBusinessTimelineChart() {

		$query = sprintf('
			SELECT
			query_1.chart,
			query_1.label,
			query_1.series1,
			SUM(query_1.data1) AS data1,
			query_1.series2,
			SUM(query_1.data2) AS data2,
			query_1.series3,
			SUM(query_1.data3) AS data3,
			query_1.series4,
			SUM(query_1.data4) AS data4
			FROM (SELECT
			\'line\' AS chart,
			DATE_FORMAT(client_checklist.completed,\'%%Y\') AS label,
			\'Non-Indigenous Female Owned Business\' AS series3,
			IF(GROUP_CONCAT(client_result.answer_id) = \'32211,32214\',1,0) AS data3,
			\'Indigenous Female Owned Business\' AS series1,
			IF(GROUP_CONCAT(client_result.answer_id) = \'32211,32213\',1,0) AS data1,
			\'Non-Indigenous Male Owned Business\' AS series4,
			IF(GROUP_CONCAT(client_result.answer_id) = \'32212,32214\',1,0) AS data4,
			\'Indigenous Male Owned Business\' AS series2,
			IF(GROUP_CONCAT(client_result.answer_id) = \'32212,32213\',1,0) AS data2
			FROM greenbiz_checklist.client_checklist
			LEFT JOIN greenbiz_checklist.client_result ON client_checklist.client_checklist_id = client_result.client_checklist_id
			WHERE client_checklist.client_checklist_id IN(%3$s)
			AND client_result.question_id IN(%2$s)
			GROUP BY client_result.client_checklist_id) query_1
			GROUP BY label
		',
			DB_PREFIX.'checklist',
			'13462,13463',
			is_array($this->client_checklist_id) ? implode($this->client_checklist_id) : $this->client_checklist_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function bankAustraliaindigenousOwnedBusiness() {

		$query = sprintf('
			SELECT
			\'pie\' as chart, 
			\'1\' as series,
			COUNT(*) AS data,
			answer_string.string AS label
			FROM greenbiz_checklist.client_result
			LEFT JOIN greenbiz_checklist.answer ON client_result.answer_id = answer.answer_id
			LEFT JOIN greenbiz_checklist.answer_string ON answer.answer_string_id = answer_string.answer_string_id
			WHERE client_result.question_id IN(%2$s)
			AND client_result.client_checklist_id IN(%3$s)
			GROUP BY client_result.answer_id
			ORDER BY answer.sequence
		',
			DB_PREFIX.'checklist',
			'14757',
			is_array($this->client_checklist_id) ? implode($this->client_checklist_id) : $this->client_checklist_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function baYearlySpend() {

		$query = sprintf('
			SELECT
			\'pie\' as chart, 
			\'1\' as series,
			COUNT(*) AS data,
			answer_string.string AS label
			FROM greenbiz_checklist.client_result
			LEFT JOIN greenbiz_checklist.answer ON client_result.answer_id = answer.answer_id
			LEFT JOIN greenbiz_checklist.answer_string ON answer.answer_string_id = answer_string.answer_string_id
			WHERE client_result.question_id IN(%2$s)
			AND client_result.client_checklist_id IN(%3$s)
			GROUP BY client_result.answer_id
			ORDER BY answer.sequence
		',
			DB_PREFIX.'checklist',
			'14790',
			is_array($this->client_checklist_id) ? implode($this->client_checklist_id) : $this->client_checklist_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

	private function baCarbonNeutrality() {

		$query = sprintf('
			SELECT
			\'pie\' as chart, 
			\'1\' as series,
			COUNT(*) AS data,
			answer_string.string AS label
			FROM greenbiz_checklist.client_result
			LEFT JOIN greenbiz_checklist.answer ON client_result.answer_id = answer.answer_id
			LEFT JOIN greenbiz_checklist.answer_string ON answer.answer_string_id = answer_string.answer_string_id
			WHERE client_result.question_id IN(%2$s)
			AND client_result.client_checklist_id IN(%3$s)
			GROUP BY client_result.answer_id
			ORDER BY answer.sequence
		',
			DB_PREFIX.'checklist',
			'14765',
			is_array($this->client_checklist_id) ? implode($this->client_checklist_id) : $this->client_checklist_id
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		
		return;
	}

}
?>