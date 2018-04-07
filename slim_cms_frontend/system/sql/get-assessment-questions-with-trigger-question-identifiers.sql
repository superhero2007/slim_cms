SET @checklist_id = 101;
USE `greenbiz_checklist`;

SELECT
#`question`.`checklist_id`,
`question`.`question_id` AS `Question Id`,
`page_section`.`title` AS `Section`,
`page`.`title` AS `Page Title`,
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(`page`.`content`,'<p>',''),'</p>',''),'<o:p></o:p>',''),'&#39;',''),'&nbsp;',''),'&rsquo;',''),'\n',''), '<b>',''), '</b>', ''),'<strong>',''),'</strong>','') AS `Page Content`,
`trigger_answer`.`question_id` AS `Parent Question Id`,
`trigger_answer`.`answer_id` AS `Parent Answer Id`,
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(`question`.`question`,'<p>',''),'</p>',''),'<o:p></o:p>',''),'&#39;',''),'&nbsp;',''),'&rsquo;',''),'\n',''), '<b>',''), '</b>', ''),'<strong>',''),'</strong>','') AS `Question`
FROM `answer`
LEFT JOIN `answer_string` ON `answer`.`answer_string_id` = `answer_string`.`answer_string_id`
LEFT JOIN `action_2_answer` ON `answer`.`answer_id` = `action_2_answer`.`answer_id`
LEFT JOIN `question` ON `answer`.`question_id` = `question`.`question_id`
LEFT JOIN `page` ON `question`.`page_id` = `page`.`page_id`
LEFT JOIN `page_section_2_page` ON `question`.`page_id` = `page_section_2_page`.`page_id`
LEFT JOIN `page_section` ON `page_section`.`page_section_id` = `page_section_2_page`.`page_section_id`
LEFT JOIN `answer_2_question` ON `question`.`question_id` = `answer_2_question`.`question_id`
LEFT JOIN `answer` AS `trigger_answer` ON `answer_2_question`.`answer_id` = `trigger_answer`.`answer_id`
WHERE `question`.`checklist_id` = @checklist_id

AND `trigger_answer`.`answer_id` IS NULL

OR `trigger_answer`.`question_id` NOT IN (
SELECT
`all_triggers`.`question_id`
FROM(
	SELECT 
	`level1`.*,
	'1' AS `level`
	FROM (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` FROM `answer_2_question`
		LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id` 
		LEFT JOIN `question` ON `answer`.`question_id` = `question`.`question_id`
        WHERE `question`.`checklist_id` = @checklist_id) AS `level1`

	UNION

	SELECT 
	`level2`.*,
	'2' AS `level`
	FROM (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id`
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`
        LEFT JOIN `question` ON `answer`.`question_id` = `question`.`question_id`
        WHERE `question`.`checklist_id` = @checklist_id) AS `level1`
	LEFT OUTER JOIN (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id`
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level2` 
	ON `level1`.`question_id` = `level2`.`parent_id`

	UNION

	SELECT 
	`level3`.*,
	'3' AS `level`
	FROM (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id` 
        LEFT JOIN `question` ON `answer`.`question_id` = `question`.`question_id` 
        WHERE `question`.`checklist_id` = @checklist_id) AS `level1`
	LEFT OUTER JOIN (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level2` 
	ON `level1`.`question_id` = `level2`.`parent_id`
	LEFT OUTER JOIN (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level3` 
	ON `level2`.`question_id` = `level3`.`parent_id`

	UNION

	SELECT 
	`level4`.*,
	'4' AS `level`
	FROM (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id` 
        LEFT JOIN `question` ON `answer`.`question_id` = `question`.`question_id` 
        WHERE `question`.`checklist_id` = @checklist_id) AS `level1`
		LEFT OUTER JOIN (
			SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id`
            FROM `answer_2_question`
            LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level2` 
		ON `level1`.`question_id` = `level2`.`parent_id`
		LEFT OUTER JOIN (
			SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
            FROM `answer_2_question` 
            LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level3` 
		ON `level2`.`question_id` = `level3`.`parent_id`
		LEFT OUTER JOIN (
			SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
            FROM `answer_2_question` 
            LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level4` 
		ON `level4`.`question_id` = `level4`.`parent_id`
	) AS `all_triggers`
	WHERE `all_triggers`.`answer_2_question_id` IS NOT NULL
	GROUP BY `all_triggers`.`question_id`
) AND `question`.`checklist_id` = @checklist_id


OR `trigger_answer`.`question_id` IN (
	SELECT `all_triggers`.`question_id`
	FROM(
		SELECT 
		`level1`.*,
		'1' AS `level`
		FROM (
			SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
            FROM `answer_2_question` 
            LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id` 
            LEFT JOIN `question` ON `answer`.`question_id` = `question`.`question_id` 
            WHERE `question`.`checklist_id` = @checklist_id) AS `level1`

	UNION

	SELECT 
	`level2`.*,
	'2' AS `level`
	FROM (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id` 
        LEFT JOIN `question` ON `answer`.`question_id` = `question`.`question_id` 
        WHERE `question`.`checklist_id` = @checklist_id) AS `level1`
	LEFT OUTER JOIN (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level2` 
	ON `level1`.`question_id` = `level2`.`parent_id`

	UNION

	SELECT 
	`level3`.*,
	'3' AS `level`
	FROM (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id` 
        LEFT JOIN `question` ON `answer`.`question_id` = `question`.`question_id` 
        WHERE `question`.`checklist_id` = @checklist_id) AS `level1`
	LEFT OUTER JOIN (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level2` 
	ON `level1`.`question_id` = `level2`.`parent_id`
	LEFT OUTER JOIN (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level3` 
	ON `level2`.`question_id` = `level3`.`parent_id`

	UNION

	SELECT 
	`level4`.*,
	'4' AS `level`
	FROM (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id` 
        LEFT JOIN `question` ON `answer`.`question_id` = `question`.`question_id` 
        WHERE `question`.`checklist_id` = @checklist_id) AS `level1`
	LEFT OUTER JOIN (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level2` 
	ON `level1`.`question_id` = `level2`.`parent_id`
	LEFT OUTER JOIN (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level3` 
	ON `level2`.`question_id` = `level3`.`parent_id`
	LEFT OUTER JOIN (
		SELECT `answer_2_question`.*, `answer`.`question_id` AS `parent_id` 
        FROM `answer_2_question` 
        LEFT JOIN `answer` ON `answer_2_question`.`answer_id` = `answer`.`answer_id`) AS `level4` 
	ON `level4`.`question_id` = `level4`.`parent_id`
) AS `all_triggers`
WHERE `all_triggers`.`answer_2_question_id` IS NOT NULL
GROUP BY `all_triggers`.`question_id`
)

GROUP BY `question`.`question_id`
ORDER BY `page_section`.`sequence`,`page`.`sequence`, `question`.`sequence`