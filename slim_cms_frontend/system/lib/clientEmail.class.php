<?php
class clientEmail extends dbModel {

	private function convertHTML2InlineCSS($html) {
		$pre = Premailer::html($html);
		$html = $pre['html'];

		return $html;
	}
	
	public function render($client_id, $client_contact_id, $stationeryFile) {
		$objects = new StdClass;
		$objects->clientUtils		= new clientUtils($this->db);
		$objects->clientChecklist	= new clientChecklist($this->db);
		
		$clientDetail	= $objects->clientUtils->getClientByClientId($client_id);
		$checklists		= $objects->clientChecklist->getChecklists($client_id);
			
		$doc = new DOMDocument('1.0','UTF-8');
		$doc->appendChild($doc->createElement('config'));
		
		$clientNode = $doc->lastChild->appendChild($doc->createElement('client'));
		foreach($clientDetail as $key => $val) {
			if($key == 'contact') { continue; }
			$clientNode->setAttribute($key,$val);
		}
		for($i=0;$i<count($clientDetail->contact);$i++) {
			// Render email for all contacts if no $client_contact_id is passed or just for specified $client_contact_id.
			if (($client_contact_id && $clientDetail->contact[$i]->client_contact_id == $client_contact_id) || $client_contact_id == NULL) {
				$contactNode = $clientNode->appendChild($doc->createElement('contact'));
				foreach($clientDetail->contact[$i] as $key => $val) {
					$contactNode->setAttribute($key,$val);
				}
			}
		}
		foreach($checklists as $checklist) {
			$checklistNode = $doc->lastChild->appendChild($doc->createElement('checklist'));
			foreach($checklist as $key => $val) {
				$checklistNode->setAttribute($key,$val);
			}
		}
		
		$xslt = new XSLTProcessor();
		$xslt->registerPHPFunctions();
		$xsl = new DOMDocument('1.0','UTF-8');
		$xsl->load(PATH_SYSTEM.'/emailStationary/'.$stationeryFile);
		$xslt->importStyleSheet($xsl);

		return $this->convertHTML2InlineCSS($xslt->transformToXML($doc));
	}
	
	//Updated 20130318 to include all headers for spam minimisation
	public function sendHTMLToClient($client_id, $client_contact_id, $stationery_template, $subject, $body, $cc = NULL) {
		$clientUtils = new clientUtils($this->db);
		$clientDetail = $clientUtils->getClientByClientId($client_id);

		$bodyDoc = DOMDocument::loadHTML($body);
		$emailBody = $bodyDoc->saveXML($bodyDoc->getElementsByTagName("html")->item(0));
		
		if($clientDetail->client_type_id == 6) {
			$from 			= 'EcoSmash <ecosmash@iag.com.au>';
			$returnPath		= '-fecosmash@iag.com.au';
			$company		= 'EcoSmash';
		}
		else {
			$from 			= 'GreenBizCheck <info@greenbizcheck.com>';
			$returnPath		= '-finfo@greenbizcheck.com';
			$company		= 'GreenBizCheck';
		}
		
		$emailHeaders =
			"From: $from\r\n".
			"Reply-To: $from\r\n".
			"Return-Path: $from\r\n".
			"Organization: $company\r\n".
			"X-Priority: 3\r\n".
			"X-Mailer: PHP". phpversion() ."\r\n".
			"MIME-Version: 1.0\r\n".
			"Content-type: text/html; charset=UTF-8\r\n";
			
		if ($cc != NULL) {
			$addressString = $this->santizeEmailAddresses($cc);			
			$emailHeaders .= "Cc: $addressString\r\n";
		}

		// Get all contact email addresses and send mail to each.
		foreach ($clientDetail->contact as $contact) {
			// Send email to all contacts if no $client_contact_id passed or just to specified $client_contact_id.
			if (($client_contact_id && $contact->client_contact_id == $client_contact_id) || $client_contact_id == NULL) {
				// Construct email address from contact.
				$emailTo = sprintf(
					'"%1$s %2$s" <%3$s>',
					$contact->firstname,
					$contact->lastname,
					$contact->email
				);
			
				$this->db->query(sprintf('
					INSERT INTO `%1$s`.`client_email` (client_contact_id, sent_date, email_to, email_stationery, email_subject, email_body)
					VALUES ("%2$d", "%3$s", "%4$s", "%5$s", "%6$s", "%7$s")
				',
					DB_PREFIX.'crm',
					$this->db->escape_string($contact->client_contact_id),
					$this->db->escape_string(date('Y-m-d H:i:s', time())),
					$this->db->escape_string($contact->email),
					$this->db->escape_string($stationery_template),
					$this->db->escape_string($subject),
					$this->db->escape_string($emailBody)
				));
			
				// Send email.
				mail($emailTo, $subject, $emailBody, $emailHeaders,$returnPath);
			}
		}			
	}
	
