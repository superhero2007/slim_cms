<?php
class adminCore extends admin {
	
	public $platform;
	
	public function __construct() {
		//$this->setPlatform();
	}
	
	//Sets the current platform variable
	private function setPlatform() {
		$this->platform = $this->path[1];
	}
	
	//Gets the version of the current application running
	public function getAppVersion() {
		$appVersion = array();
	
	/*	if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`version`
			WHERE `system` = "%2$s"
			ORDER BY `version`.`timestamp` DESC
			LIMIT 1
		',
			DB_PREFIX.'core',
			$this->db->escape_string($this->platform)
		))) {
			while($row = $result->fetch_object()) {
		
				$appVersion[] = $row;
			}
			$result->close();
		}
	*/	
		return $appVersion;
	}
}
?>