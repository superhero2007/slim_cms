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
				<p>Welcome to the National Retail Association's energy efficiency information program - Retail Buys the Future and thank you for registering <xsl:value-of select="client/@company_name" />.</p>
				<p>
					<strong>Login at:</strong><xsl:text> </xsl:text><a href="http://nra.retailbuysthefuture.com/">nra.retailbuysthefuture.com</a> with your username and password.<br />
				</p>
				<p>By registering <xsl:value-of select="client/@company_name" /> for this program you now have access to a variety of resources specifically designed for the retail and personal service sector in Australia. These include:</p>
				<ul>
					<li>Retail Assessment to assess current energy efficiency actions</li>
					<li>GHG calculator to measure and track your energy use</li>
					<li>Retail and personal service specific information fact sheets and operational guides</li>
					<li>Webinars and workshops </li>
					<li>Helpful links for further information</li>
				</ul>
				<p>Thank you again for joining the program. If you have any difficulties with the web portal please contact <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a>.</p>
			</body>
		</html>
	</xsl:template>
	
</xsl:stylesheet>