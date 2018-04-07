<?php
class content extends plugin {
	public function getContent() {
	 
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT
				`content`.`content_id`,
				`content`.`navigation_id`,
				`content`.`sequence`,
				`content`.`content`
			FROM `%1$s`.`content`
			WHERE `content`.`navigation_id` = %2$d
			ORDER BY `content`.`sequence` ASC;
		',
			DB_PREFIX.'core',
			end($GLOBALS['core']->navigationSet)
		))) {
			while($row = $result->fetch_object()) {
			 
				foreach($GLOBALS['core']->nav as $navCheck) {
					if(isset($navCheck->navigation_id) && ($navCheck->navigation_id == $row->navigation_id)) {
			 		if(isset($navCheck->duplicate_navigation_id)) {
			  
			 		//Check to see if there is a duplicate domain match to get the content from that item instead
			 		if($content_result = $GLOBALS['core']->db->query(sprintf('
						SELECT
							`content`.`content`
						FROM `%1$s`.`content`
						WHERE `content`.`navigation_id` = %2$d
						LIMIT 1;
					',
						DB_PREFIX.'core',
						$navCheck->duplicate_navigation_id	
					))) {
				
						while($content_row = $content_result->fetch_object()) {
							if(!is_null($content_row->content)) {
				 				$row->content = $content_row->content;
				 			}
			 			}
					}
				}
				}
			}
			 
				$contentNode = $this->node->appendChild($this->createHTMLNode($row->content,'content'));
				foreach($row as $key => $val) {
					if($key != 'content') {
						$contentNode->setAttribute($key,$val);
					}
				}
			}
			$result->close();
		}
		
		return;
	}
}
?>