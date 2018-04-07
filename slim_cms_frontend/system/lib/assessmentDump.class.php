<?php
class assessmentDump {
	private $db;
	private $checklist_pages;
	private $report_sections;
	
	public function __construct($db) {
		$this->db = $db;
	}
	
	public function __destruct() {
		$this->db->close();
	}
	
	public function get_assessment_pages($checklist_id) {
		$pages = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`page`.*
			FROM `%1$s`.`page`
			WHERE `page`.`checklist_id` = %2$d
			ORDER BY `page`.`sequence` ASC;
		',
			DB_PREFIX.'checklist',
			$checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$pages[$row->page_id] = $row;
				$pages[$row->page_id]->questions = $this->get_page_questions($row->page_id);
			}
			$result->close();
		}
		return($pages);
	}
	
	private function get_page_questions($page_id) {
		$questions = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`question`.*
			FROM `%1$s`.`question`
			WHERE `question`.`page_id` = %2$d
			ORDER BY `question`.`sequence` ASC;
		',
			DB_PREFIX.'checklist',
			$page_id
		))) {
			while($row = $result->fetch_object()) {
				$questions[$row->question_id] = $row;
				$questions[$row->question_id]->answers = $this->get_question_answers($row->question_id);
			}
			$result->close();
		}
		return($questions);
	}
	
	private function get_question_answers($question_id) {
		$answers = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`answer`.`answer_id`,
				`answer`.`question_id`,
				`answer`.`answer_string_id`,
				`answer`.`sequence`,
				`answer`.`answer_type`,
				`answer_string`.`string`
			FROM `%1$s`.`answer`
			LEFT JOIN `%1$s`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
			WHERE `answer`.`question_id` = %2$d
			ORDER BY `answer`.`sequence` ASC;
		',
			DB_PREFIX.'checklist',
			$question_id
		))) {
			while($row = $result->fetch_object()) {
				$answers[$row->answer_id] = $row;
				$answers[$row->answer_id]->actions = $this->get_answer_actions($row->answer_id);
			}
			$result->close();
		}
		return($answers);
	}
	
	private function get_answer_actions($answer_id) {
		$actions = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`action_2_answer`.*,
				`action`.*,
				`report_section`.`title` AS `report_section`
			FROM `%1$s`.`action_2_answer`
			LEFT JOIN `%1$s`.`action` ON `action_2_answer`.`action_id` = `action`.`action_id`
			LEFT JOIN `%1$s`.`report_section` ON `action`.`report_section_id` = `report_section`.`report_section_id`
			WHERE `action_2_answer`.`answer_id` = %2$d
			ORDER BY `action`.`sequence` ASC;
		',
			DB_PREFIX.'checklist',
			$answer_id
		))) {
			while($row = $result->fetch_object()) {
				$actions[$row->action_id] = $row;
				$actions[$row->action_id]->commitments = $this->get_action_commitments($row->action_id);
			}
			$result->close();
		}
		return($actions);
	}
	
	private function get_action_commitments($action_id) {
		$commitments = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`commitment`.*
			FROM `%1$s`.`commitment`
			WHERE `commitment`.`action_id` = %2$d
			ORDER BY `commitment`.`sequence`;
		',
			DB_PREFIX.'checklist',
			$action_id
		))) {
			while($row = $result->fetch_object()) {
				$commitments[$row->commitment_id] = $row;
			}
			$result->close();
		}
		return($commitments);
	}
}
?>