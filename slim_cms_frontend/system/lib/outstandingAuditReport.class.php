<?php
class outstandingAuditReport {
	private $db;
	
	public function __construct($db) {
		$this->db = $db;
		$data = array();

		$data['Incomplete Audits'] = $this->getOutstandingAudits();
		
		$from 			= 'GreenBizCheck <webmaster@greenbizcheck.com>';
		$returnPath		= '-fwebmaster@greenbizcheck.com';
		$company		= 'GreenBizCheck';
			
		$emailHeaders =
			"From: $from\r\n".
			"Reply-To: $from\r\n".
			"Return-Path: $from\r\n".
			"Organization: $company\r\n".
			"X-Priority: 3\r\n".
			"X-Mailer: PHP". phpversion() ."\r\n".
			"MIME-Version: 1.0\r\n".
			"Content-type: text/html; charset=UTF-8\r\n";
			
		$body =
			"<h1>Outstanding Audits ".date('D jS M Y',strtotime('-0 days'))."</h1>\n";
		foreach($data as $title => $table) {
			$body .= "<h2>".$title."</h2>\n".$table;
		}
		
		if($this->getOutstandingAuditCount() > 0) {
			mail("info@greenbizcheck.com, gbc@au.bureauveritas.com","Outstanding Audit Report for week ending ".date('D jS M Y',strtotime('-0 days')),$body,$emailHeaders,'-fwebmaster@greenbizcheck.com');
			//mail("info@timdorey.com","Outstanding Audit Report for week ending ".date('D jS M Y',strtotime('-0 days')),$body,$emailHeaders,'-fwebmaster@greenbizcheck.com');
		}
	}
	
	// Get the latest client_checklist audits and add them to the daily/weekly report
	private function getOutstandingAudits() {
		if($result = $this->db->query(sprintf('
			SELECT
				`client`.`company_name` AS `Company Name`,
				`audit`.`client_checklist_id` AS `Client Checklist Id`,
				`audit`.`audit_score` AS `Initial Audit Score`,
				`audit`.`audit_start_date` AS `Start Date`,
				`audit_status`.`status` AS `Audit Status`,
				`audit`.`audit_id`,
				CONCAT("<a href=\"http://www.greenbizcheck.com/audit/index.php?page=audit&amp;mode=audit_edit&amp;audit_id=",`audit`.`audit_id`,"\">","link","</a>") AS `link`
			FROM `%3$s`.`audit`
			LEFT JOIN `%2$s`.`client_checklist` ON `client_checklist`.`client_checklist_id` = `audit`.`client_checklist_id`
			LEFT JOIN `%1$s`.`client` ON `client`.`client_id` = `client_checklist`.`client_id`
			LEFT JOIN `%3$s`.`audit_status` ON `audit`.`status` = `audit_status`.`status_id`
			WHERE `audit`.`status` IN (1,2,5,6)
			AND `audit`.`audit_finish_date` = "0000-00-00 00:00:00"
			GROUP BY `audit`.`client_checklist_id`
			ORDER BY `audit`.`audit_start_date` ASC;
		',
			DB_PREFIX.'core',
			DB_PREFIX.'checklist',
			DB_PREFIX.'audit'
		))) {
			$table = $this->result2Table($result);
			$result->close();
		}
		return($table);
	}
	
	// Get the latest client_checklist audits and add them to the daily/weekly report
	private function getOutstandingAuditCount() {
		if($result = $this->db->query(sprintf('
			SELECT
				COUNT(`audit`.`audit_id`)
			FROM `%1$s`.`audit`
			WHERE `audit`.`status` IN (1,2,5,6)
			AND `audit`.`audit_finish_date` = "0000-00-00 00:00:00";
		',
			DB_PREFIX.'audit'
		))) {
			$count = $result->fetch_object();
		}
		return($count);
	}
	
	private function result2Table($result) {
		$data = array();
		while($row = $result->fetch_object()) {
			$data[] = $row;
			if(!isset($headers)) {
				$headers = array();
				foreach($row as $key => $val) {
					$header[] = $key;
				}
			}
		}
		$table =
			"<table border=\"1\" width=\"100%\">\n".
			"<thead>\n".
			"<tr>\n";
		foreach($data[0] as $key => $val) {
			$table .= "<th scope=\"col\">".$key."</th>\n";
		}
		$table .=
			"</tr>\n".
			"</thead>\n".
			"<tbody>\n";
		for($i=0;$i<count($data);$i++) {
			$table .= "<tr>\n";
			foreach($data[$i] as $key => $val) {
				$table .= "<td>".($val == '' ? '&nbsp;' : $val)."</td>\n";
			}
			$table .= "</tr>\n";
		}
		$table .=
			"</tbody>\n".
			"</table>\n";
		return($table);
	}
}
?>