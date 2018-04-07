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
						<p>Welcome to the APC Site-Based Energy and Resource Assessment and Action Plan for signatories.</p>
						<p>This online assessment is available to signatories who participated in Business Clean-Up Day in 2013.</p>
						<p>The focus is on site and office energy use, however we have included a range of resource use and waste management questions and actions to help organisations address some of their APC requirements.</p>
						<p>Don't forget to report these assessments and any follow-up actions as part of your APC annual report in March each year.</p>
						<p>The APC GHG Tracking program allows you to track your Scope 1, 2 and 3 Greenhouse Gas (GHG) footprints over time. The different scopes include fuel consumption,electricity usage, business travel, waste and other categories. You can update your figures quarterly to monitor your GHG and consumption trends which will also assist you in identifying areas that could be improved.</p>
						<p>Please complete the assessments from a site-perspective.  If you require multiple logins for each site please <a href="mailto:members@packagingcovenant.org.au" target="_blank">contact Brett Giddings at the APC</a>.</p>
						
		                <ol>
		                    <li>Login here:
		                        <img src="http://www.greenbizcheck.com/_images/email_content/welcome/apc_login.png" style="padding:15px" />
		                     </li>
		                     <li>Select and Click on Appropriate Assessment<br />
		                        <img src="http://www.greenbizcheck.com/_images/email_content/welcome/apc_assessment_list.png" style="padding:15px" />
		                     </li>
		                     <li>Select Category of Questions and Respond to Questions<br />
		                        <img src="http://www.greenbizcheck.com/_images/email_content/welcome/apc_assessment_start.png" style="padding:15px" />
		                     </li>
		                     <li>Instantly receive comprehensive report including score<br />
		                        <img src="http://www.greenbizcheck.com/_images/email_content/welcome/apc_web_report.png" style="padding:15px" />
		                     </li>
		                     <li>Implement recommended actions by clicking on individual action<br />
		                        <img src="http://www.greenbizcheck.com/_images/email_content/welcome/apc_action_list.png" style="padding:15px" />
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
