SELECT
`client`.`client_id`,
`client`.`company_name`,
`client`.`address_line_1`,
`client`.`address_line_2`,
`client`.`suburb`,
`client`.`state`,
`client`.`postcode`,
`client_checklist`.`client_checklist_id`,
`client_checklist`.`name`,
`client_checklist`.`progress`,
`client_checklist`.`created`,
`client_checklist`.`completed`
FROM greenbiz_checklist.client_checklist
LEFT JOIN `greenbiz_core`.`client` ON `client_checklist`.`client_id` = `client`.`client_id`
WHERE `client_checklist`.`checklist_id` IN(77,78,79,80,81,82)
AND `client`.`client_id` IS NOT NULL
AND `client_checklist`.`created` > '2014-02-10';