<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			extension-element-prefixes="date str">

  <xsl:template match="certificationLevels" mode="xhtml">
  	<xsl:choose>
        <xsl:when test="/config/plugin[@plugin = 'checklist']/report/@variation_id = '2'">
            <xsl:text>There are no certification levels for this assessment</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@points)"/>
            <xsl:variable name="demerits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@demerits)"/>
            <xsl:variable name="merits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@merits)"/>
            <xsl:variable name="initial_rate" select="($points - $demerits) div $points"/>
            <xsl:variable name="current_rate" select="($points - $demerits + $merits) div $points"/>
            <fo:block>
        
              <fo:table border-collapse="collapse" font-size="10pt">
                <fo:table-column column-width="25%" column-number="1"/>
                        <fo:table-column column-width="15%" column-number="2"/>
                <fo:table-column column-width="10%" column-number="3"/>
                <fo:table-column column-width="50%" column-number="4"/>
                <fo:table-header margin-bottom="4pt">
                  <fo:table-row display-align="before">
                    <fo:table-cell text-align="left">
                      <fo:block> </fo:block>
                    </fo:table-cell>
                    <fo:table-cell text-align="left">
                      <fo:block> </fo:block>
                    </fo:table-cell>
                    <fo:table-cell text-align="left">
                      <fo:block font-weight="bold">Target</fo:block>
                    </fo:table-cell>
                    <fo:table-cell text-align="left">
                      <fo:block font-weight="bold">Percentage Bar</fo:block>
                    </fo:table-cell>
                  </fo:table-row>
                </fo:table-header>
                <fo:table-body>
                            <xsl:variable name="numberCertificationLevels" select="count(/config/plugin[@plugin = 'checklist']/report/certificationLevel)"/>
                  <xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/certificationLevel">
                    <fo:table-row display-align="before">
                      <fo:table-cell text-align="left">
                        <fo:block>
                          <xsl:value-of select="@name"/>
                          <xsl:if test="$current_rate * 100 &gt;= @target">
                            <fo:inline font-weight="bold"> - achieved</fo:inline>
                          </xsl:if>
                        </fo:block>
                      </fo:table-cell>
        
                                    <xsl:if test="position() = 1">
                          <fo:table-cell text-align="left" number-rows-spanned="{$numberCertificationLevels}" display-align="center">
                            <fo:block>
                                                <xsl:call-template name="stampImage">
                                                    <!--<xsl:with-param name="prefix" select="/config/plugin[@plugin='checklist']/report/@logo"/>
                                                    <xsl:with-param name="certifiedLevel" select="/config/plugin[@plugin='checklist']/report/@certified_level"/>-->
                                                    <xsl:with-param name="client_checklist_id" select="/config/plugin[@plugin='checklist']/report/@client_checklist_id" />
                                                    <xsl:with-param name="imageWidth" select="'180'"/>
                                                </xsl:call-template>
                            </fo:block>
                          </fo:table-cell>
                                    </xsl:if>
        
                      <fo:table-cell text-align="left">
                        <fo:block>
                          <xsl:value-of select="concat(@target,'%')"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell text-align="left">
                        <fo:block>
                          <!--<fo:instream-foreign-object>
                            <svg:svg width="10cm" height="0.4cm">
                              <svg:defs>
                                <svg:linearGradient id="grad" x1="0%" y1="0%" x2="0%" y2="100%">
                                  <svg:stop offset="100%" style="stop-color:#{@color};stop-opacity:1"/>
                                  <svg:stop offset="100%" style="stop-color:#{@color};stop-opacity:1"/>
                                </svg:linearGradient>
                              </svg:defs>
                              <svg:rect style="fill:url(#grad);" x="0" y="0" rx="0.05cm" ry="0.05cm" width="{@target * 0.08}cm" height="0.4cm"/>
                            </svg:svg>
                          </fo:instream-foreign-object>-->
                            <fo:inline>
                                <fo:external-graphic src="url('../util/{@color}-bar-left-end.jpg')" scaling="non-uniform" content-height="0.4cm" />
                                <fo:external-graphic src="url('../util/{@color}-bar-graph.jpg')" scaling="non-uniform" content-height="0.4cm" content-width="{@target * 0.08}cm" />
                                <fo:external-graphic src="url('../util/{@color}-bar-right-end.jpg')" scaling="non-uniform" content-height="0.4cm" />
                            </fo:inline>
                        </fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                  </xsl:for-each>
                </fo:table-body>
              </fo:table>
            </fo:block>
    	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>