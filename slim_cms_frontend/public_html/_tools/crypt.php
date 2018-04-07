<?php
@include('../../config.php');
header("Content-type: text/plain");
print_r($_GET);
print crypt::encrypt(serialize($_GET));
?>