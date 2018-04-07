<?php
class dashboardContent extends plugin {
	private $client;
	private $clientClass;
	private $contact;
	private $dashboard;
	private $dashboardUser;
	private $clientChecklist;
	private $dbModel;
	public $db;
	private $permissions;
	private $submissions;

	private $client_id;
	private $client_checklist_id;
	private $client_contact_id;
	
	public function __construct() {

		//first check for a valid user/uid
		if(!$GLOBALS['core']->session->get('uid')) return;

		//Get the required classes
		$this->db = $GLOBALS['core']->db;
		$this->dbModel = new dbModel($this->db);
		$this->contact = clientContact::stGetClientContactById($this->db, $GLOBALS['core']->session->get('uid'));
		$this->client = client::stGetClientById($this->db, $this->contact->client_id);
		$this->clientChecklist = new clientChecklist($this->db);
		$this->clientClass = new client($this->db);

		//Get the dashboard classes
		$this->dashboard = new dashboard($this->db);
		$this->dashboardUser = $this->dashboard->getDashboardUser($this->contact->client_contact_id);

		if(!empty($this->dashboardUser)) {
			//Get additional information on the current user's access leves
			$this->contact->dashboard_group_id = $this->dashboardUser->dashboard_group_id;
			$this->contact->dashboard_role_id = $this->dashboardUser->dashboard_role_id;

			//Set the query fields
			$this->setQueryFields();

			//Check for any postback actions and refresh the result filter if required
			if($this->processPostbackFunctions()) {
				$this->resultFilter = new resultFilter($this->db, $this->contact);
			};

			//Get GreenBizCheck classes
			$this->permissions = new \GreenBizCheck\Permissions();
			$this->submissions = new \GreenBizCheck\Submissions();

			//Check for ajax download
			$this->processQuery();
		}

		return;
	}

	private function processQuery() {

		//Downloads
		if(isset($_REQUEST['download-mode']) && $_REQUEST['download-mode'] === 'ajax' && isset($_REQUEST['download-file'])) {

			$fileRenderer = new fileRenderer();

			switch($_REQUEST['download-file']) {
				case 'entity-results':
					$data = $this->clientChecklist->getClientResultsWithAdditionalValues(resultFilter::filtered_client_checklist_array($this->db, $this->contact));
					$fileRenderer->array2CSV($data, clientUtils::makeNameFilenameSafe($_REQUEST['download-file']));
					break;
			}
			die();
		}
	}

	//Set any get vars to be used elsewhere
	private function setQueryFields() {
		$this->client_id = isset($_GET['client_id']) && in_array($_GET['client_id'],resultFilter::accessible_clients($this->db, $this->contact)) ? $_GET['client_id'] : null;
		$this->client_checklist_id = isset($_GET['client_checklist_id'])  && in_array($_GET['client_checklist_id'],resultFilter::accessible_client_checklists($this->db, $this->contact)) ? $_GET['client_checklist_id'] : null;
		$this->client_contact_id = isset($_GET['client_contact_id']) ? $_GET['client_contact_id'] : null;

		return;
	}
	
	//Legacy Dashboard Content
	public function getContent() {

		$params = $this->setParams();

		//first check for a valid user/uid
		if(empty($this->dashboardUser)) return;

		//Get the result filter permalink
		$permalinkNode = $this->node->appendChild($this->createNodeFromRecord('filterPermalink', resultFilter::filterSettingsPermalink($this->db, $this->contact), array_keys((array)resultFilter::filterSettingsPermalink($this->db, $this->contact))));

		//Get the client node and add the fields to the XML output
		foreach(resultFilter::filterSettings($this->db, $this->contact) as $filterSetting) {
			$filterNode = $this->node->appendChild($this->createNodeFromRecord('filterSetting', $filterSetting, array_keys((array)$filterSetting)));
		}

		//Get all Client Types
		$clientTypes = $this->clientClass->getClientTypes();

		foreach($clientTypes as $clientType) {
			if(in_array($clientType->client_type_id, resultFilter::accessible_client_types($this->db, $this->contact))) {
				$clientTypeNode = $this->node->appendChild($this->createNodeFromRecord('client_type', $clientType, array_keys((array)$clientType)));
			}
		}

		//Filter Field Groups to XML
		$filterFieldGroups = $this->dashboard->getFilterFieldGroups();
		foreach($filterFieldGroups as $filterFieldGroup) {
			$filterFieldGroupNode = $this->node->appendChild($this->createNodeFromRecord('filterFieldGroup', $filterFieldGroup, array_keys((array)$filterFieldGroup)));
		}

		//Filter Fields to XML
		$filterFields = $this->dashboard->getFilterFields();
		foreach($filterFields as $filterField) {
			$filterFieldNode = $this->node->appendChild($this->createNodeFromRecord('filterField', $filterField, array_keys((array)$filterField)));
		}

		//Filter Queries to XML
		$filterQueries = $this->dashboard->getFilterQueries();
		foreach($filterQueries as $filterQuery) {
			$filterFieldNode = $this->node->appendChild($this->createNodeFromRecord('filterQuery', $filterQuery, array_keys((array)$filterQuery)));
		}
	
		//Filter Queries to XML
		$clients = $this->getClients();
		
		//Add Json encoded data
		$jsonData = $this->node->appendChild($GLOBALS['core']->doc->createElement('json-data'));
		$jsonData->setAttribute('key','client');
		$jsonData->setAttribute('data',json_encode($clients));
		
		foreach($clients as $client) {
			$clientNode = $this->node->appendChild($this->createNodeFromRecord('client', $client, array_keys((array)$client)));
			if(isset($_REQUEST['client_id'])) {
				$clientContacts = $this->getClientContacts($client->client_id);
				foreach($clientContacts as $client_contact) {
					$clientNode->appendChild($this->createNodeFromRecord('client_contact', $client_contact, array_keys((array)$client_contact)));
				}
			}
		}

		//Filter Queries to XML
		$clientChecklists = $this->getClientChecklists();

		//Add Json encoded data
		$jsonData = $this->node->appendChild($GLOBALS['core']->doc->createElement('json-data'));
		$jsonData->setAttribute('key','clientChecklist');
		$jsonData->setAttribute('data',json_encode($clientChecklists));

		foreach($clientChecklists as $clientChecklist) {
			$clientChecklistNode = $this->node->appendChild($this->createNodeFromRecord('clientChecklist', $clientChecklist, array_keys((array)$clientChecklist)));
			
			//Get the clientChecklist results if the client_id is set
			isset($_REQUEST['client_id']) ? $this->getClientChecklistAnswers($clientChecklist->client_checklist_id, $clientChecklistNode) : null;
			
			//If the action is set to compare the clientChecklists get the clientchecklist results
			if(isset($_REQUEST['action']) && $_REQUEST['action'] == "compare-checklists" && !empty($_REQUEST['compare_client_checklist_id'])) {
				if(in_array($clientChecklist->client_checklist_id, $_REQUEST['compare_client_checklist_id'])) {
					$clientChecklistNode->setAttribute('compare-this-checklist', '1');
					$this->getClientChecklistAnswers($clientChecklist->client_checklist_id, $clientChecklistNode, true);
				}
			}
		}

		if(isset($_REQUEST['client_checklist_id'])) {
			//Add Json encoded data
			$clientChecklist = new clientChecklist($this->db);
			$clientChecklistMetricResults = $clientChecklist->getClientChecklistMetricResults($_REQUEST['client_checklist_id']);

			$jsonData = $this->node->appendChild($GLOBALS['core']->doc->createElement('json-data'));
			$jsonData->setAttribute('key','clientChecklistMetricResults');
			$jsonData->setAttribute('data',json_encode($clientChecklistMetricResults));
		}

		//Filter Queries to XML
		$checklists = $this->getChecklists();
		foreach($checklists as $checklist) {
			$checklistNode = $this->node->appendChild($this->createNodeFromRecord('checklist', $checklist, array_keys((array)$checklist)));
		}

		//Filter Queries to XML
		$pages = $this->getPages();
		foreach($pages as $page) {
			$pageNode = $this->node->appendChild($this->createNodeFromRecord('page', $page, array_keys((array)$page)));
		}

		//Filter Queries to XML
		$pageSections = $this->getPageSections();
		foreach($pageSections as $pageSection) {
			$pageSectionNode = $this->node->appendChild($this->createNodeFromRecord('pageSection', $pageSection, array_keys((array)$pageSection)));
		}

		//Filter Queries to XML
		$questions = $this->getQuestions();
		foreach($questions as $question) {
			$questionNode = $this->node->appendChild($this->createNodeFromRecord('question', $question, array_keys((array)$question)));
		}

		//Add Json encoded data
		$metricGroups = $this->getMetricGroups();
		$jsonData = $this->node->appendChild($GLOBALS['core']->doc->createElement('json-data'));
		$jsonData->setAttribute('key','metricGroup');
		$jsonData->setAttribute('data',json_encode($metricGroups));

		foreach($metricGroups as $metricGroup) {
			$metricGroupNode = $this->node->appendChild($this->createNodeFromRecord('metricGroup', $metricGroup, array_keys((array)$metricGroup)));
		}

		$metrics = $this->getMetrics();
		$jsonData = $this->node->appendChild($GLOBALS['core']->doc->createElement('json-data'));
		$jsonData->setAttribute('key','metric');
		$jsonData->setAttribute('data',json_encode($metrics));


		foreach($metrics as $metric) {
			$metricNode = $this->node->appendChild($this->createNodeFromRecord('metric', $metric, array_keys((array)$metric)));
		}

		return;
	}

	//Redeveloped Dashboard Content Plugin
	public function loadContent() {
		$params = $this->setParams();


		//first check for a valid user/uid
		if(empty($this->dashboardUser)) return;

		//Pass any post data to the node for use with AJAX Posts and filtering
		$postData = $this->node->appendChild($GLOBALS['core']->doc->createElement('postData'));
		$postData->setAttribute('result_filter', json_encode(resultFilter::filterSettings($this->db, $this->contact)));

		//Get the result filter permalink
		$permalinkNode = $this->node->appendChild($this->createNodeFromRecord('filterPermalink', resultFilter::filterSettingsPermalink($this->db, $this->contact), array_keys((array)resultFilter::filterSettingsPermalink($this->db, $this->contact))));

		//Get the client node and add the fields to the XML output
		$filterSettings = resultFilter::filterSettings($this->db, $this->contact);
		foreach($filterSettings as $filterSetting) {
			$filterNode = $this->node->appendChild($this->createNodeFromRecord('filterSetting', $filterSetting, array_keys((array)$filterSetting)));
		}

		//Get all Client Types
		//$clientTypes = $this->clientClass->getClientTypes(implode(',',resultFilter::filtered_client_array($this->db, $this->contact)));
		$clientTypes = $this->clientClass->getClientType(implode(',',resultFilter::accessible_client_types($this->db, $this->contact)));


		foreach($clientTypes as $clientType) {
			$clientTypeNode = $this->node->appendChild($this->createNodeFromRecord('client_type', $clientType, array_keys((array)$clientType)));
		}

		//Get all Checklists
		$checklists = $this->clientChecklist->getAllChecklists(implode(',',resultFilter::accessible_checklists($this->db, $this->contact)),implode(',',resultFilter::filtered_client_checklist_array($this->db, $this->contact)));

		foreach($checklists as $checklist) {
			if(in_array($checklist->checklist_id, resultFilter::accessible_checklists($this->db, $this->contact))) {
				$checklistNode = $this->node->appendChild($this->createNodeFromRecord('checklist', $checklist, array_keys((array)$checklist)));
			}
		}

		//Call and only set if query variables are in place
		$this->setClient();
		$this->setClientChecklist();
		
		return;
	}


