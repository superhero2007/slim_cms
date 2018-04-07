<?php
//Audit Cost Class

class auditCost {
 	private $db;
 	private $audit_fee = "0.14";
 	private $base_cost_entry = "849.00";
  	private $base_cost_small = "1650.00";
   	private $base_cost_medium = "2900.00";
    private $base_cost_large = "5600.00";
 	private $base_cost_enterprise = "9800.00";	

	//Get an instance of the database connection in the constructor
	public function __construct($db) {
		$this->db = $db;
	}
	
	//Check if the audit cost has been set
	private function getAudit($audit_id) {
		
	 	if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`audit`
			WHERE `audit_id` = %2$d;
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($audit_id)
		))) {

			while($row = $result->fetch_object()) {
				return $row;
			}
		}
		
		return;
	}
	
	//Get the last invoice amount
	private function getLastInvoiceAmount($client_id) {
		$inv = new invoice($this->db);
		
		$client_invoices = $inv->getInvoicesByClientId($client_id);
		
		$last_client_invoice = $inv->getInvoiceById($client_invoices[0]->invoice_id);
		
		return $last_client_invoice->invoice_total;
	}
	
	//Get the number of staff that the organisaton has
	private function getClientStaffNumber($client_checklist_id) {
	$number_of_staff = 0;

		if($result = $this->db->query(sprintf('
			SELECT
				`client_result`.`arbitrary_value`
			FROM `%1$s`.`client_result`
			WHERE `client_result`.`question_id` IN (
				SELECT `question`.`question_id` 
				FROM `%1$s`.`question` 
				WHERE `question`.`question` LIKE "%%number of staff%%")
			AND `client_result`.`arbitrary_value` IS NOT NULL
			AND `client_result`.`arbitrary_value` != ""
			AND `client_result`.`client_checklist_id` = "%2$s"
			ORDER BY `client_result`.`timestamp` DESC
			LIMIT 1
		',
			DB_PREFIX.'checklist',
			$client_checklist_id
		))) {
			while($row = $result->fetch_object()) {
				$number_of_staff = $row->arbitrary_value;
			}
			$result->close();
		}
		return $number_of_staff;
	}
	
	//Get the audit cost
	private function getAuditCost($audit_id) {
	
		$audit_cost = "0";
		
		//Get the audit details
		$audit = $this->getAudit($audit_id);
	
		//Get the client_checklist details
		$client_checklist = new clientChecklist($this->db);
		$clientChecklistDetails = $client_checklist->getChecklistByClientChecklistId($audit->client_checklist_id);
		
		//Get the number of staff
		$numberOfStaff = $this->getClientStaffNumber($clientChecklistDetails->client_checklist_id);
		
		switch($numberOfStaff) {
		
			case ($numberOfStaff < 11):
											$audit_cost = $this->base_cost_entry * $this->audit_fee;
											break;
											
			case ($numberOfStaff < 21):
											$audit_cost = $this->base_cost_small * $this->audit_fee;
											break;
											
			case ($numberOfStaff < 51):
											$audit_cost = $this->base_cost_medium * $this->audit_fee;
											break;
											
			case ($numberOfStaff < 101):
											$audit_cost = $this->base_cost_large * $this->audit_fee;
											break;
											
			case ($numberOfStaff < 9999999999):
											$audit_cost = $this->base_cost_enterprise * $this->audit_fee;
											break;

			default:
											$audit_cost = $this->base_cost_entry * $this->audit_fee;
											break;
		}
		
		//Check to see if the staff level is a numeric, if set the audit cost to be the base price
		if(!is_numeric($numberOfStaff)) {
			$audit_cost = $this->base_cost_entry * $this->audit_fee;
		}
		
		//Return to 2 decimal places
		return number_format($audit_cost, 2, '.', '');
	}
	
	//Set the audit cost
	public function setAuditCost($audit_id) {
	 	//Update the audit database with the amount of the audit cost
	 	if($result = $this->db->query(sprintf('
			UPDATE `%1$s`.`audit`
			SET `audit_cost` = "%3$s"
			WHERE `audit_id` = %2$d;
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($audit_id),
			$this->getAuditCost($audit_id)
		)))
		
		return;
	}
	
	//Return an array of audits with no costs set
	public function getAllUncostedAudits() {
		$uncosted_audits = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`audit`.*
			FROM `%1$s`.`audit`
			WHERE `audit`.`audit_cost` = "0";
		',
			DB_PREFIX.'audit'
		))) {
			while($row = $result->fetch_object()) {
				$uncosted_audits[] = $row;
			}
			$result->close();
		}
		return($uncosted_audits);
	}
	
	//Update the audit_cost for each of the uncosted audits
	public function setAllUncostedAudits() {
		$uncosted_audits = $this->getAllUncostedAudits();
		
		foreach($uncosted_audits as $uncosted_audit) {
			$this->setAuditCost($uncosted_audit->audit_id);
		}
		
		return;
	}
	
}