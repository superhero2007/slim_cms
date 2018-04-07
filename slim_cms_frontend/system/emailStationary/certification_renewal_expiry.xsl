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
	
	<xsl:param name="client_checklist_id" />

	<xsl:template match="/subject">Your Green Business Certification has Expired</xsl:template>

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

						<p>Your GreenBizCheck CSR certification has expired and we would love to retain your business.</p>
						<p>To demonstrate how much we want to retain you as a client we are happy to offer you the <strong>full 3-year program at a 2-year price</strong> plus you will benefit from an upgraded, even more effective program.</p>
						<p>We will be in touch in the next few days to discuss this option and how we can help you maximize your CSR program.</p>

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