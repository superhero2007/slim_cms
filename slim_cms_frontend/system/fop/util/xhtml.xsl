<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			extension-element-prefixes="date str">

  <xsl:template name="renderXHTML">
    <xsl:param name="xhtml"/>
    <xsl:apply-templates select="$xhtml/*" mode="xhtml"/>
  </xsl:template>
  <xsl:attribute-set name="a-link">
    <xsl:attribute name="text-decoration">underline</xsl:attribute>
    <xsl:attribute name="color">blue</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="strong">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="text-light">
    <xsl:attribute name="font-weight">100</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="strong-em">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="em">
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="i">
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="b">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="ul">
    <xsl:attribute name="space-before">1em</xsl:attribute>
    <xsl:attribute name="space-after">1em</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="ol">
    <xsl:attribute name="space-before">1em</xsl:attribute>
    <xsl:attribute name="space-after">1em</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="ul-li">
    <xsl:attribute name="relative-align">baseline</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="ol-li">
    <xsl:attribute name="relative-align">baseline</xsl:attribute>
  </xsl:attribute-set>
  <xsl:template name="process-a-link">
    <xsl:choose>
      <xsl:when test="starts-with(@href,'#')">
        <xsl:attribute name="internal-destination">
          <xsl:value-of select="substring-after(@href,'#')"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="external-destination">
          <xsl:text>url('</xsl:text>
          <xsl:value-of select="@href"/>
          <xsl:text>')</xsl:text>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="b" mode="xhtml">
    <fo:inline xsl:use-attribute-sets="b">
      <xsl:apply-templates mode="xhtml"/>
    </fo:inline>
  </xsl:template>
  <xsl:template match="strong" mode="xhtml">
    <fo:inline xsl:use-attribute-sets="strong">
      <xsl:apply-templates mode="xhtml"/>
    </fo:inline>
  </xsl:template>
  <xsl:template match="strong//em | em//strong" mode="xhtml">
    <fo:inline xsl:use-attribute-sets="strong-em">
      <xsl:apply-templates mode="xhtml"/>
    </fo:inline>
  </xsl:template>
  <xsl:template match="i" mode="xhtml">
    <fo:inline xsl:use-attribute-sets="i">
      <xsl:apply-templates mode="xhtml"/>
    </fo:inline>
  </xsl:template>
  <xsl:template match="em" mode="xhtml">
    <fo:inline xsl:use-attribute-sets="em">
      <xsl:apply-templates mode="xhtml"/>
    </fo:inline>
  </xsl:template>
	<xsl:template match="sup" mode="xhtml">
		<fo:inline baseline-shift="super">
			<xsl:apply-templates mode="xhtml"/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="sub" mode="xhtml">
		<fo:inline baseline-shift="sub">
			<xsl:apply-templates mode="xhtml"/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="a[@href]" mode="xhtml">
		<fo:basic-link xsl:use-attribute-sets="a-link">
			<xsl:call-template name="process-a-link"/>
		</fo:basic-link>
	</xsl:template>
  <xsl:template match="p" mode="xhtml">
    <fo:block margin-bottom="10pt">
      <xsl:apply-templates mode="xhtml"/>
    </fo:block>
  </xsl:template>
  <xsl:template match="h4" mode="xhtml">
    <fo:block margin-bottom="14px" font-size="15px">
      <xsl:apply-templates mode="xhtml"/>
    </fo:block>
  </xsl:template>
  <xsl:template match="p[@smaller]" mode="xhtml">
    <fo:block font-size="7pt" line-height="8pt">
      <xsl:apply-templates mode="xhtml"/>
    </fo:block>
  </xsl:template>
  <xsl:template match="ul" mode="xhtml">
    <fo:list-block xsl:use-attribute-sets="ul" break-before="page">
      <xsl:apply-templates mode="xhtml"/>
    </fo:list-block>
  </xsl:template>
  <xsl:template match="ol" mode="xhtml">
    <fo:list-block xsl:use-attribute-sets="ol" break-before="page">
      <xsl:apply-templates mode="xhtml"/>
    </fo:list-block>
  </xsl:template>
  <xsl:template match="ul/li" mode="xhtml">
    <fo:list-item margin-top="2mm" xsl:use-attribute-sets="ul-li">
      <xsl:call-template name="process-ul-li"/>
    </fo:list-item>
  </xsl:template>
  <xsl:template name="process-ul-li">
    <fo:list-item-label end-indent="label-end()" text-align="end" wrap-option="wrap">
      <fo:block padding-top="-3pt" font-size="16pt">•</fo:block>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <fo:block>
        <xsl:apply-templates mode="xhtml"/>
      </fo:block>
    </fo:list-item-body>
  </xsl:template>
  <xsl:template match="ol/li" mode="xhtml">
    <fo:list-item margin-top="4pt" xsl:use-attribute-sets="ol-li">
      <xsl:call-template name="process-ol-li"/>
    </fo:list-item>
  </xsl:template>
  <xsl:template name="process-ol-li">
    <fo:list-item-label end-indent="label-end()" text-align="end" wrap-option="wrap">
      <fo:block font-size="10pt">
        <xsl:number format="1."/>
      </fo:block>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <fo:block>
        <xsl:apply-templates mode="xhtml"/>
      </fo:block>
    </fo:list-item-body>
  </xsl:template>
</xsl:stylesheet>