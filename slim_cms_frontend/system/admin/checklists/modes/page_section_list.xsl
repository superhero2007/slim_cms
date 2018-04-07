<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'page_section_list']">
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=checklist_edit">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_section_list">Page Section List</a>
		</p>
		<h1>Page Section List</h1>
		<table id="generic-list-table" class="admin-datatable stripe">
			<col />
			<col style="width: 10em;" />
			<thead>
				<tr>
					<th scope="col">Sequence</th>
					<th scope="col">Page Section</th>
					<th scope="col">No. of Pages</th>
				</tr>
			</thead>
			<thead>
				<tr class="data-filter">
					<th scope="col">Sequence</th>
					<th scope="col">Page Section</th>
					<th scope="col">No. of Pages</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="page_section[@checklist_id = $checklist_id]">
					<xsl:sort select="@sequence" data-type="number" />
					<tr id="id-{@page_section_id}">
						<td width="10%">
							<xsl:value-of select="@sequence" />
						</td>
						<td>
							<xsl:value-of select="@title" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=page_section_edit&amp;checklist_id={$checklist_id}&amp;page_section_id={@page_section_id}" title="Edit Page Section">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=page_section_list&amp;action=page_section_delete&amp;checklist_id={$checklist_id}&amp;page_section_id={@page_section_id}" title="Delete Page Section" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td width="10%">
							<xsl:value-of select="count(/config/page_section_2_page[@page_section_id = current()/@page_section_id])" />
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		
		<div class="admin-datatable-footer-buttons">
			<input type="button" value="Create Page Section" onclick="document.location = '?page=checklists&amp;mode=page_section_edit&amp;checklist_id={$checklist_id}';" />
		</div>
		
	</xsl:template>

</xsl:stylesheet>