	public function getJVMClientMap() {

		//first check for a valid user/uid
		if(empty($this->dashboardUser)) return;

		//Get the client coordinates
		$clientCoordinates = $this->getClientCoordinates();
		foreach ($clientCoordinates as $key => $clientCoordinate) {
			$clientCoordinates[$key]->latLng = array($clientCoordinate->lat, $clientCoordinate->lng);
			$clientCoordinates[$key]->name = $clientCoordinate->company_name;
			$clientCoordinates[$key]->markertype = "client";
			$clientCoordinates[$key]->address = array($clientCoordinate->address_line_1, $clientCoordinate->address_line_2, $clientCoordinate->suburb, $clientCoordinate->state, $clientCoordinate->postcode, $clientCoordinate->country);
			$clientCoordinates[$key]->address = implode(", ", array_filter($clientCoordinates[$key]->address));
			
			//If the client has returned a current alert, change the marker colour
			if(!is_null($clientCoordinates[$key]->client_alert_id)) {
				$clientCoordinates[$key]->style = new stdClass;
				$clientCoordinates[$key]->style->fill = "orange";
			}
		}

		//Get any Gdacs events to display
		$gdacs = new gdacs($this->db);
		$events = $gdacs->getGdacsEvents();
		foreach ($events as $key => $event) {
			$events[$key]->latLng = array($event->lat, $event->lng);
			switch($event->eventtype) {
				case 'EQ': $events[$key]->name = 'EARTHQUAKE ';
				break;

				case 'TC': $events[$key]->name = "CYCLONE " . $event->eventname;
				break;

				default: $events[$key]->name = $event->eventname;
				break;
			}
			$events[$key]->style = new stdClass;
			$events[$key]->style->r = "10";
			$events[$key]->style->{"fill-opacity"} = "0.25";
			$events[$key]->style->{"stroke-width"} = "2";
			$events[$key]->style->stroke = strtolower($event->alertlevel);
			$events[$key]->style->fill = strtolower($event->alertlevel);
			$events[$key]->markertype = "gdacs";
		}

		$mapDataArray = array_merge($clientCoordinates, $events);

		//Get the clientCoordinates and push to XML
		$mapData = new stdClass;
		$mapData->data = json_encode($mapDataArray);
		$clientCoordinatesNode = $this->node->appendChild($this->createNodeFromRecord('clientCoordinates', $mapData, array_keys((array)$mapData)));

		return;
	}

	public function getClientMap() {
		//first check for a valid user/uid
		if(empty($this->dashboardUser)) return;

		$this->getGeoJSONData();

		return;

	}

	private function getGeoJSONData() {

		//Create the GeoJSON class
		$geoData = new stdClass;
		$geoData->type = "FeatureCollection";

		//Create the Feature Class
		$features = array();

		//Get the client coordinates
		$clientCoordinates = $this->getClientCoordinates();
		foreach ($clientCoordinates as $key => $clientCoordinate) {

			//Create the Feature Object
			$feature = new stdClass;
			$feature->type = "Feature";

			//Crete the Geometry Object;
			$geometry = new stdClass;
			$geometry->type = "Point";
			$geometry->coordinates = array($clientCoordinate->lng, $clientCoordinate->lat);
			$feature->geometry = $geometry;

			//Create the Properties Object
			$properties = new stdClass;
			$properties->name = $clientCoordinate->company_name;
			$properties->markertype = "client";
			$properties->address = implode(", ", array_filter(array($clientCoordinate->address_line_1, $clientCoordinate->address_line_2, $clientCoordinate->suburb, $clientCoordinate->state, $clientCoordinate->postcode, $clientCoordinate->country)));
			$properties->client_id = $clientCoordinates[$key]->client_id;
			$feature->properties = $properties;

			//Create the ID Object
			$feature->id = $clientCoordinates[$key]->client_id;

			//Add the Feature Object to the features array
			$features[] = $feature;
		}
		$geoData->features = $features;

		//Create the GeoJSON class
		$disasterData = new stdClass;
		$disasterData->type = "FeatureCollection";

		//Create the Feature Class
		$features = array();

		//Get any Gdacs events to display
		$gdacs = new gdacs($this->db);
		$events = $gdacs->getGdacsEvents();
		foreach ($events as $key => $event) {

			//Create the Feature Object
			$feature = new stdClass;
			$feature->type = "Feature";

			//Crete the Geometry Object;
			$geometry = new stdClass;
			$geometry->type = "Point";
			$geometry->coordinates = array($event->lng, $event->lat);
			$feature->geometry = $geometry;

			//Create the Properties Object
			$properties = $event;
			$properties->link = $event->link;
			$properties->markertype = "gdacs";

			switch($event->eventtype) {
				case 'EQ': $properties->name = 'EARTHQUAKE ';
				break;

				case 'TC': $properties->name = "CYCLONE " . $event->eventname;
				break;

				default: $properties->name = $event->eventname;
				break;
			}
			
			$properties->style = new stdClass;
			$properties->style->radius = "25";
			$properties->style->fillOpacity = "0.35";
			$properties->style->weight = "2";
			$properties->style->stroke = "true";
			$properties->style->color = strtolower($event->alertlevel);
			$properties->style->fillColor = strtolower($event->alertlevel);

			$feature->properties = $properties;
			$feature->id = $event->eventid;

			//Add the Feature Object to the features array
			$features[] = $feature;
		}

		$disasterData->features = $features;

		$allData = array();
		$allData['clients'] = $geoData;
		$allData['disasters'] = $disasterData;

		//Get the clientCoordinates and push to XML
		$mapData = new stdClass;
		$mapData->data = json_encode($allData);
		$clientCoordinatesNode = $this->node->appendChild($this->createNodeFromRecord('clientCoordinates', $mapData, array_keys((array)$mapData)));

		return;
	}

	private function setClient() {

		//Check that the client has been set
		if(is_null($this->client_id)) {
			return;
		}

		//Get all Clients if no client_id is set, otherwise, just get the client that is set
		$query = sprintf('
			SELECT 
			`client`.*,
			(SELECT COUNT(*) FROM `%1$s`.`client_contact` WHERE `client_contact`.`client_id` = `client`.`client_id`) AS `users`,
			(SELECT COUNT(*) FROM `%2$s`.`client_checklist` WHERE `client`.`client_id` = `client_checklist`.`client_id` AND `client_checklist`.`checklist_id` IN(%4$s) AND `client_checklist`.`status` != 4) AS `entries`,
			(SELECT IFNULL(MAX(`client_contact_log`.`timestamp`), `client`.`registered`) FROM `%1$s`.`client_contact_log` WHERE `client_contact_log`.`client_id` = `client`.`client_id`) AS `last_active`
			FROM `%1$s`.`client`
			WHERE `client`.`client_id` = %3$d
			AND `client`.`company_name` IS NOT NULL
		',
			DB_PREFIX.'core',
			DB_PREFIX.'checklist',
			$this->db->escape_string($this->client_id),
			implode(',',resultFilter::accessible_checklists($this->db, $this->contact))
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {

				$row->created_formatted = new stdClass;
				$row->created_formatted->date_time = !is_null($row->registered) ? date_format(date_create($row->registered), "j/n/Y h:i A") : null;
				$row->created_formatted->order = !is_null($row->registered) ? $row->registered : null;

				$row->last_active_formatted = new stdClass;
				$row->last_active_formatted->date_time = !is_null($row->last_active) ? date_format(date_create($row->last_active), "j/n/Y h:i A") : null;
				$row->last_active_formatted->order = !is_null($row->last_active) ? $row->last_active : null;
				$row->last_active_pretty = !is_null($row->last_active) ? date_format(date_create($row->last_active), "j/n/Y h:i A") : null;
				$row->last_active_pretty_date = !is_null($row->last_active) ? date_format(date_create($row->last_active), "j/n/Y") : null;
				$row->last_active_pretty_date_word = !is_null($row->last_active) ? date_format(date_create($row->last_active), "j F Y") : null;
				$row->last_active_pretty_time = !is_null($row->last_active) ? date_format(date_create($row->last_active), "h:i A") : null;
			
				$clientNode = $this->node->appendChild($this->createNodeFromRecord('client', $row, array_keys((array)$row)));
			}
			$result->close();
		}

		return;
	}

	private function setClientChecklist() {

		//Check that the client has been set
		if(is_null($this->client_checklist_id)) {
			return;
		}

		$clientChecklist = new clientChecklist($this->db);

		$query = sprintf('
			SELECT
			client_checklist.client_checklist_id,
			client_checklist.checklist_id,
			client_checklist.client_id,
			checklist.name,
			client.company_name,
			client_checklist.progress,
			client_checklist.initial_score,
			client_checklist.current_score,
			client_checklist_status.status,
			ROUND(IFNULL((client_checklist.current_score * 100),0)) AS `score_formatted`,
			client_checklist.created AS created_timestamp,
			DATE_FORMAT(client_checklist.created, "%%e/%%c/%%Y %%l:%%i:%%s %p") AS created,
			DATE_FORMAT(client_checklist.created, "%%e/%%c/%%Y") AS started_date,
			client_checklist.completed AS completed_timestamp,
			DATE_FORMAT(client_checklist.completed, "%%e/%%c/%%Y %%l:%%i:%%s %p") AS completed,
			DATE_FORMAT(client_checklist.completed, "%%e/%%c/%%Y") AS completed_date,
			client_checklist.date_range_start AS date_range_start_timestamp,
			DATE_FORMAT(client_checklist.date_range_start, "%%e/%%c/%%Y %%l:%%i:%%s %%p") AS date_range_start,
			DATE_FORMAT(client_checklist.date_range_start, "%%M") AS date_range_start_month,
			DATE_FORMAT(client_checklist.date_range_start, "%%b") AS date_range_start_month_short,
			DATE_FORMAT(client_checklist.date_range_start, "%%Y") AS date_range_start_year,
			client_checklist.date_range_finish AS date_range_finish_timestamp,
			DATE_FORMAT(client_checklist.date_range_finish, "%%e/%%c/%%Y %%l:%%i:%%s %%p") AS date_range_finish,
			DATE_FORMAT(client_checklist.date_range_finish, "%%M") AS date_range_finish_month,
			DATE_FORMAT(client_checklist.date_range_finish, "%%b") AS date_range_finish_month_short,
			DATE_FORMAT(client_checklist.date_range_finish, "%%Y") AS date_range_finish_year,
			(SELECT COUNT(cc2.client_checklist_id) FROM %2$s.client_checklist cc2 WHERE cc2.client_id = client_checklist.client_id AND cc2.checklist_id = client_checklist.checklist_id AND cc2.client_checklist_id != client_checklist.client_checklist_id) AS siblings
			FROM %2$s.client_checklist
			LEFT JOIN %2$s.checklist ON client_checklist.checklist_id = checklist.checklist_id
			LEFT JOIN %1$s.client ON client_checklist.client_id = client.client_id
			LEFT JOIN `%2$s`.`client_checklist_status` ON `client_checklist`.`status` = `client_checklist_status`.`client_checklist_status_id`
			WHERE client_checklist.client_checklist_id = %3$d
		',
			DB_PREFIX.'core',
			DB_PREFIX.'checklist',
			$this->db->escape_string($this->client_checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clientChecklistNode = $this->node->appendChild($this->createNodeFromRecord('client_checklist', $row, array_keys((array)$row)));
				$report = $clientChecklist->getReport($this->client_checklist_id, 0, false);
			
				foreach($report->report_sections as $reportSection) {
					$reportSectionNodeNode = $clientChecklistNode->appendChild($this->createNodeFromRecord('reportSection', $reportSection, array_keys((array)$reportSection)));
				}

				foreach($report->actions as $action) {
					$actionNode = $clientChecklistNode->appendChild($this->createNodeFromRecord('action', $action, array_keys((array)$action)));
				}
			}
			$result->close();
		}

		return;
	}

