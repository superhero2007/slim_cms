<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="#stylesheet"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="/config/plugin[@plugin = 'content']">
		<xsl:apply-templates select="content/*" mode="html" />
	</xsl:template>

	<!-- //Current Date AU -->
	<xsl:template match="current-date-au" mode="html">
		<xsl:value-of select="concat(/config/datetime/@day,'/',/config/datetime/@month,'/',/config/datetime/@year)" />
	</xsl:template>

	<!-- //Company Name -->
	<xsl:template match="company-name" mode="html">
		<xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" />
	</xsl:template>

	<!-- //David Jones User Menu -->
	<xsl:template match="user-menu[@app = 'david-jones']" mode="html">
        <ul class="list-inline pull-right user-menu">
            <li>
                <xsl:call-template name="home" />
            </li>
            <li>
                <xsl:call-template name="notification" />
            </li>
            <li>
                <xsl:call-template name="user" />
            </li>
        </ul>
	</xsl:template>

    <xsl:template name="home">
		<a href="/members/" class="btn btn-dark" role="button">
			<i class="fa fa-home" title="Home"></i>
		</a>
    </xsl:template>

	<xsl:template name="user">
		<div class="dropdown">
			<button class="btn btn-dark dropdown-toggle" type="button" id="user-menu-dropdown" data-toggle="dropdown" aria-haspopup="true">
				<i class="fa fa-user" title="My Account"></i>
				<xsl:call-template name="full-name" />
			</button>
			<ul class="dropdown-menu" aria-labelledby="user-menu-dropdown">
				<li class="drop-down-menu-label">User Menu</li>
				<li role="separator" class="divider"></li>
				<li><a href="/members/?action=logout">Sign Out</a></li>
			</ul>
		</div>
    </xsl:template>

    <xsl:template name="notification">
		<div class="dropdown">
			<button class="btn btn-dark dropdown-toggle" type="button" id="notification-menu-dropdown" data-toggle="dropdown" aria-haspopup="true">
				<i class="fa fa-bell" title="Notifications"></i>
			</button>
			<ul class="dropdown-menu" aria-labelledby="notification-menu-dropdown">
				<li class="drop-down-menu-label">Notifications</li>
				<li role="separator" class="divider"></li>
				<li>No notifications.</li>
			</ul>
		</div>
    </xsl:template>

	<xsl:template name="full-name">
		<xsl:variable name="client" select="/config/plugin[@plugin='clients'][@method='login']/client" />
		
		<span class="user full-name">
			<xsl:value-of select="$client/contact/@firstname" />
			<xsl:if test="$client/contact/@lastname != ''">
				<xsl:value-of select="concat(' ', $client/contact/@lastname)" />
			</xsl:if>
		</span>
	</xsl:template>

    <xsl:template name="welcome-full-name">
        <div class="row">
            <div class="col-md-12">
                <h5>
                    <em>Welcome <xsl:call-template name="full-name" /></em>
                </h5>
            </div>
        </div>
    </xsl:template>
	
</xsl:stylesheet>