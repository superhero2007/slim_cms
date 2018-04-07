<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:svg="http://www.w3.org/2000/svg" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:date="http://exslt.org/dates-and-times" 
	xmlns:str="http://exslt.org/strings" 
	extension-element-prefixes="date str">

	<xsl:template match="categoryScores" mode="xhtml">
	  	<fo:block margin-top="14.4pt" margin-bottom="14.4pt">
	    	<fo:table border-collapse="collapse" font-size="9.5pt" background-color="rgb(255,255,255)" width="190mm">
	      		<fo:table-column column-width="30%" column-number="1"/>
	      		<fo:table-column column-width="16.25%" column-number="2"/>
	      		<fo:table-column column-width="16.25%" column-number="3"/>
	      		<fo:table-column column-width="16.25%" column-number="4"/>
	      		<fo:table-column column-width="16.25%" column-number="5"/>
	      		<fo:table-column column-width="5%" column-number="6"/>
	      		<fo:table-header margin-bottom="4pt">
	        		<fo:table-row>
	        			<fo:table-cell><fo:block></fo:block></fo:table-cell>
	          			<fo:table-cell text-align="center">
	            			<fo:block font-size="10pt">Poor</fo:block>
	          			</fo:table-cell>
	          			<fo:table-cell text-align="center">
	            			<fo:block font-size="10pt">Fair</fo:block>
	          			</fo:table-cell>
	          			<fo:table-cell text-align="center">
	            			<fo:block font-size="10pt">Good</fo:block>
	          			</fo:table-cell>
	          			<fo:table-cell text-align="center">
	            			<fo:block font-size="10pt">Excellent</fo:block>
	          			</fo:table-cell>
	          			<fo:table-cell><fo:block></fo:block></fo:table-cell>
	        		</fo:table-row>
	      		</fo:table-header>
	      		<fo:table-body>
	      			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/reportSection[@points &gt; 0]">
						<xsl:variable name="current_rate" select="(@points - @demerits + @merits) div @points"/>
				
						<xsl:variable name="arrowPos">
							<xsl:choose>
								<xsl:when test="$current_rate &lt; 0">0</xsl:when>
								<xsl:when test="$current_rate &gt; 1">1</xsl:when>
								<xsl:otherwise><xsl:value-of select="$current_rate" /></xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<fo:table-row>
							<fo:table-cell>
								<fo:block font-weight="bold" margin-top="3mm">
									<xsl:value-of select="@safe_title" />
								</fo:block>
							</fo:table-cell>
							<fo:table-cell number-columns-spanned="5">
								<fo:block>
									<fo:external-graphic src="url(../util/indicator_arrow.svg)" content-width="133mm" />
								</fo:block>
								<fo:block-container position="relative" margin-top="-11.3mm" margin-left="-1.7mm" width="100%">
									<fo:block margin-left="{$arrowPos * 128}mm">
										<fo:external-graphic src="url(../util/arrow.svg)" content-height="10mm" />
									</fo:block>
								</fo:block-container>
							</fo:table-cell>  
						</fo:table-row>
					</xsl:for-each>
	      		</fo:table-body>
	    	</fo:table>
	  	</fo:block>
	</xsl:template>

</xsl:stylesheet>