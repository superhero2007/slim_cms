<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'assessmentMetrics']">

		<h2><xsl:value-of select="clientChecklist/@checklist" /> Metrics</h2>
		<xsl:if test="@own_checklist = 'no'">
			<h3>For: <a href="/members/associate/edit-client/?client_id={clientChecklist/@client_id}"><xsl:value-of select="clientChecklist/@company_name"/></a></h3><br />
		</xsl:if>
		<xsl:if test="clientChecklist/@status = 'incomplete'">
			<div class="checklist-complete-message">Checklist Incomplete</div>
		</xsl:if>
		
		<div class="checklist-metrics">
			<xsl:for-each select="clientChecklist/page/metricGroup">
				<xsl:variable name="metricGroup" select="."/>
				<strong><xsl:value-of select="@name" /></strong>
				<table class="audit_table">
					<thead>
						<tr>
							<th scope="col">Metric</th>
							<th scope="col">Value</th>
							<th scope="col">Description</th>
							<th scope="col">Duration</th>
						</tr>
					</thead>
					<xsl:for-each select="$metricGroup/metric">
						<tr>
							<td><xsl:value-of select="@metric" /></td>
							<td><xsl:value-of select="@value" /></td>
							<td><xsl:value-of select="$metricGroup/metric/metricUnitType[@metric_unit_type_id = current()/@metric_unit_type_id]/@description" /></td>
							<td><xsl:value-of select="@months" /> months</td>
						</tr>
					</xsl:for-each>
				</table><br /><br />
			</xsl:for-each>
		</div>

	</xsl:template>
</xsl:stylesheet>