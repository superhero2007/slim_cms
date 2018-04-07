<?php
class assessmentTools {
	private $db;
	
	public function __construct($db) {
		$this->db = $db;
	}

	//Generate a random md5 key to identify the checklist publicly
	public function generateRandomKey() {
		$key = null;

		do {
			$key = md5(rand());
		} while($this->checkRandomKeyExists($key));

		return $key;
	}

	private function checkRandomKeyExists($key) {
		$exists = false;

		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`checklist`
			WHERE `checklist`.`md5 = "%2$s";
		',
			DB_PREFIX.'checklist',
			$key
		))) {
			while($row = $result->fetch_object()) {
				$exists = true;
			}
			$result->close();
		}

		return $exists;
	}
	
	//Take the client_checklist_id, if it isn't already completed, loop throught the questions and completed them
	//We can pass a variable to provide answers weighted to the left, right or center as the default.
	public function autoCompleteChecklist($client_checklist_id, $skew = "center", $skew_multiplier = 1) {
		
		//Get an array of test/sample documents
		$documentArray = array("0123-3210.docx", "0123-3210.jpg", "0123-3210.pdf");
		
		//Get Sample Lorem Ipsum Text
		$lipsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quare hoc videndum est, possitne nobis hoc ratio philosophorum dare. Dic in quovis conventu te omnia facere, ne doleas. Duo Reges: constructio interrete. Quid turpius quam sapientis vitam ex insipientium sermone pendere? Quod autem satis est, eo quicquid accessit, nimium est; Dic in quovis conventu te omnia facere, ne doleas. Paulum, cum regem Persem captum adduceret, eodem flumine invectio? Qui non moveatur et offensione turpitudinis et comprobatione honestatis? Quid enim est a Chrysippo praetermissum in Stoicis? Qui non moveatur et offensione turpitudinis et comprobatione honestatis?
				   Non enim quaero quid verum, sed quid cuique dicendum sit. Quamquam tu hanc copiosiorem etiam soles dicere. At quanta conantur! Mundum hunc omnem oppidum esse nostrum! Incendi igitur eos, qui audiunt, vides. Eadem nunc mea adversum te oratio est. Quid ergo?
				   Itaque his sapiens semper vacabit. Ille vero, si insipiens-quo certe, quoniam tyrannus -, numquam beatus; Hanc quoque iucunditatem, si vis, transfer in animum; Huius ego nunc auctoritatem sequens idem faciam. Idemne, quod iucunde? Scientiam pollicentur, quam non erat mirum sapientiae cupido patria esse cariorem. Ut pulsi recurrant? Cupit enim dícere nihil posse ad beatam vitam deesse sapienti.
				   At quicum ioca seria, ut dicitur, quicum arcana, quicum occulta omnia? Prioris generis est docilitas, memoria; Nunc haec primum fortasse audientis servire debemus. Tum, Quintus et Pomponius cum idem se velle dixissent, Piso exorsus est. Mihi enim satis est, ipsis non satis. Id enim volumus, id contendimus, ut officii fructus sit ipsum officium.";
		
		
		//First check to see if the client checklist is already completed
		$clientChecklist = new clientChecklist($this->db);
		$client_checklist = $clientChecklist->pubGetClientChecklist($client_checklist_id);
		
		if(is_null($client_checklist->completed)) {
			$pages = $clientChecklist->getChecklistPages($client_checklist_id);
			
			foreach($pages as $page) {
				$pageQuestions = $clientChecklist->getPageQuestions($page->page_id);			
				
				foreach($pageQuestions as $question) {
					
					//Get the random answer index
					$randomAnswerIndex = mt_rand(0, (count($question->answers) -1));

					//Skew the answers to one side if required
					if($skew != "center" && count($question->answers) > 1) {
						$skewArray = array();

						//Reverse array if skewed right
						if($skew === "right") {
							$question->answers = array_reverse($question->answers);
						}

						for($i = 0; $i < count($question->answers); $i++) {
							$iterations = (count($question->answers) - $i) * ($skew_multiplier > 0 ? $skew_multiplier : 1);
							for($j = 0; $j < $iterations; $j++) {
								$skewArray[] = $i;
							}
						}

						$randomAnswerIndex = $skewArray[array_rand($skewArray)];
					}

					$index = 0;
					
					//If there is a file-upload option, set that as the index to use.
					foreach($question->answers as $answer) {
						if($answer->answer_type == "file-upload") {
							$randomAnswerIndex = $index;
						}
						$index++;
					}
					
					switch($question->answers[$randomAnswerIndex]->answer_type) {
					
						case 'checkbox-other':
						case 'text':				$arbitrary_value = substr($lipsum, 0, 50);
													break;
													
						case 'textarea':			$arbitrary_value = $lipsum;
													break;
													
						case 'percent':				$arbitrary_value = mt_rand(0,100);
													break;
													
						case 'range':				$arbitrary_value = mt_rand($question->answers[$randomAnswerIndex]->range_min,$question->answers[$randomAnswerIndex]->range_max);
													break;
													
						case 'int':					$arbitrary_value = mt_rand(0,1000000);
													break;
													
						case 'float':				$arbitrary_value = round((mt_rand(0,1000000) / mt_getrandmax()),2);
													break;
													
						case 'url':					$arbitrary_value = 'http://www.greenbizcheck.com';
													break;
													
						case 'date':				$arbitrary_value = mt_rand(1970,date("Y")) . "-" . mt_rand(0,28) . "-" . mt_rand(0,12);
													break;
													
						case 'date-month':			$arbitrary_value = mt_rand(1970,date("Y")) . "-01-" . mt_rand(0,12);
													break;
													
						case 'date-quarter':		$arbitrary_value = mt_rand(1970,date("Y")) . "-01-01";
													break;
													
						case 'file-upload':			$arbitrary_value = $documentArray[mt_rand(0,(count($documentArray)-1))];
													break;								
													
						case 'email':				$arbitrary_value = 'demo@greenbizcheck.com';
													break;
						
						//Default includes checkbox, drop-down-list	
						default:					$arbitrary_value = null;
													break;
											
					}
					
					//Insert the client_result
					$clientChecklist->storeClientResult($client_checklist_id, $question->question_id, $question->answers[$randomAnswerIndex]->answer_id, $arbitrary_value);
					
				}
			}
			
			//Now that the client_results have been completed, score the client checklist and mark as completed
			$this->db->query(sprintf('
				UPDATE `%1$s`.`client_checklist` SET
					`progress` = %3$d,
					`completed` = "%4$s",
					`status` = %5$d
				WHERE `client_checklist_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$client_checklist_id,
				100, //100% completed
				date("Y-m-d H:i:s", (strtotime($client_checklist->created) + 60*60)), //Created time plus 1 hour
				2 //Closed
			));
			
			$calculatedReport = $clientChecklist->getReport($client_checklist_id);
			
		}
		
		return;
	}
	
	//If there is already a checklist that you want to add the data to, pass the third variable, otherwise pass two variables
	public function duplicateAssessment($from_checklist_id,$new_checklist_name, $new_checklist_db = null) {
		$sql = sprintf('
			USE `%1$s`;
			
				INSERT INTO `%4$s`.`checklist` SET `name` = "%3$s";
				SET @new_checklist_id = LAST_INSERT_ID();
			
			SELECT @new_checklist_id AS `checklist_id`;
			
			CREATE TEMPORARY TABLE `page_map` (
				`page_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`page_id` INT(11),
				INDEX (`page_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `question_map` (
				`question_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`question_id` INT(11),
				INDEX (`question_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `answer_map` (
				`answer_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`answer_id` INT(11),
				INDEX (`answer_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `report_section_map` (
				`report_section_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`report_section_id` INT(11),
				INDEX (`report_section_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `action_map` (
				`action_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`action_id` INT(11),
				INDEX (`action_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `metric_group_map` (
				`metric_group_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`metric_group_id` INT(11),
				INDEX (`metric_group_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `metric_map` (
				`metric_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`metric_id` INT(11),
				INDEX (`metric_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `page_section_map` (
				`page_section_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`page_section_id` INT(11),
				INDEX (`page_section_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `page_section_2_page_map` (
				`page_section_2_page_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`page_section_2_page_id` INT(11),
				INDEX (`page_section_2_page_id`)
			) ENGINE = MYISAM;
			
			INSERT INTO `page_map` (`page_id`)
			SELECT `page_id`
			FROM `page`
			WHERE `checklist_id` = %2$d
			ORDER BY `sequence` ASC;
			
			INSERT INTO `question_map` (`question_id`)
			SELECT `question_id`
			FROM `question`
			WHERE `page_id` IN (
				SELECT `page_id`
				FROM `page`
				WHERE `checklist_id` = %2$d
			)
			ORDER BY `question_id` ASC;
			
			INSERT INTO `answer_map` (`answer_id`)
			SELECT `answer_id`
			FROM `answer`
			WHERE `question_id` IN (
				SELECT `question_id`
				FROM `question`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` = %2$d
				)
			)
			ORDER BY `answer_id` ASC;
			
			INSERT INTO `report_section_map` (`report_section_id`)
			SELECT `report_section_id`
			FROM `report_section`
			WHERE `checklist_id` = %2$d
			ORDER BY `report_section_id` ASC;
			
			INSERT INTO `page_section_map` (`page_section_id`)
			SELECT `page_section_id`
			FROM `page_section`
			WHERE `checklist_id` = %2$d
			ORDER BY `page_section_id` ASC;
			
			INSERT INTO `page_section_2_page_map` (`page_section_2_page_id`)
			SELECT `page_section_2_page_id`
			FROM `page_section_2_page`
			WHERE `page_id` IN (
				SELECT `page_id`
				FROM `page`
				WHERE `checklist_id` = %2$d
			)
			ORDER BY `page_section_2_page_id` ASC;
			
			INSERT INTO `action_map` (`action_id`)
			SELECT `action_id`
			FROM `action`
			WHERE `report_section_id` IN (
				SELECT `report_section_id`
				FROM `report_section`
				WHERE `checklist_id` = %2$d
			)
			ORDER BY `action_id` ASC;
			
			INSERT INTO `metric_group_map` (`metric_group_id`)
			SELECT `metric_group_id`
			FROM `metric_group`
			WHERE `page_id` IN (
				SELECT `page_id`
				FROM `page`
				WHERE `checklist_id` = %2$d
			)
			ORDER BY `metric_group_id` ASC;
			
			INSERT INTO `metric_map` (`metric_id`)
			SELECT `metric_id`
			FROM `metric`
			WHERE `metric_group_id` IN (
				SELECT `metric_group_id`
				FROM `metric_group`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` = %2$d
				)
			)
			ORDER BY `metric_id` ASC;
			
			INSERT INTO `%4$s`.`certification_level` (`checklist_id`,`name`,`target`,`progress_bar_color`)
			SELECT
				@new_checklist_id,
				`name`,
				`target`,
				`progress_bar_color`
			FROM `certification_level`
			WHERE `checklist_id` = %2$d
			ORDER BY `certification_level_id` ASC;
			
			INSERT INTO `%4$s`.`page` (`checklist_id`,`sequence`,`enable_skipping`,`title`,`content`)
			SELECT
				@new_checklist_id,
				`sequence`,
				`enable_skipping`,
				`title`,
				`content`
			FROM `page`
			WHERE `checklist_id` = %2$d
			ORDER BY `sequence` ASC;
			
			SET @first_page_id = LAST_INSERT_ID();
			
			INSERT INTO `%4$s`.`metric_group` (`page_id`,`name`,`description`)
			SELECT
				@first_page_id + `page_map`.`page_map_id` - 1,
				`metric_group`.`name`,
				`metric_group`.`description`
			FROM `metric_group`
			LEFT JOIN `page_map` ON `metric_group`.`page_id` = `page_map`.`page_id`
			WHERE `metric_group`.`page_id` IN (
				SELECT `page_id`
				FROM `page`
				WHERE `checklist_id` = %2$d
			)
			ORDER BY `metric_group_id` ASC;
			
			SET @first_metric_group_id = LAST_INSERT_ID();
			
			INSERT INTO `%4$s`.`metric` (`metric_group_id`,`metric`)
			SELECT
				@first_metric_group_id + `metric_group_map`.`metric_group_map_id` - 1,
				`metric`.`metric`
			FROM `metric`
			LEFT JOIN `metric_group_map` ON `metric`.`metric_group_id` = `metric_group_map`.`metric_group_id`
			WHERE `metric`.`metric_group_id` IN (
				SELECT `metric_group_id`
				FROM `metric_group`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` = %2$d
				)
			)
			ORDER BY `metric`.`metric_id` ASC;
			
			SET @first_metric_id = LAST_INSERT_ID();
			
			INSERT INTO `%4$s`.`metric_unit_type_2_metric` (`metric_unit_type_id`,`metric_id`)
			SELECT
				`metric_unit_type_2_metric`.`metric_unit_type_id`,
				@first_metric_id + `metric_map`.`metric_map_id` - 1
			FROM `metric_unit_type_2_metric`
			LEFT JOIN `metric_map` ON `metric_unit_type_2_metric`.`metric_id` = `metric_map`.`metric_id`
			WHERE `metric_unit_type_2_metric`.`metric_id` IN (
				SELECT `metric_id`
				FROM `metric`
				WHERE `metric_group_id` IN (
					SELECT `metric_group_id`
					FROM `metric_group`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` = %2$d
					)
				)
			)
			ORDER BY `metric_unit_type_2_metric_id` ASC;
			
			INSERT INTO `%4$s`.`question` (`checklist_id`,`page_id`,`sequence`,`question`,`tip`,`multiple_answer`,`required`)
			SELECT
				@new_checklist_id,
				@first_page_id + `page_map`.`page_map_id` - 1,
				`question`.`sequence`,
				`question`.`question`,
				`question`.`tip`,
				`question`.`multiple_answer`,
				`question`.`required`
			FROM `question`
			LEFT JOIN `page_map` ON `question`.`page_id` = `page_map`.`page_id`
			WHERE `question`.`page_id` IN (
				SELECT `page_id`
				FROM `page`
				WHERE `checklist_id` = %2$d
			)
			ORDER BY `question`.`question_id` ASC;
			
			SET @first_question_id = LAST_INSERT_ID();
			
			INSERT INTO `%4$s`.`answer` (`question_id`,`answer_string_id`,`sequence`,`answer_type`)
			SELECT
				@first_question_id + `question_map`.`question_map_id` - 1,
				`answer`.`answer_string_id`,
				`answer`.`sequence`,
				`answer`.`answer_type`
			FROM `answer`
			LEFT JOIN `question_map` ON `answer`.`question_id` = `question_map`.`question_id`
			WHERE `answer`.`question_id` IN (
				SELECT `question_id` FROM `question`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` = %2$d
				)
			)
			ORDER BY `answer`.`answer_id` ASC;
			
			SET @first_answer_id = LAST_INSERT_ID();
			
			INSERT INTO `%4$s`.`answer_2_question` (`answer_id`,`question_id`)
			SELECT
				@first_answer_id + `answer_map`.`answer_map_id` - 1,
				@first_question_id + `question_map`.`question_map_id` - 1
			FROM `answer_2_question`
			LEFT JOIN `answer_map` ON `answer_2_question`.`answer_id` = `answer_map`.`answer_id`
			LEFT JOIN `question_map` ON `answer_2_question`.`question_id` = `question_map`.`question_id`
			WHERE `answer_2_question`.`answer_id` IN (
				SELECT `answer_id`
				FROM `answer`
				WHERE `question_id` IN (
					SELECT `question_id`
					FROM `question`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` = %2$d
					)
				)
			) OR `answer_2_question`.`question_id` IN (
				SELECT `question_id`
				FROM `question`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` = %2$d
				)
			)
			ORDER BY `answer_2_question_id` ASC;
			
			INSERT INTO `%4$s`.`report_section` (`checklist_id`,`sequence`,`title`,`content`)
			SELECT
				@new_checklist_id,
				`sequence`,
				`title`,
				`content`
			FROM `report_section`
			WHERE `checklist_id` = %2$d
			ORDER BY `report_section_id` ASC;
			
			SET @first_report_section_id = LAST_INSERT_ID();
			
			INSERT INTO `%4$s`.`confirmation` (`answer_id`,`report_section_id`,`arbitrary_value`,`confirmation`)
			SELECT
				@first_answer_id + `answer_map`.`answer_map_id` - 1,
				@first_report_section_id + `report_section_map`.`report_section_map_id` - 1,
				`confirmation`.`arbitrary_value`,
				`confirmation`.`confirmation`
			FROM `confirmation`
			LEFT JOIN `answer_map` ON `confirmation`.`answer_id` = `answer_map`.`answer_id`
			LEFT JOIN `report_section_map` ON `confirmation`.`report_section_id` = `report_section_map`.`report_section_id`
			WHERE `confirmation`.`answer_id` IN (
				SELECT `answer_id`
				FROM `answer`
				WHERE `question_id` IN (
					SELECT `question_id`
					FROM `question`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` = %2$d
					)
				)
			)
			ORDER BY `confirmation`.`confirmation_id` ASC;
			
			INSERT INTO `%4$s`.`action` (`checklist_id`,`report_section_id`,`sequence`,`demerits`,`title`,`summary`,`proposed_measure`,`comments`)
			SELECT
				@new_checklist_id,
				@first_report_section_id + `report_section_map`.`report_section_map_id` - 1,
				`action`.`sequence`,
				`action`.`demerits`,
				`action`.`title`,
				`action`.`summary`,
				`action`.`proposed_measure`,
				`action`.`comments`
			FROM `action`
			LEFT JOIN `report_section_map` ON `action`.`report_section_id` = `report_section_map`.`report_section_id`
			WHERE `action`.`report_section_id` IN (
				SELECT `report_section_id`
				FROM `report_section`
				WHERE `checklist_id` = %2$d
			)
			ORDER BY `action`.`action_id` ASC;
			
			SET @first_action_id = LAST_INSERT_ID();
			
			INSERT INTO `%4$s`.`action_2_answer` (`action_id`,`answer_id`,`range_min`,`range_max`)
			SELECT
				@first_action_id + `action_map`.`action_map_id` - 1,
				@first_answer_id + `answer_map`.`answer_map_id` - 1,
				`action_2_answer`.`range_min`,
				`action_2_answer`.`range_max`
			FROM `action_2_answer`
			LEFT JOIN `action_map` ON `action_2_answer`.`action_id` = `action_map`.`action_id`
			LEFT JOIN `answer_map` ON `action_2_answer`.`answer_id` = `answer_map`.`answer_id`
			WHERE `action_2_answer`.`action_id` IN (
				SELECT `action_id`
				FROM `action`
				WHERE `report_section_id` IN (
					SELECT `report_section_id`
					FROM `report_section`
					WHERE `checklist_id` = %2$d
				)
			) OR `action_2_answer`.`answer_id` IN (
				SELECT `answer_id`
				FROM `answer`
				WHERE `question_id` IN (
					SELECT `question_id`
					FROM `question`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` = %2$d
					)
				)
			)
			ORDER BY `action_2_answer`.`action_2_answer_id` ASC;
						
			INSERT INTO `%4$s`.`commitment` (`action_id`,`merits`,`sequence`,`commitment`)
			SELECT
				@first_action_id + `action_map`.`action_map_id` - 1,
				`commitment`.`merits`,
				`commitment`.`sequence`,
				`commitment`.`commitment`
			FROM `commitment`
			LEFT JOIN `action_map` ON `commitment`.`action_id` = `action_map`.`action_id`
			WHERE `commitment`.`action_id` IN (
				SELECT `action_id`
				FROM `action`
				WHERE `report_section_id` IN (
					SELECT `report_section_id`
					FROM `report_section`
					WHERE `checklist_id` = %2$d
				)
			)
			ORDER BY `commitment`.`commitment_id` ASC;
			
			INSERT INTO `%4$s`.`page_section` (`checklist_id`,`sequence`,`title`)
			SELECT
				@new_checklist_id,
				`sequence`,
				`title`
			FROM `page_section`
			WHERE `checklist_id` = %2$d
			ORDER BY `page_section_id` ASC;
			
			SET @first_page_section_id = LAST_INSERT_ID();
			
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($from_checklist_id),
			$this->db->escape_string($new_checklist_name),
			is_null($new_checklist_db) ? DB_PREFIX.'checklist' : $new_checklist_db
		);
		
		$result = $this->process($sql);
		
		$new_checklist_id = false;
		foreach($result->records as $record) {
			if(isset($record->checklist_id)) {
				$new_checklist_id = $record->checklist_id;
				break;
			}
		}
		if(count($result->errors)) {
			if($new_checklist_id) {
				$this->deleteAssessment($new_checklist_id);
			}
			die();
		}
		return($new_checklist_id);
	}
	
	public function deleteAssessment($checklist_id) {
	 
		$sql = sprintf('
			USE `%1$s`;
			
			DELETE FROM `metric_unit_type_2_metric`
			WHERE `metric_id` IN (
				SELECT `metric_id`
				FROM `metric`
				WHERE `metric_group_id` IN (
					SELECT `metric_group_id`
					FROM `metric_group`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` = %2$d
					)
				)
			);
			
			DELETE FROM `metric`
			WHERE `metric_group_id` IN (
				SELECT `metric_group_id`
				FROM `metric_group`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` = %2$d
				)
			);
			
			DELETE FROM `metric_group`
			WHERE `page_id` IN (
				SELECT `page_id`
				FROM `page`
				WHERE `checklist_id` = %2$d
			);
			
			DELETE FROM `answer_2_question`
			WHERE `question_id` IN (
				SELECT `question_id`
				FROM `question`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` = %2$d
				)
			)
			OR `answer_id` IN (
				SELECT `answer_id`
				FROM `answer`
				WHERE `question_id` IN (
					SELECT `question_id`
					FROM `question`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` = %2$d
					)
				)
			);
			
			DELETE FROM `action_2_answer`
			WHERE `action_id` IN (
				SELECT `action_id`
				FROM `action`
				WHERE `report_section_id` IN (
					SELECT `report_section_id`
					FROM `report_section`
					WHERE `checklist_id` = %2$d
				)
			) OR `answer_id` IN (
				SELECT `answer_id`
				FROM `answer`
				WHERE `question_id` IN (
					SELECT `question_id`
					FROM `question`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` = %2$d
					)
				)
			);
			
			DELETE FROM `confirmation`
			WHERE `answer_id` IN (
				SELECT `answer_id`
				FROM `answer`
				WHERE `question_id` IN (
					SELECT `question_id`
					FROM `question`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` = %2$d
					)
				)
			);
			
			DELETE FROM `question`
			WHERE `page_id` IN (
				SELECT `page_id`
				FROM `page`
				WHERE `checklist_id` = %2$d
			);
			
			DELETE FROM `page`
			WHERE `checklist_id` = %2$d;
			
			DELETE FROM `commitment`
			WHERE `action_id` IN (
				SELECT `action_id`
				FROM `action`
				WHERE `report_section_id` IN (
					SELECT `report_section_id`
					FROM `report_section`
					WHERE `checklist_id` = %2$d
				)
			);
			
			DELETE FROM `action`
			WHERE `report_section_id` IN (
				SELECT `report_section_id`
				FROM `report_section`
				WHERE `checklist_id` = %2$d
			);
			
			DELETE FROM `report_section`
			WHERE `checklist_id` = %2$d;
			
			DELETE FROM `certification_level`
			WHERE `checklist_id` = %2$d;
			
			DELETE FROM `checklist`
			WHERE `checklist_id` = %2$d;
			
			OPTIMIZE TABLE
				`action_2_answer`,
				`answer_2_question`,
				`answer`,
				`metric`,
				`metric_group`,
				`metric_unit_type_2_metric`,
				`question`,
				`action`,
				`report_section`,
				`certification_level`,
				`checklist`,
				`commitment`;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($checklist_id)
		);
		$result = $this->process($sql);
		if(count($result->errors)) {
			die();
		}
		
		return;
	}
	
		//If there is already a checklist that you want to add the data to, pass the third variable, otherwise pass two variables
	public function duplicateMultipleAssessments($from_checklist_id,$existingChecklistId) {
		$sql = sprintf('
			USE `%1$s`;
			
				SET @new_checklist_id = %3$d;
			
			SELECT @new_checklist_id AS `checklist_id`;
			
			CREATE TEMPORARY TABLE `page_map` (
				`page_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`page_id` INT(11),
				INDEX (`page_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `question_map` (
				`question_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`question_id` INT(11),
				INDEX (`question_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `answer_map` (
				`answer_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`answer_id` INT(11),
				INDEX (`answer_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `report_section_map` (
				`report_section_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`report_section_id` INT(11),
				INDEX (`report_section_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `action_map` (
				`action_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`action_id` INT(11),
				INDEX (`action_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `metric_group_map` (
				`metric_group_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`metric_group_id` INT(11),
				INDEX (`metric_group_id`)
			) ENGINE = MYISAM;
			
			CREATE TEMPORARY TABLE `metric_map` (
				`metric_map_id` INT(11) AUTO_INCREMENT PRIMARY KEY,
				`metric_id` INT(11),
				INDEX (`metric_id`)
			) ENGINE = MYISAM;
			
			INSERT INTO `page_map` (`page_id`)
			SELECT `page_id`
			FROM `page`
			WHERE `checklist_id` IN (%2$s)
			ORDER BY `page_id` ASC;
			
			INSERT INTO `question_map` (`question_id`)
			SELECT `question_id`
			FROM `question`
			WHERE `page_id` IN (
				SELECT `page_id`
				FROM `page`
				WHERE `checklist_id` IN (%2$s)
			)
			ORDER BY `question_id` ASC;
			
			INSERT INTO `answer_map` (`answer_id`)
			SELECT `answer_id`
			FROM `answer`
			WHERE `question_id` IN (
				SELECT `question_id`
				FROM `question`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` IN (%2$s)
				)
			)
			ORDER BY `answer_id` ASC;
			
			INSERT INTO `report_section_map` (`report_section_id`)
			SELECT `report_section_id`
			FROM `report_section`
			WHERE `checklist_id` IN (%2$s)
			ORDER BY `report_section_id` ASC;
			
			INSERT INTO `action_map` (`action_id`)
			SELECT `action_id`
			FROM `action`
			WHERE `report_section_id` IN (
				SELECT `report_section_id`
				FROM `report_section`
				WHERE `checklist_id` IN (%2$s)
			)
			ORDER BY `action_id` ASC;
			
			INSERT INTO `metric_group_map` (`metric_group_id`)
			SELECT `metric_group_id`
			FROM `metric_group`
			WHERE `page_id` IN (
				SELECT `page_id`
				FROM `page`
				WHERE `checklist_id` IN (%2$s)
			)
			ORDER BY `metric_group_id` ASC;
			
			INSERT INTO `metric_map` (`metric_id`)
			SELECT `metric_id`
			FROM `metric`
			WHERE `metric_group_id` IN (
				SELECT `metric_group_id`
				FROM `metric_group`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` IN (%2$s)
				)
			)
			ORDER BY `metric_id` ASC;
			
			INSERT INTO `certification_level` (`checklist_id`,`name`,`target`,`progress_bar_color`)
			SELECT
				@new_checklist_id,
				`name`,
				`target`,
				`progress_bar_color`
			FROM `certification_level`
			WHERE `checklist_id` = %2$d
			ORDER BY `certification_level_id` ASC;
			
			INSERT INTO `page` (`checklist_id`,`sequence`,`enable_skipping`,`title`,`content`)
			SELECT
				@new_checklist_id,
				`sequence`,
				`enable_skipping`,
				`title`,
				`content`
			FROM `page`
			WHERE `checklist_id` IN (%2$s)
			ORDER BY `page_id` ASC;
			
			SET @first_page_id = LAST_INSERT_ID();
			
			INSERT INTO `metric_group` (`page_id`,`name`,`description`)
			SELECT
				@first_page_id + `page_map`.`page_map_id` - 1,
				`metric_group`.`name`,
				`metric_group`.`description`
			FROM `metric_group`
			LEFT JOIN `page_map` ON `metric_group`.`page_id` = `page_map`.`page_id`
			WHERE `metric_group`.`page_id` IN (
				SELECT `page_id`
				FROM `page`
				WHERE `checklist_id` IN (%2$s)
			)
			ORDER BY `metric_group_id` ASC;
			
			SET @first_metric_group_id = LAST_INSERT_ID();
			
			INSERT INTO `metric` (`metric_group_id`,`metric`)
			SELECT
				@first_metric_group_id + `metric_group_map`.`metric_group_map_id` - 1,
				`metric`.`metric`
			FROM `metric`
			LEFT JOIN `metric_group_map` ON `metric`.`metric_group_id` = `metric_group_map`.`metric_group_id`
			WHERE `metric`.`metric_group_id` IN (
				SELECT `metric_group_id`
				FROM `metric_group`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` IN (%2$s)
				)
			)
			ORDER BY `metric`.`metric_id` ASC;
			
			SET @first_metric_id = LAST_INSERT_ID();
			
			INSERT INTO `metric_unit_type_2_metric` (`metric_unit_type_id`,`metric_id`)
			SELECT
				`metric_unit_type_2_metric`.`metric_unit_type_id`,
				@first_metric_id + `metric_map`.`metric_map_id` - 1
			FROM `metric_unit_type_2_metric`
			LEFT JOIN `metric_map` ON `metric_unit_type_2_metric`.`metric_id` = `metric_map`.`metric_id`
			WHERE `metric_unit_type_2_metric`.`metric_id` IN (
				SELECT `metric_id`
				FROM `metric`
				WHERE `metric_group_id` IN (
					SELECT `metric_group_id`
					FROM `metric_group`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` IN (%2$s)
					)
				)
			)
			ORDER BY `metric_unit_type_2_metric_id` ASC;
			
			INSERT INTO `question` (`checklist_id`,`page_id`,`sequence`,`question`,`tip`,`multiple_answer`)
			SELECT
				@new_checklist_id,
				@first_page_id + `page_map`.`page_map_id` - 1,
				`question`.`sequence`,
				`question`.`question`,
				`question`.`tip`,
				`question`.`multiple_answer`
			FROM `question`
			LEFT JOIN `page_map` ON `question`.`page_id` = `page_map`.`page_id`
			WHERE `question`.`page_id` IN (
				SELECT `page_id`
				FROM `page`
				WHERE `checklist_id` IN (%2$s)
			)
			ORDER BY `question`.`question_id` ASC;
			
			SET @first_question_id = LAST_INSERT_ID();
			
			INSERT INTO `answer` (`question_id`,`answer_string_id`,`sequence`,`answer_type`)
			SELECT
				@first_question_id + `question_map`.`question_map_id` - 1,
				`answer`.`answer_string_id`,
				`answer`.`sequence`,
				`answer`.`answer_type`
			FROM `answer`
			LEFT JOIN `question_map` ON `answer`.`question_id` = `question_map`.`question_id`
			WHERE `answer`.`question_id` IN (
				SELECT `question_id` FROM `question`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` IN (%2$s)
				)
			)
			ORDER BY `answer`.`answer_id` ASC;
			
			SET @first_answer_id = LAST_INSERT_ID();
			
			INSERT INTO `answer_2_question` (`answer_id`,`question_id`)
			SELECT
				@first_answer_id + `answer_map`.`answer_map_id` - 1,
				@first_question_id + `question_map`.`question_map_id` - 1
			FROM `answer_2_question`
			LEFT JOIN `answer_map` ON `answer_2_question`.`answer_id` = `answer_map`.`answer_id`
			LEFT JOIN `question_map` ON `answer_2_question`.`question_id` = `question_map`.`question_id`
			WHERE `answer_2_question`.`answer_id` IN (
				SELECT `answer_id`
				FROM `answer`
				WHERE `question_id` IN (
					SELECT `question_id`
					FROM `question`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` IN (%2$s)
					)
				)
			) OR `answer_2_question`.`question_id` IN (
				SELECT `question_id`
				FROM `question`
				WHERE `page_id` IN (
					SELECT `page_id`
					FROM `page`
					WHERE `checklist_id` IN (%2$s)
				)
			)
			ORDER BY `answer_2_question_id` ASC;
			
			INSERT INTO `report_section` (`checklist_id`,`sequence`,`title`,`content`)
			SELECT
				@new_checklist_id,
				`sequence`,
				`title`,
				`content`
			FROM `report_section`
			WHERE `checklist_id` IN (%2$s)
			ORDER BY `report_section_id` ASC;
			
			SET @first_report_section_id = LAST_INSERT_ID();
			
			INSERT INTO `confirmation` (`answer_id`,`report_section_id`,`arbitrary_value`,`confirmation`)
			SELECT
				@first_answer_id + `answer_map`.`answer_map_id` - 1,
				@first_report_section_id + `report_section_map`.`report_section_map_id` - 1,
				`confirmation`.`arbitrary_value`,
				`confirmation`.`confirmation`
			FROM `confirmation`
			LEFT JOIN `answer_map` ON `confirmation`.`answer_id` = `answer_map`.`answer_id`
			LEFT JOIN `report_section_map` ON `confirmation`.`report_section_id` = `report_section_map`.`report_section_id`
			WHERE `confirmation`.`answer_id` IN (
				SELECT `answer_id`
				FROM `answer`
				WHERE `question_id` IN (
					SELECT `question_id`
					FROM `question`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` IN (%2$s)
					)
				)
			)
			ORDER BY `confirmation`.`confirmation_id` ASC;
			
			INSERT INTO `action` (`checklist_id`,`report_section_id`,`sequence`,`demerits`,`title`,`summary`,`proposed_measure`,`comments`)
			SELECT
				@new_checklist_id,
				@first_report_section_id + `report_section_map`.`report_section_map_id` - 1,
				`action`.`sequence`,
				`action`.`demerits`,
				`action`.`title`,
				`action`.`summary`,
				`action`.`proposed_measure`,
				`action`.`comments`
			FROM `action`
			LEFT JOIN `report_section_map` ON `action`.`report_section_id` = `report_section_map`.`report_section_id`
			WHERE `action`.`report_section_id` IN (
				SELECT `report_section_id`
				FROM `report_section`
				WHERE `checklist_id` IN (%2$s)
			)
			ORDER BY `action`.`action_id` ASC;
			
			SET @first_action_id = LAST_INSERT_ID();
			
			INSERT INTO `action_2_answer` (`action_id`,`answer_id`,`range_min`,`range_max`)
			SELECT
				@first_action_id + `action_map`.`action_map_id` - 1,
				@first_answer_id + `answer_map`.`answer_map_id` - 1,
				`action_2_answer`.`range_min`,
				`action_2_answer`.`range_max`
			FROM `action_2_answer`
			LEFT JOIN `action_map` ON `action_2_answer`.`action_id` = `action_map`.`action_id`
			LEFT JOIN `answer_map` ON `action_2_answer`.`answer_id` = `answer_map`.`answer_id`
			WHERE `action_2_answer`.`action_id` IN (
				SELECT `action_id`
				FROM `action`
				WHERE `report_section_id` IN (
					SELECT `report_section_id`
					FROM `report_section`
					WHERE `checklist_id` IN (%2$s)
				)
			) OR `action_2_answer`.`answer_id` IN (
				SELECT `answer_id`
				FROM `answer`
				WHERE `question_id` IN (
					SELECT `question_id`
					FROM `question`
					WHERE `page_id` IN (
						SELECT `page_id`
						FROM `page`
						WHERE `checklist_id` IN (%2$s)
					)
				)
			)
			ORDER BY `action_2_answer`.`action_2_answer_id` ASC;
						
			INSERT INTO `commitment` (`action_id`,`merits`,`sequence`,`commitment`)
			SELECT
				@first_action_id + `action_map`.`action_map_id` - 1,
				`commitment`.`merits`,
				`commitment`.`sequence`,
				`commitment`.`commitment`
			FROM `commitment`
			LEFT JOIN `action_map` ON `commitment`.`action_id` = `action_map`.`action_id`
			WHERE `commitment`.`action_id` IN (
				SELECT `action_id`
				FROM `action`
				WHERE `report_section_id` IN (
					SELECT `report_section_id`
					FROM `report_section`
					WHERE `checklist_id` IN(%2$d)
				)
			)
			ORDER BY `commitment`.`commitment_id` ASC;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($from_checklist_id),
			$existingChecklistId
		);
		$result = $this->process($sql);
		
		$new_checklist_id = false;
		foreach($result->records as $record) {
			if(isset($record->checklist_id)) {
				$new_checklist_id = $record->checklist_id;
				break;
			}
		}
		if(count($result->errors)) {
			if($new_checklist_id) {
				$this->deleteAssessment($new_checklist_id);
			}
			die();
		}
		return($new_checklist_id);
	}
	
	private function process($sql) {
		$queryNo	= 0;
		$return = new stdClass();
		$return->errors		= array();
		$return->records	= array();
		$this->db->multi_query($sql);
		while(true) {
			if($result = $this->db->use_result()) {
				while($row = $result->fetch_object()) {
					$return->records[$queryNo] = $row;
				}
				$result->close();
			}
			if(!$this->db->more_results()) break;			
			$this->db->next_result();
			$queryNo++;
		}
		return($return);
	}
}
?>