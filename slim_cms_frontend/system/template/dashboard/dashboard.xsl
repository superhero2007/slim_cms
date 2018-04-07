<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="utf-8" indent="yes" />
		
	<xsl:param name="root" select="/" />
	<xsl:param name="root_path">
		<xsl:for-each select="/config/breadcrumb/navigation_id">
			<xsl:value-of select="concat(/config/navigation//item[@navigation_id = current()/.]/@path,'/')" />
		</xsl:for-each>
	</xsl:param>

	<xsl:variable name="app-version" select="'1.1.11'" />

	<xsl:param name="current-path">
		<xsl:value-of select="'home'" />
		<xsl:for-each select="/config/breadcrumb/navigation_id">
			<xsl:if test="position() &gt; 1">
				<xsl:value-of select="concat('-',/config/navigation//item[@navigation_id = current()/.]/@path)" />
			</xsl:if>
		</xsl:for-each>
	</xsl:param>

	<xsl:template match="/">

		<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
		<html lang="en-au">
			<head>
				<meta charset="utf-8" />
				<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
				<meta name="robots" content="index, follow" />

				<!-- //Call the page title -->
				<xsl:call-template name="page-title" />

				<!-- Favicon -->
				<xsl:if test="/config/domain/@favicon != ''">
					<link href="{/config/domain/@favicon}" rel="icon" type="image/png" />
				</xsl:if>

				<!-- //Load CSS -->
				<link rel="stylesheet" href="/css/dashboard.min.css?version={$app-version}" />
				
				<!-- //Load CSS Override -->
				<xsl:if test="/config/domain/@css_override != ''">
					<link rel="stylesheet" href="{/config/domain/@css_override}" type="text/css" />
				</xsl:if>
			</head>

			<!--<body class="dashboard-body layout-fixed aside-collapsed-text aside-collapsed"> -->
			<body class="dashboard-body">
				<div class="wrapper" id="app">
					<xsl:choose>
						<xsl:when test="/config/plugin[@plugin = 'clients'][@method = 'login']/client/dashboard">
							<xsl:call-template name="dashboard-content" /> 
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="dashboard-login" /> 
						</xsl:otherwise>
					</xsl:choose>
				</div>
				<script src="/js/dashboard.min.js?version={$app-version}"></script>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="dashboard-login">

		<div class="block-center mt-xl wd-xl">
			<!-- START panel-->
			<div class="panel panel-dark panel-flat login-panel">
			    <div class="panel-heading text-center">
			    	<xsl:value-of select="/config/domain/@site_name" /> Dashboard
			    </div>
			    <div class="panel-body">
			       <p class="text-center pv">Log into your account</p>
			       <xsl:apply-templates select="/config/plugin[@plugin = 'content']" mode="master" />
			    </div>
			</div>

			<!-- //Error messages -->
			<xsl:if test="/config/globals/item[@key = 'login-error'] or /config/plugin[@plugin = 'clients'][@method = 'login']/error">
				<div class="alert alert-danger login-error">
					<span>Incorrect username or password.</span>
				</div>
			</xsl:if>

			<!-- //Display any logout/lockout messages -->
			<xsl:if test="/config/globals/item[@key = 'logout']">
				<div class="alert alert-danger login-error">
					<xsl:choose>
						<xsl:when test="/config/globals/item[@key = 'logout'][@value = 'session']">
							<span>Your session has been logged out because this account has logged on from another location.</span>
						</xsl:when>
						<xsl:when test="/config/globals/item[@key = 'logout'][@value = 'login-fail']">
							<span>This account has been locked due to multiple failed login attempts. Please try again later.</span>
						</xsl:when>
						<xsl:when test="/config/globals/item[@key = 'logout'][@value = 'locked']">
							<span>This account has been locked. Please try again later.</span>
						</xsl:when>
					</xsl:choose>
				</div>
			</xsl:if>

		</div>
	</xsl:template>

	<xsl:template name="dashboard-content">
		<!-- //Header -->
		<xsl:call-template name="header" />
		
			
		<xsl:call-template name="navigation-bar" />

		<!-- Main section-->
		<section>
		 <!-- Page content-->
		 <div class="content-wrapper body-content">
		    <h3>
				<xsl:call-template name="page-name" />
				<xsl:call-template name="breadcrumb" />
		    </h3>
		    <div class="row">
		       <div class="col-lg-12">
					<!-- //Get the content from the GBC System -->
					<xsl:call-template name="report-messages" />
					<xsl:apply-templates select="/config/plugin[@plugin = 'content']" mode="master" />
		       </div>
		    </div>
		 </div>
		</section>


		<!-- //Footer -->
		<xsl:call-template name="footer" />

		<!-- //Post Data Settings -->
		<div class="jsonData" data-result-filter="{/config/plugin[@plugin='dashboardContent']/postData/@result_filter}" />
		<div class="jsonData" data-filter-permalink="{/config/plugin[@plugin='dashboardContent']/filterPermalink/@link}" />
	</xsl:template>

	<xsl:template name="report-messages">
		
		<!-- //Errors -->
		<xsl:if test="count(/config/message[@type = 'error']) &gt; 0">
			<div class="alert alert-danger">
				<ul>
					<xsl:for-each select="/config/message[@type = 'error']">
						<li><xsl:value-of select="@message" /></li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>

		<!-- //Warning -->
		<xsl:if test="count(/config/message[@type = 'warning']) &gt; 0">
			<div class="alert alert-warning">
				<ul>
					<xsl:for-each select="/config/message[@type = 'warning']">
						<li><xsl:value-of select="@message" /></li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>

		<!-- //Success -->
		<xsl:if test="count(/config/message[@type = 'success']) &gt; 0">
			<div class="message-container hidden">
				<xsl:for-each select="/config/message[@type = 'success']">
					<div class="notify-message" data-type="{@type}" data-key="{@key}" data-message="{@message}" />
				</xsl:for-each>
			</div>
		</xsl:if>

	</xsl:template>

	<xsl:template name="navigation-bar">
     <!-- sidebar-->
      <aside class="aside">
         <!-- START Sidebar (left)-->
         <div class="aside-inner">
            <nav data-sidebar-anyclick-close="" class="sidebar">
               <!-- START sidebar nav-->
               <ul class="nav">

           			<!-- //Loop Navigation Items -->
					<xsl:apply-templates select="/config/menuItems/menuItem" />

               </ul>
               <!-- END sidebar nav-->
            </nav>
         </div>
         <!-- END Sidebar (left)-->
      </aside>
	</xsl:template>	
	
	<xsl:template name="header">

     <!-- top navbar-->
      <header class="topnavbar-wrapper">
         <!-- START Top Navbar-->
         <nav role="navigation" class="navbar topnavbar">
            <!-- START navbar header-->
            <div class="navbar-header">
               <a href="#" class="navbar-brand">
                  <div class="brand-logo">
                  	<xsl:choose>
	              		<xsl:when test="/config/domain/@site_image_alt != ''">
	                 		<img src="{/config/domain/@site_image_alt}" alt="{concat(/config/domain/@site_name, ' Dashboard')}" class="img-responsive" />
	                 	</xsl:when>
	              		<xsl:when test="/config/domain/@site_image != ''">
	                 		<img src="{/config/domain/@site_image}" alt="{concat(/config/domain/@site_name, ' Dashboard')}" class="img-responsive" />
	                 	</xsl:when>
                	</xsl:choose>
                  </div>
                  <div class="brand-logo-collapsed">
              		<xsl:if test="/config/domain/@icon != ''">
                 		<img src="{/config/domain/@icon}" alt="{concat(/config/domain/@site_name, ' Dashboard')}" class="img-responsive" />
                 	</xsl:if>
                  </div>
               </a>
            </div>
            <!-- END navbar header-->
            <!-- START Nav wrapper-->
            <div class="nav-wrapper">
               <!-- START Left navbar-->
               <ul class="nav navbar-nav">
                  <li>

                     <!-- Button used to collapse the left sidebar. Only visible on tablet and desktops-->
                     <a href="#" data-toggle-state="aside-collapsed" class="hidden-xs">
                        <em class="fa fa-navicon"></em>
                     </a>
                     <!-- Button to show/hide the sidebar on mobile. Visible on mobile only.-->
                     <a href="#" data-toggle-state="aside-toggled" data-no-persist="true" class="visible-xs sidebar-toggle">
                        <em class="fa fa-navicon"></em>
                     </a>
                  </li>
               </ul>
               <!-- END Left navbar-->
               <!-- START Right Navbar-->
               <ul class="nav navbar-nav navbar-right">

               	<li>
               		<a class="user-welcome">
               			Welcome back, <xsl:value-of select="concat(/config/plugin[@plugin = 'clients'][@method = 'login']/client/contact/@firstname, ' ', /config/plugin[@plugin = 'clients'][@method = 'login']/client/contact/@lastname)" />
               		</a>
               	</li>

                  <li>
                     <a href="/" title="Home">
                        <em class="fa fa-home"></em>
                     </a>
                  </li>
				  <li>
                     <a href="/members/" title="My Account &amp; Entries">
                        <em class="fa fa-user"></em>
                     </a>
				  </li>
                  <li>
                     <a href="/members/dashboard/?action=logout" title="Log Out">
                        <em class="fa fa-lock"></em>
                     </a>
                  </li>
                  <!-- END lock screen-->

               </ul>
               <!-- END Right Navbar-->
            </div>
            <!-- END Nav wrapper-->
         </nav>
         <!-- END Top Navbar-->
      </header>

	</xsl:template>
	
	<!-- //Footer Template -->
	<xsl:template name="footer">
		<footer>
			<p>
				<span class="hidden-phone" style="text-align:right;float:right">
					<a href="https://www.greenbizcheck.com" target="_blank">Powered by GreenBizCheck</a>
				</span>
			</p>
		</footer>
	</xsl:template>

	
	<!-- //Drop Down menu Template -->
	<xsl:template match="menuItem">

		<xsl:variable name="scope" select="'3'" />

		<xsl:if test="@scope_id = $scope">
			<li>
				<a href="{@href}" title="{@label}">
					<xsl:if test="@icon != ''">
						<em class="{@icon}"></em>
					</xsl:if>
					<span><xsl:value-of select="@label" disable-output-escaping="yes" /></span>
				</a>
				<!-- //Test for children -->
				<xsl:if test="menuItem">
					<ul class="nav sidebar-subnav">
						<xsl:apply-templates select="menuItem" />
					</ul>
				</xsl:if>
			</li>
		</xsl:if>
	
	</xsl:template>

	
	<!-- //Page Title Template -->
	<xsl:template name="page-title">
	
		<xsl:choose>
			<xsl:when test="/config/navigation//item[@navigation_id = /config/breadcrumb/navigation_id[last()]]/@meta-title !='' ">
				<title>
					<xsl:value-of select="/config/navigation//item[@navigation_id = /config/breadcrumb/navigation_id[last()]]/@meta-title" />
					<xsl:if test="/config/domain/@site_name != ''"> | <xsl:value-of select="/config/domain/@site_name" /></xsl:if>
				</title>
			</xsl:when>
			<xsl:otherwise>
				<title>
					<xsl:apply-templates select="/config/navigation//item[@navigation_id = /config/breadcrumb/navigation_id[last()]]" mode="title" />
					<xsl:if test="/config/domain/@site_name != ''"> | <xsl:value-of select="/config/domain/@site_name" /></xsl:if>
				</title>
			</xsl:otherwise>
		</xsl:choose>
	
	</xsl:template>

	<!-- //Page Name Template -->
	<xsl:template name="page-name">
	
		<xsl:choose>
			<xsl:when test="/config/navigation//item[@navigation_id = /config/breadcrumb/navigation_id[last()]]/@meta-title !='' ">
				<xsl:value-of select="/config/navigation//item[@navigation_id = /config/breadcrumb/navigation_id[last()]]/@meta-title" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="/config/navigation//item[@navigation_id = /config/breadcrumb/navigation_id[last()]]" mode="title" />
			</xsl:otherwise>
		</xsl:choose>
	
	</xsl:template>
	
	<!-- //Breadcrumb bar template -->
	<xsl:template name="breadcrumb">
		<xsl:variable name="scope" select="'3'" />

		<ul class="breadcrumb">

			<xsl:for-each select="/config/breadcrumb/navigation_id">
				<xsl:variable name="current_navigation_id" select="." />

				<xsl:if test="/config/navigation//item[@navigation_id = $current_navigation_id]/@scope_id = $scope">

					<!-- //Check for the last node, if so, use the pathSet node instead to pick up path based variables -->
					<xsl:variable name="url_path" select="/config/navigation//item[@navigation_id = $current_navigation_id]/ancestor-or-self::item" />
					<xsl:variable name="path">
						<xsl:choose>
							<xsl:when test="position() = last()">
								<xsl:value-of select="/config/domain/@requested_url" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="$url_path">
									<xsl:value-of select="@path" /><xsl:text>/</xsl:text>
								</xsl:for-each>
							</xsl:otherwise>	
						</xsl:choose>
					</xsl:variable>

					<!--//Get the parent navigation_id of the current node, if it is not in the same scope, this is the parent of the current scope -->
					<xsl:variable name="parent_id" select="/config/navigation//item[@navigation_id = $current_navigation_id]/@parent_id" />

					<li>
						<a>
							<xsl:attribute name="href">
								<xsl:value-of select="$path" />
							</xsl:attribute>
							<xsl:if test="position() = last()">
								<xsl:attribute name="class">active</xsl:attribute>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="/config/navigation//item[@navigation_id = current()]/@label != ''">
									<xsl:value-of select="/config/navigation//item[@navigation_id = current()]/@label" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="/config/navigation//item[@navigation_id = current()]/@title" />
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</li>
				</xsl:if>
			</xsl:for-each>

		</ul>
	</xsl:template>
	
	<!-- //Site Image Template -->
	<xsl:template name="site-image">
		<xsl:if test="/config/domain/@site_image != ''">
			<a class="navbar-brand" href="/" title="{/config/domain/@site_name}">
				<img src="{/config/domain/@site_image}" alt="{/config/domain/@site_name}" class="header-image" />
			</a>
		</xsl:if>
	</xsl:template>
	
	<!-- //Required Templates -->
	<xsl:template match="item" mode="title">
		<xsl:value-of select="@title" />
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'content']" mode="master">
		<xsl:apply-templates select="content/*" mode="html" />
	</xsl:template>
	
	<xsl:template match="*" mode="html">
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="@*" />
			<xsl:apply-templates mode="html" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="a[@xpath]" mode="html">
		<a>
			<xsl:copy-of select="@*[name() != 'xpath']" />
			<xsl:attribute name="href">
				<xsl:value-of select="dyn:evaluate(@xpath)" />
			</xsl:attribute>
			<xsl:apply-templates mode="html" />
		</a>
	</xsl:template>
	
	<xsl:template match="plugin" mode="html">
		<xsl:choose>
			<xsl:when test="@mode">
				<xsl:apply-templates select="/config/plugin[@plugin = current()/@name][@method = current()/@method][@mode = current()/@mode]" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="/config/plugin[@plugin = current()/@name][@method = current()/@method]" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="subnav" mode="html">
		<xsl:variable name="sortOrder">
			<xsl:choose>
				<xsl:when test="@sort-order">
					<xsl:value-of select="@sort-order" />
				</xsl:when>
				<xsl:otherwise>ascending</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="navigation_id">
			<xsl:choose>
				<xsl:when test="@navigation_id"><xsl:value-of select="@navigation_id" /></xsl:when>
				<xsl:otherwise><xsl:value-of select="/config/breadcrumb/navigation_id[last()]" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="url_path" select="/config/navigation//item[@navigation_id = $navigation_id]/ancestor-or-self::item" />
		<ul id="search_results" class="link-list">
			<xsl:for-each select="/config/navigation//item[@parent_id = $navigation_id]">
			<xsl:sort data-type="number" select="@sequence" order="{$sortOrder}" />
			<xsl:variable name="search_url_path" select="/config/navigation//item[@navigation_id = current()/@navigation_id]/ancestor-or-self::item" />
				<li>
					<i class="fa fa-external-link gbc-core"></i>
					<a>
						<xsl:attribute name="href">
							<xsl:for-each select="$url_path">
								<xsl:value-of select="@path" /><xsl:text>/</xsl:text>
							</xsl:for-each>
							<xsl:value-of select="@path" /><xsl:text>/</xsl:text>
						</xsl:attribute>
						<xsl:value-of select="@title" />
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>
	
</xsl:stylesheet>