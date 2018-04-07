<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			extension-element-prefixes="date str">

  <!-- //Template for the audit questions -->
    <xsl:template match="auditQuestions" mode="xhtml">
    	<xsl:choose>
			<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@variation_id = '2'">
				<xsl:text>There is nothing to audit for this assessment.</xsl:text>
			</xsl:when>
			<xsl:otherwise>
                <xsl:if test="/config/plugin[@plugin = 'checklist']/report/audit">
                <fo:block>
                  <fo:table font-size="10pt">
                    <fo:table-column column-width="70%" column-number="1"/>
                    <fo:table-column column-width="30%" column-number="2"/>
                    <fo:table-header margin-bottom="4pt">
                      <fo:table-row display-align="before">
                        <fo:table-cell text-align="left" background-color="rgb(240,240,240)" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                          <fo:block font-weight="bold">Question</fo:block>
                        </fo:table-cell>
                        <fo:table-cell text-align="left" background-color="rgb(240,240,240)" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                          <fo:block font-weight="bold">Audit Type</fo:block>
                        </fo:table-cell>
                      </fo:table-row>
                    </fo:table-header>
                    <fo:table-body>
                      <xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/audit">
                        <fo:table-row display-align="before">
                          <fo:table-cell text-align="left" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                            <fo:block>
                              <xsl:value-of select="@question"/>
                            </fo:block>
                          </fo:table-cell>
                          <fo:table-cell text-align="left" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                            <fo:block>
                                <xsl:value-of select="@audit_type"/>
                            </fo:block>
                          </fo:table-cell>
                        </fo:table-row>
                      </xsl:for-each>
                    </fo:table-body>
                  </fo:table>
                </fo:block>
             </xsl:if>
    	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>