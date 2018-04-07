SELECT
`answer_2_question`.`answer_2_question_id`,
`question`.`question_id`,
`question`.`question`,
`checklist`.`checklist_id`,
`checklist`.`name`,
`trigger_question`.`question_id` AS 'Trigger Question ID',
`trigger_question`.`question` AS 'Trigger Question',
`trigger_answer`.`answer_id` AS 'Trigger Answer ID',
`trigger_answer`.`answer_type`,
`answer_string`.`string` AS 'Answer',
`answer_2_question`.`range_min`,
`answer_2_question`.`range_max`
FROM `greenbiz_checklist`.`answer_2_question`
LEFT JOIN `greenbiz_checklist`.`question` ON `answer_2_question`.`question_id` = `question`.`question_id`
LEFT JOIN `greenbiz_checklist`.`checklist` ON `question`.`checklist_id` = `checklist`.`checklist_id`
LEFT JOIN `greenbiz_checklist`.`answer` AS `trigger_answer` ON `answer_2_question`.`answer_id` = `trigger_answer`.`answer_id`
LEFT JOIN `greenbiz_checklist`.`question` AS `trigger_question` ON `trigger_answer`.`question_id` = `trigger_question`.`question_id`
LEFT JOIN `greenbiz_checklist`.`answer_string` ON `trigger_answer`.`answer_string_id` = `answer_string`.`answer_string_id`


WHERE `question`.`checklist_id` = '83'

GROUP BY `answer_2_question`.`answer_2_question_id`