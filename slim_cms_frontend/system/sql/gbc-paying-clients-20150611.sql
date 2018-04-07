SELECT
`invoice`.`client_id`,
`client`.`company_name`,
`invoice`.`timestamp` AS `last_invoice`,
`client`.`suburb`,
`client`.`state`,
`client`.`country`,
`client_contact`.`firstname`,
`client_contact`.`lastname`,
`client_contact`.`phone`,
`client_contact`.`email`,
IF(`invoice`.`paid` = '1', 'YES', 'NO') AS `paid` 
FROM `greenbiz_pos`.`invoice`
LEFT JOIN `greenbiz_core`.`client` ON `invoice`.`client_id` = `client`.`client_id`
LEFT JOIN `greenbiz_core`.`client_contact` ON `client`.`client_id` = `client_contact`.`client_id`
WHERE `invoice`.`timestamp` > '2012-06-01 00:00:00'
AND `client`.`company_name` IS NOT NULL
GROUP BY `client`.`client_id`