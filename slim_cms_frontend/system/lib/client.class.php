<?php

class client extends dbModel {
		
	// STATIC METHODS
	// ------------------------------------------------------------------------------
		
	public static function stGetClientById($db, $client_id, $additionalWhere = NULL, $additionalVariables = NULL) {
		$client = new self($db);
		return $client->getClientById($client_id, $additionalWhere, $additionalVariables);
	}
	
	public static function stGetClientByUsername($db, $username) {
		$client = new self($db);
		return $client->getClientByUsername($username);
	}
	
	public static function toXml($client, $doc) {
		$clientNode = self::createElementWithAttributes($doc, 'client', $client);
		
		// Add contacts/contact tags if required.
		if (isset($client->contacts)) {
			$contactsNode = $doc->createElement('client_contacts');
			foreach ($client->contacts as $contact) {
				$contactsNode->appendChild(clientContact::toXml($contact, $doc));
			}
			$clientNode->appendChild($contactsNode);
		}
		
		return($clientNode);
	}
	
	public static function update($db, $client_id, $data, $var1 = null, $var2 = null) {
		$validFields = array('company_name', 'department', 'industry', 'address_line_1', 'address_line_2', 'suburb', 'state', 'postcode');
		$values = array();
		foreach ($validFields as $field) {
			if (isset($data[$field])) {
				$values[$field] = $data[$field];
			}
		}
		return parent::update($db, 'core', 'client', sprintf('client_id = %1$d', $client_id), $values);
	}

	// INSTANCE METHODS
	// ------------------------------------------------------------------------------

	public function batchUpdateClientCoordinates() {
		$clients = array();

		$query = sprintf('
			SELECT 
				`client`.`client_id`
			FROM `%1$s`.`client`
			LEFT JOIN `%1$s`.`client_coordinates` ON `client`.`client_id` = `client_coordinates`.`client_id`
			WHERE (`client_coordinates`.`updated` < DATE_SUB(NOW(), INTERVAL 1 MONTH) OR `client_coordinates`.`updated` IS NULL)
			#WHERE client.client_type_id = 30
			LIMIT 10;
		',
			DB_PREFIX . 'core'
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {				
				$clients[$row->client_id] = $row;
			}
			$result->close();
		}

		foreach($clients as $client) {
			$this->updateClientCoordinates($client->client_id);
		}

		return;
	}

	public function updateClientCoordinates($client_id) {
		$clients = array();
		$clientAddress = new clientAddress($this->db);
		$clientCoordinates = new clientCoordinates($this->db);
		$mapping = new mapping($this->db);

		$query = sprintf('
			SELECT 
				`client`.`client_id`,
				`client`.`company_name`,
				`client`.`address_line_1`,
				`client`.`address_line_2`,
				`client`.`suburb`,
				`client`.`state`,
				`client`.`country`,
				`client`.`postcode`,
				`client_coordinates`.`lat`,
				`client_coordinates`.`lng`
			FROM `%1$s`.`client`
			LEFT JOIN `%1$s`.`client_coordinates` ON `client`.`client_id` = `client_coordinates`.`client_id`
			WHERE client.client_id = %2$d;
		',
			DB_PREFIX . 'core',
			$this->db->escape_string($client_id)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {				
				$clients[$row->client_id] = $row;
			}
			$result->close();
		}

		foreach($clients as $client) {
			$address = array();
			$coordinates = array();

			$query = $client->address_line_1 . " " . $client->address_line_2 . " " . $client->suburb . " " . $client->state . " " . $client->country . " " . $client->postcode;
			$response = $mapping->getCoordinates($query);
			$response = empty($response->results) ? $mapping->getAddress($client->lat, $client->lng) : $response;

			if(isset($response->results[0]->address_components)) {
				foreach($response->results[0]->address_components as $address_component) {
					$address[$address_component->types[0]] = $address_component->long_name;
				}
				$clientAddress->setClientAddress($client->client_id, $address);

				if(isset($response->results[0]->geometry->location)) {
					foreach($response->results[0]->geometry->location as $key=>$val) {
						$coordinates[$key] = $val;
					}
					$clientCoordinates->setClientCoordinates($client->client_id, $coordinates);
				}
			}
		}

		return;
	}


