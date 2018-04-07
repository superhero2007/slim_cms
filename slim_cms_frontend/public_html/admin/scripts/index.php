<?php
@include('../../../config.php');
$adminContent = new adminContent();
$adminContent->loadXSL(PATH_SYSTEM.'/admin/shell.xsl');
$adminContent->loadContent(PATH_SYSTEM.'/admin');
?>