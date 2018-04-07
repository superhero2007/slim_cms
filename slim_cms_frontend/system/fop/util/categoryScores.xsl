<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			extension-element-prefixes="date str">

 <xsl:template match="categoryScores" mode="xhtml">
    <fo:block>
      <fo:table border-collapse="collapse" font-size="10pt">
        <fo:table-column column-width="30%" column-number="1"/>
        <fo:table-column column-width="10%" column-number="2"/>
        <fo:table-column column-width="10%" column-number="3"/>
        <fo:table-column column-width="50%" column-number="4"/>
        <fo:table-header margin-bottom="4pt">
          <fo:table-row display-align="before">
            <fo:table-cell text-align="left">
              <fo:block font-weight="bold">Category</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block font-weight="bold">Rate</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block font-weight="bold">Score</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left">
              <fo:block font-weight="bold">Percentage Bar</fo:block>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-header>
        <fo:table-body>
          <xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/reportSection[@points &gt; 0][@display_in_pdf = '1']">
            <xsl:variable name="initial_rate" select="(@points - @demerits) div @points"/>
            <xsl:variable name="current_rate" select="(@points - @demerits + @merits) div @points"/>
            <fo:table-row display-align="before">
              <fo:table-cell text-align="left" number-rows-spanned="2">
                <fo:block>
                  <xsl:value-of select="@title"/>
                </fo:block>
              </fo:table-cell>
              <fo:table-cell text-align="left">
                <fo:block>Initial</fo:block>
              </fo:table-cell>
              <fo:table-cell text-align="left">
                <fo:block>
                  <xsl:value-of select="format-number($initial_rate,'##%')"/>
                </fo:block>
              </fo:table-cell>
              <fo:table-cell text-align="left">
                <fo:block>
                 <!-- <fo:instream-foreign-object>
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
            </fo:table-row>
            <fo:table-row display-align="before">
              <fo:table-cell text-align="left">
                <fo:block>Current</fo:block>
              </fo:table-cell>
              <fo:table-cell text-align="left">
                <fo:block>
                  <xsl:value-of select="format-number($current_rate,'##%')"/>
                </fo:block>
              </fo:table-cell>
              <fo:table-cell text-align="left">
                <fo:block margin-bottom="6pt">
                  <!--<fo:instream-foreign-object>
                    <svg:svg width="10cm" height="0.4cm">
                      <svg:defs>
                        <svg:linearGradient id="grad" x1="0%" y1="0%" x2="0%" y2="100%">
                          <svg:stop offset="100%" style="stop-color:#649b47;stop-opacity:1"/>
                          <svg:stop offset="100%" style="stop-color:#649b47;stop-opacity:1"/>
                        </svg:linearGradient>
                      </svg:defs>
                      <svg:rect style="fill:url(#grad)" x="0" y="0" rx="0.05cm" ry="0.05cm" width="{$current_rate * 8}cm" height="0.4cm"/>
                    </svg:svg>
                  </fo:instream-foreign-object> -->
                  <xsl:if test="$current_rate > 0">
                  	<fo:inline>
                		<fo:external-graphic src="url('../util/green-bar-left-end.jpg')" scaling="non-uniform" content-height="0.4cm" />
                		<fo:external-graphic src="url('../util/green-bar-graph.jpg')" scaling="non-uniform" content-height="0.4cm" content-width="{$current_rate * 8}cm" />
                		<fo:external-graphic src="url('../util/green-bar-right-end.jpg')" scaling="non-uniform" content-height="0.4cm" />
                	</fo:inline>
                  </xsl:if>
                </fo:block>
              </fo:table-cell>
            </fo:table-row>
          </xsl:for-each>
        </fo:table-body>
      </fo:table>
    </fo:block>
		<fo:block background-color="rgb(240,240,240)" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt" keep-together.within-page="always">
			<fo:block>The light green check <fo:external-graphic src="url(tick2.png)"/> depicts actions that your organization is already doing.</fo:block>
			<fo:block margin-top="6pt">The dark green check <fo:external-graphic src="url(tick.png)" /> bolded actions are actions your organization has implemented since its GreenBizCheck assessment.</fo:block>
			<fo:block margin-top="6pt">Actions yet to be adopted or implemented are bolded without a check.</fo:block>
		</fo:block>
  </xsl:template>
  
</xsl:stylesheet>