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
	<xsl:template match="combinedGHGBarGraph" mode="xhtml">

		<xsl:variable name="graph_url">
			<xsl:text>http://www.greenbizcheck.com/graph/?g=barGraph&amp;w=1000&amp;h=500&amp;graphTitle=Total-Emmissions-(Tons)&amp;unique_time_stamp=</xsl:text>
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-combinedScopeBarGraph</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
				<xsl:sort select="questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value" />
				<xsl:text>&amp;xdata[</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" /><xsl:text>]=</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" />
				<xsl:text>&amp;ydata[</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" /><xsl:text>]=</xsl:text><xsl:value-of select="(sum(../report/metricGroup/clientMetric[@ghg_calculation != 'ignore'][@period = substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)]/@ghg_calculation)) div count(../report/questionAnswer/answer[@answer_type = 'date-month'][substring(@arbitrary_value, 1, 4) = substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)])*12" />
			</xsl:for-each>
		</xsl:variable>
	
		<fo:block>
			<fo:external-graphic src="{$graph_url}" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
        </fo:block>
		
	</xsl:template>
			
	<!-- //Call the line graph from jGraph and send the parameters needed -->		
	<xsl:template match="combinedBarGraph" mode="xhtml">
	
		<!-- //Build the URL for the graph image -->
		<xsl:variable name="graph_url">
			<xsl:text>http://www.greenbizcheck.com/graph/?g=barGraph&amp;w=1000&amp;h=500&amp;graphTitle=Total-Greenhouse-Gas-Output-(Tons)&amp;unique_time_stamp=</xsl:text>
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-combinedScopeBarGraph</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
            	<xsl:if test="position() &gt; (last() - 4)"> <!-- //Only get the last 4 entries -->
                    <xsl:text>&amp;xdata[]=</xsl:text><xsl:value-of select="@certified_date_long_url" />
                    <xsl:text>&amp;ydata[]=</xsl:text><xsl:value-of select="sum(metricGroup/clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation)" />
				</xsl:if>
            </xsl:for-each>
		</xsl:variable>
	
		<fo:block>
			<fo:external-graphic src="{$graph_url}" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
			<!--<xsl:value-of select="$graph_url" /> -->
        </fo:block>
		
	</xsl:template>
	
	<xsl:template match="scope1BarGraph" mode="xhtml">
	
		<!-- //Build the URL for the graph image -->
		<xsl:variable name="graph_url">
			<xsl:text>http://www.greenbizcheck.com/graph/?g=barGraph&amp;w=1000&amp;h=500&amp;graphTitle=Scope-1-Greenhouse-Gas-Output-(Tons)&amp;unique_time_stamp=</xsl:text>
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-scope1BarGraph</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
            	<xsl:if test="position() &gt; (last() - 4)"> <!-- //Only get the last 4 entries -->
                    <xsl:text>&amp;xdata[]=</xsl:text><xsl:value-of select="@certified_date_long_url" />
                    <xsl:text>&amp;ydata[]=</xsl:text><xsl:value-of select="sum(metricGroup[@name = 'Scope 1']/clientMetric/@ghg_calculation)" />
                </xsl:if>
			</xsl:for-each>
		</xsl:variable>
        
		<fo:block>
			<fo:external-graphic src="{$graph_url}" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
		</fo:block>
		
	</xsl:template>
	
	<xsl:template match="scope1GHGBarGraph" mode="xhtml">
	
		<!-- //Build the URL for the graph image -->
		<xsl:variable name="graph_url">
			<xsl:text>http://www.greenbizcheck.com/graph/?g=barGraph&amp;w=1000&amp;h=500&amp;graphTitle=Fuel-Based-Emissions-(Tons)&amp;unique_time_stamp=</xsl:text>
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-scope1BarGraph</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
				<xsl:sort select="questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value" />
				<xsl:text>&amp;xdata[</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" /><xsl:text>]=</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" />
				<xsl:text>&amp;ydata[</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" /><xsl:text>]=</xsl:text><xsl:value-of select="(sum(../report/metricGroup[@name = 'Fuel Based Consumption']/clientMetric[@period = substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)]/@ghg_calculation)) div count(../report/questionAnswer/answer[@answer_type = 'date-month'][substring(@arbitrary_value, 1, 4) = substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)])*12" />
			</xsl:for-each>
		</xsl:variable>
        
		<fo:block>
			<fo:external-graphic src="{$graph_url}" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
		</fo:block>
		
	</xsl:template>
    
	<xsl:template match="scope2BarGraph" mode="xhtml">
		<!-- //Build the URL for the graph image -->
		<xsl:variable name="graph_url">
			<xsl:text>http://www.greenbizcheck.com/graph/?g=barGraph&amp;w=1000&amp;h=500&amp;graphTitle=Scope-2-Greenhouse-Gas-Output-(Tons)&amp;unique_time_stamp=</xsl:text>
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-scope2BarGraph</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
            	<xsl:if test="position() &gt; (last() - 4)"> <!-- //Only get the last 4 entries -->
                    <xsl:text>&amp;xdata[]=</xsl:text><xsl:value-of select="@certified_date_long_url" />
                    <xsl:text>&amp;ydata[]=</xsl:text><xsl:value-of select="sum(metricGroup[@name = 'Scope 2']/clientMetric/@ghg_calculation)" />
                </xsl:if>
			</xsl:for-each>
		</xsl:variable>
	
		<fo:block>
			<fo:external-graphic src="{$graph_url}" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="scope2GHGBarGraph" mode="xhtml">
		
		<!-- //Build the URL for the graph image -->
		<xsl:variable name="graph_url">
			<xsl:text>http://www.greenbizcheck.com/graph/?g=barGraph&amp;w=1000&amp;h=500&amp;graphTitle=Electricity-Based-Emissions-(Tons)&amp;unique_time_stamp=</xsl:text>
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-scope2BarGraph</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
				<xsl:sort select="questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value" />
				<xsl:text>&amp;xdata[</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" /><xsl:text>]=</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" />
				<xsl:text>&amp;ydata[</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" /><xsl:text>]=</xsl:text><xsl:value-of select="(sum(../report/metricGroup[@name = 'Electricity Consumption']/clientMetric[@period = substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)]/@ghg_calculation)) div count(../report/questionAnswer/answer[@answer_type = 'date-month'][substring(@arbitrary_value, 1, 4) = substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)])*12" />
			</xsl:for-each>
		</xsl:variable>
	
		<fo:block>
			<fo:external-graphic src="{$graph_url}" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
		</fo:block>
	</xsl:template>
    
    <xsl:template match="scope3BarGraph" mode="xhtml">
		<!-- //Build the URL for the graph image -->
		<xsl:variable name="graph_url">
			<xsl:text>http://www.greenbizcheck.com/graph/?g=barGraph&amp;w=1000&amp;h=500&amp;graphTitle=Scope-3-Greenhouse-Gas-Output-(Tons)&amp;unique_time_stamp=</xsl:text>
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-scope3BarGraph</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
            	<xsl:if test="position() &gt; (last() - 4)"> <!-- //Only get the last 4 entries -->
                    <xsl:text>&amp;xdata[]=</xsl:text><xsl:value-of select="@certified_date_long_url" />
                    <xsl:text>&amp;ydata[]=</xsl:text><xsl:value-of select="sum(metricGroup[@name = 'Scope 3']/clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation)" />
                </xsl:if>
			</xsl:for-each>
		</xsl:variable>
	
		<fo:block>
			<fo:external-graphic src="{$graph_url}" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
		</fo:block>
	</xsl:template>
    
    <xsl:template match="scope3GHGBarGraph" mode="xhtml">
		<!-- //Build the URL for the graph image -->
		<xsl:variable name="graph_url">
			<xsl:text>http://www.greenbizcheck.com/graph/?g=barGraph&amp;w=1000&amp;h=500&amp;graphTitle=Scope-3-Greenhouse-Gas-Output-(Tons)&amp;unique_time_stamp=</xsl:text>
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-scope3BarGraph</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
				<xsl:sort select="questionAnswer/answer[@answer_type = 'date-quarter']/@arbitrary_value" />
				<xsl:text>&amp;xdata[]=</xsl:text><xsl:value-of select="questionAnswer/answer[@answer_type = 'date-quarter']/@arbitrary_value" />
				<xsl:text>&amp;ydata[]=</xsl:text><xsl:value-of select="(sum(metricGroup[@name = 'Scope 3']/clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation))" />
			</xsl:for-each>
		</xsl:variable>
	
		<fo:block>
			<fo:external-graphic src="{$graph_url}" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
		</fo:block>
	</xsl:template>	
	
	<!-- //Bar Graph for Electricity Dollars @ NRA -->
	
	<xsl:template match="electricityBarGraph" mode="xhtml">
	
		<!-- //Build the URL for the graph image -->
		<xsl:variable name="graph_url">
			<xsl:text>http://www.greenbizcheck.com/graph/?g=barGraph&amp;w=1000&amp;h=500&amp;graphTitle=Electricity-Cost-per-Square-Foot(in-$)&amp;unique_time_stamp=</xsl:text>
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-electricity-cost</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
				<xsl:sort select="questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value" />
				<xsl:text>&amp;xdata[</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" /><xsl:text>]=</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" />

				<xsl:text>&amp;ydata[</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" /><xsl:text>]=</xsl:text><xsl:value-of select="(sum(../report/metricGroup[@name = 'Electricity Consumption (dollars)']/clientMetric[@period = substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)]/@value) div current()/questionAnswer/answer[@answer_type = 'int']/@arbitrary_value) div count(../report/questionAnswer/answer[@answer_type = 'date-month'][substring(@arbitrary_value, 1, 4) = substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)])*12" />		
			</xsl:for-each>
		</xsl:variable>
        
		<fo:block>
			<fo:external-graphic src="{$graph_url}" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
		</fo:block>
		
	</xsl:template>
	
	<xsl:template match="averageIndustryElectricityCost" mode="xhtml">
	
		<xsl:variable name="average-annual-electricity-cost" select="31878" />
		<xsl:variable name="average-annual-store-size" select="817" />
		
		<fo:block margin-bottom="10mm">
			The industry average cost of electricity is $<xsl:value-of select="format-number(($average-annual-electricity-cost div $average-annual-store-size), '###,##0.00')" />/m<fo:inline vertical-align="super" font-size="8pt">2</fo:inline> per annum.
		</fo:block>

	</xsl:template>
	
	<!-- //Bar Graph for Electricity KWH @ NRA -->
	
	<xsl:template match="electricityKwhBarGraph" mode="xhtml">
	
		<!-- //Build the URL for the graph image -->
		<xsl:variable name="graph_url">
			<xsl:text>http://www.greenbizcheck.com/graph/?g=barGraph&amp;w=1000&amp;h=500&amp;graphTitle=Electricity-Consumption-per-Square-Foot(kWh)&amp;unique_time_stamp=</xsl:text>
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-electricity-consumption</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
				<xsl:sort select="questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value" />
				<xsl:text>&amp;xdata[</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" /><xsl:text>]=</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" />

				<xsl:text>&amp;ydata[</xsl:text><xsl:value-of select="substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)" /><xsl:text>]=</xsl:text><xsl:value-of select="(sum(../report/metricGroup[@name = 'Electricity Consumption']/clientMetric[@period = substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)]/@value) div current()/questionAnswer/answer[@answer_type = 'int']/@arbitrary_value) div count(../report/questionAnswer/answer[@answer_type = 'date-month'][substring(@arbitrary_value, 1, 4) = substring(current()/questionAnswer/answer[@answer_type = 'date-month']/@arbitrary_value, 1, 4)])*12" />		
			</xsl:for-each>
		</xsl:variable>
        
		<fo:block>
			<fo:external-graphic src="{$graph_url}" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
		</fo:block>
		
	</xsl:template>
	
	<xsl:template match="averageIndustryElectricityConsumption" mode="xhtml">
	
		<xsl:variable name="average-annual-electricity-consumption" select="171444" />
		<xsl:variable name="average-annual-store-size" select="817" />
		
		<fo:block margin-bottom="10mm">
			The industry average consumption of electricity is <xsl:value-of select="format-number(($average-annual-electricity-consumption div $average-annual-store-size), '###,##0.00')" />kWh/Square Foot per annum.
		</fo:block>

	</xsl:template>
	
	<xsl:template match="averageIndustryElectricityCost" mode="xhtml">
	
		<xsl:variable name="average-annual-electricity-cost" select="31878" />
		<xsl:variable name="average-annual-store-size" select="817" />
		
		<fo:block margin-bottom="10mm">
			The industry average cost of electricity is $<xsl:value-of select="format-number(($average-annual-electricity-cost div $average-annual-store-size), '###,##0.00')" />/Square Foot per annum.
		</fo:block>

	</xsl:template>
	
	<xsl:template match="radarGraphCategoryScores" mode="xhtml">
		<!-- //Build the URL for the graph image -->
		<xsl:variable name="graph_url">
			<xsl:text>http://www.greenbizcheck.com/graph/?g=radarGraph&amp;w=900&amp;h=700&amp;graphTitle=Category-Scores&amp;unique_time_stamp=</xsl:text>
			<xsl:variable name="unique_time_stamp" select="concat(/config/datetime/@year,/config/datetime/@month,/config/datetime/@day,/config/datetime/@hour,/config/datetime/@minute,/config/datetime/@second)" />
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-category-scores</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/reportSection">
				<xsl:if test="(count(../action[@report_section_id = current()/@report_section_id]) &gt; 0) or (count(../confirmation[@report_section_id = current()/@report_section_id]) &gt; 0)">
					<xsl:variable name="current_score" select="format-number(((@points - @demerits + @merits) div @points)*100,'#')" />
					<xsl:text>&amp;xdata[</xsl:text><xsl:value-of select="@report_section_id" /><xsl:text>]=</xsl:text><xsl:value-of select="translate(@safe_title,' ','-')" />
					<xsl:text>&amp;ydata[</xsl:text><xsl:value-of select="@report_section_id" /><xsl:text>]=</xsl:text><xsl:value-of select="$current_score" />		
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
        
		<fo:block>
			<fo:external-graphic src="{$graph_url}" content-width="7.5in" content-height="6in"></fo:external-graphic>
		</fo:block>
	</xsl:template>

     <xsl:template match="googleImageChart" mode="xhtml">
         <xsl:variable name="graph_url">
			<xsl:text>http://chart.googleapis.com/chart?</xsl:text>
            <xsl:text>&amp;cht=bvs</xsl:text>					<!-- //Chart Type -->
            <xsl:text>&amp;chco=008000</xsl:text>				<!-- //Colour -->
            <xsl:text>&amp;chdl=Tons</xsl:text>				<!-- //Data Label -->
   			<xsl:text>&amp;chdlp=t</xsl:text>
   			<xsl:text>&amp;chtt=Scope+1</xsl:text>				<!-- //Chart Label -->
            <xsl:text>&amp;chs=800x300</xsl:text>				<!-- //Chart Size -->
            <xsl:text>&amp;chbh=a</xsl:text>
            <xsl:text>&amp;chxr=0,0,130000|1,0,0</xsl:text>
            <xsl:text>&amp;chxt=y,x</xsl:text>
			
            <!-- //Variable Data -->
            <xsl:text>&amp;chxl=1:=</xsl:text>
            <xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
				<xsl:text>|</xsl:text><xsl:value-of select="@certified_date_long_url" />
			</xsl:for-each>
            
            <!-- //Variable Data -->
            <xsl:text>&amp;chd=t:</xsl:text>
            <xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
				<xsl:value-of select="sum(metricGroup[@name = 'Scope 1']/clientMetric/@ghg_calculation)" />
                <xsl:if test="position() != last()">
                	<xsl:text>,</xsl:text>
                </xsl:if>
			</xsl:for-each>
            
            <!-- //Finish with the unique time stamp to refresh the image cache -->
            <xsl:text>&amp;unique_time_stamp=</xsl:text>
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-scope-1-graph</xsl:text>
            
		</xsl:variable>
    </xsl:template>
    
    <!-- //Template for Rendering a Pie Graph for the last GHG Entry -->
	<xsl:template match="lastGHGEntryPieGraph" mode="xhtml">
		<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
        	<xsl:if test="position() = last()"> 
            
                <xsl:variable name="totalScopeValue">
                    <xsl:value-of select="sum(metricGroup/clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation)" />
                </xsl:variable>
			
            	<!-- //Build the URL for the graph image -->
                <xsl:variable name="graph_url">
                    <xsl:text>http://www.greenbizcheck.com/graph/?g=pie3dGraph&amp;w=1000&amp;h=500&amp;graphTitle=Total-Greenhouse-Gas-Output-(Tons)&amp;unique_time_stamp=</xsl:text>
                    <xsl:value-of select="$unique_time_stamp" />
                    <xsl:text>-combinedScopePieGraph</xsl:text>
                                      
                    <xsl:for-each select="metricGroup">
                    	<xsl:text>&amp;data[]=</xsl:text>
                        <xsl:value-of select="((sum(clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation)) div $totalScopeValue)*100" />
                        <xsl:text>&amp;legend[]=</xsl:text><xsl:value-of select="translate(@name,' ','-')" />
                        <xsl:text>&amp;labels[]=</xsl:text><xsl:value-of select="translate(concat(sum(clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation), ' Tons'), ' ','-')" />
                    </xsl:for-each>
                </xsl:variable>
            
                <fo:block>
                    <fo:external-graphic src="{$graph_url}" content-width="{$graph-content-width}" content-height="{$graph-content-height}"></fo:external-graphic>
                 	<!--<xsl:value-of select="$graph_url" /> -->
                </fo:block>
            
            </xsl:if>
      	</xsl:for-each>
  	</xsl:template>
    
    
    <!-- //Template for Rendering a Pie Graph for the last GHG Entry -->
	<xsl:template match="lastGHGEntryPieGraphItems" mode="xhtml">
		<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report">
        	<xsl:if test="position() = last()"> 
            
                <xsl:variable name="totalScopeValue">
                    <xsl:value-of select="sum(metricGroup/clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation)" />
                </xsl:variable>
			
            	<!-- //Build the URL for the graph image -->
                <xsl:variable name="graph_url">
                    <xsl:text>http://www.greenbizcheck.com/graph/?g=pieGraph&amp;w=950&amp;h=750&amp;graphTitle=Total-Greenhouse-Gas-Output-(Tons)&amp;unique_time_stamp=</xsl:text>
                    <xsl:value-of select="$unique_time_stamp" />
                    <xsl:text>-combinedScopePieGraph</xsl:text>
                                      
                    <xsl:for-each select="metricGroup/clientMetric[@ghg_calculation != 'ignore']">
                    	<xsl:text>&amp;data[]=</xsl:text>
                        <xsl:value-of select="(@ghg_calculation div $totalScopeValue)*100" />
                        <xsl:text>&amp;legend[]=</xsl:text><xsl:value-of select="translate(@metric,' ','-')" />
                        <xsl:text>&amp;labels[]=</xsl:text><xsl:value-of select="translate(concat(@ghg_calculation, ' Tons'), ' ','-')" />
                    </xsl:for-each>
                </xsl:variable>
            
                <fo:block>
                    <fo:external-graphic src="{$graph_url}" content-width="170mm" content-height="160mm"></fo:external-graphic>
                 	<!-- <xsl:value-of select="$graph_url" /> -->
                </fo:block>
            
            </xsl:if>
      	</xsl:for-each>
  	</xsl:template>
	
</xsl:stylesheet>