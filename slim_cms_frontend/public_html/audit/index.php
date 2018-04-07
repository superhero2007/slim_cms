<?php
/*
File: index.php
This is the first file in the audit system. This file specifies the navigation structure of the admin system and links to all of the audit functions.
*/

//Get the site config
require_once('../../config.php');

//Get a reference to the audit class
$audit = new audit();

//Construct the audit system page header and call stylesheet/javascript links
//print '<'.'?xml version="1.0" encoding="UTF-8"?'.'>';
?>
<!DOCTYPE frameset PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html lang="en" xml:lang="en">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>GreenBizCheck Auditing System</title>

		<!-- //CSS -->
		<link type="text/css" href="/audit/css/style.css" rel="stylesheet" />
		<!-- //JS -->
		<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

	</head>
	<body>
	
	<!-- //Render the Navigation Bar -->
	<!-- //All navigation elements go in here -->
	<div id="navigation_bar">
	
		<!-- //Call stamp to dislplay in the audit area from the stamp generator -->
		<p align="center"><img src="http://www.greenbizcheck.com/stamp/?s=greenbizcheck&w=150" alt="GreenBizCheck Auditing" /></p>
		
		<!-- //Unordered list that has all of the admin system vertical navigation elements -->
		<ul class="admin_nav">
			<li><a href="index.php?">Home</a></li>
			<li><a href="index.php?page=audit">Audit</a></li>
			<li>
			<ul>
				<li><a href="index.php?page=audit&amp;mode=incomplete">Incomplete Audits</a></li>
				<li><a href="index.php?page=audit&amp;mode=complete">Complete Audits</a></li>
			</ul>
			</li>
		</ul>
	</div>
	
	<!-- //Render the top bar -->
	<div id="top_bar">
		<div id="welcome">Hi, <?php echo $audit->user->firstname; ?> | <a href="index.php?action=logout">Log Out</a></div>
	</div>
	
	<!-- //Render the main content -->
	<div id="content">
		<?php
			require_once('../../config.php');
			$auditContent = new auditContent();
			$auditContent->loadXSL(PATH_SYSTEM.'/audit/shell.xsl');
			$auditContent->loadContent(PATH_SYSTEM.'/audit');
			if(isset($_REQUEST['debug'])) {
				$auditContent->debug();
			} else {
				$auditContent->render();
			}
		?>
	</div>
	</body>

	<!-- //JS -->
	<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/TableDnD/1.0.3/jquery.tablednd.min.js"></script>
</html>