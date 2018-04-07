<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			extension-element-prefixes="date str">


  <xsl:template match="overallScore" mode="xhtml">
    <xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@points)"/>
    <xsl:variable name="demerits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@demerits)"/>
    <xsl:variable name="merits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@merits)"/>
    
	<xsl:variable name="initial_rate">
		<xsl:choose>
			<xsl:when test="(($points - $demerits) div $points) &lt; 0">0</xsl:when>
			<xsl:when test="(($points - $demerits) div $points) &gt; 100">100</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="($points - $demerits) div $points" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="current_rate">
		<xsl:choose>
			<xsl:when test="(($points - $demerits + $merits) div $points) &lt; 0">0</xsl:when>
			<xsl:when test="(($points - $demerits + $merits) div $points) &gt; 100">100</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="($points - $demerits + $merits) div $points" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>		
    <!--<xsl:variable name="current_rate" select="($points - $demerits + $merits) div $points"/>-->
    <fo:block>
      <fo:table border-collapse="collapse" font-size="10pt">
        <fo:table-column column-width="35%" column-number="1"/>
        <fo:table-column column-width="10%" column-number="2"/>
        <fo:table-column column-width="45%" column-number="3"/>
        <fo:table-column column-width="10%" column-number="4"/>
        <fo:table-header margin-bottom="4pt">
          <fo:table-row display-align="before">
            <fo:table-cell text-align="left">
              <fo:block> </fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block font-weight="bold">Score</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block font-weight="bold">Percentage Bar</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block font-weight="bold"><fo:inline color="#cccccc">Target</fo:inline></fo:block>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-header>
        <fo:table-body>
          <fo:table-row display-align="before">
            <fo:table-cell text-align="left">
              <fo:block>Your Initial Score</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block>
                <xsl:value-of select="format-number($initial_rate,'##%')"/>
                <!--<xsl:value-of select="format-number(format-number(concat(substring-before($initial_rate,'.'),'.', substring(substring-after($initial_rate,'.'),1,2)),'#.00'),'##%')" />-->
              </fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block>
                <!--<fo:instream-foreign-object>
                  <svg:svg width="10cm" height="0.4cm">
                    <svg:defs>
                      <svg:linearGradient id="grad" x1="0%" y1="0%" x2="0%" y2="100%">
                        <svg:stop offset="100%" style="stop-color:#964f25;stop-opacity:1"/>
                        <svg:stop offset="100%" style="stop-color:#964f25;stop-opacity:1"/>
                      </svg:linearGradient>
                    </svg:defs>
                    <svg:rect style="fill:url(#grad);" x="0" y="0" rx="0.05cm" ry="0.05cm" width="{$initial_rate * 8}cm" height="0.4cm"/>
                  </svg:svg>
                </fo:instream-foreign-object>-->
                <xsl:if test="$initial_rate > 0">
                	<fo:inline>
                		<fo:external-graphic src="url('../util/brown-bar-left-end.jpg')" scaling="non-uniform" content-height="0.4cm" />
                		<fo:external-graphic src="url('../util/brown-bar-graph.jpg')" scaling="non-uniform" content-height="0.4cm" content-width="{$initial_rate * 8}cm" />
                		<fo:external-graphic src="url('../util/brown-bar-right-end.jpg')" scaling="non-uniform" content-height="0.4cm" />
                	</fo:inline>
                </xsl:if>
              </fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block><fo:inline color="#cccccc">100%</fo:inline></fo:block>
            </fo:table-cell>
          </fo:table-row>
          <fo:table-row display-align="before">
            <fo:table-cell text-align="left">
              <fo:block>Your Current Score</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block>
                <!--<xsl:value-of select="format-number($current_rate,'##%')"/> -->
                <xsl:value-of select="format-number(format-number(concat(substring-before($current_rate,'.'),'.', substring(substring-after($current_rate,'.'),1,2)),'#.00'),'##%')" />
              </fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block>
                <!--<fo:instream-foreign-object>
                  <svg:svg width="10cm" height="0.4cm">
                    <svg:defs>
                      <svg:linearGradient id="grad" x1="0%" y1="0%" x2="0%" y2="100%">
                        <svg:stop offset="100%" style="stop-color:#649b47;stop-opacity:1"/>
                        <svg:stop offset="100%" style="stop-color:#649b47;stop-opacity:1"/>
                      </svg:linearGradient>
                    </svg:defs>
                    <svg:rect style="fill:url(#grad);" x="0" y="0" rx="0.05cm" ry="0.05cm" width="{$current_rate * 8}cm" height="0.4cm"/>
                  </svg:svg>
                </fo:instream-foreign-object>-->
                <xsl:if test="$current_rate > 0">
                <fo:inline>
                	<fo:external-graphic src="url('../util/green-bar-left-end.jpg')" scaling="non-uniform" content-height="0.4cm" />
                	<fo:external-graphic src="url('../util/green-bar-graph.jpg')" scaling="non-uniform" content-height="0.4cm" content-width="{$current_rate * 8}cm" />
                	<fo:external-graphic src="url('../util/green-bar-right-end.jpg')" scaling="non-uniform" content-height="0.4cm" />
                </fo:inline>
                </xsl:if>
              </fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block><fo:inline color="#cccccc">100%</fo:inline></fo:block>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:block>
  </xsl:template>
 
 </xsl:stylesheet>