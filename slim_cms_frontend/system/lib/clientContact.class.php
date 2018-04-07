<?php

class clientContact extends dbModel {
	
	// STATIC METHODS
	// ------------------------------------------------------------------------------

	public static function stGetClientContactById($db, $client_contact_id, $additionalWhere = NULL, $additionalVariables = NULL) {
		$contact = new self($db);
		return $contact->getClientContactById($client_contact_id);
	}
	
	public static function stGetClientContactsByClientId($db, $client_id, $additionalWhere = NULL, $additionalVariables = NULL) {
		$contact = new self($db);
		return $contact->getClientContactsByClientId($client_id);
	}

	public static function stGetClientContactByEmail($db, $email, $additionalWhere = NULL, $additionalVariables = NULL) {
		$contact = new self($db);
		return $contact->getClientContactByEmail($email);
	}
	
	public static function toXml($client_contact, $doc) {
		$clientContactNode = self::createElementWithAttributes($doc, 'client_contact', $client_contact);
		return($clientContactNode);
	}
	
	//Returns the account owners details if the account owner exists
	public static function stGetAccountOwnerByClientId($db, $client_id, $additionalWhere = NULL, $additionalVariables = NULL) {
		$contact = new self($db);
		return $contact->getAccountOwnerByClientId($client_id);
	}

	public static function resetPassword($db, $client_contact_id, $password) {
		return $db->query(sprintf('
			UPDATE `%1$s`.`client_contact` SET 
			`password` = "%2$s",
			`encrypted` = "%4$s"	
			WHERE `client_contact_id` = %3$d
		',
			DB_PREFIX.'core',
			$db->escape_string(password_hash($password, PASSWORD_DEFAULT)),
			$client_contact_id,
			1
		));
	}
	
	public static function update($db, $client_contact_id, $data, $var1 = null, $var2 = null) {
		$validFields = array('client_id', 'salutation', 'firstname', 'lastname', 'position', 'phone', 'email');
		$values = array();
		foreach ($validFields as $field) {
			if (isset($data[$field])) {
				$values[$field] = $data[$field];
			}
		}
		return parent::update($db, 'core', 'client_contact', sprintf('client_contact_id = %1$d', $client_contact_id), $values);
	}

	public static function create($db, $data, $var1 = null, $var2 = null) {
		$validFields = array('client_id', 'salutation', 'firstname', 'lastname', 'position', 'phone', 'email', 'password', 'encrypted');
		$values = array();
		foreach ($validFields as $field) {
			if (isset($data[$field])) {
				$values[$field] = $data[$field];
			}
		}
		return parent::create($db, 'core', 'client_contact', $values);
	}
	
	public static function delete($db, $client_contact_id, $var1 = null, $var2 = null, $var3 = null) {
		return parent::delete($db, 'core', 'client_contact', sprintf('client_contact_id = %1$d', $client_contact_id));
	}

	// INSTANCE METHODS
	// ------------------------------------------------------------------------------

	public function getClientContactById($client_contact_id, $additionalWhere = NULL, $additionalVariables = NULL) {
		$client_contact = NULL;
		
		if ($result = $this->query('
			SELECT *
			FROM `%1$s`.`client_contact`
			WHERE `client_contact`.`client_contact_id` = %2$d '.
				$this->additionalWhereToSql($additionalWhere, true)
		,
			$this->additionalVariablesMerge(
				$additionalVariables,
				array(
					DB_PREFIX.'core',
					$client_contact_id
				)
			)
		)) {
			$client_contact = $result->fetch_object();
			$client_contact = !is_null($client_contact) ? $this->getDashboardAccess($client_contact) : $client_contact;
			$result->close();
		}
		
		return($client_contact);
	}

	private function getDashboardAccess($client_contact) {
		$dashboard = new dashboard($this->db);
		$dashboardUser = $dashboard->getDashboardUser($client_contact->client_contact_id);

		$client_contact->dashboard_group_id = isset($dashboardUser->dashboard_group_id) ? $dashboardUser->dashboard_group_id : null;
		$client_contact->dashboard_role_id = isset($dashboardUser->dashboard_role_id) ? $dashboardUser->dashboard_role_id : null;

		return $client_contact;
	}
	
