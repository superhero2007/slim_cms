<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		
	<xsl:template name="body_corporate_aircon_email">
		<p><a href="/members/email-templates/">Email Templates</a><xsl:text> &gt; </xsl:text><a href="/members/email-templates/body-corporate-aircon-email/">Body Corporate Aircon Email</a></p>
				<p>
					<xsl:text>Dear Sir/Madam</xsl:text>
				</p>
				<p><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> is actively seeking to reduce its impact on our environment and to identify environmentally-friendly measures to save energy, water and other resources. We are in the process of completing GreenBizCheck's (<a href="http://www.greenbizcheck.com">www.greenbizcheck.com</a>) environmental certification program that will help us optimize our company's environmental practices.</p>
				<p>We have placed a particular emphasis on energy efficiency. As such we would kindly ask you to set the following air conditioner office temperatures:</p>
				<ul>
					<li>Winter: 20C (68F)</li>
					<li>Summer: 24C (75F)</li>
				</ul>
				<p>These temperature settings will further assist us in reducing our energy consumption.</p>
				<p>We thank you in advance for assisting us.</p>
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
