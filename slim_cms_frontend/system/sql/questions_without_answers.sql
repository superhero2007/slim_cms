SELECT
`question`.*,
`checklist`.`name`,
`page`.`title`
FROM `greenbiz_checklist`.`question`
LEFT JOIN `greenbiz_checklist`.`checklist` ON `question`.`checklist_id` = `checklist`.`checklist_id`
LEFT JOIN `greenbiz_checklist`.`page` ON `question`.`page_id` = `page`.`page_id`
WHERE `question_id` NOT IN (
	SELECT `question_id`
	FROM `greenbiz_checklist`.`answer`
	GROUP BY `question_id`
)
AND `question`.`checklist_id` != 0;