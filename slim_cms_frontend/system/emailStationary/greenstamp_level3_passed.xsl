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
		
	<xsl:template match="/subject">Green Stamp Level 3 Passed</xsl:template>
		
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
				<p>Thank you for participating in the MTA's Green Stamp Program. Your business has successfully passed Green Stamp Level 3 (Continual Improvement). Congratulations!</p>
				<p>Your participation shows great motivation to in continuing to enhance your business' environmental practices. Please find the confidential report attached for your information. The MTA hopes this will assist your business.</p>
				<p>Formal Green Stamp Accreditation is a great way of communicating your commitment to environmental management and marketing your achievements to the greater community. Let's get this underway as soon as possible!</p>
				<p>An MTA representative will be in contact shortly to finalise your Green Stamp.</p>
				
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
