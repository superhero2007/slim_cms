<?php

//A class to verify the captcha details
//Edited: 20130815
//Editor: Tim Dorey

class captcha {

	//Checks the verification image for
	public function validateVerificationImage($input) {
	 	$validated = false;
		
		if(!is_null($input)) {
			// Check challenge string
			if($this->isChallengeAccepted($input)) {
				$validated = true;
			}		
		}
		return $validated; 
	}
	
	// Check if a valid challenge string does not exist
	private function getChallengeString() {
  		
 		@session_start();
		if(!isset($_SESSION['challenge_string'])) {
 			return FALSE;
 		}
		return $_SESSION['challenge_string'];
 	}
 
 	private function isChallengeAccepted($entered_value) {
 	
 		// Get challenge string
 		$challenge_string = $this->getChallengeString();
 		if($challenge_string === FALSE) { return FALSE; }
 
 		$entered_value = strtoupper($entered_value);
 	
 		// Remove from session, so that it cannot be reused
 		unset($_SESSION['challenge_string']);
 	
 		// Compare entered value to challenge string in session
    	return ($challenge_string === $entered_value);
	}
}
?>