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
	
	<xsl:template match="/subject">Your Green Business Assessment</xsl:template>

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
						<p>Thank you for completing your GreenBizCheck CSR Assessment.</p>
						<p>There is a whole range of suggested actions you can implement to reach Bronze (60%), Silver (70%) or Gold (80%) certification levels.</p>
						<ul>
							<li>Please log into your account</li>
							<li>Click on "Complete Assessments"</li>
							<li>Select "GreenBizCheck CSR Certification Program"</li>
							<li>Implement actions (your score will be updated automatically as soon as you update your commitment option)</li>
						</ul>

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