<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config[@mode = 'list']">
		<form method="get" action="">
			<fieldset style="background: #EEE; padding: 1em;">
				<legend>Refine Reports</legend>
				<input type="hidden" name="page" value="reports" />
				<input type="hidden" name="mode" value="list" />
				<p>
					<label>
						<strong>Checklist: </strong>
						<select name="checklist_id">
							<option value="">-- Select Checklist --</option>
							<xsl:for-each select="checklist">
								<option value="{@checklist_id}">
									<xsl:if test="@checklist_id = /config/globals/item[@key = 'checklist_id']/@value"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
									<xsl:value-of select="@checklist" />
								</option>
							</xsl:for-each>
						</select>
					</label>
					<label>
						<strong>Client: </strong>
						<select name="client_id">
							<option value="">-- Select Client --</option>
							<xsl:for-each select="client">
								<option value="{@client_id}">
									<xsl:value-of select="@company_name" />
									<xsl:text> (</xsl:text>
									<xsl:value-of select="@username" />
									<xsl:text>)</xsl:text>
								</option>
							</xsl:for-each>
						</select>
					</label>
					<input type="submit" value="Go" />
				</p>
			</fieldset>
		</form>
		<form method="post" action="">
			<input type="hidden" name="action" value="regen" />
			<input type="hidden" name="checklist_id" value="{/config/globals/item[@key = 'checklist_id']/@value}" />
			<input type="hidden" name="client_id" value="{/config/globals/item[@key = 'checklist_id']/@value}" />
			
			<table id="userChecklists" class="tablesorter">
				<thead>
					<tr>
						<th scope="col">Options</th>
						<th scope="col">Client</th>
						<th scope="col">Checklist</th>
						<th scope="col">Status</th>
						<th scope="col">Progress</th>
						<th scope="col">Score</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="report">
						<tr>
							<td>
								<input type="checkbox" name="regen_report[]" value="{@client_id}-{@checklist_id}">
									<xsl:if test="@client_report_id = ''"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
								</input>
							</td>
							<th scope="row"><xsl:value-of select="@company_name" /></th>
							<td><xsl:value-of select="@checklist" /></td>
							<td><xsl:value-of select="@status" /></td>
							<td><xsl:value-of select="format-number(@progress,'000')" />%</td>
							<td>
								<xsl:if test="@demerits != ''">
									<xsl:value-of select="format-number(ceiling((@points - @demerits) div @points * 100),'000')" />%
								</xsl:if>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
			<p style="text-align: center;"><input type="submit" value="Regenerate Selected Reports" /></p>
		</form>
		<script type="text/javascript">
		$("#userChecklists").tablesorter({
			headers: {
				0: { sorter: false }
			}
		});
		</script>
	</xsl:template>
	
</xsl:stylesheet>