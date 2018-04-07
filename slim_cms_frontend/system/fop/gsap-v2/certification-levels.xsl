<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			extension-element-prefixes="date str">


  <!-- //template to catch the call for certification levels -->
  <xsl:template match="certificationLevelsv2" mode="xhtml">
    <xsl:call-template name="certification-levels" />
  </xsl:template>

  <xsl:template name="certification-levels">

    <xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@points)"/>
    <xsl:variable name="demerits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@demerits)"/>
    <xsl:variable name="merits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@merits)"/>
    <xsl:variable name="initial_rate" select="($points - $demerits) div $points"/>
    <xsl:variable name="current_rate" select="($points - $demerits + $merits) div $points"/>
    <fo:block margin-bottom="15px">

      <fo:table border-collapse="collapse" font-size="10pt">
        <fo:table-column column-width="20%" column-number="1"/>
        <fo:table-column column-width="80%" column-number="2"/>
        <fo:table-body>
          <fo:table-row display-align="before">

            <!-- //Label -->
            <fo:table-cell text-align="left">
              <fo:block font-weight="bold" line-height="25px" font-size="12px">
                <xsl:text>Targets</xsl:text>
              </fo:block>
            </fo:table-cell>

            <!-- //Bar Graph -->
            <fo:table-cell text-align="left">
              <fo:block-container height="25px" background-color="#f5f5f5">

                <!-- //Check for certificationLevels first -->
                <xsl:choose>
                  <xsl:when test="count(/config/plugin[@plugin = 'checklist']/report/certificationLevel) &gt; 0">
                    <xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/certificationLevel">
                      <xsl:sort select="@target" />
                      <xsl:variable name="upper-bound">
                        <xsl:choose>
                          <xsl:when test="following-sibling::*[1][self::certificationLevel]/@target">
                            <xsl:value-of select="following-sibling::*[1][self::certificationLevel]/@target" />
                          </xsl:when>
                          <xsl:otherwise>100</xsl:otherwise>
                        </xsl:choose> 
                      </xsl:variable>

                      <fo:block-container height="25px" width="{($upper-bound - @target)}%" background-color="#{@color}" color="#ffffff" position="absolute" top="0px" left="{@target}%">
                        <fo:block text-align="center" font-weight="bold" line-height="25px">
                          <xsl:value-of select="@target" />%
                          <xsl:text> </xsl:text>
                          <xsl:value-of select="@name" />
                        </fo:block>
                      </fo:block-container>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/genericCertificationLevel">
                      <xsl:sort select="@target" />
                      <xsl:variable name="upper-bound">
                        <xsl:choose>
                          <xsl:when test="following-sibling::*[1][self::genericCertificationLevel]/@target">
                            <xsl:value-of select="following-sibling::*[1][self::genericCertificationLevel]/@target" />
                          </xsl:when>
                          <xsl:otherwise>100</xsl:otherwise>
                        </xsl:choose> 
                      </xsl:variable>
                      
                      <fo:block-container height="25px" width="{($upper-bound - @target)}%" background-color="#{@color}" color="#ffffff" position="absolute" top="0px" left="{@target}%">
                        <fo:block text-align="center" font-weight="bold" line-height="25px">
                          <xsl:value-of select="@target" />%
                          <xsl:text> </xsl:text>
                          <xsl:value-of select="@name" />
                        </fo:block>
                      </fo:block-container>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>

              </fo:block-container>
            </fo:table-cell>

          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:block>

  </xsl:template>
  
</xsl:stylesheet>