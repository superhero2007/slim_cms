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
		
	<xsl:template match="/subject">Your Green Business Audit is now Due</xsl:template>
	
	<xsl:param name="client_checklist_id" />
	<xsl:param name="certification_level" />
	<xsl:param name="current_score" />
	<xsl:param name="client_checklist_md5" />
	
	<xsl:variable name="audit_required_count">
		<xsl:choose>
			<xsl:when test="$certification_level = 'Bronze'">8</xsl:when>
			<xsl:when test="$certification_level = 'Silver'">10</xsl:when>
			<xsl:when test="$certification_level = 'Gold'">12</xsl:when>
		</xsl:choose>
	</xsl:variable>

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

						<p>Congratulations on reaching GreenBizCheck CSR Certification.</p>
						<p>Please <a href="https://www.greenbizcheck.com/members/">login</a>, select any verifiable evidence from the list of auditable items at the bottom of your online report, upload them and submit them to Bureau Veritas for an effective desktop audit.</p>
						<p>Once Bureau Veritas have completed their desktop audit, they will issue you with your Certificate and you will have access to the Bronze, Silver or Gold GreenBizCheck CSR Certification logos.</p>
						<p>Please contact us at <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a> if you have any questions.</p>

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