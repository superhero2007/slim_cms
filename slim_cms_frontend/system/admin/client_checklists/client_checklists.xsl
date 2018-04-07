<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:exsl="http://exslt.org/common"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-extension-prefixes="exsl">

	<xsl:template name="menu">
		<h1>Client Checklists</h1>
	</xsl:template>

	<xsl:template match="config">
		<xsl:variable name="al" select="'abcdefghijklmnopqrstuvwxyz'" />
		<xsl:variable name="au" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
		<xsl:variable name="q" select="translate(/config/globals/item[@key = 'q']/@value,$au,$al)" />
		<xsl:variable name="in" select="/config/globals/item[@key = 'in']/@value" />
	
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=dashboard">Client Checklists</a>
		</p>
		<table id="clientChecklistDataTable" class="admin-datatable stripe">
			<thead>
				<tr>
					<th scope="col">Client</th>
                    <th scope="col">Assessment</th>
                    <th scope="col">Date Started</th>
					<th scope="col">Date Completed</th>
					<th scope="col">Score</th>
					<th scope="col">Status</th>
				</tr>
			</thead>
			<thead>
				<tr class="data-filter">
					<th scope="col">Client</th>
                    <th scope="col">Assessment</th>
                    <th scope="col">Date Started</th>
					<th scope="col">Date Completed</th>
					<th scope="col">Score</th>
					<th scope="col">Status</th>
				</tr>
			</thead>
			<tbody>
				<xsl:apply-templates select="client" mode="row" />
			</tbody>
		</table>
		
	<script type="text/javascript">
	$("#checklistList").tablesorter({
		cancelSelection: true
	});
	</script>
	</xsl:template>
	
	<xsl:template match="client" mode="row">
		<xsl:variable name="client_id" select="@client_id" />
		<tr>
			<xsl:attribute name="class">client</xsl:attribute>
			<td>
				<xsl:value-of select="@company_name" />
				<br />
				<span class="options">
					<a href="?page=clients&amp;mode=client_edit&amp;client_id={@client_id}" title="Edit">edit</a>
				</span>
			</td>
            <td>
            	<xsl:value-of select="@assessment_name" />
				<br />
				<span class="options">
					<a href="?page=clients&amp;mode=client_checklist_edit&amp;client_id={@client_id}&amp;client_checklist_id={@client_checklist_id}" title="Edit">edit</a>
					<xsl:text> | </xsl:text>
					<a href="?page=clients&amp;mode=client_checklist_answer_report&amp;client_id={@client_id}&amp;client_checklist_id={@client_checklist_id}">answer report</a>
					<xsl:text> | </xsl:text>
					<a href="?page=clients&amp;mode=client_checklist_edit&amp;action=export_client_results&amp;client_id={@client_id}&amp;client_checklist_id={@client_checklist_id}">export answers</a>
				</span>
            </td>
            <td><xsl:value-of select="@created" /></td>
			<td><xsl:value-of select="@completed" /></td>
			<td><xsl:value-of select="format-number(@current_score, '###%')" /></td>
			<td>
				<xsl:choose>
					<xsl:when test="@completed = ''">Incomplete</xsl:when>
					<xsl:otherwise>Complete</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>