<?php

class clientChecklistFunction {

	private $db;
	private $clientChecklistClass;
	private $clientChecklist;
	private $emissionFactors;
	private $questionAnswers;
	private $mathParser;
	
	public function __construct($db, $client_checklist_id) {
		$this->db = $db;

		//Get the clientChecklist class
		$this->clientChecklistClass = new clientChecklist($this->db);
		$this->clientChecklist = $this->clientChecklistClass->getChecklistByClientChecklistId($client_checklist_id);
		$this->questionAnswers = $this->clientChecklistClass->getQuestionAnswers($this->clientChecklist->client_checklist_id);
		$this->mathParser = new \oat\beeme\Parser();

		//Get the emission factors
		$this->emissionFactors = $this->clientChecklistClass->getClientChecklistEmissionFactors($this->clientChecklist->client_checklist_id);
	}

	public function processClientChecklistFunctions() {

		foreach($this->questionAnswers as $questionAnswerArray) {
			foreach($questionAnswerArray as $questionAnswer) {
				if($questionAnswer->function != '' & !is_null($questionAnswer->function)){
					$function = explode('|',$questionAnswer->function);
					$functionCall = explode('$', $function[0]);

					if(isset($functionCall[0])) {
						try {
							switch($functionCall[0]) {
								case 'additionalValue':	$this->calculateAdditionalValue($function, $questionAnswer);
									break;
							}
						} catch(Exception $e) {
							error_log($e);
						}
					}
				}
			}
		}

		return;
	}

	//Check for any followup SQL and process if necessary
	public function processClientChecklistFollowupSql() {
		if(isset($this->clientChecklist->followup_sql) && !is_null($this->clientChecklist->followup_sql) && isset($this->clientChecklist->client_checklist_id)) {
			$query = sprintf($this->clientChecklist->followup_sql, $this->clientChecklist->client_checklist_id);
			$this->db->multi_query($query);
			while ($this->db->more_results() && $this->db->next_result());
		}

		return;
	}

	private function calculateAdditionalValue($function, $questionAnswer) {
		$calculation = array();
		$functionCall = null;
		$value = 0;
		$skip = false;
		$numeric = true;
		$index = isset($questionAnswer->index) && intval($questionAnswer->index) >= 0 ?  $questionAnswer->index : null;

		foreach($function as $arguments) {
			$argumentItems = explode('$', $arguments);
			if(count($argumentItems) > 1 && !$skip) {
				switch($argumentItems[0]) {
					case 'emission':
						if(isset($argumentItems[1]) && isset($argumentItems[2])) {
							$calculation[] = $this->getEmissionFactor(isset($argumentItems[1]) ? $argumentItems[1] : null, isset($argumentItems[2]) ? $argumentItems[2] : null, isset($argumentItems[3]) ? $argumentItems[3] : null);
						}
					break;

					case 'answer':
						if(isset($argumentItems[1])) {
							$answer = $this->getAnswer(isset($argumentItems[1]) ? $argumentItems[1] : null, $index);
							$calculation[] = is_numeric($answer) ? $answer : 0;
						}
					break;

					case 'question':
						if(isset($argumentItems[1])) {
							$answer = $this->getQuestion(isset($argumentItems[1]) ? $argumentItems[1] : null, $index);
							$calculation[] = is_numeric($answer) ? $answer : 0;
						}
					break;

					case 'conversion':
						if(isset($argumentItems[1]) && isset($argumentItems[2])) {
							$conversion = $this->getUnitConversion($argumentItems[1], $argumentItems[2], $index);
							$calculation[] = $conversion;
						}
					break;

					case 'ifstring':
						if(isset($argumentItems[1]) && isset($argumentItems[2])) {
							if(!$this->testQuestionString($argumentItems[1], $argumentItems[2], $index)) {
								$skip = true;
							}
						}
					break;

					case 'text':
						if(isset($argumentItems[1])) {
							$calculation[] = $argumentItems[1];
							$numeric = false;
						}
					break;

					case 'getAdditionalValue':
						if(isset($argumentItems[1]) && isset($argumentItems[2])) {
							$additional_value = $this->clientChecklistClass->getClientChecklistAdditionalValue($this->clientChecklist->client_checklist_id, $argumentItems[1], $argumentItems[2], isset($argumentItems[3]) ? $argumentItems[3] : $index);
							$calculation[] = isset($additional_value->value) ? $additional_value->value : 0;
						}
					break;

					case 'additionalValue':
						$functionCall = $argumentItems;
					break;
				}

			} else {
				if($argumentItems[0] === 'endif') {
					if($skip) {
						$skip = false;
					} else {
						break;
					}
				} else {
					!$skip ? $calculation[] = $argumentItems[0] : null;
				}
			}
		}

		//echo "<p>" . implode(' ', $calculation) . "</p>";
		if(!empty($calculation)) {
			$value = $numeric ? $this->mathParser->evaluate(implode(' ', $calculation)) : implode(' ', $calculation);
			if(isset($functionCall[0]) && isset($functionCall[1]) && isset($functionCall[2])) {
				$this->setAdditionalValue($functionCall[1], $functionCall[2], isset($questionAnswer->index) ? $questionAnswer->index : 0, $value);
			}
		//	echo $value;
		}

		return;
	}

