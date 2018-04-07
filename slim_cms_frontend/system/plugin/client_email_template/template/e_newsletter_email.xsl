<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		
	<xsl:template name="e_newsletter_email">
		<p><a href="/members/email-templates/">Email Templates</a><xsl:text> &gt; </xsl:text><a href="/members/email-templates/e-newsletter-email/">E-Newsletter Email</a></p>
				<p>
					<xsl:text>Hi Sir/Madam</xsl:text>
				</p>
				<p>Our company is actively seeking to reduce its impact on our environment and to identify ecological measures to save energy, water, other resources and money. One of the measures we have decided to adopt is the transformation of our paper based newsletter to an electronic version.</p>
				<p>We hope that this change will not inconvenience you unduly and that you support this measure which will further strengthen our environmental commitment. Please provide us with the email addresses of prospective recipients of our e-newsletter.</p>
				<p>We hope that you will still enjoy our newsletter in the future and wish you all the best.</p>
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