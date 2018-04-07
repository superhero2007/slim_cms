<?php
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`checklist`
	ORDER BY `checklist_id` ASC;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'checklist');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT
		`client_id`,
		`username`,
		`company_name`
	FROM `%1$s`.`client`
	ORDER BY `company_name` ASC, `username` ASC;
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'client');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT
		`client`.`company_name`,
		`checklist_2_client`.`checklist_2_client_id`,
		`checklist_2_client`.`checklist_id`,
		`checklist_2_client`.`client_id`,
		`checklist_2_client`.`progress`,
		`checklist`.`checklist`,
		IF(`client_report`.`client_report_id` IS NOT NULL,
			IF(UNIX_TIMESTAMP(`client_report`.`timestamp`) + `checklist`.`report_delay` <= UNIX_TIMESTAMP(NOW()),
				"Report Available",
				"Report Pending"
			),
			"Incomplete"
		) AS `status`,
		SUM(`client_report_section`.`points`) AS `points`,
		SUM(`client_report_section`.`demerits`) AS `demerits`
	FROM `%1$s`.`checklist_2_client`
	LEFT JOIN `%2$s`.`client`
		ON `checklist_2_client`.`client_id` = `client`.`client_id`
	LEFT JOIN `%1$s`.`checklist`
		ON `checklist_2_client`.`checklist_id` = `checklist`.`checklist_id`
	LEFT JOIN `%1$s`.`client_report`
		ON `checklist_2_client`.`checklist_id` = `client_report`.`checklist_id`
		AND `checklist_2_client`.`client_id` = `client_report`.`client_id`
	LEFT JOIN `%1$s`.`client_report_section`
		ON `client_report`.`client_report_id` = `client_report_section`.`client_report_id`
	WHERE 1
	'.(@$_REQUEST['client_id'] ? 'AND `checklist_2_client`.`client_id` = '.$_REQUEST['client_id'] : null).'
	'.(@$_REQUEST['checklist_id'] ? 'AND `checklist_2_client`.`checklist_id` = '.$_REQUEST['checklist_id'] : null).'
	GROUP BY `checklist_2_client`.`checklist_2_client_id`
	ORDER BY `company_name` ASC, `client_id` ASC, `checklist` ASC;
',
	DB_PREFIX.'checklist',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'report');
	}
	$result->close();
}
?>