<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config">
		<h1>GreenBizCheck Admin</h1>
	</xsl:template>

	<xsl:template match="config-old">
		<h1>Dashboard</h1>
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="index.php">Dashboard</a>
		</p>
		<table>
			<thead>
				<tr>
					<th colspan ="4">Fast Facts</th>
				</tr>
			</thead>
			<tr class="even">
				<td width="25%"><a href="index.php?mode=complete_assessments">Complete Assessments</a></td><td width="25%"><xsl:value-of select="count(assessment[@completed != ''])" /></td>
				<td width="25%"><a href="index.php?mode=incomplete_assessments">Incomplete Assessments</a></td><td width="25%"><xsl:value-of select="count(assessment[@completed = ''])" /></td>
			</tr>
			<tr class="odd">
				<td width="25%"><a href="index.php?page=clients">Clients</a></td><td width="25%"><xsl:value-of select="count(client[@client_type_id = '1'])" /></td>
				<td width="25%"><a href="index.php?page=franchisees">Business Owners</a></td><td width="25%"><xsl:value-of select="count(client[@client_type_id = '2'])" /></td>
			</tr>
		</table>
	</xsl:template>
</xsl:stylesheet>