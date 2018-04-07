<?php
class clientChecklist {
	private $db;
	private $dbModel;
	
	public function __construct($db) {
		$this->db = $db;
		$this->dbModel = new dbModel($this->db);
	}
	
	public function pubGetClientChecklist($client_checklist_id) {
		return $this->getClientChecklist($client_checklist_id);
	}
	
	//Pass a hash and return the checklist_id
	public function getChecklistIdByHash($hash) {
		$checklist_id = null;
		if($result = $this->db->query(sprintf('
			SELECT
			`checklist`.`checklist_id`
			FROM `%1$s`.`checklist`
			WHERE `checklist`.`md5` = "%2$s"
		',
			DB_PREFIX.'checklist',
			$hash
		))) {
			while($row = $result->fetch_object()) {
				$checklist_id = $row->checklist_id;
			}
			$result->close();
		}
		return $checklist_id;
	}

	//Pass a hash and return the checklist_id
	public function getChecklistById($checklist_id) {
		$checklist = new stdClass;
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`checklist`
			WHERE `checklist_id` = %2$d
			LIMIT 1;
		',
			DB_PREFIX.'checklist',
			$checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$checklist = $row;
			}
			$result->close();
		}
		return $checklist;
	}
	
	//Takes a checklist_id and a client_id to auto issue an assessment - optional parameter will send an email to the client
	//Replaces the existing functions:
	//freeOfficeAssessment
	//ghgProtocolScopeAssessment
	public function autoIssueChecklist($checklist_id, $client_id, $redirect_user=false){
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`client_checklist` SET
				`checklist_id` = %3$d,
				`client_id` = %2$d,
				`name` = (SELECT `name` FROM `%1$s`.`checklist` WHERE `checklist_id` = %3$d),
				`audit_required` = %4$d;
		',
			DB_PREFIX.'checklist',
			$client_id,
			$checklist_id,
			$this->checklistAuditRequired($checklist_id)
		));
		
		//Get the checklist id
		$client_checklist_id = $this->db->insert_id;
		
		//Client to be redirected to the new assessment
		if($redirect_user){
			header('Location: /members/entry/'.$client_checklist_id.'/');
		}
		
		return $client_checklist_id;
	}
	
	//Takes the client checklist id and gets the appropriate report template
	public function getReportTemplateByClientChecklistId($client_checklist_id)
	{	
	 	//Set the default report type
	 	$report_template = "generic";
	 	
	 	//query the report type from the database
	 	$checklist = $this->getChecklistByClientChecklistId($client_checklist_id);
	 	
	 	if(!is_null($checklist->report_template) && $checklist->report_template != "") {
			$report_template = $checklist->report_template;
		}
		
		return $report_template;
	}
	
	public function getChecklists($client_id) {
		$clientChecklists = array();
		if ($result = $this->getChecklistQuery(
			'`client_checklist`.`client_id` = %3$d', 
			array(
				DB_PREFIX.'checklist',
				DB_PREFIX.'core',
				$this->db->escape_string($client_id)
			)
		)) {
			while($row = $result->fetch_object()) {
				$row->hash = crypt::encrypt($client_id.'-'.$row->client_checklist_id);
				$row->client_checklist_id_md5 = md5($row->client_checklist_id);
				
				//Insert the expiry date, if the expires field is already set, use that, otherwise set the expiry_date to created + 1Y
				if(!is_null($row->expires) ? $row->expiry_date = $row->expires : $row->expiry_date = date("Y-m-d", strtotime(date("Y-m-d", strtotime($row->created)) . " + 365 day")));
				if(!is_null($row->expires) ? $row->expires = $row->expires : $row->expires = date("Y-m-d", strtotime(date("Y-m-d", strtotime($row->created)) . " + 365 day")));
				
				$clientChecklists[$row->client_checklist_id] = $row;
			}
			$result->close();
		}
		
		return($clientChecklists);
	}

	//Gets all clientChecklists based on an array of clientChecklists
	public function getChecklistsByClientChecklistArray($clientChecklistArray) {
		$clientChecklists = array();
		if ($result = $this->getChecklistQuery(
			'`client_checklist`.`client_checklist_id` IN(%3$s)', 
			array(
				DB_PREFIX.'checklist',
				DB_PREFIX.'core',
				$this->db->escape_string(implode(',',$clientChecklistArray))
			)
		)) {
			while($row = $result->fetch_object()) {
				$row->client_checklist_id_md5 = md5($row->client_checklist_id);
				
				//Insert the expiry date, if the expires field is already set, use that, otherwise set the expiry_date to created + 1Y
				if(!is_null($row->expires) ? $row->expiry_date = $row->expires : $row->expiry_date = date("Y-m-d", strtotime(date("Y-m-d", strtotime($row->created)) . " + 365 day")));
				if(!is_null($row->expires) ? $row->expires = $row->expires : $row->expires = date("Y-m-d", strtotime(date("Y-m-d", strtotime($row->created)) . " + 365 day")));
				
				$clientChecklists[$row->client_checklist_id] = $row;
			}
			$result->close();
		}

		return($clientChecklists);
	}	

	//Take the client_checklist_id and check all results tables for the last saved
	public function getclientChecklistLastActivity($client_checklist_id) {
		$lastActivity = null;

		if($result = $this->db->query(sprintf('
			SELECT
			MAX(`all_results`.`timestamp`) AS `timestamp`
			FROM (
				SELECT
				max(`created`) AS `timestamp`
				FROM `%1$s`.`client_checklist`
				WHERE `client_checklist`.`client_checklist_id` = %2$d
					UNION
				SELECT
				max(`timestamp`) AS `timestamp`
				FROM `%1$s`.`client_result`
				WHERE `client_result`.`client_checklist_id` = %2$d
					UNION
				SELECT
				max(`timestamp`) AS `timestamp`
				FROM `%1$s`.`client_site_result`
				WHERE `client_site_result`.`client_checklist_id` = %2$d
					UNION
				SELECT
				max(`timestamp`) AS `timestamp`
				FROM `%1$s`.`client_metric`
				WHERE `client_metric`.`client_checklist_id` = %2$d) AS `all_results`
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$lastActivity = $row->timestamp;
			}
			$result->close();
		}

		return $lastActivity;
	}
	
	public function getChecklistByClientChecklistId($client_checklist_id) {
		$clientChecklist = NULL;
		if ($result = $this->getChecklistQuery(
			'`client_checklist`.`client_checklist_id` = %3$d',
			array(
				DB_PREFIX.'checklist',
				DB_PREFIX.'core',
				$this->db->escape_string($client_checklist_id)
			)
		)) {
			if ($row = $result->fetch_object()) {
				$row->hash = crypt::encrypt($row->client_checklist_id);
				$row->client_checklist_id_md5 = md5($row->client_checklist_id);
				$clientChecklist = $row;
			}
			
			$result->close();
		}
		return $clientChecklist;
	}

	public function getChecklistByClientChecklistIdHash($client_checklist_hash) {
		$clientChecklist = NULL;
		if ($result = $this->getChecklistQuery(
			'MD5(`client_checklist`.`client_checklist_id`) = "%3$s"',
			array(
				DB_PREFIX.'checklist',
				DB_PREFIX.'core',
				$this->db->escape_string($client_checklist_hash)
			)
		)) {
			$row = $result->fetch_object();
			if ($row) {
				$row->hash = crypt::encrypt($row->client_checklist_id);
				$row->client_checklist_id_md5 = md5($row->client_checklist_id);
				$clientChecklist = $row;
			}
			
			$result->close();
		}
		return $clientChecklist;
	}
	
	private function getChecklistQuery($where, $parameters) {
		$sql = '
			SELECT
				`client_checklist`.*,
				`client_checklist`.`status` AS `status_code`,
				`client_checklist_status`.`status`,
				`client_checklist`.`checklist_variation_id` AS `variation_id`,
				`checklist_variation`.`checklist_variation_id`,
				`checklist`.*,
				TRUNCATE(`client_checklist`.`initial_score`,2) AS `initial_score`,
				TRUNCATE(`client_checklist`.`current_score`,2) AS `current_score`,
				(
		          SELECT `timestamp`
		          FROM `%1$s`.`client_result`
		          WHERE `client_result`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
		          ORDER BY `timestamp` DESC
		          LIMIT 1
		        ) AS `last_modified`,
				`client_checklist`.`expires`,
				`client`.`company_name`,
				`client`.`department`,
				`client`.`parent_id` AS `client_parent_id`,
				`client`.`distributor_id` AS `distributor_id`,
				IF(
					`checklist_variation`.`checklist_variation_id` IS NULL,
					`checklist`.`name`,
					`checklist_variation`.`name`
				) AS `checklist`,
				IF (
					`checklist_variation`.`checklist_variation_id` IS NULL,
					`checklist`.`logo`,
					`checklist_variation`.`logo`
				) AS `logo`,
				IF (
					`checklist_variation`.`checklist_variation_id` IS NULL,
					`checklist`.`company_logo`,
					`checklist_variation`.`company_logo`
				) AS `company_logo`,
				MIN(`client_checklist_score`.`timestamp`) AS certified_date,
				`parent_2_child_checklist`.`parent_checklist_id`,
				`checklist`.`display_in_list`
			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%1$s`.`checklist_variation` ON `client_checklist`.`checklist_variation_id` = `checklist_variation`.`checklist_variation_id`
			LEFT JOIN `%1$s`.`checklist` ON `client_checklist`.`checklist_id` = `checklist`.`checklist_id`
			LEFT JOIN `%2$s`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
			LEFT JOIN `%1$s`.`client_checklist_score` ON `client_checklist`.`client_checklist_id` = `client_checklist_score`.`client_checklist_id` AND `client_checklist_score`.`score` = `client_checklist`.`current_score`
			LEFT JOIN `%1$s`.`parent_2_child_checklist` ON `client_checklist`.`client_checklist_id` = `parent_2_child_checklist`.`child_checklist_id`
			LEFT JOIN `%1$s`.`client_checklist_status` ON `client_checklist`.`status` = `client_checklist_status`.`client_checklist_status_id`
			WHERE '.$where.' '.
			'GROUP BY `client_checklist`.`client_checklist_id`
			ORDER BY `client_checklist`.`created`;';
			
		$query = call_user_func_array('sprintf', array_merge((array)$sql, $parameters));
		$result = $this->db->query($query);

		return $result;
	}
	
	public function isClientChecklistAParent($client_checklist_id) {
		$is_parent = false;
		
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`parent_2_child_checklist`
			WHERE `parent_checklist_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			$counter = 0;
			while($row = $result->fetch_object()) {
				$counter++;
			}
			$result->close();
			if($counter > 0) {
				$is_parent = true;
			}
		}
		
		return $is_parent;
	}
	
	private function isParent2ChildChecklistSet($parent_checklist_id, $child_checklist_id) {
		$set = false;
		
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`parent_2_child_checklist`
			WHERE `parent_checklist_id` = %2$d
			AND `child_checklist_id` = %3$d
		',
			DB_PREFIX.'checklist',
			$parent_checklist_id,
			$child_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$set = true;
			}
			$result->close();
		}
		
		return $set;
	}
	
	//Insert the parent to child client checklist relationship
	public function insertParent2ChildChecklist($parent_checklist_id, $child_checklist_id) {
		if(!$this->isParent2ChildChecklistset($parent_checklist_id, $child_checklist_id)) {
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`parent_2_child_checklist` SET
					`parent_checklist_id` = %2$d,
					`child_checklist_id` = %3$d
			',
				DB_PREFIX.'checklist',
				$parent_checklist_id,
				$child_checklist_id
			));
		
			return $this->db->insert_id;
		}
		return;
	}
	
	//Pass the question_id to return the page details along with some of the checklist details
	public function getChecklistPageFromQuestionId($question_id) {
		if($result = $this->db->query(sprintf('
			SELECT
			`checklist`.`name`,
			`page`.*
			FROM `%1$s`.`question`
			LEFT JOIN `%1$s`.`page` ON `question`.`page_id` = `page`.`page_id`
			LEFT JOIN `%1$s`.`checklist` ON `page`.`checklist_id` = `checklist`.`checklist_id`
			WHERE `question`.`question_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$question_id
		))) {
			while($row = $result->fetch_object()) {
				$pageDetails = $row;
			}
			$result->close();
		}
		return $pageDetails;
	}
	
	//Get all client_sites related to this client checklist
	public function getClientChecklistSites($client_checklist_id) {
		$clientSites = array();
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_site`
			WHERE `client_site`.`client_checklist_id` = %2$d
			ORDER BY `client_site`.`client_site_id`;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$clientSites[] = $row;
			}
			$result->close();
		}
		return($clientSites);
	}
	
	//Delete all client_sites where requested
	public function deleteClientChecklistSites($client_site_id, $client_checklist_id) {
		$clientSites = $this->getClientChecklistSites($client_checklist_id);
		
		$client_sites_ids = "";
		foreach($clientSites as $clientSite) {
			if(!in_array($clientSite->client_site_id, $client_site_id))	{
				$client_sites_ids .= $clientSite->client_site_id . ", ";
			}
		}
		$client_sites_ids = rtrim($client_sites_ids, ", ");
		
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`client_site`
			WHERE `client_checklist_id` = %2$d
			AND `client_site_id` IN(%3$s);
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($client_sites_ids)
		));
		return;
		
	}
	
	//Get all checklist pages for the checklist based on the client_checklist_id
	public function getChecklistPages($client_checklist_id) {
		$pages = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`page`.`page_id`,
				`page_section`.`page_section_id`,
				`page_section`.`title` AS `page_section_title`,
				`page`.`title`,
				`page`.`content`,
				`page`.`enable_skipping`,
				`page`.`show_notes_field`,
				`client_page_note`.`note`,
				`page`.`display_in_table`,
				`page`.`table_columns`,
				`page`.`sequence`,
				`page`.`page_layout`,
				`page`.`notes_field_title`,
				`page`.`notes_field_placeholder`
			FROM `%1$s`.`page`
			LEFT JOIN `%1$s`.`page_section_2_page` ON
				`page`.`page_id` = `page_section_2_page`.`page_id`
			LEFT JOIN `%1$s`.`page_section` ON
				`page_section_2_page`.`page_section_id` = `page_section`.`page_section_id`
			LEFT JOIN `%1$s`.`client_checklist` ON
				`page`.`checklist_id` = `client_checklist`.`checklist_id`
			LEFT JOIN `%1$s`.`client_page_note` ON 
				`client_checklist`.`client_checklist_id` = `client_page_note`.`client_checklist_id` AND
				`page`.`page_id` = `client_page_note`.`page_id`
			WHERE `client_checklist`.`client_checklist_id` = %2$d
			ORDER BY `page`.`sequence` ASC;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			$counter = 0;
			while($row = $result->fetch_object()) {
				$row->token = md5($counter);
				$pages[] = $row;
				$counter++;
			}
			$result->close();
		}
		return($pages);
	}
	
	public function getClientResults($client_checklist_id) {
		$results = array();

		$query = sprintf('
			SELECT
				`client_result`.`client_result_id`,
				`question`.`page_id`,
				`question`.`multiple_answer`,
				`client_result`.`question_id`,
				`client_result`.`answer_id`,
				`client_result`.`arbitrary_value`,
				`client_result`.`timestamp`,
				`answer`.`answer_type`,
				DATE_FORMAT(`client_result`.`timestamp`, "%%d/%%m/%%Y") AS `timestamp_date`,
            	DATE_FORMAT(`client_result`.`timestamp`, "%%h:%%i %%p") AS `timestamp_time`,
            	`client_result`.`index`
			FROM `%1$s`.`client_result`
				LEFT JOIN `%1$s`.`question` USING(`question_id`)
				LEFT JOIN `%1$s`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id`
			WHERE `client_result`.`client_checklist_id` = %2$d
			ORDER BY `client_result`.`question_id`, `client_result`.`answer_id`, `client_result`.`index`, `client_result`.`timestamp` DESC;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		);

		if($result = $this->db->query($query)) {
			$questions = array();
			while($row = $result->fetch_object()) {
				//if($row->multiple_answer == 0 && $row->index == 0 && in_array($row->question_id,$questions)) { continue; }
				$questions[] = $row->question_id;
				unset($row->multiple_answer);
				$results[] = $row;
			}
			$result->close();
		}

		return($results);
	}

	public function getClientChecklistEmissionFactors($client_checklist_id) {
		$emissionFactors = array();

		$query = sprintf('
			SELECT
				`emission_factor`.*
			FROM `%1$s`.`emission_factor`
				LEFT JOIN `%1$s`.`client_checklist` ON `emission_factor`.`checklist_id` = `client_checklist`.`checklist_id`
			WHERE `client_checklist`.`client_checklist_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$emissionFactors[] = $row;
			}
			$result->close();
		}

		return $emissionFactors;
	}

	public function getClientChecklistAdditionalValues($client_checklist_id) {
		$additionalValues = array();

		$query = sprintf('
			SELECT
				`additional_value`.*
			FROM `%1$s`.`additional_value`
			WHERE `additional_value`.`client_checklist_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$additionalValues[] = $row;
			}
			$result->close();
		}

		return $additionalValues;
	}

	public function getClientChecklistAdditionalValue($client_checklist_id, $key, $group, $index = 0) {
		$additionalValue = new stdClass;

		$query = sprintf('
			SELECT
				`additional_value`.*
			FROM `%1$s`.`additional_value`
			WHERE `additional_value`.`client_checklist_id` = %2$d
			AND `additional_value`.`key` = "%3$s"
			AND `additional_value`.`group` = "%4$s"
			AND `additional_value`.`index` = %5$d
			LIMIT 1
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($key),
			$this->db->escape_string($group),
			$this->db->escape_string($index)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$additionalValue = $row;
			}
			$result->close();
		}

		return $additionalValue;
	}

	public function getPreviousClientChecklistResults($client_checklist_id) {
		$previousResults = array();
		$siblingClientChecklists = $this->getSiblingClientChecklists($client_checklist_id);

		$query = sprintf('
			SELECT
				`client_result`.`client_result_id`,
				`question`.`page_id`,
				`question`.`multiple_answer`,
				`client_result`.`question_id`,
				`client_result`.`answer_id`,
				`client_result`.`client_checklist_id`,
				CASE 
					`answer`.`answer_type`
					WHEN "percent" THEN CONCAT(`client_result`.`arbitrary_value`, "%%")
					WHEN "checkbox" THEN `answer_string`.`string`
					WHEN "drop-down-list" THEN `answer_string`.`string`
					WHEN "checkbox-other" THEN CONCAT(`answer_string`.`string`, ":", `client_result`.`arbitrary_value`)
					ELSE `client_result`.`arbitrary_value`
				END AS `result`,
				(IF(ISNULL(`client_checklist`.`date_range_start`),DATE_FORMAT(`client_result`.`timestamp`, "%%d/%%m/%%Y"),DATE_FORMAT(`client_checklist`.`date_range_start`, "%%d/%%m/%%Y"))) AS `period`,
				(IF(ISNULL(`client_checklist`.`date_range_start`),DATE_FORMAT(`client_result`.`timestamp`, "%%e"),DATE_FORMAT(`client_checklist`.`date_range_start`, "%%e"))) AS `period_day`,
    			(IF(ISNULL(`client_checklist`.`date_range_start`),DATE_FORMAT(`client_result`.`timestamp`, "%%M"),DATE_FORMAT(`client_checklist`.`date_range_start`, "%%M"))) AS `period_month`,
    			(IF(ISNULL(`client_checklist`.`date_range_start`),DATE_FORMAT(`client_result`.`timestamp`, "%%Y"),DATE_FORMAT(`client_checklist`.`date_range_start`, "%%Y"))) AS `period_year`,
    			(IF(ISNULL(`client_checklist`.`date_range_finish`),NULL,DATE_FORMAT(`client_checklist`.`date_range_finish`, "%%d/%%m/%%Y"))) AS `period_finish`,
				(IF(ISNULL(`client_checklist`.`date_range_finish`),NULL,DATE_FORMAT(`client_checklist`.`date_range_finish`, "%%e"))) AS `period_finish_day`,
    			(IF(ISNULL(`client_checklist`.`date_range_finish`),NULL,DATE_FORMAT(`client_checklist`.`date_range_finish`, "%%M"))) AS `period_finish_month`,
    			(IF(ISNULL(`client_checklist`.`date_range_finish`),NULL,DATE_FORMAT(`client_checklist`.`date_range_finish`, "%%Y"))) AS `period_finish_year`,
            	`client_result`.`index`
			FROM `%1$s`.`client_result`
				LEFT JOIN `%1$s`.`question` USING(`question_id`)
				LEFT JOIN `%1$s`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id`
				LEFT JOIN `%1$s`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
				LEFT JOIN `%1$s`.`client_checklist` ON `client_result`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
			WHERE `client_result`.`client_checklist_id` IN (%2$s)
			ORDER BY `client_checklist`.`date_range_start` DESC, `client_checklist`.`created` DESC, `client_result`.`timestamp` DESC;
		',
			DB_PREFIX.'checklist',
			implode(',',$siblingClientChecklists)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$previousResults[] = $row;
			}
			$result->close();
		}

		return $previousResults;
	}

	public function getPreviousClientChecklistNotes($client_checklist_id) {
		$previousNotes = array();
		$siblingClientChecklists = $this->getSiblingClientChecklists($client_checklist_id);

		$query = sprintf('
			SELECT
				`client_page_note`.`note`,
				`client_page_note`.`page_id`,
				`client_checklist`.`client_checklist_id`,
				`client_checklist`.`created`,
				(IF(ISNULL(`client_checklist`.`date_range_start`),DATE_FORMAT(`client_checklist`.`created`, "%%d/%%m/%%Y"),DATE_FORMAT(`client_checklist`.`date_range_start`, "%%d/%%m/%%Y"))) AS `period`,
				(IF(ISNULL(`client_checklist`.`date_range_start`),DATE_FORMAT(`client_checklist`.`created`, "%%e"),DATE_FORMAT(`client_checklist`.`date_range_start`, "%%e"))) AS `period_day`,
    			(IF(ISNULL(`client_checklist`.`date_range_start`),DATE_FORMAT(`client_checklist`.`created`, "%%M"),DATE_FORMAT(`client_checklist`.`date_range_start`, "%%M"))) AS `period_month`,
    			(IF(ISNULL(`client_checklist`.`date_range_start`),DATE_FORMAT(`client_checklist`.`created`, "%%Y"),DATE_FORMAT(`client_checklist`.`date_range_start`, "%%Y"))) AS `period_year`
			FROM `%1$s`.`client_page_note`
			LEFT JOIN `%1$s`.`client_checklist` ON `client_checklist`.`client_checklist_id` = `client_page_note`.`client_checklist_id`
			WHERE `client_page_note`.`client_checklist_id` IN (%2$s)
			AND `client_page_note`.`note` IS NOT NULL
			AND `client_page_note`.`note` != ""
			ORDER BY `client_checklist`.`date_range_start` DESC, `client_checklist`.`created` DESC;
		',
			DB_PREFIX.'checklist',
			implode(',',$siblingClientChecklists)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$previousNotes[] = $row;
			}
			$result->close();
		}

		return $previousNotes;
	}
	
	//Gets all clientChecklist results from the client_result table
	public function getAllClientChecklistResults($client_checklist_id) {
		$results = array();
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_result`
			WHERE `client_result`.`client_checklist_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$results[] = $row;
			}
			$result->close();
		}
		return($results);
	}
	
	//Gets all clientSiteResults based on the client_site_id
	public function getAllClientSiteResults($client_site_id) {
		$results = array();
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_site_result`
			WHERE `client_site_result`.`client_site_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$client_site_id
		))) {
			while($row = $result->fetch_object()) {
				$results[] = $row;
			}
			$result->close();
		}
		return($results);
	}
	
	//Get the results for the client sites
	public function getClientSiteQuestionResults($client_checklist_id, $question_id) {
		$results = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`client_site_result`.`client_result_id`,
				`question`.`page_id`,
				`question`.`multiple_answer`,
				`client_site_result`.`question_id`,
				`client_site_result`.`answer_id`,
				`client_site_result`.`arbitrary_value`,
				`client_site_result`.`timestamp`,
				`answer`.`answer_type`,
				`client_site_result`.`client_site_id`
			FROM `%1$s`.`client_site_result`
				LEFT JOIN `%1$s`.`question` USING(`question_id`)
				LEFT JOIN `%1$s`.`answer` ON `client_site_result`.`answer_id` = `answer`.`answer_id`
			WHERE `client_site_result`.`client_checklist_id` = %2$d
			AND `client_site_result`.`question_id` = %3$d
			ORDER BY `client_site_result`.`timestamp` DESC;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id,
			$question_id
		))) {
			$questions = array();
			while($row = $result->fetch_object()) {
				$results[] = $row;
			}
			$result->close();
		}
		return($results);
	}
	
	//Get the results for the client sites
	public function getClientSiteResults($client_checklist_id) {
		$results = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`client_site_result`.`client_result_id`,
				`question`.`page_id`,
				`question`.`multiple_answer`,
				`client_site_result`.`question_id`,
				`client_site_result`.`answer_id`,
				`client_site_result`.`arbitrary_value`,
				`client_site_result`.`timestamp`,
				`answer`.`answer_type`,
				`client_site_result`.`client_site_id`
			FROM `%1$s`.`client_site_result`
				LEFT JOIN `%1$s`.`question` USING(`question_id`)
				LEFT JOIN `%1$s`.`answer` ON `client_site_result`.`answer_id` = `answer`.`answer_id`
			WHERE `client_site_result`.`client_checklist_id` = %2$d
			ORDER BY `client_site_result`.`timestamp` DESC;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			$questions = array();
			while($row = $result->fetch_object()) {
				$results[] = $row;
			}
			$result->close();
		}
		return($results);
	}

	public function getAllPageQuestions($client_checklist_id) {
		$questions = array();

		if($result = $this->db->query(sprintf('
			SELECT
				`question`.`question_id`,
				`question`.`question`,
				`question`.`tip`,
				`question`.`multiple_answer`,
				`question`.`required`,
				`question`.`sequence`,
				`question`.`multi_site`
			FROM `%1$s`.`question`
			LEFT JOIN `%1$s`.`checklist` ON `question`.`checklist_id` = `checklist`.`checklist_id`
			LEFT JOIN `%1$s`.`page` ON `page`.`page_id` = `question`.`page_id` 
			LEFT JOIN `%1$s`.`client_checklist` ON `checklist`.`checklist_id` = `client_checklist`.`checklist_id`
			WHERE `client_checklist`.`client_checklist_id` = %2$d
			ORDER BY `question`.`sequence`;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$row->dependencies = $this->getDependencies($row->question_id);
				$row->answers = $this->getAnswers($row->question_id);
				$questions[] = $row;
			}
			$result->close();
		}
		return($questions);
	}
	
	public function getPageQuestions($page_id) {
		$questions = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`question`.`question_id`,
				`question`.`question`,
				`question`.`tip`,
				`question`.`multiple_answer`,
				`question`.`required`,
				`question`.`sequence`,
				`question`.`multi_site`,
				`question`.`content_block`,
				`question`.`display_in_table`,
				`grid_layout`.`grid_layout_id`,
				`grid_layout`.`col`,
				`grid_layout`.`width`,
				`question`.`index`,
				`question`.`hidden`,
				`question`.`form_group_id`,
				`question`.`css_class`
			FROM `%1$s`.`question`
			LEFT JOIN `%2$s`.`grid_layout` ON `question`.`grid_layout_id` = `grid_layout`.`grid_layout_id`
			WHERE `question`.`page_id` = %3$d
			ORDER BY `question`.`sequence`;
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$page_id
		))) {
			while($row = $result->fetch_object()) {
				$row->dependencies = $this->getDependencies($row->question_id);
				$row->answers = $this->getAnswers($row->question_id);
				$questions[] = $row;
			}
			$result->close();
		}
		return($questions);
	}
	
	public function getClientChecklistQuestions($client_checklist_id) {
		$questions = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`question`.*
			FROM `%1$s`.`question`
			LEFT JOIN `%1$s`.`client_checklist` ON `question`.`checklist_id` = `client_checklist`.`checklist_id`
			WHERE `client_checklist`.`client_checklist_id` = %2$d
			ORDER BY `question`.`sequence`;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$questions[] = $row;
			}
			$result->close();
		}
		return($questions);
	}
	
	public function getClientChecklistAnswers($client_checklist_id) {
		$questions = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`answer`.*,
				`answer_string`.`string`
			FROM `%1$s`.`answer`
			LEFT JOIN `%1$s`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
			LEFT JOIN `%1$s`.`question` ON `answer`.`question_id` = `question`.`question_id`
			LEFT JOIN `%1$s`.`client_checklist` ON `question`.`checklist_id` = `client_checklist`.`checklist_id`
			WHERE `client_checklist`.`client_checklist_id` = %2$d
			ORDER BY `answer`.`sequence`;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$questions[] = $row;
			}
			$result->close();
		}
		return($questions);
	}
	
	public function getPageMetricGroups($page_id,$client_checklist_id) {
		$metric_groups = array();
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`metric_group`
			WHERE `metric_group`.`page_id` = %2$d
			ORDER BY `metric_group`.`sequence`;
		',
			DB_PREFIX.'checklist',
			$page_id
		))) {
			while($row = $result->fetch_object()) {
				$row->metrics = $this->getMetrics($row->metric_group_id,$client_checklist_id);
				$metric_groups[] = $row;
			}
			$result->close();
		}
		return($metric_groups);
	}
	
	public function getMetrics($metric_group_id,$client_checklist_id) {
		$metrics = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`metric`.*,
				`client_metric`.`client_metric_id`,
				`client_metric`.`client_checklist_id`,
				`client_metric`.`metric_unit_type_id`,
				`client_metric`.`timestamp`,
				`client_metric`.`value`,
				`client_metric`.`months`
			FROM `%1$s`.`metric`
			LEFT JOIN `%1$s`.`client_metric` ON `metric`.`metric_id` = `client_metric`.`metric_id`
			AND `client_metric`.`client_checklist_id` = %3$d
			WHERE `metric`.`metric_group_id` = %2$d
			ORDER BY `metric`.`sequence` ASC;
		',
			DB_PREFIX.'checklist',
			$metric_group_id,
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$row->metric_unit_types = $this->getMetricUnitTypes($row->metric_id);
				$metrics[] = $row;
			}
			$result->close();
		}
		return($metrics);
	}
	
	public function getMetricUnitTypes($metric_id) {
		$metric_unit_types = array();

		if($result = $this->db->query(sprintf('
			SELECT
				`metric_unit_type_2_metric`.`metric_unit_type_2_metric_id`,
				`metric_unit_type`.`metric_unit_type_id`,
				`metric_unit_type`.`metric_unit_type`,
				`metric_unit_type`.`description`
			FROM `%1$s`.`metric_unit_type_2_metric`
			LEFT JOIN `%1$s`.`metric_unit_type` USING(`metric_unit_type_id`)
			WHERE `metric_unit_type_2_metric`.`metric_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$metric_id
		))) {
			while($row = $result->fetch_object()) {
				$metric_unit_types[] = $row;
			}
			$result->close();
		}
		return($metric_unit_types);
	}


	//New Metrics Layout 20160430 
	//----------------------------------------------

	public function getPageMetrics($page_id,$client_checklist_id) {
		$metricGroups = array();
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`metric_group`
			WHERE `metric_group`.`page_id` = %2$d
			ORDER BY `metric_group`.`sequence`;
		',
			DB_PREFIX.'checklist',
			$page_id
		))) {
			while($row = $result->fetch_object()) {
				$row->metrics = $this->getGroupMetrics($row->metric_group_id,$client_checklist_id);
				$metricGroups[] = $row;
			}
			$result->close();
		}
		return($metricGroups);
	}	

	private function getGroupMetrics($metric_group_id,$client_checklist_id) {
		$siblingClientChecklists = $this->getSiblingClientChecklists($client_checklist_id);
		$metrics = array();

		$query = sprintf('
			SELECT
			metric.*,
			IFNULL(client_2_metric.disabled,0) AS disabled
			FROM %1$s.metric
			LEFT JOIN (SELECT * FROM %1$s.client_2_metric WHERE client_id = (SELECT client_id FROM %1$s.client_checklist WHERE client_checklist_id = %3$d)) client_2_metric ON metric.metric_id = client_2_metric.metric_id
			WHERE metric.metric_group_id = %2$d
			ORDER BY metric.sequence
		',
			DB_PREFIX.'checklist',
			$metric_group_id,
			$client_checklist_id
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$row->metricUnits = $this->getMetricUnits($row->metric_id);
				$row->clientMetricResults = $this->getClientMetricResults($row->metric_id,$client_checklist_id);
				$row->defaultMetricUnits = $this->getDefaultMetricUnit($row->metric_id,$client_checklist_id, $row->metricUnits, $row->clientMetricResults);
				$row->siblingClientMetricResultsDataArray = $this->getFormattedSibligClientMetricResults($row->metric_id,$client_checklist_id, $siblingClientChecklists, $row->metricUnits);
				$row->clientMetricVariations = $this->getClientMetricVariations($row->metric_id,$client_checklist_id);
				$row->clientSubMetrics = $this->getClientSubMetric($row->metric_id,$client_checklist_id);
				$metrics[] = $row;
			}
			$result->close();
		}
		return($metrics);
	}

	private function getMetricUnits($metric_id) {
		$metricUnits = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`metric_unit_type_2_metric`.`metric_unit_type_2_metric_id`,
				`metric_unit_type`.`metric_unit_type_id`,
				`metric_unit_type`.`metric_unit_type`,
				`metric_unit_type`.`description`,
				`metric_unit_type_2_metric`.`conversion`,
				`metric_unit_type_2_metric`.`default`
			FROM `%1$s`.`metric_unit_type_2_metric`
			LEFT JOIN `%1$s`.`metric_unit_type` USING(`metric_unit_type_id`)
			WHERE `metric_unit_type_2_metric`.`metric_id` = %2$d
			ORDER BY `metric_unit_type`.`metric_unit_type` ASC;
		',
			DB_PREFIX.'checklist',
			$metric_id
		))) {
			while($row = $result->fetch_object()) {
				$metricUnits[] = $row;
			}
			$result->close();
		}
		return($metricUnits);
	}

	private function getClientMetricResults($metric_id, $client_checklist_id) {
		$clientMetricResults = array();
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_metric`
			WHERE `metric_id` = %2$d
			AND `client_checklist_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			$metric_id,
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$clientMetricResults[] = $row;
			}
			$result->close();
		}
		return($clientMetricResults);
	}

	private function getDefaultMetricUnit($metric_id, $client_checklist_id, $metricUnits, $clientMetricResults) {
		$defaultMetricUnits = array();
		$client_metric_results_count = count($clientMetricResults);
		$metric_units_count = count($metricUnits);

		//1: Check for existing clientMetric for the given client checklist
		if(!empty($clientMetricResults)) {
			for($i = 0; $i < $client_metric_results_count; $i++) {
				for($j = 0; $j < $metric_units_count; $j++) {
					if($clientMetricResults[$i]->metric_unit_type_id === $metricUnits[$j]->metric_unit_type_id) {
						$defaultMetricUnits[] = $metricUnits[$j];
					}
				} 
			}
		}

		//2: If no existing clientMetric check for the previous result based on entry period finish
		if(empty($defaultMetricUnits)) {

			$query = sprintf('
				SELECT
				client_metric.*,
				metric_unit_type.metric_unit_type
				FROM greenbiz_checklist.client_checklist 
				LEFT JOIN greenbiz_checklist.client_metric ON client_checklist.client_checklist_id = client_metric.client_checklist_id
				LEFT JOIN greenbiz_checklist.metric_unit_type ON client_metric.metric_unit_type_id = metric_unit_type.metric_unit_type_id
				WHERE client_checklist.client_id = (SELECT client_checklist.client_id FROM greenbiz_checklist.client_checklist WHERE client_checklist.client_checklist_id = %3$d)
				AND client_metric.metric_id = %2$d
				ORDER BY client_checklist.date_range_start DESC
				LIMIT 1
			',
				DB_PREFIX.'checklist',
				$metric_id,
				$client_checklist_id
			);

			if($result = $this->db->query($query)) {
				while($row = $result->fetch_object()) {
					$defaultMetricUnits[] = $row;
				}
				$result->close();
			}
		}

		//3: If no default set, check the metric to see if there is a default
		if(empty($defaultMetricUnits) && !empty($metricUnits)) {

			for($i = 0; $i < $metric_units_count; $i++) {
				if($metricUnits[$i]->default === 1) {
					$defaultMetricUnits[] = $metricUnits[$j];
				}
			}

			//4: Get the first metric unit type alphabetically
			if(empty($defaultMetricUnits)) {
				$defaultMetricUnits[] = isset($metricUnits[0]) ? $metricUnits[0] : null;
			}
		}

		return $defaultMetricUnits;
	}

	private function getClientMetricVariations($metric_id, $client_checklist_id) {
		$clientMetricVariations = array();
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_metric_variation`
			WHERE `metric_id` = %2$d
			AND `client_checklist_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			$metric_id,
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$clientMetricVariations[] = $row;
			}
			$result->close();
		}
		return($clientMetricVariations);
	}

	private function getClientSubMetric($metric_id, $client_checklist_id) {
		$clientSubMetrics = array();
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_sub_metric`
			WHERE `metric_id` = %2$d
			AND `client_checklist_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			$metric_id,
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$clientSubMetrics[] = $row;
			}
			$result->close();
		}
		return($clientSubMetrics);
	}

	private function getFormattedSibligClientMetricResults($metric_id, $client_checklist_id, $siblingClientChecklists, $metricUnits) {
		$clientChecklist = $this->getClientChecklist($client_checklist_id);
		$formattedClientMetricResults = array();

		//Get the value from last month
		$last_month = $this->getLastMonthClientMetricResult($metric_id, $clientChecklist, $metricUnits);
		!empty($last_month) ? $formattedClientMetricResults[] = $last_month : null;

		//Get the value from last year
		$last_year = $this->getLastYearClientMetricResult($metric_id, $clientChecklist, $metricUnits);
		!empty($last_year) ? $formattedClientMetricResults[] = $last_year : null;

		//Get the values for the given AU financial Year
		$current_fy_au = $this->getCurrentFinancialYearAUClientMetricResult($metric_id, $clientChecklist, $metricUnits);
		!empty($current_fy_au) ? $formattedClientMetricResults[] = $current_fy_au : null;

		return $formattedClientMetricResults;
	}

	private function getLastMonthClientMetricResult($metric_id, $clientChecklist, $metricUnits) {
		$clientMetricResults = array();
		$key = 'previous_month';

		if($result = $this->db->query(sprintf('
			SELECT
			"%5$s" as `key`,
			`client_metric`.*
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
			WHERE `client_metric`.`metric_id` = %2$d
			AND `client_checklist`.`client_id` = %3$d
			AND MONTHNAME(`client_checklist`.`date_range_start`) = MONTHNAME(DATE_SUB("%4$s", INTERVAL 1 MONTH))
			AND YEAR(`client_checklist`.`date_range_start`) = YEAR(DATE_SUB("%4$s", INTERVAL 1 MONTH))
			LIMIT 1;
		',
			DB_PREFIX.'checklist',
			$metric_id,
			$clientChecklist->client_id,
			$clientChecklist->date_range_start,
			$key
		))) {
			while($row = $result->fetch_object()) {
				$clientMetricResults[] = $row;
			}
			$result->close();
		}
		$clientMetricResults = $this->getClientMetricConversionFactors($clientMetricResults, $metric_id, $clientChecklist, $metricUnits, $key);

		return($clientMetricResults);
	}

	private function getLastYearClientMetricResult($metric_id, $clientChecklist, $metricUnits) {
		$clientMetricResults = array();
		$key = 'previous_year';

		$query = sprintf('
			SELECT
			"%5$s" as `key`,
			`client_metric`.*
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
			WHERE `client_metric`.`metric_id` = %2$d
			AND `client_checklist`.`client_id` = %3$d
			AND MONTHNAME(`client_checklist`.`date_range_start`) = MONTHNAME(DATE_SUB("%4$s", INTERVAL 1 YEAR))
			AND YEAR(`client_checklist`.`date_range_start`) = YEAR(DATE_SUB("%4$s", INTERVAL 1 YEAR))
			LIMIT 1;
		',
			DB_PREFIX.'checklist',
			$metric_id,
			$clientChecklist->client_id,
			$clientChecklist->date_range_start,
			$key
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clientMetricResults[] = $row;
			}
			$result->close();
		}
		$clientMetricResults = $this->getClientMetricConversionFactors($clientMetricResults, $metric_id, $clientChecklist, $metricUnits, $key);

		return($clientMetricResults);
	}

	private function getCurrentFinancialYearAUClientMetricResult($metric_id, $clientChecklist, $metricUnits) {
		$clientMetricResults = array();
		$key = 'current_fy_au';

		if($result = $this->db->query(sprintf('
			SELECT
			"%6$s" as `key`,
			`client_metric`.*
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
			WHERE `client_metric`.`metric_id` = %2$d
			AND `client_checklist`.`client_id` = %3$d
			AND (`client_checklist`.`date_range_start`) >= "%4$s"
			AND (`client_checklist`.`date_range_start`) <= "%5$s";
		',
			DB_PREFIX.'checklist',
			$metric_id,
			$clientChecklist->client_id,
			!is_null($clientChecklist->date_range_start) ? DATE('Y-m-d', strtotime('JULY 1 ' . date("Y", date("n", strtotime($clientChecklist->date_range_start)) < 7 ? strtotime($clientChecklist->date_range_start . "- 1 YEAR") : strtotime($clientChecklist->date_range_start)))) : null,
			$clientChecklist->date_range_finish,
			$key
		))) {
			while($row = $result->fetch_object()) {
				$clientMetricResults[] = $row;
			}
			$result->close();
		}

		$clientMetricResults = $this->getClientMetricConversionFactors($clientMetricResults, $metric_id, $clientChecklist, $metricUnits, $key);

		return($clientMetricResults);
	}

	private function getClientMetricConversionFactors($clientMetricResults, $metric_id, $clientChecklist, $metricUnits, $key) {
		$clientMetricConversions = array();
		$metric_unit_count = count($metricUnits);

		//For the given metric, loop through all available metric unit types
		for($i = 0; $i < $metric_unit_count; $i++){
			$clientMetricConversion = new stdClass;
			$clientMetricConversion->key = $key;
			$clientMetricConversion->metric_id = $metric_id;
			$clientMetricConversion->metric_unit_type_2_metric_id = $metricUnits[$i]->metric_unit_type_2_metric_id;
			$clientMetricConversion->metric_unit_type_id = $metricUnits[$i]->metric_unit_type_id;
			$clientMetricConversion->value = null; //Set a default value

			//If this metric contains client results we need to compile the converted value
			if(!empty($clientMetricResults)) {
				$client_metric_results_count = count($clientMetricResults);

				//Loop the client results
				for($j = 0; $j < $client_metric_results_count; $j++) {

					//Loop the metric unit types to find a match
					for($k = 0; $k < $metric_unit_count; $k++) {

						//Add the value (calculated if required), to the conversion value
						if($metricUnits[$k]->metric_unit_type_id === $clientMetricResults[$j]->metric_unit_type_id) {
							//Convert to base
							$base = $clientMetricResults[$j]->value * ($metricUnits[$k]->conversion > 0 ? $metricUnits[$k]->conversion : 1);
							//Convert to unit
							$clientMetricConversion->value += $base * (1/($metricUnits[$i]->conversion > 0 ? $metricUnits[$i]->conversion : 1));
						}
					}
				}
			}

			//Round to 6 decimal places max
			if(!is_null($clientMetricConversion->value)) {	
				$clientMetricConversion->value = round($clientMetricConversion->value, 6);
			}
			$clientMetricConversions[] = $clientMetricConversion;
		}

		return $clientMetricConversions;
	}

	public function getChecklistMetricVariationOptions($client_checklist_id) {
		$checklistVariationOptions = array();

		if($result = $this->db->query(sprintf('
			SELECT `metric_variation_option`.*
			FROM `%1$s`.`client_checklist`
            LEFT JOIN `%1$s`.`metric_variation_option` ON `client_checklist`.`checklist_id` = `metric_variation_option`.`checklist_id`
			WHERE `client_checklist`.`client_checklist_id` = %2$d
			ORDER BY `metric_variation_option`.`value` ASC
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$checklistVariationOptions[] = $row;
			}
			$result->close();
		}
		return($checklistVariationOptions);
	}

	private function getSiblingClientMetricResults($metric_id, $client_checklist_id, $siblingClientChecklists) {
		$siblingClientMetricResults = array();
		if($result = $this->db->query(sprintf('
			SELECT
			`client_metric`.*,
			`client_checklist`.`date_range_start`,
			`client_checklist`.`date_range_finish`
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
			WHERE `client_metric`.`metric_id` = %2$d
			AND `client_metric`.`client_checklist_id` IN (%3$s);
		',
			DB_PREFIX.'checklist',
			$metric_id,
			implode(",", $siblingClientChecklists)
		))) {
			while($row = $result->fetch_object()) {
				$siblingClientMetricResults[] = $row;
			}
			$result->close();
		}

		return $siblingClientMetricResults;
	}

	//------------------------------------
	//Returns an array of clientChecklists from the same client_id and checklist_id
	private function getSiblingClientChecklists($client_checklist_id) {
		$clientChecklists = array();
		$clientChecklist = $this->getClientChecklist($client_checklist_id);

		if($result = $this->db->query(sprintf('
			SELECT
				`client_checklist_id`
			FROM `%1$s`.`client_checklist`
			WHERE `checklist_id` = %2$d
			AND `client_id` = %3$d
			AND `client_checklist_id` != %4$d;
		',
			DB_PREFIX.'checklist',
			$clientChecklist->checklist_id,
			$clientChecklist->client_id,
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$clientChecklists[] = $row->client_checklist_id;
			}
			$result->close();
		}

		return $clientChecklists;
	}

	
	//Delete the client result for the given client_checklist and question_id
	public function deleteClientResult($client_checklist_id, $question_id, $answer_id = null, $index = null) {
		$filter = '';
		$filter .= !is_null($answer_id) ? ' AND `answer_id` = ' . $answer_id : null;
		$filter .= !is_null($index) ? ' AND `index` = ' . $index : null;

		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`client_result`
			WHERE 1 %4$s
			AND `client_checklist_id` = %2$d
			AND `question_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($question_id),
			$this->db->escape_string($filter)
		));

		return;
	}
	
	//Delete the client result for the given client_checklist and question_isd
	public function deleteAdditionalValue($client_checklist_id, $key, $index = 0) {
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`additional_value`
			WHERE `client_checklist_id` = %2$d
			AND `key` = "%3$s"
			AND `index` = %4$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($key),
			$this->db->escape_string($index)
		));

		return;
	}

	//Delete all of the additional values for the client checklist
	public function deleteClientChecklistAdditionalValues($client_checklist_id) {
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`additional_value`
			WHERE `client_checklist_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		));

		return;
	}

	//Delete the client result for the given client_checklist and question_id
	//This is for multi-site therefore multiple entries will be deleted in the single query
	public function deleteClientSiteResult($client_checklist_id,$question_id) {
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`client_site_result`
			WHERE `client_checklist_id` = %2$d
			AND `question_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($question_id)
		));
		return;
	}

	//Delete the client result for the given client_checklist and question_id
	public function deleteClientPageResults($client_checklist_id,$questions) {
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`client_result`
			WHERE `client_checklist_id` = %2$d
			AND `question_id` IN (%3$s);
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string(implode(',',$questions))
		));

		return;
	}
	
	//Get the answer_type when given the answer_id
	private function getAnswerType($answer_id) {
		if($result = $this->db->query(sprintf('
			SELECT
				`answer`.`answer_type`
			FROM `%1$s`.`answer`
			WHERE `answer`.`answer_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$answer_id
		))) {
			while($row = $result->fetch_object()) {
				$answer = $row->answer_type;
			}
			$result->close();
		}
		return $answer;
	}
	
	public function storeClientResult($client_checklist_id, $question_id, $answer_id, $arbitrary_value = null, $index = null) {
		//Check to see if the answer_type is a percentage, if so, remove the percentage sign before signing
		if($this->getAnswerType($answer_id) == 'percent') {
			$arbitrary_value = trim($arbitrary_value,'%');
		}
		
		$query = sprintf('
		INSERT INTO `%1$s`.`client_result` SET
			`client_checklist_id` = %2$d,
			`question_id` = %3$d,
			`answer_id` = %4$d,
			`index` = %5$d
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($question_id),
			$this->db->escape_string($answer_id),
			$this->db->escape_string(!is_null($index) ? $index : '0')
		);

		//Arbitrary Value
		$query .= is_null($arbitrary_value) ? ';' : sprintf(', `arbitrary_value` = "%1$s";', $this->db->escape_string($arbitrary_value));

		$this->db->query($query);
		return $this->db->insert_id;
	}


	public function storeAdditionalValue($client_checklist_id, $key, $value, $index = 0, $group = null) {		
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`additional_value` SET
				`client_checklist_id` = %2$d,
				`key` = "%3$s",
				`value` = "%4$s",
				`index` = %5$d,
				`group` = "%6$s";
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($key),
			$this->db->escape_string($value),
			$this->db->escape_string($index),
			$this->db->escape_string($group)
		));
		return $this->db->insert_id;
	}	

	//Save transaction time, store multiple client results at one time
	public function storeMultipleClientResults($clientResults) {

		if(!empty($clientResults)) {
			$values = '';
			foreach($clientResults as $result) {
				$values .= '(' . $this->db->escape_string($result->client_checklist_id) . ',' 
						. $this->db->escape_string($result->question_id) . ','
						. $this->db->escape_string($result->answer_id) . ','
						. (!is_null($result->arbitrary_value) ? '\'' . $this->db->escape_string(str_replace('%', '%%', $result->arbitrary_value)) . '\'' : "NULL" ) . ','
						. (!is_null($result->index) ? '\'' . $this->db->escape_string($result->index) . '\'' : "NULL" ) . '),';
			}
			$values = rtrim($values, ',');

			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`client_result`
					(`client_checklist_id`,`question_id`,`answer_id`,`arbitrary_value`, `index`)
				VALUES' 
				. $values . ';
			',
				DB_PREFIX.'checklist'
			));
		}
		return;
	}
	
	//Store the client result on multi-site questions for each site
	public function storeClientSiteResult($client_checklist_id,$client_site_id,$question_id,$answer_id,$arbitrary_value=null) {
		//Check to see if the answer_type is a percentage, if so, remove the percentage sign before signing
		if($this->getAnswerType($answer_id) == 'percent') {
			$arbitrary_value = trim($arbitrary_value,'%');
		}
		
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`client_site_result` SET
				`client_checklist_id` = %2$d,
				`client_site_id` = %3$d,
				`question_id` = %4$d,
				`answer_id` = %5$d,
				`arbitrary_value` = "%6$s";
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($client_site_id),
			$this->db->escape_string($question_id),
			$this->db->escape_string($answer_id),
			$this->db->escape_string($arbitrary_value)
		));
		return;
	}
	
	public function storeClientSite($client_site_id, $client_checklist_id, $name, $staff, $space, $unit) {
		$this->db->query(sprintf('
			REPLACE INTO `%1$s`.`client_site` SET
				`client_site_id` = %2$d,
				`client_checklist_id` = %3$d,
				`site_name` = "%4$s",
				`staff_number` = "%5$s",
				`office_space` = "%6$s",
				`office_space_unit` = "%7$s";
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_site_id),
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($name),
			$this->db->escape_string($staff),
			$this->db->escape_string($space),
			$this->db->escape_string($unit)
		));
		return;
	}
	
	public function storeClientMetric($client_checklist_id,$metric_id,$metric_unit_type_id,$value,$months = 1) {
		$this->deleteClientMetric($client_checklist_id, $metric_id);
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`client_metric` SET
				`client_checklist_id` = %2$d,
				`metric_id` = %3$d,
				`metric_unit_type_id` = %4$d,
				`value` = "%5$s",
				`months` = %6$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($metric_id),
			$this->db->escape_string($metric_unit_type_id),
			$this->db->escape_string($value),
			$this->db->escape_string($months)
		));

		return $this->db->insert_id;
	}

	//Delete the clientMetric
	public function deleteClientMetric($client_checklist_id,$metric_id) {
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`client_metric`
			WHERE `client_checklist_id` = %2$d
			AND `metric_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($metric_id)
		));
		return;
	}

	public function storeClientMetricVariation($client_metric_id,$client_checklist_id,$metric_id,$metric_variation_option_id,$value) {
		
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`client_metric_variation` SET
				`client_metric_id` = %2$d,
				`client_checklist_id` = %3$d,
				`metric_id` = %4$d,
				`metric_variation_option_id` = %5$d,
				`value` = "%6$s"
			ON DUPLICATE KEY UPDATE
				`client_checklist_id` = %3$d,
				`metric_id` = %4$d,
				`metric_variation_option_id` = %5$d,
				`value` = "%6$s";
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_metric_id),
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($metric_id),
			$this->db->escape_string($metric_variation_option_id),
			$this->db->escape_string($value)
		));

		return $this->db->insert_id;
	}

	//Delete the clientMetricVaraition
	public function deleteClientMetricVariation($client_checklist_id,$metric_id) {
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`client_metric_variation`
			WHERE `client_checklist_id` = %2$d
			AND `metric_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($metric_id)
		));
		return;
	}

	//Delete the clientSubMetric
	public function deleteClientSubMetric($client_checklist_id,$metric_id) {
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`client_sub_metric`
			WHERE `client_checklist_id` = %2$d
			AND `metric_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($metric_id)
		));
		return;
	}

	public function storeClientSubMetric($client_checklist_id,$metric_id,$description,$metric_unit_type_id,$value) {
		
		$query = sprintf('
			INSERT INTO `%1$s`.`client_sub_metric` SET
				`client_checklist_id` = %2$d,
				`metric_id` = %3$d,
				`description` = "%4$s",
				`metric_unit_type_id` = %5$d,
				`value` = "%6$s";
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($metric_id),
			$this->db->escape_string($description),
			$this->db->escape_string($metric_unit_type_id),
			$this->db->escape_string($value)
		);

		$this->db->query($query);

		return $this->db->insert_id;
	}

	//Delete the client page note
	public function deleteClientPageNote($client_checklist_id,$page_id) {
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`client_page_note`
			WHERE `client_checklist_id` = %2$d
			AND `page_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($page_id)
		));
		return;
	}
	
	//Insert the client page note
	public function storeClientPageNote($client_checklist_id,$page_id,$note) {
		$this->db->query(sprintf('
			REPLACE INTO `%1$s`.`client_page_note` SET
				`client_checklist_id` = %2$d,
				`page_id` = %3$d,
				`note` = "%4$s";
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($page_id),
			$this->db->escape_string($note)
		));
		return;
	}
	
	//Updated the updateChecklistProgress function to set max progress to 100 if the checklist is already completed - 20130730
	public function updateChecklistProgress($client_checkist_id,$progress,$completed=false) {
	
		$query = sprintf('
			UPDATE `%1$s`.`client_checklist` SET
				`progress` = IF(`completed` IS NOT NULL, 100, %3$d),
				`completed` = IF(%4$d,NOW(),NULL),
				`status` = IF(%4$d,2,1)
			WHERE `client_checklist_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checkist_id),
			$this->db->escape_string($progress),
			$this->db->escape_string($completed)
		);

		$this->db->query($query);
		return;
	}
	
	private function getDependencies($question_id) {
		$dependencies = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`answer_2_question`.`answer_2_question_id`,
				`answer_2_question`.`answer_id`,
				`answer_2_question`.`range_min`,
				`answer_2_question`.`range_max`,
				`answer`.`question_id`,
				`answer`.`answer_type`,
				`question`.`page_id`,
				`answer_2_question`.`comparator`
			FROM `%1$s`.`answer_2_question`
			LEFT JOIN `%1$s`.`answer` USING(`answer_id`)
			LEFT JOIN `%1$s`.`question` ON `answer`.`question_id` = `question`.`question_id`
			WHERE `answer_2_question`.`question_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$question_id
		))) {
			while($row = $result->fetch_object()) {
				$dependencies[] = $row;
			}
			$result->close();
		}
		return($dependencies);
	}
	
	public function pubGetQuestion($question_id) {
		return($this->getQuestion($question_id));
	}
	
	private function getQuestion($question_id) {
		$question = null;
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`question`
			WHERE `question`.`question_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$question_id
		))) {
			while($row = $result->fetch_object()) {
				$question = $row;
			}
			$result->close();
		}
		return($question);
	}
	
	public function pubGetAnswers($question_id) {
		return($this->getAnswers($question_id));
	}
	
	public function getAnswers($question_id) {
		$answers = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`answer`.*,
				`answer_string`.`string`
			FROM `%1$s`.`answer`
			LEFT JOIN `%1$s`.`answer_string` USING(`answer_string_id`)
			WHERE `answer`.`question_id` = %2$d
			ORDER BY `sequence` ASC;
		',
			DB_PREFIX.'checklist',
			$question_id
		))) {
			while($row = $result->fetch_object()) {
				$answers[] = $row;
			}
			$result->close();
		}
		return($answers);
	}
	
	//Get the Action Owners for this client
	private function getActionOwnersByClientId($client_checklist_id) {
		$action_owners = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			`action_owner`.*
			FROM `%1$s`.`action_owner`
			LEFT JOIN `%1$s`.`client_checklist` ON `action_owner`.`client_id` = `client_checklist`.`client_id`
			WHERE `client_checklist`.`client_checklist_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
			while($row = $result->fetch_object()) {
				$action_owners[] = $row;
			}
			$result->close();
		}
		return($action_owners);
		
	}
	
	//Get the Action Owners for this client
	private function getOwner2Action($client_checklist_id) {
		$owner_2_action = array();

		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`owner_2_action`
			WHERE `client_checklist_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
			while($row = $result->fetch_object()) {
				$owner_2_action[] = $row;
			}
			$result->close();
		}
		return($owner_2_action);
		
	}
	
	//Gets all of the audits based on triggers that the client_checklist has set off and the confirmationAudits
	public function getAudits($client_checklist_id) {
		$audits = array();

		if($result = $this->db->query(sprintf('
			SELECT
				`audit`.`audit_id`,
				`audit`.`answer_id`,
				`audit`.`arbitrary_value`,
				`audit`.`audit_type`,
				`question`.`question`,
				`question`.`question_id`
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`audit` ON
				`client_result`.`answer_id` = `audit`.`answer_id`
			AND (`client_result`.`arbitrary_value` = "" OR `client_result`.`arbitrary_value` IS NULL OR `client_result`.`arbitrary_value` >= `audit`.`arbitrary_value`)
			LEFT JOIN `%1$s`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id` 
			LEFT JOIN `%1$s`.`question` ON `answer`.`question_id` = `question`.`question_id`
			LEFT JOIN `%1$s`.`page` ON `question`.`page_id` = `page`.`page_id`
			WHERE `client_result`.`client_checklist_id` = %2$d
			AND `audit`.`audit_id` IS NOT NULL
			GROUP BY `audit`.`answer_id`
			ORDER BY `page`.`sequence`, `question`.`sequence`, `answer`.`sequence`;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
			while($row = $result->fetch_object()) {
				
				$audits[] = $row;
			}
			$result->close();
		}
		return($audits);
	}
	
	//Gets all of the commitmentAudits based the client commitments
	public function getCommitmentAudits($client_checklist_id) {
		$commitmentAudits = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
				`audit`.`audit_id`,
				`audit`.`answer_id`,
				`audit`.`arbitrary_value`,
				`audit`.`audit_type`,
				`question`.`question`,
				`question`.`question_id`
			FROM `%1$s`.`client_commitment`
      			LEFT JOIN `%1$s`.`action_2_answer` ON `client_commitment`.`action_id` = `action_2_answer`.`action_id`
				LEFT JOIN `%1$s`.`answer` ON `action_2_answer`.`answer_id` = `answer`.`answer_id` 
				LEFT JOIN `%1$s`.`question` ON `answer`.`question_id` = `question`.`question_id`
     	 		LEFT JOIN `%1$s`.`answer` AS `answer2` ON `question`.`question_id` = `answer2`.`question_id`
      			LEFT JOIN `%1$s`.`audit` ON `answer2`.`answer_id` = `audit`.`answer_id`
			WHERE `client_commitment`.`client_checklist_id` = %2$d AND `client_commitment`.`commitment_id` != "0" AND `audit`.`audit_id` IS NOT NULL
			GROUP BY `audit`.`answer_id`
			ORDER BY `question`.`question_id`;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
			while($row = $result->fetch_object()) {
				$commitmentAudits[] = $row;
			}
			$result->close();
		}
		
		return($commitmentAudits);
	}
	
	//Get Audit Evidence
	public function getAuditEvidence($client_checklist_id) {
		$evidence = array();
		$fileDownload = new fileDownload($this->db);

		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`audit_evidence`
			WHERE `client_checklist_id` = %2$d;
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($client_checklist_id)
		))) {
			while($row = $result->fetch_object()) {
				
				//Get the file information
				$file = $fileDownload->getFileInfo($row->value);
				$row->hash = isset($file->hash) ? $file->hash : null;
				$row->name = isset($file->name) ? $file->name : null;
				$row->size = isset($file->size) ? $file->size : null;
				$row->readable_size = isset($file->readable_size) ? $file->readable_size : null;
				$row->upload_date = isset($file->upload_date) ? $file->upload_date : null;

				//Set the evidence node
				$evidence[] = $row;
			}
			$result->close();
		}
		return($evidence);
	}
	
	//Get all of the audit 
	public function getClientChecklistAuditDetails($client_checklist_id) {
		$client_audits = array();

		$query = sprintf('
			SELECT
			audit.*,
			audit_status.status AS audit_status
			FROM %1$s.audit
			LEFT JOIN %1$s.audit_status ON audit_status.status_id = audit.status
			LEFT JOIN %2$s.client_checklist ON audit.client_checklist_id = client_checklist.client_checklist_id
			WHERE audit.client_checklist_id = %3$d
		',
			DB_PREFIX.'audit',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$client_audits[] = $row;
			}
			$result->close();
		}
		return($client_audits);
	}
	
	//Gets all of the metrics for the current checklist
	public function getClientMetrics($client_checklist_id) {
		$clientMetrics = array();

		if($result = $this->db->query(sprintf('
			SELECT
				`client_metric`.`client_metric_id`,
				`client_metric`.`months`,
				`client_metric`.`value`,
				`metric`.`metric`,
				`metric_group`.`name`,
				`metric_group`.`metric_group_id`,
				`metric_unit_type`.`description`,
				`metric`.`sequence`
			FROM
				`%1$s`.`client_metric`
				LEFT JOIN `%1$s`.`metric` ON `metric`.`metric_id` = `client_metric`.`metric_id`
				LEFT JOIN `%1$s`.`metric_group` ON `metric_group`.`metric_group_id` = `metric`.`metric_group_id`
				LEFT JOIN `%1$s`.`metric_unit_type` ON `metric_unit_type`.`metric_unit_type_id` = `client_metric`.`metric_unit_type_id`
			WHERE `client_metric`.`client_checklist_id` = %2$d
			ORDER BY `metric`.`sequence`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
			while($row = $result->fetch_object()) {
				$clientMetrics[] = $row;
			}
			$result->close();
		}
		return($clientMetrics);
	}
	
	//Gets all of the metric Groups for the current checklist
	public function getMetricGroups($client_checklist_id) {
		$metricGroups = array();

		if($result = $this->db->query(sprintf('
			SELECT DISTINCT
				`metric_group`.`metric_group_id`,
				`metric_group`.`name`,
				`metric_group`.`description`,
				`metric_group`.`sequence`
				
			FROM
				`%1$s`.`client_metric`
				LEFT JOIN `%1$s`.`metric` ON `metric`.`metric_id` = `client_metric`.`metric_id`
				LEFT JOIN `%1$s`.`metric_group` ON `metric_group`.`metric_group_id` = `metric`.`metric_group_id`
			WHERE `client_metric`.`client_checklist_id` = %2$d AND `metric_group`.`metric_group_id` IS NOT NULL
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
			while($row = $result->fetch_object()) {
				$metricGroups[] = $row;
			}
			$result->close();
		}
		return($metricGroups);
	}
	
	//Return the clientResult and ClientSiteResult in a single query for use in reporting
	public function getQuestionAnswers($client_checklist_id) {
		$file = new fileDownload($this->db);
		$questionAnswers = array();

		$query = sprintf('
			SELECT `qa_query`.* FROM((SELECT
				`question`.`question_id`,
				`question`.`question`,
				`answer_string`.`string` AS `answer_string`,
				`client_result`.`arbitrary_value`,
				IF(`client_result`.`index` = 0, `question`.`index`, `client_result`.`index`) AS `index`,
				`answer`.`answer_type`,
				`page`.`page_id`,
				`page_section_2_page`.`page_section_id`,
				`answer`.`answer_id`,
				`question`.`multi_site`,
				`question`.`sequence`,
				NULL AS `client_site_id`,
				`answer`.`function`,
				`answer`.`range_unit`,
				`page`.`sequence` AS `page_sequence`,
				`question`.`sequence` AS `question_sequence`,
				`answer`.`sequence` AS `answer_sequence`,
				question.show_in_analytics,
				question.export_key,
				question.alt_key,
				question.tip,
				question.repeatable,
				question.validate
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id`
			LEFT JOIN `%1$s`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
			LEFT JOIN `%1$s`.`question` ON `client_result`.`question_id` = `question`.`question_id`
			LEFT JOIN `%1$s`.`page` ON `question`.`page_id` = `page`.`page_id`
			LEFT JOIN `%1$s`.`page_section_2_page` ON `page`.`page_id` = `page_section_2_page`.`page_id`
			WHERE `client_result`.`client_checklist_id` = %2$d)
			
			UNION
			
			(SELECT
				`question`.`question_id`,
				`question`.`question`,
				`answer_string`.`string` AS `answer_string`,
				`client_site_result`.`arbitrary_value`,
				NULL AS `index`,
				`answer`.`answer_type`,
				`page`.`page_id`,
				`page_section_2_page`.`page_section_id`,
				`answer`.`answer_id`,
				`question`.`multi_site`,
				`question`.`sequence`,
				`client_site_result`.`client_site_id`,
				`answer`.`function`,
				`answer`.`range_unit`,
				`page`.`sequence` AS `page_sequence`,
				`question`.`sequence` AS `question_sequence`,
				`answer`.`sequence` AS `answer_sequence`,
				question.show_in_analytics,
				question.export_key,
				question.alt_key,
				question.tip,
				question.repeatable,
				question.validate
			FROM `%1$s`.`client_site_result`
			LEFT JOIN `%1$s`.`answer` ON `client_site_result`.`answer_id` = `answer`.`answer_id`
			LEFT JOIN `%1$s`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
			LEFT JOIN `%1$s`.`question` ON `client_site_result`.`question_id` = `question`.`question_id`
			LEFT JOIN `%1$s`.`page` ON `question`.`page_id` = `page`.`page_id`
			LEFT JOIN `%1$s`.`page_section_2_page` ON `page`.`page_id` = `page_section_2_page`.`page_id`
			WHERE `client_site_result`.`client_checklist_id` = %2$d)) `qa_query`
			WHERE `qa_query`.`question_id` IS NOT NULL
			ORDER BY `qa_query`.`page_sequence`, `qa_query`.`question_sequence`, `qa_query`.`answer_sequence`;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {

				//Additional answer information
				switch($row->answer_type) {
					case 'file-upload':
						if($row->arbitrary_value != '') {
							$fileInfo = $file->getFileInfo($row->arbitrary_value);
							$row = (object)array_merge((array)$row,(array)$fileInfo);
						}
						break;
				}

				$questionAnswers[$row->question_id][] = $row;
			}
			$result->close();
		}
		
		return($questionAnswers);
	}

	public function getClientChecklistPages($client_checklist_id) {
		$pages = array();
	
		$query = sprintf('
			SELECT
				`page`.`page_id`,
				`page`.`checklist_id`,
				`page`.`sequence`,
				`page`.`title`,
				IF(`page`.`notes_field_title` IS NULL or `page`.`notes_field_title` = "", "Additional Information and Notes", `page`.`notes_field_title`) AS `notes_field_title`,
				`client_page_note`.`note`,
				`page_section_2_page`.`page_section_id`
			FROM `%1$s`.`page`
			LEFT JOIN `%1$s`.`checklist` ON `page`.`checklist_id` = `checklist`.`checklist_id`
			LEFT JOIN `%1$s`.`client_checklist` ON `checklist`.`checklist_id` = `client_checklist`.`checklist_id`
			LEFT JOIN `%1$s`.`client_page_note` ON `client_checklist`.`client_checklist_id` = `client_page_note`.`client_checklist_id` AND `page`.`page_id` = `client_page_note`.`page_id`
			LEFT JOIN `%1$s`.`page_section_2_page` ON `page`.`page_id` = `page_section_2_page`.`page_id`
			WHERE `client_checklist`.`client_checklist_id` = %2$d
			ORDER BY `page`.`sequence`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$pages[] = $row;
			}
			$result->close();
		}
		return($pages);
		
	}

	public function getClientChecklistPageSections($client_checklist_id) {
		$pageSections = array();
	
		$query = sprintf('
			SELECT *
			FROM %1$s.page_section
			WHERE checklist_id = (SELECT checklist_id FROM %1$s.client_checklist WHERE client_checklist_id = %2$d)
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$pageSections[] = $row;
			}
			$result->close();
		}
		return($pageSections);
	}
	
	//Get the questions that are masters and triggered slaves
	public function getMasterAndSlaveQuestions($client_checklist_id) {
		$questions = array();
	
		$query = sprintf('
			SELECT
			`client_result`.`question_id`
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`answer_2_question` ON `client_result`.`question_id` = `answer_2_question`.`question_id`
			WHERE `client_result`.`client_checklist_id` = %2$d
			AND (`answer_2_question`.`answer_id` IS NULL
			OR `answer_2_question`.`answer_id` IN (
				SELECT `cr`.`answer_id`
				FROM `%1$s`.`client_result` AS `cr`
				WHERE `cr`.`client_checklist_id` = %2$d))
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$questions[] = $row->question_id;
			}
			$result->close();
		}
		return($questions);
		
	}

	//Get the questions that are masters and triggered slaves
	public function getTallyQuestionIdentifiers($client_checklist_id) {
		$questions = array();
	
		if($result = $this->db->query(sprintf('
			SELECT `action_2_answer`.`question_id`
			FROM `%1$s`.`action_2_answer`
			LEFT JOIN `%1$s`.`question` ON `question`.`question_id` = `action_2_answer`.`question_id`
			LEFT JOIN `%1$s`.`checklist` ON `question`.`checklist_id` = `checklist`.`checklist_id`
			LEFT JOIN `%1$s`.`client_checklist` ON `checklist`.`checklist_id` = `client_checklist`.`checklist_id`
			WHERE `client_checklist`.`client_checklist_id` = %2$d
			AND `action_2_answer`.`answer_id` = "-1"
			GROUP BY `action_2_answer`.`question_id`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
			while($row = $result->fetch_object()) {
				$questions[] = $row->question_id;
			}
			$result->close();
		}
		return($questions);
		
	}
	
	//Get a list of questions that are only asked because they are triggered by another answer
	public function getTriggeredQuestions($client_checklist_id) {
		$triggeredQuestions = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`answer_2_question`.*,
				`client_result`.`question_id` AS `parent_question_id`
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`answer_2_question` ON `client_result`.`answer_id` = `answer_2_question`.`answer_id`
			WHERE `client_result`.`client_checklist_id` = %2$d
			AND `answer_2_question`.`answer_2_question_id` IS NOT NULL;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
			while($row = $result->fetch_object()) {
				$triggeredQuestions[$row->question_id][] = $row;
			}
			$result->close();
		}
		return($triggeredQuestions);
	}
	
	public function generateAnswerReport($client_checklist_id) {
		$pages = array();
		$fileDownload = new fileDownload($this->db);
		$this->getReport($client_checklist_id);
		if($result = $this->db->query(sprintf('
			SELECT
				`client`.`company_name`,
				client.city_id,
				client.suburb,
				client.state,
				client.postcode,
				client.country,
				client.parent_id,
				`client_checklist`.`name`,
				`client_checklist`.`initial_score`,
				`client_checklist`.`checklist_id`,
				client_contact.phone,
				client_contact.email,
				client_contact.firstname,
				client_contact.lastname
			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%2$s`.`client` USING(`client_id`)
			LEFT JOIN `%2$s`.`client_contact` USING(`client_id`)
			WHERE `client_checklist_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$this->db->escape_string($client_checklist_id)
		))) {
			if($row = $result->fetch_object()) {
				$checklist = $row;
			}
			$result->close();
		}
		if($result = $this->db->query(sprintf('
			SELECT
				`page`.`page_id`,
				`page`.`title`,
				`page`.`show_notes_field`,
				`client_page_note`.`note`,
				`page_section`.`title` AS `page_section_title`
			FROM `%1$s`.`page`
			LEFT JOIN `%1$s`.`client_checklist` ON
				`page`.`checklist_id` = `client_checklist`.`checklist_id`
			LEFT JOIN `%1$s`.`client_page_note` ON
				`client_checklist`.`client_checklist_id` = `client_page_note`.`client_checklist_id` AND
				`page`.`page_id` = `client_page_note`.`page_id`
			LEFT JOIN `%1$s`.`page_section_2_page` ON `page`.`page_id` = `page_section_2_page`.`page_id`
            LEFT JOIN `%1$s`.`page_section` ON `page_section_2_page`.`page_section_id` = `page_section`.`page_section_id`
			WHERE `client_checklist`.`client_checklist_id` = %2$d
			ORDER BY `page`.`sequence`;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
			while($row = $result->fetch_object()) {
				$row->questions = array();
				$pages[$row->page_id] = $row;
			}
			$result->close();
		}
		
		if($result = $this->db->query(sprintf('
			SELECT
				`question`.`page_id`,
				`question`.`question`,
				`answer_string`.`string` AS `answer_string`,
				`client_result`.`arbitrary_value`,
				`answer`.`answer_type`,
				`answer`.`range_unit`
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id`
			LEFT JOIN `%1$s`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
			LEFT JOIN `%1$s`.`question` ON `client_result`.`question_id` = `question`.`question_id`
			LEFT JOIN `%1$s`.`page` ON `question`.`page_id` = `page`.`page_id`
			WHERE `client_result`.`client_checklist_id` = %2$d
			AND `question`.`question_id` IS NOT NULL
			ORDER BY `page`.`sequence`, `question`.`sequence`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
			while($row = $result->fetch_object()) {
				$pages[$row->page_id]->questions[] = $row;
			}
			$result->close();
		}
		
		$message = 
			'<html><body>'.
			'<table border="1" style="border-collapse:collapse;">'.
			'<tr><th scope="row" style="text-align: left; width: 20%; padding:5px;" bgcolor="#ccc">Client Details</th><td colspan="2" style="padding:5px;" bgcolor="#ccc"></td></tr>'.
			'<tr><th scope="row" style="text-align: left; width: 20%; padding:5px;">Company Name</th><td colspan="2" style="padding:5px;">'.$checklist->company_name.'</td></tr>'.
			'<tr><th scope="row" style="text-align: left; padding:5px;">Location</th><td colspan="2" style="padding:5px;">'.$checklist->suburb.', ' . $checklist->state . ', ' . $checklist->country . ', ' . $checklist->postcode .'</td></tr>'.
			'<tr><th scope="row" style="text-align: left; padding:5px;">Contact Name</th><td colspan="2" style="padding:5px;">'.$checklist->firstname.' ' .$checklist->lastname.'</td></tr>'.
			'<tr><th scope="row" style="text-align: left; padding:5px;">Contact Phone</th><td colspan="2" style="padding:5px;">'.$checklist->phone.'</td></tr>'.
			'<tr><th scope="row" style="text-align: left; padding:5px;">Contact Email</th><td colspan="2" style="padding:5px;"><a href="mailto:'.$checklist->email.'">'.$checklist->email.'</a></td></tr>'.
			'<tr><th scope="row" style="text-align: left; padding:5px;">Checklist Name</th><td colspan="2" style="padding:5px;">'.$checklist->name.'</td></tr>'.
			'<tr><th scope="row" style="text-align: left; padding:5px;">Initial Score</th><td colspan="2" style="padding:5px;">'. ($checklist->initial_score * 100) .'%</td></tr>'."\n";
		foreach($pages as $page) {
			if(!count($page->questions)) continue;
			$message .= 
				'<tr><th scope="col" style="text-align: left;" bgcolor="#ccc" padding:5px;>Page</th><th colspan="2" bgcolor="#ccc" style="text-align:left; padding:5px;">' .($page->page_section_title != '' ? $page->page_section_title . ' - ' : '') . $page->title . '</th></tr>';
				
				//If the page doesn't have a notes field in the assessment - don't show this field in this report.
				if($page->show_notes_field != "0"){
					$message .='<tr><th scope="row" style="text-align: left; padding:5px;">Client Comment/Note</th><td colspan="2" style="padding:5px;">'.nl2br($page->note).'</td></tr>';
				}
				
				$message .= '<tr>'.
				'<th scope="col" bgcolor="#EEEEEE" style="text-align: left; padding:5px;" colspan="2">Question</th>'.
				'<th scope="col" bgcolor="#EEEEEE" style="text-align: left; padding:5px;">Answer</th>'.
				'</tr>'."\n";
			foreach($page->questions as $question) {
				$message .=
					'<tr>'.
					'<th scope="row" style="text-align: left; width: 60%; padding:5px;" colspan="2">'.$question->question.'</th>'.
					'<td style="padding:5px;">';
				switch($question->answer_type) {
					case 'checkbox':
					case 'drop-down-list': {
						$message .= $question->answer_string;
						break;
					}
					case 'checkbox-other': {
						$message .= "Other: ".$question->arbitrary_value;
						break;
					}
					case 'percent': {
						$message .= $question->arbitrary_value.'%';
						break;
					}
					case 'range': {
						$message .= $question->arbitrary_value.$question->range_unit;
						break;
					}
					case 'file-upload': {
						$message .= "Downloadable File: ";
						if($question->arbitrary_value == "") {
							$message .= "No file uploaded";
						} else {
							$file = $fileDownload->getFileInfo($question->arbitrary_value);
							$message .= "<a href=\"https://www.greenbizcheck.com/download/?hash=" . $file->hash . "\">" . $file->name . " (" . $file->readable_size . ")</a>";
						}
						
						break;
					}
					default: {
						$message .= nl2br($question->arbitrary_value);
						break;
					}
				}
				$message .=
					'</td>'.
					'</tr>'."\n";
			}
		}
		$message .= '</table></body></html>';
		return($message);
	}
	
	//Emails the questions and answers to the provided recipients, otherwise default to info@greenbizcheck.com
	public function emailAnswerReport($client_checklist_id, $recipient = "info@greenbizcheck.com") {
		$message = $this->generateAnswerReport($client_checklist_id);
		
		$from 			= 'GreenBizCheck <webmaster@greenbizcheck.com>';
		$returnPath		= '-fwebmaster@greenbizcheck.com';
		$company		= 'GreenBizCheck';
			
		$headers =
			"From: $from\r\n".
			"Reply-To: $from\r\n".
			"Return-Path: $from\r\n".
			"Organization: $company\r\n".
			"X-Priority: 3\r\n".
			"X-Mailer: PHP". phpversion() ."\r\n".
			"MIME-Version: 1.0\r\n".
			"Content-type: text/html; charset=UTF-8\r\n".
			"Content-Transfer-Encoding: base64\r\n";
			
		//Access the clientUtils class
		$objects = new stdClass();
		$objects->clientUtils = new clientUtils($this->db);
		
		if($result = $this->db->query(sprintf('
			SELECT
				`client`.`company_name`,
				client.city_id,
				client.suburb,
				client.state,
				client.postcode,
				client.parent_id,
				`client_checklist`.`name`,
				`client_checklist`.`initial_score`,
				`client_checklist`.`checklist_id`,
				client_contact.phone,
				client_contact.email,
				client_contact.firstname,
				client_contact.lastname
			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%2$s`.`client` USING(`client_id`)
			LEFT JOIN `%2$s`.`client_contact` USING(`client_id`)
			WHERE `client_checklist_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$this->db->escape_string($client_checklist_id),
			DB_PREFIX.'resources'
		))) {
			if($row = $result->fetch_object()) {
				$checklist = $row;
			}
			$result->close();
		}
		
		$subject = "Assessment Answer Report - Client: " . $checklist->company_name . ", Assessment: " . $checklist->name . ", Client Checklist ID: " . $client_checklist_id;
				
		$message = chunk_split(base64_encode($message));

		//If the client.parent_id is not equal to NULL - send the report email as CC to the associate email address
		if($checklist->parent_id != NULL){
			//Add the CC recipient list to the headers mail attribute
			$headers .= "CC: " . $objects->clientUtils->getClientContactEmailAddresses($checklist->parent_id) . "\r\n";
			mail($recipient,$subject,$message,$headers,'-fwebmaster@greenbizcheck.com');
		}
		else{
			mail($recipient,$subject,$message,$headers,'-fwebmaster@greenbizcheck.com');
		}
			
		return;
	}
	
	//Takes the checklist and checks for the checklist_id.  If it is '24' or (Office Mini Assessment) change client_type_id in core.client to '8' (Mini Assessment)
	public function assignClientTypeId($client_checklist_id) {
		
		$client_checklist;
		
		if($result = $this->db->query(sprintf('
			SELECT
				checklist_id,
				client_id
			FROM %1$s.client_checklist
			WHERE client_checklist_id = %2$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
				if($row = $result->fetch_object()) {
					$client_checklist = $row;
				}
				$result->close();
			}
			
			if($client_checklist->checklist_id == "24"){
				$this->db->query(sprintf('
					UPDATE %1$s.client SET
						client_type_id = %2$d
					WHERE client_id = %3$d;
				',
					DB_PREFIX.'core',
					$this->db->escape_string('8'),
					$this->db->escape_string($client_checklist->client_id)
				));
			}
		return;
	}
	
	public function reEvaluateReport($client_checklist_id,$commitments) {
		foreach($commitments as $action_id => $commitment_id) {
			$this->db->query(sprintf('
				REPLACE `%1$s`.`client_commitment` SET
					`client_checklist_id` = %2$d,
					`action_id` = %3$d,
					`commitment_id` = %4$d,
					`timestamp` = NOW();
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($client_checklist_id),
				$this->db->escape_string($action_id),
				$this->db->escape_string($commitment_id)
			));
		}
		return;
	}
	
	private function getReportSectionPoints($report_section_id,$client_checklist_id) {
		$points = 0;
		$checklist = $this->getChecklistByClientChecklistId($client_checklist_id);
		
		//Added check on completed report date due to bug found on scoring.
		//Actions were incorrectly grouped by question_id when they should be grouped by action_id
		//Each question can have one or many actions
		if($checklist->completed > "2012-04-18")
		{
			if($result = $this->db->query(sprintf('
				SELECT
	    			SUM(`max_points`.`demerits`) AS `points`
				FROM
	    			(SELECT
	         			MAX(`action`.`demerits`) AS `demerits`,
	         			`answer`.`answer_type`,
	         			`question`.`question`,
	         			`action_2_answer`.`answer_id`,
	         			`action`.`report_section_id`,
	         			`question`.`question_id`
	      			FROM `%1$s`.`client_result`
					LEFT JOIN `%1$s`.`client_checklist`
						ON `client_result`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
					LEFT JOIN `%1$s`.`answer`
						ON `client_result`.`question_id` = `answer`.`question_id`
	      			LEFT JOIN `%1$s`.`question`
	        			ON `question`.`question_id` = `answer`.`question_id`
					LEFT JOIN `%1$s`.`action_2_answer`
						ON `answer`.`answer_id` = `action_2_answer`.`answer_id`
	      			LEFT JOIN `%1$s`.`action`
	        			ON `action_2_answer`.`action_id` = `action`.`action_id`
					WHERE `client_result`.`client_checklist_id` = %2$d
					AND `action`.`report_section_id` = %3$d
					GROUP BY `question_id`) AS `max_points`
				GROUP BY `report_section_id`;
			',
				DB_PREFIX.'checklist',
				$client_checklist_id,
				$report_section_id
			))) {
				if($row = $result->fetch_object()) {
					$points = $row->points;
				}
				$result->close();
			}
		}
		else {
			if($checklist->completed > "2011-11-21") 
			{
				if($result = $this->db->query(sprintf('
					SELECT
		    			SUM(`max_points`.`demerits`) AS `points`
					FROM
		    			(SELECT
		         			MAX(`action`.`demerits`) AS `demerits`,
		         			`answer`.`answer_type`,
		         			`question`.`question`,
		         			`action_2_answer`.`answer_id`,
		         			`action`.`report_section_id`
		      			FROM `%1$s`.`client_result`
						LEFT JOIN `%1$s`.`client_checklist`
							ON `client_result`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
						LEFT JOIN `%1$s`.`answer`
							ON `client_result`.`question_id` = `answer`.`question_id`
		      			LEFT JOIN `%1$s`.`question`
		        			ON `question`.`question_id` = `answer`.`question_id`
						LEFT JOIN `%1$s`.`action_2_answer`
							ON `answer`.`answer_id` = `action_2_answer`.`answer_id`
		      			LEFT JOIN `%1$s`.`action`
		        			ON `action_2_answer`.`action_id` = `action`.`action_id`
						WHERE `client_result`.`client_checklist_id` = %2$d
						AND `action`.`report_section_id` = %3$d
						GROUP BY `answer_id`) AS `max_points`
					GROUP BY `report_section_id`;
				',
					DB_PREFIX.'checklist',
					$client_checklist_id,
					$report_section_id
				))) {
					if($row = $result->fetch_object()) {
						$points = $row->points;
					}
					$result->close();
				}
			}
			else {
				if($result = $this->db->query(sprintf('
		
				
					SELECT
						SUM(`action`.`demerits`) AS `points`
					FROM `%1$s`.`client_result`
					LEFT JOIN `%1$s`.`client_checklist`
						ON `client_result`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
					LEFT JOIN `%1$s`.`answer`
						ON `client_result`.`question_id` = `answer`.`question_id`
					LEFT JOIN `%1$s`.`action_2_answer`
						ON `answer`.`answer_id` = `action_2_answer`.`answer_id`
					LEFT JOIN `%1$s`.`action`
						ON `action_2_answer`.`action_id` = `action`.`action_id`
					AND IF(
						DATE(`client_checklist`.`completed`) between "2009-11-01" and "2011-11-17", `answer`.`answer_type` NOT IN("percent","range","int","float")
						OR `client_result`.`arbitrary_value` BETWEEN `action_2_answer`.`range_min` AND `action_2_answer`.`range_max`,
							1
						)
					AND IF(
						DATE(`client_checklist`.`completed`) > "2009-11-01", `answer`.`answer_type` NOT IN("percent","range","int","float")
						OR `client_result`.`arbitrary_value` BETWEEN `action_2_answer`.`range_min` AND `action_2_answer`.`range_max`,
							1
						)
					WHERE `client_result`.`client_checklist_id` = %2$d
					AND `action`.`report_section_id` = %3$d
					GROUP BY `action`.`report_section_id`;
				',
					DB_PREFIX.'checklist',
					$client_checklist_id,
					$report_section_id
				))) {
					if($row = $result->fetch_object()) {
						$points = $row->points;
					}
					$result->close();
				}
			}
		}
		return($points);
	}
	
	public function getGroupedClientChecklists($checklist_id, $client_id) {
	 $client_checklist_ids = array();
		if($result = $this->db->query(sprintf('
			SELECT
				client_checklist_id
			FROM %1$s.client_checklist
			WHERE checklist_id = %2$d
			AND client_id = %3$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($checklist_id),
			$this->db->escape_string($client_id)
		))) {
				while($row = $result->fetch_object()) {
					$client_checklist_ids[] = $row->client_checklist_id;
				}
				$result->close();
			}
		return $client_checklist_ids;	
	}
	
	public function getCompletedGroupedClientChecklists($checklist_id, $client_id) {
	 $client_checklist_ids = array();
		if($result = $this->db->query(sprintf('
			SELECT
				client_checklist_id
			FROM %1$s.client_checklist
			WHERE checklist_id = %2$d
			AND client_id = %3$d
			AND completed IS NOT NULL;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($checklist_id),
			$this->db->escape_string($client_id)
		))) {
				while($row = $result->fetch_object()) {
					$client_checklist_ids[] = $row->client_checklist_id;
				}
				$result->close();
			}
		return $client_checklist_ids;	
	}

	public function renameClientChecklist($client_checklist_id, $name) {
		$this->db->query(sprintf('
			UPDATE `%1$s`.`client_checklist` SET
				`name` = "%3$s"
			WHERE `client_checklist_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($name)
		));
		return;
	}
	
	public function getParentGroupedClientChecklists($client_checklist_id, $client_id) {
	 $client_checklist_ids = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`client_checklist`.`client_checklist_id`
			FROM `%1$s`.`client_checklist`
			WHERE `client_checklist`.`client_checklist_id` IN (
				SELECT
					`parent_2_child_checklist`.`child_checklist_id`
				FROM `%1$s`.`parent_2_child_checklist`
				WHERE `parent_2_child_checklist`.`parent_checklist_id` = %2$d
			)
			OR `client_checklist`.`client_checklist_id` = %2$d
			AND client_id = %3$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($client_id)
		))) {
				while($row = $result->fetch_object()) {
					$client_checklist_ids[] = $row->client_checklist_id;
				}
				$result->close();
			}
		return $client_checklist_ids;	
	}

	public function checklistAuditRequired($checklist_id) {
	 	$requires_audit = 0;
		if($result = $this->db->query(sprintf('
			SELECT
				audit
			FROM %1$s.checklist
			WHERE checklist_id = %2$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($checklist_id)
		))) {
				while($row = $result->fetch_object()) {
					if($row->audit == '1' && (strtotime(date("Y-m-d")) > strtotime(CLIENT_AUDIT_CUTOVER_DATE))) {
						$requires_audit = 1;
					}
				}
			}

		return $requires_audit;	
	}
	
	public function updateClientActionOwners($postVars) {
	 	$postVars = unserialize($postVars);
		
		//Now insert new entries
		$id = 0;
		if(isset($postVars['first_name'])) {
			foreach($postVars['first_name'] as $first_name) {
			 
				if($postVars['email'][$id] != "" || $postVars['first_name'][$id] != "" || $postVars['last_name'][$id] != "") {
				 	
					$this->db->query(sprintf('
						REPLACE INTO `%1$s`.`action_owner` SET
						`action_owner_id` = %5$d,
						`client_id` = %2$d,
						`first_name` = "%3$s",
						`last_name` = "%4$s",
						`email` = "%6$s";
					',
						DB_PREFIX.'checklist',
						$this->db->escape_string($postVars['action_owner_client_id']),
						$this->db->escape_string(($postVars['first_name'][$id] = "" ? NULL : $postVars['first_name'][$id])),
						$this->db->escape_string(($postVars['last_name'][$id] = "" ? NULL : $postVars['last_name'][$id])),
						$this->db->escape_string($postVars['existing_action_owner_id'][$id]),
						$this->db->escape_string(($postVars['email'][$id] = "" ? NULL : $postVars['email'][$id]))
					));
				}
				
				$id++;
			}
		}
		
		if(isset($postVars['delete'])) {
			//First see who has to be deleted
			foreach($postVars['delete'] as $deleteId) {
				$this->db->query(sprintf('
					DELETE FROM `%1$s`.`action_owner`
					WHERE `action_owner_id` = %2$d;
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($deleteId)
				));
				
				//Delete from the owner_2_action database
				$this->db->query(sprintf('
					DELETE FROM `%1$s`.`owner_2_action`
					WHERE `owner_id` = %2$d;
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($deleteId)
				));
			}
		}
		
		return;
	}
	
	public function updateClientQuestionOwners($postVars) {
	 	$postVars = unserialize($postVars);
		
		//Now insert new entries
		$id = 0;
		foreach($postVars['first_name'] as $first_name) {
		 
			if($postVars['email'][$id] != "" || $postVars['first_name'][$id] != "" || $postVars['last_name'][$id] != "") {
			 	
				$this->db->query(sprintf('
					REPLACE INTO `%1$s`.`question_owner` SET
					`question_owner_id` = %5$d,
					`client_id` = %2$d,
					`first_name` = "%3$s",
					`last_name` = "%4$s",
					`email` = "%6$s";
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($postVars['question_owner_client_id']),
					$this->db->escape_string(($postVars['first_name'][$id] = "" ? NULL : $postVars['first_name'][$id])),
					$this->db->escape_string(($postVars['last_name'][$id] = "" ? NULL : $postVars['last_name'][$id])),
					$this->db->escape_string($postVars['existing_question_owner_id'][$id]),
					$this->db->escape_string(($postVars['email'][$id] = "" ? NULL : $postVars['email'][$id]))
				));
			}
			
			$id++;
		}
		
		if(isset($postVars['delete'])) {
			//First see who has to be deleted
			foreach($postVars['delete'] as $deleteId) {
				$this->db->query(sprintf('
					DELETE FROM `%1$s`.`question_owner`
					WHERE `question_owner_id` = %2$d;
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($deleteId)
				));
				
				//Delete from the owner_2_question database
				$this->db->query(sprintf('
					DELETE FROM `%1$s`.`owner_2_question`
					WHERE `owner_id` = %2$d;
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($deleteId)
				));
			}
		}
		
		return;
	}
	
	//Assign the action owner based on an action_id, action_owner_id and a due date
	public function assignActionOwner($action_owner_id, $due_date, $action_id, $client_checklist_id, $owner_2_action_id, $email, $assigned_by) {
		 
		if(($action_owner_id != 'edit') && ($action_owner_id != 0)) {
		 	
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`owner_2_action` SET
				`owner_2_action_id` = %2$d,
				`client_checklist_id` = %3$d,
				`owner_id` = %4$d,
				`due_date` = "%5$s",
				`action_id` = %6$d,
				`assigned_by_client_contact_id` = %7$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($owner_2_action_id),
				$this->db->escape_string($client_checklist_id),
				$this->db->escape_string($action_owner_id),
				$this->db->escape_string($due_date),
				$this->db->escape_string($action_id),
				$this->db->escape_string($assigned_by)
			));
			
			if($email == 1) {
				$this->emailActionOwner($this->db->insert_id);	
			}
		}
		
		//Delete if needed
		if($action_owner_id == "" && $owner_2_action_id != 0) {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`owner_2_action`
				WHERE `owner_2_action_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($owner_2_action_id)
			));
		}
		
		return;
	}
	
	//The email checkbox has been selected for the action owner, try and email the action owner
	private function emailActionOwner($owner_2_action_id) {

		//Get the owner_2_action details
		$actionOwnerDetails = $this->getActionOwnerDetails($owner_2_action_id);
		
		//Get the action commitment options
		$commitments = $this->getActionCommitments($actionOwnerDetails->action_id);
		
		//If there is a valid email address, get the other details we need to construct an email
		if(!is_null($actionOwnerDetails->email) && $actionOwnerDetails->email != "") {
			//Construct the email
			$emailHeaders =
				"From: GreenBizCheck <info@greenbizcheck.com>\r\n".
				"Reply-To: $actionOwnerDetails->assigned_by_email\r\n".
				"Return-Path: GreenBizCheck <info@greenbizcheck.com>\r\n".
				"Organization: GreenBizCheck\r\n".
				"X-Priority: 3\r\n".
				"X-Mailer: PHP". phpversion() ."\r\n".
				"MIME-Version: 1.0\r\n".
				"Content-Type: text/html; charset=UTF-8\r\n";

			$emailBody = 
				'<html>'.
				'<body>'.
				'<p>Hi ' . $actionOwnerDetails->first_name . ',</p>'.
				'<p>' . $actionOwnerDetails->company_name . ' is undertaking <a href="http://www.greenbizcheck.com">GreenBizCheck</a> environmental certification and we have assigned you the task below. Could you please review this task and email <a href="mailto:'. $actionOwnerDetails->assigned_by_email . '">' . $actionOwnerDetails->assigned_by_email . '</a> with any questions and / or advise once it has been implemented.</p>'.
				'<p>
					<strong>Client:</strong> ' . $actionOwnerDetails->company_name . '<br />
					<strong>Assigned By:</strong> ';
			$assignedBy = $actionDetails->assigned_by_firstname;
			if($actionOwnerDetails->assigned_by_lastname != "") {
				$assignedBy .= " " . $actionOwnerDetails->assigned_by_lastname;
			}
			
			$emailBody .= $assignedBy . ' (<a href="mailto:' . $actionOwnerDetails->assigned_by_email . '">' . $actionOwnerDetails->assigned_by_email . '</a>)<br />
   					<strong>Assessment:</strong> ' . $actionOwnerDetails->checklist_name . '<br />
					<strong>Due:</strong> ' . ($actionOwnerDetails->due_date != "0000-00-00 00:00:00" ? date('j-n-Y', strtotime($actionOwnerDetails->due_date)) : "N/A") . '<br />
                    <strong>Action Id:</strong> ' . $actionOwnerDetails->action_id . '<br />
					<strong>Action:</strong> ' . $actionOwnerDetails->title . '<br />
					<strong>Detailed Information:</strong><br /><blockquote> ' . $actionOwnerDetails->proposed_measure . '</blockquote><br />
					<strong>Action Options:</strong><br /><ol> ';
						foreach($commitments as $commitment) {
							$emailBody .= '<li>' . $commitment->commitment . '</li>';
						}
				$emailBody .= '</ol><br />
				</p>
				<p>Kind regards,</p>
				<p>The GreenBizCheck Team<br />
					<a href="http://www.greenbizcheck.com/">www.greenbizcheck.com</a><br />
					e: <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a><br />
					p: 1300 552 335<br />
				</p>'.
				'</body>'.
				'</html>';
				
			mail($actionOwnerDetails->email,'New Action Assigned to you',$emailBody,$emailHeaders,'-finfo@greenbizcheck.com');
		}
	
		return;	
	}
	
	//Get all of the details for the current action
	private function getActionOwnerDetails($owner_2_action_id) {
		$actionOwnerDetails = null;
		
		if($result = $this->db->query(sprintf('
			SELECT
			`action_owner`.`first_name`,
			`action_owner`.`last_name`,
			`action_owner`.`email`,
			`action`.`title`,
			`action`.`proposed_measure`,
			`client`.`company_name`,
			`client_checklist`.`name` AS `checklist_name`,
			`owner_2_action`.`due_date`,
			`owner_2_action`.`action_id`,
			`client_contact`.`firstname` AS `assigned_by_firstname`,
			`client_contact`.`lastname` AS `assigned_by_lastname`,
			`client_contact`.`email` AS `assigned_by_email`
			FROM `%1$s`.`owner_2_action`
			LEFT JOIN `%1$s`.`action_owner` ON `owner_2_action`.`owner_id` = `action_owner`.`action_owner_id`
			LEFT JOIN `%1$s`.`action` ON `owner_2_action`.`action_id` = `action`.`action_id`
			LEFT JOIN `%2$s`.`client` ON `action_owner`.`client_id` = `client`.`client_id`
			LEFT JOIN `%1$s`.`client_checklist` ON `owner_2_action`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
			LEFT JOIN `%2$s`.`client_contact` ON `owner_2_action`.`assigned_by_client_contact_id` = `client_contact`.`client_contact_id`
			WHERE `owner_2_action`.`owner_2_action_id` = %3$d;
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$this->db->escape_string($owner_2_action_id)
		))) {
				while($row = $result->fetch_object()) {
					$actionOwnerDetails = $row;
				}		
			}
		
		return	$actionOwnerDetails;
	}
	
	//Get the commitment options for the current action
	private function getActionCommitments($action_id) {
		$actionCommitments = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			`commitment_id`,
			`commitment`
			FROM `%1$s`.`commitment`
			WHERE `action_id` = %2$d
			ORDER BY `merits` DESC;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($action_id)
		))) {
				while($row = $result->fetch_object()) {
					$actionCommitments[] = $row;
				}		
			}
		
		return	$actionCommitments;
	}
	
	//Allows the ability to add a product containing multiple checklists to a client account on registration
	public function addChecklistOnRegister($client_id,$product_id,$quantity) {
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT
				`checklist_2_product`.`checklist_id`,
				`checklist_2_product`.`checklist_variation_id`,
				`checklist_2_product`.`product_id`,
				`checklist_2_product`.`checklists`,
				IF(
					`checklist_variation`.`checklist_variation_id` IS NULL,
					`checklist`.`name`,
					`checklist_variation`.`name`
				) AS `name`
			FROM `%1$s`.`checklist_2_product`
			LEFT JOIN `%2$s`.`checklist` ON
				`checklist_2_product`.`checklist_id` = `checklist`.`checklist_id`
			LEFT JOIN `%2$s`.`checklist_variation` ON
				`checklist_2_product`.`checklist_variation_id` = `checklist_variation`.`checklist_variation_id`
			WHERE `checklist_2_product`.`product_id` = %3$d;
		',
			DB_PREFIX.'pos',
			DB_PREFIX.'checklist',
			$GLOBALS['core']->db->escape_string($product_id)
		))) {
			while($row = $result->fetch_object()) {
				$row->checklists = 1;
				for($i=0;$i<$row->checklists;$i++) {
					$GLOBALS['core']->db->query(sprintf('
						INSERT INTO `%1$s`.`client_checklist` SET 
							`checklist_id` = %2$d,
							`checklist_variation_id` = IF("%3$d" != "",%3$d,NULL),
							`client_id` = %4$d,
							`name` = "%5$s",
							`audit_required` = %6$d;
					',
						DB_PREFIX.'checklist',
						$row->checklist_id,
						$row->checklist_variation_id,
						$client_id,
						$GLOBALS['core']->db->escape_string($row->name),
						($row->checklist_variation_id == 2 ? '0' : $this->checklistAuditRequired($row->checklist_id))
					));
				}
			}
			$result->close();
		}
		return;
	}
	
	//Takes the action id and returns the commitment with the max score for the action
	public function getMaxCommitments($action_id) {
		$maxCommitments = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			`commitment_id`
			FROM `%1$s`.`commitment`
			WHERE `action_id` = %2$d
			AND `merits` = (
				SELECT MAX(`merits`)
				FROM `%1$s`.`commitment`
				WHERE `action_id` = %2$d
			);
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($action_id)
		))) {
				while($row = $result->fetch_object()) {
					$maxCommitments[] = $row->commitment_id;
				}		
			}
		
		return	$maxCommitments;
	}
	
	/**
	* 	Copy a client_checklist into a duplicate client_checklist
	*/
	public function duplicateClientChecklist($client_checklist_id, $set_complete = true, $metrics = true) {
		$tables = [
			'client_result',
			'client_metric',
			'additional_value',
			'client_checklist_score',
			'client_page_note',
			'client_commitment'
		];

		$new_client_checklist_id = null;
		$this->db->setDb(DB_PREFIX.'checklist');

		//Create a new client checklist
		$this->db->where('client_checklist_id', $client_checklist_id);
		$client_checklist = $this->db->getOne('client_checklist');
		unset($client_checklist['client_checklist_id']);

		$new_client_checklist_id = $this->db->insert('client_checklist',$client_checklist);

		//Copy all tables
		foreach($tables as $table) {
			$this->db->where('client_checklist_id', $client_checklist_id);
			$results = $this->db->get($table);
			$keys = $this->db->rawQueryOne('SHOW KEYS FROM ' . $table . ' WHERE Key_name = \'PRIMARY\'');

			foreach($results as $result) {
				//Unset the primary key
				if(isset($keys['Column_name'])) {
					unset($result[$keys['Column_name']]);
				}

				//Update the client_checklist_id
				$result['client_checklist_id'] = $new_client_checklist_id;
				$this->db->insert($table, $result);
			}
		}

		return $new_client_checklist_id;
	}
	
	//Pass the client_checklist_id and return all details from the client_checklist database
	private function getClientChecklistPermissions($client_checklist_id) {
		$client_checklist_permissions = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			*
			FROM `%1$s`.`client_checklist_permission`
			WHERE `client_checklist_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
				while($row = $result->fetch_object()) {
					$client_checklist_permissions[] = $row;
				}		
			}
			
		$result->close();
		
		return $client_checklist_permissions;
	}
	
	public function pubGetClientResults($client_checklist_id) {
		return $this->getAllClientResults($client_checklist_id);
	}
	
	private function getAllClientResults($client_checklist_id) {
		$client_results = array();
		$file = new fileDownload($this->db);
		
		if($result = $this->db->query(sprintf('
			SELECT
			client_result.*,
			answer.answer_type
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`answer` ON client_result.answer_id = answer.answer_id
			WHERE `client_checklist_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
				while($row = $result->fetch_object()) {
					//Additional answer information
					switch($row->answer_type) {
						case 'file-upload':
							if($row->arbitrary_value != '') {
								$fileInfo = $file->getFileInfo($row->arbitrary_value);
								$row = (object)array_merge((array)$row,(array)$fileInfo);
							}
							break;
					}

					$client_results[] = $row;
				}		
			}
			
		$result->close();
		
		return $client_results;
	}
	
	public function pubGetClientResultsWithAnswers($client_checklist_id) {
		return $this->getClientResultsWithAnswers($client_checklist_id);
	}	

	private function getClientResultsWithAnswers($client_checklist_id) {
		$client_results = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			`client_result`.*,
			`answer`.*,
			`answer_string`.*
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id`
			LEFT JOIN `%1$s`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
			WHERE `client_result`.`client_checklist_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
				while($row = $result->fetch_object()) {
					$client_results[] = $row;
				}		
			}
			
		$result->close();
		
		return $client_results;
	}
	
	private function getAllClientMetrics($client_checklist_id) {
		$client_metrics = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			*
			FROM `%1$s`.`client_metric`
			WHERE `client_checklist_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
				while($row = $result->fetch_object()) {
					$client_metrics[] = $row;
				}		
			}
			
		$result->close();
		
		return $client_metrics;
	}	

	private function getAllClientPageNotes($client_checklist_id) {
		$client_page_notes = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			*
			FROM `%1$s`.`client_page_note`
			WHERE `client_checklist_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
				while($row = $result->fetch_object()) {
					$client_page_notes[] = $row;
				}		
			}
			
		$result->close();
		
		return $client_page_notes;
	}	

	//Pass the client_checklist_id and return all details from the client_checklist database
	private function getClientChecklistScore($client_checklist_id) {
		$client_checklist_score = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			*
			FROM `%1$s`.`client_checklist_score`
			WHERE `client_checklist_id` = %2$d
			ORDER BY `timestamp` DESC
			LIMIT 1
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
				while($row = $result->fetch_object()) {
					$client_checklist_score = $row;
				}		
			}
		
		$result->close();
		
		return $client_checklist_score;
	}

	private function getAllClientCommitments($client_checklist_id) {
		$client_commitments = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			*
			FROM `%1$s`.`client_commitment`
			WHERE `client_checklist_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
				while($row = $result->fetch_object()) {
					$client_commitments[] = $row;
				}		
			}
			
		$result->close();
		
		return $client_commitments;
	}

	private function getAllOwner2Actions($client_checklist_id) {
		$owner_2_actions = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			*
			FROM `%1$s`.`owner_2_action`
			WHERE `client_checklist_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
				while($row = $result->fetch_object()) {
					$owner_2_actions[] = $row;
				}		
			}
			
		$result->close();
		
		return $owner_2_actions;
	}
	
	private function getAllOwner2Questions($client_checklist_id) {
		$owner_2_questionss = array();
		
		if($result = $this->db->query(sprintf('
			SELECT
			*
			FROM `%1$s`.`owner_2_question`
			WHERE `client_checklist_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		))) {
				while($row = $result->fetch_object()) {
					$owner_2_questions[] = $row;
				}		
			}
			
		$result->close();
		
		return $owner_2_questions;
	}

	//pass the complete client_checklist row in an object array and it will be inserted
	private function setClientChecklist($client_checklist) {
		$null_values = '';
		(!is_null($client_checklist->completed) ? $null_values .= ',`completed` = "%10$s"' : NULL);
		
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`client_checklist` SET
			`checklist_id` = %2$d,
			`checklist_variation_id` = %3$d,
			`client_id` = %4$d,
			`name` = "%5$s",
			`progress` = %6$d,
			`initial_score` = %7$f,
			`current_score` = %8$f,
			`created` = "%9$s",
			`audit_required` = %11$d'
			. $null_values
			,
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist->checklist_id),
			$this->db->escape_string($client_checklist->checklist_variation_id),
			$this->db->escape_string($client_checklist->client_id),
			$this->db->escape_string($client_checklist->name),
			$this->db->escape_string($client_checklist->progress),
			$this->db->escape_string($client_checklist->initial_score),
			$this->db->escape_string($client_checklist->current_score),
			$this->db->escape_string(date('Y-m-d H:i:s')),
			$this->db->escape_string((!is_null($client_checklist->completed) ? date('Y-m-d H:i:s') : NULL)),
			$this->db->escape_string($client_checklist->audit_required)
		));
				
		return $this->db->insert_id;
	}
	
		//pass the complete client_checklist row in an object array and it will be inserted
	private function setClientChecklistPermissions($new_client_checklist_id, $client_checklist_permissions) {
		foreach($client_checklist_permissions as $client_checklist_permission) {
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`client_checklist_permission` SET
				`client_checklist_id` = %2$d,
				`can_read_checklist` = %3$d,
				`can_read_report` = %4$d,
				`can_edit_report` = %5$d,
				`client_contact_id` = %6$d
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($new_client_checklist_id),
				$this->db->escape_string($client_checklist_permission->can_read_checklist),
				$this->db->escape_string($client_checklist_permission->can_read_report),
				$this->db->escape_string($client_checklist_permission->can_edit_report),
				$this->db->escape_string($client_checklist_permission->client_contact_id)
			));
		}
		
		return;
	}
	
	//pass the complete client_checklist row in an object array and it will be inserted
	private function setClientResults($new_client_checklist_id, $client_results) {
		foreach($client_results as $client_result) {
			$null_values = '';
			(!is_null($client_result->arbitrary_value) ? $null_values .= ',`arbitrary_value` = "%6$s"' : NULL);
			
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`client_result` SET
				`client_checklist_id` = %2$d,
				`question_id` = %3$d,
				`answer_id` = %4$d,
				`timestamp` = "%5$s"'
				. $null_values				
			 ,
				DB_PREFIX.'checklist',
				$this->db->escape_string($new_client_checklist_id),
				$this->db->escape_string($client_result->question_id),
				$this->db->escape_string($client_result->answer_id),
				$this->db->escape_string(date('Y-m-d H:i:s')),
				$this->db->escape_string((!is_null($client_result->arbitrary_value) ? $client_result->arbitrary_value : NULL))
			));
		}
		
		return;
	}

	//pass the complete client_checklist row in an object array and it will be inserted
	private function setClientMetrics($new_client_checklist_id, $client_metrics) {
		foreach($client_metrics as $client_metric) {
			$null_values = '';
			(!is_null($client_metric->value) ? $null_values .= ',`value` = "%6$s"' : NULL);
			
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`client_metric` SET
				`client_checklist_id` = %2$d,
				`metric_id` = %3$d,
				`metric_unit_type_id` = %4$d,
				`timestamp` = "%5$s",
				`months` = "%7$d"'
				. $null_values
			 ,
				DB_PREFIX.'checklist',
				$this->db->escape_string($new_client_checklist_id),
				$this->db->escape_string($client_metric->metric_id),
				$this->db->escape_string($client_metric->metric_unit_type_id),
				$this->db->escape_string(date('Y-m-d H:i:s')),
				$this->db->escape_string((!is_null($client_metric->value) ? $client_metric->value : NULL)),
				$this->db->escape_string($client_metric->months)
			));
		}
		
		return;
	}
	
	//pass the complete client_checklist row in an object array and it will be inserted
	private function setClientPageNotes($new_client_checklist_id, $client_page_notes) {
		foreach($client_page_notes as $client_page_note) {
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`client_page_note` SET
				`client_checklist_id` = %2$d,
				`page_id` = %3$d,
				`note` = "%4$s"
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($new_client_checklist_id),
				$this->db->escape_string($client_page_note->page_id),
				$this->db->escape_string($client_page_note->note)
			));
		}
		
		return;
	}
	
	//pass the complete client_checklist row in an object array and it will be inserted
	private function setClientCommitments($new_client_checklist_id, $client_commitments) {
		foreach($client_commitments as $client_commitment) {
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`client_commitment` SET
				`client_checklist_id` = %2$d,
				`action_id` = %3$d,
				`commitment_id` = %4$d,
				`timestamp` = "%5$s"
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($new_client_checklist_id),
				$this->db->escape_string($client_commitment->action_id),
				$this->db->escape_string($client_commitment->commitment_id),
				$this->db->escape_string(date('Y-m-d H:i:s'))
			));
		}
		
		return;
	}

	//pass the complete client_checklist row in an object array and it will be inserted
	private function setOwner2Actions($new_client_checklist_id, $owner_2_actions) {
		foreach($owner_2_actions as $owner_2_action) {
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`owner_2_action` SET
				`client_checklist_id` = %2$d,
				`owner_id` = %3$d,
				`due_date` = "%4$s",
				`timestamp` = "%5$s",
				`action_id` = %6$d,
				`assigned_by_client_contact_id` = %7$d
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($new_client_checklist_id),
				$this->db->escape_string($owner_2_action->owner_id),
				$this->db->escape_string($owner_2_action->due_date),
				$this->db->escape_string(date('Y-m-d H:i:s')),
				$this->db->escape_string($owner_2_action->action_id),
				$this->db->escape_string($owner_2_action->assigned_by_client_contact_id)
			));
		}
		
		return;
	}
	
	//pass the complete client_checklist row in an object array and it will be inserted
	private function setOwner2Question($new_client_checklist_id, $owner_2_questionss) {
		foreach($owner_2_questionss as $owner_2_question) {
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`owner_2_question` SET
				`client_checklist_id` = %2$d,
				`owner_id` = %3$d,
				`due_date` = "%4$s",
				`timestamp` = "%5$s",
				`question_id` = %6$d,
				`assigned_by_client_contact_id` = %7$d
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($new_client_checklist_id),
				$this->db->escape_string($owner_2_question->owner_id),
				$this->db->escape_string($owner_2_question->due_date),
				$this->db->escape_string(date('Y-m-d H:i:s')),
				$this->db->escape_string($owner_2_question->question_id),
				$this->db->escape_string($owner_2_question->assigned_by_client_contact_id)
			));
		}
		
		return;
	}
	
	public function exportQuestionAnswers($client_checklist_id) {
		
		//Get the checklist data
		$clientResults = $this->getClientResultsWithAnswers($client_checklist_id);

	 	
	 	//Set the header row for the CSV document
		$header = array('Question','Answer');
		$csv[0] = '"'.implode('","',$header).'"';
		$i = 1;
		
		foreach($clientResults as $result) {
			
			switch($result->answer_type) {
			
				case 'checkbox':	$result->answer = $result->string;
									break;
									
				default:			$result->answer = $result->arbitrary_value;
									break;
			}
		
			//Get the question
			$question = $this->getQuestion($result->question_id);

			//Check the answer details to see if we need to modify the question/answer string
			if(!is_null($result->string) AND $result->arbitrary_value != "") {
				$question->question = $question->question . ": " . $result->string;
			}

			$csv[$i] = sprintf(
			'"%s","%s"',
			$question->question,
			$result->answer
			);
			$i++;
		}
		
		//Test to see if there are no actions
		if(count($clientResults) == 0) {
			$csv[1] = 'No data to export';
		}
	
		//Create the CSV file with the above information and send it to the requesting page for download
		header("Content-type: text/plain");
		$file_name = "client_results_export_" . $client_checklist_id . ".csv";
		header('Content-Disposition: attachment; filename=' . $file_name);
		print implode("\r\n",$csv);
		die();
	}
	
	//Get the individual page setions for the current clientChecklist
	public function getChecklistPageSections($clientChecklistId) {
		$sections = array();
		if ($result = $this->db->query(sprintf('
			SELECT 
				`page_section_id`,
				`checklist_id`,
				`sequence`,
				`title`
			FROM `%1$s`.`page_section`
			WHERE `checklist_id` = %2$d
			ORDER BY `sequence`
		',
			DB_PREFIX.'checklist',
			$clientChecklistId
		))) {
			while ($row = $result->fetch_object()) {
				$sections[] = $row;
			}
			$result->close();
		}
		return $sections;
	}
	
	//Take a client_checklist_id, see if there are an client_sites associated with it and return if true or false
	public function isClientChecklistMultiSite($client_checklist_id) {
		$multi_site = false;
		
		if ($result = $this->db->query(sprintf('
			SELECT
			COUNT(*) AS `count`
			FROM `%1$s`.`client_site`
			WHERE `client_site`.`client_checklist_id` = "%2$s"
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			while ($row = $result->fetch_object()) {
				if($row->count > 0) {
					$multi_site = true;
				}
			}
			$result->close();
		}
		return $multi_site;
	}
	
	//Take a client_checklist_id, see if there are an client_sites associated with it and return if true or false
	public function getMultiSiteChildChecklistDetails($client_checklist_id) {
		$clientSite = array();
		
		if ($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_site`
			WHERE `client_site`.`child_client_checklist_id` = "%2$s"
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			while ($row = $result->fetch_object()) {
				$clientSite[] = $row;
			}
			$result->close();
		}
		return $clientSite;
	}
	
	//Get the client_checklist_id for the given client_site_id
	public function getClientSite2ClientChecklistId($client_site_id) {
		$client_checklist_id = null;
		
		if ($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_site`
			WHERE `client_site`.`client_site_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$client_site_id
		))) {
			while ($row = $result->fetch_object()) {
				$client_checklist_id = $row->child_client_checklist_id;
			}
			$result->close();
		}
		return $client_checklist_id;
	}
	
	//Set the client_checklist_id for the given client_site_id
	public function setClientSite2ClientChecklistId($client_site_id, $child_client_checklist_id) {
		
		$this->db->query(sprintf('
			UPDATE `%1$s`.`client_site` SET
			`child_client_checklist_id` = %3$d
			WHERE `client_site_id` = %2$d
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_site_id),
			$this->db->escape_string($child_client_checklist_id)
		));

		return $this->db->insert_id;
	}
	
	//Takes the client_checklist_id 
	public function createMultiSiteChildrenClientChecklist($client_checklist_id) {
		
		//Get all of the details from the parent clientChecklist
		$clientSites = $this->getClientChecklistSites($client_checklist_id);
		$clientChecklistResults = $this->getAllClientChecklistResults($client_checklist_id);
		$clientChecklist = $this->getClientChecklist($client_checklist_id);
		$clientChecklistIds = array();

		foreach($clientSites as $clientSite) {
		
			//Get all of the clientSiteResults
			$clientSiteResults = $this->getAllClientSiteResults($clientSite->client_site_id);
			
			//Create the clientChecklist if there isn't already one available
			$child_client_checklist_id = $this->getClientSite2ClientChecklistId($clientSite->client_site_id);
			if(is_null($child_client_checklist_id)) {
				$child_client_checklist_id = $this->autoIssueChecklist($clientChecklist->checklist_id, $clientChecklist->client_id);
				$this->setClientSite2ClientChecklistId($clientSite->client_site_id, $child_client_checklist_id);
			}
			$clientChecklistIds[] = $child_client_checklist_id;
			
			//Create the client_checklist_2_parent relationship
			$this->insertParent2ChildChecklist($client_checklist_id, $child_client_checklist_id);
			
			//Make sure that the child_client_checklist has no client_results
			$this->deleteAllClientResults($child_client_checklist_id);
			
			//Now loop through all the parent client_results and insert the same into the child result
			foreach($clientChecklistResults as $result) {
				$this->storeClientResult($child_client_checklist_id, $result->question_id, $result->answer_id, $result->arbitrary_value);
			}
			
			//Now loop through the client_site_results and add this data to the client_result
			foreach($clientSiteResults as $result) {
				$this->storeClientResult($child_client_checklist_id, $result->question_id, $result->answer_id, $result->arbitrary_value);
			}
			
			//Now mark the client checklist as completed
			$this->updateChecklistProgress($child_client_checklist_id, '100', true);	
		}
		
		return $clientChecklistIds;
	}
	
	//Delete all client result for the given client_checklist
	public function deleteAllClientResults($client_checklist_id) {
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`client_result`
			WHERE `client_checklist_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		));
		return;
	}
	
	//Return an array of generic colours and data for certification levels
	public function generic_certification_levels() {
		$levels = array();
		
		$levels[] = (object) array('level_id' => '1','name' => 'Very Poor','target' => '0','color' => 'f79892');
		$levels[] = (object) array('level_id' => '2','name' => 'Poor','target' => '20','color' => 'f9c090');
		$levels[] = (object) array('level_id' => '3','name' => 'Average','target' => '40','color' => 'fef87f');
		$levels[] = (object) array('level_id' => '4','name' => 'Good','target' => '60','color' => '7fceed');
		$levels[] = (object) array('level_id' => '5','name' => 'Very Good','target' => '80','color' => '97c89e');
		
		return $levels;
	}

	//Return an of resource types
	public function get_resource_types() {
		$resource_types = array();
		
		if ($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`resource_type`
		',
			DB_PREFIX.'checklist'
		))) {
			while ($row = $result->fetch_object()) {
				$resource_types[] = $row;
			}
			$result->close();
		}
		
		return $resource_types;
	}
	
	//Get the indivdual pages for each page section for the current clientChecklist
	public function getChecklistPageSectionPages($clientChecklistId) {
		$pages = array();
		if ($result = $this->db->query(sprintf('
			SELECT 
				`page_section_2_page_id`,
				`page_section_2_page`.`page_section_id`,
				`page_section_2_page`.`page_id`,
				`page_section_2_page`.`sequence`,
				`page_section`.`title` AS section_title,
				`page`.`title` AS page_title
			FROM `%1$s`.`page_section_2_page`
				INNER JOIN `%1$s`.`page_section` ON `page_section_2_page`.`page_section_id` = `page_section`.`page_section_id`
				INNER JOIN `%1$s`.`page` ON `page_section_2_page`.`page_id` = `page`.`page_id`
			WHERE `page_section`.`checklist_id` = %2$d
			ORDER BY `page_section`.`sequence`, `page`.`sequence`
		',
			DB_PREFIX.'checklist',
			$clientChecklistId
		))) {
			while ($row = $result->fetch_object()) {
				//$row->page_title = preg_replace('/^'.preg_quote($row->section_title).'\s?-?\s?(.*)$/', '\\1', $row->page_title);
				if ($row->page_title == "") { $row->page_title = $row->section_title; }
				$pages[] = $row;
			}
			$result->close();
		}
		return $pages;		
	}
	
	//Take the checklist_id and check to see if the the report should be emailed to anyone on completion
	public function getEmailAnswerReportRecipients($checklist_id) {
		$recipients = null;
		
		if ($result = $this->db->query(sprintf('
			SELECT
			`checklist`.`email_report_address`
			FROM `%1$s`.`checklist`
			WHERE `checklist`.`checklist_id` = %2$d
			AND `checklist`.`email_report` = "1"
		',
			DB_PREFIX.'checklist',
			$checklist_id
		))) {
			while ($row = $result->fetch_object()) {
				$recipients = $row->email_report_address;
			}
			$result->close();
		}
		return $recipients;
	}
	
	//Pivot Table SQL Queries
	public function getChecklistResultsPivotTable($checklist_id, $from = null, $to = null, $conditional_client_checklist_filter = null) {
		//Override the default memory limit
		ini_set('memory_limit', '-1');
		ini_set('max_execution_time', 0);
		
		$checklistResults = array();

		if($result = $this->db->query(sprintf('
			SELECT
			`client`.`company_name`,
			`client_checklist`.`client_checklist_id`,
			IF(`client_checklist`.`completed` IS NOT NULL, \'YES\', \'NO\') as `completed`,
			`cc`.`firstname`,
			`cc`.`lastname`,
			`cc`.`email`,
			`checklist`.`name`,
			IF(`answer_string`.`string` IS NOT NULL AND `client_result`.`arbitrary_value` !=\'\', CONCAT(`question`.`question`, \': \', `answer_string`.`string`), `question`.`question`) AS `question`,
            IF(`answer_string`.`string` IS NULL, `client_result`.`arbitrary_value`, IF(`client_result`.`arbitrary_value` IS NULL OR `client_result`.`arbitrary_value` = \'\', `answer_string`.`string`, `client_result`.`arbitrary_value`)) as `answer`
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`question` ON `client_result`.`question_id` = `question`.`question_id`
			LEFT JOIN `%1$s`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id`
			LEFT JOIN `%1$s`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
			LEFT JOIN `%1$s`.`client_checklist` ON `client_result`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
			LEFT JOIN `%1$s`.`checklist` ON `client_checklist`.`checklist_id` = `checklist`.`checklist_id`
			LEFT JOIN `%1$s`.`page` ON `page`.`page_id` = `question`.`page_id`
			LEFT JOIN `%2$s`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
			LEFT JOIN (
				SELECT *
				FROM `%2$s`.`client_contact`
				GROUP BY `client_contact`.`client_id`
			) AS `cc` ON `client`.`client_id` = `cc`.`client_id`

			WHERE `client_checklist`.`checklist_id` = %3$d
			AND `question`.`question` IS NOT NULL
			AND `client`.`company_name` IS NOT NULL'
			. (!is_null($from) ? ' AND `client_checklist`.`created` >= \''  . date("Y-m-d H:i:s", strtotime($from)) . '\'' : '')
			. (!is_null($to) ? ' AND `client_checklist`.`created` <= \''  . date("Y-m-d H:i:s", strtotime($to)) . '\'' : '' )
			. (!is_null($conditional_client_checklist_filter) ? ' ' . $conditional_client_checklist_filter : '') 
			. ' ORDER BY `client_checklist`.`client_checklist_id`, `page`.`sequence`, `question`.`sequence`, `answer`.`sequence`;
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$checklistResults[] = $row;
			}
			$result->close();
		}

		return($checklistResults);
	}

	//Checklist Query, either with a given checklist_id or an array of id's
	public function getChecklistResultsWithClientInformation($checklist_id, $from = null, $to = null, $conditional_client_checklist_filter = null) {
		
		$checklistResults = array();

		if($result = $this->db->query(sprintf('
			SELECT
			`client`.`client_id` AS `Client ID`,
			`client`.`company_name` AS `Company Name`,
			`client_checklist`.`client_checklist_id` AS `Client Checklist ID`,
			`checklist`.`name` AS `Checklist Name`,
			IF(`client_checklist`.`completed` IS NOT NULL, \'YES\', \'NO\') as `Completed`,
            `client_checklist`.`created` AS `Date Started`,
            `client_checklist`.`completed` AS `Date Completed`,
            IF(`client_checklist`.`completed` IS NOT NULL, \'Completed\', \'Incomplete\') as `Status`,
            IF(`client_checklist`.`current_score` IS NOT NULL, CONCAT(ROUND(`client_checklist`.`current_score` * 100),\'%%\'),\'0%%\') AS `Score`,
			`cc`.`firstname`,
			`cc`.`lastname`,
			`cc`.`email`
			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%1$s`.`checklist` ON `client_checklist`.`checklist_id` = `checklist`.`checklist_id`
			LEFT JOIN `%2$s`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
			LEFT JOIN (
				SELECT *
				FROM `%2$s`.`client_contact`
				GROUP BY `client_contact`.`client_id`
			) AS `cc` ON `client`.`client_id` = `cc`.`client_id`

			WHERE `client`.`company_name` IS NOT NULL
			' . (!is_array($checklist_id) != 0 ? 'AND `client_checklist`.`checklist_id` = %3$d' : 'AND `client_checklist`.`checklist_id` IN (' . implode(',',$checklist_id) . ')')
			. (!is_null($from) ? ' AND `client_checklist`.`created` >= \''  . date("Y-m-d H:i:s", strtotime($from)) . '\'' : '')
			. (!is_null($to) ? ' AND `client_checklist`.`created` <= \''  . date("Y-m-d H:i:s", strtotime($to)) . '\'' : '' )
			. (!is_null($conditional_client_checklist_filter) ? ' ' . $conditional_client_checklist_filter : '')  
		,
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$checklistResults[] = $row;
			}
			$result->close();
		}
		return($checklistResults);

	}

	public function updateClientChecklistScoresByChecklistId($checklist_id) {
		$clientChecklists = array();

		if ($result = $this->db->query(sprintf('
			SELECT
			`client_checklist`.`client_checklist_id`
			FROM `%1$s`.`client_checklist`
			WHERE `client_checklist`.`checklist_id` = %2$d
			AND `client_checklist`.`completed` IS NOT NULL
		',
			DB_PREFIX.'checklist',
			$checklist_id
		))) {
			while ($row = $result->fetch_object()) {
				$clientChecklists[] = $row;
			}
			$result->close();
		}

		if(count($clientChecklists > 0)) {
			foreach($clientChecklists as $clientChecklist) {
				$checklistReport = $this->getReport($clientChecklist->client_checklist_id);
			}
		}

		return;
	}

	//Get clientChecklists
	//Filter by client_id, client_checklist_id, client_type_id
	public function getClientChecklists($client_id = null, $client_checklist_id = null, $client_type_id = null, $checklist_id = null, $date_range_start = null, $date_range_finish = null, $getArchived = true) {
		$clientChecklists = array();
		$filter = '';
		$filter .= !is_null($client_id) ? ' AND `client_checklist`.`client_id` = ' . $client_id : null;
		$filter .= !is_null($client_checklist_id) ? ' AND `client_checklist`.`client_checklist_id` IN(' . $client_checklist_id . ')' : null;
		$filter .= !is_null($client_type_id) ? ' AND `client`.`client_type_id` IN(' . $client_type_id . ')' : null;
		$filter .= !is_null($checklist_id) ? ' AND `client_checklist`.`checklist_id` IN(' . $checklist_id . ')' : null;
		$filter .= !is_null($date_range_start) ? ' AND `client_checklist`.`date_range_start` = "' . $date_range_start . '"' : null;
		$filter .= !is_null($date_range_finish) ? ' AND `client_checklist`.`date_range_finish` = "' . $date_range_finish . '"' : null;
		$filter .= !$getArchived ? ' AND `client_checklist`.`status` != 4' : null;

		$query = sprintf('
			SELECT
			`client`.`company_name`,
			`client_checklist`.*
			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%2$s`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
			WHERE 1 %3$s;
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$filter
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				unset($row->password);
				$clientChecklists[] = $row;
			}
			$result->close();
		}
		
		return $clientChecklists;
	}

	public function getStructuredClientResults($client_checklist_id) {
		$checklist = new stdClass;
		$checklist->page = array();

		$pages = $this->getChecklistPages($client_checklist_id);
		$questions = $this->getClientChecklistQuestions($client_checklist_id);
		$answers = $this->getClientChecklistAnswers($client_checklist_id);
		$results = $this->getClientResults($client_checklist_id);

		foreach($pages as $page) {
			$page->question = array();
			foreach($questions as $question) {
				if($question->page_id === $page->page_id) {
					$page->question[$question->question_id] = $question;
					$page->question[$question->question_id]->answer = array();
					foreach($answers as $answer) {
						if($answer->question_id === $question->question_id) {
							foreach($results as $result) {
								if($result->question_id === $answer->question_id && $result->answer_id === $answer->answer_id) {
									$answer->value = $result->arbitrary_value;
									$page->question[$question->question_id]->answer[$answer->answer_id] = $answer;
								}
							}
						}
					}
				} 
			}
			$checklist->page[$page->page_id] = $page;
		}

		return $checklist;
	}

	public function setNewClientChecklist($data) {
		$checklist = $this->getChecklistById($data['checklist_id']);
		if(!isset($data['name'])) {
			$data['name'] = $checklist->name;
		}

		$query = $this->dbModel->prepare_query('checklist', 'client_checklist', 'INSERT INTO', $data);
		$this->db->query($query);

		return $this->db->insert_id;
	}

	public function updateClientChecklist($data, $where) {
		$query = $this->dbModel->prepare_query('checklist', 'client_checklist', 'UPDATE', $data, $where);
		$this->db->query($query);
		
		return $this->db->affected_rows;
	}

	public function getAllChecklists($checklist_id = null, $client_checklist_id = null) {
		$checklists = array();
		$filter = '';
		$filter .= !is_null($checklist_id) ? ' AND `checklist`.`checklist_id` IN(' . $checklist_id . ')' : null;

		$count_filter = '';
		$count_filter .= !is_null($client_checklist_id) ? ' AND `count`.`client_checklist_id` IN(' . $client_checklist_id . ')' : null;

		$completed_filter = '';
		$completed_filter .= !is_null($client_checklist_id) ? ' AND `completed`.`client_checklist_id` IN(' . $client_checklist_id . ')' : null;

		$incomplete_filter = '';
		$incomplete_filter .= !is_null($client_checklist_id) ? ' AND `incomplete`.`client_checklist_id` IN(' . $client_checklist_id . ')' : null;

		$average_filter = '';
		$average_filter .= !is_null($checklist_id) ? ' AND `average`.`checklist_id` IN(' . $checklist_id . ')' : null;

		$filtered_average_filter = '';
		$filtered_average_filter .= !is_null($client_checklist_id) ? ' AND `filtered_average`.`client_checklist_id` IN(' . $client_checklist_id . ')' : null;

		$query = sprintf('
			SELECT
			`checklist`.*,
			@count := (SELECT COUNT(*) FROM `%1$s`.`client_checklist` `count` WHERE `checklist`.`checklist_id` = `count`.`checklist_id`%3$s) AS `count`,
			@completed := (SELECT COUNT(*) FROM `%1$s`.`client_checklist` `completed` WHERE `checklist`.`checklist_id` = `completed`.`checklist_id` AND `completed`.`completed` IS NOT NULL%4$s) AS `completed`,
			@incomplete := (SELECT COUNT(*) FROM `%1$s`.`client_checklist` `incomplete` WHERE `checklist`.`checklist_id` = `incomplete`.`checklist_id` AND `incomplete`.`completed` IS NULL%5$s) AS `incomplete`,
			(SELECT AVG(`average`.`current_score`) FROM `%1$s`.`client_checklist` `average` WHERE `checklist`.`checklist_id` = `average`.`checklist_id` AND `average`.`completed` IS NOT NULL%6$s) AS `average`,
			(SELECT ROUND(AVG(`average`.`current_score`) * 100) FROM `%1$s`.`client_checklist` `average` WHERE `checklist`.`checklist_id` = `average`.`checklist_id` AND `average`.`completed` IS NOT NULL%6$s) AS `average_score_whole`,
			(SELECT AVG(`filtered_average`.`current_score`) FROM `%1$s`.`client_checklist` `filtered_average` WHERE `checklist`.`checklist_id` = `filtered_average`.`checklist_id` AND `filtered_average`.`completed` IS NOT NULL%7$s) AS `filtered_average`,
			(SELECT ROUND(AVG(`filtered_average`.`current_score`) * 100) FROM `%1$s`.`client_checklist` `filtered_average` WHERE `checklist`.`checklist_id` = `filtered_average`.`checklist_id` AND `filtered_average`.`completed` IS NOT NULL%7$s) AS `filtered_average_score_whole`,
			(@completed/@count) AS completion_rate,
			round((@completed/@count)*100) AS completion_rate_whole
			FROM `%1$s`.`checklist`
			WHERE 1 %2$s
			GROUP BY `checklist`.`checklist_id`;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($filter),
			$this->db->escape_string($count_filter),
			$this->db->escape_string($completed_filter),
			$this->db->escape_string($incomplete_filter),
			$this->db->escape_string($average_filter),
			$this->db->escape_string($filtered_average_filter)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$checklists[] = $row;
			}
			$result->close();
		}
		return $checklists;
	}

	//Get Accessible Client Checklists
	//Returns and array of client_checklist_ids that the current contact can access
	public function getAccessibleClientChecklists($contact, $dashboard = true) {
		$this->clientChecklist = new clientChecklist($this->db);
		
		$clientChecklists = $this->getClientChecklistsByClient($contact->client_id, false);

		if(filter_var($dashboard, FILTER_VALIDATE_BOOLEAN) && !is_null($contact->dashboard_group_id)) {
			//Get Any accessible client checklists from the result filter
			$clientChecklists = array_merge($clientChecklists, resultFilter::accessible_client_checklists($this->db, $contact));
		}

		return $clientChecklists;
	}

	private function getClientChecklistsByClient($client_id, $getArchived = true) {
		$clientChecklists = array();

		$query = sprintf('
			SELECT
			`client_checklist`.`client_checklist_id`
			FROM `%1$s`.`client_checklist`
			WHERE `client_checklist`.`client_id` = %2$d
			%3$s;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_id),
			$getArchived ? "" : " AND `client_checklist`.`status` != 4"
		);

			if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clientChecklists[] = $row->client_checklist_id;
			}
			$result->close();
		}

		return $clientChecklists;
	}

	//Expects a string of comma separated identifiers
	public function getChecklistByChecklistId($checklistIdentifiers) {
		$checklists = NULL;
		
		$query = sprintf('
			SELECT *
			FROM `%1$s`.`checklist`
			WHERE `checklist`.`checklist_id` IN(%2$s)
			ORDER BY `checklist`.`name`;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($checklistIdentifiers)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$checklists[] = $row;
			}
			$result->close();
		}
		return $checklists;
	}

	public function deleteClientChecklists($client_checklist_ids) {
		$query = sprintf('
				DELETE FROM `%1$s`.`client_checklist`
				WHERE `client_checklist_id` IN (%2$s);
				DELETE FROM `%1$s`.`client_result`
				WHERE `client_checklist_id` IN (%2$s);
				DELETE FROM `%1$s`.`additional_value`
				WHERE `client_checklist_id` IN (%2$s);
				DELETE FROM `%1$s`.`client_commitment`
				WHERE `client_checklist_id` IN (%2$s);
				DELETE FROM `%1$s`.`client_checklist_permission`
				WHERE `client_checklist_id` IN (%2$s);
				OPTIMIZE TABLE
					`%1$s`.`client_checklist`,
					`%1$s`.`client_result`,
					`%1$s`.`client_commitment`;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($client_checklist_ids)
			);

		$result = $this->db->multi_query($query);

		return $result;
	}

	public function archiveClientChecklists($client_checklist_ids) {
		$query = sprintf('
				UPDATE `%1$s`.`client_checklist`
				SET `status` = 4
				WHERE `client_checklist_id` IN (%2$s);
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($client_checklist_ids)
			);

		$result = $this->db->multi_query($query);

		return $result;
	}

	public function reopenClientChecklists($client_checklist_ids) {
		$query = sprintf('
			UPDATE `%1$s`.`client_checklist`
			SET `completed` = NULL
			WHERE `client_checklist_id` IN (%2$s);
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_ids)
		);

		$result = $this->db->multi_query($query);

		return $result;	
	}

	//Submit the given client checklists
	public function submitClientChecklists($client_checklist_ids) {
		$clientChecklists = explode(',',$client_checklist_ids);
		foreach($clientChecklists as $client_checklist_id) {
			$clientChecklistFunction = new clientChecklistFunction($this->db, $client_checklist_id);

			//Delete any existing client checklist additional values and process them again
			$this->deleteClientChecklistAdditionalValues($client_checklist_id);
			$clientChecklistFunction->processClientChecklistFunctions();

			//Submit the client checklist
			$this->updateChecklistProgress($client_checklist_id, 100, true);

			//Process any followup SQL
			$clientChecklistFunction->processClientChecklistFollowupSql();
		}

		$result = count($clientChecklists);
		return $result;	
	}

	public function setClientChecklistDateFormats($clientChecklist) {
		$clientChecklist->last_active = !isset($clientChecklist->last_active_pretty) ? $this->getclientChecklistLastActivity($clientChecklist->client_checklist_id) : $clientChecklist->last_active;

		//Last Active
		$clientChecklist->last_active_pretty 			= !is_null($clientChecklist->last_active) ? date_format(date_create($clientChecklist->last_active), "F j, Y, g:i a") : null;
		
		//Date Range Start and Finish
		$clientChecklist->date_range_start_pretty		= !is_null($clientChecklist->date_range_start) ? date_format(date_create($clientChecklist->date_range_start), "Y-m-d") : null;
		$clientChecklist->date_range_finish_pretty 		= !is_null($clientChecklist->date_range_finish) ? date_format(date_create($clientChecklist->date_range_finish), "Y-m-d") : null;
		$clientChecklist->date_range_start_year 		= !is_null($clientChecklist->date_range_start) ? date_format(date_create($clientChecklist->date_range_start), "Y") : null;
		$clientChecklist->date_range_start_month		= !is_null($clientChecklist->date_range_start) ? date_format(date_create($clientChecklist->date_range_start), "F") : null;
		$clientChecklist->date_range_finish_year 		= !is_null($clientChecklist->date_range_finish) ? date_format(date_create($clientChecklist->date_range_finish), "Y") : null;
		$clientChecklist->date_range_finish_month		= !is_null($clientChecklist->date_range_finish) ? date_format(date_create($clientChecklist->date_range_finish), "F") : null;
		
		//Previous Month
		$clientChecklist->previous_month_month			= !is_null($clientChecklist->date_range_start) ? date("M", strtotime($clientChecklist->date_range_start . "- 1 MONTH")) : null;
		$clientChecklist->previous_month_year			= !is_null($clientChecklist->date_range_start) ? date("Y", strtotime($clientChecklist->date_range_start . "- 1 MONTH")) : null;
		
		//Previous Year
		$clientChecklist->previous_year_month			= !is_null($clientChecklist->date_range_start) ? date("M", strtotime($clientChecklist->date_range_start . "- 1 YEAR")) : null;
		$clientChecklist->previous_year_year			= !is_null($clientChecklist->date_range_start) ? date("Y", strtotime($clientChecklist->date_range_start . "- 1 YEAR")) : null;
		
		//Current Month
		$clientChecklist->current_month_month			= !is_null($clientChecklist->date_range_start) ? date("M", strtotime($clientChecklist->date_range_start)) : null;
		$clientChecklist->current_month_year			= !is_null($clientChecklist->date_range_start) ? date("Y", strtotime($clientChecklist->date_range_start)) : null;
		
		//Current Financial Year AU
		$clientChecklist->current_fy_au_start_month		= !is_null($clientChecklist->date_range_start) ? date("M", strtotime('July')) : null;
		$clientChecklist->current_fy_au_start_year		= !is_null($clientChecklist->date_range_start) ? date("Y", date("n", strtotime($clientChecklist->date_range_start)) < 7 ? strtotime($clientChecklist->date_range_start . "- 1 YEAR") : strtotime($clientChecklist->date_range_start)) : null;

		//Filtering Data
		$clientChecklist->date_range_start_formatted = new stdClass;
		$clientChecklist->date_range_start_formatted->year = !is_null($clientChecklist->date_range_start) ? date_format(date_create($clientChecklist->date_range_start), "Y") : null;
		$clientChecklist->date_range_start_formatted->month = !is_null($clientChecklist->date_range_start) ? date_format(date_create($clientChecklist->date_range_start), "F") : null;
		$clientChecklist->date_range_start_formatted->month_year = !is_null($clientChecklist->date_range_start) ? date_format(date_create($clientChecklist->date_range_start), "F Y") : null;
		$clientChecklist->date_range_start_formatted->order = !is_null($clientChecklist->date_range_start) ? $clientChecklist->date_range_start : null;

		$clientChecklist->date_range_finish_formatted = new stdClass;
		$clientChecklist->date_range_finish_formatted->year = !is_null($clientChecklist->date_range_finish) ? date_format(date_create($clientChecklist->date_range_finish), "Y") : null;
		$clientChecklist->date_range_finish_formatted->month = !is_null($clientChecklist->date_range_finish) ? date_format(date_create($clientChecklist->date_range_finish), "F") : null;
		$clientChecklist->date_range_finish_formatted->month_year = !is_null($clientChecklist->date_range_finish) ? date_format(date_create($clientChecklist->date_range_finish), "F Y") : null;
		$clientChecklist->date_range_finish_formatted->order = !is_null($clientChecklist->date_range_finish) ? $clientChecklist->date_range_finish : null;

		return $clientChecklist;
	}

	public function getClientChecklistMetricResults($client_checklist_id) {
		$clientChecklistMetricResults = array();
		
		$query = sprintf('
			SELECT
			`metric_group`.`name` AS `metric_group_name`,
			`metric`.`metric`,
			`client_metric`.*,
			`metric_unit_type`.`metric_unit_type`
			FROM `%1$s`.`client_metric`
			LEFT JOIN `%1$s`.`metric_unit_type` ON `client_metric`.`metric_unit_type_id` = `metric_unit_type`.`metric_unit_type_id`
			LEFT JOIN `%1$s`.`metric` ON `client_metric`.`metric_id` = `metric`.`metric_id`
			LEFT JOIN `%1$s`.`metric_group` ON `metric`.`metric_group_id` = `metric_group`.`metric_group_id`
			LEFT JOIN `%1$s`.`page` ON `metric_group`.`page_id` = `page`.`page_id`
			WHERE `client_metric`.`client_checklist_id` = %2$d
			ORDER BY `page`.`sequence`, `metric_group`.`sequence`, `metric`.`sequence`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clientChecklistMetricResults[] = $row;
			}
			$result->close();
		}
		return $clientChecklistMetricResults;
	}

	public function getClient2Metric($client_checklist_id) {
		$client2Metric = array();
		
		$query = sprintf('
			SELECT
			client_2_metric.*
			FROM %1$s.client_2_metric
			WHERE client_2_metric.client_id = (SELECT client_id FROM %1$s.client_checklist WHERE client_checklist_id = %2$d)
			GROUP BY client_2_metric.metric_id
			ORDER BY client_2_metric.metric_id
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$client2Metric[] = $row;
			}
			$result->close();
		}
		return $client2Metric;	
	}

	public function updateClient2Metric() {
		$result = '';

		if(isset($_POST['status'])) {

			$query = sprintf('
				DELETE FROM `%1$s`.`client_2_metric`
				WHERE `client_id` = %2$d
				AND `metric_id` = %3$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string(isset($_POST['client_id']) ? $_POST['client_id'] : null),
				$this->db->escape_string(isset($_POST['metric_id']) ? $_POST['metric_id'] : null)
			);

			//Delete first
			$this->db->query($query);

			$result .= "Client Id: " . $_POST['client_id'] . ", Metrid Id: " . $_POST['metric_id'];
			$result .= ", " . $_POST['status'] . ", Delete: " . $this->db->affected_rows;

			//If insert is set
			if(isset($_POST['status']) && $_POST['status'] === 'insert') {
				$query = sprintf('
					INSERT INTO `%1$s`.`client_2_metric` SET
					`client_id` = %2$d,
					`metric_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string(isset($_POST['client_id']) ? $_POST['client_id'] : null),
					$this->db->escape_string(isset($_POST['metric_id']) ? $_POST['metric_id'] : null)
				);

				$this->db->query($query);
				$result .= ", Insert: " . $this->db->insert_id;
			}
		}

		echo $result;

		die();
	}

	public function getClientResultsWithAdditionalValuesQuery($client_checklist_id) {

		$query = sprintf('
			SELECT *
			FROM
			(SELECT
			client_results.*
			FROM
			(SELECT
			client.company_name,
			client.client_id,
			checklist.name,
			client_checklist.client_checklist_id,
			client_checklist.date_range_finish,
			"Answer" as type,
	        IFNULL(page_section.sequence,0) AS page_section_sequence,
	        page.sequence AS page_sequence,
	        question.sequence AS question_sequence,
	        answer.sequence AS answer_sequence,
	        CONCAT(IFNULL(page_section.sequence,0), ".", page.sequence, ".", question.sequence, ".", answer.sequence) AS `order`,
			CONCAT(page.sequence, ".", question.sequence, ".", answer.sequence) AS `page_order`,
	        CASE 
				WHEN page_section.title IS NOT NULL THEN concat(page_section.title, " - ", page.title) 
	            ELSE page.title 
			END AS section, 
	        CASE
				WHEN answer.answer_type IN("float", "int") AND answer_string.string IS NOT NULL THEN CONCAT(question.question, " - " , answer_string.string)
	            ELSE question.question
	        END AS question,
	        question.question_id, 
	        CASE 
				WHEN answer.answer_type IN("checkbox-other") THEN CONCAT(answer_string.string, " - ", client_result.arbitrary_value)
	            WHEN answer.answer_type IN("file-upload") THEN IF(client_result.arbitrary_value != "",CONCAT("https://www.greenbizcheck.com/download/?hash=", client_result.arbitrary_value),"No File")
				WHEN answer_string.string IS NOT NULL AND client_result.arbitrary_value != "" THEN CONCAT(answer_string.string, " - " , client_result.arbitrary_value)
				WHEN answer_string.string IS NOT NULL THEN answer_string.string
				ELSE IFNULL(client_result.arbitrary_value,answer_string.string) 
	        END as answer,
	        CASE
				WHEN file_upload.name IS NOT NULL THEN file_upload.name COLLATE utf8_unicode_ci
                ELSE client_result.arbitrary_value
			END AS answer_label,
	        CASE
				WHEN answer.answer_type IN("file-upload") AND client_result.arbitrary_value != "" THEN "url"
	            ELSE "text"
	        END AS rendering,
			answer.answer_id,
			client_result.index AS `group`,
			client_result.timestamp
			FROM %1$s.client_result
			LEFT JOIN %1$s.answer ON client_result.answer_id = answer.answer_id
			LEFT JOIN %1$s.answer_string ON answer.answer_string_id = answer_string.answer_string_id
			LEFT JOIN %1$s.question ON answer.question_id = question.question_id
			LEFT JOIN %1$s.page ON question.page_id = page.page_id
			LEFT JOIN %1$s.page_section_2_page ON question.page_id = page_section_2_page.page_id
			LEFT JOIN %1$s.page_section ON page_section_2_page.page_section_id = page_section.page_section_id
			LEFT JOIN %1$s.client_checklist ON client_result.client_checklist_id = client_checklist.client_checklist_id
			LEFT JOIN %2$s.client ON client_checklist.client_id = client.client_id
			LEFT JOIN %1$s.checklist ON client_checklist.checklist_id = checklist.checklist_id
			LEFT JOIN greenbiz_core.file_upload ON client_result.arbitrary_value = file_upload.hash
			WHERE client_result.client_checklist_id IN(%3$s)
			AND (answer_string.string IS NOT NULL OR client_result.arbitrary_value != "")) client_results

			UNION

			SELECT
			client.company_name,
			client.client_id,
			checklist.name,
			client_checklist.client_checklist_id,
			client_checklist.date_range_finish,
			"Calculated Value" AS type,
			99 AS page_section_sequence,
			0 AS page_sequence,
			0 AS question_sequence,
			0 AS answer_sequence,
			"99.0.0.0" AS `order`,
			"99.0.0.0" AS `page_order`,
			additional_value.group AS section,
			additional_value.key AS question,
			NULL as question_id,
			additional_value.value as answer,
			"" AS answer_label,
			"text" AS rendering,
			NULL as answer_id,
			additional_value.index as `group`,
			additional_value.timestamp as timestamp
			FROM %1$s.additional_value
			LEFT JOIN %1$s.client_checklist ON additional_value.client_checklist_id = client_checklist.client_checklist_id
			LEFT JOIN %2$s.client ON client_checklist.client_id = client.client_id
			LEFT JOIN %1$s.checklist ON client_checklist.checklist_id = checklist.checklist_id
			WHERE additional_value.client_checklist_id IN(%3$s)) combimed_results
			ORDER BY date_range_finish DESC, client_checklist_id, page_section_sequence, page_sequence, question_sequence, answer_sequence
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$this->db->escape_string(is_array($client_checklist_id) ? implode(',',$client_checklist_id) : $client_checklist_id)
		);

		return $query;
	}

	public function getClientResultsWithAdditionalValues($client_checklist_id) {
		$results = array();

		$query = $this->getClientResultsWithAdditionalValuesQuery($client_checklist_id);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$results[] = $row;
			}
			$result->close();
		}

		return($results);
	}

	public function getClientChecklistVariation($client_checklist_id) {

		$query = sprintf('
			SELECT *
			FROM(
				SELECT
				client_checklist.client_checklist_id,
				sibling.client_checklist_id AS sibling_client_checklist_id,
				client_checklist.client_id,
				client.company_name,
				CASE
					WHEN page_section.title IS NOT NULL THEN concat(page_section.title, " - ", page.title)
					ELSE page.title
				END AS section,
				(CASE
					WHEN question.export_key IS NOT NULL AND question.export_key != "" THEN question.export_key
					ELSE question.question
				END) AS question,
				DATE_FORMAT(client_checklist.date_range_finish, "%%Y") AS current_period,
				client_result.arbitrary_value AS current_value,
				DATE_FORMAT(sibling.date_range_finish, "%%Y") AS previous_period,
				sibling_client_result.arbitrary_value AS previous_value,
				(CASE
					WHEN sibling_client_result.arbitrary_value = 0 AND client_result.arbitrary_value > 0 THEN 100.00
					ELSE IFNULL(ROUND(ABS((((client_result.arbitrary_value - sibling_client_result.arbitrary_value)/sibling_client_result.arbitrary_value)*100)),2),0.00)
				END) as variation
				FROM %1$s.client_result
				LEFT JOIN %1$s.client_checklist ON client_result.client_checklist_id = client_checklist.client_checklist_id
				LEFT JOIN %2$s.client ON client_checklist.client_id = client.client_id
				LEFT JOIN %1$s.question ON client_result.question_id = question.question_id
				LEFT JOIN %1$s.answer ON client_result.answer_id = answer.answer_id
				LEFT JOIN %1$s.page ON question.page_id = page.page_id
				LEFT JOIN %1$s.page_section_2_page ON page.page_id = page_section_2_page.page_id
				LEFT JOIN %1$s.page_section ON page_section_2_page.page_section_id = page_section.page_section_id
				LEFT JOIN %1$s.client_checklist sibling ON sibling.client_checklist_id = (SELECT sibling.client_checklist_id FROM %1$s.client_checklist sibling WHERE client_checklist.client_id = sibling.client_id AND client_checklist.checklist_id = sibling.checklist_id AND sibling.date_range_finish < client_checklist.date_range_finish ORDER BY sibling.date_range_finish DESC LIMIT 1)
				LEFT JOIN %1$s.client_result sibling_client_result ON sibling_client_result.client_checklist_id = sibling.client_checklist_id AND sibling_client_result.answer_id = client_result.answer_id
				WHERE client_result.client_checklist_id IN(%3$s)
				AND answer.answer_type IN("int", "float")
				AND client_result.index = 0
				AND client_result.arbitrary_value NOT REGEXP "[[:alpha:]]"
				AND sibling_client_result.arbitrary_value NOT REGEXP "[[:alpha:]]"
				HAVING variation > 0

				UNION ALL

				SELECT
				client_checklist.client_checklist_id,
				sibling.client_checklist_id AS sibling_client_checklist_id,
				client_checklist.client_id,
				client.company_name,
				additional_value.group AS section,
				additional_value.key,
				DATE_FORMAT(client_checklist.date_range_finish, "%%Y") AS current_period,
				SUM(additional_value.value) AS current_value,
				DATE_FORMAT(sibling.date_range_finish, "%%Y") AS previous_period,
				sibling_additional_value.value AS previous_value,
				(CASE
					WHEN sibling_additional_value.value = 0 AND SUM(additional_value.value) > 0 THEN 100.00
					ELSE IFNULL(ROUND(ABS((((SUM(additional_value.value) - sibling_additional_value.value)/sibling_additional_value.value)*100)),2),0.00)
				END) AS variation
				FROM %1$s.additional_value
				LEFT JOIN %1$s.client_checklist ON additional_value.client_checklist_id = client_checklist.client_checklist_id
				LEFT JOIN %2$s.client ON client_checklist.client_id = client.client_id
				LEFT JOIN %1$s.client_checklist sibling ON sibling.client_checklist_id = (SELECT sibling.client_checklist_id FROM %1$s.client_checklist sibling WHERE client_checklist.client_id = sibling.client_id AND client_checklist.checklist_id = sibling.checklist_id AND sibling.date_range_finish < client_checklist.date_range_finish ORDER BY sibling.date_range_finish DESC LIMIT 1)
				LEFT JOIN (SELECT SUM(additional_value.value) AS value, additional_value.`key`, additional_value.client_checklist_id FROM %1$s.additional_value GROUP BY client_checklist_id, `key`) sibling_additional_value ON sibling_additional_value.client_checklist_id = sibling.client_checklist_id AND sibling_additional_value.key = additional_value.key
				WHERE additional_value.client_checklist_id IN(%3$s)
				GROUP BY additional_value.client_checklist_id, additional_value.key
				HAVING variation > 0
			) variation
			ORDER BY variation DESC
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$this->db->escape_string(is_array($client_checklist_id) ? implode(',',$client_checklist_id) : $client_checklist_id)
		);

		return $query;
	}

	public function clientMetricQuery($client_checklist_id, $client_id, $metric_filter = null) {

		$query = sprintf('
			SELECT
			client_checklist.client_id,
			client_checklist.client_checklist_id,
			client.company_name AS "Entity",
			DATE_FORMAT(client_checklist.date_range_start, "%%M %%Y") AS "Period",
			DATE_FORMAT(client_checklist.date_range_start, "%%Y-%%m-%%d") AS "Date",
			client_checklist.date_range_start,
			metric_group.name AS "Metric Group",
			metric.metric AS "Metric",
			client_metric.value AS "Value",
			metric_unit_type.metric_unit_type AS "Unit",
			(CASE
				WHEN metric_unit_type_2_metric.conversion IS NOT NULL AND metric_unit_type_2_metric.conversion != 0
					THEN client_metric.value * metric_unit_type_2_metric.conversion
				ELSE client_metric.value
			END) AS "Default Value",
			(CASE
				WHEN default_unit.metric_unit_type_id IS NOT NULL AND default_unit.metric_unit_type_id != client_metric.metric_unit_type_id
					THEN default_unit_type.metric_unit_type
				ELSE metric_unit_type.metric_unit_type
			END) AS "Default Unit",
			metric_variation_option.value AS "Justification",
			client_metric_variation.value AS "Comment"
			FROM %1$s.client_metric
			LEFT JOIN %1$s.metric ON client_metric.metric_id = metric.metric_id
			LEFT JOIN %1$s.metric_group ON metric.metric_group_id = metric_group.metric_group_id
			LEFT JOIN %1$s.metric_unit_type ON client_metric.metric_unit_type_id = metric_unit_type.metric_unit_type_id
			LEFT JOIN %1$s.client_checklist ON client_metric.client_checklist_id = client_checklist.client_checklist_id
			LEFT JOIN %1$s.metric_unit_type_2_metric ON metric_unit_type_2_metric.metric_unit_type_id = client_metric.metric_unit_type_id AND metric_unit_type_2_metric.metric_id = client_metric.metric_id
			LEFT JOIN %2$s.client ON client_checklist.client_id = client.client_id
			LEFT JOIN %1$s.metric_unit_type_2_metric default_unit ON default_unit.metric_id = client_metric.metric_id AND default_unit.default = 1
			LEFT JOIN %1$s.metric_unit_type default_unit_type ON default_unit.metric_unit_type_id = default_unit_type.metric_unit_type_id
			LEFT JOIN %1$s.client_metric_variation ON client_metric.client_metric_id = client_metric_variation.client_metric_id
			LEFT JOIN %1$s.metric_variation_option ON client_metric_variation.metric_variation_option_id = metric_variation_option.metric_variation_option_id
			WHERE client_checklist.client_id IN(%4$s)
			AND metric.metric IS NOT NULL
			AND client_checklist.client_checklist_id IN(%3$s)
			%5$s
			ORDER BY client_checklist.date_range_start DESC
			#LIMIT 50000
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$this->db->escape_string(is_array($client_checklist_id) ? implode(',',$client_checklist_id) : $client_checklist_id),
			$this->db->escape_string(is_array($client_id) ? implode(',',$client_id) : $client_id),
			$metric_filter
		);

		return $query;
	}

	public function clientMetricEmissions($client_checklist_id, $client_id, $metric_filter = null, $unit = 'Tonne') {

		$query = sprintf('
			SELECT
			c.client_id,
			c.company_name,
			cc.client_checklist_id,
			DATE_FORMAT(IF(cc.date_range_start IS NOT NULL, cc.date_range_start, cc.created), "%%Y-%%m-%%d") as `timestamp`,
			DATE_FORMAT(IF(cc.date_range_start IS NOT NULL, cc.date_range_start, cc.created), "%%M %%Y") AS date_range_start_month_year,
			DATE_FORMAT(IF(cc.date_range_start IS NOT NULL, cc.date_range_start, cc.created), "%%Y") AS date_range_start_year,
			IF("%6$s" = "kg", ROUND(e.value),ROUND((e.value/1000),3)) as value,
			IF("%6$s" = "kg", "kg C02e","Tonnes CO2e") as unit,
			ef.category,
			ef.type,
			ef.scope
			FROM %3$s.emission e
			LEFT JOIN %1$s.client_checklist cc ON e.client_checklist_id = cc.client_checklist_id
			LEFT JOIN %2$s.client c ON cc.client_id = c.client_id
			LEFT JOIN %3$s.emission_factor ef ON e.emission_factor_id = ef.emission_factor_id

			WHERE cc.client_id IN(%5$s)
			AND cc.client_checklist_id IN(%4$s)

			ORDER BY cc.date_range_finish DESC, c.company_name, ef.category, ef.type;
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			DB_PREFIX.'ghg',
			$this->db->escape_string(is_array($client_checklist_id) ? implode(',',$client_checklist_id) : $client_checklist_id),
			$this->db->escape_string(is_array($client_id) ? implode(',',$client_id) : $client_id),
			$this->db->escape_string($unit)
		);

		//var_dump($query);

		return $query;
	}

	public function getAnalyticsQuestions($checklist_id) {
		$questions = array();

		$query = sprintf('
			SELECT *
			FROM (SELECT
			page.page_id,
			(CASE
				WHEN page_section.title IS NOT NULL THEN CONCAT(page_section.title, " - ", page.title)
			    ELSE page.title
			END) AS section,
			question.question_id,
			(CASE
				WHEN question.export_key IS NOT NULL AND question.export_key != "" THEN question.export_key
				ELSE question.question
			END) AS question,
			"question" AS type,
			(CASE
				WHEN question.alt_key = "percent" THEN "percent"
			    ELSE answer.answer_type
			END) AS output
			FROM %1$s.answer
			LEFT JOIN %1$s.question ON answer.question_id = question.question_id
			LEFT JOIN %1$s.page ON question.page_id = page.page_id
			LEFT JOIN %1$s.page_section_2_page ON page.page_id = page_section_2_page.page_id
			LEFT JOIN %1$s.page_section ON page_section_2_page.page_section_id = page_section.page_section_id
			WHERE question.checklist_id = %2$d
			#AND answer.answer_type IN("checkbox","checkbox-other", "float", "int", "drop-down-list", "range", "percent")
			AND question.show_in_analytics = 1
			GROUP BY question.question_id
			ORDER BY page_section.sequence, page.sequence, question.sequence) questions
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$questions[] = $row;
			}
			$result->close();
		}

		return $questions;
	}

	public function getAnalyticsAdditionalValues($checklist_id) {
		$questions = array();

		$query = sprintf('
			SELECT *
			FROM (SELECT
			client_checklist.checklist_id,
			additional_value.group AS section,
			additional_value.key AS question_id,
			additional_value.key AS question,
			"additional-value" AS type,
			(CASE
				WHEN LOWER(additional_value.key) LIKE "%% per %%" THEN "additional-value-alt"
			    ELSE "additional-value"
			END) AS output
			FROM %1$s.additional_value
			LEFT JOIN %1$s.client_checklist ON additional_value.client_checklist_id = client_checklist.client_checklist_id
			WHERE client_checklist.checklist_id = %2$d
			GROUP BY additional_value.key
			ORDER BY additional_value.group, additional_value.key) additional_values			

		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$questions[] = $row;
			}
			$result->close();
		}

		return $questions;
	}

	public function getAnalyticsChartQuestionResults($checklist_id, $question_id, $postData) {
		$response = array();
		$benchmark = isset($postData['benchmark']) && $postData['benchmark'] ? true : false;
		$query = '';

		//Switch on answer type
		switch($postData['output']) {
			case 'float':
			case 'int':

				$query = sprintf('		
					SELECT
					"bar" as chart,
					question.question AS series1,
					(CASE
						WHEN client_checklist.date_range_finish IS NOT NULL THEN DATE_FORMAT(client_checklist.date_range_finish, "%%Y")
						WHEN client_checklist.completed IS NOT NULL THEN DATE_FORMAT(client_checklist.completed, "%%Y")
						ELSE DATE_FORMAT(client_checklist.created, "%%Y")
					END) AS label,
					ROUND(SUM(client_result.arbitrary_value),2) AS data1
					FROM %1$s.client_result
					LEFT JOIN %1$s.client_checklist ON client_result.client_checklist_id = client_checklist.client_checklist_id
					LEFT JOIN %1$s.question ON client_result.question_id = question.question_id
					WHERE client_result.question_id = %2$d'
					 . ($benchmark ? ' ' : ' AND client_result.client_checklist_id IN(%3$s) ') .
					'GROUP BY label
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($question_id), 
					$this->db->escape_string(isset($postData['filtered_client_checklist_array']) ? json_decode($postData['filtered_client_checklist_array']) : null)
				);

				break;

			case 'additional-value':

				$query = sprintf('		
					SELECT
					"bar" as chart,
					CONCAT(additional_value.group, " - ", additional_value.key) AS series1,
					DATE_FORMAT(client_checklist.date_range_finish, "%%Y") AS label,
					ROUND(SUM(additional_value.value),2) AS data1
					FROM %1$s.additional_value
					LEFT JOIN %1$s.client_checklist ON additional_value.client_checklist_id = client_checklist.client_checklist_id
					WHERE additional_value.key IN("%2$s")
					AND client_checklist.date_range_finish IS NOT NULL'
					. ($benchmark ? ' ' : ' AND additional_value.client_checklist_id IN(%3$s) ') .
					'GROUP BY client_checklist.date_range_finish
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($question_id), 
					$this->db->escape_string(isset($postData['filtered_client_checklist_array']) ? json_decode($postData['filtered_client_checklist_array']) : null)
				);

				break;

			case 'additional-value-alt':

				$query = sprintf('		
					SELECT
					"bar" as chart,
					CONCAT(additional_value.group, " - ", additional_value.key) AS series1,
					DATE_FORMAT(client_checklist.date_range_finish, "%%Y") AS label,
					ROUND(SUM(additional_value.value) / IF(SUM(client_result.arbitrary_value) > 0, SUM(client_result.arbitrary_value), 1),2) AS data1
					FROM %1$s.additional_value
					LEFT JOIN %1$s.client_checklist ON additional_value.client_checklist_id = client_checklist.client_checklist_id
		            LEFT JOIN %1$s.question ON LOWER(question.alt_key) = LOWER("%3$s")
					LEFT JOIN %1$s.client_result ON client_checklist.client_checklist_id = client_result.client_checklist_id AND client_result.question_id = question.question_id
					WHERE additional_value.key IN("%2$s")
					AND client_checklist.date_range_finish IS NOT NULL'
					 . ($benchmark ? ' ' : ' AND additional_value.client_checklist_id IN(%4$s) ') .
					'GROUP BY client_checklist.date_range_finish
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string(str_replace(substr($question_id, stripos($question_id," per ")),"",$question_id)),
					$this->db->escape_string(substr($question_id, stripos($question_id," per ")+1)),
					$this->db->escape_string(isset($postData['filtered_client_checklist_array']) ? json_decode($postData['filtered_client_checklist_array']) : null)
				);

				break;

			case 'range':
			case 'percent':

				$query = sprintf('
					SELECT
					`range`.*,
					COUNT(*) AS `data`
					FROM(		
						SELECT
						"pie" as chart,
						"1" as series,
						@step := 5,
						@unit := IF(answer.range_unit != "" AND answer.range_unit IS NOT NULL, answer.range_unit,"%%") AS unit,
						(CASE
							WHEN client_result.arbitrary_value < @step+1 THEN CONCAT("< ",@step+1,@unit)
                            WHEN client_result.arbitrary_value %% @step = 0 THEN CONCAT(FLOOR(((client_result.arbitrary_value/@step)-1)*@step)+1, " - ", ROUND(CEIL((client_result.arbitrary_value)/@step)*@step), @unit)
                            ELSE CONCAT((FLOOR(client_result.arbitrary_value/@step)*@step)+1, " - ", ROUND(CEIL((client_result.arbitrary_value)/@step)*@step), @unit)
						END) AS label
						FROM %1$s.client_result
						LEFT JOIN %1$s.answer ON client_result.answer_id = answer.answer_id
						WHERE client_result.question_id = %2$d'
						 . ($benchmark ? ' ' : ' AND client_result.client_checklist_id IN (%3$s) ') .
					') `range`
					GROUP BY `range`.`label`
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($question_id), 
					$this->db->escape_string(isset($postData['filtered_client_checklist_array']) ? json_decode($postData['filtered_client_checklist_array']) : null)
				);

				break;

			case 'checkbox':
			case 'checkbox-other':
			case 'drop-down-list':

				$query = sprintf('		
					SELECT
					"pie" as chart,
					"1" as series,
					answer.question_id,
					answer.answer_id,
					answer.answer_type,
					answer_string.string AS label,
					(SELECT COUNT(client_result.answer_id) FROM %1$s.client_result WHERE client_result.answer_id = answer.answer_id AND' . ($benchmark ? ' 1' : ' client_result.client_checklist_id IN(%3$s)') . ') AS data,
					ROUND((SELECT SUM(client_result.arbitrary_value) FROM %1$s.client_result WHERE client_result.answer_id = answer.answer_id AND' . ($benchmark ? ' 1' : ' client_result.client_checklist_id IN(%3$s)') . '),2) AS sum
					FROM %1$s.answer
					LEFT JOIN %1$s.answer_string ON answer.answer_string_id = answer_string.answer_string_id
					WHERE answer.question_id = %2$d
					ORDER BY answer.sequence
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($question_id), 
					$this->db->escape_string(isset($postData['filtered_client_checklist_array']) ? json_decode($postData['filtered_client_checklist_array']) : null)
				);

				break;

			default:
				$query = sprintf('		
					SELECT
					"null" as chart,
					"1" as series,
					answer.question_id,
					answer.answer_id,
					answer.answer_type,
					answer_string.string AS label,
					(SELECT COUNT(client_result.answer_id) FROM %1$s.client_result WHERE client_result.answer_id = answer.answer_id AND' . ($benchmark ? ' 1' : ' client_result.client_checklist_id IN(%3$s)') . ') AS data,
					ROUND((SELECT SUM(client_result.arbitrary_value) FROM %1$s.client_result WHERE client_result.answer_id = answer.answer_id AND' . ($benchmark ? ' 1' : ' client_result.client_checklist_id IN(%3$s)') . '),2) AS sum
					FROM %1$s.answer
					LEFT JOIN %1$s.answer_string ON answer.answer_string_id = answer_string.answer_string_id
					WHERE answer.question_id = %2$d
					ORDER BY answer.sequence
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($question_id), 
					$this->db->escape_string(isset($postData['filtered_client_checklist_array']) ? json_decode($postData['filtered_client_checklist_array']) : null)
				);

				break;
		}

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$response[] = $row;
			}
			$result->close();
		}

		return $response;
	}

	public function getAnalyticsTableQuestionResults($checklist_id, $question_id, $postData) {
		$response = array();
		$query = "";

		switch($postData['output']) {
			case 'additional-value':
			case 'additional-value-alt':

				$query = sprintf('		
					SELECT
					client.client_id,
					client.company_name,
					client_checklist.name,
					client_checklist.client_checklist_id,
					CONCAT(additional_value.group, " - ", additional_value.key) AS question,
					ROUND(SUM(additional_value.value),4) AS answer,
					(CASE
						WHEN client_checklist.date_range_finish IS NOT NULL THEN DATE_FORMAT(client_checklist.date_range_finish, "%%Y")
						WHEN client_checklist.completed IS NOT NULL THEN DATE_FORMAT(client_checklist.completed, "%%Y")
						ELSE DATE_FORMAT(client_checklist.created, "%%Y")
					END) AS period
					FROM %1$s.additional_value 
					LEFT JOIN %1$s.client_checklist ON additional_value.client_checklist_id = client_checklist.client_checklist_id
					LEFT JOIN %2$s.client ON client_checklist.client_id = client.client_id
					WHERE additional_value.key IN("%3$s") 
					AND additional_value.client_checklist_id IN(%4$s) 
					GROUP BY client_checklist.client_checklist_id
					ORDER BY client_checklist.date_range_finish DESC, client.company_name
				',
					DB_PREFIX.'checklist',
					DB_PREFIX.'core',
					$this->db->escape_string($question_id), 
					$this->db->escape_string(isset($postData['filtered_client_checklist_array']) ? json_decode($postData['filtered_client_checklist_array']) : null)
				);

				break;

			case 'range':
			case 'percent':

				$query = sprintf('		
					SELECT
					#@unit := IF(answer.answer_type = "percent", "%%", answer.range_unit) AS unit,
					@unit := IF(answer.range_unit != "" AND answer.range_unit IS NOT NULL, answer.range_unit,"%%") AS unit,
					client.client_id,
					client.company_name,
					client_checklist.name,
					client_checklist.client_checklist_id,
					question.question,
					CONCAT(client_result.arbitrary_value, @unit) AS answer,
					(CASE
						WHEN client_checklist.date_range_finish IS NOT NULL THEN DATE_FORMAT(client_checklist.date_range_finish, "%%Y")
						WHEN client_checklist.completed IS NOT NULL THEN DATE_FORMAT(client_checklist.completed, "%%Y")
						ELSE DATE_FORMAT(client_checklist.created, "%%Y")
					END) AS period
					FROM %1$s.client_result 
					LEFT JOIN %1$s.client_checklist ON client_result.client_checklist_id = client_checklist.client_checklist_id
					LEFT JOIN %2$s.client ON client_checklist.client_id = client.client_id 
					LEFT JOIN %1$s.question ON client_result.question_id = question.question_id 
					LEFT JOIN %1$s.answer ON client_result.answer_id = answer.answer_id
					LEFT JOIN %1$s.answer_string ON answer.answer_string_id = answer_string.answer_string_id
					WHERE client_result.question_id = %3$s
					AND client_result.client_checklist_id IN(%4$s)
					ORDER BY client_checklist.date_range_finish DESC, client.company_name
				',
					DB_PREFIX.'checklist',
					DB_PREFIX.'core',
					$this->db->escape_string($question_id), 
					$this->db->escape_string(isset($postData['filtered_client_checklist_array']) ? json_decode($postData['filtered_client_checklist_array']) : null)
				);

				break;

			default:

				$query = sprintf('		
					SELECT
					client.client_id,
					client.company_name,
					client_checklist.name,
					client_checklist.client_checklist_id,
					question.question,
					(CASE
						WHEN answer_string.string IS NOT NULL AND client_result.arbitrary_value IS NOT NULL AND client_result.arbitrary_value != "" THEN CONCAT(answer_string.string, " - ", client_result.arbitrary_value)
						WHEN answer.answer_type = "file-upload" AND file_upload.name IS NOT NULL THEN file_upload.name
						WHEN answer.answer_type = "file-upload" AND file_upload.name IS NULL THEN client_result.arbitrary_value
					    WHEN client_result.arbitrary_value IS NOT NULL AND client_result.arbitrary_value != "" THEN client_result.arbitrary_value
					    ELSE answer_string.string
					END) AS answer,
					CASE 
						WHEN answer.answer_type IN("file-upload") AND client_result.arbitrary_value != "" 
						THEN "url" 
						ELSE "text" 
					END AS rendering,
					client_result.arbitrary_value,
					(CASE
						WHEN client_checklist.date_range_finish IS NOT NULL THEN DATE_FORMAT(client_checklist.date_range_finish, "%%Y")
						WHEN client_checklist.completed IS NOT NULL THEN DATE_FORMAT(client_checklist.completed, "%%Y")
						ELSE DATE_FORMAT(client_checklist.created, "%%Y")
					END) AS period
					FROM %1$s.client_result 
					LEFT JOIN %1$s.client_checklist ON client_result.client_checklist_id = client_checklist.client_checklist_id
					LEFT JOIN %2$s.client ON client_checklist.client_id = client.client_id 
					LEFT JOIN %1$s.question ON client_result.question_id = question.question_id 
					LEFT JOIN %1$s.answer ON client_result.answer_id = answer.answer_id
					LEFT JOIN %1$s.answer_string ON answer.answer_string_id = answer_string.answer_string_id
					LEFT JOIN %2$s.file_upload ON client_result.arbitrary_value = file_upload.hash
					WHERE client_result.question_id = %3$s
					AND client_result.client_checklist_id IN(%4$s)
					ORDER BY client_checklist.date_range_finish DESC, client.company_name
				',
					DB_PREFIX.'checklist',
					DB_PREFIX.'core',
					$this->db->escape_string($question_id), 
					$this->db->escape_string(isset($postData['filtered_client_checklist_array']) ? json_decode($postData['filtered_client_checklist_array']) : null)
				);

				break;
		}

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$response[] = $row;
			}
			$result->close();
		}

		return $response;
	}

	public function getChecklistContent($checklist_id) {
		$checklistContent = array();

		//Get checklists
		$checklists = $this->getChecklistsByChecklistId($checklist_id);

		//For Each Checklist
		foreach($checklists as $checklist) {

			//Get page sections / pages
			$checklistPages = $this->getChecklistPages($checklist->checklist_id);

			foreach($checklistPages as $checklistPage) {
				
				//Get page questions
				$pageQuestions = $getPageQuestions($checklistPage->page_id);
				foreach($pageQuestions as $pageQuestion) {

					//Get question answer options
					$questionAnswers = $this->getQuestionAnswers($pageQuestion->question_id);
					foreach($questionAnswers as $questionAnswer) {

						//List all of the answer options
					}
				}
			}
		}

		return $checklistContent;
	}

	private function getChecklistsByChecklistId($checklist_id) {
		$checklists = array();

		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`checklist`
			WHERE `checklist_id` IN(%2$s);
		',
			DB_PREFIX.'checklist',
			is_array($checklist_id) ? implode(',',$checklist_id) : $checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$checklist[$row->checklist_id] = $row;
			}
			$result->close();
		}

		return $checklists;
	}

	//Get a list of checklists based on a given client_contact_id
	public function getContactChecklists($client_contact_id) {
		$checklists = array();

		$query = sprintf('
			SELECT
			checklist.checklist_id,
			checklist.name
			FROM %1$s.client_checklist
			LEFT JOIN %1$s.checklist ON client_checklist.checklist_id = checklist.checklist_id
			LEFT JOIN %2$s.client_contact ON client_checklist.client_id = client_contact.client_id
			WHERE client_contact.client_contact_id = %3$d
			GROUP BY checklist.checklist_id
			ORDER BY checklist.name
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$client_contact_id
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$checklists[$row->checklist_id] = $row;
			}
			$result->close();
		}
		return $checklists;
	}

	//Get a list of checklists based on a given client_contact_id
	public function getContactClientChecklists($client_contact_id) {
		$clientChecklists = array();

		$query = sprintf('
			SELECT
			client_checklist.client_checklist_id
			FROM %1$s.client_checklist
			LEFT JOIN %2$s.client_contact ON client_checklist.client_id = client_contact.client_id
			WHERE client_contact.client_contact_id = %3$d
			GROUP BY client_checklist.client_checklist_id
			ORDER BY client_checklist.client_checklist_id
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$client_contact_id
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clientChecklists[] = $row->client_checklist_id;
			}
			$result->close();
		}
		return $clientChecklists;
	}

	public function getMetricsByName($checklist_id, $name) {
		$metrics = array();

		$query = sprintf('
			SELECT 
			metric.*
			FROM %1$s.metric
			LEFT JOIN %1$s.metric_group ON metric.metric_group_id = metric_group.metric_group_id
			LEFT JOIN %1$s.page ON metric_group.page_id = page.page_id
			WHERE metric.metric = "%2$s"
			AND page.checklist_id = %3$d;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($name),
			$this->db->escape_string($checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$metrics[] = $row;
			}
			$result->close();
		}
		return($metrics);
	}

	public function getMetricUnitTypesByName($name) {
		$metricUnitTypes = array();

		$query = sprintf('
			SELECT *
			FROM `%1$s`.`metric_unit_type`
			WHERE metric_unit_type.metric_unit_type = "%2$s";
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($name)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$metricUnitTypes[] = $row;
			}
			$result->close();
		}
		return($metricUnitTypes);
	}

	public function getClientChecklistByDate($client_id, $checklist_id, $date_range_start) {
		$clientChecklists = array();

		$query = sprintf('
			SELECT *
			FROM `%1$s`.`client_checklist`
			WHERE client_id = %2$d
			AND checklist_id = %3$d
			AND date_range_start = "%4$s";
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_id),
			$this->db->escape_string($checklist_id),
			$this->db->escape_string($date_range_start)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clientChecklists[] = $row;
			}
			$result->close();
		}
		return($clientChecklists);
	}




