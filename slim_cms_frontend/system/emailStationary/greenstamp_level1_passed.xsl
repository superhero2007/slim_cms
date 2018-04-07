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
		
	<xsl:template match="/subject">Green Stamp Level 1 Passed</xsl:template>
		
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
				<p>Thank you for participating in the MTA's Green Stamp Program. Your business has successfully passed Green Stamp Level 1 (Legislative Requirements). Congratulations!</p>
				<p>Your participation shows great motivation to in continuing to enhance your business' environmental practices. Please find the confidential report attached for your information. The MTA hopes this will assist your business.</p>
				<p>In order to achieve the 'Green Stamp', your business will need to comply with the criteria set out in Green Stamp Level 2 (Voluntary Initiatives). Formal Green Stamp Accreditation is a great way to communicate your commitment to environmental management. Let’s get this underway as soon as possible!</p>
                
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
