<?php

//Get the hash
foreach($_REQUEST as $key=>$val) {
    if(in_array($key,['hash','filename','file-name'])) {
        $hash = $val;
        break;
    }
}

//No hash
if(!isset($hash)) {
    header("HTTP/1.0 404 Not Found");
    die();
}

//config & database
include('../../config.php');
$db = new mysqli(DB_HOST,DB_USER,DB_PASS);
$db->autocommit(MYSQL_AUTOCOMMIT);

$file = new fileDownload($db);
$file->getFile($hash);

return;

?>