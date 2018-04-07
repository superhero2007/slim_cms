<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		
	<xsl:template name="silver_staff_email">
		<p><a href="/members/email-templates/">Email Templates</a><xsl:text> &gt; </xsl:text><a href="/members/email-templates/silver-staff-email/">Silver Staff Introduction Email</a></p>
				<p>
					<xsl:text>Hi All</xsl:text>
				</p>
				<p>Our company is very proud to announce that we have reached Silver GreenBizCheck (<a href="http://www.greenbizcheck.com">www.greenbizcheck.com</a>)environmental certification and we would like to thank all of you for your invaluable contribution.</p>
				<p>We will continue with our efforts to try to reach Silver and then ultimately Gold certification.</p>
				<p>Again, many thanks for your engagement and support. We firmly believe that sustainability is critical to the success of our company. On behalf of the management team, I want you to know that we really appreciate your efforts.
				</p>
				<p>Kind regards,</p>
				<p>
					<xsl:value-of select="/config/plugin[@plugin = 'clients']/client/contact/@firstname" /><xsl:text> </xsl:text><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/contact/@lastname" />
					<br />
					<xsl:if test="/config/plugin[@plugin = 'clients']/client/contact/@position != ''">
						<xsl:value-of select="/config/plugin[@plugin = 'clients']/client/contact/@position" />
						<br />
					</xsl:if>
					<xsl:value-of select="/config/plugin[@plugin = 'clients']/client/contact/@email" />
					<br />
				</p>
	</xsl:template>
	
</xsl:stylesheet>