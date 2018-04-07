<?php
//Script to export and combine multiple checklists into one new checklist
//Please make sure that there is already a checklist created and use the id below

require_once('../../../config.php');
$db;
$db = new mysqli(DB_HOST,DB_USER,DB_PASS);
$db->autocommit(MYSQL_AUTOCOMMIT);

$checklistIdsToDuplicate = "1,25,35";
$newChecklistId = 49;

$at = new assessmentTools($db);
$at->duplicateMultipleAssessments($checklistIdsToDuplicate,$newChecklistId);
?>
