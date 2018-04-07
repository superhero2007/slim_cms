<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config">
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
				<td width="25%"><a href="index.php?page=audit&amp;mode=incomplete">Incomplete Audits</a></td><td width="25%"><xsl:value-of select="count(audit[@status != '3' and @status != '4'])" /></td>
				<td width="25%"><a href="index.php?page=audit&amp;mode=complete">Complete Audits</a></td><td width="25%"><xsl:value-of select="count(audit[@status = '4' or @status = '3'])" /></td>
			</tr>
		</table>
	</xsl:template>
	
		<xsl:include href="modes/incomplete_assessments.xsl" />
		<xsl:include href="modes/complete_assessments.xsl" />
</xsl:stylesheet>