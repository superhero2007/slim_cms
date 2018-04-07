<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		
	<xsl:template name="bronze_client_supply_chain_email">
		<p><a href="/members/email-templates/">Email Templates</a><xsl:text> &gt; </xsl:text><a href="/members/email-templates/bronze-client-supply-chain-email/">Bronze Client Supply Chain Email</a></p>
				<p>
					<xsl:text>Dear Sir/Madam</xsl:text>
				</p>
				<p><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> is very proud to announce that we have reached Bronze GreenBizCheck (<a href="http://www.greenbizcheck.com">www.greenbizcheck.com</a>) environmental certification.</p>
				<p>We will continue with our efforts to try to reduce our corporate footprint. We firmly believe that sustainability is critical to the success of our company and would like to encourage your company in joining us in making business more efficient.</p>
				<p>Again, many thanks for your engagement and support. Best regards</p>
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