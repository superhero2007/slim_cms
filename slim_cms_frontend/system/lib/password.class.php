<?php
/*

Checks password complexity and generates random passwords

*/

class password {
	private $db;
	
	public function __construct($db) {
		$this->db = $db;
	}

	public function validatePassword($password,$password_confirm = null) {
		$errors = array();

		if(!$this->checkPasswordComplexity($password)) {
			$errors[] = array('type' => 'error', 'key' => 'Password', 'message' => PASSWORD_COMPLEXITY_ERROR);
		}

		if(!is_null($password_confirm)) {
			if($password_confirm != $password) {
				$errors[] = array('type' => 'error', 'key' => 'Password', 'message' => PASSWORD_CONFIRM_ERROR);
			}
		}
		
		return $errors;
	}	
	
	//Check the password complexity
	//Returns true if the password meets complexity requirements
	public function checkPasswordComplexity($password) {
		$pass = true;
	
		//Check the password is minimum 8 chars
		if(strlen($password) < 8)
		{
		 	$pass = false;
		}

		//Check the password is maximum 60 chars
		if(strlen($password) > 60)
		{
			$pass = false;
		}
		
		//Check the password contains numbers
		if(!preg_match("#[0-9]+#", $password))
		{
			$pass = false;
		}
		
		//Check the password contains a capital letter
		if(!preg_match("#[A-Z]+#", $password)) 
		{
			$pass = false;
		}
		
		//Check the password contains a symbol
		if(!preg_match("#\W+#", $password))
		{
		 	$pass = false;
		}
	
		return $pass;
	}
	
	//Return a ramdom, complexity checked password for password reset
	public function generateRandomPassword() {
		$valid = false;
		$alphabet = "abcdefghijklmnopqrstuwxyzABCDEFGHIJKLMNOPQRSTUWXYZ0123456789!@#$%^&*()";
		$alphaLength = strlen($alphabet) - 1; //put the length -1 in cache
		
		do {
			
			$pass = array(); //remember to declare $pass as an array
			for ($i = 0; $i < 8; $i++) {
				$n = rand(0, $alphaLength);
				$pass[] = $alphabet[$n];
			}
    		$password = implode($pass); //turn the array into a string
    		
    		//Check the password complexity, if valid, pass
    		$valid = $this->checkPasswordComplexity($password);
		
		} while (!$valid);
		
		return $password;
	}
	
	//Update all passwords to be encrypted
	public function encryptAllPasswords() {
		$client_contacts = array();
		
		//Get all client_contacts
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_contact`;
		',
			DB_PREFIX.'core'
		))) {
				while($row = $result->fetch_object()) {
					$client_contacts[] = $row;
				}		
			}
			
		//Now loop through the client_contacts to make sure the passwords are encrypted
		foreach($client_contacts as $client_contact) {
			if($client_contact->encrypted == 0) {
			
				$this->db->query(sprintf('
					UPDATE `%1$s`.`client_contact` SET
						`password` = "%2$s",
						`encrypted` = %3$d
					WHERE `client_contact_id` = %4$d;
				',
					DB_PREFIX.'core',
					password_hash($client_contact->password, PASSWORD_DEFAULT),
					1,
					$this->db->escape_string($client_contact->client_contact_id)
				));
			
			}
		}
		
		$result->close();	
	
		return;
	}
	
	//Update admin passwords to make sure that they are encrypted
	public function encryptAllAdminPasswords() {
		$admin_users = array();
		
		//Get all admin users
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`admin`;
		',
			DB_PREFIX.'core'
		))) {
				while($row = $result->fetch_object()) {
					$admin_users[] = $row;
				}		
			}
			
		//Now loop through the client_contacts to make sure the passwords are encrypted
		foreach($admin_users as $admin_user) {
			if($admin_user->encrypted == 0) {
			
				$this->db->query(sprintf('
					UPDATE `%1$s`.`admin` SET
						`password` = "%2$s",
						`encrypted` = %3$d
					WHERE `admin_id` = %4$d;
				',
					DB_PREFIX.'core',
					password_hash($admin_user->password, PASSWORD_DEFAULT),
					1,
					$this->db->escape_string($admin_user->admin_id)
				));
			
			}
		}
		
		$result->close();	
	
		return;
	}
	
	//Generate a random token for reseting the client password after it has been forgotton
	function crypto_rand_secure($min, $max) {
			$range = $max - $min;
			if ($range < 0) return $min; // not so random...
			$log = log($range, 2);
			$bytes = (int) ($log / 8) + 1; // length in bytes
			$bits = (int) $log + 1; // length in bits
			$filter = (int) (1 << $bits) - 1; // set all lower bits to 1
			do {
				$rnd = mt_rand();
				$rnd = $rnd & $filter; // discard irrelevant bits
			} while ($rnd >= $range);
			return $min + $rnd;
	}

	//Seed the token for reseting the client password
	function getToken($length=32){
		$token = "";
		$codeAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		$codeAlphabet.= "abcdefghijklmnopqrstuvwxyz";
		$codeAlphabet.= "0123456789";
		for($i=0;$i<$length;$i++){
			$token .= $codeAlphabet[$this->crypto_rand_secure(0,strlen($codeAlphabet))];
		}
		return $token;
	}
	
	function generatePasswordResetToken($client_contact_id) {
		$resetToken = $this->getToken();
		
		$this->db->query(sprintf('
			REPLACE INTO `%1$s`.`password_reset` SET
				`client_contact_id` = %2$d,
				`token` = "%3$s";
		',
			DB_PREFIX.'core',
			$this->db->escape_string($client_contact_id),
			$this->db->escape_string($resetToken)
		));
		
		return $resetToken;
	}
	
}
?>