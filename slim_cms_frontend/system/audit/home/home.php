<?php

//Get all of the assessments completed and incomplete
//$monitor = new monitor($this->db);

	if($result = $this->db->query($sql = sprintf('
		SELECT *
		FROM `%1$s`.`audit`
	',
		DB_PREFIX.'audit'
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'audit');
		}
		$result->close();
	}