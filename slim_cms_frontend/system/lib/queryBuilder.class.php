<?php
class queryBuilder {
	private $db;
	private static $query = null;
	private static $values = null;
	
	public function __construct($db) {
		$this->db = $db;
		$this->constructQuery();
	}

	public function getQuery() {
		return self::$query;
	}

	public function getValues() {
		return self::$values;
	}

	public function buildQueryFilter() {
		return $this->getQuery();
	}

	private function constructQuery() {
		$index = 0;
		$query = array();
		$values = array();
		if(isset($_REQUEST['filter-field'])) {

			foreach($_REQUEST['filter-field'] as $filterField) {
			
				if(!empty($filterField)) {

					//Get the filterField Data
					$filter_query = $this->getFilterQueryById($_REQUEST['filter-type'][$index]);
					$filter_value = $_REQUEST['filter-value'][$index];
					$raw_value = $_REQUEST['filter-value'][$index];
					$grouped = false;

					if($filterField === '16') {
						$dashboard = new dashboard($this->db);
						$filter_value = $dashboard->buildUserDefinedGroupHierarchyArray($filter_value);
					}

					//Check to see if the query is pattern matching. Replace single percentage with double for sprintf.
					if(strpos($filter_query->sql,'%') !== false) {
						$filter_value = str_replace('%','%%',str_replace(str_replace('%','',$filter_query->sql), $filter_value, $filter_query->sql));
						$filter_query->sql = str_replace('%','',$filter_query->sql); 
					}

					//Check if the filter query is using the IN sql parameter and prepre the content
					if($filter_query->sql === 'IN(' OR $filter_query->sql === 'NOT IN(') {
						$grouped = true;
						$filter_value = $this->prepareGroupedFilterValue($filter_value);
					}

					//Now check how the post data is to be formatted
					//Question/Answer
					if(strpos($filterField, 'qid') !== false) {
						$filter_field = new stdClass;
						$filter_field->table = 'client_result';
						$filter_field->field = 'question_id';
						$identifiers = explode('-',$filterField);

						!isset($query[$index]) ? $query[$index] = "\n" : null;
						//Question ID
						$query[$index] .= " AND `" . $filter_field->table . "`.`" . $filter_field->field . "` = ";
						$query[$index] .= (is_numeric($identifiers[1]) ? $identifiers[1] : "'" . $identifiers[1] . "'") . "\n";

						//Answer String
						$query[$index] .= " AND (`client_result`.`arbitrary_value` ";
						$query[$index] .= ($grouped ? $filter_query->sql : $filter_query->sql . " ");
						$query[$index] .= (is_numeric($filter_value) ? $filter_value : "'" . $filter_value . "'");
						$query[$index] .= " OR `answer_string`.`string` ";
						$query[$index] .= ($grouped ? $filter_query->sql : $filter_query->sql . " ");
						$query[$index] .= (is_numeric($filter_value) ? $filter_value : "'" . $filter_value . "'") . ") \n";

					} else {

						$filter_field = $this->getFilterFieldById($filterField);
						if($filter_field->apply_formatting) {
							$filter_value = $this->formatInputValue($filter_value, $filter_field->formatting);
						}

						!isset($query[$index]) ? $query[$index] = "\n" : null;
						$query[$index] .= " AND `" . $filter_field->table . "`.`" . $filter_field->field . "` "; 
						$query[$index] .= $filter_query->sql;
						$query[$index] .= $grouped ? "" . $filter_value . " \n" : " '" . $filter_value . "' \n";
					}

					//Set values
					$values[] = [
						//'database' 		=> $filter_field->database,
						'table' 		=> $filter_field->table,
						'field' 		=> $filter_field->field,
						'sql' 			=> $filter_query->sql,
						'explanation' 	=> $filter_query->explanation,
						'value' 		=> $filter_value,
						'raw'	 		=> $raw_value
					];
				}
		
				$index++;
			}
		} else {
			//If the filter field is not set then check for any other applicable query variables
			if(isset($_GET)) {
				foreach($_GET as $key=>$val) {
					switch($key) {
						case 'client_id':
							$query[] = " AND `client`.`client_id` = '" . $val . "'\n";
							break;
						case 'client_checklist_id':
							$query[] = " AND `client_checklist`.`client_checklist_id` = '" . $val . "'\n";
							break;
					}
				}
			}
		}

		//Set the static values
		self::$query = $query;
		self::$values = $values;

		return;
	}
	
	private function getFilterFieldById($id) {
		$filter_field = new stdClass;
	
		//Get the filter field
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`filter_fields`
			WHERE `filter_fields_id` = %2$d;
		',
			DB_PREFIX.'dashboard',
			$id
		))) {
			while($row = $result->fetch_object()) {
				$filter_field = $row;
			}
			$result->close();
		}	
		
		return $filter_field;
	}

	private function formatInputValue($value, $format) {
		$evalString = str_replace('^', $value, $format);
		return(@eval('return('.$evalString.');'));
	}
	
	private function getFilterQueryById($id) {
		$filter_query = new stdClass;
	
		//Get the filter field
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`filter_queries`
			WHERE `filter_query_id` = %2$d;
		',
			DB_PREFIX.'dashboard',
			$id
		))) {
			while($row = $result->fetch_object()) {
				$filter_query = $row;
			}
			$result->close();
		}	
		
		return $filter_query;
	
	}

	private function prepareGroupedFilterValue($value) {
		$prepared_value = "";
		$value_items = is_array($value) ? $value : explode(',',$value);

		$item_count = count($value_items);
		for($i = 0; $i < $item_count; $i++) {
			$prepared_value .= "'" . trim($value_items[$i]) . "'" . ($i === (count($value_items)-1) ? ")" : ",");
		}

		return $prepared_value;
	}

}
?>