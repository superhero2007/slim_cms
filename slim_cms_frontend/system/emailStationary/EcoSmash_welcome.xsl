<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:output
		method="xml"
		version="1.0"
		encoding="UTF-8"
		omit-xml-declaration="yes"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		indent="yes"
		media-type="text/html" />
	
	<xsl:template match="/config">
		<html>
			<body>
				<p>
					<xsl:text>Dear </xsl:text>
					<xsl:for-each select="client/contact">
						<xsl:value-of select="@firstname" />
						<xsl:choose>
							<xsl:when test="position() = last()-1"> and </xsl:when>
							<xsl:when test="position() != last()">, </xsl:when>
						</xsl:choose>
					</xsl:for-each>
					<xsl:text>,</xsl:text>
				</p>
				<p>Welcome to the EcoSmash self assessment program and thank you for registering <xsl:value-of select="client/@company_name" />.</p>
				<p>
					<strong>Login at:</strong><xsl:text> </xsl:text><a href="http://assessment.ecosmash.com.au/">assessment.ecosmash.com.au</a> with your username and password.<br />
				</p>
				<p>Thank you again for joining the EcoSmash self assessment program.</p>
				<p>Kind regards,</p>
				<p>
					<xsl:text>The EcoSmash Team</xsl:text>
					<br />
					<xsl:text>w: </xsl:text><a href="http://assessment.ecosmash.com.au/">assessment.ecosmash.com.au</a>
					<br />
					<xsl:text>e: </xsl:text><a href="mailto:ecosmash@iag.com.au">ecosmash@iag.com.au</a>
					<br />
				</p>
			</body>
		</html>
	</xsl:template>
	
</xsl:stylesheet>