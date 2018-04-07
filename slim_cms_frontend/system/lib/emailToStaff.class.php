<?php

class emailToStaff {
	private $db;
	
	public function __construct($db) {
		$this->db = $db;
	}
	
	public function send($client_contact_id, $recipient, $question_id) {
		
		//Get the senders details
		$clientUtils = new clientUtils($this->db);
		$client_contact = $clientUtils->getClientByContactId($client_contact_id);
		
		//Get the question details
		$clientChecklist = new clientChecklist($this->db);
		$question = $clientChecklist->pubGetQuestion($question_id);

		//Get the answer details
		$page = $clientChecklist->getChecklistPageFromQuestionId($question_id);

		//Get the answer details
		$answers = $clientChecklist->pubGetAnswers($question_id);
		
		$sender = $client_contact->firstname . " " . $client_contact->lastname . " <" . $client_contact->email . ">";
		$subject = "GreenBizCheck Assessment Question Assistance Required";
		
		$message = "<p>Hi,</p>";
		$message .= "<p>" . $client_contact->company_name . " are undertaking GreenBizCheck certification. As part of this certification we require the answer to the question below. Please respond to the person below with the answer to the question.</p>";
		
		$message .= "<p><strong>Assessment: </strong>" . $page->name . "</p>";
		$message .= "<p><strong>Section: </strong>" . $page->title . "</p>";
		$message .= "<p><strong>Question: </strong>" . $question->question . "</p>";
		
		if(count($answers) > 1) {
			$message .= "<p>You can choose from the following answers:</p><p>";
			foreach($answers as $answer) {
				$message .= $answer->string . "<br />";
			}
			$message .= "</p>";
		}
		else {
			switch($answers[0]->answer_type) {
				
				case 'range':		$message .= "<p>Your answer should be between " . $answers[0]->range_min . " and " . $answers[0]->range_max . ".</p>";
									break;
				case 'percent':		$message .= "<p>Your answer should be between 0% and 100%.</p>";
									break;
				case 'int':			$message .= "<p>Your answer should be a whole number.</p>";
									break;
				case 'text':
				case 'text-area':	$message .= "<p>Your answer should be a text string.</p>";
									break;
				case 'date':		$message .= "<p>Your answer should be a date.</p>";
									break;
				case 'float':		$message .= "<p>Your answer should be a number.</p>";
									break;
				case 'url':			$message .= "<p>Your answer should be a url.</p>";
									break;
				case 'email':		$message .= "<p>Your answer should be an email address.</p>";
									break;
			}
		}
		
		$message .= "<p>This message was sent to you by " . $client_contact->firstname . " " . $client_contact->lastname . " from " . $client_contact->company_name . ".</p><p>Please respond to this person at <a href=\"" . $client_contact->email . "\">" . $client_contact->email . "</a></p>";
		
		
		$mailer = new mailer($this->db);
		$mailer->deliver($recipient, $sender, $subject, $message);
		
		return;
	}
	
}

?>
