<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="#stylesheet"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- 
	//
	// Generic Template for JSChart
	//
	-->
	<xsl:template name="jschart">
		<xsl:param name="chart-type" />

		<xsl:variable name="data" select="/config/plugin[@plugin = 'chartjs'][@method = 'drawChart'][@chart = $chart-type]" />

		<xsl:variable name="height">
			<xsl:choose>
				<xsl:when test="$data/@height">
					<xsl:value-of select="$data/@height" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>1</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="width">
			<xsl:choose>
				<xsl:when test="$data/@width">
					<xsl:value-of select="$data/@width" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>1</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="chartjs ajax-chart data-loading">
			<canvas class="chartjs" data-query-id="{$data/query-data/@query}" data-key="{$data/query-data/@key}" data-timestamp="{$data/query-data/@timestamp}" data-hash="{$data/query-data/@hash}" width="{$width}" height="{$height}" data-type="{$data/@type}" data-colors="{$data/@colors}" data-data-options="{$data/@data-options}" data-chart-options="{$data/@chart-options}">
			</canvas>
			<i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw loader"></i>
		</div>
	</xsl:template>

	<!-- 
	//
	// AusLSA Chart Templates
	//
	-->
	<xsl:template match="auslsa-emissions-pie-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'auslsa-emissions-pie-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="auslsa-electricity-line-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'auslsa-electricity-line-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="auslsa-naturalgas-line-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'auslsa-naturalgas-line-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="auslsa-domesticairtravel-line-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'auslsa-domesticairtravel-line-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="auslsa-internationalairtravel-line-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'auslsa-internationalairtravel-line-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="auslsa-cartravel-line-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'auslsa-cartravel-line-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="auslsa-paper-bar-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'auslsa-paper-bar-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="auslsa-offsets-bar-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'auslsa-offsets-bar-chart'" />
		</xsl:call-template>
	</xsl:template>


	<!-- 
	//
	// TWE Chart Templates
	//
	-->

	<xsl:template match="twe-site-h2o-useage-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'twe-site-h2o-useage-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="twe-site-energy-useage-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'twe-site-energy-useage-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="twe-site-waste-pie-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'twe-site-waste-pie-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="twe-site-water-efficiency" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'twe-site-water-efficiency'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="twe-site-energy-efficiency" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'twe-site-energy-efficiency'" />
		</xsl:call-template>
	</xsl:template>


	<!-- 
	//
	// Bank Australia Chart Templates
	//
	-->

	<xsl:template match="ba-indigenous-owned-business" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'ba-indigenous-owned-business'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="ba-yearly-spend" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'ba-yearly-spend'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="ba-carbon-neutrality" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'ba-carbon-neutrality'" />
		</xsl:call-template>
	</xsl:template>

	<!-- 
	//
	// Generic Chart Templates
	//
	-->

	<xsl:template match="user-access-30-days" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'user-access-30-days'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="average-score-timeline-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'average-score-timeline-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="climate-change-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'climate-change-chart'" />
		</xsl:call-template>
	</xsl:template>	

	<xsl:template match="child-labour-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'child-labour-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="indigenous-owned-business" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'indigenous-owned-business'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="indigenous-gender-owned-business-timeline-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'indigenous-gender-owned-business-timeline-chart'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="female-owned-business" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'female-owned-business'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="australian-owned-business" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'australian-owned-business'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="indigenous-gender-owned-business" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'indigenous-gender-owned-business'" />
		</xsl:call-template>
	</xsl:template>	

	<xsl:template match="australian-owned-business-timeline-chart" mode="html">
		<xsl:call-template name="jschart">
			<xsl:with-param name="chart-type" select="'australian-owned-business-timeline-chart'" />
		</xsl:call-template>
	</xsl:template>	

</xsl:stylesheet>