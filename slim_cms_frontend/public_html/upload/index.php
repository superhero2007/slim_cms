<?php

//Include the config for GBC
include('../../config.php');

//Get a connection to the database
$db = new mysqli(DB_HOST,DB_USER,DB_PASS);
$db->autocommit(MYSQL_AUTOCOMMIT);
$file = new fileUpload($db);

return;

?>