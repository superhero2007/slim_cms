<?php
/* 
*   ClientAddress model
*/

class clientAddress {

    private $db;
	private $clientAddressFields = ['street_number','route','locality','administrative_area_level_1','administrative_area_level_2', 'country','postal_code'];

	public function __construct($db) {
		$this->db = $db;
	}

	/*
	*	Set clientAddress
	*/
	public function setClientAddress($client_id, $address) {

		$query = sprintf('
			INSERT INTO %1$s.client_address SET 
				client_id = %2$d, 
				updated = NOW()',
			DB_PREFIX . 'core',
			$this->db->escape_string($client_id));
		
		foreach($address as $key=>$val) {
			if(in_array($key,$this->clientAddressFields)) {
				$query .= sprintf(', %1$s = "%2$s"',$this->db->escape_string($key),$this->db->escape_string($val));
			}
		}

		$query .= ' ON DUPLICATE KEY UPDATE updated = NOW()';

		foreach($address as $key=>$val) {
			if(in_array($key,$this->clientAddressFields)) {
				$query .= sprintf(', %1$s = "%2$s"',$this->db->escape_string($key),$this->db->escape_string($val));
			}
		}

		$query .= ';';
		return $this->db->query($query);	
	}

	/*
	*	Get clientAddress
	*/
	public function getClientAddress($client_id) {
        $clientCoordinates = null;

		$query = sprintf('
            SELECT *
            FROM %1$s.client_address
            WHERE client_id = %2$d;
		',
			$this->db_prefix . 'core',
			$this->db->escape_string($client_id)
		);

		$this->db->query($query);
		
		return $clientAddress;		
	}
}

?>