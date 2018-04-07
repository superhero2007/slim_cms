SELECT
`metric_group`.`sequence`,
`metric_group`.`name`,
`metric`.`sequence`,
`metric`.`metric`,
(
	SELECT 
	GROUP_CONCAT(`metric_unit_type`.`metric_unit_type`)
    FROM `greenbiz_checklist`.`metric_unit_type`
    LEFT JOIN `greenbiz_checklist`.`metric_unit_type_2_metric` ON `metric_unit_type`.`metric_unit_type_id` = `metric_unit_type_2_metric`.`metric_unit_type_id`
    WHERE `metric_unit_type_2_metric`.`metric_id` = `metric`.`metric_id`
) AS `units`
#`metric`.`max_duration`,
#`metric`.`required`
FROM `greenbiz_checklist`.`metric`
LEFT JOIN `greenbiz_checklist`.`metric_group` ON `metric`.`metric_group_id` = `metric_group`.`metric_group_id`
WHERE `metric_group`.`page_id` = '2574'
ORDER BY
`metric_group`.`sequence`, `metric`.`sequence`;