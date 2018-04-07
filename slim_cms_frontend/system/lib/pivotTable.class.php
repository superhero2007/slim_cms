<?php
class pivotTable {

	/*
	*		pivotTable class takes mySql data sources along with multiple arguments to 
	*		create a pivot table and return as a single PHP array
	*/


	private $db;
	private $pivotPoint;
	private $pivotData;
	private $pivotArray;
	
	public function __construct($db) {
		$this->db = $db;
		$this->pivotArray = new stdClass();
	}
	
	//The main function
	public function getPivotTable($pivotData, $pivotPoint) {
		//Override the default memory limit
		ini_set('memory_limit', '-1');
		ini_set('max_execution_time', 0);
		
		//Set the values
		$this->pivotData = $pivotData;
		
		//Should be passed as $pivotPoint->key, $pivotPoint->value
		//key is the header column, value is the data
		$this->pivotPoint = $pivotPoint;
	
		//Call the fuction to generate the pivot Table;
		$data = array();
		$data = $this->createPivotTable();	
	
		return $data;
		exit;
	}
	
	private function createPivotTable() {
	
		//Create a new array for the left side and also the right side
		$leftArray = $this->getPivotArrayLeftSide($this->pivotData);
		$rightArray = $this->getPivotArrayRightSide($this->pivotData);
		$this->pivotArray = $this->joinArraySides($leftArray, $rightArray);
		
		return $this->pivotArray;
	}
	
	private function joinArraySides($leftSide, $rightSide) {
		$pivotArray = array();
		$rowKey = null;
		
		//Get the rowKey
		foreach($leftSide as $key=>$val) {
			$rowKey = $key;
			
			//Add the left side keys and vals to the pivotArray
			foreach($val as $key=>$val) {
				$pivotArray[$rowKey][$key] = $val;
			}
			
			//Now add the right side to the pivotArray
			foreach($rightSide as $rightRow) {
				foreach($rightRow as $key=>$val) {
					if($key == $rowKey) {
						foreach($val as $key=>$val) {
							$pivotArray[$rowKey][$key] = $val;
						}
					}
				}
			}
		}
	
		return $pivotArray;
	}
	
	private function getPivotArrayLeftSide($data) {
		$filteredArray = array();
		$rightSideKeys = $this->getRightSideColumns();
		
		foreach($data as $row) {
			$rowKey = $this->getRowKey($row);
			
			foreach($row as $key=>$val) {
				if( (!in_array($key,$rightSideKeys)) && (!in_array($val, $rightSideKeys)) ){
					$filteredArray[$rowKey][$key] = $val;
				}
			}
		}
	
		return $filteredArray;
	}
	
	private function getPivotArrayRightSide($data) {
		$filteredArray = array();
		$rightSideKeys = $this->getRightSideColumns();
		$values = array();
		
		foreach($data as $row) {
			$rowKey = $this->getRowKey($row);
			
			foreach($row as $key=>$val) {
				$values[$key] = $val;
			}
			
			foreach($this->pivotPoint->column as $column) {
				foreach($column as $key=>$val) {
					$filteredArray[][$rowKey][$values[$key]] = $values[$val];
				}
			}
		}
	
		return $filteredArray;
	}	
	
	private function getRowKey($row) {
		$rowKey = null;
		
		foreach($row as $key=>$val) {
			if($key == $this->pivotPoint->point) {
				$rowKey = $val;
			}
		}
		
		return $rowKey;
	}
	
	private function getRightSideColumns() {
		$rightSideKeys = array();
		
		foreach($this->pivotPoint->column as $col) {
			foreach($col as $key=>$val) {
				$rightSideKeys[] = $key;
				$rightSideKeys[] = $val;
			}
		}
		
		return $rightSideKeys;
	}

}
?>