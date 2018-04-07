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
		
	<xsl:template match="/subject">Your assessment has been submitted/waiting on approval</xsl:template>
		
	<xsl:template match="/config">
		<html>
			<body>
				
                <!-- //Dear names -->
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
				
				<!-- //Email Message -->
				<p>Thank you for participating in the MTA's Green Stamp Program.</p>
				<p>Your assessment results are currently under review. The MTA will be in contact soon with your final outcomes.</p>
				<p>With the increased public awareness on environmental issues, it is crucial that businesses within the automotive industry demonstrate their commitment to protecting the environment openly to show recognition of their corporate responsibility.</p>
				<p>The participation of your business displays a great motivation to continue enhancing your environmental practices, as well as setting a precedence for the industry as a whole!</p>
                
                <!-- Footer content -->
                <p>
					<strong>Kind Regards,<br />
					Motor Traders' Association of NSW<br />
					Ph: 02 9016 9000<br />
					Email: <a href="mailto:greenstamp@mtansw.com.au">greenstamp@mtansw.com.au</a>
					</strong>
                </p>	
			</body>
		</html>
	</xsl:template>
	
</xsl:stylesheet>
