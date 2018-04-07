<?php
/*
File: index.php
This is the first file in the admin system. This file specifies the navigation structure of the admin system and links to all of the admin functions.
*/

//Get the site config
require_once('../../config.php');

$adminContent = new adminContent();
$adminContent->loadXSL(PATH_SYSTEM.'/admin/shell.xsl');
$adminContent->loadContent(PATH_SYSTEM.'/admin');

if((isset($_REQUEST['debug'])) && (SERVER_ENV == 'local')) {
	$adminContent->debug();
} else {
			
//Get a reference to the admin class
$admin = new admin();

//Construct the admin system page header and call stylesheet/javascript links
print '<'.'?xml version="1.0" encoding="UTF-8"?'.'>';
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title><?php echo ADMIN_TEMPLATE; ?> Administration</title>

		<!-- //CSS -->
		<link type="text/css" href="/admin/css/style.css" rel="stylesheet" />
		<link type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.16/css/jquery.dataTables.css" rel="stylesheet" />
	
		<!-- //JS -->
		<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	
	</head>
	
	<body>
	
		<!-- //Render the Navigation Bar -->
		<div id="account_bar">
			<div class="site-image">
				<?php 
					switch(ADMIN_TEMPLATE) {
													
						case 'EcoBizCheck':			echo " <img src=\"http://www.greenbizcheck.com/stamp?s=ecobizcheck&amp;h=25\" />";
													break;
										
						default:					echo " <img src=\"http://www.greenbizcheck.com/stamp?s=greenbizcheck&amp;h=25\" />";
													break;
					}
				?>
				
			</div>
			<div class="site-name">
				<?php echo ADMIN_TEMPLATE; ?> Administration
				<?php
					if($_SERVER['SERVER_ADDR'] == '127.0.0.1') {
						print " - Local Server";
					} else {
						print " - Live Server";
					}
				?>
			</div>
			<div id="welcome">Hi, <?php echo $adminContent->user->firstname; ?> | <a href="index.php?action=logout">Log Out</a></div>
		</div>
	
		<div class="nav-content-wrap">
			<!-- //All navigation elements go in here -->
			<div id="navigation_bar">
		
				<!-- //Unordered list that has all of the admin system vertical navigation elements -->
				<ul class="admin_nav">
					<li><a href="index.php">Home</a></li>
					<li>
						<a href="index.php?page=clients">Account Management</a>
						<ul>
							<li><a href="index.php?page=clients&amp;mode=client_edit">Add Account</a></li>
							<li><a href="index.php?page=invoices&amp;mode=outstanding-invoices">Invoices</a></li>
						</ul>
					</li>
					<li>
						<a href="index.php?page=checklists">Assessment Maintenance</a>
						<ul>
							<li><a href="index.php?page=checklists&amp;mode=variation_list">Variations</a></li>
						</ul>
					</li>
					<li>
						<a href="index.php?page=domain">Domain</a>
					</li>
					<li>
						<a href="index.php?page=navigation&amp;domain_id=1">Site Content</a>
						<ul>
							<li><a href="index.php?page=navigation&amp;mode=menu_item_list&amp;domain_id=1">Menu Items</a></li>
						</ul>
					</li>
					<li><a href="index.php?page=triggers">Followup Triggers</a></li>
					<li>
						<a href="index.php?page=scripts">Admin Scripts</a>
					</li>
					<li>
						<a href="index.php?page=api">API</a>
					</li>
				</ul>
			</div>
	
			<!-- //Render the main content -->
			<div id="admin-content">
				<?php
					$adminContent->render();
				?>
			</div>
		</div>
	</body>

	<!-- //JS -->
	<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/PapaParse/4.3.6/papaparse.js"></script>
	<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/TableDnD/1.0.3/jquery.tablednd.min.js"></script>
	<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.16/js/jquery.dataTables.min.js"></script>

	<script type="text/javascript" src="/admin/js/scripts.js"></script>
	<script type="text/javascript" src="/admin/scripts/jsSHA-2.0.2/src/sha256.js"></script>
	<script type="text/javascript" src="/admin/js/greenbizcheck.api.js"></script>
	<script type="text/javascript" src="/admin/js/admin.js"></script>
	
</html>
<?php } ?>