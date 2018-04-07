<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		
	<xsl:template name="body_corporate_recycle_bin_email">
		<p><a href="/members/email-templates/">Email Templates</a><xsl:text> &gt; </xsl:text><a href="/members/email-templates/body-corporate-recycle-bin-email/">Body Corporate Recycle Bin Email</a></p>
				<p>
					<xsl:text>Dear Sir/Madam</xsl:text>
				</p>
				<p><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> is actively seeking to reduce its impact on our environment and to identify environmentally-friendly measures to save energy, water and other resources. We are in the process of completing GreenBizCheck's (<a href="http://www.greenbizcheck.com">www.greenbizcheck.com</a>) environmental certification program that will help us optimize our company's environmental practices.</p>
				<p>We have placed particular emphasis on recycling and would therefore kindly ask you to provide our office building with a recycling bin. Such a bin will allow us to massively reduce our waste that ends up in landfills and increase recycling by all tenants.</p>
				<p>We thank you for assisting us.</p>
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