<?php
//Contains all Cookie and Session related functions eg, Cookie Setting, Session Setting, Remembering clients etc
//Edited: 20120108
//Editor: Tim Dorey


class sessionCookie {
	
	private $data;
	private $expiry;
	private $cookieName;
	private $cookieNameHash;
	
	// CONSTRUCTOR
	
	public function __construct($cookieName) {
		$this->expiry = null;

		if (session_status() == PHP_SESSION_NONE) {
    		session_start();
		}
		
		$this->cookieName = $cookieName;
		$this->cookieNameHash = $cookieName.'_hash';
		
		if (isset($_COOKIE[$this->cookieName]) && isset($_COOKIE[$this->cookieNameHash])) {
			$this->load($_COOKIE[$this->cookieName], $_COOKIE[$this->cookieNameHash]);
		}
		else {
			$this->reset();
		}
	}
	
	// STATIC METHODS	
	
	// PUBLIC METHODS
	
	public function __get($key) {
		return $this->get($key);
	}
	
	public function __set($key, $value) {
		return $this->set($key, $value);
	}
	
	public function get($key) {
		if (isset($this->data[$key])) {
			return $this->data[$key];
		}
		else {
			return NULL;
		}
	}
	
	public function set($key, $value) {
		if ($key != 'ts') {
			$this->data[$key] = $value;
		}
	}
	
	public function setExpiry($expiry) {
		$this->expiry = $expiry;
	}

	public function getExpiry() {
		return $this->expiry;
	}
	
	//Return the session hash
	public function getHash() {
		return $this->calculateHash($_COOKIE[$this->cookieName]);
	}
		
	public function load($serializedCookie, $cookieHash) {
		if ($this->calculateHash($serializedCookie) == $cookieHash) {
			$this->data = (array)json_decode($serializedCookie);
		}
		else {
			$this->reset();
		}
	}

	
	public function save($path = '/') {
		$this->updateTimestamp();
		$expiry = $this->calculateExpiry();		
		$serializedCookie = json_encode($this->data);
		setcookie($this->cookieName, $serializedCookie, $expiry, $path, null , (isset($GLOBALS['core']->domain->ssl) && $GLOBALS['core']->domain->ssl == '1' && SERVER_ENV == 'remote') ? true : false, true);
		setcookie($this->cookieNameHash, $this->calculateHash($serializedCookie), $expiry, $path, null, (isset($GLOBALS['core']->domain->ssl) && $GLOBALS['core']->domain->ssl == '1' && SERVER_ENV == 'remote') ? true : false, true);
	}
	
	//Reset the client session
	public function reset() {
		$this->data = array();
		session_destroy();
	}
			
	// PRIVATE METHODS
	
	//Uses the SESSION_SALT in the site config to calculate a hashing code
	private function calculateHash($value) {
		return md5('--'.$value.'--'.SESSION_SALT);
	}
	
	//Updates the timestamp to the current time
	private function updateTimestamp() {
		$this->data['ts'] = time();
		return $this->data['ts'];
	}
	
	//Takes the current session exipry and finds when the expiry date/time is
	private function calculateExpiry() {
		if ($this->expiry) {
			return time() + $this->expiry;
		}
		return NULL;
	}


	/*
	*	PHP Session
	*/

	//Set session variables
	public function setSessionVar($key, $var) {
		$_SESSION[$key] = $var;
		return;
	}

	public function getSessionVar($key) {
		return isset($_SESSION[$key]) ? $_SESSION[$key] : null;
	}

	public function deleteSessionVar($key) {
		unset($_SESSION[$key]);
		return;
	}
	
}

?>