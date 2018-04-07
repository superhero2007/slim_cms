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

	<xsl:template match="/subject">Your Green Business Certification Renewal is Due</xsl:template>

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
						
						<p>This is a quick heads-up as it is almost time to renew your annual GreenBizCheck CSR certification program.</p>
						<p>It has been a pleasure working with you and we value your continued support. We have attached a renewal invoice and look forward to continuing to assist you on your CSR journey. Please feel free to contact us at <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a> if you would like to explore our highly cost effective 3-year CSR certification solution or if you have any other questions.</p>
						<p>We sincerely thank you for your ongoing CSR commitment.</p>

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