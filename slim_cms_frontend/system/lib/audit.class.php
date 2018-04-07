<?php
class audit {
	public $user = false;
	protected $db;
	protected $session;
	
	public function __construct($associate=false) {
		$this->db = new mysqli(DB_HOST,DB_USER,DB_PASS);
		$this->db->autocommit(MYSQL_AUTOCOMMIT);
		
		//If the user is logging out
		if(isset($_REQUEST['action'])) {
			switch($_REQUEST['action']) {
				case 'logout': {
					$this->doLogout();
					return;
				}
			}
		}
		
		$this->authenticate($associate);
		$this->session = new sessionCookie(SESSION_COOKIE);
	}
		
	private function authenticate($associate) {
		if(isset($_SERVER['PHP_AUTH_USER']) && isset($_SERVER['PHP_AUTH_PW'])) {
				$sql = sprintf('
					SELECT
						`auditor`.*
					FROM `%1$s`.`auditor`
					WHERE `auditor`.`username` = "%2$s"
					AND `auditor`.`password` = "%3$s";
				',
					DB_PREFIX.'audit',
					$this->db->escape_string($_SERVER['PHP_AUTH_USER']),
					$this->db->escape_string($_SERVER['PHP_AUTH_PW'])
				);
			if($result = $this->db->query($sql)) {
				if($this->user = $result->fetch_object()) {
					$result->close();
					return;
				}
				$result->close();
			} else {
				print $this->db->error;
				die();
			}
		}
		$this->sendHeaders($associate);
	}
	
	private function sendHeaders($associate) {
		header('WWW-Authenticate: Basic realm="GreenBizCheck Audit');
		header('HTTP/1.0 401 Unauthorized');
		print '<h1>Access Denied</h1>';
		die();
	}
	
	//Logout an audit user
	private function doLogout() {
		$this->sendHeaders(null);
	}
}
?>