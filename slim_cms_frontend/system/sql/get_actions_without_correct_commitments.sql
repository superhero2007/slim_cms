#Query to locate all actions with either 0 demerits or 
#actions with demerits that have a higher
#value than the maximum commitment merits

SELECT
	`action`.*
FROM `greenbiz_checklist`.`action`
WHERE `action`.`action_id` NOT IN (
	SELECT
	`action`.`action_id`
	FROM `greenbiz_checklist`.`commitment`
	LEFT JOIN `greenbiz_checklist`.`action` ON `commitment`.`action_id` = `action`.`action_id`
	WHERE `commitment`.`merits` = `action`.`demerits`
)
#Uncomment the following line to remove actions with zero demerits
#AND `action`.`demerits` > 0
ORDER BY `action`.`checklist_id`