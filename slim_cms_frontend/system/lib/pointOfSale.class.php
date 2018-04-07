<?php
//Point of Sale Class

class pointOfSale {
	private $db;

	public function __construct($db) {
		$this->db = $db;

		return;
	}

	public function addProductToAccount($client_id,$product_id,$quantity) {
		$clientChecklist = new clientChecklist($this->db);

		if($result = $this->db->query(sprintf('
			SELECT
				`checklist_2_product`.`checklist_id`,
				`checklist_2_product`.`checklist_variation_id`,
				`checklist_2_product`.`product_id`,
				`checklist_2_product`.`checklists`,
				IF(
					`checklist_variation`.`checklist_variation_id` IS NULL,
					`checklist`.`name`,
					`checklist_variation`.`name`
				) AS `name`
			FROM `%1$s`.`checklist_2_product`
			LEFT JOIN `%2$s`.`checklist` ON
				`checklist_2_product`.`checklist_id` = `checklist`.`checklist_id`
			LEFT JOIN `%2$s`.`checklist_variation` ON
				`checklist_2_product`.`checklist_variation_id` = `checklist_variation`.`checklist_variation_id`
			WHERE `checklist_2_product`.`product_id` = %3$d;
		',
			DB_PREFIX.'pos',
			DB_PREFIX.'checklist',
			$this->db->escape_string($product_id)
		))) {
			while($row = $result->fetch_object()) {
				$row->checklists = 1;
				for($i=0;$i<$row->checklists;$i++) {
					$this->db->query(sprintf('
						INSERT INTO `%1$s`.`client_checklist` SET 
							`checklist_id` = %2$d,
							`checklist_variation_id` = IF("%3$d" != "",%3$d,NULL),
							`client_id` = %4$d,
							`name` = "%5$s",
							`audit_required` = %6$d;
					',
						DB_PREFIX.'checklist',
						$row->checklist_id,
						$row->checklist_variation_id,
						$client_id,
						$this->db->escape_string($row->name),
						($row->checklist_variation_id == 2 ? '0' : $clientChecklist->checklistAuditRequired($row->checklist_id))
					));
				}
			}
			$result->close();
		}
		return;
	}

}

?>