	public function getClientContactsByClientId($client_id, $additionalWhere = NULL, $additionalVariables = NULL) {
		$client_contacts = array();
		
		if ($result = $this->query('
			SELECT *
			FROM `%1$s`.`client_contact`
			WHERE `client_contact`.`client_id` = %2$d '.
				$this->additionalWhereToSql($additionalWhere, true)
		,
			$this->additionalVariablesMerge(
				$additionalVariables,
				array(
					DB_PREFIX.'core',
					$client_id
				)
			)
		)) {
			while ($row = $result->fetch_object()) {
				$client_contacts[] = $row;
			}
			$result->close();
		}
		
		return($client_contacts);
	}
	
	//Get the account owner of the given client_id
	public function getAccountOwnerByClientId($client_id, $additionalWhere = NULL, $additionalVariables = NULL) {
		$client_contacts;
		
		if ($result = $this->query('
			SELECT
			`client_contact`.*,
			`client`.`company_name`
			FROM `%1$s`.`client_contact`
			LEFT JOIN `%1$s`.`client` ON `client_contact`.`client_id` = `client`.`client_id`
			WHERE `client_contact`.`client_id` = (SELECT `client`.`parent_id` FROM `greenbiz_core`.`client` WHERE `client`.`client_id` = %2$d)
			LIMIT 1'.
				$this->additionalWhereToSql($additionalWhere, true)
		,
			$this->additionalVariablesMerge(
				$additionalVariables,
				array(
					DB_PREFIX.'core',
					$client_id
				)
			)
		)) {
			while ($row = $result->fetch_object()) {
				$client_contacts = $row;
			}
			
			$result->close();
		}
		
		return($client_contacts);
	}

	public function getClientContactByEmail($email, $additionalWhere = NULL, $additionalVariables = NULL) {
		$client_contact = null;
		
		if ($result = $this->query('
			SELECT *
			FROM `%1$s`.`client_contact`
			WHERE `client_contact`.`email` = "%2$s" '.
				$this->additionalWhereToSql($additionalWhere, true)
		,
			$this->additionalVariablesMerge(
				$additionalVariables,
				array(
					DB_PREFIX.'core',
					$this->db->escape_string($email)
				)
			)
		)) {
			$client_contact = $result->fetch_object();
			$result->close();
		}
		
		return $client_contact;
	}

	private function validateEmail($email, $client_contact_id = null) {
		$errors = array();

		//Check for valid email
		if(filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
			$errors[] = array('type' => 'error', 'key' => 'Email', 'message' => EMAIL_ADDRESS_INVALID);
		}

		//Check already registered email
		if(!is_null($this->getClientContactByEmail($email, !is_null($client_contact_id) ? 'AND `client_contact`.`client_contact_id` != "' . $client_contact_id . '"' : null))) {
			$errors[] = array('type' => 'error', 'key' => 'Email', 'message' => EMAIL_ADDRESS_ALREADY_REGISTERED);
		}

		return $errors;
	}

	//Get clientContacts
	//Filter by client_contact_id, client_type_id
	public function getClientContacts($client_id = null, $client_contact_id = null, $client_type_id = null, $multiple = true) {
		$clientContacts = array();
		$filter = '';
		$filter .= !is_null($client_id) ? ' AND `client_contact`.`client_id` = ' . $client_id : '';
		$filter .= !is_null($client_contact_id) ? ' AND `client_contact`.`client_contact_id` = ' . $client_contact_id : '';
		$filter .= !is_null($client_type_id) ? ' AND `client`.`client_type_id` IN(' . $client_type_id  .')' : '';

		$query = sprintf('
			SELECT
			`client_contact`.*
			FROM `%1$s`.`client_contact`
			LEFT JOIN `%1$s`.`client` ON `client_contact`.`client_id` = `client`.`client_id`
			WHERE 1%2$s;
		',
			DB_PREFIX.'core',
			$this->db->escape_string($filter)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				unset($row->password);
				if($multiple) {
					$clientContacts[] = $row;
				} else {
					$clientContacts = $row;
				}
			}
			$result->close();
		}
		
