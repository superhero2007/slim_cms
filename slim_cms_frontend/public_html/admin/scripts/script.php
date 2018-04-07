<?php
/*

Temporary location to run scripts

*/
@include('../../../config.php');
$adminContent = new adminContent();
$adminContent->loadXSL(PATH_SYSTEM.'/admin/shell.xsl');
$adminContent->loadContent(PATH_SYSTEM.'/admin');

header("Content-type: text/plain");
$db = new mysqli(DB_HOST,DB_USER,DB_PASS);

	 /* Testing before output can be entered here */
	
    $password = new password($db);
	$password->encryptAllAdminPasswords();
	//$password->encryptAllPasswords();
	 
	//$mcsync = new mailchimpSync($db); 
	
	//Checklist Data for Pivot Table
	//$clientChecklist = new clientChecklist($db);
	//$data = $clientChecklist->getChecklistResultsPivotTable('79');
	
	//Pivot Table Class
	//$pivotTable = new pivotTable($db);	
	//$pivotPoint = new stdClass();
	//$pivotPoint->point = "client_checklist_id";
	//$pivotPoint->column[] = array("question" => "answer");
	//$data = $pivotTable->getPivotTable($data, $pivotPoint);
	
	//CSVBuilder Class
	//$csvBuilder = new csvBuilder($db);
	//$csvBuilder->buildCSV($data, false); 
	 
	 
	 /* End of testing ouptput */

?>