<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config[@mode = 'incomplete_assessments']">
		<h1>Incomplete Assessments</h1>
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="index.php">Dashboard</a><xsl:text> &gt; </xsl:text><a href="index.php?mode=incomplete_assessments">Incomplete Assessments</a>
		</p>
		<table id="incomplete">
			<col style="width: 20%;" />
			<col />
			<col style="width: 10%;" />
			<col style="width: 15%;" />
			<col style="width: 15%;" />
			<thead>
				<tr>
					<th scope="col">Assessment</th>
					<th scope="col">Client</th>
					<th scope="col">Progress</th>
					<th scope="col">Created</th>
					<th scope="col">Last Activity</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="assessment[@completed = '']">
					<tr>
						<td><xsl:value-of select="@checklist" /></td>
						<td><a href="?page=clients&amp;mode=client_edit&amp;client_id={@client_id}"><xsl:value-of select="@company_name" /></a></td>
						<td><xsl:value-of select="@progress" />%</td>
						<td><xsl:value-of select="@created" /></td>
						<td><xsl:value-of select="@last_activity" /></td>
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