	public function getClientById($client_id, $additionalWhere = NULL, $additionalVariables = NULL) {
		$client = NULL;
				
		if ($result = $this->query($this->clientSql().
			'WHERE `client`.`client_id` = %2$d
				'.$this->additionalWhereToSql($additionalWhere, true).'
			GROUP BY `client`.`client_id`;',	
			$this->additionalVariablesMerge(
				$additionalVariables,
				array(
					DB_PREFIX.'core',
					$client_id
				)
			)
		)) {
			if ($client = $result->fetch_object()) {
				$client->contacts = clientContact::stGetClientContactsByClientId($this->db, $client->client_id);
			}
			$result->close();
		}
		
		return($client);
	}
	
	//Return an array of all the possible client types
	public function getClientTypes($client_id = null) {

		$clientTypes = array();

		$filter = '';
		$filter .= !is_null($client_id) ? ' AND `client`.`client_id` IN(' . (is_array($client_id) ? implode(',', $client_id) : $client_id) . ')' : null;

		$query = sprintf('
			SELECT `client_type`.*,
			COUNT(DISTINCT `client`.`client_id`) AS `count`,
			COUNT(DISTINCT `client_contact`.`client_contact_id`) AS `users`
			FROM `%1$s`.`client_type`
			LEFT JOIN `%1$s`.`client` ON `client_type`.`client_type_id` = `client`.`client_type_id`
			LEFT JOIN `%1$s`.client_contact ON client.client_id = client_contact.client_id
			WHERE `client`.`status` != 3
			%2$s
			GROUP BY `client_type`.`client_type_id`;
		',
			DB_PREFIX.'core',
			$this->db->escape_string($filter)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				
				$clientTypes[] = $row;
			}
			$result->close();
		}

		
		return $clientTypes;
	}

	public function getClientType($client_type_id = null) {
		$clientTypes = array();

		$filter = '';
		$filter .= !is_null($client_type_id) ? ' AND client_type.client_type_id IN(' . (is_array($client_type_id) ? implode(',', $client_type_id) : $client_type_id) . ')' : null;
		$query = sprintf('
			SELECT
			client_type.*,
			COUNT(DISTINCT `client`.`client_id`) AS `count`,
			COUNT(DISTINCT `client_contact`.`client_contact_id`) AS `users`
			FROM %1$s.client_type
			LEFT JOIN `%1$s`.`client` ON `client_type`.`client_type_id` = `client`.`client_type_id`
			LEFT JOIN `%1$s`.client_contact ON client.client_id = client_contact.client_id
			WHERE `client`.`status` != 3
			%2$s
			GROUP BY `client_type`.`client_type_id`;', 
			DB_PREFIX.'core', 
			$this->db->escape_string($filter)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clientTypes[] = $row;
			}
			$result->close();
		}
		
		return $clientTypes;
	}
	
	public function getClientByUsername($username) {
		$client = NULL;
				
		if ($result = $this->query($this->clientSql().
			'WHERE `client`.`username` = "%2$s"
			GROUP BY `client`.`client_id`;',	
			array(
				DB_PREFIX.'core',
				$this->db->escape_string($username)
			)
		)) {
			if ($client = $result->fetch_object()) {
				$client->contacts = clientContact::stGetClientContactsByClientId($this->db, $client->client_id);
			}
			$result->close();
		}
		
		return $client;
	}
	
	private function clientSql() {
		return '
			SELECT 
				`client`.*,
				DATE(`client`.`registered`) AS `date_registered`,
				DATE(`client_log`.`timestamp`) AS `last_active`,
				`client_type`.`client_type`
			FROM `%1$s`.`client`
			LEFT JOIN `%1$s`.`client_type` ON `client`.`client_type_id` = `client_type`.`client_type_id`
			LEFT JOIN `%1$s`.`client_log` USING(`client_id`)
		';
	}

	//Get clients
	//Filter by client_id, client_type_id
	public function getClients($client_id = null, $client_type_id = null) {
		$clients = array();
		$filter = '';
		$filter .= !is_null($client_id) ? ' AND `client_id` IN( ' . (is_array($client_id) ? implode(',',$client_id) : $client_id)  . ')' : null;
		$filter .= !is_null($client_type_id) ? ' AND `client_type_id` IN(' . $client_type_id . ')' : null;

		$query = sprintf('
			SELECT *
			FROM `%1$s`.`client`
			WHERE 1 %2$s
			ORDER BY client.company_name;
		',
			DB_PREFIX.'core',
			$this->db->escape_string($filter)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clients[] = $row;
			}
			$result->close();
		}
		
		return $clients;
	}

	//Get clients by company name
	//Filter by company_name, client_type_id
	public function getClientsByCompanyName($company_name = null, $client_type_id = null) {

		if(is_array($company_name)) {
			foreach($company_name as $key=>$val) {
				$company_name[$key] = str_replace('\'', '\\\'', $val);
			}
		} else {
			$company_name = str_replace('\'', '\\\'', $company_name);
		}

		$clients = array();
		$filter = '';
		$filter .= !is_null($company_name) ? ' AND `company_name` IN(' . (is_array($company_name) ? '\'' . implode(',\'',$company_name) . '\'' : '\'' . $company_name . '\'')  . ')' : null;
		$filter .= !is_null($client_type_id) ? ' AND `client_type_id` IN(' . $client_type_id . ')' : null;

		$query = sprintf('
			SELECT *
			FROM `%1$s`.`client`
			WHERE 1 %2$s
			ORDER BY client.company_name;
		',
			DB_PREFIX.'core',
			//$this->db->escape_string($filter)
			$filter
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$clients[] = $row;
			}
			$result->close();
		}
		
		return $clients;
	}

	public function setClient($data) {
		$query = parent::prepare_query('core', 'client', 'INSERT INTO', $data);
		$this->db->query($query);

		$client_id = $this->db->insert_id;

		if($client_id > 0) {
			//Set the client account number
			$this->db->query(sprintf('
				UPDATE `%1$s`.`client` SET
					`account_no` = "%3$s"
				WHERE `client_id` = %2$d
			',
				DB_PREFIX.'core',
				$client_id,
				clientUtils::luhn($client_id,time())
			));

			//Set the client address and coordinates
			$this->updateClientCoordinates($client_id);
		}
		
		return $client_id;
	}

	public function updateClient($data, $where) {
		$query = parent::prepare_query('core', 'client', 'UPDATE', $data, $where);
		$this->db->query($query);
		
		return $this->db->affected_rows;
	}

	public function deleteClients($client_ids) {
		$query = sprintf('
			DELETE FROM `%1$s`.`client`
			WHERE `client_id` IN (%3$s);
			DELETE FROM `%1$s`.`client_contact`
			WHERE `client_id` IN (%3$s);
			DELETE FROM `%1$s`.`client_note`
			WHERE `client_id` IN (%3$s);
			DELETE FROM `%2$s`.`client_result`
			WHERE `client_checklist_id IN (
				SELECT `client_checklist_id`
				FROM `%2$s`.`client_checklist`
				WHERE `client_id` IN (%3$s);
			);
			DELETE FROM `%2$s`.`additional_value`
			WHERE `client_checklist_id IN (
				SELECT `client_checklist_id`
				FROM `%2$s`.`client_checklist`
				WHERE `client_id` IN (%3$s);
			);
			DELETE FROM `%2$s`.`client_commitment`
			WHERE `client_checklist_id IN (
				SELECT `client_checklist_id`
				FROM `%2$s`.`client_checklist`
				WHERE `client_id` IN (%3$s);
			);
			DELETE FROM `%2$s`.`client_checklist`
			WHERE `client_id` IN (%3$s);
			OPTIMIZE TABLE
				`%1$s`.`client`,
				`%1$s`.`client_contact`,
				`%1$s`.`client_note`,
				`%2$s`.`client_checklist`,
				`%2$s`.`additional_value`,
				`%2$s`.`client_result`,
				`%2$s`.`client_commitment`;
		',
			DB_PREFIX.'core',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_ids)
		);

		$this->db->multi_query($query);
	}

	public function archiveClients($client_ids) {
		$query = sprintf('
			UPDATE `%1$s`.`client`
			SET `status` = 3
			WHERE `client_id` IN (%3$s);

			UPDATE `%1$s`.`client_contact`
			SET `locked_out` = 1
			WHERE `client_id` IN (%3$s);

			UPDATE `%2$s`.`client_checklist`
			SET `status` = 4
			WHERE `client_id` IN (%3$s);
		',
			DB_PREFIX.'core',
			DB_PREFIX.'checklist',
			$this->db->escape_string($client_ids)
		);

		$this->db->multi_query($query);
	}
}

?>
