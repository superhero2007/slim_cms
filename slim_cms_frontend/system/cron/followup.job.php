<?php

/*
This code is executed every 10 minutes of every day as a CRON job

There are 6 options for the cron jobs:

1) Email - This emails a teplated email to the client
2) Call - Emails a notice to the account owner (if there is no account owner it emails to info@greenbizcheck.com)
3) Head Office - Emails a notice to info@greenbizcheck.com 
4) Delete - Deletes any results from the crm followup table allowing a reschedule
5) Issue Assessment + email client - Automaticaly issues a new assessment to a client along with a notification email
6) Function - Takes the sql query result and the function arguments to start a process

*/

$followup = new followup($db);

class followup {
	private $db;
	private $clientEmail;
	private $clientChecklist;
	
	public function __construct($db) {
		$this->db = $db;
		$this->clientEmail = new clientEmail($this->db);
		$this->clientChecklist = new clientChecklist($this->db);
		$this->processFollowups();
	}
	
	private function processFollowups() {
		if($result = $this->db->query(sprintf('
			SELECT
				`followup_trigger_id`,
				`name`,
				`sql`,
				`action`,
				`email_stationary`,
				`email_subject`,
				`function_arguments`
			FROM `%1$s`.`followup_trigger`
			ORDER BY `followup_trigger_id` ASC;
		',
			DB_PREFIX.'crm'
		))) {
			while($row = $result->fetch_object()) {
				switch($row->action) {
					case 'email': {
						$this->emailFollowup($row->followup_trigger_id,$row->sql,$row->email_stationary,$row->email_subject);
						break;
					}
					case 'call': {
						$this->phoneFollowup($row->followup_trigger_id,$row->sql,$row->name);
						break;
					}
					case 'head office': {
						$this->headOfficeFollowup($row->followup_trigger_id,$row->sql,$row->name);
						break;
					}
					case 'head office + associate': {
						$this->associateAndHeadOfficeFollowup($row->followup_trigger_id,$row->sql,$row->name);
						break;
					}
					case 'delete': {
						//Deletes any results from the crm followup table allowing a reschedule
						break;
					}
					case 'issue assessment + email client': {
						$this->issueAssessmentAndSendEmail($row->followup_trigger_id,$row->sql,$row->email_stationary,$row->email_subject);
						break;
					}
					//Takes the results of the sql query along with the function arguments from the trigger and fires a function
					case 'function': {
						$this->processFunction($row->followup_trigger_id, $row->sql, $row);
						break;
					}
				}
			}
			$result->close();
		}
		return;
	}
	
	//Processes the arguments passed in the trigger
	public function processFunction($followup_trigger_id, $sql, $data) {
		if($result = $this->db->query($sql)) {
			while($row = $result->fetch_object()) {
				if(isset($row->client_id) && !$this->hasBeenTriggered($followup_trigger_id, $row->client_id, $row->identifier)) {		
					//Takes the argument and attempts to run it
					eval($data->function_arguments);
					//set the admin-crm to mark the job as complete
					$this->reportFollowup($row->client_id,$followup_trigger_id, $row->identifier);
				}
			}
		}
		return;		
	}
	
	//Auto issues a new assessment
	public function issueAssessmentAndSendEmail($followup_trigger_id,$sql,$email_stationary,$email_subject) {
		if($result = $this->db->query($sql)) {
			while($row = $result->fetch_object()) {
				if(isset($row->client_id) && !$this->hasBeenTriggered($followup_trigger_id, $row->client_id, $row->client_checklist_id)) {
				 
				 //Issue the new assessment
				 $row->issued_client_checklist_id = $this->clientChecklist->autoIssueChecklist($row->checklist_id, $row->client_id);
				 
				 //Send the email to the client
					$this->clientEmail->send(
						$row->client_id,
						$email_subject,
						$email_stationary,
						$row,
						null,
						null,
						true
					);
					
					//set the admin-crm to mark the job as complete
					$this->reportFollowup($row->client_id,$followup_trigger_id, $row->client_checklist_id);
				}
			}
			$result->close();
		}
		return;
	}
	
