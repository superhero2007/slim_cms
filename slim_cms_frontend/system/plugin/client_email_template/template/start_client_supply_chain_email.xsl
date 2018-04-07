<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		
	<xsl:template name="start_client_supply_chain_email">
		<p><a href="/members/email-templates/">Email Templates</a><xsl:text> &gt; </xsl:text><a href="/members/email-templates/start-client-supply-chain-email/">Start Client Supply Chain Email</a></p>
				<p>
					<xsl:text>Dear Sir/Madam</xsl:text>
				</p>
				<p><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> is actively seeking to reduce its impact on our environment and to identify environmentally-friendly measures to save energy, water and other resources. We are in the process of completing GreenBizCheck's (<a href="http://www.greenbizcheck.com">www.greenbizcheck.com</a>) environmental certification program that will help us optimize our company's environmental practices.</p>
				<p>We are very keen to get our business partners involved in sustainability and would like to encourage you to also undertake GreenBizCheck's comprehensive assessment for your organization. </p>
				<p>GreenBizCheck's full assessment will assist you in becoming more sustainable and save you money by identifying easy-to-implement environmental opportunities. It also comes with a 100% money back guarantee.</p>
				<p>Please do not hesitate to contact GreenBizCheck directly at <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a> if you have any questions or would like more information.</p>
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