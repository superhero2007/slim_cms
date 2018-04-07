<?php

class dbModel {
	
	protected $db;
	
	public function __construct($db) {
		$this->db = $db;
	}
	
	protected static function createElementWithAttributes($doc, $tagName, $obj) {
		$node = $doc->createElement($tagName);
		if (is_object($obj)) {
			foreach ($obj as $key => $value) {
				if (!is_object($value) && !is_array($value)) {
					$node->setAttribute($key, $value);
				}
			}
		}
		return($node);
	}
	
	protected static function update($db, $dbName, $tableName, $where, $values) {
		$updateSql = '';
		$counter = 3;
		
		$dataParameters = array();
		foreach ($values as $key => $value) {
			if ($updateSql != '') {
				$updateSql .= ', ';
			}
			
			$updateSql .= '`'.$key.'`'.'="%'.$counter.'$s"';
			$dataParameters[] = $value;
			$counter += 1;
		}
		
		$sql = '
			UPDATE `%1$s`.`%2$s`
			SET '.$updateSql.'
			WHERE '.$where.';';
			
		$parameters = array(
			DB_PREFIX.$dbName,
			$tableName
		);
		
		$preparedSql = call_user_func_array('sprintf', array_merge((array)$sql, $parameters, $dataParameters));
		return($db->query($preparedSql));
	}
	
	protected static function create($db, $dbName, $tableName, $values) {
		$updateSql = '';
		$counter = 3;
		
		$sqlKeys = '';
		$sqlValues = '';
		$sqlData = array();
		
		$counter = 3;
		foreach ($values as $key => $value) {
			if ($sqlKeys != '') {
				$sqlKeys .= ',';
				$sqlValues .= ',';
			}
			
			$sqlKeys .= '`'.$key.'`';
			$sqlValues .= '"%'.$counter.'$s"';
			$sqlData[] = $value;
			
			$counter += 1;
		}
		
		$sql = '
			INSERT INTO `%1$s`.`%2$s`
				('.$sqlKeys.')
				VALUES ('.$sqlValues.');';
			
		$parameters = array(
			DB_PREFIX.$dbName,
			$tableName
		);
		
		$preparedSql = call_user_func_array('sprintf', array_merge((array)$sql, $parameters, $sqlData));
		return($db->query($preparedSql));
	}

	protected static function delete($db, $dbName, $tableName, $where) {
		$sql = sprintf('
			DELETE FROM `%1$s`.`%2$s`
			WHERE '.$where.';
		',
			DB_PREFIX.$dbName,
			$tableName			
		);
		return($db->query($sql));
	}

	protected function query($sql, $parameters) {
		$preparedSql = call_user_func_array('sprintf', array_merge((array)$sql, $parameters));
		return($this->db->query($preparedSql));
	}
	
	protected function additionalWhereToSql($where, $includeAnd) {
		if ($where) {
			if ($includeAnd) {
				return('AND ('.$where.')');
			}
			else {
				return(' '.$where);
			}
		}
		return('');
	}
	
	protected function prep_vars($parameters) {
		foreach($parameters as $key => $value) {
			// Check if any nodes are arrays themselves
			if(is_string($parameters[$key]))
				// If they are, perform the real escape function over the selected node
				$parameters[$key] = mysql_real_escape_string($parameters[$key]);
		}  
	
	}
	
	protected function additionalVariablesMerge($additionalVariables, $variables) {
		if ($additionalVariables) {
			$variables = array_merge($variables, $additionalVariables);
		}
		return($variables);
	}

	public function getTableFields($schema, $table) {
		$columns = array();

		$query = sprintf('SHOW COLUMNS FROM `%1$s`.`%2$s`;', DB_PREFIX.$schema, $table);
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$columns[$row->Field] = $row;
			}
			$result->close();
		}

		return $columns;
	}

	//Take an insert or update query and prepare the query
	//Pass the schema, table, command (INSERT INTO, UPDATE, REPLACE INTO)
	//Pass array of values eg $data['field_name'] = 'field_value'
	//Optional: Pass array of WHERE/AND options eg $data['field_name'] = 'field_value'
	public function prepare_query($schema, $table, $command, $data, $where = null) {
		$query = '';

		$tableFields = $this->getTableFields($schema, $table);
		foreach($data as $key => $val) {

			//Remove unrequired fields
			if(!in_array($key, array_keys($tableFields))) {
				unset($data[$key]);
				continue;

			//Remove primary key
			} elseif($tableFields[$key]->Key === 'PRI' && $tableFields[$key]->Extra === 'auto_increment') {
				unset($data[$key]);
				continue;
			}

			//Prepare the data for the field
			switch($tableFields[$key]->Type) {
				case 'datetime':
				case 'timestamp':
					 	$data[$key] = date('Y-m-d H:i:s', strtotime($data[$key]));
					 break;		
			}

		}

		$query .= sprintf('%1$s `%2$s`.`%3$s` SET',$command, DB_PREFIX.$schema, $table);
		foreach($data as $key => $val) {
			$query .= sprintf(' `%1$s` = "%2$s",', $this->db->escape_string($key), $this->db->escape_string($val));
		}

		//Trim any extra comma
		$query = rtrim($query, ',');

		if(!is_null($where)) {
			$query .= ' WHERE 1 ';
			foreach($where as $key => $val) {
				$query .= sprintf('AND `%1$s` = "%2$s"', $this->db->escape_string($key), $this->db->escape_string($val));
			}			
		}

		return $query . ';';
	}
}

?>
