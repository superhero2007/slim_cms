<?php
/*
	GreenBizCheck API running on the Slim Framework
	http://www.slimframework.com
*/

class api {
	private $db;
	private $dbModel;
	private $app;
	private $messages;
	private $resultFilter;
	private $result;
	private $error;
	private $baseUrl;

	function __construct($db) {

		//Set the execution time for large queries
		$memory_limit = ini_get('memory_limit');
		$max_execution_time = ini_get('max_execution_time');
		ini_set('max_execution_time', '0');
		ini_set('memory_limit', '-1');

		$this->db = $db;
		$this->dbModel = new dbModel($this->db);
		$this->result = new stdClass;
		$this->resultFilter = new stdClass;
		$this->error = false;

		$this->messages = new stdClass();
		$this->messages->httpsRequired = "Requests must be made over HTTPS.";
		$this->messages->forbiddenUser = "Forbidden. Invalid User.";
		$this->messages->forbiddenHash = "Forbidden. Invalid API Key.";
		$this->messages->requiredData = "Data array missing required information.";	
		$this->messages->invalidIdentifier = "The provided identifier is invalid or has produced an empty result.";
		$this->messages->dbInsertFailure = "Failed to insert record into database.";
		$this->messages->dbUpdateFailure = "Failed to update record in database.";
		$this->messages->userPrivledgesNotSet = "Error. User privledges not set.";
		$this->messages->permissionDenied = "Forbidden. Insufficient privledges.";
		
		//Get the slim app
		$this->app = new \Slim\Slim(array(
			'log.enabled' => true,
			'mode' => APP_MODE
		));

		$authenticate = function() {
			$this->authenticate();
		};		

		//Settings for development mode 
		$this->app->configureMode('development', function () {
		    $this->app->config(array(
		        'debug' => true
		    ));
		});

	    //API Version 1
	    $this->app->group('/v1', $authenticate, function () {
	    	$this->run_api_v1();
	    });

		//Run the slim app
		$this->app->run();

		//Reset the max execution time
		ini_set('max_execution_time', $max_execution_time);
		ini_set('memory_limit', $memory_limit);
	}

	//Authenticate the request with API key
	private function authenticate() {
		$headers = $this->app->request->headers->all();

		//Check the user, authentication, protocol and privledges
		$user = $this->checkUser($headers);
		$authenticated = $this->authenticateUser($headers, $user);
		$ssl = $this->checkProtocol();

		$this->setUserPrivledges($user);

		if($this->error) {
			$this->stopApplication();
		}

		return;
	}

	private function stopApplication() {
		$this->returnJsonResponse($this->result);	
		$this->app->stop();
		die();
	}

	private function setRequestFail($code, $message) {
		$this->error = true;
		$this->result->code = $code;
		$this->result->status = $message;
		$this->stopApplication();
		return;
	}

	//Check correct API Key
	//Secrect key expects headers to be sent of X-Public and X-Timestamp
	//The two header values are concatenated and processed with the private key  with SHA256 to get the result
	private function authenticateUser($headers, $user) {
		$authenticated = true;
		$secretKey = (isset($headers['X-Public']) ? $headers['X-Public'] : null) . (isset($headers['X-Timestamp']) ? $headers['X-Timestamp'] : null);
		$token = hash_hmac("sha256", $secretKey, (isset($user->private_key) ? $user->private_key : null));
		if($token != (isset($headers['X-Hash']) ? $headers['X-Hash'] : '')) {
			$authenticated = false;
			$this->setRequestFail('403', $this->messages->forbiddenHash);
		}
		return $authenticated;
	}

	//Check that we are using SSL in the development environment
	private function checkProtocol() {
		$ssl = true;
		if($this->app->mode == 'production' && empty($_SERVER['HTTPS'])) {
			$ssl = false;
			$this->setRequestFail('403', $this->messages->httpsRequired);
		}
		return $ssl;
	}

	//Check for a user
	private function checkUser($headers) {
		$user = $this->getUser(isset($headers['X-Public']) ? $headers['X-Public'] : null);
		$this->logRequest($user); //Log the user/non-user request		
		if(empty($user)) {
			$this->setRequestFail('403', $this->messages->forbiddenUser);
		}

		return $user;
	}

