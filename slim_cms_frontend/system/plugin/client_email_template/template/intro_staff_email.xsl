<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		
	<xsl:template name="intro_staff_email">
		<p><a href="/members/email-templates/">Email Templates</a><xsl:text> &gt; </xsl:text><a href="/members/email-templates/intro-staff-email/">Introduction Staff Email</a></p>
				<p>
					<xsl:text>Hi All</xsl:text>
				</p>
				<p><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> is actively seeking to reduce its impact on our environment and to identify environmentally-friendly measures to save energy, water and other resources. We are in the process of completing GreenBizCheck's (<a href="http://www.greenbizcheck.com">www.greenbizcheck.com</a>) environmental certification program that will help us optimize our company's environmental practices.</p>
				<p>GreenBizCheck's comprehensive assessment encompasses:</p>
				<p>
					<ul>
						<li>Energy</li>
						<li>Water</li>
						<li>Waste and Recycling</li>
						<li>Transportation and travel</li>
						<li>Supply chain sustainability</li>
						<li>IT/Data Centre</li>
					</ul>
				</p>
				<p>GreenBizCheck's practical certification program will help us save money by identifying easy-to-implement environmental opportunities.</p>
				<p>We will regularly email you updates and progress reports. We would also be very grateful if you could identify additional ways of improving our corporate sustainability, and hope that you will contribute to achieving our goal of substantially reducing our footprint on this planet.</p>
				<p>[Insert name] will coordinate our sustainability drive. Please contact GreenBizCheck directly at <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a> if you have any questions.</p>
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