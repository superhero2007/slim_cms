<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			extension-element-prefixes="date str">

  <!-- //template to catch the call for certification levels -->
  <xsl:template match="overallScoreGenericv2" mode="xhtml">
    <xsl:call-template name="overall-score" />
  </xsl:template>

  <xsl:template name="overall-score">

    <xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@points)" />
    <xsl:variable name="demerits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@demerits)" />
    <xsl:variable name="merits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@merits)" />
    <xsl:variable name="initial_rate" select="($points - $demerits) div $points" />
    <xsl:variable name="current_rate" select="($points - $demerits + $merits) div $points" />

    <xsl:variable name="initial_rate_width">
      <xsl:choose>
        <xsl:when test="floor($initial_rate * 100) &gt; 10">
          <xsl:value-of select="floor($initial_rate * 100)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'10'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="current_rate_width">
      <xsl:choose>
        <xsl:when test="floor($current_rate * 100) &gt; 10">
          <xsl:value-of select="floor($current_rate * 100)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'10'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- //Initial Score -->
    <fo:block margin-bottom="15px">

      <fo:table border-collapse="collapse" font-size="10pt">
        <fo:table-column column-width="20%" column-number="1"/>
        <fo:table-column column-width="80%" column-number="2"/>
        <fo:table-body>
          <fo:table-row display-align="before">

            <!-- //Label -->
            <fo:table-cell text-align="left">
              <fo:block font-weight="bold" line-height="25px" font-size="12px">
                <xsl:text>Initial Score</xsl:text>
              </fo:block>
            </fo:table-cell>

            <!-- //Bar Graph -->
            <fo:table-cell text-align="left">
              <fo:block-container height="25px" background-color="#f5f5f5">

                <fo:block-container width="{$initial_rate_width}%" height="25px" background-color="#3498db" color="#ffffff" position="absolute" top="0px">
                  <fo:block text-align="center" font-weight="bold" line-height="25px">
                  <xsl:value-of select="floor($initial_rate * 100)" />%
                  </fo:block>
                </fo:block-container>

              </fo:block-container>
            </fo:table-cell>

          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:block>


    <!-- //Current Score -->
    <fo:block margin-bottom="15px">

      <fo:table border-collapse="collapse" font-size="10pt">
        <fo:table-column column-width="20%" column-number="1"/>
        <fo:table-column column-width="80%" column-number="2"/>
        <fo:table-body>
          <fo:table-row display-align="before">

            <!-- //Label -->
            <fo:table-cell text-align="left">
              <fo:block font-weight="bold" line-height="25px" font-size="12px">
                <xsl:text>Current Score</xsl:text>
              </fo:block>
            </fo:table-cell>

            <!-- //Bar Graph -->
            <fo:table-cell text-align="left">
              <fo:block-container height="25px" background-color="#f5f5f5">

                <fo:block-container width="{$current_rate_width}%" height="25px" background-color="rgb(81,174,80)" color="#ffffff" position="absolute" top="0px">
                  <fo:block text-align="center" font-weight="bold" line-height="25px">
                  <xsl:value-of select="floor($current_rate * 100)" />%
                  </fo:block>
                </fo:block-container>

              </fo:block-container>
            </fo:table-cell>

          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:block>

  </xsl:template>
 
 </xsl:stylesheet>