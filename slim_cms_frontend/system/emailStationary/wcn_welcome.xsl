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
		
	<xsl:template match="/subject">Green Business Certification</xsl:template>
		
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
						<p>Welcome to GreenBizCheck and our global environmental certification program for <xsl:value-of select="client/@company_name" />.</p>
		                <p>The certification process is cloud-based and highly intuitive:</p>
						
		                <ol>
		                    <li>Login here
		                        <img src="http://www.greenbizcheck.com/_images/email_content/welcome/wcn_login_1.PNG" style="padding:15px" />
								<img src="http://www.greenbizcheck.com/_images/email_content/welcome/wcn_login_2.PNG" style="padding:15px" />
		                     </li>
		                     <li>Select and Click on Appropriate Assessment<br />
		                        <img src="http://www.greenbizcheck.com/_images/email_content/welcome/wcn_assessment_list.PNG" style="padding:15px" />
		                     </li>
		                     <li>Select Category of Questions and Respond to Questions<br />
		                        <img src="http://www.greenbizcheck.com/_images/email_content/welcome/wcn_assessment_start.PNG" style="padding:15px" />
		                     </li>
		                     <li>Instantly receive comprehensive report including score<br />
		                        <img src="http://www.greenbizcheck.com/_images/email_content/welcome/wcn_web_report.PNG" style="padding:15px" />
		                     </li>
		                     <li>Implement recommended actions by clicking on individual action to improve your score<br />
		                        <img src="http://www.greenbizcheck.com/_images/email_content/welcome/wcn_action_list.PNG" style="padding:15px" />
		                     </li>
		                 </ol>
		                 
		                 <p>We are delighted to welcome you to our certification program and look forward to working with you and your organisation. Please feel free to contact us at <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a> at any time if you have any questions.</p>
						
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
