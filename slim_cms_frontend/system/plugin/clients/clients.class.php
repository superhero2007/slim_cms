<?php
class clients extends plugin {
	private $clientUtils;
	public $client = false;
	private $countries    = array();
	private $industries = array();
	private $groups;
	    
	public function __construct() {
		$this->groups = new \GreenBizCheck\Groups();
		$this->getCountries();
		$this->getIndustries();
		return;
	}
		
	public function login() {
		$this->clientUtils = new clientUtils($this->db);

		//Get a list of the countries available for the client to register with
		$countries = $this->node->appendChild($GLOBALS['core']->doc->createElement('countries'));
		foreach($this->countries as $country) {
			$countryNode = $countries->appendChild($GLOBALS['core']->doc->createElement('country'));
			$countryNode->setAttribute('country_id',$country->country_id);
			$countryNode->setAttribute('name',$country->country);
		}
		
		//Get a list of the countries available for the client to register with
		$industries = $this->node->appendChild($GLOBALS['core']->doc->createElement('industries'));
		foreach($this->industries as $industry) {
			$industryNode = $industries->appendChild($GLOBALS['core']->doc->createElement('industry'));
			$industryNode->setAttribute('anzsic_id',$industry->anzsic_id);
			$industryNode->setAttribute('description',$industry->description);
		}		

		// Login/logout/register user.
		if(isset($_REQUEST['action'])) {
			switch($_REQUEST['action']) {
				case 'login': {
					$this->doLogin();
					return;
				}
				case 'logout': {
					$this->doLogout();
					return;
				}
				case 'register': {
					$this->doRegister();
					return;
				}
			}
		}
		
		// Set the client if they are already logged in.
		$client = NULL;
		$contact = NULL;
		if ($this->session->get('uid')) {
			$contact = clientContact::stGetClientContactById($this->db, $this->session->get('uid'));
			$client = client::stGetClientById($this->db, $contact->client_id);
			$this->setClient($client, $contact);
		}
		
		return;
	}