	private function getQuestion($question_id, $index = 0) {
		$answer_value = 0;

		foreach($this->questionAnswers as $questionAnswer) {
			foreach($questionAnswer as $question) {
				if($question->question_id === $question_id) {
					if(intval($index) >= 0) {
						if(intval($question->index) === intval($index)) {
							$answer_value = $question->arbitrary_value;
						}
					} else {
						$answer_value = $question->arbitrary_value;
					}
				}
			}
		}

		return $answer_value;
	}

	private function getQuestionNode($question_id, $index = 0) {
		$questionNode = null;

		foreach($this->questionAnswers as $questionAnswer) {
			foreach($questionAnswer as $question) {
				if($question->question_id === $question_id) {
					if(intval($index) >= 0) {
						if(intval($question->index) === intval($index)) {
							$questionNode = $question;
						}
					} else {
						$questionNode = $question;
					}
				}
			}
		}

		return $questionNode;
	}

	private function getAnswer($answer_id, $index = 0) {
		$answer_value = 0;

		foreach($this->questionAnswers as $questionAnswer) {
			foreach($questionAnswer as $answer) {
				if($answer->answer_id === $answer_id) {
					if(intval($index) >= 0) {
						if(intval($answer->index) === intval($index)) {
							$answer_value = $answer->arbitrary_value;
						}
					} else {
						$answer_value = $answer->arbitrary_value;
					}
				}
			}
		}

		return $answer_value;
	}

	private function getEmissionFactor($category, $key, $sub_category = null) {
		$factor = 0;

		foreach($this->emissionFactors as $emissionFactor) {
			if($emissionFactor->category === $category && $emissionFactor->key === $key) {
				if(!is_null($sub_category)) {
					if($emissionFactor->sub_category === $sub_category) {
						$factor = $emissionFactor->factor;
					}
				} else {
					$factor = $emissionFactor->factor;
				}
			}
		}

		return $factor;
	}

	private function testQuestionString($question_id, $query, $index = 0) {
		$result = false;

		$question = $this->getQuestionNode($question_id, $index);

		if(isset($question->answer_string) && $question->answer_string === $query) {
			$result = true;
		}

		return $result;
	}

	private function getUnitConversion($toUnit, $question_id, $index = 0) {
		$value = 1; //Default conversion
		$question = $this->getQuestionNode($question_id, $index);
		$baseUnit = isset($question->answer_string) ? $question->answer_string : null;

		switch($baseUnit) {
			case 'GJ': 
				switch($toUnit) {
					case 'MJ':
						$value = 1000;
					break;
				}
			break;

			case 'MJ': 
				switch($toUnit) {
					case 'GJ':
						$value = 0.001;
					break;
				}
			break;
		}

		return $value;
	}

	private function setAdditionalValue($key, $group, $index = 0, $value = 0) {

		$this->clientChecklistClass->deleteAdditionalValue($this->clientChecklist->client_checklist_id, $key, $index);
		$this->clientChecklistClass->storeAdditionalValue($this->clientChecklist->client_checklist_id, $key, $value, $index, $group);
	
		return;
	}
}
?>