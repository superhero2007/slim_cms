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
		
	<xsl:template match="/subject">Supply Chain Solution Software</xsl:template>
	
	<xsl:param name="client_checklist_id" />
	<xsl:param name="certification_level" />
	<xsl:param name="current_score" />
	<xsl:param name="client_checklist_md5" />

	<!-- //Include Generic Email Components -->
	<xsl:include href="email-components.xsl" />
	
	<xsl:template match="/config">
		<html>
			<head>
				<!-- //Email Styling -->
				<xsl:call-template name="gbc-email-styling" />
			</head>

			<body>            	
				<table class="background-table">
					<tr>
						<td class="background-table-cell">
						
							<center>

					<!-- //All content should be inside the email-container block -->
	                <div class="email-container">
				
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

						<p>Many thanks for completing the Supply Chain Sustainability Tracker which was co-developed by GreenBizCheck and the Australian Centre for Corporate Social Responsibility (ACCSR).</p>
						<p>We hope that you found this tracker useful and we would be very grateful for your feedback and comments. We will contact you in the next few days but please do not hesitate to contact us directly at <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a> in the meantime.</p>
						<p>Again many thanks for completing the tracker.</p>

						<!-- //Generic GBC Email Template Signature -->
						<xsl:call-template name="gbc-generic-email-signature" />

	                </div>
	                <!-- //All content should be inside the above email-container block -->

							</center>
                		
                		</td>
                	</tr>
                </table>
                
			</body>
		</html>
	</xsl:template>
	
</xsl:stylesheet>