	private function getCountries() {
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT
				`country`.`country_id`,
				`country`.`country`
			FROM `%1$s`.`country`;
		',
			DB_PREFIX.'resources'
		))) {
			while($row = $result->fetch_object()) {
				$this->countries[$row->country_id] = $row;
			}
			$result->close();
		}
		return;		
	}
	
	private function getIndustries() {
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`anzsic`
			ORDER BY `description`;
		',
			DB_PREFIX.'resources'
		))) {
			while($row = $result->fetch_object()) {
				$this->industries[$row->anzsic_id] = $row;
			}
			$result->close();
		}
		return;		
	}
	
	public function passwordRecovery() {
		$this->node->setAttribute('action','email_request');
		if(isset($_REQUEST['action']) && $_REQUEST['action'] == 'recoverPassword') {
			$error = array();
			$fields = array(
				array('Email','email',1)
			);
			$data = validateForm::validateDetails($fields,$error);
			if(!isset($error['email'])) {
				if($result = $this->db->query(sprintf('
					SELECT 
						`client_contact`.`client_contact_id`,
						`client_contact`.`client_id`
					FROM `%1$s`.`client_contact`
					WHERE `client_contact`.`email` = "%2$s";
				',
					DB_PREFIX.'core',
					$this->db->escape_string($data['email'])
				))) {
					$clientEmail = new clientEmail($this->db);
					
					while($row = $result->fetch_object()) {
						//Get the reset token and send the email to the client_contact
						$password = new password($this->db);
						$token = $password->generatePasswordResetToken($row->client_contact_id);

						$params = array(
							"reset_link" => "http://" . $_SERVER['HTTP_HOST'] . "/password-recovery/?token=" . $token . "&action=reset&email=" . $data['email'],
							"site_url" => $GLOBALS['core']->domain->site_url,
							"site_name" => $GLOBALS['core']->domain->site_name
						);
					
						//Send generic reset token password
						$clientEmail->sendClientContact(
							$row->client_id,
							$row->client_contact_id,
							'Password Change Request',
							'generic_password_change_request',
							$params
						);
					}

					$this->node->setAttribute('message', 'If your account was located, an email will be sent be sent with instructions for resetting your password.');
					
					$result->close();
				} 
			}			
			if(validateForm::writeErrors($this->doc,$this->node,$error)) return;
		}
		
		
		//If action is equal to reset, load the reset form
		if(isset($_REQUEST['action']) && ($_REQUEST['action'] == 'reset' || $_REQUEST['action'] == 'contactChangePassword')) {
			$this->node->setAttribute('action','reset');
			$this->node->setAttribute('valid','0');

			if($result = $this->db->query(sprintf('
				SELECT 
					`client_contact`.*
				FROM `%1$s`.`password_reset`
				LEFT JOIN `%1$s`.`client_contact` ON `password_reset`.`client_contact_id` = `client_contact`.`client_contact_id`
				WHERE `client_contact`.`email` = "%2$s"
				AND `password_reset`.`token` = "%3$s"
				AND `password_reset`.`timestamp` >= DATE_SUB(NOW(), INTERVAL 1 DAY);
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_REQUEST['email']),
				$this->db->escape_string($_REQUEST['token'])
				
			))) {
				if($result->num_rows == 1) {
					$row = $result->fetch_object();
					$this->node->setAttribute('action','reset');
					$this->node->setAttribute('valid','1');
					$requestedContact = $this->doc->createElement('requested_client_contact');
					$requestedContact->appendChild(clientContact::toXml($row, $this->doc));
					$this->node->appendChild($requestedContact);
				}
				$result->close();
			}
			
			if($_REQUEST['action'] == 'contactChangePassword') {
			
				//Now check the password reset if it has been set
				$contact = clientContact::stGetClientContactById($this->db, $_POST['client_contact_id']);
		
				$error = array();
			
				//Check that the fields are not empty
				$fields = array(
					array('New Password', 'password_0',1),
					array('Confirm  New password','password_1',1)
				);
			
				$data = validateForm::validateDetails($fields, $error);
	
				$this->validatePassword($error, $_POST['password_0'], $_POST['password_1']);
									
				if (validateForm::writeErrors($this->doc, $this->node, $error)) return;
			
				if (clientContact::resetPassword($this->db, $contact->client_contact_id, $_POST['password_0'])) {
					$this->node->setAttribute('action','resetCompleted');
					$this->node->setAttribute('valid','1');
				}
				
			}
		}
		
		return;
	}
	
	public function updateClient() {
		// Load all the contacts associated with this client.
		$contacts = clientContact::stGetClientContactsByClientId($this->db, $this->client->client_id);
		$allContactsNode = $this->doc->createElement('all_client_contacts');
		foreach ($contacts as $contact) {
			$allContactsNode->appendChild(clientContact::toXml($contact, $this->doc));
		}
		$this->node->appendChild($allContactsNode);
		
		// Load any REQUEST-string specified contact.
		if (isset($_REQUEST['client_contact_id'])) {
			$contact = clientContact::stGetClientContactByid($this->db, $_REQUEST['client_contact_id']);
			if ($contact) {
				$requestedContact = $this->doc->createElement('requested_client_contact');
				$requestedContact->appendChild(clientContact::toXml($contact, $this->doc));
				$this->node->appendChild($requestedContact);
			}
		}
				
		// Do any updates to the client/contact records.
		
		// GET-based actions.
		if (isset($_GET['action'])) {
			switch($_GET['action']) {
				case 'contactDelete': {
					// Load from the $_GET variable in case we want to allow users other than the
					// logged in client to modify the client data.
					$contact = clientContact::stGetClientContactById($this->db, $_GET['client_contact_id']);
					
					// Make sure this contact is one of the client's.
					if ($contact->client_id == $this->client->client_id) {
						clientContact::delete($this->db, $contact->client_contact_id);
						//header("Location: /members/account");
						header("Location: " . $_SERVER['REQUEST_URI']);
						die();
					}					
				}
			}
		}
		
		// POST-based actions.
		if (isset($_POST['action'])) {
			switch($_POST['action']) {
				case 'contactResetPassword': {
					$contact = clientContact::stGetClientContactById($this->db, $_POST['client_contact_id']);
					// Make sure the contact is one of the client's.
					if ($contact->client_id == $this->client->client_id) {
						if (clientContact::resetPassword($this->db, $contact->client_contact_id, $_REQUEST['new_password'])) {
							// $this->setClient($this->clientUtils->getClientByContactId($this->client->client_contact_id));
							echo "changed";
						}
						else {
							echo "error";
						}
					}
					die();
				}
				case 'clientSave': {
					// Load from the $_POST variable in case we want to allow users other than the
					// logged in client to modify the client data.
					$client = client::stGetClientById($this->db, $_POST['client_id']);

					// Make sure the client is the same as the one logged in.
					if ($client->client_id == $this->client->client_id) {
						$error = array();
						$fields = array(
							array('Organisation name','company_name',1),
							array('Address Line 1','address_line_1',1),
							array('Address Line 2','address_line_2',0),
							array('City','suburb',1),
							array('State','state',1),
							array('Post Code','postcode',1)
						);
						$data = validateForm::validateDetails($fields, $error);
						if (validateForm::writeErrors($this->doc, $this->node, $error)) return;
						
						client::update($this->db, $client->client_id, $data);
						// $this->setClient($this->clientUtils->getClientByContactId($this->client->client_contact_id));
						//header("Location: /members/account/");
						header("Location: " . $_SERVER['REQUEST_URI']);
						die();
					}
				}
				case 'contactEditSave';
				case 'contactSave': {
					// Load from the $_POST variable in case we want to allow users other than the
					// logged in client to modify the client data.
					$contact = clientContact::stGetClientContactById($this->db, $_POST['client_contact_id']);
					
					// Make sure the contact is one of the client's.
					if ($contact->client_id == $this->client->client_id) {
						$error = array();
						$fields = array(
							array('Salutation', 'salutation', 0),
							array('First name', 'firstname', 1),
							array('Last name', 'lastname', 1),
							array('Title/Position', 'position', 0),
							array('Phone', 'phone', 0),
							array('Email', 'email', 1, 'email')
						);
						$data = validateForm::validateDetails($fields, $error);
						//Validate Email, if it has been updated
						if($data['email'] != $contact->email) {
							$this->validateEmail($error,$data['email'], 'email');
						}
						if (validateForm::writeErrors($this->doc, $this->node, $error)) return;
					
						clientContact::update($this->db, $contact->client_contact_id, $data);
						//header("Location: /members/account/");
						header("Location: " . $_SERVER['REQUEST_URI']);
						die();
					}
				}
				case 'contactCreate': {
					$error = array();
					$fields = array(
						array('Salutation', 'salutation', 0),
						array('First name', 'firstname', 1),
						array('Last name', 'lastname', 1),
						array('Title/Position', 'position', 0),
						array('Phone', 'phone', 0),
						array('Email', 'email', 1, 'email'),
						array('Password', 'password_0', isset($_REQUEST['action']) && $_REQUEST['action'] == 'contactCreate' ? 1 : 0),
						array('Confirm password','password_1',isset($_REQUEST['action']) && $_REQUEST['action'] == 'contactCreate' ? 1 : 0)
					);
					$data = validateForm::validateDetails($fields, $error);
					$data['client_id'] = $_POST['client_id'];
					
					//Validate Email
					$this->validateEmail($error,$data['email'], 'email');
					
					//Validate the password
					if(isset($_REQUEST['action']) && $_REQUEST['action'] == 'contactCreate') {
						$this->validatePassword($error,$data['password_0'],$data['password_1']);
					}
					
					//Now validate the rest of the form
					if (validateForm::writeErrors($this->doc, $this->node, $error)) return;
					
					//If we are passed this stage, hash the password
					$data['password'] = password_hash($data['password_0'], PASSWORD_DEFAULT);
					$data['encrypted'] = '1';
				
					clientContact::create($this->db, $data);
					//header("Location: /members/account/");
					header("Location: " . $_SERVER['REQUEST_URI']);
					die();
				}
				case 'contactChangePassword': {
					// Load from the $_POST variable in case we want to allow users other than the
					// logged in client to modify the client data.
					$contact = clientContact::stGetClientContactById($this->db, $_POST['client_contact_id']);
					
					// Make sure this contact is one of the client's.
					if ($contact->client_id == $this->client->client_id) {
						$error = array();
						
						//Check that the fields are not empty
						$fields = array(
							array('New Password', 'password_0',1),
							array('Confirm  New password','password_1',1)
						);
						
						$data = validateForm::validateDetails($fields, $error);
				
						$this->validatePassword($error, $_POST['password_0'], $_POST['password_1']);
												
						if (validateForm::writeErrors($this->doc, $this->node, $error)) return;
						
						if (clientContact::resetPassword($this->db, $contact->client_contact_id, $_POST['password_0'])) {
							//header("Location: /members/account");
							header("Location: " . $_SERVER['REQUEST_URI']);
							die();
						}
					}
				}

			}
		}
		return;
	}
	
	private function updateClientContactLoginLog($contact, $fail) {
	
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`client_contact_login_log` SET
				`client_contact_id` = %2$d,
				`fail` = %3$d,
				`ip_address` = "%4$s",
				`timestamp` = NOW();
		',
			DB_PREFIX.'core',
			$contact->client_contact_id,
			$fail,
			$this->db->escape_string($_SERVER['REMOTE_ADDR'])
		));
		
		return;
	}
	
	private function checkAccountLockout($contact) {
		$lockout = null;
	
		//If the account is locked, and the lockout_expiry has been reached, unlock the account
		$lockout = $this->unlockAccount($contact->client_contact_id);
	
		//Check to see if the current account is locked
		$lockout = $this->isAccountLocked($contact->client_contact_id);
		
		//Now check to see if the user has failed login 5 times in 10 minutes
		$lockout = $this->isAccountLoginFailReached($contact->client_contact_id);
		
		//No errors, return for remianing login process.
		return;
	}
	
	private function unlockAccount($client_contact_id) {
		$this->db->query(sprintf('
			UPDATE `%1$s`.`client_contact` SET
				`locked_out` = 0,
				`locked_out_expiry` = NULL
			WHERE `client_contact_id` = %2$d
			AND `locked_out` = "1"
			AND `locked_out_expiry` < NOW()
			AND `locked_out_expiry` != "0000-00-00 00:00:00"
			AND `locked_out_expiry` IS NOT NULL;
		',
			DB_PREFIX.'core',
			$client_contact_id
		));

		return;
	}
	
	private function isAccountLoginFailReached($client_contact_id) {
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT COUNT(`client_contact_login_log`) AS `count`
			FROM `%1$s`.`client_contact_login_log`
			WHERE `client_contact_id` = %2$d
			AND `fail` = "1"
			AND `timestamp` >= NOW() - INTERVAL 10 MINUTE;
		',
			DB_PREFIX.'core',
			$client_contact_id
		))) {
			while($row = $result->fetch_object()) {
				if($row->count >= '5') {
					$this->db->query(sprintf('
						UPDATE `%1$s`.`client_contact` SET
							`locked_out` = 1,
							`locked_out_expiry` = NOW() + INTERVAL 20 MINUTE
						WHERE `client_contact_id` = %2$d
						AND `locked_out` != "1";
					',
						DB_PREFIX.'core',
						$client_contact_id
					));
				
					$this->doLogout("login-fail");
				}
			}
			$result->close();
		}

		return;
	}
	
	private function isAccountLocked($client_contact_id) {
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_contact`
			WHERE `client_contact_id` = %2$d
			AND `locked_out` = %3$d
			LIMIT 1;
		',
			DB_PREFIX.'core',
			$client_contact_id,
			1
		))) {
			while($row = $result->fetch_object()) {
				//If there is a result, the account is locked
				$this->doLogout("locked");
			}
			$result->close();
		}

		return;
	}
	
	private function doLogin() {
		$this->node->setAttribute('mode','login');
		$error = array();
		$fields = array(
			array('Username','username',1),
			array('Password','password',1),
			array('encoded','encoded',0)
		);
		$data = validateForm::validateDetails($fields,$error);
		if(validateForm::writeErrors($this->doc,$this->node,$error)) return;
		
		// Attempt to login with email address.
		$client = null;
		$contact = clientContact::stGetClientContactByEmail($this->db, $data['username']);
		if (!$contact) {
			// Attempt to login with client's username/password [deprecated].
			$client = client::stGetClientByUsername($this->db, $data['username']);
			if (!$client || !password_verify($data['password'],$client->password)) {
				$error['username'] = 'Username and/or password is incorrect.';
			}
		}
		else {
			// Attempt to verify contact's password.
			if (!password_verify($data['password'],$contact->password)) {
				$error['username'] = 'Username and/or password is incorrect.';
			}
		}
		
		//Log the login attempt with either a fail or pass
		if($contact) {
			$this->updateClientContactLoginLog($contact, isset($error['username']) ? '1':'0');
			$this->checkAccountLockout($contact);
		}
		
		if(validateForm::writeErrors($this->doc,$this->node,$error)) return;
		
		// The user logged in with the client username/password. Because this is deprecated,
		// notify the user that they cannot do this anymore however, notify the user
		// of the first contact's email address (if it exists).
		if ($client) {
			if ($client->contacts && $client->contacts[0]) {
				$this->node->appendChild($this->createNodeFromRecord('alternativeAuthContact', $client->contacts[0], array('salutation', 'firstname', 'lastname', 'email')));
			}
			$this->node->setAttribute('usernameAuthDeprecated', 'yes');
			
			// Send reminder email.
			$clientEmail = new clientEmail($this->db);
			$clientEmail->send(
				$client->client_id,
				'Your Green Business Password',
				'password_reminder'
			);
			
			return;
		}
		
		// Encode any location data.
		if($data['encoded']) {
			$data['encoded'] = unserialize(crypt::decrypt($data['encoded']));
			if(!isset($data['encoded']) || $data['encoded']['key'] != 'helloThere') {
				unset($data['encoded']);
			}
		}

		// Log-in the user (contact).
		$client = client::stGetClientById($this->db, $contact->client_id);
		$client->client_contact_id = $contact->client_contact_id;
		$this->setJwt($data['username'], $data['password']);
		$this->setClient($client, $contact);
		$this->session->save();
		
		if(isset($data['encoded']['location'])) {
			header('Location: '.$data['encoded']['location']);
			die();
		}
		return;
	}

	//Logout user, kill the session, redirect to home or login page
	private function doLogout($reason = null) {
		$this->session->reset();
		$this->session->save();
		$this->client = false;
		header("Location: " . strtok($_SERVER["REQUEST_URI"],'?') . (!is_null($reason) ? "?logout=" . $reason : ""));

		exit();
	}

	private function doRegister() {	
		$this->node->setAttribute('mode','register');
		$error	= array();
		
		$fields	= array(
			array('First name','firstname',1),
			array('Last name','lastname',1),
			array('Email','email',1,'email'),
			array('Company','company_name',1),
			array('Password','password',1),
			array('Confirm password','password_confirm',1),
			array('Street Address','address_line_1',0),
			array('Street Address','address_line_2',0),
			array('City', 'suburb',0),
			array('State', 'state',0),
			array('Zip/Post Code', 'postcode',0),
			array('Country', 'country',0),
			array('Industry', 'industry',0),
			array('Membership Number','membership_number',0),
			array('Agreement','service_agreement',0)
		);
		
		//Validate form data
		$data = validateForm::validateDetails($fields,$error);
		$this->validateEmail($error,$data['email']);
		$this->validatePassword($error,$data['password'],$data['password_confirm'], 'password');

		//Validation Check
		if(isset($_POST['legacy']) && $_POST['legacy'] === '1') {
			//Legacy
			$captcha = new captcha($this->db);
			if(!isset($_POST['verificationCode']) || !$captcha->validateVerificationImage($_POST['verificationCode'])) {
				$error['verificationCode'] = 'Incorrect Verification Code';
			}
		} else {
			//Google Captcha
			$recaptcha_url = 'https://www.google.com/recaptcha/api/siteverify?secret=' . GOOGLE_RECAPTCHA_SECRET_KEY . '&response=' . (isset($_REQUEST['g-recaptcha-response']) ? $_REQUEST['g-recaptcha-response'] : null);
	        $googleRecaptcha = json_decode(file_get_contents($recaptcha_url));
	        if($googleRecaptcha->success === false) {
	        	$error['Recaptcha Verification'] = 'Unable to verify reCaptcha';
	        }
		}

		//Return any errors to the form	
		if(validateForm::writeErrors($this->doc,$this->node,$error)) return;
		
		//Additional fields not specifically asked in the form
		$data['client_type_id'] = isset($_REQUEST['client_type_id']) ? $_REQUEST['client_type_id'] : 1;

		//Create the client
		$client = new client($this->db);
		$password = $data['password'];
		unset($data['password']); //Do not store in client table
		$client_id = $client->setClient($data);

		//Create the client contact
		$clientContact = new clientContact($this->db);
		$data['password'] = $password;
		$data['client_id'] = $client_id;
		$contactObject = $clientContact->setClientContact($data);
		
		if($contactObject->result > 1) {
			//Issue any products to the client account
			if(isset($_POST['product_id'])) {
				$pos = new pointOfSale($this->db);
				$pos->addProductToAccount($client_id,$_POST['product_id'],1);
			}
			
			//Get the client and contact details, then set the client login and session
			$contact = clientContact::stGetClientContactById($this->db, $contactObject->result);
			$client = client::stGetClientById($this->db, $client_id);
			$this->setJwt($data['email'], $data['password']);		
			$this->setClient($client, $contact);
			$this->session->save();
		}
		
		return;
	}

	private function setJwt($email, $password) {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, GBCAPI . '/auth/login');
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, "email=" . $email . "&password=" . $password);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		$output = curl_exec ($ch);
		curl_close ($ch);
		$response = json_decode($output);
		setcookie('gbc_token', isset($response->token) ? $response->token : null, null, '/', null, (isset($GLOBALS['core']->domain->ssl) && $GLOBALS['core']->domain->ssl == '1' && SERVER_ENV == 'remote') ? true : false, false);
	}
		
	private function setClient($client, $contact) {
		$this->client = $client;
		
		//Get the client node and add the fields to the XML output
		$clientNode = $this->node->appendChild($this->createNodeFromRecord('client', $client, array_keys((array)$client)));
		$contactNode = $clientNode->appendChild($this->createNodeFromRecord('contact', $contact, array_keys((array)$contact)));
				
		// Remember username/password cookie.
		if(isset($_REQUEST['remember']) || isset($_COOKIE['rem'])) {
			$expire = time()+(28*24*60*60); // 28 day
			$this->session->setExpiry($expire);
			setcookie('rem',1,$expire,'/', null, ($GLOBALS['core']->domain->ssl == '1' && SERVER_ENV == 'remote') ? true : false, true);
		} else {
			$expire = null;
		}
		
		//Set the login token when client logs in for the first time.
		if(!$this->session->get('uid')) {
			$this->session->set('token', uniqid($contact->client_contact_id));
		} else {
			//If the user has already been logged in, compare the client_contact_log
			$this->checkSingleSessionClient($client, $contact, $this->session->get('token'));
		}
		
		// Set the user as being logged in.
		$this->session->set('cid', $client->client_id);
		$this->session->set('uid', $contact->client_contact_id);
		
		//Update client log
		$this->updateClientLog($client, $contact, $this->session->get('token'));

		//At this point the client has authenticated, now check to see if the client has access to a dashboard interface
		$this->setDashboardAccess($contact->client_contact_id, $clientNode);
		$this->setModuleAccess($contact->client_contact_id, $contactNode);
		$this->setUserDefinedGroupMembership($contact->client_id, $contactNode);
		
		return;
	}

	/**
	 * Set User Defined Group Membership
	 *
	 * @param int $client_id
	 * @param xsl $clientNode
	 * @return void
	 */
	public function setUserDefinedGroupMembership($client_id, $clientNode) {
		$groups = $this->groups->getGroupMembership($client_id);

		foreach($groups as $group) {
			$clientNode->appendChild($this->createNodeFromArray('user_defined_group', $group, array_keys($group)));
		}

		return;
	}
	
	//Take the current client, contact and session token
	//If the same client contact has logged in elsewhere since
	//The current session, log this session out
	//to allow only single user sessions
	private function checkSingleSessionClient($client, $contact, $token) {
	
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_contact_log`
			WHERE `client_id` = %2$d
			AND `client_contact_id` = %3$d
			ORDER BY `timestamp` DESC
			LIMIT 1;
		',
			DB_PREFIX.'core',
			$client->client_id,
			$contact->client_contact_id
		))) {
			while($row = $result->fetch_object()) {
				if($row->token != $token) {
					$result->close();
					$this->doLogout("session");
				}
			}
			$result->close();
		}
		
		return;
	}
	
	//Log the client
	private function updateClientLog($client, $contact, $token) {
	
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`client_contact_log` SET
				`client_id` = %2$d,
				`client_contact_id` = %3$d,
				`ip_address` = "%4$s",
				`request` = "%5$s",
				`token` = "%6$s",
				`timestamp` = NOW();
		',
			DB_PREFIX.'core',
			$client->client_id,
			$contact->client_contact_id,
			$this->db->escape_string($_SERVER['REMOTE_ADDR']),
			$this->db->escape_string("http" . (isset($_SERVER['HTTPS']) ? "s" : "") . "://" . "{$_SERVER['HTTP_HOST']}{$_SERVER['REQUEST_URI']}"),
			$this->db->escape_string($token)
		));
		
		return;
	}
	

	//TODO - Change to check on client_type_id to allow multiple accounts accross multiple domains
	private function validateEmail(&$error ,$email, $key = 'contact_email') {
		if(isset($error['contact_email'])) return;
		if($result = $this->db->query(sprintf('
			SELECT 1
			FROM `%1$s`.`client_contact`
			WHERE `email` = "%2$s";
		',
			DB_PREFIX.'core',
			$this->db->escape_string($email)
		))) {
			if($result->num_rows > 0) {
				$error[$key] = 'This email address is already registered';
			}
			$result->close();
		}
		return;
	}
	
	private function validatePassword(&$error,$password_0,$password_1,$passwordFieldKey = 'password_0') {
		if(isset($error[$passwordFieldKey])) return;
		
		$password = new password($this->db);
		
		if(!$password->checkPasswordComplexity($password_0)) {
			$error[$passwordFieldKey] = 'Password does not meet complexity requirements.';
		}
		
		if($password_0 != $password_1) {
			$error[$passwordFieldKey] = 'Passwords don\'t match';
		} 
		
		return;
	}

	//Access the dashboard library, check the user has access, if so, set the appropriate nodes
	private function setDashboardAccess($client_contact_id, $clientNode) {

		$dashboard = new dashboard($this->db);
		$dashboardUser = $dashboard->getDashboardUser($client_contact_id);

		//We have a valid dashboard user, create the nodes required
		if(!empty($dashboardUser)) {

			$dashboardNode = $clientNode->appendChild(
				$this->createNodeFromRecord('dashboard', $dashboardUser, 
					array('client_contact_id','dashboard_group_id', 'dashboard_role_id')
				)
			);

		}

		return;
	}

	//Get the modules that the client contact has accessible to them
	private function setModuleAccess($client_contact_id, $contactNode) {

		$clientContact = new clientContact($this->db);
		$modules = $clientContact->getModuleAccess($client_contact_id);

		if(!empty($modules)) {
			foreach($modules as $module) {
				$contactNode->appendChild($this->createNodeFromRecord('module', $module, array_keys((array)$module)));
			}
		}

		return;
	}

	private function uniqueEmail($email) {
		$this->db->setDb(DB_PREFIX.'core');
		$contact = $this->db->where('email',$email)->getOne('client_contact');
		return empty($contact) ? true : false;
	}

	public function addClient() {
		$params = $this->setParams();
		$errors = array();
		$successes = array();
		$requiredFields = ['client_type_id' => 'Client Type', 'company_name' => (isset($params->record_type) ? $params->record_type . ' Name' : 'Company Name'), 'firstname' => 'First Name', 'lastname' => 'Last Name', 'email' => 'Email'];

		//Set countries
		if(isset($params->address) && $params->address == 'true') {
			$countries = new DOMDocument();
			$countries->load(realpath(dirname(__FILE__)) .'/countries.xml');
			$this->node->appendChild($this->doc->importNode($countries->documentElement, true));
		}

		//Set roles
		if(isset($params->clientRole) && $params->clientRole == 'true') {
			$requiredFields['clientrole'] = 'Client Role';
			$client_roles = $this->doc->createElement('client_roles');
			if($result = $GLOBALS['core']->db->query(sprintf('
				SELECT
					`client_role`.`client_role_id`,
					`client_role`.`client_role`,
					`client_role`.`client_type_id`
				FROM `%1$s`.`client_role`;
			',
				DB_PREFIX.'core'
			))) {
				while($row = $result->fetch_object()) {
					$client_roles->appendChild(clientRole::toXml($row, $this->doc));
				}
				$result->close();
			}
			$this->node->appendChild($client_roles);
		}

		if(isset($_POST['action']) && $_POST['action'] == 'addClient') {

			//Validate Data
			foreach($requiredFields as $key=>$field) {
				if(!isset($_POST[$key]) || (isset($_POST[$key]) && empty($_POST[$key]))) {
					$errors[] = array('message' => $field . ' is a required field.');
				}
			}

			//Validate Email Address
			if(!$this->uniqueEmail($_POST['email'])) {
				$errors[] = array('message' => 'Email is already registered.');
			}

			if(empty($errors)) {
				//Create Client
				$client = new client($this->db);
				$client_id = $client->setClient(
					[
						'company_name' => isset($_POST['company_name']) ? $_POST['company_name'] : null,
						'client_type_id' => isset($_POST['client_type_id']) ? $_POST['client_type_id'] : null,
						'address_line_1' => isset($_POST['address_line_1']) ? $_POST['address_line_1'] : null,
						'suburb' => isset($_POST['suburb']) ? $_POST['suburb'] : null,
						'state' => isset($_POST['state']) ? $_POST['state'] : null,
						'postcode' => isset($_POST['postcode']) ? $_POST['postcode'] : null,
						'country' => isset($_POST['country']) ? $_POST['country'] : null,
					]
				);

				$client_id > 0 ? $successes[] = array('message' => 'Account successfully created.') : $errors[] = array('message' => 'Account could not be created.');

				//Create User
				$clientContact = new clientContact($this->db);
				$password = new password($this->db);
				$client_contact = $clientContact->setClientContact(
					[
						'client_id' => isset($client_id) ? $client_id : null,
						'firstname' => isset($_POST['fistname']) ? $_POST['firstname'] : null,
						'lastname' => isset($_POST['lastname']) ? $_POST['lastname'] : null,
						'email' => isset($_POST['email']) ? $_POST['email'] : null,
						'password' => $password->generateRandomPassword()
					],
					false
				);

				$client_contact->result > 0 ? $successes[] = array('message' => 'User successfully created.') : $errors[] = array('message' => 'User could not be created.');

				//Create Client to Client Role
				if(isset($params->clientRole) && $params->clientRole == 'true') {
					$clientRole = new clientRole($this->db);
					$client_2_client_role_id = $clientRole->setClientToClientRole(
						[
							'client_id' => isset($client_id) ? $client_id : null,
							'client_role_id' => isset($_POST['clientrole']) ? $_POST['clientrole'] : null
						],
						false
					);

					$client_2_client_role_id > 0 ? $successes[] = array('message' => 'Role successfully created.') : $errors[] = array('message' => 'Role could not be created.');
				}

				//Add Form
				if(isset($params->checklist_id)) {
					$clientChecklist = new clientChecklist($this->db);
					$client_checklist_id = $clientChecklist->setNewClientChecklist(
						[
							'client_id' => isset($client_id) ? $client_id : null,
							'checklist_id' => isset($params->checklist_id) ? $params->checklist_id : null
						]
					);
					$client_checklist_id > 0 ? $successes[] = array('message' => 'Entry successfully created, <a class="default-link" href="/members/entry/' . $client_checklist_id . '/">Open entry</a>.') : $errors[] = array('message' => 'Entry could not be created.');
				}
			}

			//Report Success
			if(!empty($successes)) {
				$successNode = $this->node->appendChild($this->doc->createElement('success'));
				foreach($successes as $success) {
					$successNode->appendChild($this->createNodeFromRecord('item', (object)$success, array_keys($success)));
				}
				return;
			}

			//Report Errors
			if(!empty($errors)) {
				$errorNode = $this->node->appendChild($this->doc->createElement('error'));
				foreach($errors as $error) {
					$errorNode->appendChild($this->createNodeFromRecord('item', (object)$error, array_keys($error)));
				}
				return;
			}
		}

		return;
	}
}
?>
