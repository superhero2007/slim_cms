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

                        <p>This is just a courtesy email to help you get started on your 3-step GreenBizCheck CSR certification program.</p>
                        <ol>
                            <li>Login and complete assessment at <a href="https://www.greenbizcheck.com">www.greenbizcheck.com</a></li>
                            <li>Instantly receive comprehensive CSR report including score</li>
                            <li>Reach Certification levels / complete desktop audit by Bureau Veritas: Bronze (60%), Silver (70%) and Gold (80%)</li>
                        </ol>
                        <p>We are delighted to welcome you to our CSR certification program and look forward to working with you and your team. Please feel free to contact us at <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a> at any time if you have any questions.</p>
        				
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
