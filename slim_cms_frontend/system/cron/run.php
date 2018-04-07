<?php
$path = realpath(dirname(__FILE__));
require_once($path.'/../../config.php');
$db = new mysqli(DB_HOST,DB_USER,DB_PASS);
if(isset($argv[1]) && is_file($path.'/'.$argv[1])) {
	require_once($path.'/'.$argv[1]);
}
$db->close();
?>