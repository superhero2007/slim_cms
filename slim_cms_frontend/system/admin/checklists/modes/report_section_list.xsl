<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'report_section_list']">
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_list&amp;checklist_id={$checklist_id}">Report Section List</a>
		</p>
		<h1>Report Section List</h1>
		<p>This is the report section list for this checklist. To edit a report section or to access the associated actions click "edit" in the corrosponding row. The report sections are in the order they will appear to the client, you can reorder the rows by simply draging the rows into the right order.</p>
		<table class="tablesorter" id="table-report-section-list">
			<col />
			<col style="width: 10em;" />
			<thead>
				<tr>
					<th scope="col">Report Section</th>
					<th scope="col">Display in PDF</th>
					<th scope="col">Display in HTML</th>
					<th scope="col">Multi Site Content</th>
					<th scope="col">Number of Actions</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="5"><input type="button" value="Create New Report Section" onclick="document.location='?page=checklists&amp;mode=report_section_edit&amp;checklist_id={$checklist_id}';" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="report_section[@checklist_id = $checklist_id]">
					<xsl:sort select="@sequence" data-type="number" />
					<tr id="id-{@report_section_id}">
						<td>
							<xsl:value-of select="@title" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={@report_section_id}" alt="Edit Report Section">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=report_section_list&amp;action=report_section_delete&amp;checklist_id={$checklist_id}&amp;report_section_id={@report_section_id}" alt="Delete Report Section" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td>
							<xsl:if test="@display_in_pdf = '1'">Yes</xsl:if>
							<xsl:if test="@display_in_pdf = '0'"></xsl:if>
						</td>
						<td>
							<xsl:if test="@display_in_html = '1'">Yes</xsl:if>
							<xsl:if test="@display_in_html = '0'"></xsl:if>
						</td>
						<td>
							<xsl:if test="@multi_site = '1'">Yes</xsl:if>
							<xsl:if test="@multi_site = '0'"></xsl:if>
						</td>
						<td><xsl:value-of select="count(/config/action[@report_section_id = current()/@report_section_id])" /></td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
<script type="text/javascript"><xsl:comment>
$(document).ready(function() {
	// Initialise the table
	$("#table-report-section-list").tableDnD({
		onDrop: function(tbody, row) {
			$.get('/admin/index.php?page=checklists&amp;action=report_section_reorder&amp;'+$.tableDnD.serialize());
		}
	});
});
</xsl:comment></script>
	</xsl:template>
	
</xsl:stylesheet>