<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">


<xsl:template match="/config/plugin[@plugin = 'moduleAccess'][@method = 'register']">

	<!-- //Message -->
	<xsl:choose>
		<xsl:when test="@message">
			<div class="alert alert-{@message_type}">
				<xsl:value-of select="@message" />
			</div>
		</xsl:when>
	</xsl:choose>

	<!-- //Redirect -->

	<xsl:choose>
		<xsl:when test="@redirect = '1'">
			<p>You will be automatically redirected to the <xsl:value-of select="@module_name" /> in 10 seconds. Alternatively you can <a href="{@redirect_url}" class="underline-link">click here</a> to continue.</p>
		</xsl:when>
	</xsl:choose>

</xsl:template>


</xsl:stylesheet>