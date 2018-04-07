<?php
class form extends plugin {
	public function contactForm() {
		if(!isset($_REQUEST['action']) || $_REQUEST['action'] != 'enquire') return;
		$error = array();
		$fields = array(
			array('Name','name',1),
			array('Email','email',1,'email'),
			array('Phone','phone',0),
			array('Location','location',1),
			array('Company','company',0),
			array('Message','message',1)
		);
		$data = validateForm::validateDetails($fields,$error);
		
		//Check the captcha image
		$captcha = new captcha($this->db);
		if(!$captcha->validateVerificationImage($_POST['verificationCode'])) {
			$error['verificationCode'] = 'Incorrect Verification Code';
		}
		
		if(count($error) > 0) {
			foreach($error as $field => $msg) {
				$errorNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('error',$msg));
				$errorNode->setAttribute('field',$field);
			}
			return;
		}
		$body 
			= '<p>Dear '.$data['name'].',</p>' 
			. '<p>Thank you for contacting GreenBizCheck. Your message has been received and we will respond to your enquiry as soon as possible.</p>'
			. '<p>Kind regards,</p>'
			. '<p>The GreenBizCheck Team<br />'
			. '<a href="http://www.greenbizcheck.com/">www.greenbizcheck.com</a><br />'
			. '<strong>e:</strong> <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a><br />'
			. '<strong>p:</strong> 1300 552 335</p>'
			. '<p><strong><em>Please consider the environment before printing this email. We are losing 40 million acres of oxygen producing forests through logging and land clearing every year.</em></strong></p>';
		$headers 
			= "MIME-Version: 1.0\r\n"
			. "Content-type: text/html; charset=UTF-8\r\n"
			. "From: GreenBizCheck <info@greenbizcheck.com>\r\n";
		mail($data['name'].' <'.$data['email'].'>','Thank you for contacting GreenBizCheck',$body,$headers,"-f info@greenbizcheck.com");
		$this->sendEmail($fields,$data, 'Contact Enquiry - (greenbizcheck.com)');
		header("Location: /contact/thankyou/");
		die();
	}
	
	public function nraContactForm() {
		if(!isset($_REQUEST['action']) || $_REQUEST['action'] != 'enquire') return;
		$error = array();
		$fields = array(
			array('Name','name',1),
			array('Email','email',1,'email'),
			array('Phone','phone',0),
			array('Location','location',1),
			array('Company','company',0),
			array('Message','message',1)
		);
		$data = validateForm::validateDetails($fields,$error);
		
		//Check the captcha image
		$captcha = new captcha($this->db);
		if(!$captcha->validateVerificationImage($_POST['verificationCode'])) {
			$error['verificationCode'] = 'Incorrect Verification Code';
		}
		
		if(count($error) > 0) {
			foreach($error as $field => $msg) {
				$errorNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('error',$msg));
				$errorNode->setAttribute('field',$field);
			}
			return;
		}

		$headers 
			= "MIME-Version: 1.0\r\n"
			. "Content-type: text/html; charset=UTF-8\r\n"
			. "From: Retail Buys the Future <no-reply@nra.retailbuysthefuture.com>\r\n";
		$body = '<table border="1">';
		for($i=0;$i<count($fields);$i++) {
			if(empty($data[$fields[$i][1]])) continue;
			$body 
				.= '<tr>'
				. '<th scope="row">'.$fields[$i][0].':</th>'
				. '<td>'.nl2br($data[$fields[$i][1]]).'</td>'
				. '</tr>';
		}
		$body
			.= '<tr>'
			. '<th scope="row">Timestamp:</th>'
			. '<td>'.date("c").'</td>'
			. '</tr>'
			. '<tr>'
			. '<th scope="row">IP Address:</th>'
			. '<td>'.$_SERVER['REMOTE_ADDR'].'</td>'
			. '</tr>'
			. '<tr>'
			. '<th scope="row">Host Address:</th>'
			. '<td>'.gethostbyaddr($_SERVER['REMOTE_ADDR']).'</td>'
			. '</tr>'
			. '<tr>'
			. '<th scope="row">User Agent:</th>'
			. '<td>'.$_SERVER['HTTP_USER_AGENT'].'</td>'
			. '</tr>'
			. '</table>';
			
		//Change to recipient address
		$subject = "Retail Buys the Future Website Enquiry";
		mail('info@timdorey.com',$subject,$body,$headers);
		
		header("Location: /contact/thankyou/");
		die();
	}
	
	private function sendEmail($fields,$data,$subject) {
		$headers 
			= "MIME-Version: 1.0\r\n"
			. "Content-type: text/html; charset=UTF-8\r\n"
			. "From: GreenBizCheck <info@greenbizcheck.com>\r\n";
		$body = '<table border="1">';
		for($i=0;$i<count($fields);$i++) {
			if(empty($data[$fields[$i][1]])) continue;
			$body 
				.= '<tr>'
				. '<th scope="row">'.$fields[$i][0].':</th>'
				. '<td>'.nl2br($data[$fields[$i][1]]).'</td>'
				. '</tr>';
		}
		$body
			.= '<tr>'
			. '<th scope="row">Timestamp:</th>'
			. '<td>'.date("c").'</td>'
			. '</tr>'
			. '<tr>'
			. '<th scope="row">IP Address:</th>'
			. '<td>'.$_SERVER['REMOTE_ADDR'].'</td>'
			. '</tr>'
			. '<tr>'
			. '<th scope="row">Host Address:</th>'
			. '<td>'.gethostbyaddr($_SERVER['REMOTE_ADDR']).'</td>'
			. '</tr>'
			. '<tr>'
			. '<th scope="row">User Agent:</th>'
			. '<td>'.$_SERVER['HTTP_USER_AGENT'].'</td>'
			. '</tr>'
			. '</table>';
		mail('info@greenbizcheck.com',$subject,$body,$headers);
		return;
	}
	
	//Franchise Info Web Form
	public function franchiseForm() {
		if(!isset($_REQUEST['action']) || $_REQUEST['action'] != 'franchiseInfo') return;
		$error = array();
		$fields = array(
			array('First Name','first-name',1),
			array('Last Name','last-name',1),						
			array('Email','email',1,'email'),
			array('Phone','phone',0),
			array('Location','location',1),
			array('Preferred Contact Option','preferred-contact',1),
			array('Preferred Time','preferred-time',1)
		);
		
		//Get all of the data and make sure that it is valid
		$data = validateForm::validateDetails($fields,$error);
		
		//Check the captcha image
		$captcha = new captcha($this->db);
		if(!$captcha->validateVerificationImage($_POST['verificationCode'])) {
			$error['verificationCode'] = 'Incorrect Verification Code';
		}
		
		if(count($error) > 0) {
			foreach($error as $field => $msg) {
				$errorNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('error',$msg));
				$errorNode->setAttribute('field',$field);
			}
			return;
		}
		
		//Construct the body of the email to the contact making the enquiry.
		$body 
			= '<p>Dear '.$data['name'].',</p>' 
			. '<p>Thank you for contacting GreenBizCheck. Your message has been received and we will respond to your enquiry as soon as possible.</p>'
			. '<p>Kind regards,</p>'
			. '<p>The GreenBizCheck Team<br />'
			. '<a href="http://www.greenbizcheck.com/">www.greenbizcheck.com</a><br />'
			. '<strong>e:</strong> <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a><br />'
			. '<strong>p:</strong> 1300 552 335</p>'
			. '<p><strong><em>Please consider the environment before printing this email. We are losing 40 million acres of oxygen producing forests through logging and land clearing every year.</em></strong></p>';
		$headers 
			= "MIME-Version: 1.0\r\n"
			. "Content-type: text/html; charset=UTF-8\r\n"
			. "From: GreenBizCheck <info@greenbizcheck.com>\r\n";
		mail($data['name'].' <'.$data['email'].'>','Thank you for contacting GreenBizCheck',$body,$headers,"-f info@greenbizcheck.com");
		
		//Now email the details to Head Office then redirect the contact to the thankyou page
		$this->sendEmail($fields,$data, 'Franchise Enquiry - (ecobizcheckfranchise.com)');
		header("Location: /more-information/thankyou/");
		die();
	}
}
?>