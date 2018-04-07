<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		
	<xsl:template name="bronze_press_release_email">
		<p><a href="/members/email-templates/">Email Templates</a><xsl:text> &gt; </xsl:text><a href="/members/email-templates/bronze-press-release-email/">Bronze Press Release Email</a></p>
				<p>
					<xsl:value-of select="/config/datetime/@day" /><xsl:text>-</xsl:text><xsl:value-of select="/config/datetime/@month" /><xsl:text>-</xsl:text><xsl:value-of select="/config/datetime/@year" />
				</p>
				<p><strong><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> achieves GreenBizCheck Bronze Certification</strong></p>
				<p><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> is pleased to announce that it has reached GreenBizCheck (<a href="http://www.greenbizcheck.com">www.greenbizcheck.com</a>) bronze certification.</p>
				<p>GreenBizCheck's practical and effective program helped <xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> quickly implement environmentally responsible business practices that have helped save resources, attract customers, motivate staff and help protect the environment.</p>
				<p><i>&quot;We are providing businesses with a practical and low cost means of taking action to help reduce their increasing impact on climate change&quot;</i>, said GreenBizCheck Managing Director Nicholas Bernhardt. <i>&quot;Our assessment and action-oriented report is so thorough we offer a 100% money back guarantee that clients will easily save the cost of certification in the first year,.&quot;</i> he said.</p>
				<p><i>&quot;<xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> enjoyed working with GreenBizCheck to efficiently reduce energy, water and waste costs in our business. Aside from the cost savings we were keen to set a high green standard in our market and independently show <xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> is committed to sustainable business practices.&quot;</i><xsl:text> </xsl:text><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" />'s <xsl:value-of select="/config/plugin[@plugin = 'clients']/client/contact/@firstname" /><xsl:text> </xsl:text><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/contact/@lastname" /> said.</p>
				<p><strong>For further information please contact:</strong></p>
				<p><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/contact/@firstname" /><xsl:text> </xsl:text><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/contact/@lastname" />, <xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" />, <xsl:value-of select="/config/plugin[@plugin = 'clients']/client/contact/@email" /></p>
	</xsl:template>
	
</xsl:stylesheet>