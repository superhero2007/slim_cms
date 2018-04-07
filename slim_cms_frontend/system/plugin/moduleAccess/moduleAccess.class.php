<?php
class moduleAccess extends plugin {
	private $client;
	private $contact;
	public $db;
	
	public function __construct() {

		//first check for a valid user/uid
		if(!$GLOBALS['core']->session->get('uid')) return;

		//Get the client and contact
		$this->db = $GLOBALS['core']->db;
		$this->contact = clientContact::stGetClientContactById($this->db, $GLOBALS['core']->session->get('uid'));
		$this->client = client::stGetClientById($this->db, $this->contact->client_id);
	}
	
	private function getModule2Token($token) {
		$module_2_token = array();

		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`module_2_token`
			WHERE `token` = "%2$s"
			LIMIT 1;
		',
			DB_PREFIX.'core',
			$token
		))) {
			while($row = $result->fetch_object()) {
				$module_2_token = $row;
			}
			$result->close();
		}

		return $module_2_token;
	}

	public function register() {

		//first check for a valid user/uid
		if(!$GLOBALS['core']->session->get('uid')) return;

		//Check for a token, if no token report error
		if(isset($_REQUEST['token'])) {

			//The token is set, get the details of the module
			$module_2_token = $this->getModule2Token($_REQUEST['token']);
			if(!empty($module_2_token)) {

				switch($module_2_token->module) {

					case 'dashboard':
						$this->dashboardRegister($module_2_token);
						break;
				}
			} else {
				$this->invalidRequest();
			}
		} else {
			//No module has been set. Return invalid warning
			$this->invalidRequest();
		}
		return;
	}

	private function invalidRequest() {
		$this->node->setAttribute('message_type', 'danger');
		$this->node->setAttribute('message', 'Invalid module registration information.');

		return;
	}
	

	private function dashboardRegister($module_2_token) {

		//First check to see if client already has access
		$dashboard = new dashboard($this->db);
		$dashboardUser = $dashboard->getDashboardUser($this->contact->client_contact_id);
		if(!empty($dashboardUser)) {
			//User is already registered for this module
			$this->node->setAttribute('message_type', 'warning');
			$this->node->setAttribute('message', 'This account already has access to the Dashboard module.');
			$this->node->setAttribute('redirect', '1');
			$this->node->setAttribute('redirect_url', '/members/dashboard/');
			$this->node->setAttribute('module_name', 'Dashboard');

			//Redirect user to resource with a 10 second delay
			header('Refresh: 10;url=/members/dashboard/');
		} else {

			//Get the dashboard registration details
			$registration = $dashboard->getDashboardRegistration($module_2_token->module_2_token_id);
			if(!empty($registration)) {
				$success = $dashboard->setDashboardUser($this->contact->client_contact_id, $registration->dashboard_group_id, $registration->dashboard_role_id);

				if($success) {
					//User has been registered, success and redirect
					$this->node->setAttribute('message_type', 'success');
					$this->node->setAttribute('message', 'This account has been granted access to the Dashboard module.');
					$this->node->setAttribute('redirect', '1');
					$this->node->setAttribute('redirect_url', '/members/dashboard/');
					$this->node->setAttribute('module_name', 'Dashboard');

					//Redirect user to resource with a 10 second delay
					header('Refresh: 10;url=/members/dashboard/');
				} else {
					$this->invalidRequest();
				}

			} else {
				//Invalid token, show the form
				$this->invalidRequest();
			}

		}

		return;
	}
}
?>
