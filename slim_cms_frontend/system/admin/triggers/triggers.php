<?php
if(isset($_REQUEST['action'])) {
	switch($_REQUEST['action']) {
		case 'followup_trigger_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`followup_trigger` SET
					`followup_trigger_id` = %2$d,
					`active` = "%3$s",
					`name` = "%4$s",
					`sql` = "%5$s",
					`action` = "%6$s",
					`email_stationary` = "%7$s",
					`email_subject` = "%8$s",
					`function_arguments` = "%9$s";
					
			',
				DB_PREFIX.'crm',
				$this->db->escape_string($_POST['followup_trigger_id']),
				$this->db->escape_string($_POST['active']),
				$this->db->escape_string($_POST['name']),
				$this->db->escape_string($_POST['sql']),
				$this->db->escape_string($_POST['trigger_action']),
				$this->db->escape_string($_POST['email_stationary']),
				$this->db->escape_string($_POST['email_subject']),
				$this->db->escape_string($_POST['function_arguments'])
			));
			header('location: ?page=triggers&mode=followup_trigger_edit&followup_trigger_id='.$this->db->insert_id);
			die();
		}
		case 'followup_trigger_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`followup_trigger`
				WHERE `followup_trigger_id` = %2$d;
				OPTIMIZE TABLE `%1$s`.`followup_trigger`;
			',
				DB_PREFIX.'crm',
				$this->db->escape_string($_REQUEST['followup_trigger_id'])
			));
			header('location: ?page=triggers');
			die();
		}
		
		case 'manual_process': {
			//Run the follow up cron script
			$db = $this->db;
			include(PATH_SYSTEM . '/cron/followup.job.php');
			header('location: ?page=triggers');
			die();
		}
	}
}
if($result = $this->db->query(sprintf('
	SELECT `followup_trigger`.*
	FROM `%1$s`.`followup_trigger`;
',
	DB_PREFIX.'crm'
))) {
	while($row = $result->fetch_object()) {
		$sql[$row->followup_trigger_id] = $row->sql;
		$this->row2config($row,'followup_trigger');
	}
	$result->close();
}
if(isset($_REQUEST['followup_trigger_id'])) {
	if($result = $this->db->query($sql[$_REQUEST['followup_trigger_id']])) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'trigger_result');
		}
		$result->close();
	} else {
		$this->doc->lastChild->appendChild($this->doc->createElement('trigger_error',$this->db->error));
	}
}
?>