	private function getClients() {
		$clients = array();

		//Get all Clients if no client_id is set, otherwise, just get the client that is set
		$query = sprintf('
			SELECT
			`client`.*,
			if(MAX(`client_contact_log`.`timestamp`) != NULL, MAX(`client_contact_log`.`timestamp`), `client`.`registered`) AS `last_active`
			FROM `%1$s`.`client`
			LEFT JOIN `%1$s`.`client_contact_log` ON `client`.`client_id` = `client_contact_log`.`client_id`
			WHERE `client`.`company_name` IS NOT NULL
			AND `client`.`client_id` IN (%2$s)
			GROUP BY `client`.`client_id`
			ORDER BY `client`.`company_name`
		',
			DB_PREFIX.'core',
			!isset($_REQUEST['client_id']) ? $this->db->escape_string(implode(',',resultFilter::filtered_client_array($this->db, $this->contact))) : (in_array($_REQUEST['client_id'], resultFilter::filtered_client_array($this->db, $this->contact)) ? $_REQUEST['client_id'] : null)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {

				$row->created_formatted = new stdClass;
				$row->created_formatted->date_time = !is_null($row->registered) ? date_format(date_create($row->registered), "j/n/Y h:i A") : null;
				$row->created_formatted->order = !is_null($row->registered) ? $row->registered : null;

				$row->last_active_formatted = new stdClass;
				$row->last_active_formatted->date_time = !is_null($row->last_active) ? date_format(date_create($row->last_active), "j/n/Y h:i A") : null;
				$row->last_active_formatted->order = !is_null($row->last_active) ? $row->last_active : null;
				$row->last_active_pretty = !is_null($row->last_active) ? date_format(date_create($row->last_active), "j/n/Y h:i A") : null;
				$row->last_active_pretty_date = !is_null($row->last_active) ? date_format(date_create($row->last_active), "j/n/Y") : null;
				$row->last_active_pretty_date_word = !is_null($row->last_active) ? date_format(date_create($row->last_active), "j F Y") : null;
				$row->last_active_pretty_time = !is_null($row->last_active) ? date_format(date_create($row->last_active), "h:i A") : null;
			
				$clients[] = $row;
			}
			$result->close();
		}

		return $clients;
	}

