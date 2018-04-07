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
		
	<xsl:template match="/subject">Green Stamp Level 1 Failed</xsl:template>
		
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
				<p>Your participation shows great motivation to in continuing to enhance your business' environmental practices. Please find the confidential report attached for your information. The MTA hopes this will assist your business.</p>
				<p>Unfortunately, <xsl:value-of select="client/@company_name" /> has failed to meet the Green Stamp criteria set out in Level 1 – Legislative Requirements.</p>
				<p>The environmental criteria in Level 1 establishes that a business hold all relevant  permits and licenses and are operating in a manner that meets all legislative requirements. The criterion detailed in Level 1 has been designed to incorporate other important considerations contained within relevant industry Codes of Practice.</p>
				<p>For further assistance in achieving Level 1, please contact the MTA for a free and confidential environmental audit or to ask for industry related environmental advice.</p>
				
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
