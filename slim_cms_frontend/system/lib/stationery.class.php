<?php
//Functions to use and implement email stationary templates that are stored in the SYSTEM/Email Stationary/ directory
//Edited: 20120108
//Editor: Tim Dorey

class stationery {
	
	//Private array of words that stay in lower case
	private static $words_stay_lowercase = array('on', 'the', 'a', 'in', 'to');
	
	// Retreive a list of the templates by iterating over the PATH_STATIONERY directory.
	public static function getTemplates() {
		$stationery_templates = array();
		$dp = opendir(PATH_STATIONERY);
		while ($filename = readdir($dp)) {
			if (preg_match("/^(.+)\.xsl$/", $filename, $matches)) {
				$stationery_templates[] = array(
					'filename' => $filename,
					'name' => self::filenameToHumanName($matches[1]),
					'subject' => self::getSubject($filename)
				);
			}
		}
		return $stationery_templates;
	}
	
	// Convert a name from something like here_is_a_path_to_a_file to
	// Here is a Path to a File.
	private static function filenameToHumanName($filename) {
		$words = preg_split("/_/", strtolower($filename));
		$human = "";
		foreach ($words as $i => $word) {
			// Words that should not be capitalised.
			if (in_array($word, self::$words_stay_lowercase)) {
				$words[$i] = $word;
			}
			
			// Convert words like 15pc to 15%.
			elseif (preg_match("/^(\d+)pc$/", $word, $matches)) {
				$words[$i] = $matches[1]."%";
			}
			
			// All other words should be capitalised.
			else {
				$words[$i] = strtoupper(substr($word, 0, 1)).substr($word, 1);
			}
		}
		return implode(' ', $words);
	}
	
	//Get the subject of the stationery if it is set
	private static function getSubject($filename) {
		$subject = "";
		
		$subjectDoc = new DOMDocument('1.0','UTF-8');
		$subjectDoc->appendChild($subjectDoc->createElement('subject'));
		
		$xslt = new XSLTProcessor();
		$xslt->registerPHPFunctions();
		$xsl = new DOMDocument('1.0','UTF-8');
		$xsl->load(PATH_SYSTEM.'/emailStationary/'.$filename);
		$xslt->importStyleSheet($xsl);
		
		$subjectContent = $xslt->transformToXML($subjectDoc);
		
		if(!is_null($subjectContent)) {
			$subject = $subjectContent;
		}
		
		return $subject;
	}
	
}

?>