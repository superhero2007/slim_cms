<?php
class admin {
	public $user = false;
	protected $db;
	protected $session;
	public $path;
	
	public function __construct() {
	
		//Load the session
		$this->session = new sessionCookie(SESSION_COOKIE);
	
		//Get the browser path
		$this->path = explode('/',$_SERVER['REQUEST_URI']);
		$this->db = new db(DB_HOST,DB_USER,DB_PASS);
		
		//If the user is logging out
		if(isset($_REQUEST['action'])) {
			switch($_REQUEST['action']) {
				case 'logout': {
					$this->doLogout();
					return;
				}
			}
		}

		if($this->session->get('uid')) {
			$this->setUser($this->session->get('uid'));
			return;
		}
		
		//If there is no session or cookie yet, try and authenticate the user
		$this->authenticate();
		
	}
	
	public function logout() {
		$this->doLogout();
	}
	
	//Get the user details
	private function setUser($uid) {
		if($this->path[1] != 'judging') {
			$sqlQuery = 'SELECT `admin`.`admin_id`, `admin`.`username`, `admin`.`firstname`, `admin`.`lastname`, `admin`.`admin_group_id`, `admin`.`admin_group_id` AS `dashboard_group_id`, `admin`.`admin_role_id` AS `dashboard_role_id` FROM `%1$s`.`admin` WHERE `admin`.`admin_id` = %2$d';
		} else {
			$sqlQuery = 'SELECT * FROM `%1$s`.`judge` WHERE `judge`.`judge_id` = %2$d';
		}

		$sql = sprintf('
			' . $sqlQuery . ';
		',
			$this->path[1] != 'judging' ? DB_PREFIX.'core' : DB_PREFIX.'judging',
			$this->db->escape_string($uid)
		);
			
		if($result = $this->db->query($sql)) {
			if($this->user = $result->fetch_object()) {
				$result->close();
				
				if($this->path[1] == 'admin' && $this->user->dashboard_group_id != '1') {
					//Client is not an admin client, log them out
					$this->doLogout();
				}
				
				return;
			}
			$result->close();
		} else {
			//The uid is invalid. Logout.
			$this->doLogout();
		}
	}
		
	private function authenticate() {
		if(isset($_REQUEST['username']) && isset($_REQUEST['password'])) {
				
			switch($this->path[1]) {
				case 'control-panel':
				case 'dashboard':
				case ' judging' :		$sqlQuery = 'SELECT `admin`.* FROM `%1$s`.`admin` WHERE `admin`.`username` = "%2$s"';
										$table = 'core';
										$conditional_admin_filter = '';
										break;
										
				case 'judging':			$sqlQuery = 'SELECT `judge`.* FROM `%1$s`.`judge` WHERE `judge`.`username` = "%2$s"';
										$conditional_admin_filter = "";
										$table = 'judging';
										break;
				
				case 'admin':			$sqlQuery = 'SELECT `admin`.* FROM `%1$s`.`admin` WHERE `admin`.`username` = "%2$s"';
										$conditional_admin_filter = 'AND `admin`.`admin_group_id` = 1';
										$table = 'core';
										break;
			}
		
			$sql = sprintf('
				' . $sqlQuery . '
				' . $conditional_admin_filter . ';
			',
				DB_PREFIX.$table,
				$this->db->escape_string($_REQUEST['username'])
			);
			
			if($result = $this->db->query($sql)) {
				if($this->user = $result->fetch_object()) {
					$result->close();
					
					//Judging has no password encryption for now
					if($this->path[1] != 'judging') {
						if(password_verify($_REQUEST['password'],$this->user->password)) {
							//Set the session for the user as they authenticated
							$this->doLogin($this->user);
							return;
						}
					} else {
						if($_REQUEST['password'] == $this->user->password) {
							//Set the session for the user as they authenticated
							$this->doLogin($this->user);
							return;
						}
					}
				}
			} else {
				print $this->db->error;
				die();
			}
		}
		//User has not authenticated, load the login form
		$location = 'location: login.php';
		
		if(isset($_REQUEST['action']) && $_REQUEST['action'] == 'login') {
			$location .= '?login-error=true';
		}
		
		header($location);
		
		die();
	}
	
	//Logout an admin user
	private function doLogout() {
	
		//$this->session = new sessionCookie(SESSION_COOKIE);

		$this->session->reset();
		$this->session->save('/'.$this->path[1].'/');
		$this->user = false;
		header('location: /' . $this->path[1] . '/');
		exit();
	}
	
	private function doLogin($user) {
	
		//$this->session = new sessionCookie(SESSION_COOKIE);
		
		// Remember username/password cookie.
		if(isset($_REQUEST['remember']) || isset($_COOKIE['rem'])) {
			$expire = time()+(28*24*60*60); // 28 day
			$this->session->setExpiry($expire);
			setcookie('rem',1,$expire,'/'.$this->path[1].'/');
		} else {
			$expire = null;
		}
		
		// Set the user as being logged in.
		if($this->path[1] != 'judging') {
			$this->session->set('uid', $user->admin_id);
		} else {
			$this->session->set('uid', $user->judge_id);
		}
		$this->session->save('/'.$this->path[1].'/');
		$this->setUser($this->session->get('uid'));
		
		return;
	}
}
?>