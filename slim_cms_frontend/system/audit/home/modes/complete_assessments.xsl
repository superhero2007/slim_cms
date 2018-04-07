<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config[@mode = 'complete_assessments']">
		<h1>Complete Assessments</h1>
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="index.php">Dashboard</a><xsl:text> &gt; </xsl:text><a href="index.php?mode=complete_assessments">Complete Assessments</a>
		</p>
		<table id="complete">
			<col style="width: 20%;" />
			<col />
			<col style="width: 10%;" />
			<col style="width: 10%;" />
			<col style="width: 20%;" />
			<thead>
				<tr>
					<th scope="col" rowspan="2">Assessment</th>
					<th scope="col" rowspan="2">Client</th>
					<th scope="col" colspan="2">Score</th>
					<th scope="col" rowspan="2">Completed</th>
				</tr>
				<tr>
					
					<th scope="col">Initial</th>
					<th scope="col">Current</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="assessment[@completed != '']">
					<tr>
						<td><xsl:value-of select="@checklist" /></td>
						<td><a href="?page=clients&amp;mode=client_edit&amp;client_id={@client_id}"><xsl:value-of select="@company_name" /></a></td>
						<td><xsl:value-of select="format-number(@initial_score,'##%')" /></td>
						<td><xsl:value-of select="format-number(@current_score,'##%')" /></td>
						<td><xsl:value-of select="@completed" /></td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
<script type="text/javascript">
$("#incomplete").tablesorter({
	cancelSelection: true
});
$("#complete").tablesorter({
	cancelSelection: true,
	headers: {
		2: { sorter: false }
	}

});
</script>
	</xsl:template>
	
</xsl:stylesheet>