<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="utf-8" indent="yes" />
		
	<xsl:param name="root" select="/" />
	<xsl:param name="root_path">
		<xsl:for-each select="/config/breadcrumb/navigation_id">
			<xsl:value-of select="concat(/config/navigation//item[@navigation_id = current()/.]/@path,'/')" />
		</xsl:for-each>
	</xsl:param>

	<xsl:variable name="app-version" select="'1.1.23'" />

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
				<link rel="stylesheet" href="/css/app.min.css?version={$app-version}" />

				<!-- Load CSS Overide -->
				<xsl:if test="/config/domain/@css_override != ''">
					<link rel="stylesheet" href="{/config/domain/@css_override}" type="text/css" />
				</xsl:if>
			</head>

			<body class="{$current-path}">
			
				<!-- //MAIN WRAPPER -->
				<div class="body-wrap">
			
					<!-- //Header -->
					<xsl:call-template name="header" />
					
					<!-- //Breadcrumb -->
					<xsl:call-template name="breadcrumb" />
					
					<!-- //Page Content -->
					<!-- //Check to see if the content contains the section tag, if not, apply a default section -->
					<div class="body-content">
						<xsl:choose>
							<!-- //David Jones -->
							<xsl:when test="/config/domain/@domain_id = '97'">
								<xsl:apply-templates select="/config/plugin[@plugin = 'content']" mode="master" />
							</xsl:when>
							<xsl:when test="count(/config/plugin[@plugin = 'content']/content/section) &gt; 0">
								<xsl:apply-templates select="/config/plugin[@plugin = 'content']" mode="master" />
							</xsl:when>
							<xsl:otherwise>
								<section class="slice white">
									<div class="container">
										<xsl:apply-templates select="/config/plugin[@plugin = 'content']" mode="master" />
									</div>
								</section>
							</xsl:otherwise>
						</xsl:choose>
					</div>
					<xsl:call-template name="footer" />

				</div>
				<!-- //Load JS including any from the database -->
				<script src="https://www.google.com/recaptcha/api.js"></script>
				<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBFSLXw2chw2pxhmwr-BaFWakRwxs2LXLo"></script>
				<script src="/js/app.min.js?version={$app-version}"></script>
				<xsl:apply-templates select="/config/domain/footer_scripts/*" mode="html" />
			</body>
		</html>

	</xsl:template>
	
	<xsl:template name="header">
        <!-- HEADER -->
        <div id="divHeaderWrapper">
            <header class="header-standard-2">     
				<!-- MAIN NAV -->
				<div class="navbar navbar-wp navbar-arrow mega-nav" role="navigation">
					<div class="container">
						<div class="navbar-header">

							<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
								<i class="fa fa-bars icon-custom"></i>
							</button>

							<!-- //Call the site image tempalte -->
							<xsl:call-template name="site-image" />
							
						</div>
						<div class="navbar-collapse collapse">
							<ul class="nav navbar-nav navbar-right">

								<!-- //Apply the drop down nav -->
								<xsl:apply-templates select="/config/menuItems/menuItem" />
							</ul>
			   
						</div><!--/.nav-collapse -->
					</div>
				</div>
			</header>        
		</div>
	</xsl:template>
	
	<!-- //Footer Template -->
	<xsl:template name="footer">

		<footer class="footer">
			<span class="footer-top" />
			<div class="container">
			
				<!-- //Custom Footer Content from Database -->
				<xsl:apply-templates select="/config/domain/footer_content/*" mode="html" />
				
			</div>
		</footer>
	</xsl:template>
	
	<!-- //Drop Down menu Template -->
	<xsl:template match="menuItem">
		<xsl:variable name="scope" select="'1'" />
	
		<xsl:if test="@scope_id = $scope">
			<li>
				<!-- //Test for parent nav level -->
				<xsl:if test="count(menuItem[@parent_id = current()/@menu_item_id]) > 0">
					<xsl:attribute name="class">dropdown</xsl:attribute>
				</xsl:if>
				<a href="{@href}">
					<xsl:if test="count(menuItem[@parent_id = current()/@menu_item_id]) > 0">
						<xsl:attribute name="class">dropdown-toggle</xsl:attribute>
						<xsl:attribute name="data-toggle">dropdown</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="@label" disable-output-escaping="yes" />
				</a>
				
				<!-- //Test for children -->
				<xsl:if test="menuItem">
					<ul class="dropdown-menu">
						<xsl:apply-templates select="menuItem" />
					</ul>
				</xsl:if>
			</li>
		</xsl:if>
	
	</xsl:template>
	
	<!-- //Slide Out Responsive Menu Template -->
	<xsl:template name="slide-out-menu">
		<!-- SLIDEBAR -->
		<section id="asideMenu" class="aside-menu right">
			<form class="form-horizontal form-search">
				<div class="input-group">
					<input type="search" class="form-control core site-search" placeholder="Search..." />
					<span class="input-group-btn">
						<button id="btnHideAsideMenu" class="btn btn-close" type="button" title="Hide sidebar"><i class="fa fa-times"></i></button>
					</span>
				</div>
			</form>
	
			<h5 class="side-section-title">Page Menu</h5>

			<!-- Call slide out nav -->
			<div class="nav slide-out-nav">
				<ul>
					<!-- //Apply the nav items -->
					<xsl:apply-templates select="/config/menuItems/menuItem" />
				</ul>
			</div>
		</section>
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
	
	<!-- //Breadcrumb bar template -->
	<xsl:template name="breadcrumb">
	
		<!-- //Only render on pages that aren't home pages -->
		<xsl:if test="count(/config/breadcrumb/navigation_id) &gt; '1'">
			<div class="pg-opt">
				<div class="container">
					<div class="row">
						<div class="col-md-6 page-title">
							<!-- //Page Title -->
							<h2>
								<xsl:value-of select="/config/navigation//item[@navigation_id = /config/breadcrumb/navigation_id[last()]]/@title" />
							</h2>
						</div>
						<div class="col-md-6 breadcrumbs">
							<ol class="breadcrumb">
								<!-- //Do the home page separate to the loop -->
								<li>
									<a href="/">Home</a>
								</li>
								<xsl:for-each select="/config/breadcrumb/navigation_id">
									<xsl:if test="position() != '1'">
										<xsl:variable name="current_navigation_id" select="." />

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
							</ol>
						</div>
					</div>
				</div>
			</div>
		</xsl:if>
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
	
	<!-- //Site Image Template -->
	<xsl:template name="site-image">
		<xsl:if test="/config/domain/@site_image != ''">
			<a class="navbar-brand" href="/" title="{/config/domain/@site_name}">
				<img src="{/config/domain/@site_image}" alt="{/config/domain/@site_name}" class="header-image" />
			</a>
		</xsl:if>
	</xsl:template>

	<!-- //Shopping Cart Pop Up Template -->
	<xsl:template name="shopping-cart-pop-up">
		<xsl:if test="count(/config/plugin[@plugin='pos'][@method='getCart']/item) &gt; 0">
			<a href="/cart/" id="toCart" style="display: inline;">
				<span id="toCartHover"></span></a>
				<div class="shopping-cart-count label label-danger">
					<xsl:value-of select="sum(/config/plugin[@plugin='pos'][@method='getCart']/item/@quantity)" />
				</div>
		</xsl:if>
	</xsl:template>
	
	<!-- //Required Templates -->
	<xsl:template match="item" mode="title">
		<xsl:value-of select="@title" />
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'content']" mode="master">
		<xsl:call-template name="report-messages" />
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
			<xsl:when test="@call">
				<xsl:apply-templates select="/config/plugin[@plugin = current()/@name][@method = current()/@method][@mode = current()/@call]" />
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