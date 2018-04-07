<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'page_section_edit']">
		
		<xsl:variable name="pageSection" select="page_section[@page_section_id = current()/globals/item[@key = 'page_section_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=checklist_edit">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_section_list">Page Sections List</a>
			<xsl:text> &gt; </xsl:text>
			Page Section: <a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_section_edit&amp;page_section_id={$pageSection/@page_section_id}"><xsl:value-of select="$pageSection/@title" /></a>
		</p>
		<h1>Add / Edit Page Section</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="page_section_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="page_section_id" value="{$pageSection/@page_section_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Page Section" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="metric">Title:</label></th>
						<td><input type="text" id="title" name="title" value="{$pageSection/@title}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="metric">Sequence:</label></th>
						<td><input type="text" id="sequence" name="sequence" value="{$pageSection/@sequence}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
		
		<xsl:if test="$pageSection/@page_section_id">
			<h1>Pages in Section</h1>
		
			<form method="post" action="">
				<input type="hidden" name="action" value="page_section_unlink_page" />
				<input type="hidden" name="page_section_id" value="{$pageSection/@page_section_id}" />
				<input type="hidden" name="checklist_id" value="{$checklist_id}" />
				<input type="hidden" name="mode" value="page_section_edit" />
				<table class="tablesorter" id="table-page-list">
					<tfoot>
						<th colspan="3">
							<input type="submit" value="Unlink Pages" />
						</th>
					</tfoot>
					<thead>
						<tr>
							<th scope="col" width="20%">Page</th>
							<th scope="col" width="20%">Questions</th>
							<th scope="col" width="60%">Content</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="page_section_2_page[@page_section_id = $pageSection/@page_section_id]">
							<tr>
								<td>
									<input type="checkbox" name="page_section_2_page[]" value="{@page_section_2_page_id}" />
									<xsl:value-of select="../page[@page_id = current()/@page_id]/@title" />
								</td>
								<td>
									<xsl:value-of select="count(../question[@page_id = current()/@page_id])" />
								</td>
								<td>
									<xsl:value-of select="../page[@page_id = current()/@page_id]/@content" disable-output-escaping="yes" />
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</form>
		
			<h1>Potential Pages</h1>
		
			<form method="post" action="">
				<input type="hidden" name="action" value="page_section_link_page" />
				<input type="hidden" name="page_section_id" value="{$pageSection/@page_section_id}" />
				<input type="hidden" name="checklist" value="{$checklist_id}" />
				<input type="hidden" name="mode" value="page_section_edit" />
				<table class="editTable">
					<tfoot>
						<th colspan="3">
							<input type="submit" value="Link Pages" />
						</th>
					</tfoot>
					<thead>
						<tr>
							<th scope="col" width="20%">Page</th>
							<th scope="col" width="20%">Questions</th>
							<th scope="col" width="60%">Content</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="page[@checklist_id = $pageSection/@checklist_id]">
							<xsl:sort select="@sequence" />
							<tr>
								<td>
									<input type="checkbox" name="page_id[]" value="{@page_id}" />
									<xsl:value-of select="@title" />
								</td>
								<td>
									<xsl:value-of select="count(../question[@page_id = current()/@page_id])" />
								</td>
								<td>
									<xsl:value-of select="@content" disable-output-escaping="yes" />
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</form>
		</xsl:if>
		
	</xsl:template>
</xsl:stylesheet>