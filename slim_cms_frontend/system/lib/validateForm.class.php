<?php
//Takes parameters and checks to see if they are valid for a form input eg; Client registration form, password, email etc.
//Edited: 20120108
//Editor: Tim Dorey

class validateForm {
 
	//Takes an array of form fields and checks them against certain criterea eg, null values or Not A Number
	//Returns the errors to be displayed on the client side if there are any to be found 
	static function validateDetails($fields,&$error=array()) {
		$data = array();
		for($i=0;$i<count($fields);$i++) {
			$data[$fields[$i][1]] = (isset($_REQUEST[$fields[$i][1]]) ? trim($_REQUEST[$fields[$i][1]]) : null);
			if($fields[$i][2] == 0) { continue; }
			if($data[$fields[$i][1]] == '') {
				$error[$fields[$i][1]] = $fields[$i][0].' can not be left empty';
			} elseif(isset($fields[$i][3])) {
				switch($fields[$i][3]) {
					case 'int': {
						if(!is_numeric($data[$fields[$i][1]])) {
							$error[$fields[$i][1]] = $fields[$i][0].' must be a number';
						}
						break;
					}
					case 'email': {
						 if(!preg_match("/^[_\.0-9a-zA-Z-]+@([0-9a-zA-Z][0-9a-zA-Z-]+\.)+[a-zA-Z]{2,6}$/i", $_REQUEST[$fields[$i][1]])) {
							$error[$fields[$i][1]] = $fields[$i][0].' must be a valid email address';
						}
						break;
					}
				}
			}
			
			//Strip output chars
			//$data[$fields[$i][1]] = $GLOBALS['core']->xssafe($data[$fields[$i][1]]);
		}
		return($data);
	}
	
	//Validates and email address using Regex
	//Takes the email address and either returns true or false with an error message
	static function validateEmail($email,&$error=array(),$key='email') {
		if(eregi("^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,3})$", $email)) {
			return(true);
		} else {
			$error[$key] = 'Your email address is invalid';
			return(false);
		}
	}
	
	//Takes the error node parameter and chacks to see if we need to write any errors back to the client side
	//If there are errors return them to the end user display otherwise continue with the process
	static function writeErrors($doc,$node,$error=array()) {
		if(count($error) > 0) {
			foreach($error as $field => $msg) {
				//$errorNode = $node->appendChild($doc->createElement('error',$GLOBALS['core']->xssafe($msg)));
				$errorNode = $node->appendChild($doc->createElement('error',$msg));
				$errorNode->setAttribute('field',$field);
			}
			return(true);
		}
		return(false);
	}
}
?>