	//Log the client
	private function logRequest($user) {
	
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`user_log` SET
				`user_id` = %2$d,
				`ip_address` = "%3$s",
				`request` = "%4$s",
				`timestamp` = NOW();
		',
			DB_PREFIX.'api',
			isset($user->user_id) ? $user->user_id : 0, //No user ID, still log the request
			$this->db->escape_string($_SERVER['REMOTE_ADDR']),
			$this->db->escape_string("http" . (isset($_SERVER['HTTPS']) ? "s" : "") . "://" . "{$_SERVER['HTTP_HOST']}{$_SERVER['REQUEST_URI']}")
		));
		
		return;
	}

	private function setUserPrivledges($user) {
		$this->resultFilter->client2checklist = $this->getUser2Checklist($user);
		$this->resultFilter->client2clientType = $this->getUser2ClientType($user);

		if(empty($this->resultFilter->client2checklist) || empty($this->resultFilter->client2clientType)) {
			$this->setRequestFail('403', $this->messages->userPrivledgesNotSet);
		}

		return;
	}

	private function getPermittedClientTypes($returnString = false) {
		$permittedClientTypes = array();

		if(!in_array('0',$this->resultFilter->client2clientType)) {
			$permittedClientTypes = $this->resultFilter->client2clientType;
		} else {
			$client = new client($this->db);
			$clientTypes = $client->getClientTypes();
			foreach($clientTypes as $clientType) {
				$permittedClientTypes[] = $clientType->client_type_id;
			}
		}

		return $returnString ? implode(',',$permittedClientTypes) : $permittedClientTypes;
	}

	private function getPermittedChecklists($returnString = false) {
		$permittedChecklists = array();

		if(!in_array('0',$this->resultFilter->client2checklist)) {
			$permittedChecklists = $this->resultFilter->client2checklist;
		} else {
			$clientChecklist = new clientChecklist($this->db);
			$checklists = $clientChecklist->getAllChecklists();
			foreach($checklists as $checklist) {
				$permittedChecklists[] = $checklist->checklist_id;
			}
		}

		return $returnString ? implode(',',$permittedChecklists) : $permittedChecklists;
	}

	private function run_api_v1() {

		//Set the return response to include the posted data
		$this->result->data = $this->app->request->post();

		//Get REQUESTS
		//Individual clientChecklists
		$this->app->get('/clients/:client_id/checklists/:client_checklist_id', function ($client_id, $client_checklist_id) {
		    $this->getClientChecklists($client_id, $client_checklist_id);
		});

		//Individual clientChecklists by date
		$this->app->get('/clients/:client_id/checklist/:checklist_id/date', function ($client_id, $checklist_id) {
		    $this->getClientChecklistByDate($client_id, $checklist_id, $this->app->request->get('date_range_start'));
		});

		//Update clientChecklist
		$this->app->put('/clients/:client_id/checklists/:client_checklist_id', function ($client_id, $client_checklist_id) {
			$postData = $this->app->request->post();
		    $this->updateClientChecklist($client_id, $client_checklist_id, $postData);
		});

		//All clientChecklists
		$this->app->get('/clients/:client_id/checklists/', function ($client_id) {
		    $this->getClientChecklists($client_id);
		});

		//Insert clientChecklist
		$this->app->post('/clients/:client_id/checklists/', function ($client_id) {
			$data = $this->app->request->post();
		    $this->insertClientChecklist($client_id, $data);
		});

		//Insert clientChecklist
		$this->app->post('/import/', function () {
		    $this->importData($this->app->request->post());
		});

		//Individual clientContact
		$this->app->get('/clients/:client_id/contacts/:client_contact_id', function ($client_id, $client_contact_id) {
		    $this->getClientContacts($client_id, $client_contact_id);
		});

		//All clientContacts
		$this->app->get('/clients/:client_id/contacts/', function ($client_id) {
		    $this->getClientContacts($client_id);
		});

		//Individual client search
		$this->app->get('/clients', function () {
		    $this->getClientsByCompanyName($this->app->request->get('company_name'));
		});		

		//Individual client
		$this->app->get('/clients/:client_id', function ($client_id) {
		    $this->getClients($client_id);
		});

		//All clients
		$this->app->get('/clients/', function () {
		    $this->getClients();
		});

		//Get client maps
		$this->app->get('/api/maps/clients/:external_client_id/:client_type_id', function ($external_client_id, $client_type_id) {
		    $this->getClientApiMap($external_client_id, $client_type_id);
		});

		//Get clientChecklist maps
		$this->app->get('/api/maps/clientchecklists/:client_id/:external_client_checklist_id', function ($client_id, $external_client_checklist_id) {
		    $this->getClientChecklistApiMap($client_id, $external_client_checklist_id);
		});

		//Insert client
		$this->app->post('/clients/', function () {
			$postData = $this->app->request->post();
		    $this->insertClient($postData);
		});

		//Update client
		$this->app->put('/clients/:client_id', function ($client_id) {
			$postData = $this->app->request->post();
		    $this->updateClient($client_id, $postData);
		});

		//Insert client api map
		$this->app->post('/api/maps/clients/', function () {
			$postData = $this->app->request->post();
		    $this->insertClientApiMap($postData);
		});

		//Insert client checklist api map
		$this->app->post('/api/maps/clientchecklists/', function () {
			$postData = $this->app->request->post();
		    $this->insertClientChecklistApiMap($postData);
		});

		//Insert/Update Client Result
		$this->app->post('/clients/:client_id/checklists/:client_checklist_id/clientresults/', function ($client_id, $client_checklist_id) {
			$postData = $this->app->request->post();
		    $this->insertClientResult($client_id, $client_checklist_id, $postData);
		});

		//Insert/Update Client Metric
		$this->app->post('/clients/:client_id/checklists/:client_checklist_id/clientmetrics/', function ($client_id, $client_checklist_id) {
			$postData = $this->app->request->post();
		    $this->insertClientMetric($client_id, $client_checklist_id, $postData);
		});

		//Insert/Update Client AdditionalValue
		$this->app->post('/clients/:client_id/checklists/:client_checklist_id/additionalvalues/', function ($client_id, $client_checklist_id) {
			$postData = $this->app->request->post();
		    $this->insertAdditionalValue($client_id, $client_checklist_id, $postData);
		});

		//Checklist Metric Search
		$this->app->get('/checklists/:checklist_id/metrics', function ($checklist_id) {
		    $this->getMetricsByName($checklist_id, $this->app->request->get('name'));
		});

		//Checklist Metric Unit Type Search
		$this->app->get('/checklists/metricUnitTypes', function () {
		    $this->getMetricUnitTypesByName($this->app->request->get('name'));
		});			

		//Get Stored Query
		$this->app->get('/storedQuery/:query_id', function ($query_id) {
		    $this->getStoredQuery($query_id);
		});

		//Get Analytics Checklist Questions
		$this->app->post('/analytics/checklist/:checklist_id/question/', function ($checklist_id) {
			$this->getAnalyticsChecklistQuestions($checklist_id, $this->app->request->post());
		});

		//Get Analytics Chart Checklist Questions
		$this->app->post('/analytics/chart/checklist/:checklist_id/question/:question_id/', function ($checklist_id, $question_id) {
			$postData = $this->app->request->post();
			$this->getAnalyticsChartChecklistQuestionResults($checklist_id, $question_id, $postData);
		});

		//Get Analytics Chart Benchmark Checklist Questions
		$this->app->post('/analytics/benchmark/checklist/:checklist_id/question/:question_id/', function ($checklist_id, $question_id) {
			$postData = $this->app->request->post();
			$this->getBenchmarkQuestionResults($checklist_id, $question_id, $postData);
		});

		//Get Analytics Table Checklist Questions
		$this->app->post('/analytics/table/checklist/:checklist_id/question/:question_id/', function ($checklist_id, $question_id) {
			$postData = $this->app->request->post();
			$this->getAnalyticsTableChecklistQuestionResults($checklist_id, $question_id, $postData);
		});

		//Get Analytics Checklist Questions
		$this->app->post('/dashboard/user/group/', function () {
			$postData = $this->app->request->post();
			$this->getDashboardUserGroup($postData);
		});

		//Get Analytics Checklist Questions
		$this->app->post('/dashboard/result-filter/', function () {
			$postData = $this->app->request->post();
			$this->getDashboardResultFilter($postData);
		});

		//Get Analytics Checklist Questions
		$this->app->post('/dashboard/company-name/', function () {
			$postData = $this->app->request->post();
			$this->getDashboardCompanyNames($postData);
		});

		//Check gdacs
		$this->app->get('/gdacs/', function () {
		    $this->getGDACS();
		});

		//Check for unique user email
		$this->app->get('/unique/user/:email', function ($email) {
		    $this->checkUniqueEmail($email);
		});

		return;
	}

	private function checkUniqueEmail($email) {
		$contact = new clientContact($this->db);
		$clientContact = $contact->getClientContactByEmail($email);

		empty($clientContact) ? $this->result->unique = true : $this->result->unique = false;
		$this->returnJsonResponse($this->result);
		return;
	}

	/*********************/
	//
	// Stored Query
	//
	private function getStoredQuery($query_id) {

		$storedQuery = new stdClass;
		$results = array();

		//Get the Stored Query
		$query = sprintf('
			SELECT
			*
			FROM `%1$s`.`stored_query`
			WHERE `stored_query_id` = %2$d
			AND `completed` IS NULL;
		',
			DB_PREFIX.'api',
			$this->db->escape_string($query_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$storedQuery = $row;
			}
			$result->close();
		}

		//Now get the results
		if(!empty($storedQuery)) {
			if($result = $this->db->query($storedQuery->query)) {
				while($row = $result->fetch_object()) {
					$results[] = $row;
				}
				$result->close();
			}
		}

		$this->result->data = $results;
		$this->returnJsonResponse($this->result);

		//Delete the used query from the database
		$updateQuery = sprintf('
			DELETE
			FROM `%1$s`.`stored_query`
			WHERE `stored_query_id` = %2$d;
		',
			DB_PREFIX.'api',
			$this->db->escape_string($query_id)
		);
		$update = $this->db->query($updateQuery);

		return;
	}

	/*********************/
	//
	// Dashboard
	//
	private function getDashboardUserGroup($postData) {
		$dashboard = new dashboard($this->db);
		$data = isset($postData['data']) ? json_decode($postData['data']) : null;
		$groups = $dashboard->getDashboardUserGroup($data);

		$this->result->data = $groups;
		$this->returnJsonResponse($this->result);

		return;
	}

	private function getDashboardResultFilter($postData) {
		$dashboard = new dashboard($this->db);
		$data = isset($postData['data']) ? json_decode($postData['data']) : null;
		$filters = $dashboard->getResultFilter($data);

		$this->result->data = $filters;
		$this->returnJsonResponse($this->result);

		return;
	}

	private function getDashboardCompanyNames($postData) {
		$dashboard = new dashboard($this->db);
		$data = isset($postData['data']) ? json_decode($postData['data']) : null;
		$names = $dashboard->getCompanyNames($data);

		$this->result->data = $names;
		$this->returnJsonResponse($this->result);

		return;
	}

	private function getGDACS() {
		$gdacs = new gdacs($this->db);
		$results = $gdacs->getGDACS();

		$this->result->data = $results;
		$this->returnJsonResponse($this->result);

		return;
	}


	/*********************/
	//
	// Analytics
	//
	private function getAnalyticsChecklistQuestions($checklist_id, $post) {
		$clientChecklist = new clientChecklist($this->db);
		$questions = $clientChecklist->getAnalyticsQuestions($checklist_id);
		if(isset($post['additional_values']) && $post['additional_values'] == 'true') {
			 $questions = array_merge($questions, $clientChecklist->getAnalyticsAdditionalValues($checklist_id));
		}

		//Error Reporting
		empty($questions) ? $this->reportError($this->messages->invalidIdentifier, $checklist_id, 'checklist_id') : null;

		$this->result->questions = $questions;
		$this->returnJsonResponse($this->result);

		return;
	}

	private function getAnalyticsChartChecklistQuestionResults($checklist_id, $question_id, $postData) {
		$clientChecklist = new clientChecklist($this->db);
		$data = $clientChecklist->getAnalyticsChartQuestionResults($checklist_id, $question_id, $postData);

		//Error Reporting
		empty($data) ? $this->reportError($this->messages->invalidIdentifier, $checklist_id, 'checklist_id') : null;

		$this->result->data = $data;
		$this->returnJsonResponse($this->result);

		return;
	}

	private function getBenchmarkQuestionResults($checklist_id, $question_id, $postData) {
		$clientChecklist = new clientChecklist($this->db);
		$data = new stdClass;
		$client_id = isset($postData['client_id']) ? json_decode($postData['client_id']) : null;

		$data->benchmarks = $clientChecklist->getChecklistBenchmarkResults($checklist_id, $question_id);
		$data->answers = $clientChecklist->getChecklistAnswers($checklist_id, $question_id);
		$data->results = $clientChecklist->getChecklistResults($checklist_id, $question_id, !is_null($client_id) ? $client_id : null);

		$this->result->data = $data;
		$this->returnJsonResponse($this->result);

		return;
	}

	private function getAnalyticsTableChecklistQuestionResults($checklist_id, $question_id, $postData) {
		$clientChecklist = new clientChecklist($this->db);
		$data = $clientChecklist->getAnalyticsTableQuestionResults($checklist_id, $question_id, $postData);

		//Error Reporting
		empty($data) ? $this->reportError($this->messages->invalidIdentifier, $checklist_id, 'checklist_id') : null;

		$this->result->data = $data;
		$this->returnJsonResponse($this->result);

		return;
	}

	/*********************/
	//
	// Client
	//
	private function getClients($client_id = null) {
		$client = new client($this->db);
		$clients = $client->getClients($client_id, null, $this->getPermittedClientTypes(true));

		//Error Reporting
		(!is_null($client_id) && empty($clients)) ? $this->reportError($this->messages->invalidIdentifier, $client_id, 'client_id') : null;

		$this->result->clients = $clients;
		$this->returnJsonResponse($this->result);

		return;
	}

	/*********************/
	//
	// Search Client by Company Name
	//
	private function getClientsByCompanyName($company_name = null) {
		$client = new client($this->db);
		$clients = $client->getClientsByCompanyName($company_name, $this->getPermittedClientTypes(true));

		//Error Reporting
		//(!is_null($company_name) && empty($clients)) ? $this->reportError($this->messages->invalidIdentifier, $company_name, 'company_name') : null;

		$this->result->clients = $clients;
		$this->returnJsonResponse($this->result);

		return;
	}

	/*********************/
	//
	// Search Metrics by Name
	//
	private function getMetricsByName($checklist_id, $name = null) {
		$clientChecklist = new clientChecklist($this->db);
		$metrics = $clientChecklist->getMetricsByName($checklist_id, $name);

		//Error Reporting
		//(!is_null($company_name) && empty($clients)) ? $this->reportError($this->messages->invalidIdentifier, $company_name, 'company_name') : null;

		$this->result->metrics = $metrics;
		$this->returnJsonResponse($this->result);

		return;
	}

	/*********************/
	//
	// Search Metrics by Name
	//
	private function getMetricUnitTypesByName($name = null) {
		$clientChecklist = new clientChecklist($this->db);
		$metricUnitTypes = $clientChecklist->getMetricUnitTypesByName($name);

		//Error Reporting
		//(!is_null($company_name) && empty($clients)) ? $this->reportError($this->messages->invalidIdentifier, $company_name, 'company_name') : null;

		$this->result->metricUnitTypes = $metricUnitTypes;
		$this->returnJsonResponse($this->result);

		return;
	}

	/*********************/
	//
	// Contact
	//
	private function getClientContacts($client_id = null, $client_contact_id = null) {
		$clientContact = new clientContact($this->db);
		$clientContacts = $clientContact->getClientContacts($client_id, $client_contact_id, $this->getPermittedClientTypes(true));
		
		//Error Reporting
		(!is_null($client_id) && empty($clients)) ? $this->reportError($this->messages->invalidIdentifier, $client_id, 'client_id') : null;
		(!is_null($client_contact_id) && empty($clientContacts)) ? $this->reportError($this->messages->invalidIdentifier, $client_contact_id, 'client_contact_id') : null;

		$this->result->clientContacts = $clientContacts;
		$this->returnJsonResponse($this->result);

		return;
	}


	/*********************/
	//
	// ClientChecklists
	//
	private function getClientChecklists($client_id = null, $client_checklist_id = null) {
		$clientChecklist = new clientChecklist($this->db);
		$clientChecklists = $clientChecklist->getClientChecklists($client_id, $client_checklist_id, $this->getPermittedClientTypes(true), $this->getPermittedChecklists(true));
		
		if(!is_null($client_checklist_id) && isset($clientChecklists[0])) {
			$clientChecklists[0]->results = $clientChecklist->getStructuredClientResults($client_checklist_id);
		}

		//Error Reporting
		(!is_null($client_id) && empty($clientChecklists)) ? $this->reportError($this->messages->invalidIdentifier, $client_id, 'client_id') : null;
		(!is_null($client_checklist_id) && empty($clientChecklists)) ? $this->reportError($this->messages->invalidIdentifier, $client_checklist_id, 'client_checklist_id') : null;

		$this->result->clientChecklists = $clientChecklists;
		$this->returnJsonResponse($this->result);

		return;
	}

	private function getClientChecklistByDate($client_id = null, $checklist_id = null, $date_range_start = null) {
		$clientChecklist = new clientChecklist($this->db);
		$clientChecklists = $clientChecklist->getClientChecklistByDate($client_id, $checklist_id, $date_range_start);
		
		//if(!is_null($client_checklist_id) && isset($clientChecklists[0])) {
			//$clientChecklists[0]->results = $clientChecklist->getStructuredClientResults($client_checklist_id);
		//}

		//Error Reporting
		//(!is_null($client_id) && empty($clientChecklists)) ? $this->reportError($this->messages->invalidIdentifier, $client_id, 'client_id') : null;
		//(!is_null($client_checklist_id) && empty($clientChecklists)) ? $this->reportError($this->messages->invalidIdentifier, $client_checklist_id, 'client_checklist_id') : null;

		$this->result->clientChecklists = $clientChecklists;
		$this->returnJsonResponse($this->result);

		return;
	}

	/*********************/
	//
	// Insert Client
	//
	private function insertClient($data) {
		$required = ['client_type_id', 'company_name'];
		$checkFields = ['client_type_id'];
		
		if($this->validateData($data, $required) && $this->checkUserPermissions($data, $checkFields)) {
			$client = new client($this->db);
			$this->result->client_id = $client->setClient($data);
			$this->result->client_id === 0 ? $this->reportError($this->messages->dbInsertFailure) : null;
			$this->result->code = $this->result->client_id > 0 ? "201" : "400";
			$this->result->status = $this->result->client_id > 0 ? "Created" : "Not Created";

			if(isset($data['external_client_id']) && $this->result->client_id > 0) {
				$data['client_id'] = (string)$this->result->client_id;
				$this->insertClientApiMap($data);
			}
		}

		$this->result->data = $data;
		$this->returnJsonResponse($this->result);
		
		return;
	}

	/*********************/
	//
	// Update Client
	//
	private function updateClient($client_id, $data) {
		$checkFields = ['client_type_id'];
		$checkData = array('client_id' => $client_id);

		if($this->checkUserPermissions($checkData, $checkFields)) {
			$client = new client($this->db);
			$update_id = $client->updateClient($data, array('client_id' => $client_id));

			$this->result->code = $update_id > 0 ? "201" : "202";
			$this->result->status = $update_id > 0 ? "Updated" : "Not Modified";
		}

		$this->result->data = $data;
		$this->returnJsonResponse($this->result);
		
		return;
	}


	/*********************/
	//
	// Insert ClientChecklist
	//
	private function insertClientChecklist($client_id, $data) {
		$required = ['client_id', 'checklist_id'];
		$data['client_id'] = $client_id;
		$checkFields = ['client_id', 'checklist_id'];
		
		if($this->validateData($data, $required) && $this->checkUserPermissions($data, $checkFields)) {
			$clientChecklist = new clientChecklist($this->db);
			$this->result->client_checklist_id = $clientChecklist->setNewClientChecklist($data);
			$this->result->client_checklist_id === 0 ? $this->reportError($this->messages->dbInsertFailure) : null;
			$this->result->code = $this->result->client_checklist_id > 0 ? "201" : "400";
			$this->result->status = $this->result->client_checklist_id > 0 ? "Created" : "Not Created";

			if(isset($data['external_client_checklist_id'])) {
				$data['client_checklist_id'] = (string)$this->result->client_checklist_id;
				$this->insertClientChecklistApiMap($data);
			}
		}

		$this->result->data = $data;
		$this->returnJsonResponse($this->result);
		
		return;
	}

	/*********************/
	//
	// Update ClientChecklist
	//
	private function updateClientChecklist($client_id, $client_checklist_id, $data) {
		$checkFields = ['client_id', 'client_checklist_id'];
		$checkData = array('client_id' => $client_id,'client_checklist_id' => $client_checklist_id);

		if($this->checkUserPermissions($checkData, $checkFields)) {
			$clientChecklist = new clientChecklist($this->db);
			$update_id = $clientChecklist->updateClientChecklist($data, array('client_id' => $client_id, 'client_checklist_id' => $client_checklist_id));
			
			$this->result->code = $update_id > 0 ? "201" : "202";
			$this->result->status = $update_id > 0 ? "Updated" : "Not Modified";
		}

		$this->result->data = $data;
		$this->returnJsonResponse($this->result);

		return;
	}

	/*********************/
	//
	// Insert ClientResult
	//
	private function insertClientResult($client_id, $client_checklist_id, $data) {
		$required = ['checklist_id', 'answer_id', 'question_id'];
		$checkData = array('client_id' => $client_id,'client_checklist_id' => $client_checklist_id);
		$checkFields = ['client_id', 'checklist_id'];

		//Answer key is set, if not, try question key
		if(isset($data['checklist_id']) && isset($data['external_answer_id'])) {
			$answer = $this->getAnswerApiMap($data['checklist_id'], $data['external_answer_id'], isset($data['index']) ? $data['index'] : null);
			isset($answer->answer_id) ? $data['answer_id'] = $answer->answer_id : null;
			isset($answer->question_id) ? $data['question_id'] = $answer->question_id : null;
		} elseif(isset($data['checklist_id']) && isset($data['external_question_id'])) {
			$answer = $this->getQuestionApiMap($data['checklist_id'], $data['external_question_id'], isset($data['index']) ? $data['index'] : null , isset($data['arbitrary_value']) ? $data['arbitrary_value'] : null);
			isset($answer->answer_id) ? $data['answer_id'] = $answer->answer_id : null;
			isset($answer->question_id) ? $data['question_id'] = $answer->question_id : null;
		}
		
		if($this->validateData($data, $required) && $this->checkUserPermissions($checkData, $checkFields)) {
			$clientChecklist = new clientChecklist($this->db);
			$clientChecklist->deleteClientResult($client_checklist_id, $data['question_id'], $data['answer_id'], isset($data['index']) ? $data['index'] : null);
			$this->result->insert_id = $clientChecklist->storeClientResult($client_checklist_id, $data['question_id'], $data['answer_id'], isset($data['arbitrary_value']) && strlen($data['arbitrary_value']) > 0 ? $data['arbitrary_value'] : null, isset($data['index']) ? $data['index'] : null);
			$this->result->code = $this->result->insert_id > 0 ? "201" : "400";
			$this->result->status = $this->result->insert_id > 0 ? "Created" : "Not Created";
		}

		$this->result->data = $data;
		$this->returnJsonResponse($this->result);
		
		return;
	}


	/*********************/
	//
	// Insert ClientMetric
	//
	private function insertClientMetric($client_id, $client_checklist_id, $data) {
		$required = ['checklist_id', 'metric_id', 'metric_unit_type_id'];
		$checkData = array('client_id' => $client_id,'client_checklist_id' => $client_checklist_id);
		$checkFields = ['client_id', 'checklist_id'];

		if(isset($data['external_metric_id']) && isset($data['checklist_id'])) {
			$metric = $this->getMetricApiMap($data['external_metric_id'], $data['checklist_id']);
			isset($metric->metric_id) ? $data['metric_id'] = $metric->metric_id : null;
			isset($metric->metric_unit_type_id) ? $data['metric_unit_type_id'] = $metric->metric_unit_type_id : null;
		}
		
		if($this->validateData($data, $required) && $this->checkUserPermissions($checkData, $checkFields)) {
			$clientChecklist = new clientChecklist($this->db);
			
			$this->result->insert_id = $clientChecklist->storeClientMetric($client_checklist_id, $data['metric_id'], $data['metric_unit_type_id'], isset($data['arbitrary_value']) && strlen($data['arbitrary_value']) > 0 ? $data['arbitrary_value'] : null, isset($data['months']) ? $data['months'] : 1);
			
			$this->result->code = $this->result->insert_id > 0 ? "201" : "400";
			$this->result->status = $this->result->insert_id > 0 ? "Created" : "Not Created";
		}

		$this->result->data = $data;
		$this->returnJsonResponse($this->result);
		
		return;
	}	

	/*********************/
	//
	// Insert Additional Value
	//
	private function insertAdditionalValue($client_id, $client_checklist_id, $data) {
		$required = ['checklist_id', 'key', 'value'];
		$checkData = array('client_id' => $client_id,'client_checklist_id' => $client_checklist_id);
		$checkFields = ['client_id', 'checklist_id'];
		
		if($this->validateData($data, $required) && $this->checkUserPermissions($checkData, $checkFields)) {
			$clientChecklist = new clientChecklist($this->db);
			$clientChecklist->deleteAdditionalValue($client_checklist_id, $data['key'], isset($data['index']) ? $data['index'] : null);
			$this->result->insert_id = $clientChecklist->storeAdditionalValue($client_checklist_id, $data['key'], $data['value'], isset($data['index']) ? $data['index'] : null, isset($data['group']) ? $data['group'] : null);
			$this->result->code = $this->result->insert_id > 0 ? "201" : "400";
			$this->result->status = $this->result->insert_id > 0 ? "Created" : "Not Created";
		}

		$this->result->data = $data;
		$this->returnJsonResponse($this->result);
		
		return;
	}

	/*********************/
	//
	// Set Client API Map
	//
	private function insertClientApiMap($data) {
		$required = ['client_id', 'client_type_id', 'external_client_id'];
		$checkFields = ['client_type_id'];

		if($this->validateData($data, $required) && $this->checkUserPermissions($data, $checkFields)) {	
			$query = $this->dbModel->prepare_query('api', 'client_map', 'INSERT INTO', $data);
			$this->db->query($query);
			$this->result->client_map_id = $this->db->insert_id;
			$this->result->client_map_id === 0 ? $this->reportError($this->messages->dbInsertFailure) : null;
		}
		
		return;
	}

	/*********************/
	//
	// Set Client Checklist API Map
	//
	private function insertClientChecklistApiMap($data) {
		$required = ['client_id', 'client_checklist_id', 'external_client_checklist_id'];
		$checkFields = ['client_id', 'client_checklist_id'];

		if($this->validateData($data, $required) && $this->checkUserPermissions($data, $checkFields)) {	
			$query = $this->dbModel->prepare_query('api', 'client_checklist_map', 'INSERT INTO', $data);
			$this->db->query($query);
			$this->result->client_checklist_map_id = $this->db->insert_id;
			$this->result->client_checklist_map_id === 0 ? $this->reportError($this->messages->dbInsertFailure) : null;
		}

		return;
	}

	/*********************/
	//
	// ClientAPIMap
	//
	private function getClientApiMap($external_client_id, $client_type_id) {
		$clients = array();

		$filter = '';
		$filter .=' AND `client`.`client_type_id` IN(' . $this->getPermittedClientTypes(true) . ')';

		$query = sprintf('
			SELECT
			`client_map`.*
			FROM `%1$s`.`client_map`
			LEFT JOIN `%2$s`.`client` ON `client_map`.`client_id` = `client`.`client_id`
			WHERE 1 %5$s
			AND `client_map`.`external_client_id` = %3$d
			AND `client_map`.`client_type_id` = %4$d;
		',
			DB_PREFIX.'api',
			DB_PREFIX.'core',
			$this->db->escape_string($external_client_id),
			$this->db->escape_string($client_type_id),
			$this->db->escape_string($filter)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clients[] = $row;
			}
			$result->close();
		}

		$this->result->clients = $clients;
		$this->returnJsonResponse($this->result);

		return;
	}

	/*********************/
	//
	// ClientChecklistAPIMap
	//
	private function getClientChecklistApiMap($client_id, $external_client_checklist_id) {
		$clientChecklists = array();

		$filter = '';
		$filter .= ' AND `client`.`client_type_id` IN(' . $this->getPermittedClientTypes(true) . ')';
		$filter .= ' AND `client_checklist`.`checklist_id` IN(' . $this->getPermittedChecklists(true) . ')';

		$query = sprintf('
			SELECT
			`client_checklist_map`.*
			FROM `%1$s`.`client_checklist_map`
			LEFT JOIN `%3$s`.`client_checklist` ON `client_checklist_map`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
			LEFT JOIN `%2$s`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
			WHERE 1 %6$s
			AND `client_checklist_map`.`client_id` = %4$d
			AND `client_checklist_map`.`external_client_checklist_id` = %5$d;
		',
			DB_PREFIX.'api',
			DB_PREFIX.'core',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_id),
			$this->db->escape_string($external_client_checklist_id),
			$this->db->escape_string($filter)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clientChecklists[] = $row;
			}
			$result->close();
		}

		$this->result->clientChecklists = $clientChecklists;
		$this->returnJsonResponse($this->result);

		return;
	}

	/*********************/
	//
	// AnswerAPIMap
	//
	private function getAnswerApiMap($checklist_id, $external_answer_id, $index = 0) {
		$answer = new stdClass;

		$query = sprintf('
			SELECT *
			FROM `%1$s`.`answer_map`
			WHERE `external_answer_id` = "%3$s"
			AND `checklist_id` = %4$d;
			AND `index` = %5$d;
		',
			DB_PREFIX.'api',
			DB_PREFIX.'checklist',
			$this->db->escape_string($external_answer_id),
			$this->db->escape_string($checklist_id),
			$this->db->escape_string($index)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$answer = $row;
			}
			$result->close();
		}

		return $answer;
	}

	/*********************/
	//
	// QuestionAPIMap
	//
	private function getQuestionApiMap($checklist_id, $external_question_id, $index = 0, $arbitrary_value = null) {
		$answer = new stdClass;

		$query = sprintf('
			SELECT *
			FROM `%1$s`.`answer_map`
			WHERE `external_question_id` = "%2$s"
			AND `checklist_id` = %3$d
			AND `index` IN(%4$d, 0);
		',
			DB_PREFIX.'api',
			$this->db->escape_string($external_question_id),
			$this->db->escape_string($checklist_id),
			$this->db->escape_string($index)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				if(!is_null($row->external_answer_id)) {
					if($row->external_answer_id === $arbitrary_value) {
						$answer = $row;
					}
				} else {
					$answer = $row;
				}
			}
			$result->close();
		}

		return $answer;
	}

	/*********************/
	//
	// ClientAPIMap
	//
	private function getMetricApiMap($external_metric_id, $checklist_id) {
		$metric = new stdClass;

		$query = sprintf('
			SELECT
			`metric_map`.*
			FROM `%1$s`.`metric_map`
			WHERE `metric_map`.`external_metric_id` = "%3$s"
			AND `metric_map`.`checklist_id` = %4$d;
		',
			DB_PREFIX.'api',
			DB_PREFIX.'checklist',
			$this->db->escape_string($external_metric_id),
			$this->db->escape_string($checklist_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$metric = $row;
			}
			$result->close();
		}

		return $metric;
	}

	/*********************/
	//
	// Check required fields are set in the data array
	//
	private function validateData($data, $required = null) {
		$valid = true;
		$error = new stdClass;

		//First check the mandatory fields
		foreach($required as $key) {
			if(!in_array($key, array_keys($data))) {
				$valid = false;
				$this->reportError($this->messages->requiredData, $key);
			}
		}

		return $valid;
	}

	/*********************/
	//
	// Check that the user has permissions
	//
	private function checkUserPermissions($data, $checkFields) {
		$permission = true;
		$error = new stdClass;

		//First check the mandatory fields
		foreach($checkFields as $key) {
			if(isset($data[$key])) {
				switch($key) {
					case 'client_type_id':
						if(!in_array($data[$key], $this->getPermittedClientTypes())) {
							$permission = false;
							$this->reportError($this->messages->permissionDenied, $key);
						}
						break;

					case 'client_id':
						$clientClass = new client($this->db);
						if(empty($clientClass->getClients($data[$key], $this->getPermittedClientTypes(true)))) {
							$permission = false;
							$this->reportError($this->messages->permissionDenied, $key);						
						}
						break;

					case 'client_checklist_id':
						$clientChecklist = new clientChecklist($this->db);
						if(empty($clientChecklist->getClientChecklists(null, $data[$key], $this->getPermittedClientTypes(true), $this->getPermittedChecklists(true)))) {
							$permission = false;
							$this->reportError($this->messages->permissionDenied, $key);	
						}
						break;

					case 'checklist_id':
						$clientChecklist = new clientChecklist($this->db);
						if(empty($clientChecklist->getAllChecklists($this->getPermittedChecklists(true)))) {
							$permission = false;
							$this->reportError($this->messages->permissionDenied, $key);	
						}
						break;
				}
			}
		}

		//Return a response immediately with 403
		if(!$permission) {
			$this->setRequestFail('403', $this->messages->permissionDenied);
		}

		return $permission;
	}

	/*********************/
	//
	// Report any error to the response
	//
	private function reportError($message, $key = null, $field = null) {
		$error = new stdClass;
		$error->message = $message;
		$error->key = $key;
		$error->field = $field;

		$this->result->error[] = $error;
		$this->setRequestFail('400', $message);

		return;
	}

	/*********************/
	//
	// Get the user based on the public key
	//
	private function getUser($public_key) {
		$user = array();
		$query = sprintf('
			SELECT *
			FROM `%1$s`.`user`
			WHERE `public_key` = "%2$s";
		',
			DB_PREFIX.'api',
			$this->db->escape_string($public_key)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$user = $row;
			}
			$result->close();
		}

		return $user;
	}

	/*********************/
	//
	// Get the user2checklist
	//
	private function getUser2Checklist($user) {
		$user2checklist = array();
		$query = sprintf('
			SELECT *
			FROM `%1$s`.`user_2_checklist`
			WHERE `user_id` = %2$d;
		',
			DB_PREFIX.'api',
			$this->db->escape_string(isset($user->user_id) ? $user->user_id : null)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$user2checklist[] = $row->checklist_id;
			}
			$result->close();
		}

		return $user2checklist;
	}

	/*********************/
	//
	// Get the user2clientType
	//
	private function getUser2ClientType($user) {
		$user2clientType = array();
		$query = sprintf('
			SELECT *
			FROM `%1$s`.`user_2_client_type`
			WHERE `user_id` = %2$d;
		',
			DB_PREFIX.'api',
			$this->db->escape_string(isset($user->user_id) ? $user->user_id : null)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$user2clientType[] = $row->client_type_id;
			}
			$result->close();
		}

		return $user2clientType;
	}

	/**
	*
	*	Import Data
	*
	*/
	private function importData($post) {
		if(isset($post['action'])) {
			switch($post['action']) {
				case 'import_client_result':
					$this->importClientResult($post);
					break;
			}
		}

		return $this->returnJsonResponse($this->result);
	}

	/**
	*
	*	Import Client Result
	*/
	private function importClientResult($post) {
		$client = new client($this->db);
		$clientChecklist = new clientChecklist($this->db);

		//Get/Set Client
		if(isset($post['company_name'])) {
			$clients = $client->getClientsByCompanyName($post['company_name'], isset($post['client_type_id']) ? $post['client_type_id'] : null);
			$this->result->client_id = empty($clients) ? $client->setClient($post) : $clients[0]->client_id;
		}

		//Get/Set Client Checklist
		if(isset($this->result->client_id) && isset($post['checklist_id'])) {
			$clientChecklists = $clientChecklist->getClientChecklists($this->result->client_id, null, isset($post['client_type_id']) ? $post['client_type_id'] : null, isset($post['checklist_id']) ? $post['checklist_id'] : null, isset($post['date_range_start']) ? $post['date_range_start'] : null, isset($post['date_range_finish']) ? $post['date_range_finish'] : null, false);
			$this->result->client_checklist_id = empty($clientChecklists) ? $clientChecklist->setNewClientChecklist(['client_id' => $this->result->client_id,'checklist_id' => $post['checklist_id'], 'date_range_start' => isset($post['date_range_start']) ? $post['date_range_start'] : null, 'date_range_finish' => isset($post['date_range_finish']) ? $post['date_range_finish'] : null]) : $clientChecklists[0]->client_checklist_id;
		}

		//Set Client Result
		if(isset($this->result->client_checklist_id) && isset($post['question_id'])) {
			$this->result->answer = $clientChecklist->findAnswer($post['question_id'], isset($post['answer_id']) ? $post['answer_id'] : null, isset($post['answer']) ? $post['answer'] : null);

			if(isset($this->result->answer->answer_id)) {
				$clientChecklist->deleteClientResult($this->result->client_checklist_id, $this->result->answer->question_id);
				$arbitrary_value = isset($post['arbitrary_value']) ? $post['arbitrary_value'] : (isset($post['answer']) ? $post['answer'] : null);
				$this->result->client_result_id = $clientChecklist->storeClientResult($this->result->client_checklist_id, $this->result->answer->question_id, $this->result->answer->answer_id, in_array($this->result->answer->answer_type, ['checkbox', 'checkbox-other', 'drop-down-list']) ? null : $arbitrary_value);
			}
		}
		
		return;
	}


	/*********************/
	//
	// Send the response with JSON
	//
	private function returnJsonResponse($data) {
		!isset($data->code) ? $data->code = '200' : null;
		!isset($data->error) && !isset($data->status) ? $data->status = 'Success' : null;

		$this->app->response()->status($data->code);
		$this->app->response->headers->set('Content-Type', 'application/json');
		echo json_encode($data);
		return;
	}
}

?>