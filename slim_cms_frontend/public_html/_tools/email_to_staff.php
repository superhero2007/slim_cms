<?php
//Takes information from the assessment engine and emails to a person with the question and answers for 1 question.

@include('../../config.php');
ini_set('display_errors',1);
ini_set('error_reporting',E_ALL);

$db = new mysqli(DB_HOST,DB_USER,DB_PASS);

$data = json_decode($_REQUEST['data']);

$emailToStaff = new emailToStaff($db);
$emailToStaff->send($data->sender, $data->recipient, $data->question_id);

echo "finished";
$db->close();
?>