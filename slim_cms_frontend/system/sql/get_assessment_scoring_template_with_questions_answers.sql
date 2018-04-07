#Gets question_id, page_title and question in sequence order and removes xhtml formatting.
SELECT
`question`.`question_id` AS `Question Id`,
#`question`.`checklist_id`,
#`question`.`page_id`,
#`question`.`sequence`,
IFNULL(`page_section`.`title`,'') AS `Page Section`,
`page`.`title` AS `Page Title`,
#`page`.`sequence`,
IF(`page`.`display_in_table` = '1',
	CONCAT(
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(`page`.`content`,'<p>',''),'</p>',''),'<o:p></o:p>',''),'&#39;',''),'&nbsp;',''),'&rsquo;',''),'\n',''), '<strong>',''), '</strong>',''), '\r',' '), ' - ',
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(`question`.`question`,'<p>',''),'</p>',''),'<o:p></o:p>',''),'&#39;',''),'&nbsp;',''),'&rsquo;',''),'\n','')),
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(`question`.`question`,'<p>',''),'</p>',''),'<o:p></o:p>',''),'&#39;',''),'&nbsp;',''),'&rsquo;',''),'\n','')
) AS `Question`,
#`answer`.`answer_id` AS `Answer Id`,
#`answer`.`answer_type` AS `Answer Type`,
#REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(`question`.`tip`,'<p>',''),'</p>',''),'<o:p></o:p>',''),'&#39;',''),'&nbsp;',''),'&rsquo;',''),'\n','') AS 'Help Text',
IFNULL(IF(`answer`.`answer_type` IN('percent','range'), CONCAT(`action_2_answer`.`range_min`, ' to ', `action_2_answer`.`range_max`), `answer_string`.`string`),'') AS `Answer`,
IFNULL(`action`.`demerits`, 0) AS `Demerits`,
'' AS `Confirmation`,
'' AS `Suggested Action`,
'' AS `Relevant Facts`,
'' AS `Commitment Options`
FROM `greenbiz_checklist`.`answer`
LEFT JOIN `greenbiz_checklist`.`answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
LEFT JOIN `greenbiz_checklist`.`action_2_answer` ON `answer`.`answer_id` = `action_2_answer`.`answer_id`
LEFT JOIN `greenbiz_checklist`.`question` ON `answer`.`question_id` = `question`.`question_id`
LEFT JOIN `greenbiz_checklist`.`page` ON `question`.`page_id` = `page`.`page_id`
LEFT JOIN `greenbiz_checklist`.`page_section_2_page` ON `question`.`page_id` = `page_section_2_page`.`page_id`
LEFT JOIN `greenbiz_checklist`.`page_section` ON `page_section`.`page_section_id` = `page_section_2_page`.`page_section_id`
LEFT JOIN `greenbiz_checklist`.`action` ON `action_2_answer`.`action_id` = `action`.`action_id`
WHERE `question`.`checklist_id` = '116'
GROUP BY `answer`.`answer_id`
ORDER BY `page`.`sequence`, `question`.`sequence`;