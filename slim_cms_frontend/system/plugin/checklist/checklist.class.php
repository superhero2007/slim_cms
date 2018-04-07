<?php
class checklist extends plugin {
	private $clientChecklist;
	private $ghg;
	
	//New Auto Issue Assessment - Generic, Just pass the identifier as a hashed md5
	public function auto_issue_checklist() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		if(isset($_REQUEST['checklist_id'])) {
			$this->clientChecklist = new clientChecklist($this->db);
			$checklist_id = $this->clientChecklist->getChecklistIdByHash($_REQUEST['checklist_id']);
			if(is_null($checklist_id)) {
				$messageNode = $this->doc->lastChild->appendChild($this->doc->createElement('message'));
				$messageNode->setAttribute('message',"Invalid Identifier");
				return;
			}
			$client_checklist_id = $this->clientChecklist->autoIssueChecklist($checklist_id, $client_id, false);
			$params = $this->setParams();
			isset($params->base_url) ? header("location: " . $params->base_url . $client_checklist_id) . "/" : header('Location: /members/assessment-checklist/'.$client_checklist_id.'/');
			$messageNode = $this->doc->lastChild->appendChild($this->doc->createElement('message'));
			$messageNode->setAttribute('message',"Success. Entry added to your client account.");
			die();
		}
		else {
			return;
		}
	}
	
	//Creates a Free Mini Assessment
	public function freeOfficeAssessment() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(24, $client_id, true);
		die();
	}
	
	//Creates a Supply Chain sustainability Tracker Assessment
	public function issueSupplyChainSustainabilityAssessment() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(87, $client_id, true);
		die();
	}

	//Creates a Supply Chain sustainability Tracker Assessment
	public function issueSupplyChainAccreditationAssessment() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(92, $client_id, true);
		die();
	}
	
	//Creates a Retail Energy Efficiency Health Check
	public function retailEnergyEfficiencyHealthCheck() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(75, $client_id, true);
		die();
	}
	
	//Creates a Social Enterprise Awards Assessment
	public function socialEnterpriseAwardsCat1() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(77, $client_id, true);
		die();
	}

	//Creates a Social Enterprise Awards Assessment
	public function socialEnterpriseAwardsCat2() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(78, $client_id, true);
		die();
	}
	
	//Creates a Social Enterprise Awards Assessment
	public function socialEnterpriseAwardsCat3() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(79, $client_id, true);
		die();
	}
	
	//Creates a Social Enterprise Awards Assessment
	public function socialEnterpriseAwardsCat4() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(80, $client_id, true);
		die();
	}
	
	//Creates a Social Enterprise Awards Assessment
	public function socialEnterpriseAwardsCat5() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(81, $client_id, true);
		die();
	}
	
	//Creates a Social Enterprise Awards Assessment
	public function socialEnterpriseAwardsCat6() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(82, $client_id, true);
		die();
	}
	
	//Creates a GBC 2012 Client Survey Assessment Assessment
	public function issueGBC2012CSAssessment() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(68, $client_id, true);
		die();
	}
	
	//Creates a GHG Scope Assessment
	public function ghgProtocolScopeAssessment() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(42, $client_id, true);
		die();
	}
	
	//Creates a GHG Scope Assessment
	public function apcGhgProtocolScopeAssessment() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(70, $client_id, true);
		die();
	}
	
	//Creates a GHG Scope Assessment
	public function nraGhgProtocolScopeAssessment() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(76, $client_id, true);
		die();
	}
	
	//Creates a Free F&B Mini Assessment
	public function freeFoodAndBeverageAssessment() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(56, $client_id, true);
		die();
	}
	
	//Creates a Business Owner Feedback Form Assessment
	public function feedbackFormAssessment() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(65, $client_id, true);
		die();
	}
	
	//Creates a Free Staples Eco Health Check
	public function freeStaplesEcoHealthCheck() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(57, $client_id, true);
		die();
	}
	
	//Creates a Australia Post Bushfire Assessment
	public function freeAustraliaPostBushfireAssessment() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientChecklist->autoIssueChecklist(86, $client_id, true);
		die();
	}
	
	//Creates a demo version of the Office Assessment and sends the browser to the first page of the Demo assessment
	public function officeAssessmentDemo() {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`client_checklist` SET
				`checklist_id` = 1,
				`client_id` = %2$d,
				`name` = CONCAT("Office Assessment Demo - Expires ",DATE_FORMAT(DATE_ADD(NOW(),INTERVAL 1 MONTH),"%%e %%M %%Y")),
				`expires` = DATE_ADD(NOW(),INTERVAL 1 MONTH);
		',
			DB_PREFIX.'checklist',
			$client_id
		));
		$client_checklist_id = $this->db->insert_id;
		header('Location: /members/assessment-checklist/'.$client_checklist_id.'/');
		die();
	}
	
	//Creates a list of the clients assessments.  Breaks the display into completed and un completed assesments. Provides report
	//hyperlinks if the assessment is complete, otherwise a link to the current page in the assessment
	public function assessmentList() {
		//Added delete command for business owners 
	 	if(isset($_REQUEST['action']) && $_REQUEST['action'] == 'delete_assessment') {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`client_checklist`
				WHERE `client_checklist_id` = %2$d;
				DELETE FROM `%1$s`.`client_result`
				WHERE `client_checklist_id` = %2$d;
				DELETE FROM `%1$s`.`client_commitment`
				WHERE `client_checklist_id` = %2$d;
				DELETE FROM `%1$s`.`client_checklist_permission`
				WHERE `client_checklist_id` = %2$d;
				OPTIMIZE TABLE
					`%1$s`.`client_checklist`,
					`%1$s`.`client_result`,
					`%1$s`.`client_commitment`;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['client_checklist_id'])));
			header('Location: /members/');
		}
		
		//Added create command for child checklists 
	 	if(isset($_REQUEST['action']) && $_REQUEST['action'] == 'create_child_checklist') {
			if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
			$this->clientChecklist = new clientChecklist($this->db);
			//$child_checklist_id = $this->clientChecklist->autoIssueChecklist($_REQUEST['checklist_id'], $client_id, true);
			$child_checklist_id = $this->clientChecklist->duplicateClientChecklist($_REQUEST['client_checklist_id'],false,false);
			
			//Update the parent_2_child_checklist database
			$this->clientChecklist->insertParent2ChildChecklist($_REQUEST['client_checklist_id'], $child_checklist_id);
			$pageToken = '';
			
			//if the page_id is set, get the correct token and push the user to the correct page
			if(isset($_REQUEST['page_id'])) {
				$checklistPages = $this->clientChecklist->getChecklistPages($child_checklist_id);
				foreach($checklistPages as $checklistPage) {
					if($checklistPage->page_id == $_REQUEST['page_id']) {
						$pageToken = $checklistPage->token;
					}
				}
			}
			
			//Redirect to the new client checklist
			if($pageToken != '') {
				header('Location: /members/assessment-checklist/' . $child_checklist_id . '?p=' . $pageToken);
			}
			else {
				header('Location: /members/assessment-checklist/' . $child_checklist_id);
			}
		}
		
		//Added rename command for child checklists 
	 	if(isset($_REQUEST['action']) && $_REQUEST['action'] == 'rename_client_checklist') {
			if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;
			
			if(isset($_REQUEST['checklist_name']) && $_REQUEST['checklist_name'] != '') {
				$this->clientChecklist = new clientChecklist($this->db);
				$this->clientChecklist->renameClientChecklist($_REQUEST['client_checklist_id'], $_REQUEST['checklist_name']);
			}
			
			//header('Location: /members/');
		}
		
		$this->clientChecklist = new clientChecklist($this->db);
		$clientChecklists = $this->clientChecklist->getChecklists($this->session->get('cid'));
		
		$accessibleChecklists = $this->accessibleClientChecklists($clientChecklists);
		$grouped_assessments = array();
		foreach ($accessibleChecklists as $checklist) {	
		 	
			if(!in_array($checklist->checklist_id,$grouped_assessments) || $checklist->status != "Closed") {
				$checklistNode = $this->node->appendChild(
					$this->createNodeFromRecord('clientChecklist', $checklist,
						array(	'client_checklist_id', 'checklist_id', 'checklist', 'name', 'report_type', 'progress', 'initial_score',
								'current_score', 'created', 'completed', 'expires', 'last_modified', 'expires', 'company_name', 'department', 
								'status', 'hash', 'client_checklist_id_md5', 'assessment_certificate', 'scorable_assessment', 'downloadable_reports', 'audit', 'audit_required', 'expiry_date', 'exportable_actions', 'parent_checklist_id', 'display_in_list')
					)
				);
				
				if($checklist->report_type == "grouped") {
					$grouped_assessments[] = $checklist->checklist_id;
				}
				
				//Insert if this client checklist is a parent of a child client checklist
				$checklistNode->setAttribute('is_parent',$this->clientChecklist->isClientChecklistAParent($checklist->client_checklist_id));
							
				foreach ($clientChecklistPermissions as $permission) {
					if ($permission->client_checklist_id == $checklist->client_checklist_id) {
						$checklistNode->appendChild($permission->xmlRenderer()->toNode());
					}
				}
				
				if($checklist->expires && strtotime($checklist->expires) <= time()) {
					$checklistNode->setAttribute('expired','yes');
				}
				else {
					$checklistNode->setAttribute('expired','no');
				}
				
				//Check to see if the current clientChecklist has any multi-site children
				if($this->clientChecklist->isClientChecklistMultiSite($checklist->client_checklist_id)) {
					$checklistNode->setAttribute('multi_site','yes');
				}
				else {
					$checklistNode->setAttribute('multi_site','no');
				}
			}
		}
	}
	
	
	/* Plugin methods, push the request through to the getClientChecklits function */
	
	public function incompleteAssessments () {
		$this->getClientChecklists('incomplete');
		
		return;
	}
	
	public function completeAssessments () {
		$this->getClientChecklists('complete');
		
		return;
	}

	//Returns all clientChecklists Accessible to the current user
	public function getAllEntries() {
		$params = $this->setParams();

		//Get the contact from the session
		$contact = clientContact::stGetClientContactById($this->db, $GLOBALS['core']->session->get('uid'));
		if(empty($contact)) {
			return;
		}

		if(isset($params->columns)) {
			$columnsNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('columns'));
			$columns = explode(',',$params->columns);
			foreach($columns as $column) {
				$columnNode = $columnsNode->appendChild($GLOBALS['core']->doc->createElement('column'));
				$columnNode->setAttribute('name',trim($column));
			}
		}

		//Get the clientChecklist Identifiers that are accessible to the user
		$this->clientChecklist = new clientChecklist($this->db);
		$accessibleClientChecklists = $this->clientChecklist->getAccessibleClientChecklists($contact, isset($params->dashboard) ? $params->dashboard : true);

		$query = sprintf('
			SELECT
				`client_checklist`.`client_checklist_id`,
				`client_checklist`.`created`,
				`client_checklist`.`completed`,
				`client_checklist`.`client_id`,
				`client_checklist`.`date_range_start`,
				`client_checklist`.`date_range_finish`,
				`client_checklist`.`current_score`,
				`client_checklist`.`name` AS `name`,
				`client_checklist_status`.`status`,
				`client`.`company_name`,
	            CONCAT(ROUND(IFNULL((`current_score` * 100),0)),\"%%\") AS `score_round_formatted`,
	            IF(`client_checklist`.`completed` IS NULL, \"No\",\"Yes\") AS `finished`,
	            DATE_FORMAT(`client_checklist`.`date_range_start`, \"%%Y-%%m-%%d\") as `date_range_start_pretty`,
	            DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%Y-%%m-%%d\") as `date_range_finish_pretty`,
	            DATE_FORMAT(`client_checklist`.`date_range_start`, \"%%Y\") as `date_range_start_year`,
	            DATE_FORMAT(`client_checklist`.`date_range_start`, \"%%M\") as `date_range_start_month`,
	            DATE_FORMAT(`client_checklist`.`date_range_start`, \"%%M %%Y\") as `date_range_start_month_year`,
	            DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%Y\") as `date_range_finish_year`,
	            DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%M\") as `date_range_finish_month`,
	            DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%M %%Y\") as `date_range_finish_month_year`
			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%2$s`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
			LEFT JOIN `%1$s`.`checklist` ON `client_checklist`.`checklist_id` = `checklist`.`checklist_id`
			LEFT JOIN `%1$s`.`client_checklist_status` ON `client_checklist`.`status` = `client_checklist_status`.`client_checklist_status_id`
			WHERE `client`.`company_name` IS NOT NULL
			AND `client_checklist`.`client_checklist_id` IN (%3$s)
			' . (isset($params->checklists) ? ' AND client_checklist.checklist_id IN(%4$s) ' : '') . '
			GROUP BY `client_checklist`.`client_checklist_id`
			ORDER BY `client_checklist`.`created` DESC
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			$this->db->escape_string(implode(',',$accessibleClientChecklists)),
			$this->db->escape_string(isset($params->checklists) ? $params->checklists : null)
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);

		return;	
	}

	private function getDashboardAccessibleClientChecklists($clientChecklists = array()) {
		$contact = clientContact::stGetClientContactById($this->db, $GLOBALS['core']->session->get('uid'));
		
		if(isset($contact->dashboard_group_id) && isset($contact->dashboard_role_id)) {
			$this->clientChecklist = new clientChecklist($this->db);
			$dashboardAccessibleClientChecklists = $this->clientChecklist->getChecklistsByClientChecklistArray(resultFilter::accessible_client_checklists($this->db, $contact));
			$clientChecklists = !empty($dashboardAccessibleClientChecklists) ? $dashboardAccessibleClientChecklists : $clientChecklists;
		}

		return $clientChecklists;
	}
	
	/* Gets all of the checklists available */
	public function getClientChecklists($status) {
		$this->clientChecklist = new clientChecklist($this->db);
		$clientChecklists = $this->clientChecklist->getChecklists($this->session->get('cid'));
		$accessibleChecklists = $this->accessibleClientChecklists($clientChecklists);
		
		$grouped_assessments = array();
		foreach ($accessibleChecklists as $checklist) {	
		
			//Check to see the status and what we are going to render
			if(($status == 'incomplete' && $checklist->status == 'incomplete') OR ($status == 'complete' && $checklist->status != 'incomplete') OR $status === 'all' OR $status =='all-accessible') {
		 	
				if(!in_array($checklist->checklist_id,$grouped_assessments) || $checklist->status != "Closed") {
					$checklistNode = $this->node->appendChild($this->createNodeFromRecord('clientChecklist', $checklist, array_keys((array)$checklist)));
				
					if($checklist->report_type == "grouped") {
						$grouped_assessments[] = $checklist->checklist_id;
					}
				
					//Insert if this client checklist is a parent of a child client checklist
					$checklistNode->setAttribute('is_parent',$this->clientChecklist->isClientChecklistAParent($checklist->client_checklist_id));
				
					if($checklist->expires && strtotime($checklist->expires) <= time()) {
						$checklistNode->setAttribute('expired','yes');
					}
					else {
						$checklistNode->setAttribute('expired','no');
					}
				
					//Check to see if the current clientChecklist has any multi-site children
					if($this->clientChecklist->isClientChecklistMultiSite($checklist->client_checklist_id)) {
						$checklistNode->setAttribute('multi_site','yes');
					}
					else {
						$checklistNode->setAttribute('multi_site','no');
					}

					//Set Dates
					$checklistNode->setAttribute('date_range_start_pretty',!is_null($checklist->date_range_start) ? date_format(date_create($checklist->date_range_start), "Y-m-d") : null);
					$checklistNode->setAttribute('date_range_finish_pretty',!is_null($checklist->date_range_finish) ? date_format(date_create($checklist->date_range_finish), "Y-m-d") : null);
					$checklistNode->setAttribute('date_range_start_year',!is_null($checklist->date_range_start) ? date_format(date_create($checklist->date_range_start), "Y") : null);
					$checklistNode->setAttribute('date_range_start_month',!is_null($checklist->date_range_start) ? date_format(date_create($checklist->date_range_start), "F") : null);
					$checklistNode->setAttribute('date_range_finish_year',!is_null($checklist->date_range_finish) ? date_format(date_create($checklist->date_range_finish), "Y") : null);
					$checklistNode->setAttribute('date_range_finish_month',!is_null($checklist->date_range_finish) ? date_format(date_create($checklist->date_range_finish), "F") : null);

				}
			}
		}
	}
	
	public function exportActions() {
	 	$clientChecklist = new clientChecklist($this->db);
	 	$checklist = $clientChecklist->getChecklistByClientChecklistId($this->extractClientChecklistIdFromUrl());
	 	$report = $clientChecklist->getReport($this->extractClientChecklistIdFromUrl());
	 	
	 	//Set the header row for the CSV document
		$header = array('Action ID','Action Title','Summary', 'Proposed Measure', 'Comments', 'Weighting');
		$csv[0] = '"'.implode('","',$header).'"';
		
		//Calculate the total assessment points
		$points = 0;
		foreach($report->report_sections as $reportSectionPoints){
			$points = $points + $reportSectionPoints->points;
		}
		
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
	
	// Assessment Checklist
	public function assessment() {
		$start =  microtime(true);	
		$clientChecklistId = $this->extractClientChecklistIdFromUrl();
		if ($checklist = $this->accessibleClientChecklistId($clientChecklistId)) {
			// Permission to access the checklist.
			
			if ($checklist->status == 'Open' || $this->node->getAttribute('is_checklist_admin') == 'yes') {
				// The checklist is incomplete or the the user is a checklist admin.
				$this->loadChecklist($checklist);
			}
			else {
				// The checklist is complete, redirect to report.
				header("Location: /members/assessment-report/".$clientChecklistId);
				die();
			}
		} 
		else {
			// No permission to access the checklist.
			header("Location: /");
			die();
		}
		//Send load time feedback
		$this->pluginLoadTime($start, microtime(true));	
	
		return;
	}
	
	// Assessment Checklist Answers (all pages & answers displayed together).
	public function assessmentAnswers() {
		$clientChecklistId = $this->extractClientChecklistIdFromUrl();
		if ($checklist = $this->accessibleClientChecklistId($clientChecklistId)) {
			// Permission to access the checklist.	
			$this->loadChecklistWithAllPages($checklist);
		}

		if (isset($_REQUEST['pdf'])) {
			// Display answers to questions.
			$answersFop = new fopRenderer('assessment-answer', @$this->doc);
			$answersFop->sendFile("AssessmentAnswers-".clientUtils::makeNameFilenameSafe($checklist->company_name).".pdf");
		}
	}
	
	//Assessment Metrics - Metrics are optional in most assessments therefore there may not be any to display.
	public function assessmentMetrics() {
		$clientChecklistId = $this->extractClientChecklistIdFromUrl();
		if ($checklist = $this->accessibleClientChecklistId($clientChecklistId)) {
			// Permission to access the checklist.	
			$this->loadChecklistWithAllPages($checklist);
		}
	}
	
	//Checks to see if the client has permissions to access the report and if it is completed calls the  function
	public function report() {
		$clientChecklistId = $this->extractClientChecklistIdFromUrl();
		if ($checklist = $this->accessibleClientChecklistId($clientChecklistId)) {
			// Permission to access the checklist.
			if ($checklist->status == "Closed") {
				$this->loadReport($checklist);
			}
			else {
				// The checklist is incomplete, redirect to the checklist.
				header("Location: /members/assessment-checklist/".$clientChecklistId);
				die();
			}
		}
		else {
			// No permission to access the checklist.
			header("Location: /");
			die();
		}
	}
	
	//Checks to see if the client has permissions to access the report and if it is completed calls the  function
	//Report-v2
	public function reportv2() {

		$clientChecklistId = $this->extractClientChecklistIdFromUrl();
		if ($checklist = $this->accessibleClientChecklistId($clientChecklistId)) {
			// Permission to access the checklist.
			if ($checklist->status == "Closed") {
				$this->loadReport($checklist);
			}
			else {
				// The checklist is incomplete, redirect to the checklist.
				header("Location: /members/assessment-checklist/".$clientChecklistId);
				die();
			}
		}
		else {
			// No permission to access the checklist.
			header("Location: /");
			die();
		}
	}
	
	//Loads the client checklist with all pages 
	private function loadChecklistWithAllPages($clientChecklist) {
		$this->node->setAttribute('mode','checklist');
		$checklistNode = $this->node->appendChild($this->createNodeFromRecord('clientChecklist', $clientChecklist, array(
								'client_checklist_id', 'checklist_id', 'client_id', 'checklist', 'name', 
								'company_name', 'status', 'company_logo', 'logo')));
		if($clientChecklist->expires && strtotime($clientChecklist->expires) <= time()) {
			$checklistNode->setAttribute('expired','yes');
		}
		$pages		= $this->clientChecklist->getChecklistPages($clientChecklist->client_checklist_id);
		$results	= $this->clientChecklist->getClientResults($clientChecklist->client_checklist_id);
		foreach ($pages as $page_no => $page) {
			list($pageNode,$error) = $this->setChecklistContent($clientChecklist->client_checklist_id, $page, $results);
			
			$metricGroups = $this->clientChecklist->getPageMetricGroups($page->page_id, $clientChecklist->client_checklist_id);
			foreach($metricGroups as $metricGroup) {
				$metricGroupNode = $pageNode->appendChild(
					$this->createNodeFromRecord('metricGroup', $metricGroup, 
						array('metric_group_id', 'name', 'description', 'sequence', 'metric_group_type_id'))
				);
				foreach($metricGroup->metrics as $metric) {
					$metricNode = $metricGroupNode->appendChild(
						$this->createNodeFromRecord('metric', $metric, 
							array('metric_id', 'metric_unit_type_id', 'metric', 'value', 'months', 'max_duration'))
					);
					foreach($metric->metric_unit_types as $metricUnitType) {
						$metricUnitTypeNode = $metricNode->appendChild(
							$this->createNodeFromRecord('metricUnitType', $metricUnitType, 
								array('metric_unit_type_id', 'metric_unit_type', 'description'))
						);
					}
					if(isset($_POST['metric'][$metric->metric_id]['value']) && $_POST['metric'][$metric->metric_id]['value'] != '') {
						if(!is_numeric($_POST['metric'][$metric->metric_id]['value'])) {
							$metricNode->setAttribute('error','If '.$metric->metric.' is set it must be a number');
							$error = true;
							continue;
						}
						$this->clientChecklist->storeClientMetric(
							$clientChecklist->client_checklist_id,
							$metric->metric_id,
							$_POST['metric'][$metric->metric_id]['metric_unit_type_id'],
							$_POST['metric'][$metric->metric_id]['value'],
							$_POST['metric'][$metric->metric_id]['months']
						);
						$metricNode->setAttribute('value',$_POST['metric'][$metric->metric_id]['value']);
						$metricNode->setAttribute('months',$_POST['metric'][$metric->metric_id]['months']);
					}
				}
			}

			$pageNode->setAttribute('page_no', $page_no);
			$checklistNode->appendChild($pageNode);	
		}				
	}

	private function isQuestionTriggered($question, $results) {
		$questionTriggered = false;
		if(count($question->dependencies) <= 0) {
			$questionTriggered = true;
		} else {
			foreach($question->dependencies as $key=>$val) {
				if($this->clientChecklist->dependencyTriggered($question->dependencies, $key, $results)) {
					$questionTriggered = true;
				}
			}	
		}

		return $questionTriggered;
	}
	
	//Loads the clients current checklist
	private function loadChecklist($clientChecklist) {
		$pages				= $this->clientChecklist->getChecklistPages($clientChecklist->client_checklist_id);
		$results			= $this->clientChecklist->getClientResults($clientChecklist->client_checklist_id);
		$clientSiteResults 	= $this->clientChecklist->getClientSiteResults($clientChecklist->client_checklist_id);
		
		//Merge the results and the clientSiteResults arrays into a single results array
		$results			= array_merge($clientSiteResults, $results);
		$pageComplete 		= $this->clientChecklist->getChecklistPagesCompleted($pages, $results);
		$skipPages			= $this->clientChecklist->getPageDisplayStatus($pages, $results);
		$pageProgress		= $this->clientChecklist->getClientChecklistProgress($pages, $pageComplete, $skipPages, $clientChecklist->completed);
		$page_no			= 0;
		
		//Inject the clientChecklist page progress into the clientChecklist object
		$clientChecklist->pageProgress = $pageProgress;
		
		//Create the clientChecklistNode
		$this->node->setAttribute('mode','checklist');
		$checklistNode = $this->node->appendChild($this->createNodeFromRecord('clientChecklist', $clientChecklist, array(
								'client_checklist_id', 'checklist_id', 'client_id', 'checklist', 'name', 
								'company_name', 'status', 'pageProgress')));
		if($clientChecklist->expires && strtotime($clientChecklist->expires) <= time()) {
			$checklistNode->setAttribute('expired','yes');
		}
		
		foreach ($pages as $page) {
		 	$page->skipPage = ($skipPages[$page->page_id] ? '1' : '0');
			$page->complete = ($pageComplete[$page->page_id] ? 'yes' : 'no');
		 	
			$checklistNode->appendChild($this->createNodeFromRecord('checklistPage', $page, array('page_id', 'sequence', 'token', 'title', 'complete', 'skipPage', 'display_in_table', 'table_columns')));
		}	
		
		for($i=0;$i<count($pages);$i++) {	
			if(count($results) && $results[0]->page_id == $pages[$i]->page_id) {
				$page_no = $i;
				break;
			}
		}
		for($i=0;$i<count($pages);$i++) {
			$pages[$i]->token = md5($i);
			if(isset($_REQUEST['p']) && $pages[$i]->token == $_REQUEST['p']) {
				$page_no = $i;
			}
		}
		$skipPage = true;
		while($skipPage) {
			list($pageNode,$error) = $this->setChecklistContent($clientChecklist->client_checklist_id,$pages[$page_no],$results);
			if($pages[$page_no]->enable_skipping && $pageNode->getElementsByTagName('question')->length <= 0) {
				if(isset($_REQUEST['back'])) {
					$page_no--;
				} else {
					$page_no++;
				}
			} else {
				$skipPage = false;
				break;
			}
		}
		
		$metricGroups = $this->clientChecklist->getPageMetricGroups($pages[$page_no]->page_id,$clientChecklist->client_checklist_id);
		foreach($metricGroups as $metricGroup) {
			$metricGroupNode = $pageNode->appendChild(
				$this->createNodeFromRecord('metricGroup', $metricGroup, 
					array('metric_group_id', 'name', 'description', 'metric_group_type_id'))
			);
			foreach($metricGroup->metrics as $metric) {
				$metricNode = $metricGroupNode->appendChild(
					$this->createNodeFromRecord('metric', $metric, 
						array('metric_id', 'metric_unit_type_id', 'metric', 'value', 'months', 'max_duration'))
				);
				foreach($metric->metric_unit_types as $metricUnitType) {
					$metricUnitTypeNode = $metricNode->appendChild(
						$this->createNodeFromRecord('metricUnitType', $metricUnitType, 
							array('metric_unit_type_id', 'metric_unit_type', 'description'))
					);
				}
				if(isset($_POST['metric'][$metric->metric_id]['value']) && $_POST['metric'][$metric->metric_id]['value'] != '') {
					if(!is_numeric($_POST['metric'][$metric->metric_id]['value'])) {
						$metricNode->setAttribute('error','If '.$metric->metric.' is set it must be a number');
						$error = true;
						continue;
					}
					$this->clientChecklist->storeClientMetric(
						$clientChecklist->client_checklist_id,
						$metric->metric_id,
						$_POST['metric'][$metric->metric_id]['metric_unit_type_id'],
						$_POST['metric'][$metric->metric_id]['value'],
						$_POST['metric'][$metric->metric_id]['months']
					);
					$metricNode->setAttribute('value',$_POST['metric'][$metric->metric_id]['value']);
					$metricNode->setAttribute('months',$_POST['metric'][$metric->metric_id]['months']);
				}
			}
		}
		
		//Get the pageSection and PageSection pages data and write it to XML Nodes
		$pageSectionPages = $this->clientChecklist->getChecklistPageSectionPages($clientChecklist->checklist_id);
		$completedPage = true;
		$currentPageSectionId = NULL;
		$pageSectionFirstPage = array();
		foreach($pageSectionPages as $pageSectionPage) {			
			if($pageSectionPage->page_id == $pages[$page_no]->page_id) {
				$completedPage = false;
				$currentPageSectionId = $pageSectionPage->page_section_id;
			}
			
			if(!isset($pageSectionFirstPage[$pageSectionPage->page_section_id])) {
				$pageSectionFirstPage[$pageSectionPage->page_section_id] = $pageSectionPage->page_id;
			}
			
			$pageSectionPageNode = $checklistNode->appendChild(
				$this->createNodeFromRecord(
					'pageSectionPage',
					$pageSectionPage,
					array(
						'page_section_2_page_id',
						'page_section_id',
						'page_id',
						'sequence',
						'section_title',
						'page_title'
					)
				)
			);
									
			$pageSectionPageNode->setAttribute('completed_page', $completedPage ? 'yes' : 'no');
		}
		
		$pageSections = $this->clientChecklist->getChecklistPageSections($clientChecklist->checklist_id);
		$completedPageSection = true;
		foreach($pageSections as $pageSection) {
			if($pageSection->page_section_id == $currentPageSectionId) {
				$completedPageSection = false;
			}
			
			$pageSectionNode = $checklistNode->appendChild(
				$this->createNodeFromRecord(
					'pageSection',
					$pageSection,
					array(
						'page_section_id',
						'checklist_id',
						'sequence',
						'title'
					)
				)
			);
			
			$pageSectionNode->setAttribute('completed_page_section', $completedPageSection ? 'yes' : 'no');
			$pageSectionNode->setAttribute('first_page_id', $pageSectionFirstPage[$pageSection->page_section_id]);
			
			$allPagesComplete = true;
			foreach($pageSectionPages as $pageSectionPage) {
				if($pageSectionPage->page_section_id == $pageSection->page_section_id && !$pageComplete[$pageSectionPage->page_id]) {
					$allPagesComplete = false;
				}
			}
			$pageSectionNode->setAttribute('allPagesComplete', $allPagesComplete ? 'yes' : 'no');
		}
		
		$pageNode->setAttribute('page_no',$page_no);
		//Added new node for notes field
		$pageNode->setAttribute('show_notes_field',$pages[$page_no]->show_notes_field);
		$pageNode->setAttribute('number_of_pages',count($pages));
		$pageNode->setAttribute('display_page_number', $page_no + 1);
		
		$progress = ($page_no == 0 ? 0 : ceil(($page_no+1) / count($pages) * 100));
		$checklistNode->setAttribute('progress',$progress); 
		$checklistNode->appendChild($pageNode);
		if(isset($_POST['note'])) {
			$this->clientChecklist->storeClientPageNote(
				$clientChecklist->client_checklist_id,
				$pages[$page_no]->page_id,
				$_POST['note']
			);
		}
		
		if(!$error && isset($_REQUEST['action'])) {
			// If this is not the user's own checklist and the checklist has been completed, then we don't
			// want to set it back to being incomplete.
			$complete = false;
			if ($clientChecklist->status == 'report' && $this->node->getAttribute('own_checklist') == 'no') {
				$complete = true;
				
				// Also recalculate total scores.
				// 		getReport updates the totals in client_checklist and adds a new log entry 
				//		to the client_checklist_score table.
				$report = $this->clientChecklist->getReport($clientChecklist->client_checklist_id);
			}

			//Check for a single page assessment
			if(isset($_REQUEST['single-page']) && $_REQUEST['single-page'] == 'true') {
				//No errors, single-page is set
				$this->clientChecklist->updateChecklistProgress(
					$clientChecklist->client_checklist_id,
					100, // Single page, set to 100 percent complete
					true // Always set to complete if this stage is met.
				);

				//redirect the page
				$client_checklist_id_path = $clientChecklist->client_checklist_id . "/";
				$url = strtok($_SERVER["REQUEST_URI"],'?') . $client_checklist_id_path;
				$url = str_replace($client_checklist_id_path, '', $url);
				header("Location: " . $url);
				die();
			}
			
			$path = $this->navBase().'/'.$clientChecklist->client_checklist_id.'/';
			switch($_REQUEST['action']) {
				case 'save': {
					$this->clientChecklist->updateChecklistProgress(
						$clientChecklist->client_checklist_id,
						$pageProgress,
						$complete
					);
					header('Location: '.$this->navBase().'/?saved');
					die();
				}
				
				case 'saveProgress': {
					$this->clientChecklist->updateChecklistProgress(
						$clientChecklist->client_checklist_id,
						$pageProgress,
						$complete
					);
					header('Location: '.$path.'?forward&p='.$pages[$page_no]->token);
					die();
				}
				case 'first': {
					$this->clientChecklist->updateChecklistProgress(
						$clientChecklist->client_checklist_id,
						$pageProgress,
						$complete
					);
					header('Location: '.$path.'?p='.$pages[0]->token);
					die();
				}
				case 'next': {
					$this->clientChecklist->updateChecklistProgress(
						$clientChecklist->client_checklist_id,
						$pageProgress,
						$complete
					);
					
					if(array_key_exists($page_no+1,$pages)) {
						header('Location: '.$path.'?forward&p='.$pages[$page_no+1]->token);
					}
					else {
						header('Location: '.$path.'?forward&p='.$pages[$page_no]->token);
					}

					die();
				}
				case 'previous': {
					$this->clientChecklist->updateChecklistProgress(
						$clientChecklist->client_checklist_id,
						$pageProgress,
						$complete
					);
					
					if(array_key_exists($page_no-1,$pages)) {
						header('Location: '.$path.'?back&p='.$pages[$page_no-1]->token);
					}
					else {
						header('Location: '.$path.'?back&p='.$pages[$page_no]->token);
					}
					die();
				}
				case 'submit': {
					if($pageProgress >= 100) {
						$this->clientChecklist->updateChecklistProgress(
							$clientChecklist->client_checklist_id,
							$pageProgress,
							true // Always set to complete if this stage is met.
						);
						
						$recipients = $this->clientChecklist->getEmailAnswerReportRecipients($clientChecklist->checklist_id);
						
						if(!is_null($recipients)) {
							$this->clientChecklist->emailAnswerReport($clientChecklist->client_checklist_id, $recipients);
						}
						
						//Count the number of client checklists - if this is the first client_checklist - update the client_type_id
						if(count($this->clientChecklist->getChecklists($clientChecklist->client_id)) <= 1){
							$this->clientChecklist->assignClientTypeId($clientChecklist->client_checklist_id);	
						}
						
						//Now check if the client_checklist is a multi_site, if so, create new client_checklist and auto fill parent content along with the client_site content
						if($this->clientChecklist->isClientChecklistMultiSite($clientChecklist->client_checklist_id)) {
							$childClientChecklistIdArray = $this->clientChecklist->createMultiSiteChildrenClientChecklist($clientChecklist->client_checklist_id);
							
							// Set the script time out to indefinate for looping
							set_time_limit(0);
							
							//For each of the client checklist id's created, load the report to get the scoring completed
							foreach($childClientChecklistIdArray as $clientChecklistId) {
								$checklist = $this->accessibleClientChecklistId($clientChecklistId);
								$this->loadReport($checklist);
							}
							
							// Change the timeout back to 30 seconds after completed.
							set_time_limit(30);
						}
						
						header('Location: /members/assessment-report/'.$clientChecklist->client_checklist_id);
					}
					header('Location: '.$path.'?back&p='.$pages[$page_no]->token);
					die();
				}
			}
		}
		
		$clientSites = $this->clientChecklist->getClientChecklistSites($clientChecklist->client_checklist_id);
		//List all of the client checklist sites
		foreach ($clientSites as $site) {
			$checklistNode->appendChild($this->createNodeFromRecord('clientSite', $site, array('client_site_id', 'client_checklist_id', 'site_name', 'staff_number', 'office_space', 'office_space_unit')));
		}
		
		//Add a value to the clientChecklist for multisite
		$checklistNode->setAttribute('siteCount',count($clientSites));
		
		return;
	}
		
	//Sets the content (Questions, Answers) for the current client checklist and page
	private function setChecklistContent($client_checklist_id,$page,$results) {

		$error = false;
		$pageNode = $this->createNodeFromRecord('page', $page, array('page_id', 'title', 'note'));
		$pageNode->appendChild($this->createHTMLNode($page->content,'content'));
		$questions = $this->clientChecklist->getPageQuestions($page->page_id);
		$clientSites = $this->clientChecklist->getClientChecklistSites($client_checklist_id);
		
		foreach($questions as $question) {
			$skipQuestion = (count($question->dependencies) > 0 ? true : false);
			$questionNode = $this->doc->createElement('question');
			$clientSiteTriggers = array();
			$triggered_question = 0;
			
			//Loop through all results and see what questions are triggered
			foreach($results as $result) {
				
				foreach($question->dependencies as $dependancy) {
				
					if(!$skipQuestion) {
						$skipQuestion = false;
						break;
					}
					
					elseif($result->question_id == $dependancy->question_id && $result->answer_id == $dependancy->answer_id) {
						
						//Mark this question as triggered
						$triggered_question = "1";
						
						//Check to see if there are other client_sites that have triggered this result
						foreach($results as $clientSiteResult) {
						
							if($clientSiteResult->question_id == $dependancy->question_id && $clientSiteResult->answer_id == $dependancy->answer_id) {
								//We have a match for the question_id and answer_id, now check for a client_site_id
								if(isset($clientSiteResult->client_site_id)) {
									$clientSiteTriggers[] = $clientSiteResult->client_site_id;
								}
								else {
									//else, the triggering question is not multi-site, trigger all sites
									foreach($clientSites as $clientSite) {
										$clientSiteTriggers[] = $clientSite->client_site_id;
									}
								}
							}
						}
						
						//We have a dependency triggered therefore we need to display the question
						if($result->answer_type == 'percent' || $result->answer_type == 'range') {
							//We need to test and see if the range is valid now
							if(($result->arbitrary_value >= $dependancy->range_min) && ($result->arbitrary_value <= $dependancy->range_max)) {
								$skipQuestion = false;
							}
						}
						else {
							$skipQuestion = false;
						}
						
					} else {
						$skipQuestion = true;
					}
				}
				
				//Get all of the previous clientChecklist results and render to XML - If this question is set in a POST var don't render this result
				if($result->question_id == $question->question_id) {
				 	if(!isset($_POST['question'][$question->question_id])) {
						if($question->multi_site && !empty($clientSites)) {
							$resultNode = $questionNode->appendChild(
							$this->createNodeFromRecord('result', $result, 
								array('client_result_id', 'answer_id', 'timestamp', 'client_site_id'),
								array('value' => $result->arbitrary_value))
							);
						} else {
							$resultNode = $questionNode->appendChild(
							$this->createNodeFromRecord('result', $result, 
								array('client_result_id', 'answer_id', 'timestamp'),
								array('value' => $result->arbitrary_value))
							);
						}
					}
				}
			}


			if($skipQuestion) { continue; }
			$questionNode->setAttribute('question_id',$question->question_id);
			$questionNode->setAttribute('multiple',$question->multiple_answer ? 'yes' : 'no');
			$questionNode->setAttribute('question',$question->question);
			$questionNode->setAttribute('tip',$question->tip);
			$questionNode->SetAttribute('required',$question->required ? 'yes' : 'no');
			$questionNode->setAttribute('sequence',$question->sequence);
			$questionNode->setAttribute('multi_site',$question->multi_site ? 'yes' : 'no');
			$questionNode->setAttribute('triggered_question',$triggered_question);

			if(isset($_POST['action'])) {

				//Error checking to make sure that all required questions are answered
				//First we check to see if this is multi_site, if so check all applicable sites
				if($question->multi_site) {
					if($_POST['action'] == 'next' && $question->required) {


						//Now check for client_site_triggers
						if(count($question->answers) == 1) {
							$answer_id = $question->answers[0]->answer_id;

							if(!empty($clientSiteTriggers)) {
								foreach($clientSiteTriggers as $clientSite) {
									if(!isset($_REQUEST['question'][$question->question_id][$answer_id][$clientSite]) || $_REQUEST['question'][$question->question_id][$answer_id][$clientSite] == '') {
										$error = true;
										$questionNode->setAttribute('error','This question is mandatory');
									}
								}
							} else {
								foreach($clientSites as $clientSite) {
									if(!isset($_REQUEST['question'][$question->question_id][$answer_id][$clientSite->client_site_id]) || $_REQUEST['question'][$question->question_id][$answer_id][$clientSite->client_site_id] == '') {
										$error = true;
										$questionNode->setAttribute('error','This question is mandatory');
									}
								}
							}
						} else {
							if(!empty($clientSiteTriggers)) {
								foreach($clientSiteTriggers as $clientSite) {
									if(!isset($_REQUEST['question'][$question->question_id][$clientSite])) {
										$error = true;
										$questionNode->setAttribute('error','This question is mandatory');
									}
								}
							} else {
								foreach($clientSites as $clientSite) {
									if(!isset($_REQUEST['question'][$question->question_id][$clientSite->client_site_id])) {
										$error = true;
										$questionNode->setAttribute('error','This question is mandatory');
									}
								}
							}
						}

					}
				} else {
					if($_POST['action'] == 'next' && $question->required && !isset($_POST['question'][$question->question_id])) {
						$error = true;
						$questionNode->setAttribute('error','This question is mandatory');
					}
				}

				//Delete the result for the current question, for the current client_checklist
				$this->clientChecklist->deleteClientResult(
					$client_checklist_id,
					$question->question_id
				);
				
				//Delete the client site result, for the current question, for the current client_checklist
				$this->clientChecklist->deleteClientSiteResult(
					$client_checklist_id,
					$question->question_id
				);				
				
			}
						
			//Now list the client_site_id's to know which have bee triggered
			foreach($clientSiteTriggers as $clientSiteTrigger) {
				$csTriggerNode = $questionNode->appendChild($this->doc->createElement('client_site_trigger'));
				$csTriggerNode->setAttribute('client_site_id',$clientSiteTrigger);
			}
			
			foreach($question->answers as $answer) {

				$answerNode = $questionNode->appendChild($this->doc->createElement('answer'));
				$answerNode->setAttribute('answer_id',$answer->answer_id);
				$answerNode->setAttribute('type',$answer->answer_type);
				$answerNode->setAttribute('string',$answer->string);


				switch($answer->answer_type) {
					case 'checkbox-other':
					case 'checkbox':
					case 'drop-down-list': {

						$answerNode->setAttribute('string',$answer->string);
						$other_value = (isset($_POST['question-other'][$answer->answer_id]) ? $_POST['question-other'][$answer->answer_id] : null);

						if($question->multiple_answer) {
							//Mutlisite First, then regular single sites
							if($question->multi_site && !empty($clientSites)) {
								foreach($clientSites as $clientSite) {
									$other_value = (isset($_POST['question-other'][$clientSite->client_site_id][$answer->answer_id]) ? $_POST['question-other'][$clientSite->client_site_id][$answer->answer_id] : null);
									if(@in_array($answer->answer_id,$_POST['question'][$question->question_id][$clientSite->client_site_id])) {
										$this->clientChecklist->storeClientSiteResult(
											$client_checklist_id,
											$clientSite->client_site_id,
											$question->question_id,
											$answer->answer_id,
											$other_value
										);
										$resultNode = $questionNode->appendChild($this->doc->createElement('result'));
										$resultNode->setAttribute('client_site_id',$clientSite->client_site_id);
										$resultNode->setAttribute('answer_id',$answer->answer_id);
										$resultNode->setAttribute('value',$other_value);
									}
								}
							} else {
								if(@in_array($answer->answer_id,$_POST['question'][$question->question_id])) {
									$this->clientChecklist->storeClientResult(
										$client_checklist_id,
										$question->question_id,
										$answer->answer_id,
										$other_value
									);
									$resultNode = $questionNode->appendChild($this->doc->createElement('result'));
									$resultNode->setAttribute('answer_id',$answer->answer_id);
									$resultNode->setAttribute('value',$other_value);
								}
							}
						} else {
							//Mutlisite First, then regular single sites
							if($question->multi_site && !empty($clientSites)) {
								foreach($clientSites as $clientSite) {
									$other_value = (isset($_POST['question-other'][$clientSite->client_site_id][$answer->answer_id]) ? $_POST['question-other'][$clientSite->client_site_id][$answer->answer_id] : null);
									if(isset($_POST['question'][$question->question_id][$clientSite->client_site_id]) && $_POST['question'][$question->question_id][$clientSite->client_site_id] == $answer->answer_id) {
										$this->clientChecklist->storeClientSiteResult(
											$client_checklist_id,
											$clientSite->client_site_id,
											$question->question_id,
											$answer->answer_id,
											$other_value
										);
										$resultNode = $questionNode->appendChild($this->doc->createElement('result'));
										$resultNode->setAttribute('client_site_id',$clientSite->client_site_id);
										$resultNode->setAttribute('answer_id',$answer->answer_id);
										$resultNode->setAttribute('value',$other_value);
									}
								}
							} else {

								if(isset($_POST['question'][$question->question_id]) && $_POST['question'][$question->question_id] == $answer->answer_id) {								
									if($answer->answer_type == 'checkbox-other') { //Check for an empty string in the other field before posting the result
										if(strlen(trim($other_value)) > 0) {
											$this->clientChecklist->storeClientResult(
												$client_checklist_id,
												$question->question_id,
												$answer->answer_id,
												$other_value
											);
										}

									} else {
										$this->clientChecklist->storeClientResult(
											$client_checklist_id,
											$question->question_id,
											$answer->answer_id,
											$other_value
										);
									}

									$resultNode = $questionNode->appendChild($this->doc->createElement('result'));
									$resultNode->setAttribute('answer_id',$answer->answer_id);
									$resultNode->setAttribute('value',$other_value);
								}
							}							
						}

						// Check for checkbox with nothing selected
						if(isset($_POST['action']) && $_POST['action'] == 'next' && $question->required && !$question->multiple_answer && $answer->answer_type == 'checkbox' && !isset($_POST['question'][$question->question_id])) {
							$error = true;
							$questionNode->setAttribute('error','This question is mandatory');
						}
						
						// Check for drop down with nothing selected
						if(isset($_POST['action']) && $_POST['action'] == 'next' && $question->required && !$question->multiple_answer && $answer->answer_type == 'drop-down-list' && $_POST['question'][$question->question_id] == '') {
							$error = true;
							$questionNode->setAttribute('error','This question is mandatory');
						}

						// Check for checkbox-other where selected but other field left empty
						if(isset($_POST['action']) && $_POST['action'] == 'next' && $question->required && !$question->multiple_answer && $answer->answer_type == 'checkbox-other' && isset($_POST['question'][$question->question_id]) && $_POST['question'][$question->question_id] == $answer->answer_id && strlen(trim($other_value)) == 0) {
							$error = true;
							$questionNode->setAttribute('error','Additional comments text field is mandatory');
						}

						break;
					}
					case 'range': {
						$answerNode->setAttribute('range_min',$answer->range_min);
						$answerNode->setAttribute('range_max',$answer->range_max);
						$answerNode->setAttribute('range_step',$answer->range_step);
						$answerNode->setAttribute('range_unit',$answer->range_unit);
					}
					case 'textarea': {
						$answerNode->setAttribute('number_of_rows',$answer->number_of_rows);
					}
					//Multi Site Release
					case 'multi-site-query': {
						if(isset($_POST['site'])) {
							//Now take the remaining client_site_id and client_checklist_id and check for any that need to be deleted
							$this->clientChecklist->deleteClientChecklistSites($_REQUEST['site']['client_site_id'], $client_checklist_id);
							
							$site_index = 0;
							foreach($_POST['site']['name'] as $name) {
								if($_POST['site']['name'][$site_index] != '') {
										$this->clientChecklist->storeClientSite(
											(isset($_REQUEST['site']['client_site_id'][$site_index]) && $_REQUEST['site']['client_site_id'][$site_index] != "") ? $_REQUEST['site']['client_site_id'][$site_index] : null,
											$client_checklist_id,
											$_REQUEST['site']['name'][$site_index],
											$_REQUEST['site']['staff'][$site_index],
											$_REQUEST['site']['space'][$site_index],
											$_REQUEST['site']['unit'][$site_index]
										);
									
								}
								$site_index++;
							}
						}
					}
					default: {
						if(isset($_POST['question'][$question->question_id][$answer->answer_id])) {
							//Allowing multiple answers for non checkbox answer_types
							if($question->multiple_answer) {
								if(isset($_POST['action']) && $_POST['action'] == 'next' && $question->required) {
									$one_result = false;
									foreach($question->answers as $check_answer) {
										if($_POST['question'][$question->question_id][$check_answer->answer_id] != '') {
											$one_result = true;
										}
									}
									if(!$one_result) {
										$error = true;
										$questionNode->setAttribute('error','This question is mandatory');
									}

								}
							}
							elseif($_POST['question'][$question->question_id][$answer->answer_id] == '') {
								if(isset($_POST['action']) && $_POST['action'] == 'next' && $question->required) {
									$error = true;
									$questionNode->setAttribute('error','This question is mandatory');
								}
							} else {
								switch($answer->answer_type) {
									case 'int': {
										if($question->multi_site && !empty($clientSites)) {
											foreach($clientSites as $clientSite) {
												if(array_key_exists($clientSite->client_site_id,$_POST['question'][$question->question_id][$answer->answer_id])) {
													if(filter_var($_POST['question'][$question->question_id][$answer->answer_id][$clientSite->client_site_id],FILTER_VALIDATE_INT) === false) {
														$error = true;
														$questionNode->setAttribute('error','Your answer must be a whole number');
													}
												}
											}
										}
										else {
											if(filter_var($_POST['question'][$question->question_id][$answer->answer_id],FILTER_VALIDATE_INT) === false) {
												$error = true;
												$questionNode->setAttribute('error','Your answer must be a whole number');
											}
										}
										break;
									}
									case 'float': {
										if($question->multi_site && !empty($clientSites)) {
											foreach($clientSites as $clientSite) {
												if(array_key_exists($clientSite->client_site_id,$_POST['question'][$question->question_id][$answer->answer_id])) {
													if(filter_var($_POST['question'][$question->question_id][$answer->answer_id][$clientSite->client_site_id],FILTER_VALIDATE_FLOAT) === false) {
														$error = true;
														$questionNode->setAttribute('error','Your answer must be a whole number');
													}
												}
											}
										}
										else {
											if(filter_var($_POST['question'][$question->question_id][$answer->answer_id],FILTER_VALIDATE_FLOAT) === false) {
												$error = true;
												$questionNode->setAttribute('error','Your answer must be a number');
											}
										}
										break;
									}
									case 'email': {
										if($question->multi_site && !empty($clientSites)) {
											foreach($clientSites as $clientSite) {
												if(array_key_exists($clientSite->client_site_id,$_POST['question'][$question->question_id][$answer->answer_id])) {
													if(!filter_var($_POST['question'][$question->question_id][$answer->answer_id][$clientSite->client_site_id],FILTER_VALIDATE_EMAIL)) {
														$error = true;
														$questionNode->setAttribute('error','Your answer must be a whole number');
													}
												}
											}
										}
										else {
											if(!filter_var($_POST['question'][$question->question_id][$answer->answer_id],FILTER_VALIDATE_EMAIL)) {
												$error = true;
												$questionNode->setAttribute('error','Your answer must be valid email address');
											}
										}
										break;
									}
									case 'url': {
										if($question->multi_site && !empty($clientSites)) {
											foreach($clientSites as $clientSite) {
												if(array_key_exists($clientSite->client_site_id,$_POST['question'][$question->question_id][$answer->answer_id])) {
													if(!filter_var($_POST['question'][$question->question_id][$answer->answer_id][$clientSite->client_site_id],FILTER_VALIDATE_URL,FILTER_FLAG_HOST_REQUIRED)) {
														$error = true;
														$questionNode->setAttribute('error','Your answer must be a whole number');
													}
												}
											}
										}
										else {
											if(!filter_var($_POST['question'][$question->question_id][$answer->answer_id],FILTER_VALIDATE_URL,FILTER_FLAG_HOST_REQUIRED)) {
												$error = true;
												$questionNode->setAttribute('error','Your answer must be vaild website url');
											}
										}
										break;
									}
								}
							}
							
							//If the question is multisite, store the client site result for each site in a separate table for client sites
							if($question->multi_site && !empty($clientSites)) {
								foreach($clientSites as $clientSite) {
									if(array_key_exists($clientSite->client_site_id,$_POST['question'][$question->question_id][$answer->answer_id])) {
										$this->clientChecklist->storeClientSiteResult(
											$client_checklist_id,
											$clientSite->client_site_id,
											$question->question_id,
											$answer->answer_id,
											$_POST['question'][$question->question_id][$answer->answer_id][$clientSite->client_site_id]
										);
									}
								}
							} else {
							
								//Fill the clientResult table with the client result
								$this->clientChecklist->storeClientResult(
									$client_checklist_id,
									$question->question_id,
									$answer->answer_id,
									$_POST['question'][$question->question_id][$answer->answer_id]
								);
							} 													
							
							//Mutlisite First, then regular single sites
							if($question->multi_site && !empty($clientSites)) {
								foreach($clientSites as $clientSite) {
									if(array_key_exists($clientSite->client_site_id,$_POST['question'][$question->question_id][$answer->answer_id])) {
										$resultNode = $questionNode->appendChild($this->doc->createElement('result'));
										$resultNode->setAttribute('answer_id',$answer->answer_id);
										$resultNode->setAttribute('client_site_id',$clientSite->client_site_id);
										$resultNode->setAttribute('value',$_POST['question'][$question->question_id][$answer->answer_id][$clientSite->client_site_id]);
									}
								}
							} else {
								$resultNode = $questionNode->appendChild($this->doc->createElement('result'));
								$resultNode->setAttribute('answer_id',$answer->answer_id);
								$resultNode->setAttribute('value',$_POST['question'][$question->question_id][$answer->answer_id]);
							}
						} elseif(isset($_POST['action']) && $_POST['action'] == 'next' && $question->required) {
							$error = true;
							$questionNode->setAttribute('error','This question is mandatory');
						}
						
						break;
					}
				}
			}
			$pageNode->appendChild($questionNode);
		}
		return(array($pageNode,$error));
	}
	
	// Web-based version of the certificate. Displays a HTML version of the vertificate to the screen.
	public function loadCertificate() {
		if(($client_checklist_id_hash = @$GLOBALS['core']->pathSet[2]) != false) {
			$this->clientChecklist = new clientChecklist($this->db);
			$clientChecklist = $this->clientChecklist->getChecklistByClientChecklistIdHash($client_checklist_id_hash);
			if ($clientChecklist) {
				$this->loadReport($clientChecklist);
			}	
		}
		return;
		
	}
	
	// PDF version of the certificate. Renders a PDF certification via the FOP renderer
	public function loadCertificatePdf() {
		if(($client_checklist_id_hash = @$GLOBALS['core']->pathSet[2]) != false) {
			$this->clientChecklist = new clientChecklist($this->db);
			$clientChecklist = $this->clientChecklist->getChecklistByClientChecklistIdHash($client_checklist_id_hash);
			
			//Workaround for problem hash codes - if the above is null try and get the clientChecklist by id
			if(is_null($clientChecklist)) {
				$clientChecklist = $this->accessibleClientChecklistId($this->extractClientChecklistIdFromUrl());
			}
			
			if ($clientChecklist) {
				// Generate the same XML tree as would be used for the HTML display.
				$clientReport = $this->loadReport($clientChecklist);

				// This assessment has reached a level of certification.
				if ($clientReport->certified_level) {			 
					$certificateFop = new fopRenderer('certificate', @$this->doc);
					$certificateFop->sendFile("Certificate-".clientUtils::makeNameFilenameSafe($clientChecklist->company_name).".pdf");
				}				
			}
		}
		return;
	}
		
	//Renders a PDF report of the client assessment via the FOP renderer
	public function loadReportPdf() {
	
		if ($checklist = $this->accessibleClientChecklistId($this->extractClientChecklistIdFromUrl())) {
			// Generate the same XML tree as would be used for the HTML display.
			$this->loadReport($checklist);
			$this->clientChecklist = new clientChecklist($this->db);
			$report_template = $this->clientChecklist->getReportTemplateByClientChecklistId($this->extractClientChecklistIdFromUrl());
			
			// report_type request variable will either be:
			//		summary (default): No measures or commitments or 0-value actions.
			//    full:  Complete report
			$reportType = "summary";
			$filenamePart = "Summary";
			if (isset($_REQUEST['report_type']) && $_REQUEST['report_type'] == "full") {
				$reportType = "full";
				$filenamePart = "Complete";
			}
			$this->node->setAttribute("report_type", $reportType);
			
			//Test to see if the post back has been registered for the actions CSV
			if(isset($_REQUEST['action']) && $_REQUEST['action'] = 'export-actions'){
				$this->exportActions();
				return;
			}
			
			// Render the assessment report.	
			if (!isset($_REQUEST['debug'])) {
				// Display analysed report.
				
				//Get access to the FOP Class - Takes two parametres - the xsl file name, the XSL to put into the document
				//To change the report template:
				//Add a new folder the the FOP Directory eg 'assessment', Inside this folder have 'assessment.xsl' and any images for the report
				$assessmentFop = new fopRenderer($report_template, @$this->doc);
				
				//If the merge file value is not set, do the default report download to screen, otherwise create a temp file and merge PDF files
				//$pdf_filename = "Assessment".$filenamePart."-".clientUtils::makeNameFilenameSafe($checklist->company_name).".pdf";
				$pdf_filename = clientUtils::makeNameFilenameSafe(($checklist->report_name != '' ? $checklist->report_name : $checklist->name))."_".clientUtils::makeNameFilenameSafe($checklist->company_name).".pdf";
				
				if(!isset($_REQUEST['mergefile'])) {
					$assessmentFop->sendFile($pdf_filename);
				}
				else {
					$tempFile = PATH_PDF_MERGE . "/" . $checklist->client_checklist_id . ".pdf";
					$pdf = $assessmentFop->render();
					$assessmentFop->save_file($pdf, $tempFile);
					$assessmentFop->mergeFilesAndReturn(array("temp" => $checklist->client_checklist_id . ".pdf","template" => $_REQUEST['mergefile']),$pdf_filename);
				}
			}
		}
		return;
	}
	
		//Renders a PDF report of the client assessment via the FOP renderer
	public function loadGroupedReportPdf() {
		if ($checklist = $this->extractClientChecklistIdFromUrl()) {
			// Generate the same XML tree as would be used for the HTML display.
			$clientModel = new client($this->db);
			$client = $clientModel->getClientById($this->session->get('cid'));
			$myClientChecklist = new clientChecklist($this->db);
			
			if($_REQUEST['group_type'] == 'grouped') {
				$groupedClientChecklists = $myClientChecklist->getGroupedClientChecklists($checklist, $client->client_id);
			}
			elseif($_REQUEST['group_type'] == 'parent_grouped') {
				$groupedClientChecklists = $myClientChecklist->getParentGroupedClientChecklists($_REQUEST['client_checklist_id'], $client->client_id);
			}
			
			foreach($groupedClientChecklists as $clientChecklist) {
				$this->loadReport($this->accessibleClientChecklistId($clientChecklist));
			}
			
			$report_template = $myClientChecklist->getReportTemplateByClientChecklistId($groupedClientChecklists[0]);
			
			// report_type request variable will either be:
			//		summary (default): No measures or commitments or 0-value actions.
			//    full:  Complete report
			$reportType = "summary";
			$filenamePart = "Summary";
			if (isset($_REQUEST['report_type']) && $_REQUEST['report_type'] == "full") {
				$reportType = "full";
				$filenamePart = "Complete";
			}
			$this->node->setAttribute("report_type", $reportType);
			
			// Render the assessment report.	
			if (!isset($_REQUEST['debug'])) {
				$assessmentFop = new fopRenderer($report_template, @$this->doc); 
				$assessmentFop->sendFile("Assessment-".$filenamePart."-".clientUtils::makeNameFilenameSafe($client->company_name).".pdf");
			}
		}
		return;
	}
	
	private function loadReport($clientChecklist) {
		$params = $this->setParams();
	 	//Get access to the GHG Calculations Class
	 	$this->ghg = new greenHouseGasCalculations($this->db);

	 	//Call any checklist followup
		$this->checklistFollowup($clientChecklist);
	 
	 	//Get the client object
		$clientModel = new client($this->db);
		$client = $clientModel->getClientById($this->session->get('cid'));
	 
		if(isset($_POST['action']) && $_POST['action'] == 'reEvaluateReport' && isset($_POST['commitment']) && is_array($_POST['commitment'])) {
			if(isset($_REQUEST['current-action-id'])) {
				$this->clientChecklist->reEvaluateReport($clientChecklist->client_checklist_id,$_POST['commitment']);
			}
		}

		//Client Action Note
		if(isset($_POST['client_action_note'])) {
			$this->clientChecklist->setClientActionNotes($clientChecklist->client_checklist_id,$_POST['client_action_note']);
		}

		if(isset($_POST['linkafter']) && $_POST['linkafter'] == '#certification-level-table') {
			$auditDocument = new auditDocument($this->db);
			$audit_items = 0;
			foreach($_POST['audit-file'] as $key=>$val) {
				$auditDocument->deleteAuditEvidence($clientChecklist->client_checklist_id, $key);
				if(!empty($val)) {
					$auditDocument->addAuditEvidence($clientChecklist->client_checklist_id, $key, $val);
					$audit_items++;
				}
			}

			$certification_level = $auditDocument->getCertificationLevel($_POST['certification_level_id']);
			if(isset($certification_level->audit_item_count) && $audit_items >= $certification_level->audit_item_count) {
				if(isset($_POST['audit_id'])) {
					$auditDocument->resubmitAudit($_POST['audit_id']);
				} else {
					$auditDocument->submitAudit($clientChecklist->client_checklist_id, $clientChecklist->current_score, $certification_level->certification_level_id, $GLOBALS['core']->session->get('uid'));
				}
			}
		}
		
		$clientReport = $this->clientChecklist->getReport($clientChecklist->client_checklist_id);
		$this->node->setAttribute('mode','report');

		//Set values for clientChecklist node
		$clientChecklist = $this->setClientChecklistDateFormats($clientChecklist);
		$clientChecklist->initial_score = ceil($clientChecklist->initial_score * 100);
		$clientChecklist->current_score = ceil($clientChecklist->current_score * 100);
		$clientChecklist->certified_date = strftime("%Y-%m-%dT%H:%M:%S", strtotime($clientChecklist->certified_date));
		$clientChecklist->certified_date_long = strftime("%d %B %Y", strtotime($clientChecklist->certified_date));
		$clientChecklist->created_date_long = strftime("%d %B %Y", strtotime($clientChecklist->created));
		$clientChecklist->certified_date_long_url = str_replace(" ","-",strftime("%d %B %Y", strtotime($clientChecklist->certified_date)));
		$clientChecklist->is_parent = $this->clientChecklist->isClientChecklistAParent($clientChecklist->client_checklist_id);

		$reportNode = $this->node->appendChild($this->createNodeFromRecord('report', $clientChecklist, array_keys((array)$clientChecklist)));
		
		// Set certification level
		$reportNode->setAttribute('certified_level',strtolower(isset($clientReport->certified_level->name) ? $clientReport->certified_level->name : ''));
		$availableAuditItems = count($clientReport->audits) + count($clientReport->commitmentAudits);
		foreach($clientReport->certificationLevels as $certificationLevel) {
			$certificationLevel->required_audit_items_reached = $certificationLevel->audit_item_count <= $availableAuditItems ? 1 : 0;
			$certificationLevel->required_score_reached = $certificationLevel->target <= $clientChecklist->current_score ? 1 : 0;
			$reportNode->appendChild($this->createNodeFromRecord('certificationLevel', $certificationLevel, array_keys((array)$certificationLevel)));
		}
		
		foreach($clientReport->genericCertificationLevels as $genericCertificationLevel) {
			$reportNode->appendChild($this->createNodeFromRecord('genericCertificationLevel', $genericCertificationLevel, array_keys((array)$genericCertificationLevel)));
		}

		//Get all of the report sections for the client_checklist and add it to the XML output
		foreach($clientReport->reportSections as $reportSection) {
			//Insert Report Section safe title replacing ampersand with xhtml character
			$reportSection->safe_title = str_replace('&','%26',$reportSection->title);
		
			$reportSectionNode = $reportNode->appendChild($this->createNodeFromRecord('reportSection', $reportSection, array_keys((array)$reportSection)));
			$reportSectionNode->appendChild($this->createHTMLNode($reportSection->content,'content'));
		}
		foreach($clientReport->actions as $action) {
			$actionNode = $reportNode->appendChild($this->createNodeFromRecord('action', $action, array_keys((array)$action)));
			$actionNode->appendChild($this->createHTMLNode($action->proposed_measure,'proposed_measure'));
			$actionNode->appendChild($this->createHTMLNode($action->comments,'comments'));
		}
		foreach($clientReport->commitments as $commitment) {
			$actionNode = $reportNode->appendChild($this->createNodeFromRecord('commitment', $commitment, array_keys((array)$commitment)));
		}
		foreach($clientReport->resources as $resource) {
			$resourceNode = $reportNode->appendChild($this->createNodeFromRecord('resource', $resource, array_keys((array)$resource)));
		}

		//Get the client action notes
		$clientActionNotes = $this->clientChecklist->getClientActionNotes($clientChecklist->client_checklist_id);
		foreach($clientActionNotes as $note) {
			$clientActionNoteNode = $reportNode->appendChild($this->createNodeFromRecord('client_action_note', $note, array_keys((array)$note)));
		}		

		//Get the resource_type
		$resource_types = $this->clientChecklist->get_resource_types();

		foreach($resource_types as $resource_type) {
			$resourceTypeNode = $reportNode->appendChild($this->createNodeFromRecord('resource_type', $resource_type, array_keys((array)$resource_type)));
			$resourceTypeNode->appendChild($this->createHTMLNode($resource_type->icon,'icon'));
		}

		/*
		foreach($clientReport->commitment_fields as $commitmentField) {
			$commitmentFieldNode = $reportNode->appendChild($this->createNodeFromRecord('commitmentField', $commitmentField, array_keys((array)$commitmentField)));
		}*/

		foreach($clientReport->checklistPageSections as $checklistPageSection) {
			$checklistPageSectionNode = $reportNode->appendChild($this->createNodeFromRecord('checklistPageSection', $checklistPageSection, array_keys((array)$checklistPageSection)));
		}

		foreach($clientReport->checklistPages as $checklistPage) {
			$checklistPageNode = $reportNode->appendChild($this->createNodeFromRecord('checklistPage', $checklistPage, array_keys((array)$checklistPage)));
		}

		foreach($clientReport->questionAnswers as $questionAnswer) {
			$questionAnswerNode = $reportNode->appendChild($this->doc->createElement('questionAnswer'));
			$questionAnswerNode->setAttribute('question_id',$questionAnswer[0]->question_id);
			$questionAnswerNode->setAttribute('question',$questionAnswer[0]->question);
			$questionAnswerNode->setAttribute('multi_site',$questionAnswer[0]->multi_site);
			$questionAnswerNode->setAttribute('page_id',$questionAnswer[0]->page_id);
			$questionAnswerNode->setAttribute('page_section_id',$questionAnswer[0]->page_section_id);
			$questionAnswerNode->setAttribute('sequence',$questionAnswer[0]->sequence);
			$questionAnswerNode->setAttribute('export_key',$questionAnswer[0]->export_key);
			$questionAnswerNode->setAttribute('tip',$questionAnswer[0]->tip);
			$questionAnswerNode->setAttribute('show_in_analytics',$questionAnswer[0]->show_in_analytics);
			
			
			//Get the triggered Question Identifiers
			foreach($clientReport->triggeredQuestions as $triggeredQuestion) {
				if($triggeredQuestion[0]->question_id == $questionAnswer[0]->question_id) {
					$questionAnswerNode->setAttribute('triggered_by_question_id',$triggeredQuestion[0]->parent_question_id);
					$questionAnswerNode->setAttribute('triggered_by_answer_id',$triggeredQuestion[0]->answer_id);
				}
			}

			for($i=0;$i<count($questionAnswer);$i++) {
				$answerNode = $questionAnswerNode->appendChild($this->createNodeFromRecord('answer', $questionAnswer[$i], array_keys((array)$questionAnswer[$i])));
			}
		}

		/**
		* Previous Responses
		*/
		if(isset($params->previous_results) && $params->previous_results == true) {
			$previousClientChecklistsNode = $reportNode->appendChild($this->doc->createElement('previousClientChecklists'));
			$previousClientChecklists = $this->clientChecklist->getPreviousClientChecklists($clientChecklist->client_checklist_id);
			foreach($previousClientChecklists as $previousClientChecklist) {
				$previousClientChecklist->year = date('Y', strtotime($previousClientChecklist->date_range_finish));
				$previousClientChecklistNode = $previousClientChecklistsNode->appendChild($this->createNodeFromRecord('clientChecklist', $previousClientChecklist, array_keys((array)$previousClientChecklist)));

				//Get Results
				$results = $this->clientChecklist->pubGetClientResultsWithAnswers($previousClientChecklist->client_checklist_id);
				foreach($results as $result) {
					$previousClientChecklistNode->appendChild($this->createNodeFromRecord('clientResult', $result, array_keys((array)$result)));
				}
			}
		}

		/**
		* Benchmarks
		*/
		if(isset($params->benchmarks) && $params->benchmarks == true) {
			$benchmarksNode = $reportNode->appendChild($this->doc->createElement('benchmarks'));
			
			$answers = $this->clientChecklist->getChecklistAnswers($clientChecklist->checklist_id);
			$results = $this->clientChecklist->getChecklistBenchmarkResults($clientChecklist->checklist_id);

			foreach($answers as $answer) {
				$answerNode = $benchmarksNode->appendChild($this->createNodeFromRecord('answer', $answer, array_keys((array)$answer)));
				foreach($results as $result) {
					if($result->answer_id == $answer->answer_id) {
						$answerNode->appendChild($this->createNodeFromRecord('result', $result, array_keys((array)$result)));
					}
				}
			}
		}

		$additionalValues = $this->clientChecklist->getClientChecklistAdditionalValues($clientChecklist->client_checklist_id);
		if(count($additionalValues) > 0) {
			$additionalValuesNode = $reportNode->appendChild($GLOBALS['core']->doc->createElement('additionalValues'));
			foreach($additionalValues as $additionalValue) {
				$additionalValueNode = $additionalValuesNode->appendChild($this->createNodeFromRecord('additionalValue', $additionalValue, array_keys((array)$additionalValue)));
			}
		}
		
		//Get all confirmations
		foreach($clientReport->confirmations as $confirmation) {
			$confirmationNode = $reportNode->appendChild($this->createNodeFromRecord('confirmation', $confirmation, array_keys((array)$confirmation)));
		}
		
		// Get all of the audit questions
		foreach($clientReport->audits as $audit) {
			$audit->question = strip_tags($audit->question);
			$reportNode->appendChild($this->createNodeFromRecord('audit', $audit, array_keys((array)$audit)));
		}
		
		// Get all of the commitmentAudit questions
		foreach($clientReport->commitmentAudits as $commitmentAudit) {
		 	$unique = true;
		 	foreach($clientReport->audits as $audit) {
				if($commitmentAudit->question_id == $audit->question_id)
				{
					$unique = false;
				}
			}
			
			if($unique)
			{
				$auditNode = $reportNode->appendChild($this->createNodeFromRecord('audit', $commitmentAudit, array_keys((array)$commitmentAudit)));
			}
		}

		foreach($clientReport->auditEvidence as $auditEvidence) {
			$auditEvidenceNode = $reportNode->appendChild($this->createNodeFromRecord('auditEvidence', $auditEvidence, array_keys((array)$auditEvidence)));
		}

		$client_audits = $this->clientChecklist->getClientChecklistAuditDetails($clientChecklist->client_checklist_id);
		foreach($client_audits as $client_audit) {
			$reportNode->appendChild($this->createNodeFromRecord('client_audit', $client_audit, array_keys((array)$client_audit)));
		}
		
		// Get all of the metric groups that the client has completed
		foreach($clientReport->metricGroups as $metricGroup) {
		 	$metricGroupNode = $reportNode->appendChild($this->createNodeFromRecord('metricGroup', $metricGroup, array_keys((array)$metricGroup)));
		 	
		 	//Test to see if it is a GHG Assessment
		 	if($metricGroup->name == "Scope 1" || $metricGroup->name == "Scope 2" || $metricGroup->name == "Scope 3") {
				//Attach each metric to the parent metric group
				foreach($clientReport->clientMetrics as $clientMetric) {
				 	if($clientMetric->metric_group_id == $metricGroup->metric_group_id){
				 	 //Get the GHG Calculation
				 	 $clientMetric = $this->ghg->calculateGhgScore($clientMetric, $clientReport, $clientChecklist->client_checklist_id);
						$clientMetricNode = $metricGroupNode->appendChild($this->createNodeFromRecord('clientMetric', $clientMetric, array_keys((array)$clientMetric)));
					}
				}
			}
		 	//Test to see if it is a GHG Assessment - Type 2 with NRA and the like
		 	elseif($metricGroup->metric_group_type_id = '2') {
				//Attach each metric to the parent metric group
				foreach($clientReport->clientMetrics as $clientMetric) {
				 	if($clientMetric->metric_group_id == $metricGroup->metric_group_id){
				 	 //Get the GHG Calculation
				 	 $clientMetric = $this->ghg->calculateGhgScore($clientMetric, $clientReport, $clientChecklist->client_checklist_id);
					$clientMetricNode = $metricGroupNode->appendChild($this->createNodeFromRecord('clientMetric', $clientMetric, array_keys((array)$clientMetric)));
					}
				}
			}			
			
			else {
			
				//Attach each metric to the parent metric group
				foreach($clientReport->clientMetrics as $clientMetric) {
				 	if($clientMetric->metric_group_id == $metricGroup->metric_group_id){
						$clientMetricNode = $metricGroupNode->appendChild($this->createNodeFromRecord('clientMetric', $clientMetric, array_keys((array)$clientMetric)));
					}
				}
			}
		}
		
		//Get the list of action_owners
		foreach($clientReport->action_owner as $owner) {
			$ownerNode = $reportNode->appendChild($this->createNodeFromRecord('actionOwner', $owner, array_keys((array)$owner)));
		}
		
		//Get the list of owner_2_action
		foreach($clientReport->owner_2_action as $action_owner) {
			$actionOwnerNode = $reportNode->appendChild($this->createNodeFromRecord('owner2Action', $action_owner, array_keys((array)$action_owners)));
		}
		
		//Get the list of client sites
		foreach($clientReport->client_sites as $client_site) {
			$clientSiteNode = $reportNode->appendChild($this->createNodeFromRecord('clientSite', $client_site, array_keys((array)$client_site)));
			
			//Now get the current_score and overall_score for the current client_site
			$childClientChecklist = $this->accessibleClientChecklistId($client_site->child_client_checklist_id);
			$clientSiteNode->setAttribute('initial_score',$childClientChecklist->initial_score);
			$clientSiteNode->setAttribute('current_score',$childClientChecklist->current_score);
			
		}
		
		//Now set the report content for the childClientChecklist for multi-site
		$multiSiteChildClientChecklist = $this->clientChecklist->getMultiSiteChildChecklistDetails($clientChecklist->client_checklist_id);
		foreach($multiSiteChildClientChecklist as $msClientChecklist) {
			$clientChecklistClientSiteNode = $reportNode->appendChild($this->createNodeFromRecord('currentClientSite', $msClientChecklist, array_keys((array)$msClientChecklist)));
		}

		//GHG
		$ghg = new ghg($this->db);
		$emissions = $ghg->getEmissions($clientChecklist->client_checklist_id, 'object');
		foreach($emissions as $emission) {
			$emissionNode = $reportNode->appendChild($this->createNodeFromRecord('emission', $emission, array_keys((array)$emission)));
		}
		
		//Return the completed client report
		return $clientReport;
	}
	
	// Last URL-part should be the checklist ID.
	private function extractClientChecklistIdFromUrl() {
		return @$GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) - 1];
	}
	
	// Return permissions this user has for the passed in $clientChecklistId.
	// Return: clientChecklist if user can access checklist (inserts attribute into plugin
	// node too if admin).
	// NOTE: Loads and returns checklist.
	private function accessibleClientChecklistId($clientChecklistId) {
		$session = $this->session;
		$db = $this->db;
		$this->clientChecklist = new clientChecklist($db);
		$contactModel = new clientContact($db);
		$clientModel = new client($db);
		
		$contact = $contactModel->getClientContactById($session->get('uid'));
		$client = $clientModel->getClientById($session->get('cid'));
		$checklist = $this->clientChecklist->getChecklistByClientChecklistId($clientChecklistId);
		
		//Check to see if the report overide is set in the url
		if(isset($_REQUEST['permission']) && $_REQUEST['permission'] == "true") {
			return $checklist;
		}
		
		if ($contact) {
			$permissions = $this->canAccessClientChecklist($checklist, $client, $contact);
			$canAccess = $permissions[0];
			$isChecklistAdmin = $permissions[1];

			if (isset($checklist) && isset($clientChecklistPermissions) && isset($clientChecklistPermissions[$checklist->client_checklist_id])) {
				$clientChecklistPermissions[$checklist->client_checklist_id]->xmlRenderer()->injectAttributesInNode($this->node);
			}
				
			if ($client && $contact && $checklist) {
				$this->node->setAttribute('own_checklist', $client->client_id == $checklist->client_id ? 'yes' : 'no');
			}
		
			$this->node->setAttribute('can_access',	$canAccess ? 'yes' : 'no');
			$this->node->setAttribute('is_checklist_admin', $isChecklistAdmin ? 'yes' : 'no');
		
			return $canAccess ? $checklist : NULL;
		}
		else {
			return NULL;
		}
	}
	
	//Return the account type of the current user
	private function checkClientAccountType() {
		$db = $this->db;
		$clientModel = new client($db);
		$client = $clientModel->getClientById($session->get('cid'));
		
		return $client->client_type_id;
	}
	
	// From the passed in $clientChecklists, return only those that the current user
	// can access.
	// NOTE: Doesn't load checklists.
	private function accessibleClientChecklists($clientChecklists) {
		$session = $this->session;
		$db = $this->db;
		$this->clientChecklist = new clientChecklist($db);
		$contactModel = new clientContact($db);
		$clientModel = new client($db);

		$contact = $contactModel->getClientContactById($session->get('uid'));
		$client = $clientModel->getClientById($session->get('cid'));
		$accessibleChecklists = array();
		if ($contact) {	
			foreach ($clientChecklists as $checklist) {
				$permissions = $this->canAccessClientChecklist($checklist, $client, $contact);
				if ($permissions[0]) { // canAccess == true
					$accessibleChecklists[] = $checklist;
				}
			}
		}
		
		return $accessibleChecklists;
	}
	
	// Generic permissions function that returns an array containing [$canAccess, $isChecklistAdmin].
	private function canAccessClientChecklist($checklist, $client, $contact) {
		$clientModel = new client($this->db);

		$this->clientChecklist = new clientChecklist($this->db);
		
		$canAccess = false;
		$isChecklistAdmin = false;
		
		if ($client && $contact && $checklist) {
			
			// Client's checklist (only if client is admin for client).
			if ($checklist->client_id == $client->client_id && $contact->is_client_admin) {
				$canAccess = true;
			}		
		
			// Admin/Associates' client's checklist.
			elseif ($client->client_type_id == "2" || $client->client_type_id == "5" || $client->client_type_id == "16") {
				if (($checklist->client_parent_id == $client->client_id) || ($checklist->distributor_id == $client->client_id)) {
					$canAccess = true;
					$isChecklistAdmin = true;
				}
			}

			elseif(in_array($checklist->client_checklist_id, resultFilter::accessible_client_checklists($this->db, $contact))) {
				$canAccess = true;
				$isChecklistAdmin = true;
			}
			
			$this->node->setAttribute('own_checklist', $client->client_id == $checklist->client_id ? 'yes' : 'no');
		}
		elseif ($client && $checklist) {
			// No contact means legacy username/password and therefore client should be considered an admin client.
			$canAccess = true;
		}
		
		return array($canAccess, $isChecklistAdmin);
	}
	
	//Provides a audit interface for the client checklist
	//This area is used for the client to upload their documentary evidence after completing an assessment and reaching a certification level eg 70%
	public function audit()
	{
	 	$auditDoc = new auditDocument($this->db);
	 
	 	//Load the client checklist report to audit
	 	$clientChecklistId = $this->extractClientChecklistIdFromUrl();
		 	
	 	//First check if there is something to do
	 	if(isset($_REQUEST['audit-mode'])) {
			switch($_REQUEST['audit-mode']){
				case 'delete':
					$auditDoc->deleteAuditDocument($clientChecklistId, $_REQUEST['audit-id']);
					break;	
				case 'download':
					$auditDoc->downloadAuditDocument($_REQUEST['audit-document-id']);
					break;
				case 'submit':
					//Submit the audit for processing - and enter the current score
					$auditDoc->submitAudit($clientChecklistId, $_REQUEST['current_score'], $_REQUEST['client_contact_id']);
					
					//Send Notification to BV about the new audit
					$from 		= 'GreenBizCheck <info@greenbizcheck.com>';
					$company	= 'GreenBizCheck';
					
					$emailHeaders =
						"From: $from\r\n".
						"Reply-To: $from\r\n".
						"Return-Path: $from\r\n".
						"Organization: $company\r\n".
						"X-Priority: 3\r\n".
						"X-Mailer: PHP". phpversion() ."\r\n".
						"MIME-Version: 1.0\r\n".
						"Content-type: text/html; charset=UTF-8\r\n";

					$emailBody = 
						'<html>'.
						'<body>'.
						'<p>Hi Auditor,</p>'.
						'<p>' . @$GLOBALS['core']->plugin->clients->client->company_name . ' has reached ' . @$GLOBALS['core']->plugin->checklist->report->certification_level . ' certification and is now ready to be audited.</p>'.
						'<p><a href="http://www.greenbizcheck.com/audit/">Click here to access the GreenBizCheck Auditing System</a>.</p>'.
						'</body>'.
						'</html>';
					mail('gbc@au.bureauveritas.com','A New Client Checklist is ready for Auditing',$emailBody,$emailHeaders,'-finfo@greenbizcheck.com');
					//mail('td@greenbizcheck.com','A New Client Checklist is ready for Auditing',$emailBody,$emailHeaders);
					
					//Send Notification to the client of audit submit
					$clientEmail = new clientEmail($this->db);
					$clientEmail->send(
						@$GLOBALS['core']->plugin->clients->client->client_id,
						'Your Assessment has been submitted for Auditing',
						'bv_audit_request_notification',
						null,
						null,
						null,
						true
					);
					break;
					
				case 'resubmit':
					//Submit the audit for processing - and enter the current score
					$auditDoc->resubmitAudit($_REQUEST['audit_id']);
					
							//Send Notification to BV about the new audit
				$from 		= 'GreenBizCheck <info@greenbizcheck.com>';
				$company	= 'GreenBizCheck';
				
				$emailHeaders =
					"From: $from\r\n".
					"Reply-To: $from\r\n".
					"Return-Path: $from\r\n".
					"Organization: $company\r\n".
					"X-Priority: 3\r\n".
					"X-Mailer: PHP". phpversion() ."\r\n".
					"MIME-Version: 1.0\r\n".
					"Content-type: text/html; charset=UTF-8\r\n";

					$emailBody = 
						'<html>'.
						'<body>'.
						'<p>Hi Auditor,</p>'.
						'<p>' . @$GLOBALS['core']->plugin->clients->client->company_name . ' has reached resubmitted their checklist for auditing.</p>'.
						'<p><a href="http://www.greenbizcheck.com/audit/">Click here to access the GreenBizCheck Auditing System</a>.</p>'.
						'</body>'.
						'</html>';
					mail('gbc@au.bureauveritas.com','A New Client Checklist is ready for Auditing',$emailBody,$emailHeaders,'-finfo@greenbizcheck.com');
					//mail('td@greenbizcheck.com','A Client Checklist has been Resubmitted for Auditing',$emailBody,$emailHeaders);
					
					//Send Notification to the client of audit submit
					$clientEmail = new clientEmail($this->db);
					$clientEmail->send(
						@$GLOBALS['core']->plugin->clients->client->client_id,
						'Your Assessment has been resubmitted for Auditing',
						'bv_audit_request_notification',
						null,
						null,
						null,
						true
					);
					break;
					
				case 'delayed':
						$this->updateAuditStatus($_REQUEST['status'], $_REQUEST['audit_id']);
					break;
			}
		}
	 
		if ($checklist = $this->accessibleClientChecklistId($clientChecklistId)) {
			// Permission to access the checklist.
			if ($checklist->status == "Closed") {
				$this->loadReport($checklist);
			}
			else {
				// The checklist is incomplete, redirect to the checklist.
				header("Location: /members/assessment-checklist/".$clientChecklistId);
				die();
			}
		}
		else {
			// No permission to access the checklist.
			header("Location: /");
			die();
		}
		//Get the list of documents that have been uploaded for this client checklist
		$audit_documents = $this->clientChecklist->getAuditDocuments($clientChecklistId);
		foreach($audit_documents as $audit_document) {
			$this->node->appendChild(
				$this->createNodeFromRecord('audit_documents', $audit_document, 
					array('document_id', 'document_name', 'document_file_name','audit_id'))
			);
		}
		
		//Get the audit progress for the current checklist if it is applicable
		$client_audits = $this->clientChecklist->getClientChecklistAuditDetails($clientChecklistId);
		foreach($client_audits as $client_audit) {
			$this->node->appendChild($this->createNodeFromRecord('client_audit', $client_audit, array_keys((array)$client_audit)));
		}
		
		return;
	}
	
	public function updateAuditStatus($status, $audit_id) {
		$this->db->query(sprintf('
			UPDATE `%1$s`.`audit` SET
				`status` = %3$d
			WHERE `audit_id` = %2$d;
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($audit_id),
			$this->db->escape_string($status)
		));
		
		return;
	}

	//GHG Assessment Plugin Function
	public function GHGAssessment() {
		$params = $this->setParams();

		$client = $this->session->get('cid');
		if(empty($client)) return;

		if(isset($_REQUEST['ghg-action'])) {
			switch($_REQUEST['ghg-action']) {

				case 'add-entry':	$this->issueGHGAssessment($params->checklistId);
									break;

			}
		}

		$clientModel = new client($this->db);
		$client = $clientModel->getClientById($this->session->get('cid'));
		$clientChecklist = new clientChecklist($this->db);
		$this->ghg = new greenHouseGasCalculations($this->db);
		$clientChecklistId = $this->extractClientChecklistIdFromUrl();
		$mode = new stdClass;

		$groupedClientChecklists = $clientChecklist->getCompletedGroupedClientChecklists($params->checklistId, $client->client_id);

		//If the clientChecklistId has been set, get the checklist content
		if ($checklist = $this->accessibleClientChecklistId($clientChecklistId)) {

			$mode->mode = "checklist";	
			$this->loadChecklist($checklist);

		} else {
			
			$mode->mode = "report";
		}

		$this->ghg = new greenHouseGasCalculations($this->db);
		$reports = array();

		foreach($groupedClientChecklists as $clientChecklist) {
			$reports[] = $this->loadReport($this->accessibleClientChecklistId($clientChecklist));
		}

		$formattedResultData = $this->ghg->getFormatedEntryResults($reports);
		$mode->formattedData = json_encode($formattedResultData);

		//Set the mode node
		$modeNode = $this->node->appendChild($this->createNodeFromRecord('mode', $mode, array_keys((array)$mode)));

		return;
	}

	private function issueGHGAssessment($checklist_id) {
		if(($client_id = @$GLOBALS['core']->plugin->clients->client->client_id) == false) return;

		$this->clientChecklist = new clientChecklist($this->db);
		if(is_null($checklist_id)) {
			$messageNode = $this->doc->lastChild->appendChild($this->doc->createElement('message'));
			$messageNode->setAttribute('message',"Invalid Checklist");
			return;
		} else {
			$client_checklist_id = $this->clientChecklist->autoIssueChecklist($checklist_id, $client_id, false);

			$url = strtok($_SERVER["REQUEST_URI"],'?') . $client_checklist_id . "/";
			header("Location: " . $url);
			die();
		}
	}


	// ************************************** Load Entry ***************************/
	// loadEntry function
	// 20160205 
	// 5/2/2016
	// 
	// Rebuild of the assessment engine
	// Removes code bloat, allows: dynamic quetion triggering, real-time data validation, faster processing of data

	public function loadEntry() {
		$start = microtime(true);

		//Check for an ajax post first
		if(isset($_POST['post_type']) && $_POST['post_type'] === 'ajax') {
			if(isset($_POST['action'])) {
				$clientChecklist = new clientChecklist($this->db);
				switch($_POST['action']) {
					case 'updateClient2Metric':
						$clientChecklist->updateClient2Metric();
					break;
				}
			}
			return;
		}

		$client_checklist_id = $GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) -1]; //Expects last path item to be the client_checklist_id
		$action = $GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) -2]; //Looks for the second last variable as an action

		if ($checklist = $this->accessibleClientChecklistId($client_checklist_id)) {

			switch($action) {

				case 'recalculate':		
					$this->processClientChecklistFunctions($checklist->client_checklist_id);
					$checklist->status == 'Open' ? $this->loadChecklistContent($checklist) : $this->loadReport($checklist);
					break;

				case 'report':
					if($checklist->status != 'Open' || isset($checklist->progress_report) && $checklist->progress_report === '1') {
						$this->loadReport($checklist);
					} else {
						$checklist->status == 'Open' ? $this->loadChecklistContent($checklist) : $this->loadReport($checklist);
					}
					break;

				case 'export':
						$this->export($client_checklist_id);
					break;

				case 'report-pdf':
					$this->loadReportPdf();
					break;

				default:
					$checklist->status == 'Open' ? $this->loadChecklistContent($checklist) : $this->loadReport($checklist);
					break;
			}
		} 
		else {
			// No permission to access the checklist.
			header("Location: /");
			die();
		}

		//Send load time feedback
		$this->pluginLoadTime($start, microtime(true));

		return;
	}

	private function getCurrentChecklistPage($pages, $results) {
		$page_no = 0;

		for($i=0;$i<count($pages);$i++) {	
			count($results) && $results[0]->page_id == $pages[$i]->page_id ? $page_no = $i : null;
		}

		for($i=0;$i<count($pages);$i++) {
			isset($_REQUEST['p']) && $pages[$i]->token == $_REQUEST['p'] ? $page_no = $i : null;
		}

		return $page_no;
	}

	public function setClientChecklistDateFormats($clientChecklist) {
		$clientChecklist->last_active = !isset($clientChecklist->last_active_pretty) ? $this->clientChecklist->getclientChecklistLastActivity($clientChecklist->client_checklist_id) : $clientChecklist->last_active;

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

		return $clientChecklist;
	}

	private function getLastPage($pages, $skipPages) {
		$last = null;
		foreach($pages as $key=>$page) {
			if($skipPages[$page->page_id]) {
				$pages[$key]->last_page = 0;
			} else {
				$pages[$key]->last_page = 1;
				if(!is_null($last)) {
					$pages[$last]->last_page = 0;
				}
				$last = $key;
			}
		}

		return $pages;
	}

	private function loadChecklistContent($clientChecklist) {
		$params = $this->setParams();
		$pages							= $this->clientChecklist->getChecklistPages($clientChecklist->client_checklist_id);
		$results						= array_merge($this->clientChecklist->getClientSiteResults($clientChecklist->client_checklist_id), $this->clientChecklist->getClientResults($clientChecklist->client_checklist_id));	
		$pageComplete 					= $this->clientChecklist->getChecklistPagesCompleted($pages, $results);
		$pageSubmitable 				= $this->getPageSubmitStatus($pageComplete);
		$skipPages						= $this->clientChecklist->getPageDisplayStatus($pages, $results);
		$page_no						= $this->getCurrentChecklistPage($pages, $results);
		$clientChecklist 				= $this->setClientChecklistDateFormats($clientChecklist);
		$clientChecklist->progress		= $this->clientChecklist->getClientChecklistProgress($pages, $pageComplete, $skipPages, $clientChecklist->completed);		

		//Create the clientChecklist node
		$this->node->setAttribute('mode','checklist');
		$clientChecklist->pages = count($pages);
		$checklistNode = $this->node->appendChild($this->createNodeFromRecord('clientChecklist',$clientChecklist,array_keys((array)$clientChecklist)));
		if($clientChecklist->expires && strtotime($clientChecklist->expires) <= time()) {
			$checklistNode->setAttribute('expired','yes');
		}

		//Add the help content to the clientChecklist node
		$checklistNode->appendChild($this->createHTMLNode($clientChecklist->help_content,'help_content'));

		//Create the checklistPages node
		$pageCounter = 0;
		$pageCount = count($pages);
		$pages = $this->getLastPage($pages, $skipPages);
		foreach ($pages as $page) {
		 	$page->skipPage = ($skipPages[$page->page_id] ? '1' : '0');
			$page->complete = ($pageComplete[$page->page_id] ? 'yes' : 'no');
			$page->submitable = $clientChecklist->last_page_submit == '1' ? ($pageSubmitable[$page->page_id] && $pageCounter == ($pageCount -1) ? '1' : '0') : ($pageSubmitable[$page->page_id] ? '1' : '0');
			$checklistNode->appendChild($this->createNodeFromRecord('checklistPage', $page,array_keys((array)$page)));
			$pageCounter++;
		}
		
		//Get the content for the selected page
		//Check to see if the page is skipable and has any questions
		$skipPage = true;
		while($skipPage) {
			list($pageNode,$error,$showPageContent) = $this->setDynamicChecklistContent($clientChecklist,$pages[$page_no],$results);
			if($pages[$page_no]->enable_skipping && !$showPageContent) {
				isset($_REQUEST['back']) ? $page_no-- : $page_no++;
			} else {
				$skipPage = false;
				break;
			}
		}

		$checklistNode->setAttribute('current_page',$pages[$page_no]->page_id);
		$checklistNode->setAttribute('current_page_section',$pages[$page_no]->page_section_id);

		//Load the pageSections node
		$pageSections = $this->clientChecklist->getChecklistPageSections($clientChecklist->checklist_id);
		$enabledPageSections = 0;
		foreach($pageSections as $key=>$pageSection) {
			$enabled = 0;
			foreach($pages as $page) {
				if($page->page_section_id == $pageSection->page_section_id) {
					if(!$page->skipPage) {
						$enabled = 1;
					}
				}
			}
			$pageSections[$key]->enabled = $enabled;
			$enabledPageSections = $enabled ? $enabledPageSections+1 : $enabledPageSections; 
		}

		$pageSectionWidth = $this->getPageSectionWidth($enabledPageSections);
		foreach($pageSections as $pageSection) {
			$pageSection->width = $pageSectionWidth;
			$pageSectionNode = $checklistNode->appendChild($this->createNodeFromRecord('pageSection',$pageSection,array_keys((array)$pageSection)));
		}
		
		//Load clientSites node
		$clientSites = $this->clientChecklist->getClientChecklistSites($clientChecklist->client_checklist_id);
		foreach ($clientSites as $site) {
			$checklistNode->appendChild($this->createNodeFromRecord('clientSite', $site, array_keys((array)$site)));
		}
		$checklistNode->setAttribute('siteCount',count($clientSites));
		$this->node->setAttribute('layout_type',$this->getChecklistLayout($pageSections, $pages));

		//Load the metrics for the selected page
		$pageNode = $this->loadPageMetrics($pages[$page_no], $pageNode, $clientChecklist->client_checklist_id);
		$checklistNode->appendChild($pageNode);

		/**
		* Validation
		*/
		if(isset($params->validation) && $params->validation == true) {
			$checklistPages = $this->clientChecklist->getChecklistPages($clientChecklist->client_checklist_id);
			$validationNode = $checklistNode->appendChild($this->doc->createElement('validation'));
			$previousClientChecklists = $this->clientChecklist->getPreviousClientChecklists($clientChecklist->client_checklist_id);
			if(!empty($previousClientChecklists)) {
				$variations = $this->clientChecklist->getClientChecklistVariations($clientChecklist->client_checklist_id, $previousClientChecklists[0]->client_checklist_id);
			
				$clientChecklistNode = $validationNode->appendChild($this->createNodeFromRecord('clientChecklist', $variations->clientChecklist, array_keys((array)$variations->clientChecklist)));
				foreach($variations->variations as $question_id=>$variation) {
					$variationNode = $validationNode->appendChild($this->doc->createElement('variation'));
					$variationNode->setAttribute('key', $question_id);
					if(isset($variation['currentResponses'])) {
						foreach($variation['currentResponses'] as $currentResponse) {
							$currentResponseNode = $variationNode->appendChild($this->createNodeFromRecord('currentResponse', $currentResponse, array_keys((array)$currentResponse)));
						}
					}
					if(isset($variation['previousResponses'])) {
						foreach($variation['previousResponses'] as $previousResponse) {
							$previousResponseNode = $variationNode->appendChild($this->createNodeFromRecord('previousResponse', $previousResponse, array_keys((array)$previousResponse)));
						}
					}
					$changeNode = $variationNode->appendChild($this->createNodeFromRecord('change', $variation['change'], array_keys((array)$variation['change'])));
				}			
			}

			$variationResponses = $this->clientChecklist->getClientChecklistVariationResponses($clientChecklist->client_checklist_id);
			foreach($variationResponses as $variationResponse) {
				$variationResponseNode = $validationNode->appendChild($this->createNodeFromRecord('variationResponse', $variationResponse, array_keys((array)$variationResponse)));
			}

			$variationResponseOptions = $this->clientChecklist->getClientChecklistVariationResponseOptions($clientChecklist->client_checklist_id);
			foreach($variationResponseOptions as $variationResponseOption) {
				$variationResponseOptionNode = $validationNode->appendChild($this->createNodeFromRecord('variationResponseOption', $variationResponseOption, array_keys((array)$variationResponseOption)));
			}
		}

		//Lastly if no errors in the data and there is an action var present, process the request
		if(!$error && $this->processPageData()) {

			$complete = false;
			if ($clientChecklist->status == 'Closed' && $this->node->getAttribute('own_checklist') == 'no') {
				$complete = true;
				$report = $this->clientChecklist->getReport($clientChecklist->client_checklist_id);
			}

			//Set the clientChecklist Progress
			$this->clientChecklist->updateChecklistProgress(
				$clientChecklist->client_checklist_id,
				$clientChecklist->progress,
				$complete
			);

			$this->processPageActionRequest($clientChecklist, $pages, $page_no);
		}
			
		return;
	}

	//Decide what sort of nav to use
	private function getChecklistLayout($pageSections, $pages) {

		$navigation = count($pageSections) > 0 ? 'page-section-navigation' : 'page-navigation';
		$navigation = count($pages) <= 1 ? 'single-page' : $navigation;

		return $navigation;
	}

	private function processPageActionRequest($clientChecklist, $pages, $page_no) {
		$messages = array();
		//Set the default location (self)
		$location = '?p=' . $pages[$page_no]->token;

		switch($_POST['action']) {
			case 'save':
				$messages[] = array('type' => 'success', 'key' => 'User', 'message' => ENTRY_PAGE_SAVE_SUCCESS);
				$location = '?p=' . $pages[$page_no]->token . '&saved=true';
				break;

			case 'submit':
				$this->submitEntry($clientChecklist);
				$messages[] = array('type' => 'success', 'key' => 'User', 'message' => ENTRY_SUBMIT_SUCCESS);
				$location = strtok($_SERVER["REQUEST_URI"],'?');
				break;
			
			case 'next':
				$messages[] = array('type' => 'success', 'key' => 'User', 'message' => ENTRY_PAGE_SAVE_SUCCESS);
				$location = array_key_exists($page_no+1,$pages) ? '?p=' . $pages[$page_no+1]->token : $location;
				break;
	
			case 'previous':
				$messages[] = array('type' => 'success', 'key' => 'User', 'message' => ENTRY_PAGE_SAVE_SUCCESS);
				$location = array_key_exists($page_no-1,$pages) ? '?p=' . $pages[$page_no-1]->token : $location;
				break;
		}

		$GLOBALS['core']->session->setSessionVar('messages',$messages);

		//Process GHG Calculations
		ghg::db($this->db)->processTriggers($clientChecklist->client_checklist_id);
		header('Location: ' . $location);
		die();
	}

	//Sets the content (Questions, Answers) for the current client checklist and page
	//Dynamic content is aded to the function so that sub questions can be added on the fly
	private function setDynamicChecklistContent($clientChecklist,$page,$results) {

		$error = false;
		$processPost = $this->processPageData();
		$client_checklist_id = $clientChecklist->client_checklist_id;
		$previousResults = $clientChecklist->show_previous_results === '1' ? $this->clientChecklist->getPreviousClientChecklistResults($clientChecklist->client_checklist_id) : null;
		$previousNotes = $clientChecklist->show_previous_results === '1' ? $this->clientChecklist->getPreviousClientChecklistNotes($clientChecklist->client_checklist_id) : null;
		$questions = $this->clientChecklist->getPageQuestions($page->page_id);
		$formGroups = $this->clientChecklist->getPageFormGroups($page->page_id);
		$allQuestions = $this->clientChecklist->getAllPageQuestions($client_checklist_id);
		$clientSites = $this->clientChecklist->getClientChecklistSites($client_checklist_id);	
		$pageNode = $this->node->appendChild($this->createNodeFromRecord('page', $page, array_keys((array)$page)));
		$pageNode->appendChild($this->createHTMLNode($page->content,'content'));
		$questionArray = array();
		$clientResultsArray = array();
		$showPageContent = 0;
		$requirePageComplete = $this->clientChecklist->requirePageComplete($client_checklist_id);

		//Apply question permissions
		//$questions = $this->applyQuestionPermissions($clientChecklist, $questions);

		//Append any previous page notes
		if(count($previousNotes) > 0) {
			$previousNotesNode = $pageNode->appendChild($GLOBALS['core']->doc->createElement('previousNotes'));
			foreach($previousNotes as $previousNote) {
				if($previousNote->page_id === $page->page_id) {
					$previousNoteNode = $previousNotesNode->appendChild($this->createNodeFromRecord('previousNote', $previousNote, array_keys((array)$previousNote)));
				}
			}
		}

		//Now loop through all of the questions
		foreach($questions as $question) {

			//Check to see if the question has any dependencies
			$question->dependent_question = count($question->dependencies) > 0 ? 1 : 0;
			$question->triggered = $question->dependent_question ? 0 : 1;
			$question->data_parsley_required = $question->required === '1' && $requirePageComplete ? 'true' : 'false';

			$questionNode = $pageNode->appendChild($this->createNodeFromRecord('question', $question, array_keys((array)$question)));

			//Append the answers node
			foreach($question->answers as $answer) {

				//Check to see if the answer has any children
				$this->answerHasChildren($question->question_id, $answer->answer_id, $allQuestions) ? $answer->hasChildren = 1 : $answer->hasChildren = 0;

				$answer->type = $answer->answer_type;
				$answer->question_id = $question->question_id;
				$answer->default_value = strlen($answer->default_value) > 0 ? $this->getDefaultValue($client_checklist_id, $answer->answer_id, $answer->default_value) : $answer->default_value;
				$questionNode->appendChild($this->createNodeFromRecord('answer', $answer, array_keys((array)$answer)));
			}
			
			//Append the dependency node
			foreach($question->dependencies as $key=>$val) {
				$val->triggered = $this->clientChecklist->dependencyTriggered($question->dependencies, $key, $results) ? 1 : 0;
				$question->triggered = $question->triggered === 0 ? $val->triggered : 1;
				$questionNode->appendChild($this->createNodeFromRecord('dependency', $val, array_keys((array)$val)));
			}
			
			$showPageContent = $showPageContent ? 1 : $question->triggered;
			$questionNode->setAttribute('triggered', $question->triggered);


			//Get the page questions
			$questionArray[$question->question_id] = $question->question_id;

			//Append the results node
			//Check for a matching post result, if so, do not render the existing result
			foreach($results as $result) {
				if($result->question_id === $question->question_id && !isset($_POST['question'][$question->question_id])) {
					$result->value = $result->arbitrary_value; //Filling the value field with existing arbitraty_value
					
					//Check for file details
					if($result->answer_type === 'file-upload') {
						$fileDownload = new fileDownload($this->db);
						$file = $fileDownload->getFileInfo($result->value);
						$result->filename = isset($file->name) ? $file->name : $result->value;
						$result->filesize = isset($file->size) ? $file->size : null;
						$result->value = isset($file->hash) ? $file->hash : null;
					}

					$questionNode->appendChild($this->createNodeFromRecord('result', $result, array_keys((array)$result)));
				}
			}

			//Append the previousResults/Historical Results for the question
			if(count($previousResults) > 0) {
				$previousResultsNode = $questionNode->appendChild($GLOBALS['core']->doc->createElement('previousResults'));
				foreach($previousResults as $previousResult) {
					if($previousResult->question_id === $question->question_id) {
						$previousResultNode = $previousResultsNode->appendChild($this->createNodeFromRecord('previousResult', $previousResult, array_keys((array)$previousResult)));
					}
				}
			}

			//Validate the client results
			if($processPost) {
				list($clientResults, $questionError, $message) = $this->validateClientResult($client_checklist_id, $question, $requirePageComplete);
			
				//Add the POST data to the results node
				foreach($clientResults as $clientResult) {
					$clientResult->value = $clientResult->arbitrary_value; //Filling the value field with existing arbitraty_value
					$questionNode->appendChild($this->createNodeFromRecord('result', $clientResult, array_keys((array)$clientResult)));
				}

				//Log the error if present
				if($questionError) {
					$error = true;
					$questionNode->setAttribute('error',$message);
				} else {
					//If there are no errors
					//Add the client results to the client results array
					$clientResultsArray = array_merge($clientResultsArray, $clientResults);
				}
			}
		}

		foreach($formGroups as $formGroup) {
			$rows = $this->getFormGroupRows($formGroup, $questions, $results);
			$formGroupNode = $pageNode->appendChild($this->createNodeFromRecord('formGroup', $formGroup, array_keys((array)$formGroup)));
			foreach($rows as $key=>$val) {
				$rowNode = $formGroupNode->appendChild($GLOBALS['core']->doc->createElement('row'));
				$rowNode->setAttribute('index', $key);
				if($val === 'template') {
					$rowNode->setAttribute('template', true);
				}
			}
		}

		//See if we are processing the page data
		if($processPost) {

			//Remove all previous answers for the current page and the current client checklist
			$this->clientChecklist->deleteClientPageResults($client_checklist_id, $questionArray);

			//Save all client data for the current page
			$this->clientChecklist->storeMultipleClientResults($clientResultsArray);

			//Save client notes or delete the page note if nothing has been posted
			isset($_POST['note']) && strlen($_POST['note']) > 0 ? $this->clientChecklist->storeClientPageNote($client_checklist_id, $page->page_id, $_POST['note']) : $this->clientChecklist->deleteClientPageNote($client_checklist_id, $page->page_id);

			//Run any clientChecklist Functions on page submit (delete all before running again)
			$this->processClientChecklistFunctions($client_checklist_id);

			if(isset($_POST['variation-response-option'])) {
				$this->processValidationResponses();
			}
		}

		return(array($pageNode, $error, $showPageContent));
	}

	private function getFormGroupRows($formGroup, $questions, $results) {
		$rows = array();

		//Previous Results
		foreach($questions as $question) {
			if($formGroup->form_group_id == $question->form_group_id) {
				foreach($results as $result) {
					if($result->question_id == $question->question_id) {
						$rows[$result->index] = $result->index;
					}
				}
			}
		}

		//Minimum Rows
		while(count($rows) < $formGroup->min_rows) {
			$rows[count($rows)] = count($rows);
		}

		//Template
		if(count($rows) < 1) {
			$rows[0] = 'template';
		}

		asort($rows);

		return $rows;
	}

	private function processValidationResponses() {
		foreach($_POST['variation-response-option'] as $client_checklist_id=>$variations) {
			foreach($variations as $key=>$option) {
				$reason = isset($_POST['variation-response-reason'][$client_checklist_id][$key]) ? $_POST['variation-response-reason'][$client_checklist_id][$key] : null;
				if($option > 0) {
					$this->clientChecklist->storeVariationResponse($client_checklist_id, $key, $option, $reason);
				} else {
					$this->clientChecklist->deleteVariationResponse($client_checklist_id, $key);
				}
			}
		}

		return;
	}

	// Get all metrics and results for the current page
	private function loadPageMetrics($page, $pageNode, $client_checklist_id) {
		$processPost = $this->processPageData();

		//Get the page Metric Groups
		$metricGroups = $this->clientChecklist->getPageMetrics($page->page_id, $client_checklist_id);

		//If there are metrics, get the metric variation options
		if(!empty($metricGroups)) {
			$metricVariationOptions	= $this->clientChecklist->getChecklistMetricVariationOptions($client_checklist_id);
			if(!empty($metricVariationOptions)) {
				$metricVariationOptionsNode = $pageNode->appendChild($GLOBALS['core']->doc->createElement('metricVariationOptions'));
				foreach($metricVariationOptions as $metricVariationOption) {
					$metricVariationOptionNode = $metricVariationOptionsNode->appendChild($this->createNodeFromRecord('metricVariationOption', $metricVariationOption, array_keys((array)$metricVariationOption)));
				}
			}
		}

		foreach($metricGroups as $metricGroup) {
			$metricGroupNode = $pageNode->appendChild($this->createNodeFromRecord('metricGroup', $metricGroup, array_keys((array)$metricGroup)));
			
			//Get the metric group metrics
			foreach($metricGroup->metrics as $metric) {
				$metricNode = $metricGroupNode->appendChild($this->createNodeFromRecord('metric', $metric, array_keys((array)$metric)));
				
				//Get the metrics available units of measurement
				foreach($metric->metricUnits as $metricUnit) {
					$metricUnitNode = $metricNode->appendChild($this->createNodeFromRecord('metricUnit', $metricUnit, array_keys((array)$metricUnit)));
				}

				//Get the client metric results
				foreach($metric->clientMetricResults as $clientMetricResult) {
					$clientMetricResultNode = $metricNode->appendChild($this->createNodeFromRecord('clientMetric', $clientMetricResult, array_keys((array)$clientMetricResult)));
				}

				//Get the client default metric type
				foreach($metric->defaultMetricUnits as $defaultMetricUnit) {
					$defaultMetricUnitNode = $metricNode->appendChild($this->createNodeFromRecord('defaultMetricUnit', $defaultMetricUnit, array_keys((array)$defaultMetricUnit)));
				}

				//Get the client metric variations
				foreach($metric->clientMetricVariations as $clientMetricVariation) {
					$clientMetricVariationNode = $metricNode->appendChild($this->createNodeFromRecord('clientMetricVariation', $clientMetricVariation, array_keys((array)$clientMetricVariation)));
				}

				//Get the client sub metrics
				foreach($metric->clientSubMetrics as $clientSubMetric) {
					$clientSubMetricNode = $metricNode->appendChild($this->createNodeFromRecord('clientSubMetric', $clientSubMetric, array_keys((array)$clientSubMetric)));
				}

				//Get historical client metric results
				if(!empty($metric->siblingClientMetricResultsDataArray)) {
					$previousClientMetricResultsNode = $metricNode->appendChild($GLOBALS['core']->doc->createElement('previousResults'));
					foreach($metric->siblingClientMetricResultsDataArray as $siblingClientMetricResultsData) {
						foreach($siblingClientMetricResultsData as $siblingClientMetricResult) {
							$siblingClientMetricResultsNode = $previousClientMetricResultsNode->appendChild($this->createNodeFromRecord('clientMetricData', $siblingClientMetricResult, array_keys((array)$siblingClientMetricResult)));
						}
					}
				}

				//Update the clientMetrics
				if($processPost) {
					if(isset($_POST['metric'][$metric->metric_id]['value']) && strlen($_POST['metric'][$metric->metric_id]['value']) > 0) {
						if(!is_numeric($_POST['metric'][$metric->metric_id]['value'])) {
							$metricNode->setAttribute('error','If '.$metric->metric.' is set it must be a number');
							$error = true;
							continue;
						}
						$client_metric_id = $this->clientChecklist->storeClientMetric($client_checklist_id,$metric->metric_id,$_POST['metric'][$metric->metric_id]['metric_unit_type_id'],$_POST['metric'][$metric->metric_id]['value'],$_POST['metric'][$metric->metric_id]['months']);
						$metricNode->setAttribute('value',$_POST['metric'][$metric->metric_id]['value']);
						$metricNode->setAttribute('months',$_POST['metric'][$metric->metric_id]['months']);

						//Delete any existing client metric variations
						$this->clientChecklist->deleteClientMetricVariation($client_checklist_id,$metric->metric_id);
						if(isset($_POST['metricVariation'][$metric->metric_id])) {
							$this->clientChecklist->storeClientMetricVariation($client_metric_id, $client_checklist_id,$metric->metric_id,$_POST['metricVariation'][$metric->metric_id]['metric_variation_option_id'],$_POST['metricVariation'][$metric->metric_id]['metric_variation_value']);
						}
					} else {
						//Delete the client metric
						$this->clientChecklist->deleteClientMetric($client_checklist_id,$metric->metric_id);
					}

					//Sub Metrics
					if(isset($_POST['sub_metric'][$metric->metric_id]['description'])) {
						$this->clientChecklist->deleteClientSubMetric($client_checklist_id,$metric->metric_id);
						for($i = 0; $i < count($_POST['sub_metric'][$metric->metric_id]['description']); $i++) {
							if(isset($_POST['sub_metric'][$metric->metric_id]['description'][$i]) && isset($_POST['sub_metric'][$metric->metric_id]['metric_unit_type_id'][$i]) && isset($_POST['sub_metric'][$metric->metric_id]['value'][$i])) {
								$this->clientChecklist->storeClientSubMetric($client_checklist_id,$metric->metric_id,$_POST['sub_metric'][$metric->metric_id]['description'][$i],$_POST['sub_metric'][$metric->metric_id]['metric_unit_type_id'][$i],$_POST['sub_metric'][$metric->metric_id]['value'][$i]);
							}
						}
					}
				}		
			}
		}

		return $pageNode;
	}

	private function processPageData() {
		$process = false;

		if(isset($_REQUEST['action'])) {
			switch($_REQUEST['action']) {

				case 'previous':
				case 'next':
				case 'submit':
				case 'save':

					$process = true;

				break;
			}
		}
		return $process;
	}

	private function validateClientResult($client_checklist_id, $question, $requirePageComplete = true) {
		$error = false;
		$clientResults = array();
		$message = null;

		//Get the answers from POST
		foreach($question->answers as $answer) {
			if(isset($_POST['question'][$question->question_id])) {
				foreach($_POST['question'][$question->question_id] as $index=>$responses) {
					foreach($responses as $key=>$val) {
						$match = false;
						$value = null;

						switch($answer->answer_type) {
							case 'drop-down-list':
							case 'checkbox':
								$match = $val == $answer->answer_id ? true : false;
								break;

							case 'checkbox-other':
								$match = $val == $answer->answer_id ? true : false;
								$value = isset($_POST['question-other'][$question->question_id][$index][$answer->answer_id]) ? $_POST['question-other'][$question->question_id][$index][$answer->answer_id] : null;
								break;

							default:
								$match = $key == $answer->answer_id ? true : false;
								$value = $val;
								break;
						}

						if($match) {
							$clientResults[] = $this->createResultObject($client_checklist_id, $question->question_id, $answer->answer_id, $value, $index);
						}
					}
				}
			}
		}

		//Error Checking
		if(empty($clientResults)) {
			if(($question->required && !$question->dependent_question) || ($question->required && $question->dependent_question && $question->triggered)) {
				if($requirePageComplete) {
					$error = true;
					$message = 'This value is required.';
				}
			}
		}

		return array($clientResults, $error, $message);
	}

	private function createResultObject($client_checklist_id, $question_id, $answer_id, $arbitrary_value, $index = 0) {
		$result = new stdClass;

		//Set the result object and add to the clientResults array
		$result->client_checklist_id = $client_checklist_id;
		$result->question_id = $question_id;
		$result->answer_id = $answer_id;
		$result->arbitrary_value =  $arbitrary_value;
		$result->index =  $index;

		return $result;
	}

	private function answerHasChildren($question_id, $answer_id, $questions) {
		$hasChildren = false;

		foreach($questions as $question) {
			foreach($question->dependencies as $dependency) {
				if($dependency->question_id === $question_id && $dependency->answer_id === $answer_id) {
					$hasChildren = true;
				}
			}
		}

		return $hasChildren;
	}

	private function getPageSubmitStatus($pagesComplete) {
		$pagesSubmitable = array();
		$completedCount = (count($pagesComplete) - count(array_filter($pagesComplete)));

		foreach($pagesComplete as $key=>$val) {

			switch($completedCount) {

				case 0:
					$pagesSubmitable[$key] = true;
					break;

				case 1:
					$pagesSubmitable[$key] = $val ? false : true;
					break;

				default:
					$pagesSubmitable[$key] = false;
					break;
			}
		}

		return $pagesSubmitable;
	}

	private function submitEntry($clientChecklist) {

		$this->clientChecklist->updateChecklistProgress($clientChecklist->client_checklist_id, 100, true);
		
		//Email any answer reports
		$recipients = $this->clientChecklist->getEmailAnswerReportRecipients($clientChecklist->checklist_id);
		!is_null($recipients) ? $this->clientChecklist->emailAnswerReport($clientChecklist->client_checklist_id, $recipients) : null;
		
		//Now check if the client_checklist is a multi_site, if so, create new client_checklist and auto fill parent content along with the client_site content
		if($this->clientChecklist->isClientChecklistMultiSite($clientChecklist->client_checklist_id)) {
			$childClientChecklistIdArray = $this->clientChecklist->createMultiSiteChildrenClientChecklist($clientChecklist->client_checklist_id);
			
			// Set the script time out to indefinate for looping
			set_time_limit(0);
			
			//For each of the client checklist id's created, load the report to get the scoring completed
			foreach($childClientChecklistIdArray as $clientChecklistId) {
				$checklist = $this->accessibleClientChecklistId($clientChecklistId);
				$this->loadReport($checklist);
			}
			
			// Change the timeout back to 30 seconds after completed.
			set_time_limit(30);
		}

		//Call any checklist followup
		$this->checklistFollowup($clientChecklist);

		return;
	}

	//Call a class name for the checklist to process any custom data
	private function checklistFollowup($clientChecklist) {

		if(isset($clientChecklist->followup_call) && !is_null($clientChecklist->followup_call) && isset($clientChecklist->client_checklist_id)) {
			$checklistFollowup = new $clientChecklist->followup_call($this->db, $clientChecklist->client_checklist_id);
		}

		return;
	}

	//Gets the default valud for a given checklist answer
	private function getDefaultValue($client_checklist_id, $answer_id, $query) {
		$default_value = null;
		$contactModel = new clientContact($this->db);
		$clientModel = new client($this->db);

		$node = new stdClass;
		$node->contact = $contactModel->getClientContactById($this->session->get('uid'));
		$node->client = $clientModel->getClientById($this->session->get('cid'));

		$query = explode('::',$query);

		if(isset($query[0]) && isset($query[1])) {
			switch($query[0]) {
				case 'node':
					$result = $this->getNodeValue($node, $query[1]);
					!is_null($result) ? $default_value = $result : null;
					break;

				case 'static':
				default:
					$default_value = $query[1];
					break;
			}
		}

		return $default_value;
	}

	//Takes a node and a query array to try and find the matching element in the node
	private function getNodeValue($node, $query) {
		$result = null;

		$query = explode('/', $query);
		foreach($query as $queryKey=>$queryVal) {
			foreach($node as $nodeKey=>$nodeVal) {
				$nodeKey === $queryVal ? $node = $nodeVal : null;
			}
			!is_array($node) && !is_object($node) ? $result = $node : null;
		}

		return $result;
	}

	//Take the pageSection object and figure out what percentage width is optimal for display
	private function getPageSectionWidth($pageSectionCount) {
		$pageSectionWidth = null;

		switch($pageSectionCount) {

			case 0: $pageSectionWidth = 0;
				break;

			case ($pageSectionCount<5):
				$pageSectionWidth = 100/$pageSectionCount;
				break;

			case ($pageSectionCount>=5):
			default:
				$pageSectionCount = $pageSectionCount%2 == 1 ? $pageSectionCount-1 : $pageSectionCount;
				$pageSectionWidth = (ceil(($pageSectionCount/5))*100)/$pageSectionCount;
				break;
		}

		return $pageSectionWidth;
	}

	//Add Entry Wizard Plugin
	public function addEntryWizard() {
		$clientChecklist = new clientChecklist($this->db);
		$timeAndDate = new timeAndDate();

		//Get the checklists from the param
		$params = $this->setParams();
		$iterations = isset($params->iterations) ? $params->iterations : null;
		$offset = isset($params->offset) ? $params->offset : null;
		$seedDate = isset($params->seedDate) ? $params->seedDate : null;

		//Get the checklists available
		$checklists = isset($params->checklists) ? $clientChecklist->getChecklistByChecklistId($params->checklists) : array();
		$checklistsNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('checklists'));
		foreach($checklists as $checklist) {
			$checklistNode = $checklistsNode->appendChild($this->createNodeFromRecord('checklist', $checklist, array_keys((array)$checklist)));
		}

		//Get periods available
		if(isset($params->period)) {
			$periodsNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('periods'));

			switch($params->period) {

				case 'fy_au':
					$periods = $timeAndDate->getFinancialYearAustralia($iterations, $offset, $seedDate);
					foreach($periods as $period) {
						$periodNode = $periodsNode->appendChild($this->createNodeFromRecord('period', $period, array_keys((array)$period)));
					}
					break;

				case 'year':
					$periods = $timeAndDate->getPreviousYears($iterations, $offset, $seedDate);
					foreach($periods as $period) {
						$periodNode = $periodsNode->appendChild($this->createNodeFromRecord('period', $period, array_keys((array)$period)));
					}
					break;

				case 'month':
					$periods = $timeAndDate->getPreviousMonths($iterations, $offset, $seedDate);
					foreach($periods as $period) {
						$periodNode = $periodsNode->appendChild($this->createNodeFromRecord('period', $period, array_keys((array)$period)));
					}
					break;
			}
		}

		//Get Entities Available
		$contact = clientContact::stGetClientContactById($this->db, $GLOBALS['core']->session->get('uid'));
		$clientModel = new client($this->db);

		$accessible_clients = resultFilter::accessible_clients($this->db, $contact);
		$accessible_clients[] = $contact->client_id;
		$clients = $clientModel->getClients($accessible_clients);

		$entitiesNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('entities'));
		foreach($clients as $entity) {
			$entityNode = $entitiesNode->appendChild($this->createNodeFromRecord('entity', $entity, array_keys((array)$entity)));
		}

		//Check for postback
		if(isset($_POST['action']) && $_POST['action'] == 'addEntry') {
			$checklist_id = $clientChecklist->getChecklistIdByHash($_REQUEST['checklist_id']);
			if(isset($checklist_id) && $checklist_id > 0 && isset($_REQUEST['client_id']) && $_REQUEST['client_id'] > 0) {
				$data = array('client_id' => $_REQUEST['client_id'],'checklist_id' => $checklist_id);
				if(isset($_REQUEST['date_range_start'])) {

					$data['date_range_start'] = $_REQUEST['date_range_start'];
					$data['date_range_finish'] = isset($_REQUEST['date_range_finish']) ? $_REQUEST['date_range_finish'] : $timeAndDate->getEndOfPeriod($_REQUEST['date_range_start'], isset($_REQUEST['period']) ? $_REQUEST['period'] : null);
				}
				$clientChecklistId = $clientChecklist->setNewClientChecklist($data);

				if($clientChecklistId > 0) {
					header('Location: /members/entry/' . $clientChecklistId . '/');
					die();
				}
			}
		} else {
			//No postback but check for single values
			if(!isset($params->period) && count($checklists) == 1 && count($clients) == 1) {
				foreach($clients as $client) {
					foreach($checklists as $checklist) {
						$clientChecklistId = $clientChecklist->setNewClientChecklist(array('client_id' => $client->client_id,'checklist_id' => $checklist->checklist_id));

						if($clientChecklistId > 0) {
							header('Location: /members/entry/' . $clientChecklistId . '/');
							die();
						}
					}
				}
			}
		}

		return;
	}

	private function processClientChecklistFunctions($client_checklist_id) {
		$clientChecklistFunction = new clientChecklistFunction($this->db, $client_checklist_id);
		$this->clientChecklist->deleteClientChecklistAdditionalValues($client_checklist_id);
		$clientChecklistFunction->processClientChecklistFunctions();
		$clientChecklistFunction->processClientChecklistFollowupSql();

		return;
	}

	private function export($client_checklist_id, $file_type = 'csv', $data_type = null) {
		
		$checklist = $this->accessibleClientChecklistId($client_checklist_id);

		switch($file_type) {
			case 'csv':
			default:

				$fileRenderer = new fileRenderer();
				switch($data_type) {
					default:
						$data = $this->clientChecklist->getClientResultsWithAdditionalValues($client_checklist_id);
						$fileRenderer->array2CSV($data, clientUtils::makeNameFilenameSafe(($checklist->report_name != '' ? $checklist->report_name : $checklist->name))."_".clientUtils::makeNameFilenameSafe($checklist->company_name));
				}

			break;
		}

		return;
	}

	public function getEntryVariation() {
		$client_checklist_id = $GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) -1];

		$query = $this->clientChecklist->getClientChecklistVariation($client_checklist_id);
		$query = str_replace("\"","\\\"", $query);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		$this->node->setAttribute('mode','entry_variation');
		return;
	}

	public function analytics() {
		$params = $this->setParams();

		$client_contact_id = $GLOBALS['core']->session->get('uid');
		$client_id = $GLOBALS['core']->session->get('cid');
		if(is_null($client_contact_id) || is_null($client_id)) {
			return;
		}

		//Get the accessible checklists for the current user
		$clientChecklist = new clientChecklist($this->db);
		$checklists = $clientChecklist->getContactChecklists($client_contact_id);
		$clientChecklists = $clientChecklist->getContactClientChecklists($client_contact_id);

		//Add API data
		$apiData = $this->node->appendChild($GLOBALS['core']->doc->createElement('query-data'));
		$timestamp = time();
		$apiData->setAttribute('key', GBC_API_PUB_KEY);
		$apiData->setAttribute('hash',hash_hmac('sha256', (GBC_API_PUB_KEY . $timestamp), GBC_API_PRV_KEY));
		$apiData->setAttribute('timestamp',$timestamp);

		//Accesible client and client_checklist
		$apiData->setAttribute('client_array', json_encode($client_id));
		$apiData->setAttribute('client_id', json_encode($client_id));
		$apiData->setAttribute('client_checklist_array', json_encode(implode(',',$clientChecklists)));

		$checklistsNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('checklists'));
		foreach($checklists as $checklist) {
			$checklistNode = $checklistsNode->appendChild($this->createNodeFromRecord('checklist', $checklist, array_keys((array)$checklist)));
		}	

		return;
	}

	/**
	*	Apply Question Permissions
	*	Refines the required and hidden options based on user accessing the data
	*/
	private function applyQuestionPermissions($clientChecklist, $questions) {
		$dashboard = new dashboard($this->db);
		$cc = new clientChecklist($this->db);

		$contact = clientContact::stGetClientContactById($this->db, $this->session->get('uid'));
		$dashboardUser = $dashboard->getDashboardUser($contact->client_contact_id);
		$userDefinedGroups = $dashboard->getClient2UserDefinedGroup(null, [$contact->client_id]);
		$permissionTypes = $cc->getPermissionTypes();

		foreach($questions as $key=>$question) {

			//Set permission to none
			$questions[$key]->permission_id = 0;
			$questionPermissions = $cc->getQuestionPermissions($question->question_id);
			if(!empty($questionPermissions)) {
				$questions[$key]->permission_id = 1;
				foreach($questionPermissions as $questionPermission) {
					switch($questionPermission->permission_group_id) {
						case '1':
								if($clientChecklist->client_id == $contact->client_id) {
									$questions[$key]->permission_id = $questionPermission->permission_type_id > $questions[$key]->permission_id ? $questionPermission->permission_type_id : $questions[$key]->permission_id;
								}
							break;

						case '2':
								foreach($userDefinedGroups as $userDefinedGroup) {
									if($userDefinedGroup->user_defined_group_id == $questionPermission->id) {
										$questions[$key]->permission_id = $questionPermission->permission_type_id > $questions[$key]->permission_id ? $questionPermission->permission_type_id : $questions[$key]->permission_id;
									}
								}

							break;
					}
				}
			} else { 
				//Apply Edit Permission
				$questions[$key]->permission_id = 3;
			}

			//Set the permission description
			foreach($permissionTypes as $permissionType) {
				if($permissionType->permission_type_id == $questions[$key]->permission_id) {
					$questions[$key]->permission = $permissionType->type;
				}
			}

			//Update the hidden and required fields
			$questions[$key]->hidden = $questions[$key]->permission_id == 1 ? 1 : $question->hidden;
			$questions[$key]->required = in_array($questions[$key]->permission_id, Array(1,2)) ? 0 : $question->required;
		}

		return $questions;
	}

}
?>
