SELECT
`client`.`client_id`,
`client`.`company_name`,
`client_checklist`.`client_checklist_id`,
`checklist`.`checklist_id`,
`checklist`.`name`,
`question`.`question_id`,
`question`.`question`,
`answer_string`.`string`,
`client_result`.`arbitrary_value`,
`client_result`.`client_result_id`,
`client_result`.`answer_id`
FROM `greenbiz_checklist`.`client_result`
LEFT JOIN `greenbiz_checklist`.`client_checklist` ON `client_result`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
LEFT JOIN `greenbiz_checklist`.`checklist` ON `client_checklist`.`checklist_id` = `checklist`.`checklist_id`
LEFT JOIN `greenbiz_checklist`.`question` ON `client_result`.`question_id` = `question`.`question_id`
LEFT JOIN `greenbiz_checklist`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id`
LEFT JOIN `greenbiz_checklist`.`page` ON `question`.`page_id` = `page`.`page_id`
LEFT JOIN `greenbiz_checklist`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
LEFT JOIN `greenbiz_core`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
WHERE `client_checklist`.`checklist_id` IN(77,78,79,80,81,82)
AND `client`.`client_id` IS NOT NULL
ORDER BY `client_checklist`.`client_checklist_id`,`page`.`sequence`,`question`.`sequence`, `answer`.`sequence`
