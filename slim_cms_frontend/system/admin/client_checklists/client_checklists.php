<?php

//Check to see if we need to set additional client filters
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`client_type`;
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'client_type');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT
		`client_checklist`.`client_id`,
		`client_checklist`.`checklist_id`,
		`client_checklist`.`client_checklist_id`,
		`client_checklist`.`name` AS `assessment_name`,
		CASE WHEN `client_checklist`.`current_score` IS NOT NULL
		THEN `client_checklist`.`current_score`
		ELSE 0
		END AS `current_score`,
		`client_checklist`.`completed`,
		`client_checklist`.`created`,
		`client`.`company_name`
		FROM `%1$s`.`client_checklist`
		LEFT JOIN `%2$s`.`client` on `client_checklist`.`client_id` = `client`.`client_id`
		WHERE 1
		' . resultFilter::conditional_client_filter($this->db, $this->user) . '
		' . resultFilter::conditional_client_checklist_filter($this->db, $this->user) . '
		AND `client`.`client_id` IS NOT NULL
		ORDER BY `client`.`company_name` ASC;
',
	DB_PREFIX.'checklist',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'client');
	}
	$result->close();
}

?>