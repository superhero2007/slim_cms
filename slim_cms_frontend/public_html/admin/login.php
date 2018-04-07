<?php
/*
File: login.php
This file is the first page in the Control Panel admin section
The Control Panel assessment engine piggy-backs off the GBC system and displays a simplified user interface for clients
*/

//Get the global configuration file
require_once('../../config.php');

//Construct the admin system page header and call stylesheet/javascript links
print '<'.'?xml version="1.0" encoding="UTF-8"?'.'>';
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
	
	<!-- start: Meta -->
	<meta charset="utf-8">
	<title><?php echo ADMIN_TEMPLATE; ?> Administration</title>
	<meta name="description" content="Metro Admin Template.">
	<meta name="author" content="Łukasz Holeczek">
	<meta name="keyword" content="Metro, Metro UI, Dashboard, Bootstrap, Admin, Template, Theme, Responsive, Fluid, Retina">
	<!-- end: Meta -->
	
	<!-- start: Mobile Specific -->
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<!-- end: Mobile Specific -->
	
	<!-- start: CSS -->
	<link id="bootstrap-style" href="/themes/metro/css/bootstrap.min.css" rel="stylesheet">
	<link href="/themes/metro/css/bootstrap-responsive.min.css" rel="stylesheet">
	<link id="base-style" href="/themes/metro/css/style.css" rel="stylesheet">
	<link id="base-style-responsive" href="/themes/metro/css/style-responsive.css" rel="stylesheet">
	<link href='http://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,800italic,400,300,600,700,800&subset=latin,cyrillic-ext,latin-ext' rel='stylesheet' type='text/css'>
	<!-- end: CSS -->
	

	<!-- The HTML5 shim, for IE6-8 support of HTML5 elements -->
	<!--[if lt IE 9]>
	  	<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
		<link id="ie-style" href="/themes/metro/css/ie.css" rel="stylesheet">
	<![endif]-->
	
	<!--[if IE 9]>
		<link id="ie9style" href="/themes/metro/css/ie9.css" rel="stylesheet">
	<![endif]-->
		
	<!-- start: Favicon -->
	<link rel="shortcut icon" href="/_images/favicon.ico">
	<!-- end: Favicon -->
	
 	<style type="text/css">
		body { background: url(/themes/metro/img/bg-login.jpg) !important; }
	</style>
		
		
</head>

<body>
		<div class="container-fluid-full">
		<div class="row-fluid">
					
			<div class="row-fluid">
			
				<div class="login-box">
					<div class="icons">
						<a href="index.php"><i class="halflings-icon home"></i></a>
						<!--<a href="#"><i class="halflings-icon cog"></i></a> -->
					</div>
					<h2>Login to your account</h2>
					<form class="form-horizontal" action="index.php" method="post">
						<input type="hidden" name="action" value="login" />
						<fieldset>
							
							<div class="input-prepend" title="Username">
								<span class="add-on"><i class="halflings-icon user"></i></span>
								<input class="input-large span10" name="username" id="username" type="text" placeholder="type username"/>
							</div>
							<div class="clearfix"></div>

							<div class="input-prepend" title="Password">
								<span class="add-on"><i class="halflings-icon lock"></i></span>
								<input class="input-large span10" name="password" id="password" type="password" placeholder="type password"/>
							</div>
							<div class="clearfix"></div>
							
							<label class="remember" for="remember"><input type="checkbox" id="remember" name="remember" />Remember me</label>

							<div class="button-login">	
								<button type="submit" class="btn btn-primary">Login</button>
							</div>
							<div class="clearfix"></div>
							<input type="hidden" name="action" value="login" />
					</form>
				</div><!--/span-->
				
			<!-- //Error messages -->
			<?php if(isset($_REQUEST['login-error'])) { ?>
				<div class="alert alert-error login-error">
					<span>Incorrect username or password.</span>
				</div>
			<?php } ?>
				
			</div><!--/row-->

	</div><!--/.fluid-container-->
	
		</div><!--/fluid-row-->
	
	<!-- start: JavaScript-->

		<script src="/themes/metro/js/jquery-1.9.1.min.js"></script>
		<script src="/themes/metro/js/jquery-migrate-1.0.0.min.js"></script>
	
		<script src="/themes/metro/js/jquery-ui-1.10.0.custom.min.js"></script>
	
		<script src="/themes/metro/js/jquery.ui.touch-punch.js"></script>
	
		<script src="/themes/metro/js/modernizr.js"></script>
	
		<script src="/themes/metro/js/bootstrap.min.js"></script>
	
		<script src="/themes/metro/js/jquery.cookie.js"></script>
	
		<script src='/themes/metro/js/fullcalendar.min.js'></script>
	
		<script src='/themes/metro/js/jquery.dataTables.min.js'></script>

		<script src="/themes/metro/js/excanvas.js"></script>
		<script src="/themes/metro/js/jquery.flot.js"></script>
		<script src="/themes/metro/js/jquery.flot.pie.js"></script>
		<script src="/themes/metro/js/jquery.flot.stack.js"></script>
		<script src="/themes/metro/js/jquery.flot.resize.min.js"></script>
	
		<script src="/themes/metro/js/jquery.chosen.min.js"></script>
	
		<script src="/themes/metro/js/jquery.uniform.min.js"></script>
		
		<script src="/themes/metro/js/jquery.cleditor.min.js"></script>
	
		<script src="/themes/metro/js/jquery.noty.js"></script>
	
		<script src="/themes/metro/js/jquery.elfinder.min.js"></script>
	
		<script src="/themes/metro/js/jquery.raty.min.js"></script>
	
		<script src="/themes/metro/js/jquery.iphone.toggle.js"></script>
	
		<script src="/themes/metro/js/jquery.uploadify-3.1.min.js"></script>
	
		<script src="/themes/metro/js/jquery.gritter.min.js"></script>
	
		<script src="/themes/metro/js/jquery.imagesloaded.js"></script>
	
		<script src="/themes/metro/js/jquery.masonry.min.js"></script>
	
		<script src="/themes/metro/js/jquery.knob.modified.js"></script>
	
		<script src="/themes/metro/js/jquery.sparkline.min.js"></script>
	
		<script src="/themes/metro/js/counter.js"></script>
	
		<script src="/themes/metro/js/retina.js"></script>

		<script src="/themes/metro/js/custom.js"></script>
	<!-- end: JavaScript-->
	
</body>
</html>