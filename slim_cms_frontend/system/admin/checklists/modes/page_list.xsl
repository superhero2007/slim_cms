<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'page_list']">
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=checklist_edit">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_list">Page List</a>
		</p>
		<h1>Page List</h1>
		<table class="editTable" id="table-page-list">
			<col />
			<col style="width: 10em;" />
			<thead>
				<tr>
					<th scope="col">Page</th>
					<th scope="col">No. of Questions</th>
				</tr>
			</thead>
			<thead>
				<tr>
					<th colspan="2"></th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="2"><input type="button" value="Create Page" onclick="document.location = '?page=checklists&amp;mode=page_edit&amp;checklist_id={$checklist_id}';" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="page[@checklist_id = $checklist_id]">
					<xsl:sort select="@sequence" data-type="number" />
					<tr id="id-{@page_id}">
						<td>
							<xsl:choose>
								<xsl:when test="/config/page_section_2_page[@page_id = current()/@page_id]">
									<xsl:value-of select="concat(/config/page_section[@page_section_id = /config/page_section_2_page[@page_id = current()/@page_id]/@page_section_id]/@title, ' > ' , @title)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@title" />
								</xsl:otherwise>
							</xsl:choose>
							
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=page_edit&amp;checklist_id={$checklist_id}&amp;page_id={@page_id}" title="Edit Page">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=page_list&amp;action=page_delete&amp;checklist_id={$checklist_id}&amp;page_id={@page_id}" title="Delete Page" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td><xsl:value-of select="count(/config/question[@page_id = current()/@page_id])" /></td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		<script type="text/javascript"><xsl:comment>
		$(document).ready(function() {
			// Initialise the table
			$("#table-page-list").tableDnD({
				onDrop: function(tbody, row) {
					$.get('/admin/index.php?page=checklists&amp;action=page_reorder&amp;'+$.tableDnD.serialize());
				}
			});
		});
		</xsl:comment></script>
	</xsl:template>

</xsl:stylesheet>