<?php
@include('../../../config.php');
$adminContent = new adminContent();
$adminContent->loadXSL(PATH_SYSTEM.'/admin/shell.xsl');
$adminContent->loadContent(PATH_SYSTEM.'/admin');

header("Content-type: text/plain");
$db = new mysqli(DB_HOST,DB_USER,DB_PASS);
$checklist_id = $_REQUEST['checklist_id'];

if($result = $db->query(sprintf('
	SELECT 
		`page_id`,
		`title`
	FROM `%1$s`.`page`
	WHERE `checklist_id` = %2$d
	ORDER BY `sequence` ASC;
',
	DB_PREFIX.'checklist',
	$db->escape_string($checklist_id)
))) {
	while($page = $result->fetch_object()) {
		print_r($page);
		$db->query(sprintf('
			INSERT INTO `%1$s`.`report_section` SET
				`checklist_id` = %2$d,
				`title` = "%3$s";
		',
			DB_PREFIX.'checklist',
			$db->escape_string($checklist_id),
			$db->escape_string($page->title)
		));
		$report_section_id = $db->insert_id;
		if($result2 = $db->query(sprintf('
			SELECT
				`question`.`question_id`,
				`answer`.`answer_id`,
				`question`.`question`
			FROM `%1$s`.`question`
			LEFT JOIN `%1$s`.`answer` ON 
				`question`.`question_id` = `answer`.`question_id` AND
				`answer`.`answer_string_id` = 2
			WHERE `question`.`page_id` = %2$d
			ORDER BY `question`.`sequence`
		',
			DB_PREFIX.'checklist',
			$db->escape_string($page->page_id)
		))) {
			while($question = $result2->fetch_object()) {
				print_r($question);
				$db->query(sprintf('
					INSERT INTO `%1$s`.`action` SET
						`checklist_id` = %2$d,
						`report_section_id` = %3$d,
						`demerits` = 1,
						`title` = "%4$s",
						`summary` = "%4$s";
				',
					DB_PREFIX.'checklist',
					$db->escape_string($checklist_id),
					$db->escape_string($report_section_id),
					$db->escape_string($question->question)
				));
				$action_id = $db->insert_id;
				$db->query(sprintf('
					INSERT INTO `%1$s`.`action_2_answer` SET
						`action_id` = %2$d,
						`answer_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$db->escape_string($action_id),
					$db->escape_string($question->answer_id)
				));
				$db->query(sprintf('
					INSERT INTO `%1$s`.`commitment` SET
						`action_id` = %2$d,
						`merits` = 1,
						`sequence` = 1,
						`commitment` = "We have or will commit to implement this measure";
				',
					DB_PREFIX.'checklist',
					$db->escape_string($action_id)
				));
			}
			$result2->close();
		}
	}
	$result->close();
}
print $db->error;
?>