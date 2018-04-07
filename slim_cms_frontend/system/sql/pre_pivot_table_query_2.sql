SELECT
`client`.`company_name`,
`client_checklist`.`client_checklist_id`,
IF(`client_checklist`.`completed` IS NOT NULL, 'YES', 'NO') as `completed`,
`cc`.`firstname`,
`cc`.`lastname`,
`cc`.`email`,
`checklist`.`name`,
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(`question`.`question`,'<p>',''),'</p>',''),'<o:p></o:p>',''),'&#39;',''),'&nbsp;',''),'&rsquo;',''),'\n','') AS `question`,
IF(`answer_string`.`string` IS NULL, `client_result`.`arbitrary_value`, `answer_string`.`string`) as `answer`
FROM `greenbiz_checklist`.`client_result`
LEFT JOIN `greenbiz_checklist`.`question` ON `client_result`.`question_id` = `question`.`question_id`
LEFT JOIN `greenbiz_checklist`.`answer` ON `client_result`.`answer_id` = `answer`.`answer_id`
LEFT JOIN `greenbiz_checklist`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
LEFT JOIN `greenbiz_checklist`.`client_checklist` ON `client_result`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
LEFT JOIN `greenbiz_checklist`.`checklist` ON `client_checklist`.`checklist_id` = `checklist`.`checklist_id`
LEFT JOIN `greenbiz_checklist`.`page` ON `page`.`page_id` = `question`.`page_id`
LEFT JOIN `greenbiz_core`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
LEFT JOIN (
	SELECT *
    FROM `greenbiz_core`.`client_contact`
    GROUP BY `client_contact`.`client_id`
) AS `cc` ON `client`.`client_id` = `cc`.`client_id`

#Set the checklist_id
WHERE `client_checklist`.`checklist_id` = '79'
AND `question`.`question` IS NOT NULL
AND `client`.`company_name` IS NOT NULL
ORDER BY `client_checklist`.`client_checklist_id`, `page`.`sequence`, `question`.`sequence`, `answer`.`sequence`;