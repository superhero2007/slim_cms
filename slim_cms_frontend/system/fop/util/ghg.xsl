<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			extension-element-prefixes="date str">
            
	<!-- //Template for GHG Protocol Scope Questions -->
	
	<xsl:template match="ghgMetricAnswers" mode="xhtml">
		    <xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
    			<!--<xsl:if test="metricGroup/clientMetric/@ghg_calculations != ''">-->
    			<fo:block margin-top="20">
    				<fo:inline font-weight="bold"><xsl:value-of select="@checklist" /> completed on <xsl:value-of select="@certified_date_long" /></fo:inline>
    			</fo:block>
    			<xsl:for-each select="metricGroup">
				<fo:block margin-top="10">
    				<xsl:value-of select="@name" />
    			</fo:block>
      				<fo:table font-size="10pt">
        				<fo:table-column column-width="70%" column-number="1"/>
        				<fo:table-column column-width="30%" column-number="2"/>
        				<fo:table-header margin-bottom="4pt">
          					<fo:table-row display-align="before">
          					
            					<fo:table-cell text-align="left" background-color="rgb(240,240,240)" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
              						<fo:block font-weight="bold">Scope Item</fo:block>
            					</fo:table-cell>
            				
								<fo:table-cell text-align="left" background-color="rgb(240,240,240)" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
              						<fo:block font-weight="bold">CO2-e</fo:block>
            					</fo:table-cell>
          					
							</fo:table-row>
        				</fo:table-header>
        				<fo:table-body>
          					<xsl:for-each select="clientMetric">
            					<fo:table-row display-align="before">
              						<fo:table-cell text-align="left" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block>
                  							<xsl:value-of select="@metric"/>
                						</fo:block>
              						</fo:table-cell>
              						<fo:table-cell text-align="right" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block>
											<xsl:value-of select="format-number(@ghg_calculation, '###,###')" />
										</fo:block>
              						</fo:table-cell>
            					</fo:table-row>
          					</xsl:for-each>
        				</fo:table-body>
      				</fo:table>
      				<!-- //Add a table footer to calculate the total for the current scope  - Table footers not working so workaround as a separate table -->
      				<fo:table font-size="10pt">
        				<fo:table-column column-width="70%" column-number="1"/>
        				<fo:table-column column-width="30%" column-number="2"/>
        				<fo:table-body>
            					<fo:table-row display-align="before">
              						<fo:table-cell text-align="right" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block font-weight="bold">
                  							Total <xsl:value-of select="@name" /> CO2-e
                						</fo:block>
              						</fo:table-cell>
              						<fo:table-cell text-align="right" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block font-weight="bold">
											<xsl:value-of select="format-number(sum(clientMetric/@ghg_calculation), '###,###')" />
										</fo:block>
              						</fo:table-cell>
            					</fo:table-row>
        				</fo:table-body>
        			</fo:table>
      			<!--</xsl:if> -->
      			</xsl:for-each>
      		</xsl:for-each>
  	</xsl:template>
	
	<!-- //End of the GHG Protocol Scope Questions -->
  
    <!-- //Template for the grouped metrics list -->
    <xsl:template match="listGroupedMetrics" mode="xhtml">
    	
    		<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
    			<xsl:if test="metricGroup ">
    			<fo:block margin-top="20">
    				<xsl:value-of select="@checklist" /> completed on <xsl:value-of select="@certified_date" />
    			</fo:block>
    			<xsl:for-each select="metricGroup">
				<fo:block margin-top="10">
    				<xsl:value-of select="@name" />
    			</fo:block>
      				<fo:table font-size="10pt">
        				<fo:table-column column-width="50%" column-number="1"/>
        				<fo:table-column column-width="15%" column-number="2"/>
        				<fo:table-column column-width="20%" column-number="3"/>
        				<fo:table-column column-width="15%" column-number="4"/>
        				
        				<fo:table-header margin-bottom="4pt">
          					<fo:table-row display-align="before">
          					
            					<fo:table-cell text-align="left" background-color="rgb(240,240,240)" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
              						<fo:block font-weight="bold">Metric</fo:block>
            					</fo:table-cell>
            				
								<fo:table-cell text-align="left" background-color="rgb(240,240,240)" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
              						<fo:block font-weight="bold">Value</fo:block>
            					</fo:table-cell>
            				
								<fo:table-cell text-align="left" background-color="rgb(240,240,240)" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
              						<fo:block font-weight="bold">Description</fo:block>
            					</fo:table-cell>
            				
								<fo:table-cell text-align="left" background-color="rgb(240,240,240)" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
              						<fo:block font-weight="bold">Duration</fo:block>
            					</fo:table-cell>
          					
							</fo:table-row>
        				</fo:table-header>
        				<fo:table-body>
          				<xsl:for-each select="clientMetric">
            					<fo:table-row display-align="before">
              						<fo:table-cell text-align="left" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block>
                  							<xsl:value-of select="@metric"/>
                						</fo:block>
              						</fo:table-cell>
              						<fo:table-cell text-align="left" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block>
											<xsl:value-of select="@value"/>
										</fo:block>
              						</fo:table-cell>
                            		<fo:table-cell text-align="left" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block>
											<xsl:value-of select="@description"/>
										</fo:block>
              						</fo:table-cell>
                            		<fo:table-cell text-align="left" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block>
											<xsl:value-of select="@months"/>
										</fo:block>
              						</fo:table-cell>
            					</fo:table-row>
          					</xsl:for-each>
        				</fo:table-body>
      				</fo:table>
      			</xsl:for-each>
      			</xsl:if>
      		</xsl:for-each>
  	</xsl:template>
  
  <!-- //End of metrics list -->
  
  
  	<!-- //Template for GHG Protocol Scope Questions -->
	
	<xsl:template match="lastGHGEntry" mode="xhtml">
		<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
        	<xsl:if test="position() = last()">    
            
            
    			<!--<xsl:if test="metricGroup/clientMetric/@ghg_calculations != ''">-->
    			<fo:block margin-top="20">
    				<fo:inline font-weight="bold"><xsl:value-of select="@checklist" /> completed on <xsl:value-of select="@certified_date_long" /></fo:inline>
    			</fo:block>
    			<xsl:for-each select="metricGroup">
				<fo:block margin-top="10">
    				<xsl:value-of select="@name" />
    			</fo:block>
      				<fo:table font-size="10pt">
        				<fo:table-column column-width="70%" column-number="1"/>
        				<fo:table-column column-width="30%" column-number="2"/>
        				<fo:table-header margin-bottom="4pt">
          					<fo:table-row display-align="before">
          					
            					<fo:table-cell text-align="left" background-color="rgb(240,240,240)" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
              						<fo:block font-weight="bold">Scope Item</fo:block>
            					</fo:table-cell>
            				
								<fo:table-cell text-align="left" background-color="rgb(240,240,240)" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
              						<fo:block font-weight="bold">CO2-e</fo:block>
            					</fo:table-cell>
          					
							</fo:table-row>
        				</fo:table-header>
        				<fo:table-body>
          					<xsl:for-each select="clientMetric[@ghg_calculation != 'ignore']">
            					<fo:table-row display-align="before">
              						<fo:table-cell text-align="left" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block>
                  							<xsl:value-of select="@metric"/>
                						</fo:block>
              						</fo:table-cell>
              						<fo:table-cell text-align="right" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block>
											<xsl:value-of select="format-number(@ghg_calculation, '###,###')" />
										</fo:block>
              						</fo:table-cell>
            					</fo:table-row>
          					</xsl:for-each>
        				</fo:table-body>
      				</fo:table>
      				<!-- //Add a table footer to calculate the total for the current scope  - Table footers not working so workaround as a separate table -->
      				<fo:table font-size="10pt">
        				<fo:table-column column-width="70%" column-number="1"/>
        				<fo:table-column column-width="30%" column-number="2"/>
        				<fo:table-body>
            					<fo:table-row display-align="before">
              						<fo:table-cell text-align="right" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block font-weight="bold">
                  							Total <xsl:value-of select="@name" /> CO2-e
                						</fo:block>
              						</fo:table-cell>
              						<fo:table-cell text-align="right" border-style="solid" border-width="0.5pt" border-color="rgb(128,128,128)" padding="6pt">
                						<fo:block font-weight="bold">
											<xsl:value-of select="format-number(sum(clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation), '###,###')" />
										</fo:block>
              						</fo:table-cell>
            					</fo:table-row>
        				</fo:table-body>
        			</fo:table>
      			<!--</xsl:if> -->
      			</xsl:for-each>
     		</xsl:if>
      	</xsl:for-each>
  	</xsl:template>
  	
  		<!-- //Compare the current result of GHG with the average -->
	<xsl:template match="averageGHGResult" mode="xhtml">
		<xsl:variable name="averageResult" select="0.0129" />
		<xsl:variable name="floorSpace" select="/config/plugin[@plugin = 'checklist'][@method = 'loadGroupedReportPdf']/report/questionAnswer/answer[@answer_id = '23373' or @answer_id = '18869']/@arbitrary_value" />
		<xsl:variable name="ghgResult" select="format-number(((sum(/config/plugin[@plugin = 'checklist'][@method = 'loadGroupedReportPdf']/report/metricGroup/clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation)*12)), '###,##0.000')" />
		<xsl:variable name="ghgFloorSpaceResult" select="$ghgResult div $floorSpace" />
		
		<fo:block-container background-color="rgb(221,234,251)" padding-top="5mm" padding-bottom="5mm" color="rgb(0,44,93)" margin-bottom="5mm">
			<xsl:choose>
				<xsl:when test="$averageResult &gt; $ghgFloorSpaceResult">
					<fo:block margin-bottom="5mm" font-weight="bold">Your result is below average.</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<fo:block margin-bottom="5mm" font-weight="bold">Your result is above average.</fo:block>
				</xsl:otherwise>
			</xsl:choose>
			
			<fo:block margin-bottom="5mm">The average result is <xsl:value-of select="format-number($averageResult,'###,##0.000')" /> Tonnes CO2-e per square metre of floor space. Your result is <xsl:value-of select="format-number($ghgFloorSpaceResult, '###,##0.000')" /> Tonnes CO2-e per square metre of floor space.</fo:block>
			
		</fo:block-container>
		
	</xsl:template>
	
	<!-- //End of the GHG Protocol Scope Questions -->
    
</xsl:stylesheet>