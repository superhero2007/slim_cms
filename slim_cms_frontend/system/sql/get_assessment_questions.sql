#Gets question_id, page_title and question in sequence order and removes xhtml formatting.
SELECT
`question`.`question_id` AS `Question Id`,
#`question`.`checklist_id`,
#`question`.`page_id`,
#`question`.`sequence`,
`page`.`title` AS `Page Title`,
#`page`.`sequence`,
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(`question`.`question`,'<p>',''),'</p>',''),'<o:p></o:p>',''),'&#39;',''),'&nbsp;',''),'&rsquo;',''),'\n','') AS `Question`
FROM `greenbiz_checklist`.`question`
LEFT JOIN `greenbiz_checklist`.`page` ON `question`.`page_id` = `page`.`page_id`
WHERE `question`.`checklist_id` = '57'
ORDER BY `page`.`sequence`, `question`.`sequence`;