	//Finds all of the email jobs that are to be completed, processes them and then adds them to the ADMIN-CRM to mark as completed.
	private function emailFollowup($followup_trigger_id,$sql,$email_stationary,$email_subject) {
		$processed_followups = $this->getProcessedFollowups($followup_trigger_id);
		if($result = $this->db->query($sql)) {
			while($row = $result->fetch_object()) {
				if(isset($row->client_id) && !in_array($row->client_id,$processed_followups)) {
				
					//Check to see if auto emails are checked for the client
					if($this->clientEmail->allowAutoEmail($row->client_id) == true) {
						$this->clientEmail->send(
							$row->client_id,
							$email_subject,
							$email_stationary,
							$row,
							null,
							null,
							true
						);
					}
					//Report the triggered email to the database so that it is only sent once even if auto emails are disabled
					$this->reportFollowup($row->client_id,$followup_trigger_id);
					
				}
			}
			$result->close();
		}
		return;
	}
	
	//This function will send a notice email to the associate assigned to the client, and if not associate exists an email is sent to info@greenbizcheck.com
	private function phoneFollowup($followup_trigger_id,$sql,$name) {
		$processed_followups = $this->getProcessedFollowups($followup_trigger_id);
		
		$from 			= 'GreenBizCheck <webmaster@greenbizcheck.com>';
		$returnPath		= '-fwebmaster@greenbizcheck.com';
		$company		= 'GreenBizCheck';
			
		$emailHeaders =
			"From: $from\r\n".
			"Reply-To: $from\r\n".
			"Return-Path: $from\r\n".
			"Organization: $company\r\n".
			"X-Priority: 3\r\n".
			"X-Mailer: PHP". phpversion() ."\r\n".
			"MIME-Version: 1.0\r\n".
			"Content-type: text/html; charset=UTF-8\r\n";
			
		if($result = $this->db->query($sql)) {
			while($row = $result->fetch_object()) {
				if(isset($row->client_id) && !in_array($row->client_id,$processed_followups)) {		
				 
				//Checks to see if the associate_email value is set (it is an email address) and if so BCC's the associate
				if(isset($row->associate_email)) {
					$recipientEmail = $row->associate_email;
				}
				else
					{
						$recipientEmail = "info@greenbizcheck.com";
					}
				 
					$emailBody = 
						'<html>'.
						'<body>'.
						'<h1>Automatic Followup Notification</h1>'.
						'<h2>'.$name.'</h2>'.
						'<p><a href="http://www.greenbizcheck.com/admin2010/index.php?page=clients&mode=client_edit&client_id='.$row->client_id.'">Click here to access the user/client details</a>.</p>'.
						'<p>The following details have been provided:</p>'.
						'<dl>';
					foreach($row as $key => $val) {
						$emailBody .=
							'<dt><strong>'.$key.'</strong></dt>'.
							'<dd>'.$val.'</dd>';
					}
					$emailBody .=
						'</dl>'.
						'</body>'.
						'</html>';
					mail($recipientEmail,'Automatic Followup Notification',$emailBody,$emailHeaders,'-fwebmaster@greenbizcheck.com');
					$this->reportFollowup($row->client_id,$followup_trigger_id);
				}
			}
			$result->close();
		}
		return;
	}
	