	//Gets the clients email address and send an email to the client based on the information provided eg; clientId, stationary etc
	public function send($client_id,$subject,$stationary,$params=array(),$add_to_crm=false, $bcc=null, $automated=false) {

		$objects->clientUtils		= new clientUtils($this->db);
		$objects->clientChecklist	= new clientChecklist($this->db);
		
		$clientDetail	= $objects->clientUtils->getClientByClientId($client_id);
		$checklists		= $objects->clientChecklist->getChecklists($client_id);
		$emailTo = array();
		
		//Get the domain email details and construc for mailing
		$domain = $this->getSenderDetails($GLOBALS['core']->domain->domain_id);
		$from 			= $domain->email_address_label . '<' . $domain->email_address . '>';
		$returnPath		= '-f' . $domain->email_address;
		$company		= $domain->site_name;
		
		$emailHeaders =
			"From: $from\r\n".
			"Reply-To: $from\r\n".
			"Return-Path: $from\r\n".
			"Organization: $company\r\n".
			"X-Priority: 3\r\n".
			"X-Mailer: PHP". phpversion() ."\r\n".
			"MIME-Version: 1.0\r\n".
			"Content-type: text/html; charset=UTF-8\r\n";
			
		$doc = new DOMDocument('1.0','UTF-8');
		$doc->appendChild($doc->createElement('config'));
		
		$clientNode = $doc->lastChild->appendChild($doc->createElement('client'));
		foreach($clientDetail as $key => $val) {
			if($key == 'contact') { continue; }
			$clientNode->setAttribute($key,$val);
		}
		
		for($i=0;$i<count($clientDetail->contact);$i++) {
			$contactNode = $clientNode->appendChild($doc->createElement('contact'));
			foreach($clientDetail->contact[$i] as $key => $val) {
				$contactNode->setAttribute($key,$val);
			}
			
			//Check to see if this is an auto email - Some people don't receive auto emails
			if($automated) {
			 	if($clientDetail->contact[$i]->send_auto_emails == 1){
					$emailTo[] = $clientDetail->contact[$i]->email;
				}
			}
			else {
				$emailTo[] = $clientDetail->contact[$i]->email;
			}
		}
		
		foreach($checklists as $checklist) {
			$checklistNode = $doc->lastChild->appendChild($doc->createElement('checklist'));
			foreach($checklist as $key => $val) {
				$checklistNode->setAttribute($key,$val);
			}
		}
		
		$xsl = new XSLTProcessor();
		$xsl->registerPHPFunctions();
		$xsl->importStyleSheet(DOMDocument::load(PATH_SYSTEM.'/emailStationary/'.$stationary.'.xsl'));
		foreach($params as $key => $val) {
			$xsl->setParameter('',$key,$val);
		}
		$emailTo		= implode(', ',$emailTo);
		$mailSubject	= $subject;
		$emailBody		= $this->convertHTML2InlineCSS($xsl->transformToXML($doc));
			
		//Checks to see if the head_office_email has been selected in the SQL query....if so CC info@greenbizcheck.com
		if(isset($params->head_offce_email)) {
		 		$emailHeaders .= "Cc: " . $params->head_office_email . "\r\n";
		}	
			
		//Checks to see if the associate_email value is set (it is an email address) and if so BCC's the associate
		if(isset($params->associate_email)) {
			$emailHeaders .= "Bcc: " . $params->associate_email . "\r\n";
		}
		
		//Checks to see if a BCC variable has been passed
		if(!is_null($bcc)) {
			$emailHeaders .= "Bcc: " . $bcc . "\r\n";
		}
		
		//If the option to add the outbound email to the admin-crm is set
		if($add_to_crm == true) {
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`client_email` (client_contact_id, sent_date, email_to, email_stationery, email_subject, email_body)
				VALUES ("%2$d", "%3$s", "%4$s", "%5$s", "%6$s", "%7$s")
			',
			DB_PREFIX.'crm',
			$this->db->escape_string($clientDetail->contact[0]->client_contact_id),
			$this->db->escape_string(date('Y-m-d H:i:s', time())),
			$this->db->escape_string($clientDetail->contact[0]->email),
			$this->db->escape_string($stationary),
			$this->db->escape_string($mailSubject),
			$this->db->escape_string($emailBody)
			));
		}
		
		//If there are no people to email this email to....end the email process here
		if(count($emailTo) > 0) {
			mail($emailTo,$mailSubject,$emailBody,$emailHeaders,$returnPath);
		}
		
		return;
	}
	
	//New function to send an email to an individual client_contact
	//Added a sender variable
	public function sendClientContact($client_id,$client_contact_id,$subject,$stationary,$params=array()) {
		$objects = new StdClass();
		$objects->clientUtils		= new clientUtils($this->db);
		$objects->clientChecklist	= new clientChecklist($this->db);
		
		$clientDetail	= $objects->clientUtils->getClientByClientId($client_id);
		$checklists		= $objects->clientChecklist->getChecklists($client_id);

		//Get the domain email details and construc for mailing
		$domain = $this->getSenderDetails($GLOBALS['core']->domain->domain_id);
		$from 			= $domain->email_address_label . '<' . $domain->email_address . '>';
		$returnPath		= '-f' . $domain->email_address;
		$company		= $domain->site_name;
		
		$emailHeaders =
			"From: $from\r\n".
			"Reply-To: $from\r\n".
			"Return-Path: $from\r\n".
			"Organization: $company\r\n".
			"X-Priority: 3\r\n".
			"X-Mailer: PHP". phpversion() ."\r\n".
			"MIME-Version: 1.0\r\n".
			"Content-type: text/html; charset=UTF-8\r\n";
			
		$doc = new DOMDocument('1.0','UTF-8');
		$doc->appendChild($doc->createElement('config'));
		
		$clientNode = $doc->lastChild->appendChild($doc->createElement('client'));
		foreach($clientDetail as $key => $val) {
			if($key == 'contact') { continue; }
			$clientNode->setAttribute($key,$val);
		}
		for($i=0;$i<count($clientDetail->contact);$i++) {
			//Pick out the one client_contact that you want to email
			if($clientDetail->contact[$i]->client_contact_id == $client_contact_id){
			
				$contactNode = $clientNode->appendChild($doc->createElement('contact'));
				foreach($clientDetail->contact[$i] as $key => $val) {
					$contactNode->setAttribute($key,$val);
				}			

				$emailTo[] = sprintf(
					'%1$s %2$s <%3$s>',
					$clientDetail->contact[$i]->firstname,
					$clientDetail->contact[$i]->lastname,
					$clientDetail->contact[$i]->email
				);
			}
		}
		foreach($checklists as $checklist) {
			$checklistNode = $doc->lastChild->appendChild($doc->createElement('checklist'));
			foreach($checklist as $key => $val) {
				$checklistNode->setAttribute($key,$val);
			}
		}

		$xslt = new XSLTProcessor();
		$xslt->registerPHPFunctions();
		$xsl = new DOMDocument('1.0','UTF-8');
		$xsl->load(PATH_SYSTEM.'/emailStationary/'.$stationary.'.xsl');
		$xslt->importStyleSheet($xsl);


		foreach($params as $key => $val) {
			$xslt->setParameter('',$key,$val);
		}

		$emailTo		= implode(', ',$emailTo);
		$mailSubject	= $subject;
		$emailBody		= $this->convertHTML2InlineCSS($xslt->transformToXML($doc));
		
		mail($emailTo,$mailSubject,$emailBody,$emailHeaders,$returnPath);
		return;
	}
	
	public function santizeEmailAddresses($addresses) {
		$str = '';
		foreach (preg_split('/[\s,]/', $addresses) as $email) {
			$email = trim($email);
			if ($email != '') {
				if ($str != '') { $str .= ', '; }
				$str .= '<'.$email.'>';
			}
		}
		return $str;
	}
	
	//Checks to see if the client has auto_emails enabled
	public function allowAutoEmail($client_id) {
		
		$send = false;
		
		//Query the database, if num_rows greater than zero there is atleast one client_contact recieving emails
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_contact`
			WHERE `client_contact`.`client_id` = %2$d
			AND `client_contact`.`send_auto_emails;
		',
			DB_PREFIX.'core',
			$client_id
		))) {
			while($row = $result->fetch_object()) {
				$send = true;
			}
		}
			
		$result->close();
		
		return $send;
	}
	
	public function getSenderDetails($domain_id) {
		$domain = array();
	
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`domain`
			WHERE `domain`.`domain_id` = %2$d
			AND `domain`.`email_address` IS NOT NULL;
		',
			DB_PREFIX.'core',
			$domain_id
		))) {
				while($row = $result->fetch_object()) {
					$domain = $row;
			}
		}
		
		if(empty($domain)) {
			if($result = $this->db->query(sprintf('
				SELECT *
				FROM `%1$s`.`domain`
				WHERE `domain`.`domain_id` = %2$d
				AND `domain`.`email_address` IS NOT NULL;
			',
				DB_PREFIX.'core',
				1
			))) {
					while($row = $result->fetch_object()) {
						$domain = $row;
				}
			}
		}
			
		$result->close();
		
		return($domain);
	}
}
?>