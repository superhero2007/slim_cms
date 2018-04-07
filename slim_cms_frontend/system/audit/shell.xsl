<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:php="http://php.net/xsl"
	xmlns:dyn="http://exslt.org/dynamic"
	xmlns:exsl="http://exslt.org/common"
	xmlns:func="http://exslt.org/functions"
	xmlns:math="http://exslt.org/math"
	xmlns:regexp="http://exslt.org/regular-expressions"
	xmlns:set="http://exslt.org/sets"
	xmlns:str="http://exslt.org/strings"
	exclude-result-prefixes="php dyn exsl func math regexp set str">
	
	<xsl:output
		method="xml"
		version="1.0"
		encoding="UTF-8"
		omit-xml-declaration="no"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		indent="yes"
		media-type="text/html" />

	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template name="option_count">
		<xsl:param name="limit" select="10" />
		<xsl:param name="count" select="0" />
		<xsl:param name="selected" />
		
		<xsl:if test="$count &lt;= $limit">
			<option value="{$count}">
				<xsl:if test="$selected = $count"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
				<xsl:value-of select="$count" />
			</option>
			<xsl:call-template name="option_count">
				<xsl:with-param name="limit" select="$limit" />
				<xsl:with-param name="count" select="$count+1" />
				<xsl:with-param name="selected" select="$selected" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