	//Function sends email to Head Office and CC's Associate
		private function associateAndHeadOfficeFollowup($followup_trigger_id,$sql,$name) {
		$processed_followups = $this->getProcessedFollowups($followup_trigger_id);

		$from 			= 'GreenBizCheck <webmaster@greenbizcheck.com>';
		$returnPath		= '-fwebmaster@greenbizcheck.com';
		$company		= 'GreenBizCheck';
			
		$emailHeaders =
			"From: $from\r\n".
			"Reply-To: $from\r\n".
			"Return-Path: $from\r\n".
			"Organization: $company\r\n".
			"X-Priority: 3\r\n".
			"X-Mailer: PHP". phpversion() ."\r\n".
			"MIME-Version: 1.0\r\n".
			"Content-type: text/html; charset=UTF-8\r\n";

		if($result = $this->db->query($sql)) {
			while($row = $result->fetch_object()) {
				if(isset($row->client_id) && !in_array($row->client_id,$processed_followups)) {		
				 
				//Checks to see if the associate_email value is set (it is an email address) and if so CC's the associate
				if(isset($row->associate_email)) {
					$emailHeaders .= "CC:" . $row->associate_email . "\r\n";
				}

				 
					$emailBody = 
						'<html>'.
						'<body>'.
						'<h1>Automatic Followup Notification</h1>'.
						'<h2>'.$name.'</h2>'.
						'<p><a href="http://www.greenbizcheck.com/admin2010/index.php?page=clients&mode=client_edit&client_id='.$row->client_id.'">Click here to access the user/client details</a>.</p>'.
						'<p>The following details have been provided:</p>'.
						'<dl>';
					foreach($row as $key => $val) {
						$emailBody .=
							'<dt><strong>'.$key.'</strong></dt>'.
							'<dd>'.$val.'</dd>';
					}
					$emailBody .=
						'</dl>'.
						'</body>'.
						'</html>';
					mail('info@greenbizcheck.com','Automatic Followup Notification',$emailBody,$emailHeaders,'-fwebmaster@greenbizcheck.com');
					$this->reportFollowup($row->client_id,$followup_trigger_id);
				}
			}
			$result->close();
		}
		return;
	}
	
	
	//Function to send notice email to info@grenbizcheck.com (Head Office) and not to the associate
		private function headOfficeFollowup($followup_trigger_id,$sql,$name) {
		$processed_followups = $this->getProcessedFollowups($followup_trigger_id);

		$from 			= 'GreenBizCheck <webmaster@greenbizcheck.com>';
		$returnPath		= '-fwebmaster@greenbizcheck.com';
		$company		= 'GreenBizCheck';
			
		$emailHeaders =
			"From: $from\r\n".
			"Reply-To: $from\r\n".
			"Return-Path: $from\r\n".
			"Organization: $company\r\n".
			"X-Priority: 3\r\n".
			"X-Mailer: PHP". phpversion() ."\r\n".
			"MIME-Version: 1.0\r\n".
			"Content-type: text/html; charset=UTF-8\r\n";

		if($result = $this->db->query($sql)) {
			while($row = $result->fetch_object()) {
				if(isset($row->client_id) && !in_array($row->client_id,$processed_followups)) {		
				 
					$emailBody = 
						'<html>'.
						'<body>'.
						'<h1>Automatic Followup Notification</h1>'.
						'<h2>'.$name.'</h2>'.
						'<p><a href="http://www.greenbizcheck.com/admin2010/index.php?page=clients&mode=client_edit&client_id='.$row->client_id.'">Click here to access the user/client details</a>.</p>'.
						'<p>The following details have been provided:</p>'.
						'<dl>';
					foreach($row as $key => $val) {
						$emailBody .=
							'<dt><strong>'.$key.'</strong></dt>'.
							'<dd>'.$val.'</dd>';
					}
					$emailBody .=
						'</dl>'.
						'</body>'.
						'</html>';
					mail('info@greenbizcheck.com','Automatic Followup Notification',$emailBody,$emailHeaders,'-fwebmaster@greenbizcheck.com');
					$this->reportFollowup($row->client_id,$followup_trigger_id);
				}
			}
			$result->close();
		}
		return;
	}
	
	private function reportFollowup($client_id,$followup_trigger_id, $identifier=null) {
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`followup` SET
				`client_id` = %2$d,
				`followup_trigger_id` = %3$d,
				`identifier` = %4$d
		',
			DB_PREFIX.'crm',
			$client_id,
			$followup_trigger_id,
			$identifier
		));
		return;
	}
	
	//Gets the processed followups
	private function getProcessedFollowups($followup_trigger_id) {
		$processed_followups = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`client_id`
			FROM `%1$s`.`followup`
			WHERE `followup_trigger_id` = %2$d;
		',
			DB_PREFIX.'crm',
			$followup_trigger_id
		))) {
			while($row = $result->fetch_object()) {
				$processed_followups[] = $row->client_id;
			}
			$result->close();
		}
		return($processed_followups);
	}
	
	//returns a bool (true or false) if the client has already had this trigger for the identifier
	//Basically a trigger can only run once on the given identifier - that could be a checklistId, invoiceId etc.
	private function hasBeenTriggered($followup_trigger_id, $client_id, $identifier) {
	 	$isSent = false;
		if($result = $this->db->query(sprintf('
			SELECT
				`client_id`
			FROM `%1$s`.`followup`
			WHERE `followup_trigger_id` = %2$d
			AND `client_id` = %3$d
			AND `identifier` = %4$d;
		',
			DB_PREFIX.'crm',
			$followup_trigger_id,
			$client_id,
			$identifier
		))) {
			while($row = $result->fetch_object()) {
				$isSent = true;
			}
			
			$result->close();
		}
		
		return($isSent);
	}
}
?>