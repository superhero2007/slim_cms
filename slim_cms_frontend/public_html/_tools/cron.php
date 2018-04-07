<?php
@include('../../config.php');
ini_set('display_errors',1);
ini_set('error_reporting',E_ALL);
$db = new mysqli(DB_HOST,DB_USER,DB_PASS);
if(isset($_REQUEST['file']) && is_file(PATH_SYSTEM.'/cron/'.$_REQUEST['file'])) {
	require_once(PATH_SYSTEM.'/cron/'.$_REQUEST['file']);
} else {
	print "I need 'file' as a variable";
}
$db->close();
?>