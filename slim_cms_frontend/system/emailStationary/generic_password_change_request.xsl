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

	<xsl:param name="reset_link" />
	<xsl:param name="site_name" />
	<xsl:param name="site_email" />
		
	<xsl:template match="/subject">
		<xsl:value-of select="$site_name" /> Password Change Request
	</xsl:template>
	
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
										<xsl:text>Hi </xsl:text>
										<xsl:for-each select="client/contact">
											<xsl:value-of select="@firstname" />
											<xsl:choose>
												<xsl:when test="position() = last()-1"> and </xsl:when>
												<xsl:when test="position() != last()">, </xsl:when>
											</xsl:choose>
										</xsl:for-each>
										<xsl:text>,</xsl:text>
									</p>
									<p>A request to reset your password has recently been made.</p>
									
									<p>To change your password, click <a href="{$reset_link}">here</a> or paste the following link into your browser: <a href="{$reset_link}"><xsl:value-of select="$reset_link" /></a></p>
			 
									<p>The link will expire in 24 hours, so be sure to use it right away.</p>

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