	private function getClientsQuery() {

		$query = sprintf('
			SELECT 
			`client`.*,
			DATE_FORMAT(`client`.`registered`, \"%%e/%%c/%%Y %%h:%%i %%p\") as `created_date_time`, 
			`client_contact_log`.`timestamp` AS `last_active_timestamp`,
			DATE_FORMAT(`client_contact_log`.`timestamp`, \"%%e/%%c/%%Y %%h:%%i %%p\") as `last_active`, 
			DATE_FORMAT(`client_contact_log`.`timestamp`, \"%%e/%%c/%%Y\") as `last_active_date`, 
			DATE_FORMAT(`client_contact_log`.`timestamp`, \"%%e %%M %%Y\") as `last_active_word`, 
			DATE_FORMAT(`client_contact_log`.`timestamp`, \"%%h:%%i %%p\") as `last_active_time`,
			(SELECT COUNT(*) FROM `%1$s`.`client_contact` WHERE `client_contact`.`client_id` = `client`.`client_id`) AS `users`, 
			(SELECT COUNT(*) FROM `%2$s`.`client_checklist` WHERE `client`.`client_id` = `client_checklist`.`client_id` AND `client_checklist`.`checklist_id` IN(%4$s) AND `client_checklist`.`status` != 4) AS `entries`
			FROM `%1$s`.`client`
			LEFT JOIN (SELECT `client_contact_log`.`client_id`, MAX(`client_contact_log`.`timestamp`) AS `timestamp` FROM `greenbiz_core`.`client_contact_log` GROUP BY `client_contact_log`.`client_id`) `client_contact_log` ON `client`.`client_id` = `client_contact_log`.`client_id`
			WHERE `client`.`company_name` IS NOT NULL 
			AND `client`.`client_id` IN (%3$s) 
			GROUP BY `client`.`client_id` 
			ORDER BY `client`.`company_name`
		',
			DB_PREFIX.'core',
			DB_PREFIX.'checklist',
			!isset($_REQUEST['client_id']) ? $this->db->escape_string(implode(',',resultFilter::filtered_client_array($this->db, $this->contact))) : (in_array($_REQUEST['client_id'], resultFilter::filtered_client_array($this->db, $this->contact)) ? $_REQUEST['client_id'] : null),
			implode(',',resultFilter::accessible_checklists($this->db, $this->contact))
		);

		return $query;
	}

	private function getClientCoordinates() {
		$clientCoordinates = array();

		//Get all Clients if no client_id is set, otherwise, just get the client that is set
		if($result = $this->db->query(sprintf('
			SELECT
			`client`.`client_id`,
            `client`.`company_name`,
			`client_coordinates`.`lat`,
            `client_coordinates`.`lng`,
            `client`.`address_line_1`,
            `client`.`address_line_2`,
            `client`.`suburb`,
            `client`.`state`,
            `client`.`postcode`,
            `client`.`country`,
            `client_alert`.`client_alert_id`
			FROM `%1$s`.`client`
			LEFT JOIN `%1$s`.`client_coordinates` ON `client`.`client_id` = `client_coordinates`.`client_id`
			LEFT JOIN `%2$s`.`client_alert` ON `client`.`client_id` = `client_alert`.`client_id`
			WHERE `client`.`company_name` IS NOT NULL
            AND `client`.`company_name` != ""
            AND `client_coordinates`.`lat` IS NOT NULL
            AND `client_coordinates`.`lng` IS NOT NULL
			AND `client`.`client_id` IN (%3$s)
			GROUP BY `client`.`client_id`
			ORDER BY `client`.`company_name`
		',
			DB_PREFIX.'core',
			DB_PREFIX.'dashboard',
			!isset($_REQUEST['client_id']) ? $this->db->escape_string(is_array(resultFilter::filtered_client_array($this->db, $this->contact)) ? implode(',',resultFilter::filtered_client_array($this->db, $this->contact)) : resultFilter::filtered_client_array($this->db, $this->contact)) : (in_array($_REQUEST['client_id'], resultFilter::filtered_client_array($this->db, $this->contact)) ? $_REQUEST['client_id'] : null)
		))) {
			while($row = $result->fetch_object()) {
			
				$clientCoordinates[] = $row;
			}
			$result->close();
		}

		return $clientCoordinates;
	}


	private function getClientChecklists() {
		$clientChecklists = array();
		$clientChecklist = new clientChecklist($this->db);

		if($result = $this->db->query(sprintf('
			SELECT
			`client_checklist`.*,
			IF(`client_checklist`.`completed` IS NULL, `progress`, "100") AS `progress`,
			`checklist`.`name` AS `checklist_name`,
            `client`.`company_name`,
			`client_checklist_status`.`status` AS `status`,
            IF(`client_checklist`.`current_score` IS NULL, NULL, CONCAT(FORMAT((`current_score` * 100),2),"%%")) AS `score`,
            CONCAT(ROUND(IFNULL((`current_score` * 100),0)),"%%") AS `score_round_formatted`,
            ROUND(IFNULL((`current_score` * 100),0)) AS `score_formatted`,
            DATE_FORMAT(`client_checklist`.`created`, "%%d/%%m/%%Y") AS `started_date`,
            DATE_FORMAT(`client_checklist`.`completed`, "%%d/%%m/%%Y") AS `completed_date`,
            IF(`client_checklist`.`completed` IS NULL, "No","Yes") AS `finished`
			FROM `%1$s`.`client_checklist`
			LEFT JOIN `%2$s`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
			LEFT JOIN `%1$s`.`checklist` ON `client_checklist`.`checklist_id` = `checklist`.`checklist_id`
			LEFT JOIN `%1$s`.`client_checklist_status` ON `client_checklist`.`status` = `client_checklist_status`.`client_checklist_status_id`
			WHERE `client`.`company_name` IS NOT NULL
			AND `client_checklist`.`client_checklist_id` IN (%3$s)
			AND `client_checklist`.`client_id` IN (%4$s)
			GROUP BY `client_checklist`.`client_checklist_id`
			ORDER BY `client_checklist`.`created` DESC
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			!isset($_REQUEST['client_checklist_id']) ? $this->db->escape_string(implode(',',resultFilter::filtered_client_checklist_array($this->db, $this->contact))) : (in_array($_REQUEST['client_checklist_id'], resultFilter::filtered_client_checklist_array($this->db, $this->contact)) ? $_REQUEST['client_checklist_id'] : null),
			!isset($_REQUEST['client_id']) ? $this->db->escape_string(implode(',',resultFilter::filtered_client_array($this->db, $this->contact))) : (in_array($_REQUEST['client_id'], resultFilter::filtered_client_array($this->db, $this->contact)) ? $_REQUEST['client_id'] : null)
		))) {
			while($row = $result->fetch_object()) {

				//Format the dates
				$row = $clientChecklist->setClientChecklistDateFormats($row);
				$clientChecklists[] = $row;
			}
	
			$result->close();
		}

		return $clientChecklists;
	}

	private function getClientChecklistsQuery($checklists = null) {

		$query = sprintf('
			SELECT 
			`client_checklist`.`client_checklist_id`, 
			`client_checklist`.`date_range_start`, 
			`client_checklist`.`date_range_finish`, 
			`client_checklist`.`created` AS `created_timestamp`, 
			`client_checklist`.`completed` AS `completed_timestamp`, 
			`client_checklist`.`client_id`,
			`client_checklist_status`.`status`,
			IF(`client_checklist`.`completed` IS NULL, `progress`, \"100\") AS `progress`, 
			`checklist`.`name` AS `checklist_name`,
			`client_checklist`.`name`,
			`client`.`company_name`,
			`all_results`.`min_timestamp` AS `first_modified_timestamp`,
			`all_results`.`max_timestamp` AS `last_modified_timestamp`,
			DATE_FORMAT(`all_results`.`min_timestamp`, \"%%e/%%c/%%Y %%h:%%i %%p\") AS `first_modified`,
			DATE_FORMAT(`all_results`.`max_timestamp`, \"%%e/%%c/%%Y %%h:%%i %%p\") AS `last_modified`,
			IF(`client_checklist`.`current_score` IS NULL, NULL, CONCAT(FORMAT((`current_score` * 100),2),\"%%\")) AS `score`,
			IF(`client_checklist`.`current_score` IS NULL, 0, `client_checklist`.`current_score`) AS `score_decimal`, 
			CONCAT(ROUND(IFNULL((`current_score` * 100),0)),\"%%\") AS `score_round_formatted`, 
			ROUND(IFNULL((`current_score` * 100),0)) AS `score_formatted`, 
			DATE_FORMAT(`client_checklist`.`created`, \"%%e/%%c/%%Y %%h:%%i %%p\") AS `created`,
			DATE_FORMAT(`client_checklist`.`created`, \"%%e/%%c/%%Y\") AS `created_date`, 
			DATE_FORMAT(`client_checklist`.`completed`, \"%%e/%%c/%%Y %%h:%%i %%p\") AS `completed`,
			DATE_FORMAT(`client_checklist`.`completed`, \"%%e/%%c/%%Y\") AS `completed_date`,
			IF(`client_checklist`.`completed` IS NULL, \"No\",\"Yes\") AS `finished`, 
			DATE_FORMAT(`client_checklist`.`date_range_start`, \"%%Y\") AS `date_range_start_year`, 
			DATE_FORMAT(`client_checklist`.`date_range_start`, \"%%M\") AS `date_range_start_month`, 
			DATE_FORMAT(`client_checklist`.`date_range_start`, \"%%M %%Y\") AS `date_range_start_month_year`, 
			DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%Y\") AS `date_range_finish_year`, 
			DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%M\") AS `date_range_finish_month`, 
			DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%M %%Y\") AS `date_range_finish_month_year` 
			FROM `%1$s`.`client_checklist` 
			LEFT JOIN `%2$s`.`client` ON `client_checklist`.`client_id` = `client`.`client_id` 
			LEFT JOIN `%1$s`.`checklist` ON `client_checklist`.`checklist_id` = `checklist`.`checklist_id`
			LEFT JOIN `%1$s`.`client_checklist_status` ON `client_checklist`.`status` = `client_checklist_status`.`client_checklist_status_id`
			LEFT JOIN 

			(SELECT
			`all_results`.`client_checklist_id`,
			MAX(`all_results`.`timestamp`) AS `max_timestamp`,
			MIN(`all_results`.`timestamp`) AS `min_timestamp`
			FROM
			(SELECT 
			`client_result`.`client_checklist_id`, 
			`client_result`.`timestamp`
			FROM `%1$s`.`client_result`
			WHERE `client_result`.`client_checklist_id` IN (%3$s) 

			UNION

			SELECT 
			`client_metric`.`client_checklist_id`, 
			`client_metric`.`timestamp`
			FROM `%1$s`.`client_metric`
			WHERE `client_metric`.`client_checklist_id` IN (%3$s) 

			UNION 

			SELECT 
			`client_site_result`.`client_checklist_id`, 
			`client_site_result`.`timestamp`
			FROM `%1$s`.`client_site_result`
			WHERE `client_site_result`.`client_checklist_id` IN (%3$s) 

			UNION 

			SELECT 
			`client_sub_metric`.`client_checklist_id`, 
			`client_sub_metric`.`timestamp`
			FROM `%1$s`.`client_sub_metric`
			WHERE `client_sub_metric`.`client_checklist_id` IN (%3$s) ) `all_results`
			GROUP BY `all_results`.`client_checklist_id`) `all_results` ON `client_checklist`.`client_checklist_id` = `all_results`.`client_checklist_id`

			WHERE `client`.`company_name` IS NOT NULL 
			AND `client_checklist`.`client_checklist_id` IN (%3$s) 
			AND `client_checklist`.`client_id` IN (%4$s)
			AND `checklist`.`archived` != 1
			' . (!is_null($checklists) ? ' AND client_checklist.checklist_id IN(%5$s) ' : '') . '

			GROUP BY `client_checklist`.`client_checklist_id` 
			ORDER BY `client_checklist`.`created` DESC
		',
			DB_PREFIX.'checklist',
			DB_PREFIX.'core',
			!isset($_REQUEST['client_checklist_id']) ? $this->db->escape_string(implode(',',resultFilter::filtered_client_checklist_array($this->db, $this->contact))) : (in_array($_REQUEST['client_checklist_id'],resultFilter::filtered_client_checklist_array($this->db, $this->contact)) ? $_REQUEST['client_checklist_id'] : null),
			!isset($_REQUEST['client_id']) ? $this->db->escape_string(implode(',',resultFilter::filtered_client_array($this->db, $this->contact))) : (in_array($_REQUEST['client_id'], resultFilter::filtered_client_array($this->db, $this->contact)) ? $_REQUEST['client_id'] : null),
			$this->db->escape_string(!is_null($checklists) ? $checklists : null)
		);

		return $query;
	}
	
	private function getChecklists() {
		$checklists = array();

		//Get the Accessible checklists
		if($result = $this->db->query(sprintf('
			SELECT
			`checklist`.*,
			IFNULL(`checklist_count`.`count`,0) AS `count`,
			IFNULL(`checklist_completed`.`count`,0) AS `completed_count`,
			IFNULL(`checklist_incomplete`.`count`,0) AS `incomplete_count`,
			CONCAT(ROUND((IFNULL((`checklist_score`.`score`/`checklist_score`.`count`),0) * 100)),"%%") AS `average_score_formatted`,
			FORMAT((IFNULL((`checklist_score`.`score`/`checklist_score`.`count`),0) * 100),2) AS `average_score`,
			CONCAT(ROUND((IFNULL((`checklist_completed`.`count`/`checklist_count`.`count`),0) * 100)),"%%") AS `completion_rate_formatted`,
			FORMAT((IFNULL((`checklist_completed`.`count`/`checklist_count`.`count`),0) * 100),2) AS `completion_rate`
			FROM `%1$s`.`checklist`
			LEFT JOIN (
				SELECT 
			    `client_checklist`.`checklist_id`,
			    COUNT(`client_checklist`.`checklist_id`) AS `count`
			    FROM `%1$s`.`client_checklist`
			    GROUP BY `client_checklist`.`checklist_id`
			    ) `checklist_count` ON `checklist`.`checklist_id` = `checklist_count`.`checklist_id`

			LEFT JOIN (
				SELECT
			    `client_checklist`.`checklist_id`,
			    COUNT(`client_checklist`.`checklist_id`) AS `count`
			    FROM `%1$s`.`client_checklist` 
			    WHERE `client_checklist`.`created` IS NOT NULL 
			    AND `client_checklist`.`completed` IS NOT NULL
			    GROUP BY `client_checklist`.`checklist_id`
			    ) `checklist_completed` ON `checklist`.`checklist_id` = `checklist_completed`.`checklist_id`
    
			LEFT JOIN (
				SELECT
			    `client_checklist`.`checklist_id`,
			    COUNT(`client_checklist`.`checklist_id`) AS `count`
			    FROM `%1$s`.`client_checklist` 
			    WHERE `client_checklist`.`created` IS NOT NULL 
			    AND `client_checklist`.`completed` IS NULL
			    GROUP BY `client_checklist`.`checklist_id`
			    ) `checklist_incomplete` ON `checklist`.`checklist_id` = `checklist_incomplete`.`checklist_id`
    
			LEFT JOIN (
				SELECT
			    `client_checklist`.`checklist_id`,
			    COUNT(`client_checklist`.`checklist_id`) AS `count`,
			    SUM(`client_checklist`.`current_score`) AS `score`
			    FROM `%1$s`.`client_checklist` 
			    WHERE `client_checklist`.`created` IS NOT NULL 
			    AND `client_checklist`.`completed` IS NOT NULL
			    GROUP BY `client_checklist`.`checklist_id`
			    ) `checklist_score` ON `checklist`.`checklist_id` = `checklist_score`.`checklist_id`
    
			WHERE `checklist`.`checklist_id` IN (%2$s)
			ORDER BY `checklist`.`checklist_id`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string(implode(',',resultFilter::accessible_checklists($this->db, $this->contact)))
		))) {
			while($row = $result->fetch_object()) {
			
				$checklists[] = $row;
			}
			$result->close();
		}

		return $checklists;
	}
	
	private function getPages() {
		$pages = array();
		//Get the Accessible checklist pages
		if($result = $this->db->query(sprintf('
			SELECT
			`page`.`page_id`,
			`page`.`checklist_id`,
			`page`.`sequence`,
			`page`.`title`,
			`page_section`.`title` as `page_section_title`,
			`page_section_2_page`.`page_section_id`,
			IF (`page_section_2_page`.`page_section_id` IS NOT NULL, CONCAT(`page_section`.`title`, " - ", `page`.`title`), `page`.`title`) AS `formatted_page_title`
			FROM `%1$s`.`page`
			LEFT JOIN `%1$s`.`page_section_2_page` ON `page_section_2_page`.`page_id` = `page`.`page_id`
			LEFT JOIN `%1$s`.`page_section` ON `page_section`.`page_section_id` = `page_section_2_page`.`page_section_id`
			WHERE `page`.`checklist_id` IN (%2$s)
			ORDER BY `page`.`checklist_id`, `page`.`sequence`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string(implode(',',resultFilter::accessible_checklists($this->db, $this->contact)))
		))) {
			while($row = $result->fetch_object()) {
			
				$pages[] = $row;
			}
			$result->close();
		}
		return $pages;
	}

	private function getPageSections() {
		$pageSections = array();
		//Get the Accessible checklist pages
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`page_section`
			WHERE `page_section`.`checklist_id` IN (%2$s)
			ORDER BY `page_section`.`sequence`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string(implode(',',resultFilter::accessible_checklists($this->db, $this->contact)))
		))) {
			while($row = $result->fetch_object()) {
			
				$pageSections[] = $row;
			}
			$result->close();
		}
		return $pageSections;
	}
	
	private function getQuestions() {
		$questions = array();
		//Get the Accessible checklist questions
		if($result = $this->db->query(sprintf('
			SELECT
			`question`.`question_id`,
			`question`.`checklist_id`,
			`question`.`page_id`,
			`question`.`question`,
			`question`.`sequence`
			FROM `%1$s`.`question`
			WHERE `question`.`checklist_id` IN (%2$s)
			ORDER BY `question`.`sequence`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string(implode(',',resultFilter::accessible_checklists($this->db, $this->contact)))
		))) {
			while($row = $result->fetch_object()) {
			
				$questions[] = $row;
			}
			$result->close();
		}
		return $questions;
	}

	private function getMetricGroups() {
		$metricGroups = array();
		//Get the Accessible checklist metrics
		if($result = $this->db->query(sprintf('
			SELECT
			`metric_group`.*
			FROM `%1$s`.`metric_group`
			LEFT JOIN `%1$s`.`page` ON `metric_group`.`page_id` = `page`.`page_id`
			WHERE `page`.`checklist_id` IN (%2$s)
			ORDER BY `metric_group`.`sequence`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string(implode(',',resultFilter::accessible_checklists($this->db, $this->contact)))
		))) {
			while($row = $result->fetch_object()) {
			
				$metricGroups[] = $row;
			}
			$result->close();
		}
		return $metricGroups;
	}

	private function getMetrics() {
		$metrics = array();

		$query = sprintf('
			SELECT
			`metric`.*,
			`metric_group`.`name` as `metric_group_name`,
			`default_metric_unit_type`.`metric_unit_type` AS `default_unit`,
			(
				SELECT 
					GROUP_CONCAT(`other_metric_unit_type`.`metric_unit_type`)
			    FROM `%1$s`.`metric_unit_type_2_metric` `other_metric_unit`
			    LEFT JOIN `%1$s`.`metric_unit_type` `other_metric_unit_type` ON `other_metric_unit`.`metric_unit_type_id` = `other_metric_unit_type`.`metric_unit_type_id`
				WHERE `other_metric_unit`.`metric_id` = `metric`.`metric_id`
			    AND `other_metric_unit`.`default` != "1"
			) AS `other_units`
			FROM `%1$s`.`metric`
			LEFT JOIN `%1$s`.`metric_group` ON `metric`.`metric_group_id` = `metric_group`.`metric_group_id`
			LEFT JOIN `%1$s`.`metric_unit_type_2_metric` `default_metric_unit` ON `metric`.`metric_id` = `default_metric_unit`.`metric_id`
			LEFT JOIN `%1$s`.`metric_unit_type` `default_metric_unit_type` ON `default_metric_unit`.`metric_unit_type_id` = `default_metric_unit_type`.`metric_unit_type_id`
			LEFT JOIN `%1$s`.`page` ON `metric_group`.`page_id` = `page`.`page_id`
			WHERE `page`.`checklist_id` IN (%2$s)
			AND `default_metric_unit`.`default` = "1"
			ORDER BY `metric`.`sequence`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string(implode(',',resultFilter::accessible_checklists($this->db, $this->contact)))
		);

		//Get the Accessible checklist metrics
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
			
				$metrics[] = $row;
			}
			$result->close();
		}
		return $metrics;
	}

	private function getClientChecklistMetrics($client_checklist_id) {
		$clientMetrics = array();
		$clientChecklist = new clientChecklist($this->db);

		//Checklist Pages
		$checklistPages = $clientChecklist->getChecklistPages($client_checklist_id);
		foreach($checklistPages as $checklistPage) {
			$metricGroups = $clientChecklist->getPageMetricGroups($checklistPage->page_id, $client_checklist_id);
			$clientMetrics = $metricGroups;
		}

		return $clientMetrics;
	}

	private function getClientChecklistAnswers($client_checklist_id, &$clientChecklistNode, $withReport = false) {

		$clientChecklist = new clientChecklist($this->db);
		
		//Client Results
		$clientResults = $clientChecklist->getClientResults($client_checklist_id);
		foreach($clientResults as $clientResult) {
			$clientResult->arbitrary_value = str_replace("<br/>","<br/><br/>",nl2br(mb_convert_encoding($clientResult->arbitrary_value,"HTML-ENTITIES","UTF-8")));
			$clientResultNode = $clientChecklistNode->appendChild($this->createNodeFromRecord('client_result', $clientResult, array_keys((array)$clientResult)));
		}
			
		//Checklist Pages
		$checklistPages = $clientChecklist->getChecklistPages($client_checklist_id);
		foreach($checklistPages as $checklistPage) {
			$checklistPageNode = $clientChecklistNode->appendChild($this->createNodeFromRecord('checklistPage', $checklistPage, array_keys((array)$checklistPage)));

			//Get the Metrics 
			$metricGroups = $clientChecklist->getPageMetricGroups($checklistPage->page_id, $client_checklist_id);
			foreach($metricGroups as $metricGroup) {
				$metricGroupNode = $checklistPageNode->appendChild(
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
				}
			}
		}
		
		//Checklist Questions
		$pageQuestions = $clientChecklist->getClientChecklistQuestions($client_checklist_id);
		foreach($pageQuestions as $pageQuestion) {
			$questionNode = $clientChecklistNode->appendChild($this->createNodeFromRecord('question', $pageQuestion, array_keys((array)$pageQuestion)));
		}
		
		//Checklist Answers
		$questionAnswers = $clientChecklist->getClientChecklistAnswers($client_checklist_id);
		foreach($questionAnswers as $questionAnswer) {
			$answertNode = $clientChecklistNode->appendChild($this->createNodeFromRecord('answer', $questionAnswer, array_keys((array)$questionAnswer)));
		}

		//Get the report sections
		if((isset($_REQUEST['client_checklist_id']) && $_REQUEST['client_checklist_id'] == $client_checklist_id) OR $withReport === true) {
			$report = $clientChecklist->getReport($client_checklist_id, 0, false);
			
			//Report Sections
			foreach($report->report_sections as $reportSection) {
				$reportSectionNodeNode = $clientChecklistNode->appendChild($this->createNodeFromRecord('reportSection', $reportSection, array_keys((array)$reportSection)));
			}

			//Report Actions
			foreach($report->actions as $action) {
				$actionNode = $clientChecklistNode->appendChild($this->createNodeFromRecord('action', $action, array_keys((array)$action)));
			}
		}

		return;
	}

	private function getClientContacts($client_id) {
		$clientContacts = array();

		//Get the Accessible checklist questions
		if($result = $this->db->query(sprintf('
			SELECT
			`client_contact`.`client_contact_id`,
            `client_contact`.`client_id`,
            `client_contact`.`firstname`,
            `client_contact`.`lastname`,
            `client_contact`.`phone`,
            `client_contact`.`email`,
            `client_contact`.`position`,
            `client_contact`.`is_client_admin`,
            max(`client_contact_log`.`timestamp`) AS `last_active`,
			DATE_FORMAT(max(`client_contact_log`.`timestamp`), "%%d/%%m/%%Y") AS `last_active_date`,
            DATE_FORMAT(max(`client_contact_log`.`timestamp`), "%%h:%%i %%p") AS `last_active_time`
			FROM `%1$s`.`client_contact`
            LEFT JOIN `%1$s`.`client_contact_log` ON `client_contact`.`client_contact_id` = `client_contact_log`.`client_contact_id`
			WHERE `client_contact`.`client_id` IN (%2$d)
			ORDER BY `client_contact`.`lastname`, `client_contact`.`firstname`
		',
			DB_PREFIX.'core',
			$this->db->escape_string($client_id)
		))) {
			while($row = $result->fetch_object()) {
			
				$clientContacts[] = $row;
			}
			$result->close();
		}

		return $clientContacts;
	}

	//Check for any post or get variables
	private function processPostbackFunctions() {
		$refresh = false;
		
		if(isset($_REQUEST['action'])) {

			//Data Table Based Form
			if(isset($_REQUEST['row-index'])) {
				$response = '';
				switch($_REQUEST['action']) {

					//*** Entity ***
					//Delete
					case 'entity-delete':
						$client = new client($this->db);
						$result = $client->deleteClients(implode(',',$_REQUEST['row-index']));
						$refresh = true;
					break;

					//Archive
					case 'entity-archive':
						$client = new client($this->db);
						$result = $client->archiveClients(implode(',',$_REQUEST['row-index']));
						$refresh = true;
					break;

					//*** User ***
					//Delete
					case 'user-delete':
						$clientContact = new clientContact($this->db);
						$response = $clientContact->deleteClientContacts(implode(',',$_REQUEST['row-index']));
						$GLOBALS['core']->session->setSessionVar('messages',$response->messages);
					break;

					//*** Entry ***
					//Delete
					case 'entry-delete':
						$clientChecklist = new clientChecklist($this->db);
						$filteredClientChecklistArray = $this->getFilteredClientChecklistArray($_REQUEST['row-index']);
						$result = $clientChecklist->deleteClientChecklists(implode(',',$filteredClientChecklistArray));
						$response = $result > 0 ? 'success' : 'fail';
						$refresh = true;
					break;

					//Set Status
					case 'entry-open':
					case 'entry-closed':
					case 'entry-locked':
					case 'entry-archived':
						$clientChecklist = new clientChecklist($this->db);
						$filteredClientChecklistArray = $this->getFilteredClientChecklistArray($_REQUEST['row-index']);

						//Get Status
						$status = $clientChecklist->getStatusCode(str_replace('entry-','',$_REQUEST['action']));

						//Set Status
						$result = $clientChecklist->setStatus($status, $filteredClientChecklistArray);

						//Set Progress
						$progress = $status === 1 ? $clientChecklist->setProgress($filteredClientChecklistArray, 0, false) : null;
						$progress = $status === 2 ? $clientChecklist->setProgress($filteredClientChecklistArray, 100, true) : null;

						//Process GHG on closed
						if($status === 2) {
							//Set the script processing limits
							set_time_limit(0);
							ini_set('memory_limit', '1024M');
							foreach($filteredClientChecklistArray as $client_checklist_id) {
								ghg::db($this->db)->processTriggers($client_checklist_id);
							}
							set_time_limit(30);
							ini_set('memory_limit', '200M');
						}

						$response = $result > 0 ? 'success' : 'fail';
					break;

					//*** Settings ***/
					//Delete Group
					case 'settings-group-delete':
						$result = $this->dashboard->deleteGroups($_REQUEST['row-index']);
						$refresh = true;
					break;

					default: $response = 'invalid';
				}

				if($refresh) {
					header('Location: '.$_SERVER['REQUEST_URI']);
					die();
				}
			}	
		}

		return;
	}

	public function getAnalytics() {

		//Checklist Pivot Tables
		if(isset($_REQUEST['report']) && $_REQUEST['report'] == "checklistPivotTableReport") {
		
			//Check for the checklist_id
			if(isset($_REQUEST['checklist_id']) && in_array($_REQUEST['checklist_id'], resultFilter::accessible_checklists($this->db, $this->contact))) {

				//Checklist Data for Pivot Table
				$clientChecklist = new clientChecklist($this->db);
				$data = $clientChecklist->getChecklistResultsPivotTable($_REQUEST['checklist_id'], isset($_REQUEST['from']) ? $_REQUEST['from'] : null, isset($_REQUEST['to']) ? $_REQUEST['to'] : null, resultFilter::conditional_client_checklist_filter($this->db, $this->contact));
		
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
			if(isset($_REQUEST['checklist_id']) && (in_array($_REQUEST['checklist_id'], resultFilter::accessible_checklists($this->db, $this->contact))) || $_REQUEST['checklist_id'] == 0) {

				$client_checklist_id = $_REQUEST['checklist_id'] == 0 ? resultFilter::accessible_checklists($this->db, $this->contact) : $_REQUEST['checklist_id'];

				//Checklist Data for Pivot Table
				$clientChecklist = new clientChecklist($this->db);
				$data = $clientChecklist->getChecklistResultsWithClientInformation($client_checklist_id, isset($_REQUEST['from']) ? $_REQUEST['from'] : null, isset($_REQUEST['to']) ? $_REQUEST['to'] : null, resultFilter::conditional_client_checklist_filter($this->db, $this->contact));
		
				//CSVBuilder Class
				$csvBuilder = new csvBuilder($this->db);
				$csvBuilder->buildCSV($data); 
			}
		
			die();
		}

		return;
	}

	private function getFilteredClientChecklistArray($client_checklist_array) {
		$filtered_client_checklist_array = array();

		foreach($client_checklist_array as $client_checklist_id) {
			if(in_array($client_checklist_id, resultFilter::accessible_client_checklists($this->db, $this->contact))) {
				$filtered_client_checklist_array[] = $client_checklist_id;
			}
		}

		return $filtered_client_checklist_array;
	}

	//Add/Edit/Delete Entry
	public function entry() {
		$params = $this->setParams();
		$params->mode = isset($params->mode) ? $params->mode : 'list';

		switch($params->mode) {

			case 'emission_factors_list' : $this->entryEmissionFactorsList();
			break;

			case 'entry_answer_functions' : $this->entryAnswerFunctions();
			break;

			case 'entry_variation' : $this->getEntryVariation();
			break;

			case 'entry_validation' : $this->getEntryValidation();
			break;

			case 'client_metric_results' : $this->getClientMetricResults();
			break;

			case 'compare' : $this->compareEntry();
			break;

			case 'client_metric_emissions' : $this->getClientMetricEmissions();
			break;

			default: $this->entryList($params);
			break;
		}

		return;
	}

	/**
	* Get Action Plan
	*/

	public function actionPlan() {
		$clientChecklist = new clientChecklist($this->db);
		$client_checklist_id = null;

		if(isset($_REQUEST['client_checklist_id'])) {
			$client_checklist_id = $_REQUEST['client_checklist_id'];
		} else {
			return;
		}

		//Get Report
		$report = $clientChecklist->getReport($client_checklist_id);

		/*
		echo "<pre>";
		var_dump($report);
		echo "</pre>";
		*/

		foreach($report->reportSections as $reportSection) {
			$reportSectionNode = $this->node->appendChild($this->createNodeFromRecord('reportSection', $reportSection, array_keys((array)$reportSection)));
			foreach($report->actions as $action) {
				if($action->report_section_id == $reportSection->report_section_id) {
					$actionNode = $reportSectionNode->appendChild($this->createNodeFromRecord('action', $action, array_keys((array)$action)));
					foreach($report->commitments as $commitment) {
						if($commitment->action_id == $action->action_id) {
							$commitmentNode = $actionNode->appendChild($this->createNodeFromRecord('commitment', $commitment, array_keys((array)$commitment)));
						}
					}
				}
			}

			foreach($report->confirmations as $confirmation) {
				if($confirmation->report_section_id == $reportSection->report_section_id) {
					$confirmationNode = $reportSectionNode->appendChild($this->createNodeFromRecord('confirmation', $confirmation, array_keys((array)$confirmation)));
				}
			}
		}

		return;
	}

	private function compareEntry() {

		$clientChecklist = new clientChecklist($this->db);
		$filteredClientChecklistArray = $this->getFilteredClientChecklistArray($_REQUEST['row-index']);
		$result = $clientChecklist->compareClientChecklist(implode(',',$filteredClientChecklistArray));

		foreach($result->clientChecklists as $clientChecklist) {
			$clientChecklistNode = $this->node->appendChild($this->createNodeFromRecord('clientChecklist', $clientChecklist, array_keys((array)$clientChecklist)));
			foreach($clientChecklist->answers as $answer) {
				$answerNode = $clientChecklistNode->appendChild($this->createNodeFromRecord('answer', $answer, array_keys((array)$answer)));
			}
		}
		
		foreach($result->pages as $page) {
			$pageNode = $this->node->appendChild($this->createNodeFromRecord('page', $page, array_keys((array)$page)));
			foreach($result->questions as $question) {
				if($question->page_id === $page->page_id) {
					$questionNode = $pageNode->appendChild($this->createNodeFromRecord('question', $question, array_keys((array)$question)));
				}
			}
		}

		return;
	}

	private function getEntryVariation() {
		if(is_null($this->contact)) return;

		$query = $this->clientChecklist->getClientChecklistVariation(implode(',',resultFilter::filtered_client_checklist_array($this->db, $this->contact)));
		$query = str_replace("\"","\\\"", $query);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		$this->node->setAttribute('mode','entry_variation');
		return;
	}

	/**
	*	Entry Validation
	*/
	private function getEntryValidation() {
		if(is_null($this->contact)) return;
		$response = array();

		$variations = array();
		$validations = $this->clientChecklist->getClientChecklistValidation(resultFilter::filtered_client_checklist_array($this->db, $this->contact));
		foreach($validations as $key=>$validation) {
			$previousClientChecklists = $this->clientChecklist->getPreviousClientChecklists($validation->client_checklist_id);
			$validations[$key]->previous_client_checklist = isset($previousClientChecklists[0]) ? $previousClientChecklists[0] : null;

			//Get the variations for the current client_checklist_id
			if(!isset($variations[$validation->client_checklist_id])) {
				$variations[$validation->client_checklist_id] = $this->clientChecklist->getClientChecklistVariations($validations[$key]->client_checklist_id, $validations[$key]->previous_client_checklist->client_checklist_id);
			}

			foreach($variations[$validation->client_checklist_id]->variations as $question_id=>$variation) {
				if($question_id == $validation->key) {

					$row = new stdClass;
					$row->company_name = $validation->company_name;
					$row->current_period = date('Y', strtotime($validation->date_range_finish));
					$row->current_entry = $validation->client_checklist_id;
					$row->previous_period = date('Y', strtotime($validations[$key]->previous_client_checklist->date_range_finish));
					$row->previous_entry = $validations[$key]->previous_client_checklist->client_checklist_id;
					$row->validation = $validation->variation;
					$row->reason = $validation->reason;
					$row->validation_id = $validation->variation_id;					
					$row->difference = $variation['change']->difference;
					$row->percent = $variation['change']->percent;

					//Concatenate Current Responses
					$current_response = array();
					foreach($variation['currentResponses'] as $currentResponse) {
						$row->section = $currentResponse->page_section_title;
						$row->page = $currentResponse->page_title;
						$row->question = $currentResponse->question;
						switch($currentResponse->answer_type) {
							case 'float':
							case 'int':
								$current_response[] = $currentResponse->arbitrary_value;
								break;

							default:
							$current_response[] = $currentResponse->answer_string;
								break;
						}
					}
					$row->current_response = implode(', ',$current_response);

					//Concatenate Previous Responses
					$previous_response = array();
					if(isset($variation['previousResponses'])) {
						foreach($variation['previousResponses'] as $previousResponse) {
							switch($previousResponse->answer_type) {
								case 'float':
								case 'int':
									$previous_response[] = $previousResponse->arbitrary_value;
									break;

								default:
									$previous_response[] = $previousResponse->answer_string;
									break;
							}
						}
					}
					$row->previous_response = implode(', ',$previous_response);

					$response[] = $row;
				}
			}
		}
		
		$validationsNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('validations'));
		foreach($response as $res) {
			$validationNode = $validationsNode->appendChild($this->createNodeFromRecord('validation', $res, array_keys((array)$res)));
		}

		$this->node->setAttribute('mode','entry_validation');
		return;
	}

	private function entryAnswerFunctions() {
		$this->node->setAttribute('mode','entry_answer_functions');

		$query = sprintf('
			SELECT
			@left := SUBSTRING_INDEX(answer.function, \"|\",1),
			SUBSTRING_INDEX(@left,\"$\",-1) AS type,
			REPLACE(SUBSTRING_INDEX(@left,\"$\",2),\"additionalValue$\",\"\") AS field,
			answer.function_description AS pseudocode
			FROM %1$s.answer
			LEFT JOIN %1$s.question ON answer.question_id = question.question_id
			WHERE question.checklist_id IN(%2$s)
			AND answer.function IS NOT NULL
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string(implode(',',resultFilter::accessible_checklists($this->db, $this->contact)))
		);


		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);	

		return;
	}

	private function entryEmissionFactorsList() {
		$this->node->setAttribute('mode','emission_factors_list');

		$query = sprintf('
			SELECT
			emission_factor.category,
			emission_factor.sub_category,
			emission_factor.key,
			emission_factor.factor,
			emission_factor.unit,
			emission_factor.default_unit
			FROM %1$s.emission_factor
			WHERE emission_factor.checklist_id IN(%2$s)
			ORDER BY emission_factor.category;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string(implode(',',resultFilter::accessible_checklists($this->db, $this->contact)))
		);


		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);	

		return;
	}

	private function entryList($params) {
		$this->node->setAttribute('mode','list');
		$this->setTableColumns($params);

		$query = $this->getClientChecklistsQuery(isset($params->checklists) ? $params->checklists : null);
		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);	

		return;
	}

	//Add/Edit/Delete Entity
	public function entity() {
		$params = $this->setParams();
		$params->mode = isset($params->mode) ? $params->mode : 'list';

		switch($params->mode) {
			case 'add': $this->entityEdit('add');
			break;

			case 'edit': $this->entityEdit('edit');
			break;

			default: $this->entityList($params);
			break;
		}

		return;
	}

	private function entityList($params) {
		$this->node->setAttribute('mode','list');
		$this->setTableColumns($params);
		$query = $this->getClientsQuery();
		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);	

		return;
	}

	//Add and Edit Entity
	private function entityEdit($mode) {
		$this->node->setAttribute('mode', isset($mode) ? $mode : 'add');
		
		//Check the action on post back
		if(isset($_POST['action'])) {
			switch($_POST['action']) {
				case 'addEntity':
					$clientData = array();
					foreach($_POST as $key=>$val) {
						$clientData[$key] = $val;
					}

					$client = new client($this->db);
					$client_id = $client->setClient($clientData);

					if($client_id > 0) {
						header("location: /members/dashboard/account/edit/?client_id=" . $client_id);
					} else {
						//Error
					}

				break;

				case 'editEntity':
					$clientData = array();
					foreach($_POST as $key=>$val) {
						$clientData[$key] = $val;
					}

					$client_id = isset($_POST['client_id']) ? $_POST['client_id'] : null;

					$client = new client($this->db);
					$updated = $client->updateClient($clientData, array('client_id' => $client_id));
					$client->updateClientCoordinates($client_id);

					if($client_id > 0) {
						header("location: /members/dashboard/account/edit/?client_id=" . $client_id);
					} else {
						//Error
					}

				break;
			}
		}

		return;
	}

	//List Users
	public function user() {
		$params = $this->setParams();
		$params->mode = isset($params->mode) ? $params->mode : 'list';

		switch($params->mode) {
			case 'add': $this->userEdit('add');
			break;

			case 'edit': $this->userEdit('edit');
			break;

			case 'log': $this->userLog();
			break;

			default: $this->userList();
			break;
		}

		return;
	}

	private function userList() {
		$this->node->setAttribute('mode','list');
		$query = $this->getUserList();
		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);	

		return;
	}

	private function getUserList() {

		$query = sprintf('
			SELECT
            client_contact.client_contact_id,
            client.client_id,
            CONCAT(client_contact.firstname, \' \', client_contact.lastname) as user,
            client_contact.email,
            client.company_name,
            client_contact_log.last_active_timestamp,
            client_contact_log.last_active
			FROM %1$s.client_contact
            LEFT JOIN %1$s.client ON client_contact.client_id = client.client_id
            LEFT JOIN (SELECT client_contact_log.client_contact_id, MAX(client_contact_log.timestamp) AS last_active_timestamp, DATE_FORMAT(MAX(client_contact_log.timestamp), \"%%e/%%c/%%Y %%l:%%i:%%s %%p\") AS last_active FROM %1$s.client_contact_log WHERE client_contact_log.client_id IN(%2$s) GROUP BY client_contact_log.client_contact_id) client_contact_log ON client_contact.client_contact_id = client_contact_log.client_contact_id
			WHERE client_contact.client_id IN(%2$s)
            GROUP BY client_contact.client_contact_id
            ORDER BY user ASC
            LIMIT 50000;
		',
			DB_PREFIX.'core',
			$this->db->escape_string(implode(',',resultFilter::filtered_client_array($this->db, $this->contact)))
		);

		return $query;
	}

	private function userLog() {
		$this->node->setAttribute('mode','log');
		$query = $this->getUserLog();
		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);	

		return;
	}

	private function getUserLog() {

		$query = sprintf('
			SELECT
			client_contact.client_contact_id,
            client.client_id,
            CONCAT(client_contact.firstname, \" \", client_contact.lastname) as user,
            client.company_name,
            client_contact_log.ip_address,
            client_contact_log.request,
			DATE_FORMAT(client_contact_log.timestamp, \"%%e\/%%c\/%%Y %%l:%%i:%%s %%p\") AS date,
			client_contact_log.timestamp
			FROM greenbiz_core.client_contact_log
            LEFT JOIN greenbiz_core.client_contact ON client_contact_log.client_contact_id = client_contact.client_contact_id
            LEFT JOIN greenbiz_core.client ON client_contact.client_id = client.client_id
			WHERE client_contact_log.client_id IN(%2$s)
			AND request NOT LIKE(\"%%api/v1%%\")
			AND request NOT LIKE(\"%%site-en.json\")
            ORDER BY client_contact_log.timestamp DESC
            LIMIT 50000;
		',
			DB_PREFIX.'core',
			$this->db->escape_string(implode(',',resultFilter::accessible_clients($this->db, $this->contact)))
		);

		return $query;
	}

	//User Add/Edit
	private function userEdit($mode) {
		$this->node->setAttribute('mode', isset($mode) ? $mode : 'add');
		$this->setJsonTableData(null, $this->contact->client_contact_id);
		$clientContact = new clientContact($this->db);
		$client_contact_id = isset($_GET['client_contact_id']) ? $_GET['client_contact_id'] : null;
		
		//Check the action on post back
		if(isset($_POST['action'])) {

			$userData = array();
			foreach($_POST as $key=>$val) {
				$userData[$key] = $val;
			}

			switch($_POST['action']) {
				case 'addUser':

					$response = $clientContact->setClientContact($userData);
					$client_contact_id = $response->result !== false ? $response->result : $client_contact_id;

					if($response->result !== false) {
						$userData['client_contact_id'] = $client_contact_id;
						$roleResponse = $this->dashboard->setDashboardUserRole($userData);
						$response->result = $roleResponse->result;
					}

					$GLOBALS['core']->session->setSessionVar('messages',$response->messages);					

					if($response->result !== false) {		
						header("location: /members/dashboard/user/edit/?client_contact_id=" . $client_contact_id);
						die();
					}

				break;

				case 'editUser':
					if(isset($_POST['locked_out']) && $_POST['locked_out'] == '0') {
						$userData['locked_out_expiry'] = date("Y-m-d H:i:s");
					}				
					$client_contact_id = isset($_POST['client_contact_id']) ? $_POST['client_contact_id'] : $client_contact_id;
					$response = $clientContact->updateClientContact($userData, array('client_contact_id' => $client_contact_id));

					if($response->result !== false) {
						$roleResponse = $this->dashboard->setDashboardUserRole($userData, array('client_contact_id' => $client_contact_id));
						$response->result = $roleResponse->result;
					}
					
					$GLOBALS['core']->session->setSessionVar('messages',$response->messages);

					if($response->result !== false) {
						header("location: /members/dashboard/user/edit/?client_contact_id=" . $client_contact_id);
						die();
					}

				break;
			}
		}

		//Check if the client contact id is set, add the clientContact node
		if(!is_null($client_contact_id)) {
			
			$contact = $clientContact->getClientContacts(null, $client_contact_id, null, false);

			//If the client_id is an accessible client_id, continue
			if(isset($contact->client_id) && in_array($contact->client_id, resultFilter::accessible_clients($this->db, $this->contact))) {
				$clientContactNode = $this->node->appendChild($this->createNodeFromRecord('clientContact', $contact, array_keys((array)$contact)));

				$dashboardUser = $this->dashboard->getDashboardUser($contact->client_contact_id);
				if(!empty($dashboardUser)) {
					$clientContactNode->appendChild($this->createNodeFromRecord('dashboard', $dashboardUser, array_keys((array)$dashboardUser)));
				
					//Client Restriction
					$clientRestrictions = $this->dashboard->getUserClientRestriction($contact->client_contact_id);
					$clientRestrictionNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('clientRestrictions'));
					foreach($clientRestrictions as $clientRestriction) {
						if(in_array($clientRestriction->client_id, resultFilter::accessible_clients($this->db, $this->contact))) {
							$clientRestrictionNode->appendChild($this->createNodeFromRecord('client', $clientRestriction, array_keys((array)$clientRestriction)));
						}
					}

					//Checklist Restriction
					$checklistRestrictions = $this->dashboard->getUserChecklistRestriction($contact->client_contact_id);
					$checklistRestrictionNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('checklistRestrictions'));
					foreach($checklistRestrictions as $checklistRestriction) {
						if(in_array($checklistRestriction->checklist_id, resultFilter::accessible_checklists($this->db, $this->contact))) {
							$checklistRestrictionNode->appendChild($this->createNodeFromRecord('checklist', $checklistRestriction, array_keys((array)$checklistRestriction)));
						}
					}		
				}
			}
		}

		//Accessible clients
		$clients = $this->dashboard->getCompanyNames($this->contact->client_contact_id);
		$clientsNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('clients'));
		foreach($clients as $client) {
			$clientsNode->appendChild($this->createNodeFromRecord('client', $client, array_keys((array)$client)));
		}

		//Accessible checklists
		$checklists = $this->getAccessibleChecklists();
		$checklistsNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('checklists'));
		foreach($checklists as $checklist) {
			$checklistsNode->appendChild($this->createNodeFromRecord('checklist', $checklist, array_keys((array)$checklist)));
		}

		//Dashboard Roles
		$roles = $this->dashboard->getDashboardRoles();
		$rolesNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('roles'));
		foreach($roles as $role) {
			if($role->dashboard_role_id >= $this->dashboardUser->dashboard_role_id) {
				$rolesNode->appendChild($this->createNodeFromRecord('role', $role, array_keys((array)$role)));
			}
		}

		return;
	}


	//Client Results Plugin
	public function clientResults() {
		$params = $this->setParams();
		$params->mode = isset($params->mode) ? $params->mode : 'clientResults';

		switch($params->mode) {
			case 'metrics':
				$this->getMetricResults();
				break;

			case 'entry_results':
				$this->getEntryResults();
				break;
		}

		return;
	}

	private function getMetricResults() {

		$query = sprintf('
			SELECT
			`metric_group`.`name` AS `metric_group_name`,
			`metric`.`metric`,
			`client_metric`.*,
			`metric_unit_type`.`metric_unit_type`,
			`client`.`company_name`,
			`client_checklist`.`date_range_start`,
			`client_checklist`.`date_range_finish`,
            DATE_FORMAT(`client_checklist`.`date_range_start`, \"%%Y\") AS `date_range_start_year`,
            DATE_FORMAT(`client_checklist`.`date_range_start`, \"%%M\") AS `date_range_start_month`,
            DATE_FORMAT(`client_checklist`.`date_range_start`, \"%%M %%Y\") AS `date_range_start_month_year`,
            DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%Y\") AS `date_range_finish_year`,
            DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%M\") AS `date_range_finish_month`,
            DATE_FORMAT(`client_checklist`.`date_range_finish`, \"%%M %%Y\") AS `date_range_finish_month_year`,
			DATE_FORMAT(`client_metric`.`timestamp`, \"%%d/%%m/%%Y\") AS `date_entered`
			FROM `%2$s`.`client_metric`
			LEFT JOIN `%2$s`.`metric_unit_type` ON `client_metric`.`metric_unit_type_id` = `metric_unit_type`.`metric_unit_type_id`
			LEFT JOIN `%2$s`.`metric` ON `client_metric`.`metric_id` = `metric`.`metric_id`
			LEFT JOIN `%2$s`.`metric_group` ON `metric`.`metric_group_id` = `metric_group`.`metric_group_id`
			LEFT JOIN `%2$s`.`page` ON `metric_group`.`page_id` = `page`.`page_id`
			LEFT JOIN `%2$s`.`client_checklist` ON `client_metric`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
			LEFT JOIN `%1$s`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
			WHERE `client_checklist`.`client_checklist_id` IN (%3$s)
			ORDER BY `client_metric`.`timestamp` DESC
			LIMIT 1000;
		',
			DB_PREFIX.'core',
			DB_PREFIX.'checklist',
			$this->db->escape_string(implode(',',resultFilter::filtered_client_checklist_array($this->db, $this->contact)))
		);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		$this->node->setAttribute('mode','metrics');
		return;
	}

	private function getEntryResults() {
		$params = $this->setParams();
		$this->setTableColumns($params);
		$query = $this->clientChecklist->getClientResultsWithAdditionalValuesQuery(implode(',',resultFilter::filtered_client_checklist_array($this->db, $this->contact)));
		$query = str_replace("\"","\\\"", $query);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		$this->node->setAttribute('mode','entry_results');
		return;
	}

	private function getClientMetricResults() {
		$queryBuilder = new queryBuilder($this->db);
		$queryFilters = $queryBuilder->buildQueryFilter();
		$metric_filter = '';
		foreach($queryFilters as $queryFilter) {
			$metric_filter .= strpos($queryFilter,'client_metric') !== false ? $queryFilter : '';
		}

		$query = $this->clientChecklist->clientMetricQuery(
			implode(',',resultFilter::filtered_client_checklist_array($this->db, $this->contact)),
			implode(',',resultFilter::filtered_client_array($this->db, $this->contact)),
			$metric_filter
		);
		$query = str_replace("\"","\\\"", $query);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		$this->node->setAttribute('mode','client_metric_results');
		return;
	}

	private function getClientMetricEmissions() {
		$params = $this->setParams();
		$queryBuilder = new queryBuilder($this->db);
		$queryFilters = $queryBuilder->buildQueryFilter();
		$metric_filter = '';
		foreach($queryFilters as $queryFilter) {
			$metric_filter .= strpos($queryFilter,'client_metric') !== false ? $queryFilter : '';
		}

		$query = $this->clientChecklist->clientMetricEmissions(
			implode(',',resultFilter::filtered_client_checklist_array($this->db, $this->contact)),
			implode(',',resultFilter::filtered_client_array($this->db, $this->contact)),
			$metric_filter,
			!empty($params->unit) ? $params->unit : null
		);
		$query = str_replace("\"","\\\"", $query);

		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);
		$this->node->setAttribute('mode','client_metric_emissions');
		return;
	}

	//Add/Edit/Delete Entry Content
	public function entryContent() {
		$params = $this->setParams();
		$params->mode = isset($params->mode) ? $params->mode : 'entry-list';

		switch($params->mode) {
			case 'metric-list': $this->metricList();
			break;

			default: $this->entityList();
			break;
		}

		return;
	}

	private function metricList() {
		$this->node->setAttribute('mode','metric-list');
		$query = $this->getClientsQuery();
		$query_id = $this->db->insertStoredQuery($query);
		$this->setJsonTableData($query_id);	

		return;
	}

	//See if we are setting columns
	private function setTableColumns($params) {
		if(isset($params->columns)) {
			$columnsNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('columns'));
			$columns = explode(',',$params->columns);
			foreach($columns as $column) {
				$columnNode = $columnsNode->appendChild($GLOBALS['core']->doc->createElement('column'));
				$columnNode->setAttribute('name',trim($column));
			}
		}
		return;
	}

	//Analytics and reporting plugin method
	public function analytics() {
		if(is_null($this->contact)) return;
		$params = $this->setParams();

		//Add Json encoded data
		$apiData = $this->node->appendChild($GLOBALS['core']->doc->createElement('query-data'));
		$timestamp = time();
		$apiData->setAttribute('key', GBC_API_PUB_KEY);
		$apiData->setAttribute('hash',hash_hmac('sha256', (GBC_API_PUB_KEY . $timestamp), GBC_API_PRV_KEY));
		$apiData->setAttribute('timestamp',$timestamp);
		$apiData->setAttribute('filtered_client_array', json_encode(implode(',',resultFilter::filtered_client_array($this->db, $this->contact))));
		$apiData->setAttribute('filtered_client_checklist_array', json_encode(implode(',',resultFilter::filtered_client_checklist_array($this->db, $this->contact))));

		$checklists = $this->getAccessibleChecklists();
		$checklistsNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('checklists'));
		foreach($checklists as $checklist) {
			$checklistNode = $checklistsNode->appendChild($this->createNodeFromRecord('checklist', $checklist, array_keys((array)$checklist)));
		}	

		return;
	}

	private function getAccessibleChecklists() {
		$checklists = array();

		$query = sprintf('
			SELECT
			`checklist`.*
			FROM `%1$s`.`checklist`
			WHERE `checklist`.`checklist_id` IN (%2$s)
			ORDER BY `checklist`.`name`
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string(implode(',',resultFilter::accessible_checklists($this->db, $this->contact)))
		);

		//Get the Accessible checklists
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$checklists[] = $row;
			}
			$result->close();
		}

		return $checklists;
	}

	public function settings() {
		if(empty($this->dashboardUser)) return;
		$params = $this->setParams();

		switch($params->setting) {
			case 'groups':
				$params->mode = isset($params->mode) ? $params->mode : 'list';
				switch($params->mode) {
					case 'add': $this->groupEdit('add');
					break;

					case 'edit': $this->groupEdit('edit');
					break;

					default: $this->groupList($params);
					break;
				}

			break;
		}
		return;
	}

	private function groupList($params) {
		$this->node->setAttribute('mode','list');
		$this->setTableColumns($params);
		$this->setJsonTableData(null, $this->contact->client_contact_id);	

		return;
	}

	//Add and Edit Entity
	private function groupEdit($mode) {
		$this->node->setAttribute('mode', isset($mode) ? $mode : 'add');
		
		//Check the action on post back
		if(isset($_POST['action'])) {
			switch($_POST['action']) {
				case 'addGroup':
					$postData = array();
					foreach($_POST as $key=>$val) {
						$postData[$key] = $val;
					}

					$group_id = $this->dashboard->setUserDefinedGroup($postData);

					if($group_id > 0) {
						header("location: /members/dashboard/group/edit/?group_id=" . $group_id);
					} else {
						//Error
					}

				break;

				case 'editGroup':
					$postData = array();
					foreach($_POST as $key=>$val) {
						$postData[$key] = $val;
					}
					$group_id = isset($_POST['user_defined_group_id']) ? $_POST['user_defined_group_id'] : null;
					$updated = $this->dashboard->updateUserDefinedGroup($postData, array('user_defined_group_id' => $group_id));

					$update = $this->dashboard->updateClient2UserDefinedGroup($group_id, isset($_POST['member_id']) ? $_POST['member_id'] : null);

					if($group_id > 0) {
						header("location: /members/dashboard/group/edit/?group_id=" . $group_id);
					} else {
						//Error
					}

				break;
			}
		}

		//Get the available groups
		$groups = !is_null(resultFilter::accessible_user_defined_groups($this->db, $this->contact)) ? $this->dashboard->getDashboardGroups(resultFilter::accessible_user_defined_groups($this->db, $this->contact)) : array();
		$disabledGroups = isset($_REQUEST['group_id']) ? $this->dashboard->getChildrenGroups($_REQUEST['group_id'], $groups) : array();

		foreach($groups as $group) {
			$group->attachable = (isset($_REQUEST['group_id']) && $group->user_defined_group_id === $_REQUEST['group_id']) || in_array($group->user_defined_group_id, $disabledGroups) ? 0 : 1;
			$groupNode = $this->node->appendChild($this->createNodeFromRecord('group', $group, array_keys((array)$group)));
			$members = $this->dashboard->getClient2UserDefinedGroup($group->user_defined_group_id, resultFilter::accessible_clients($this->db, $this->contact));
			foreach($members as $member) {
				$memberNode = $groupNode->appendChild($this->createNodeFromRecord('member', $member, array_keys((array)$member)));
			}
		}

		if($mode === 'edit') {
			$clients = $this->getAccessibleClients();
			foreach($clients as $client) {
				$clientNode = $this->node->appendChild($this->createNodeFromRecord('client', $client, array_keys((array)$client)));
			}
		}

		return;
	}

	private function getAccessibleClients() {
		$accessibleClients = array();

		$query = sprintf('
			SELECT
				client.client_id,
				client.company_name
			FROM %1$s.client
			WHERE client.client_id IN(%2$s)
			ORDER BY client.company_name
		',
			DB_PREFIX.'core',
			$this->db->escape_string(implode(',',resultFilter::accessible_clients($this->db, $this->contact)))
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$accessibleClients[] = $row;
			}
			$result->close();
		}

		return $accessibleClients;
	}

	public function leafletMap() {
		$params = $this->setParams();

		//API Data
		$timestamp = time();
		$this->node->setAttribute('key', GBC_API_PUB_KEY);
		$this->node->setAttribute('hash',hash_hmac('sha256', (GBC_API_PUB_KEY . $timestamp), GBC_API_PRV_KEY));
		$this->node->setAttribute('timestamp',$timestamp);

		//Create the GeoJSON class
		$geoData = new stdClass;
		$geoData->type = "FeatureCollection";

		//Create the Feature Class
		$features = array();

		//Get the client coordinates
		$clientCoordinates = $this->getClientCoordinates();
		foreach ($clientCoordinates as $key => $clientCoordinate) {

			//Create the Feature Object
			$feature = new stdClass;
			$feature->type = "Feature";

			//Crete the Geometry Object;
			$geometry = new stdClass;
			$geometry->type = "Point";
			$geometry->coordinates = array($clientCoordinate->lng, $clientCoordinate->lat);
			$feature->geometry = $geometry;

			//Create the Properties Object
			$properties = new stdClass;
			$properties->name = $clientCoordinate->company_name;
			$properties->markertype = "client";
			$properties->client_id = $clientCoordinates[$key]->client_id;
			$feature->properties = $properties;

			//Create the ID Object
			$feature->id = $clientCoordinates[$key]->client_id;

			//Add the Feature Object to the features array
			$features[] = $feature;
		} 
		$geoData->features = $features;

		//Get the clientCoordinates and push to XML
		$mapData = new stdClass;
		$mapData->data = json_encode($geoData);
		$clientCoordinatesNode = $this->node->appendChild($this->createNodeFromRecord('clientCoordinates', $mapData, array_keys((array)$mapData)));

		return;
	}

	//Method to get the dashboard result filter plugin content
	public function resultFilter() {
		$params = $this->setParams();
		$this->setJsonTableData(null, isset($this->contact->client_contact_id) ? $this->contact->client_contact_id : null);

		if(isset($_REQUEST['filter-field'])) {
			$filterFormData = array();
			$filterFormData['setFilters']['filter-field'] = isset($_REQUEST['filter-field']) ? $_REQUEST['filter-field'] : null;
			$filterFormData['setFilters']['filter-type'] = isset($_REQUEST['filter-type']) ? $_REQUEST['filter-type'] : null;
			$filterFormData['setFilters']['filter-value'] = isset($_REQUEST['filter-value']) ? $_REQUEST['filter-value'] : null;
			$this->node->setAttribute('data-json-post', json_encode($filterFormData));
		}

		return;
	}

	/**
	*	Vivid Sydney Plugin
	*/
	public function vividSydney() {
		$params = $this->setParams();

		switch($params->mode) {
			case 'environment-charts': $this->vividSydneyEnvironmentCharts();
			break;

			case 'facts': $this->vividSydneyFacts();
			break;
		}	

		return;
	}

	private function vividSydneyEnvironmentCharts() {

		$resources = [
			'Petrol' => ['category' => 'Generator', 'unit' => 'L', 'identifiers' => ['unit' => 15549, 'value' => 15607]],
			'Diesel' => ['category' => 'Generator', 'unit' => 'L', 'identifiers' => ['unit' => 15560, 'value' => 15608]],
			'LPG' => ['category' => 'Generator', 'unit' => 'L', 'identifiers' => ['unit' => 15565, 'value' => 15609]],
			'LNG' => ['category' => 'Generator', 'unit' => 'L', 'identifiers' => ['unit' => 15570, 'value' => 15610]],
			'Electricity' => ['category' => 'Electricity', 'unit' => 'kWh', 'identifiers' => ['unit' => 15538, 'value' => 15738, 'multiplier' => 15632, 'method' => 'subtract']], 
			'GreenPower' => ['category' => 'Electricity', 'unit' => 'kWh', 'identifiers' => ['unit' => 15538, 'value' => 15738, 'multiplier' => 15632, 'method' => 'multiply']],
			'General Waste' => ['category' => 'Waste', 'unit' => 'kg', 'identifiers' => ['unit' => 15512, 'value' => 15633]],
			'Commingled Waste' => ['category' => 'Waste', 'unit' => 'kg', 'identifiers' => ['unit' => 15517, 'value' => 15634]],
			'Paper & Cardboard Waste' => ['category' => 'Waste', 'unit' => 'kg', 'identifiers' => ['unit' => 15521, 'value' => 15635]],
			'Organic Waste' => ['category' => 'Waste', 'unit' => 'kg', 'identifiers' => ['unit' => 15525, 'value' => 15636]]
		];

		$precinct = 16349;
		$precincts = [];

		$results = $this->clientChecklist->getClientChecklistResults(resultFilter::filtered_client_checklist_array($this->db, $this->contact));

		$clientChecklists = array();
		foreach($results as $result) {
			$clientChecklists[$result['client_checklist_id']][$result['question_id']] = $result;
			
			if($result['question_id'] == $precinct && !isset($precincts[$result['answer_id']])) {
				$precincts[$result['answer_id']] = $result['string'];
			}
		}

		//Add the precincts
		asort($precincts);
		$precincts[0] = 'Uncategorised Precinct';
		$precinctsNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('precincts'));
		foreach($precincts as $id=>$name) {
			$precinctNode = $precinctsNode->appendChild($GLOBALS['core']->doc->createElement('precinct'));
			$precinctNode->setAttribute('precinct_id',$id);
			$precinctNode->setAttribute('precinct',$name);
		}

		//Resources
		foreach($resources as $name=>$resource) {
			
			//Set the resource node
			$resourceNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('resource'));
			$resourceNode->setAttribute('name',$name);
			$resourceNode->setAttribute('category',$resource['category']);
			$resourceNode->setAttribute('unit',$resource['unit']);

			foreach($clientChecklists as $ccid=>$clientChecklist) {
				$value = 0;
				
				//Calculate the base value
				if(in_array($resource['identifiers']['unit'], array_keys($clientChecklist)) && in_array($resource['identifiers']['value'], array_keys($clientChecklist))) {					
					switch($resource['identifiers']['unit']) {
						case 'kL':		$value = $clientChecklist[$resource['identifiers']['value']]['arbitrary_value'] * 1000;
										break;

						case 'GJ':		$value = $clientChecklist[$resource['identifiers']['value']]['arbitrary_value'] * 277.77;
										break;

						case 'Tonnes':	$value = $clientChecklist[$resource['identifiers']['value']]['arbitrary_value'] * 1000;
										break;

						default:		$value = $clientChecklist[$resource['identifiers']['value']]['arbitrary_value'] * 1;
					}
				}

				//Multiplier
				if(isset($resource['identifiers']['multiplier']) && isset($resource['identifiers']['method']) && isset($clientChecklist[$resource['identifiers']['multiplier']])) {
					$multiplier = $clientChecklist[$resource['identifiers']['multiplier']]['arbitrary_value'] > 0 ? ($clientChecklist[$resource['identifiers']['multiplier']]['arbitrary_value']/100) : 0;				
					switch($resource['identifiers']['method']) {
						case 'subtract':	$value = $value * (1 - $multiplier);
											break;

						case 'multiply':	$value = $value * $multiplier;
											break;
					}
				}

				//Set the clientChecklist resource consumption
				$client = array_values($clientChecklist);
				$consumptionNode = $resourceNode->appendChild($GLOBALS['core']->doc->createElement('consumption'));
				$consumptionNode->setAttribute('client_checklist_id',$client[0]['client_checklist_id']);
				$consumptionNode->setAttribute('client_id',$client[0]['client_id']);
				$consumptionNode->setAttribute('company_name',$client[0]['company_name']);
				$consumptionNode->setAttribute('value',$value);
				$consumptionNode->setAttribute('precinct_id',isset($clientChecklist[$precinct]) ? $clientChecklist[$precinct]['answer_id'] : '0');
				$consumptionNode->setAttribute('precinct',isset($clientChecklist[$precinct]) ? $clientChecklist[$precinct]['string'] : 'Uncategorised Precinct');
			}
		}

		//Emissions
		$ghg = new ghg($this->db);
		$emissions = $ghg->getEmissions(resultFilter::filtered_client_checklist_array($this->db, $this->contact));
		
		$emissionNames = [];
		foreach($emissions as $emission) {
			$emissionNames[$emission['emission_factor_id']] = $emission['type']; 
		}
		
		foreach($emissionNames as $emissionId=>$emissionName) {
			$resourceNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('resource'));
			$resourceNode->setAttribute('name',$emissionName);
			$resourceNode->setAttribute('category','Emissions');
			$resourceNode->setAttribute('unit','kg CO2-e');
			foreach($emissions as $emission) {
				if($emission['emission_factor_id'] == $emissionId) {
					$consumptionNode = $resourceNode->appendChild($GLOBALS['core']->doc->createElement('consumption'));
					$consumptionNode->setAttribute('client_checklist_id',$emission['client_checklist_id']);
					$consumptionNode->setAttribute('client_id',$emission['client_id']);
					$consumptionNode->setAttribute('company_name',$emission['company_name']);
					$consumptionNode->setAttribute('value',$emission['value']);
					$consumptionNode->setAttribute('precinct_id',isset($clientChecklists[$emission['client_checklist_id']][$precinct]) ? $clientChecklists[$emission['client_checklist_id']][$precinct]['answer_id'] : '0');
					$consumptionNode->setAttribute('precinct',isset($clientChecklists[$emission['client_checklist_id']][$precinct]) ? $clientChecklists[$emission['client_checklist_id']][$precinct]['string'] : 'Uncategorised Precinct');	
				}
			}
		}

		return;
	}

	private function vividSydneyFacts() {
		$ghg = new ghg($this->db);
		$visitors = 2330000;
		$dollars = 143000000;
		$artists = 185;
		$totalEmissions = 0;
		$questions = [
			16785 => ['key' => 'attendance'],
			16786 => ['key' => 'area'],
			16787 => ['key' => 'activations'],
			16788 => ['key' => 'activated-hours']
		];

		$emissions = $ghg->getEmissions(resultFilter::filtered_client_checklist_array($this->db, $this->contact));
		$results = $this->clientChecklist->getClientChecklistResults(resultFilter::filtered_client_checklist_array($this->db, $this->contact), array_keys($questions));

		//Total Emissions
		foreach($emissions as $emission) {
			$totalEmissions += $emission['value'];
		}

		$resource = $this->node->appendChild($GLOBALS['core']->doc->createElement('fact'));
		$resource->setAttribute('key','total-emissions');
		$resource->setAttribute('value',round($totalEmissions,3));

		//Emissions per visitor
		$resource = $this->node->appendChild($GLOBALS['core']->doc->createElement('fact'));
		$resource->setAttribute('key','emissions-per-visitor');
		$resource->setAttribute('value',round($totalEmissions/$visitors, 3));

		//Dollars per visitor
		$resource = $this->node->appendChild($GLOBALS['core']->doc->createElement('fact'));
		$resource->setAttribute('key','dollars-per-visitor');
		$resource->setAttribute('value',round($dollars/$visitors, 3));

		//Emissions per visitor
		$resource = $this->node->appendChild($GLOBALS['core']->doc->createElement('fact'));
		$resource->setAttribute('key','emissions-per-artist');
		$resource->setAttribute('value',round($totalEmissions/$artists, 3));

		foreach($questions as $key=>$val) {
			$total = 0;
			foreach($results as $result) {
				if($result['question_id'] == $key) {
					$total += floatval($result['arbitrary_value']);
				}
			}

			$resource = $this->node->appendChild($GLOBALS['core']->doc->createElement('fact'));
			$resource->setAttribute('key',$val['key']);
			$resource->setAttribute('value',round($total, 2));
			$resource->setAttribute('emission-value',$total > 0 ? round($totalEmissions/$total, 3) : 0);
		}

		return;
	}

	public function import() {
		return;
	}
	//End of class
}
?>
