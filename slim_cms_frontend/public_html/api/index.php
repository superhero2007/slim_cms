<?php

//Get access to the config file
require('../../config.php');

//Call the core
$core = new core();

//Call the API
$api = new api($GLOBALS['core']->db);

?>