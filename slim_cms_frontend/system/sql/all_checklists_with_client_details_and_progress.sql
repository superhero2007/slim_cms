SELECT
`client_checklist`.`client_checklist_id`,
`client_checklist`.`name`,
`client`.`client_id`,
`client`.`company_name`,
`client_contact`.`firstname`,
`client_contact`.`lastname`,
`client_contact`.`email`,
`client_checklist`.`created`,
`client_checklist`.`completed`,
`client_checklist`.`progress`,
(CASE
	WHEN `client_checklist`.`completed` IS NOT NULL
	THEN 'YES'
	ELSE 'NO'
END) AS `finished`
FROM `greenbiz_checklist`.`client_checklist`
LEFT JOIN `greenbiz_core`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
LEFT JOIN `greenbiz_core`.`client_contact` ON `client`.`client_id` = `client_contact`.`client_id`
WHERE `client_checklist`.`checklist_id` IN(77,78,79,80,81,82)
AND `client`.`client_id` IS NOT NULL
GROUP BY `client_checklist`.`client_checklist_id`
ORDER BY `client_checklist`.`created`;