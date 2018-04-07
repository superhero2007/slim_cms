<?php

class debug {
	private $doc;
	
	public function __construct($doc) {
		$this->doc = $doc;
	}

	//Pass the data, render the output to screen
	public function debugOutput($data) {
		
		echo "<pre>";
		var_dump($data);
		echo "</pre>";

		die();
	}

	public function renderXML() {
		if(($_REQUEST['debug'] == 'now') && ($_REQUEST['pass'] == 'gr33n')) {
			$this->doc->formatOutput = true;
			header("Content-type: text/xml");
			print $this->doc->saveXML();
		} else {	
			return;
		}

	}
}

?>