<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			xmlns:xs="http://www.w3.org/2001/XMLSchema"
			xmlns:my="http://www.fgeorges.org/TMP/svg/charts#internals"
			extension-element-prefixes="date str">		
		
	<xsl:variable name="date_time" select="/config/datetime" />
	<xsl:variable name="unique_time_stamp" select="concat($date_time/@year,$date_time/@month,$date_time/@day,$date_time/@hour,$date_time/@minute,$date_time/@second)" />
	<xsl:variable name="graph-content-height" select="'3.5in'" />
	<xsl:variable name="graph-content-width" select="'7in'" />
	
			
	<!-- //Call the line graph from jGraph and send the parameters needed -->		
	<xsl:template match="google-bar-chart" mode="xhtml">
	
		<fo:block>
			<fo:external-graphic src="http://www.greenbizcheck.local/google-chart/index.php" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
        </fo:block>
		
	</xsl:template>
	
</xsl:stylesheet>