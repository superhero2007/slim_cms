<?php
/* 
*   ClientCoordinates model
*/

class clientCoordinates {

    private $db;
	private $clientCoordinatesFields = ['lat','lng'];

	public function __construct($db) {
		$this->db = $db;
	}

	/*
	*	Set clientCoordinates
	*/
	public function setClientCoordinates($client_id, $coordinates) {

		$query = sprintf('
			INSERT INTO %1$s.client_coordinates SET 
				client_id = %2$d, 
				updated = NOW()',
			DB_PREFIX . 'core',
			$this->db->escape_string($client_id));
		
		foreach($coordinates as $key=>$val) {
			if(in_array($key,$this->clientCoordinatesFields)) {
				$query .= sprintf(', %1$s = "%2$s"',$this->db->escape_string($key),$this->db->escape_string($val));
			}
		}

		$query .= ' ON DUPLICATE KEY UPDATE updated = NOW()';

		foreach($coordinates as $key=>$val) {
			if(in_array($key,$this->clientCoordinatesFields)) {
				$query .= sprintf(', %1$s = "%2$s"',$this->db->escape_string($key),$this->db->escape_string($val));
			}
		}

		$query .= ';';
		return $this->db->query($query);		
	}

	/*
	*	Get clientCoordinates
	*/
	public function getClientCoordinates($client_id) {
        $clientCoordinates = null;

		$query = sprintf('
            SELECT *
            FROM %1$s.client_coordinates
            WHERE client_id = %2$d;
		',
			$this->db_prefix . 'core',
			$this->db->escape_string($client_id)
		);

		$this->db->query($query);
		
		return $clientCoordinates;		
	}
}

?>