		return $clientContacts;
	}

	public function getModuleAccess($client_contact_id) {
		$modules = array();

		$query = sprintf('
			SELECT
			`module`.*
			FROM `%1$s`.`client_contact_2_module`
			LEFT JOIN `%1$s`.`module` ON `client_contact_2_module`.`module_id` = `module`.`module_id`
			WHERE `client_contact_2_module`.`client_contact_id` = %2$d;
		',
			DB_PREFIX.'core',
			$this->db->escape_string($client_contact_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$modules[] = $row;
			}
			$result->close();
		}
		
		return $modules;
	}

	public function deleteClientContacts($client_contact_id) {
		$response = new stdClass;
		$response->result = false;
		$response->messages = array();

		$query = sprintf('
			DELETE FROM `%1$s`.`client_contact`
			WHERE `client_contact`.`client_contact_id` IN(%3$s);
			
			DELETE FROM `%1$s`.`client_contact_log`
			WHERE `client_contact_log`.`client_contact_id` IN(%3$s);

			DELETE FROM `%2$s`.`client_contact_2_checklist`
			WHERE `client_contact_id` IN (%3$s);

			DELETE FROM `%2$s`.`client_contact_2_client`
			WHERE `client_contact_id` IN (%3$s);

			DELETE FROM `%2$s`.`client_contact_2_dashboard`
			WHERE `client_contact_id` IN (%3$s);
			
			OPTIMIZE TABLE `%1$s`.`client_contact`;
			OPTIMIZE TABLE `%1$s`.`client_contact_log`;
			OPTIMIZE TABLE `%2$s`.`client_contact_2_checklist`;
			OPTIMIZE TABLE `%2$s`.`client_contact_2_client`;
			OPTIMIZE TABLE `%2$s`.`client_contact_2_dashboard`;
		',
			DB_PREFIX.'core',
			DB_PREFIX.'dashboard',
			$this->db->escape_string(is_array($client_contact_id) ? implode(',',$client_contact_id) : $client_contact_id)
		);

		$this->db->multi_query($query);

		//Wait for the multi_queryt to complete
		while ($this->db->next_result()) {;}

		switch($this->db->affected_rows) {
			case 0:	$response->messages[] = array('type' => 'error', 'key' => 'User', 'message' => USER_DELETE_FAIL);
				break;

			case 1:	$response->messages[] = array('type' => 'success', 'key' => 'User', 'message' => USER_DELETE_SUCCESS);
				break;

			default:	$response->messages[] = array('type' => 'success', 'key' => 'User', 'message' => USERS_DELETE_SUCCESS);
				break;
		}

		return $response;
	}

	public function setClientContact($data) {
		$response = new stdClass;
		$response->result = false;
		$password = new password($this->db);
		$response->messages = array_merge($password->validatePassword($data['password'], isset($data['password_confirm']) ? $data['password_confirm'] : null), $this->validateEmail($data['email']));

		//If no errors, continue with the insert
		if(!in_array('error', array_column($response->messages, 'type'))) {
			$data['password'] = password_hash($data['password'], PASSWORD_DEFAULT);
			$data['encrypted'] = 1;
			$query = parent::prepare_query('core', 'client_contact', 'INSERT INTO', $data);
			$this->db->query($query);
			$response->result = $this->db->insert_id;
			$response->messages[] = array('type' => 'success', 'key' => 'User', 'message' => USER_INSERT_SUCCESS);
		}
		
		return $response;
	}

	public function updateClientContact($data, $where) {
		$response = new stdClass;
		$response->result = false;
		$response->messages = $this->validateEmail($data['email'], isset($where['client_contact_id']) ? $where['client_contact_id'] : null);

		//Make sure the password is valid, if set
		if(isset($data['password'])) {
			$password = new password($this->db);
			$response->messages = array_merge($response->messages,$password->validatePassword($data['password'], isset($data['password_confirm']) ? $data['password_confirm'] : null));
			$data['password'] = password_hash($data['password'], PASSWORD_DEFAULT);;
			$data['encrypted'] = 1;	
		}

		//If no errors, update
		if(!in_array('error', array_column($response->messages, 'type'))) {
			$query = parent::prepare_query('core', 'client_contact', 'UPDATE', $data, $where);
			$this->db->query($query);
			$response->result = $this->db->affected_rows;
			$response->messages[] = array('type' => 'success', 'key' => 'User', 'message' => USER_UPDATE_SUCCESS);
		}
		
		return $response;
	}	
}

?>