// Refactored 20170424

	/**
	*	getClientChecklist
	*/
	private function getClientChecklist($client_checklist_id) {
		$clientChecklist = new stdClass;
		
		$query = sprintf('
			SELECT *
			FROM %1$s.client_checklist
			WHERE client_checklist_id = %2$d
			LIMIT 1
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clientChecklist = $row;
			}
			$result->close();
		}
		
		return $clientChecklist;
	}

	/**
	* 	Get Report Sections by checklist id
	*/
	public function getReportSections($checklist_id) {
		$reportSections = array();

		$query = sprintf('SELECT report_section.*, 0 as demerits, 0 as merits FROM %1$s.report_section WHERE checklist_id = %2$d ORDER BY sequence ASC;',DB_PREFIX.'checklist',$checklist_id);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$reportSections[$row->report_section_id] = $row;
			}
			$result->close();
		}

		return $reportSections;
	}

	/**
	*	Get Checklist by checklist_id
	*/
	public function getChecklist($checklist_id) {
		$checklist = new stdClass;

		$query = sprintf('SELECT * FROM %1$s.checklist WHERE checklist_id = %2$d LIMIT 1',DB_PREFIX.'checklist',$checklist_id);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$checklist = $row;
			}
			$result->close();
		}
		return $checklist;
	}

	/**
	* 	Get Certification Levels by checklist_id
	*/
	public function getCertificationLevels($checklist_id) {
		$certificationLevels = array();

		$query = sprintf('SELECT * FROM %1$s.certification_level WHERE checklist_id = %2$d ORDER BY target ASC;',DB_PREFIX.'checklist',$checklist_id);
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$row->color = $row->progress_bar_color;
				$certificationLevels[] = $row;
			}
			$result->close();			
		}

		return $certificationLevels;
	}

	/**
	* 	Get generic certification levels
	*/
	public function getGenericVertificationLevels() {
		$levels = array();
		
		$levels[] = (object) array('level_id' => '1','name' => 'Very Poor','target' => '0','color' => 'f79892');
		$levels[] = (object) array('level_id' => '2','name' => 'Poor','target' => '20','color' => 'f9c090');
		$levels[] = (object) array('level_id' => '3','name' => 'Average','target' => '40','color' => 'fef87f');
		$levels[] = (object) array('level_id' => '4','name' => 'Good','target' => '60','color' => '7fceed');
		$levels[] = (object) array('level_id' => '5','name' => 'Very Good','target' => '80','color' => '97c89e');
		
		return $levels;
	}

	/**
	* 	get Actions
	*/
	public function getActions($client_checklist_id) {
		$actions = array();

		$query = sprintf('
			SELECT
				action.*,
				MAX(`action`.`demerits`) as `demerits`,
				IF(`client_commitment`.`commitment_id`,`client_commitment`.`commitment_id`,0) AS `commitment_id`,
				IF(`action_2_answer`.`question_id` != "0", `action_2_answer`.`question_id`, `answer`.`question_id`) AS `question_id`,
				IF(`action_2_answer`.`answer_id` = "-1", `action_2_answer`.`answer_id`, `answer`.`answer_id`) AS `answer_id`
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`question`
				ON `client_result`.`question_id` = `question`.`question_id`
			LEFT JOIN `%1$s`.`client_checklist` cc ON `question`.`checklist_id` = `cc`.`checklist_id`
			LEFT JOIN `%1$s`.`answer`
				ON `client_result`.`answer_id` = `answer`.`answer_id`

			LEFT JOIN `%1$s`.`action_2_answer`

				ON (`client_result`.`answer_id` = `action_2_answer`.`answer_id`
				AND IF(
					`answer`.`answer_type` IN ("percent","range","int","float"),
					`client_result`.`arbitrary_value` BETWEEN `action_2_answer`.`range_min` AND `action_2_answer`.`range_max`,
					1
				))

				OR (`action_2_answer`.`question_id` IN (%4$s)
				AND (
					SELECT
						COUNT(`client_result`.`question_id`)
						FROM `%1$s`.`client_result`
						LEFT JOIN `%1$s`.`answer` ON `answer`.`answer_id` = `client_result`.`answer_id`
						WHERE `client_result`.`question_id` = `action_2_answer`.`question_id`
						AND `client_result`.`client_checklist_id` = %2$d
				)
				BETWEEN `action_2_answer`.`range_min` AND `action_2_answer`.`range_max`
				)
			LEFT JOIN `%1$s`.`action`
				ON `action_2_answer`.`action_id` = `action`.`action_id`
			LEFT JOIN `%1$s`.`report_section`
				ON `action`.`report_section_id` = `report_section`.`report_section_id`
			LEFT JOIN `%1$s`.`client_commitment`
				ON `client_result`.`client_checklist_id` = `client_commitment`.`client_checklist_id`
				AND `action`.`action_id` = `client_commitment`.`action_id`
			WHERE 1
				AND `cc`.`checklist_id` = `action`.`checklist_id`
				AND `client_result`.`client_checklist_id` = %2$d
				AND `action`.`action_id` IS NOT NULL
				AND `client_result`.`question_id` IN (%3$s)
			GROUP BY `action`.`action_id`
			ORDER BY 
				`report_section`.`sequence` ASC,
				`action`.`sequence` ASC;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id,
			$this->db->escape_string(implode(",",$this->getMasterAndSlaveQuestions($client_checklist_id)) != "" ? implode(",",$this->getMasterAndSlaveQuestions($client_checklist_id)) : "NULL"),
			$this->db->escape_string(implode(",",$this->getTallyQuestionIdentifiers($client_checklist_id)) != "" ? implode(",",$this->getTallyQuestionIdentifiers($client_checklist_id)) : "NULL")
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$actions[$row->action_id] = $row;
			}
			$result->close();
		}

		return $actions;
	}

	/**
	* 	Get commitments
	*/
	public function getCommitments($actions) {
		$commitments = array();

		$query = sprintf('
			SELECT
				commitment.*,
				`action`.`report_section_id`
			FROM `%1$s`.`commitment`
			LEFT JOIN `%1$s`.`action` ON `commitment`.`action_id` = `action`.`action_id`
			WHERE `commitment`.`action_id` IN (%2$s)
			ORDER BY `commitment`.`action_id` ASC, `commitment`.`sequence` ASC;
		',
			DB_PREFIX.'checklist',
			implode(',',array_keys($actions))
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$commitments[$row->commitment_id] = $row;
			}
			$result->close();
		}

		return $commitments;
	}

	/**
	* 	Get Comfirmations
	*/
	public function getConfirmations($client_checklist_id) {
		$confirmations = array();

		$query = sprintf('
			SELECT
				confirmation.*
			FROM `%1$s`.`client_result`
			LEFT JOIN `%1$s`.`confirmation` ON `client_result`.`answer_id` = `confirmation`.`answer_id`
			AND (`client_result`.`arbitrary_value` = "" OR `client_result`.`arbitrary_value` IS NULL OR CAST(`client_result`.`arbitrary_value` AS SIGNED) >= CAST(`confirmation`.`arbitrary_value` AS SIGNED))
			LEFT JOIN `%1$s`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id` 
			LEFT JOIN `%1$s`.`question` ON `answer`.`question_id` = `question`.`question_id`
			LEFT JOIN `%1$s`.`page` ON `question`.`page_id` = `page`.`page_id`
			WHERE `client_result`.`client_checklist_id` = %2$d
			AND `confirmation`.`confirmation_id` IS NOT NULL
			ORDER BY `page`.`sequence`, `question`.`sequence`, `answer`.`sequence`;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$confirmations[] = $row;
			}
			$result->close();
		}

		return $confirmations;
	}

	/**
	* 	Get Resources
	*/
	public function getResources($actions) {
		$resources = array();

		$query = sprintf('SELECT resource.* FROM %1$s.resource WHERE action_id IN (%2$s);', DB_PREFIX.'checklist',implode(',',array_keys($actions)));

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$resources[$row->resource_id] = $row;
			}
			$result->close();
		}
		return $resources;
	}

	/**
	* 	Get Commitment Fields
	*/
	/*
	public function getCommitmentFields($commitments, $client_checklist_id) {
		$commitmentFields = array();

		$query = sprintf('
			SELECT
				commitment_field.*
				`client_commitment_field`.`value`
			FROM `%1$s`.`commitment_field`
			LEFT JOIN `%1$s`.`commitment_fieldset` USING (`commitment_fieldset_id`)
			LEFT JOIN `%1$s`.`client_commitment_field`
				ON `commitment_field`.`commitment_field_id` = `client_commitment_field`.`commitment_field_id`
				AND `client_commitment_id` IN (
					SELECT
						`client_commitment`.`client_commitment_id`
					FROM `%1$s`.`client_commitment`
					WHERE `client_commitment`.`client_checklist_id` = %2$d
				)
			WHERE `commitment_field`.`commitment_fieldset_id` IN (
				SELECT
					DISTINCT `commitment`.`commitment_fieldset_id`
				FROM `%1$s`.`commitment`
				WHERE `commitment`.`commitment_id` IN (%3$s)
			);
		',
			DB_PREFIX.'checklist',
			$client_checklist_id,
			implode(',',array_keys($commitments))
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$commitmentFields[$row->commitment_field_id] = $row;
			}
			$result->close();
		}

		return $commitmentFields;	
	}*/

	/**
	* 	Update Client Checklist
	*/
	public function updateClientChecklistScores($client_checklist_id, $initial_score, $current_score, $fail_points) {
		$query = sprintf('
			UPDATE `%1$s`.`client_checklist` SET
				`initial_score` = %3$f,
				`current_score` = %4$f,
				`fail_points` = %5$d
			WHERE `client_checklist_id` = %2$d;
		',
			DB_PREFIX.'checklist',
			$client_checklist_id,
			$initial_score,
			$current_score,
			$fail_points
		);

		return $this->db->query($query);
	}

	/**
	* 	Set client checklist score
	*/
	private function setClientChecklistScore($client_checklist_id, $score) {
		
		$query = sprintf('
			INSERT INTO `%1$s`.`client_checklist_score` SET
			`client_checklist_id` = %2$d,
			`timestamp` = "%3$s",
			`score` = %4$f
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string(date('Y-m-d H:i:s')),
			$this->db->escape_string($score)
		);

		return $this->db->query($query);
	}

	/**
	* 	Get Report
	*/
	public function getReport($client_checklist_id, $getFullReport = true) {		
		$report 								= $this->getClientChecklist($client_checklist_id);
		$checklist								= $this->getChecklist($report->checklist_id);

		$report->checklist_id 					= $checklist->checklist_id;
		$report->certificationLevels 			= $this->getCertificationLevels($report->checklist_id);
		$report->genericCertificationLevels 	= $this->getGenericVertificationLevels();
		$report->reportSections 				= $this->getReportSections($report->checklist_id);

		$report->points							= 0;
		$report->demerits						= 0;
		$report->merits							= 0;
		$report->initial_score					= 0;
		$report->current_score					= 0;
		$report->fail_points					= 0;
		$report->report_sections				= array();
		$report->actions						= array();
		$report->commitments					= array();
		// $report->commitment_fields				= array();
		$report->certification_levels			= array();
		$report->action_owner					= array();
		$report->owner_2_action					= array();
		$report->client_sites					= array();
		$report->resources						= array();
		$report->insta_fail						= false;
		$report->certifiedLevel					= NULL;
		
		//Set Report Section Points
		foreach($report->reportSections as $key=>$val) {
			$report->reportSections[$key]->points = $this->getReportSectionPoints($key,$report->client_checklist_id);
			$report->points += $report->reportSections[$key]->points;
		}
		
		//Set Report Actions
		$report->actions = $this->getActions($report->client_checklist_id);

		foreach($report->actions as $key=>$val) {
				
			//Fail factor multiplication
			if($report->actions[$key]->fail_factor > 0) {
				$report->actions[$key]->demerits = ($report->actions[$key]->demerits * $report->actions[$key]->fail_factor);
			}
			
			//If the new demerits are going to be less than the available points for the section
			if(($report->reportSections[$report->actions[$key]->report_section_id]->demerits + $report->actions[$key]->demerits) <= $report->reportSections[$report->actions[$key]->report_section_id]->points) {
				$report->reportSections[$report->actions[$key]->report_section_id]->demerits += $report->actions[$key]->demerits;
				$report->demerits += $report->actions[$key]->demerits;
			} else {
				$difference = ($report->reportSections[$report->actions[$key]->report_section_id]->points - $report->reportSections[$report->actions[$key]->report_section_id]->demerits);
				$report->reportSections[$report->actions[$key]->report_section_id]->demerits += $difference;
				$report->demerits += $difference;
			}
			
			//Instant fail has been triggered, set all report section scores to zero for a complete fail
			if($report->actions[$key]->insta_fail == '1') {
				$report->insta_fail = true;
			}
			
			//Fail points, tally the failing points for the overall report
			if($report->actions[$key]->fail_point == '1') {
				$report->fail_points++;
			}
		}
		
		$report->commitments = $this->getCommitments($report->actions);

		foreach($report->commitments as $key=>$val) {
			if($report->actions[$report->commitments[$key]->action_id]->commitment_id == $report->commitments[$key]->commitment_id) {
				$report->reportSections[$report->commitments[$key]->report_section_id]->merits += $report->commitments[$key]->merits;
				$report->merits += $report->commitments[$key]->merits;
			}
		}

		if($report->points) {
			if($report->insta_fail) {
				$report->initial_score = 0;
				$report->current_score = 0;			
			}
			else {		
				$report->initial_score = ($report->points - $report->demerits) / $report->points;
				$report->current_score = ($report->points - $report->demerits + $report->merits) / $report->points;
			}

			if($report->initial_score < 0) {
				$report->initial_score = 0;
			}
			if($report->current_score < 0) {
				$report->current_score = 0;
			}
		}

		if($getFullReport) {
			$report->resources = $this->getResources($report->actions);
            // $report->commitment_fields = $this->getCommitmentFields($report->commitments, $client_checklist_id);
			$report->checklistPages = $this->getClientChecklistPages($client_checklist_id);
			$report->checklistPageSections = $this->getClientChecklistPageSections($client_checklist_id);
			$report->questionAnswers = $this->getQuestionAnswers($client_checklist_id);
			$report->triggeredQuestions = $this->getTriggeredQuestions($client_checklist_id);
			$report->confirmations = $this->getConfirmations($client_checklist_id);
			$report->audits = $this->getAudits($client_checklist_id);
			$report->commitmentAudits = $this->getCommitmentAudits($client_checklist_id);
			$report->auditEvidence = $this->getAuditEvidence($client_checklist_id);
			$report->clientMetrics = $this->getClientMetrics($client_checklist_id);
			$report->metricGroups = $this->getMetricGroups($client_checklist_id);
			$report->action_owner = $this->getActionOwnersByClientId($client_checklist_id);
			$report->owner_2_action = $this->getOwner2Action($client_checklist_id);
			$report->client_sites = $this->getClientChecklistSites($client_checklist_id);

			$this->updateClientChecklistScores($client_checklist_id,$report->initial_score,$report->current_score,$report->fail_points);
			$this->setClientChecklistScore($client_checklist_id, $report->current_score);
		}
		
		// Set certification 
		foreach($report->certificationLevels as $certificationLevel) {
			if($report->current_score * 100 >= $certificationLevel->target) {
				$report->certified_level = $certificationLevel;
			}
		}
		
		//Format score
		$report->initial_score = number_format($report->initial_score,2,'.','');
		$report->current_score = number_format($report->current_score,2,'.','');
		
		return $report;
	}

	public function getEntry($client_checklist_id) {
		$entries = array();

		//Get Client Checklists
		$query = sprintf('
			SELECT *
			FROM %1$s.client_checklist
			WHERE client_checklist.client_checklist_id IN(%2$s);
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$entries[$row->client_checklist_id] = $row;
			}
			$result->close();
		}

		return $entries;
	}

	private function compareSequence($a, $b) {
    	return $a->sequence - $b->sequence;
	}

	private function compareClientChecklistCurrentScore($a, $b) {
    	return (floatval($a->current_score)*100) < (floatval($b->current_score)*100);
	}

	public function compareClientChecklist($client_checklist_id) {
		$comparison = new stdClass;
		$comparison->clientChecklists = array();
		$comparison->pages = array();
		$comparison->questions = array();
		$client = new client($this->db);

		$clientChecklists = $this->getEntry($client_checklist_id);
		usort($clientChecklists, array('clientChecklist','compareClientChecklistCurrentScore'));

		foreach($clientChecklists as $clientChecklist) {
			$clientChecklist->answers = array();
			$company = $client->getClients($clientChecklist->client_id);
			$clientChecklist->company_name = $company[0]->company_name;
			$clientChecklist->score = is_null($clientChecklist->current_score) ? 'N/A' : number_format($clientChecklist->current_score * 100,2).'%';
			$clientChecklist->start = is_null($clientChecklist->created) ? 'N/A' : date('j/n/Y' , strtotime($clientChecklist->created));
			$clientChecklist->finish = is_null($clientChecklist->completed) ? 'N/A' : date('j/n/Y' , strtotime($clientChecklist->completed));

			$pages = $this->getChecklistPages($clientChecklist->client_checklist_id);
			foreach($pages as $page) {
				$comparison->pages[$page->page_id] = $page;
			}

			$questions = $this->getClientChecklistQuestions($clientChecklist->client_checklist_id);
			foreach($questions as $question) {
				$comparison->questions[$question->question_id] = $question;
			}

			$questionAnswers = $this->getQuestionAnswers($clientChecklist->client_checklist_id);
			foreach($questionAnswers as $questionAnswer) {
				$clientChecklist->answers[] = $questionAnswer[0];
			}

			$comparison->clientChecklists[$clientChecklist->client_checklist_id] = $clientChecklist;
		}

		return $comparison;
	}

	/**
	* A method to set the clientChecklist status
	*
	* @param string $status
	* @param array $client_checklist_id
	* @return bool
	*/
	public function setStatus($status, $client_checklist_id) {
		$client_checklist_id = !is_array($client_checklist_id) ? explode(',', $client_checklist_id) : $client_checklist_id;

		$this->db->setDb(DB_PREFIX.'checklist');
		$result = $this->db->where('client_checklist_id', $client_checklist_id, 'IN')
			->update('client_checklist', Array('status' => $status));
		
		return $result;
	}

	/**
	* A method to get the status code
	*
	* @param string $status
	* @return int
	*/
	public function getStatusCode($status) {
		$this->db->setDb(DB_PREFIX.'checklist');
		$codes = $this->db->where('status', strtolower($status))
			->orWhere('client_checklist_status_id',$status)
			->getOne('client_checklist_status');

		return $this->db->count > 0 ? $codes['client_checklist_status_id'] : 1;
	}

	/**
	* A method to set the clientChecklist progress
	*
	* @param array $client_checklist_id
	* @param int $progress
	* @param bool $completed
	* @return bool
	*/
	public function setProgress($client_checklist_id,$progress,$completed=false) {
		$date = $completed ? $this->db->now() : null;
		$client_checklist_id = !is_array($client_checklist_id) ? explode(',', $client_checklist_id) : $client_checklist_id;

		$this->db->setDb(DB_PREFIX.'checklist');
		$result = $this->db->where('client_checklist_id', $client_checklist_id, 'IN')
			->update('client_checklist', Array('progress' => $progress, 'completed' => $date));

		return $result;
	}

	public function getRelatedClientResults($question_id, $client_checklist_id = null) {
		$this->db->setDb(DB_PREFIX.'checklist');

		//Subquery
		$qid = $this->db->subQuery();
		$qid->join(DB_PREFIX.'checklist.question q', 'rq.page_id = q.page_id AND rq.index = q.index', 'LEFT');
		$qid->where('q.question_id',$question_id);
		$qid->where('cr.question_id',$question_id, '!=');
		$qid->get(DB_PREFIX.'checklist.question rq', NULL,'rq.question_id');

		//Query
		$this->db->join(DB_PREFIX.'checklist.answer a','cr.answer_id = a.answer_id', 'LEFT');
		$this->db->join(DB_PREFIX.'checklist.question q', 'cr.question_id = q.question_id', 'LEFT');
		$this->db->where('cr.question_id', $qid, 'IN');

        if(!is_null($client_checklist_id)) {
            $this->db->where('cr.client_checklist_id',$client_checklist_id);
        }

        $columns = 'cr.*, q.*, a.*';

        return $this->db->get(DB_PREFIX.'checklist.client_result cr', NULL, $columns);	
	}

	/**
	* Get related client checklists
	*/
	public function getPreviousClientChecklists($client_checklist_id) {
		$previousClientChecklists = array();
		$clientChecklist = $this->getClientChecklist($client_checklist_id);

		if(!empty($clientChecklist)) {
			$this->db->setDb(DB_PREFIX.'checklist');
			$this->db->where('cc.client_id', $clientChecklist->client_id);
			$this->db->where('cc.checklist_id', $clientChecklist->checklist_id);
			$this->db->where('cc.status', 4, '!=');
			$this->db->where('cc.date_range_start', $clientChecklist->date_range_start, '<');
			$this->db->orderBy('date_range_start', 'desc');
			$previousClientChecklists = $this->db->ObjectBuilder()->get('client_checklist cc');
		}
		
		return $previousClientChecklists;
	}

	/**
	* Get checklist answers
	*/
	public function getChecklistAnswers($checklist_id, $question_id = null) {
		$answers = array();

		$this->db->setDb(DB_PREFIX.'checklist');
		$this->db->join('answer_string ast', 'a.answer_string_id = ast.answer_string_id', 'LEFT');
		$this->db->join('question q', 'a.question_id = q.question_id', 'LEFT');
		$this->db->join('page p', 'q.page_id = p.page_id', 'LEFT');
		$this->db->where('p.checklist_id', $checklist_id);
		if(!is_null($question_id)) {
			$this->db->where('q.question_id', $question_id);
		}
		$this->db->orderBy('p.sequence', 'asc');
		$this->db->orderBy('q.sequence', 'asc');
		$this->db->orderBy('a.sequence', 'asc');

		$answers = $this->db->ObjectBuilder()->get('answer a', NULL, 'q.question, q.export_key, q.multiple_answer, a.*, ast.string AS answer_string');

		return $answers;
	}

	/**
	* Get checklist results
	*/
	public function getChecklistResults($checklist_id, $question_id = null, $client_id = null, $client_checklist_id = array()) {
		$results = array();

		$this->db->setDb(DB_PREFIX.'checklist');
		$this->db->join('question q', 'cr.question_id = q.question_id', 'LEFT');
		$this->db->join('answer a', 'cr.answer_id = a.answer_id', 'LEFT');
		$this->db->join('answer_string ans', 'a.answer_string_id = ans.answer_string_id', 'LEFT');
		$this->db->join('client_checklist cc', 'cr.client_checklist_id = cc.client_checklist_id', 'LEFT');
		$this->db->where('cc.checklist_id', $checklist_id);
		if(!empty($client_checklist_id)) {
			$this->db->where('cr.client_checklist_id', array_values($client_checklist_id), 'IN');
		}
		if(!is_null($client_id)) {
			$this->db->where('cc.client_id', $client_id);
		}
		if(!is_null($question_id)) {
			$this->db->where('q.question_id', $question_id);
		}

		$results = $this->db->ObjectBuilder()->get('client_result cr', NULL, 'cr.*, a.answer_type, a.range_unit, ans.string, cc.date_range_finish, DATE_FORMAT(cc.date_range_finish, "%Y") AS "year"');
		return $results;
	}

	/**
	* Get clientChecklist variations
	*/
	public function getClientChecklistVariationResponses($client_checklist_id) {
		$results = array();
		$this->db->setDb(DB_PREFIX.'checklist');
		$this->db->where('client_checklist_id', $client_checklist_id);
		$results = $this->db->ObjectBuilder()->get('variation', NULL);

		return $results;
	}

	/**
	* Get clientChecklist variation options
	*/
	public function getClientChecklistVariationResponseOptions() {
		$results = array();
		$this->db->setDb(DB_PREFIX.'checklist');
		$results = $this->db->ObjectBuilder()->get('variation_option', NULL);

		return $results;
	}

	/**
	* Get checklist benchmark results
	*/
	public function getChecklistBenchmarkResults($checklist_id, $question_id = null) {
		$params = !is_null($question_id) ? [$checklist_id, $question_id] : [$checklist_id];
		
		$this->db->setDb(DB_PREFIX . 'checklist');
		$results = $this->db->ObjectBuilder()->rawQuery('
			SELECT 
			cr.question_id, 
			cr.answer_id,
			q.multiple_answer,
			ans.string,
			IF(q.multiple_answer = 1,(
			SELECT
			COUNT(DISTINCT ucr.client_checklist_id)
			FROM client_result ucr
			LEFT JOIN client_checklist ucc ON ucr.client_checklist_id = ucc.client_checklist_id
			WHERE ucr.question_id = cr.question_id
			AND ucc.date_range_finish = cc.date_range_finish
			), COUNT(cr.answer_id)) AS respondents,
			COUNT(*) AS count, 
			MIN(CAST(cr.arbitrary_value AS SIGNED)) AS min, 
			MAX(CAST(cr.arbitrary_value AS SIGNED)) AS max, 
			ROUND(AVG(CAST(cr.arbitrary_value AS SIGNED))) AS avg, 
			DATE_FORMAT(cc.date_range_finish, "%Y") AS "year" 
			FROM client_result cr 
			LEFT JOIN question q on cr.question_id = q.question_id 
			LEFT JOIN client_checklist cc on cr.client_checklist_id = cc.client_checklist_id
			LEFT JOIN answer a ON cr.answer_id = a.answer_id
			LEFT JOIN answer_string ans ON a.answer_string_id = ans.answer_string_id
			WHERE cc.checklist_id = ?'
			. (!is_null($question_id) ? ' AND q.question_id = ?' : '') .
			' GROUP BY cr.answer_id, cc.date_range_finish
		', $params);

		return $results;
	}

	/**
	* Get Client Checklist variations
	*/
	public function getClientChecklistVariations($client_checklist_id, $previous_client_checklist_id) {
		$variations = array();
		$compare = ['checkbox', 'percent', 'range', 'date', 'int', 'float', 'drop-down-list'];
		$numerical = ['percent', 'range', 'int', 'float'];
		$previousClientChecklist = $this->getClientChecklist($previous_client_checklist_id);

		//Get Answers
		$currentResults = $this->getQuestionAnswers($client_checklist_id);
		$previousResults = $this->getQuestionAnswers($previous_client_checklist_id);
		
		//Remove checkbox-other answer types
		$currentResults = $this->removeQuestionAnswersOfType($currentResults, ['checkbox-other']);
		$previousResults = $this->removeQuestionAnswersOfType($previousResults, ['checkbox-other']);

		//Remove Legacy Answers
		$currentResults = $this->removeLegacyQuestionAnswers($previousClientChecklist->checklist_id, $currentResults);
		$previousResults = $this->removeLegacyQuestionAnswers($previousClientChecklist->checklist_id, $previousResults);

		//Sum repeatable
		$currentResults = $this->sumRepeatableAnswers($currentResults);
		$previousResults = $this->sumRepeatableAnswers($previousResults);
		
		$checklistPages = $this->getChecklistPages($client_checklist_id);

		foreach($currentResults as $currentQuestion=>$currentResult) {
			foreach($previousResults as $previousQuestion=>$previousResult) {
				if($currentQuestion == $previousQuestion && isset($currentResult[0]) && in_array($currentResult[0]->answer_type, $compare)) {
					$variation = array();
					foreach($currentResult as $cakey=>$currentAnswer) {
						foreach($checklistPages as $checklistPage) {
							if($checklistPage->page_id === $currentAnswer->page_id) {
								$currentAnswer->token = $checklistPage->token;
								$currentAnswer->page_section_title = $checklistPage->page_section_title;
								$currentAnswer->page_title = $checklistPage->title;
								$currentAnswer->page_section_id = $checklistPage->page_section_id;
							}
						}
						$currentAnswer->type = 'question';
						$currentAnswer->key = $currentAnswer->question_id;
						unset($currentAnswer->tip);

						$variation['currentResponses'][$currentAnswer->answer_id] = $currentAnswer;
						$currentAnswer->match = false;
						foreach($previousResult as $pakey=>$previousAnswer) {
							unset($previousAnswer->tip);

							$variation['previousResponses'][$previousAnswer->answer_id] = $previousAnswer;
							if($currentAnswer->answer_id == $previousAnswer->answer_id) {
								$currentAnswer->match = true;

								//If a numerical and arbitrary value is different
								if($currentAnswer->arbitrary_value != $previousAnswer->arbitrary_value && in_array($currentAnswer->answer_type, $numerical)) {
									if(!in_array($currentAnswer->answer_type,['float', 'int'])) {
										$variation['change'] = new stdClass;
										$variation['change']->difference = $currentAnswer->arbitrary_value - $previousAnswer->arbitrary_value;
										$variation['change']->percent = $previousAnswer->arbitrary_value != 0 ? number_format((($currentAnswer->arbitrary_value - $previousAnswer->arbitrary_value) / $previousAnswer->arbitrary_value) * 100,2) : 100;
									} else {
										if($currentAnswer->arbitrary_value != 0 && $currentAnswer->arbitrary_value != 0) {
											$variation['change'] = new stdClass;
											$variation['change']->difference = $currentAnswer->arbitrary_value - $previousAnswer->arbitrary_value;
											$variation['change']->percent = $previousAnswer->arbitrary_value != 0 ? number_format((($currentAnswer->arbitrary_value - $previousAnswer->arbitrary_value) / $previousAnswer->arbitrary_value) * 100,2) : 100;
										}
									}
								}								
							}
						}

						//If not a numerical and no match or different answer count
						if(!in_array($currentAnswer->answer_type, $numerical)) {
							if(!$currentAnswer->match || count($currentResult) != count($previousResult)) {
								$variation['change'] = new stdClass;
								$currentDifference = $this->compareAnswers($currentResult, $previousResult);
								$previousDifference = $this->compareAnswers($previousResult, $currentResult);
								$variation['change']->difference = ($currentDifference > 0 ? $currentDifference . ' added. ' : '') . ($previousDifference > 0 ? $previousDifference . ' removed.' : '');
								$variation['change']->percent = null;
							}
						}

						if(isset($variation['change'])) {
							$variations[$currentQuestion] = $variation;
						}
					}
				}
			}
		}

		$response = new stdClass;
		$response->clientChecklist = $previousClientChecklist;
		$response->variations = $variations;

		return $response;
	}

	public function compareAnswers($answers, $compareAnswers) {
		$count = 0;
		foreach($answers as $key=>$answer) {
			foreach($compareAnswers as $ckey=>$cAnswer) {
				$count += $answer->answer_id == $cAnswer->answer_id ? 1 : 0;
			}
		}

		return count($answers) - $count;
	}

	public function sumRepeatableAnswers($questionAnswers) {
		foreach($questionAnswers as $index=>$questionAnswer) {
			if(isset($questionAnswer[0]) && $questionAnswer[0]->repeatable) {
				if($questionAnswer[0]->show_in_analytics) {
					$total = 0;
					foreach($questionAnswer as $key=>$answer) {
						if(is_numeric($answer->arbitrary_value)) {
							$total += $answer->arbitrary_value;
						}
					}
					$questionAnswer[0]->arbitrary_value = $total;
					$questionAnswers[$index] = array($questionAnswer[0]);
				} else {
					unset($questionAnswers[$index]);
				}
			}
		}

		return $questionAnswers;
	}

	public function removeQuestionAnswersOfType($questionAnswers, $type = array()) {
		foreach($questionAnswers as $index=>$questionAnswer) {
			foreach($questionAnswer as $key=>$answer) {
				if(in_array($answer->answer_type, $type)) {
					unset($questionAnswers[$index][$key]);
				}
			}
		}

		return $questionAnswers;
	}

	public function removeLegacyQuestionAnswers($checklist_id, $questionAnswers) {
		$validAnswers = array();
		$checklistAnswers = $this->getChecklistAnswers($checklist_id);
		foreach($checklistAnswers as $checklistAnswer) {
			$validAnswers[] = $checklistAnswer->answer_id;
		}

		foreach($questionAnswers as $index=>$questionAnswer) {
			foreach($questionAnswer as $key=>$answer) {

				//Remove Legacy
				if(!in_array($answer->answer_id, $validAnswers)) {
					unset($questionAnswers[$index][$key]);

				//Remove non validate
				} elseif($answer->validate != 1) {
					unset($questionAnswers[$index][$key]);
				}
			}
		}

		return $questionAnswers;		
	}

	public function storeVariationResponse($client_checklist_id, $key, $option, $reason) {
		$this->deleteVariationResponse($client_checklist_id, $key);

		$data = Array(
			'client_checklist_id' => $client_checklist_id,
			'key' => $key,
			'variation_option_id' => $option,
			'reason' => $reason
		);

		$this->db->setDb(DB_PREFIX.'checklist');
		$id = $this->db->insert('variation', $data);

		return;
	}

	public function deleteVariationResponse($client_checklist_id, $key) {
		$this->db->setDb(DB_PREFIX.'checklist');
		$this->db->where('client_checklist_id', $client_checklist_id);
		$this->db->where('`key`', $key);
		$this->db->delete('variation');

		return;
	}

	/**
	*	Get all client results including answer string
	*	Optional limit by $question_id
	*	@param array An array of client checklist identifiers
	*	@param array An optional array of question identifiers to limit the results
	*/
	public function getClientChecklistResults($client_checklist_id, $question_id = array()) {
		$this->db->setTrace(true);
		$this->db->setDb(DB_PREFIX.'checklist');
		$this->db->join('answer a', 'a.answer_id=cr.answer_id', 'LEFT');
		$this->db->join('answer_string ans', 'ans.answer_string_id=a.answer_string_id', 'LEFT');
		$this->db->join('client_checklist cc', 'cc.client_checklist_id=cr.client_checklist_id', 'LEFT');
		$this->db->join(DB_PREFIX.'core.client c', 'cc.client_id=c.client_id', 'LEFT');
		$this->db->where('cr.client_checklist_id', array_values($client_checklist_id), 'IN');
		if(!empty($question_id)){
			$this->db->where('cr.question_id', array_values($question_id), 'IN');
		}

		$results = $this->db->get('client_result cr', NULL, 'cr.*, cc.client_id, c.company_name, a.sequence, a.answer_type, a.alt_value, ans.string');

		return $results;
	}

	/**
	* Check to see if the checklist requires the page to be completed before proceding
	*/
	public function requirePageComplete($client_checklist_id) {
		$this->db->setDb(DB_PREFIX.'checklist');
		$this->db->join('checklist c', 'c.checklist_id=cc.checklist_id', 'LEFT');
		$this->db->where('cc.client_checklist_id', $client_checklist_id);
		$clientChecklist = $this->db->ObjectBuilder()->getOne('client_checklist cc', NULL, 'c.require_page_complete');

		return isset($clientChecklist->require_page_complete) && $clientChecklist->require_page_complete == 0 ? false : true;
	}

	/**
	* 	Get Form Group
	*/
	public function getPageFormGroups($page_id) {
		$this->db->setDb(DB_PREFIX.'checklist');
		$this->db->where('page_id', $page_id);
		$formGroups = $this->db->ObjectBuilder()->get('form_group');

		return $formGroups;
	}

	/**
	*	Find Answer
	*/
	public function findAnswer($question_id, $answer_id = null, $string = null) {
		$response = null;
		$answers = $this->getAnswers($question_id);

		foreach($answers as $answer) {

			//Answer ID
			if($answer->answer_id == $answer_id) {
				$response = $answer;
				break;
			}
			
			//Answer String
			if($answer->string == $string) {
				$response = $answer;
				break;
			}

			//Single Answer
			if(count($answers) == 1) {
				$response = $answer;
				break;
			}
		}

		return $response;
	}

	/**
	*	Get Client Checklist Validation
	*/
	public function getClientChecklistValidation($client_checklist_id) {
		$validation = array();

		$this->db->setDb(DB_PREFIX.'checklist');
		$this->db->join('client_checklist cc', 'v.client_checklist_id=cc.client_checklist_id','LEFT');
		$this->db->join(DB_PREFIX.'core.client c', 'cc.client_id=c.client_id','LEFT');
		$this->db->join('variation_option vo', 'v.variation_option_id=vo.variation_option_id','LEFT');
		$this->db->where('v.client_checklist_id', array_values($client_checklist_id), 'IN');

		$columns = 'v.*, vo.variation, c.company_name, cc.date_range_start, cc.date_range_finish';
		$validation = $this->db->ObjectBuilder()->get('variation v', NULL, $columns);

		return $validation;
	}

	public function getQuestionPermissions($question_id) {
		$permissions = array();

		$this->db->setDb(DB_PREFIX.'checklist');
		$this->db->where('qp.question_id', $question_id);
		$permissions = $this->db->ObjectBuilder()->get('question_permission qp');

		return $permissions;
	}

	public function getPermissionTypes() {
		$permissionTypes = array();
		
		$this->db->setDb(DB_PREFIX.'checklist');
		$permissionTypes = $this->db->ObjectBuilder()->get('permission_type pt');

		return $permissionTypes;		
	}

	/**
	 * Set Client Action Notes
	 */
	 public function setClientActionNotes($client_checklist_id, $notes) {
		$this->deleteClientActionNotes($client_checklist_id);

		if(isset($notes['report_section_id'])) {
			foreach($notes['report_section_id'] as $key=>$val) {
				$note = array();
				$note['client_checklist_id'] = $client_checklist_id;
				!isset($notes['action_id'][$key]) ?: $note['action_id'] = $notes['action_id'][$key];
				!isset($notes['report_section_id'][$key]) ?: $note['report_section_id'] = $notes['report_section_id'][$key];
				for($i=1;$i<10;$i++) {
					!isset($notes['extension' . $i][$key]) ?: $note['extension' . $i] = $notes['extension' . $i][$key];
				}

				$this->db->setDb(DB_PREFIX.'checklist');
				$this->db->insert('client_action_note', $note);
			}
		}
	 }

	/**
	 * Get Client Action Notes
	 */
	public function getClientActionNotes($client_checklist_id) {
		$this->db->setDb(DB_PREFIX.'checklist');
		$this->db->where('client_checklist_id', $client_checklist_id);
		return $this->db->ObjectBuilder()->get('client_action_note');
	}

	/**
	 * Delete Client Action Notes
	 */
	public function deleteClientActionNotes($client_checklist_id) {
		$this->db->setDb(DB_PREFIX.'checklist');
		$this->db->where('client_checklist_id', $client_checklist_id);
		return $this->db->delete('client_action_note');
	}

	/**
	 * Get the progress of a clientChecklist
	 *
	 * @param [type] $pages
	 * @param [type] $pageComplete
	 * @param [type] $skipPages
	 * @param [type] $completed
	 * @return void
	 */
	public function getClientChecklistProgress($pages, $pageComplete, $skipPages, $completed) {
		$progress = 0;
		$completedPages = 0;
		$pageCount = 0;
		
		foreach($pages as $page) {
			if(!$skipPages[$page->page_id]) {
				$pageCount++;
			}
				
			if(($pageComplete[$page->page_id]) && (!$skipPages[$page->page_id])) {
				$completedPages++;
			}
		}
		
		if($completedPages > 0) {
			$progress = ceil(($completedPages/$pageCount)*100);
		}
		
		if(!is_null($completed)) {
			$progress = 100;
		}
				
		return $progress;
	}

	/**
	 * Get the progress of the client checklist using the client checklist id
	 *
	 * @param [type] $client_checklist_id
	 * @return void
	 */
	public function getClientChecklistProgressByClientChecklistId($client_checklist_id) {
		$clientChecklist = $clientChecklist = $this->getClientChecklist($client_checklist_id);
		$pages = $this->getChecklistPages($client_checklist_id);
		$results = $this->getClientResults($client_checklist_id);
		$pageComplete = $this->getChecklistPagesCompleted($pages, $results);
		$skipPages = $this->getPageDisplayStatus($pages, $results);
		$progress = $this->getClientChecklistProgress($pages, $pageComplete, $skipPages, $clientChecklist->completed);

		if($clientChecklist->progress != $progress) {
			$this->updateChecklistProgress($clientChecklist->client_checklist_id, $progress);
		}

		return $progress;
	}

	/**
	 * Get the completed pages of a client checklist
	 *
	 * @param [type] $pages
	 * @param [type] $results
	 * @return void
	 */
	public function getChecklistPagesCompleted($pages, $results) {
		$pageComplete = array();

		foreach($pages as $page) {
			$pageComplete[$page->page_id] = true;

			$questions = $this->getPageQuestions($page->page_id);
			foreach($questions as $question) {
				$question->triggered = count($question->dependencies) <= 0 ? true : false;

				foreach($question->dependencies as $key=>$val) {
					if($this->dependencyTriggered($question->dependencies, $key, $results)) {
						$question->triggered = true;
					}
				}

				if($question->triggered) {
					$question->result = false;
					foreach($results as $result) {
						if($result->question_id == $question->question_id) {
							$question->result = true;
						}
					}

					if(!$question->result && $question->required == 1) {
						$pageComplete[$page->page_id] = false;
					}				
				}
			}
		}

		return $pageComplete;
	}

	/**
	 * Check if a dependency has been triggered
	 *
	 * @param [type] $dependencies
	 * @param [type] $key
	 * @param [type] $results
	 * @return void
	 */
	public function dependencyTriggered($dependencies, $key, $results) {
		$dependencyTriggered = false;
		$triggered = array();
		$comparatorTrigger = array();


		foreach($dependencies as $dependency) {
			foreach($results as $result) {
				if($dependency->answer_id === $result->answer_id) {				
					switch($result->answer_type) {
						case 'range':
						case 'percent':
							if($result->arbitrary_value >= $dependency->range_min && $result->arbitrary_value <= $dependency->range_max) {
								$triggered[$dependency->answer_2_question_id] = true;
							}
							break;

						default:
							$triggered[$dependency->answer_2_question_id] = true;
							break;
					}
				}
			}
		}

		switch($dependencies[$key]->comparator) {
			case 'AND':	 	
			 				foreach($dependencies as $key=>$val) {
								if($val->comparator === 'AND') {
									$comparatorTrigger[$val->answer_2_question_id] = isset($triggered[$val->answer_2_question_id]) ? $triggered[$val->answer_2_question_id] : false;
								}
							}
							$dependencyTriggered = in_array(false,$comparatorTrigger) ? false : true;
							break;

			default: 
			case 'OR': 		
							$dependencyTriggered = isset($triggered[$dependencies[$key]->answer_2_question_id]) ? $triggered[$dependencies[$key]->answer_2_question_id] : false;
							break;
		}

		return $dependencyTriggered;
	}

	/**
	 * Get the display status of a page
	 *
	 * @param [type] $pages
	 * @param [type] $results
	 * @return void
	 */
	public function getPageDisplayStatus($pages, $results) {
		$skipPage = array();

		foreach ($pages as $page) {
			$skipPage[$page->page_id] = true;

			if(!$page->enable_skipping) {
				$skipPage[$page->page_id] = false;
			} else {
				$questions = $this->getPageQuestions($page->page_id);
				foreach($questions as $question) {
					if(count($question->dependencies) <= 0) {
						$skipPage[$page->page_id] = false;
					} else {
						foreach($question->dependencies as $key=>$val) {
							if($this->dependencyTriggered($question->dependencies, $key, $results)) {
								$skipPage[$page->page_id] = false;
							}
						}
					}
				}
			}
		}

		return $skipPage;
	}
}

?>