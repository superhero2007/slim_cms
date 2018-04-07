<?php

class client_email_template extends plugin {

	public function renderClientTemplates() {
	
		$template = $this->extractTemplateFromUrl();
		if(isset($_REQUEST['template'])) {
			$template = $_REQUEST['template'];
		}
		
		//Set the template to the XML output
		$this->node->setAttribute('template',$template);
		
		//Get the highest score in an office assessment - we want to know if they have scored Gold, Silver or Bronze
		$this->node->setAttribute('highest_score',$this->getHighestClientScore());
		
	//	die();
		return $template;
	}

	// Last URL-part should be the template name
	private function extractTemplateFromUrl() {
		return @$GLOBALS['core']->pathSet[count($GLOBALS['core']->pathSet) - 1];
	}
	
	//Get the highest score of the client and see if there is a matching stamp/score level for this assessment
	private function getHighestClientScore() {
	 	return "test";	
	}
}

?>