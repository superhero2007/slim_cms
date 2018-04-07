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

                        <p>Welcome to the GreenBizCheck CSR certification program for <xsl:value-of select="client/@company_name" />. You are 3 simple steps away from achieving certification:</p>
                        <ol>
                            <li>Assessment: <a href="https://www.greenbizcheck.com/members/">Registration</a> / <a href="https://www.greenbizcheck.com/members/">log-in here</a> to complete assessment</li>
                            <li>Report: Receive scorecard and action plan</li>
                            <li>Certification: Reach certification benchmarks Bronze (60%), Silver (70%) or Gold (80%); complete seamless Bureau Veritas audit and become certified</li>
                        </ol>
                        <p>We are delighted to welcome you to our CSR Certification Program and look forward to working with you and your team. Please feel free to contact us at <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a> at any time if you have any questions.</p>
        				
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
