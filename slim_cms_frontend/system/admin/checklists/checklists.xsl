<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:param name="checklist_id" select="/config/globals/item[@key = 'checklist_id']/@value" />
		
	<xsl:template name="menu">
		<h1><xsl:value-of select="checklist[@checklist_id = $checklist_id]/@name" /> Maintenance</h1>
		<ul id="tabs">
			<li><a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a></li>
			<li><a href="?page=checklists&amp;mode=page_section_list&amp;checklist_id={$checklist_id}">Page Sections</a></li>
			<li><a href="?page=checklists&amp;mode=page_list&amp;checklist_id={$checklist_id}">Checklist Pages</a></li>
			<li><a href="?page=checklists&amp;mode=report_section_list&amp;checklist_id={$checklist_id}">Report Sections</a></li>
			<li><a href="?page=checklists&amp;mode=search&amp;checklist_id={$checklist_id}">Search</a></li>
			<li><a href="?page=checklists&amp;mode=orphans&amp;checklist_id={$checklist_id}">Orphans</a></li>
			<li><a href="?page=checklists&amp;mode=checklist_dump&amp;checklist_id={$checklist_id}">Checklist Dump</a></li>
			<li><a href="?page=checklists&amp;mode=report_dump&amp;checklist_id={$checklist_id}">Report Dump</a></li>
			<li><a href="?page=checklists&amp;mode=audit_list&amp;checklist_id={$checklist_id}">Audit</a></li>
		</ul>
		<br class="clear" />
	</xsl:template>
	
	<xsl:template name="numberOptions">
		<xsl:param name="count" select="0" />
		<xsl:param name="limit" select="100" />
		<xsl:param name="selected" />
		<xsl:param name="prefix" />
		<xsl:param name="suffix" />
		<option value="{$count}">
			<xsl:if test="$count = $selected"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
			<xsl:value-of select="$prefix" />
			<xsl:value-of select="$count" />
			<xsl:value-of select="$suffix" />
		</option>
		<xsl:if test="$count &lt; $limit">
			<xsl:call-template name="numberOptions">
				<xsl:with-param name="count" select="$count + 1" />
				<xsl:with-param name="limit" select="$limit" />
				<xsl:with-param name="selected" select="$selected" />
				<xsl:with-param name="prefix" select="$prefix" />
				<xsl:with-param name="suffix" select="$suffix" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="config">
		<h1>Assessment Maintenance</h1>
		<table id="generic-list-table" class="admin-datatable stripe">
			<col />
			<col style="width: 15em;" />
			<thead>
				<tr>
					<th scope="col">Name</th>
					<th scope="col">No. of Client Assessments</th>
				</tr>
			</thead>
			<thead>
				<tr class="data-filter">
					<th scope="col">Name</th>
					<th scope="col">No. of Client Assessments</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="checklist">
					<xsl:sort select="@name" data-type="text" />
					<tr>
						<td>
							<xsl:value-of select="@name" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={@checklist_id}">edit</a>
								<div style="display:inline; display:none;">
									<xsl:text> | </xsl:text>
									<a href="?page=checklists&amp;action=checklist_delete&amp;checklist_id={@checklist_id}" onclick="return(confirm('Do you really want to delete the \'{@name}\' checklist?'))">delete</a>
								</div>
							</span>
						</td>
						<td><xsl:value-of select="@num_clients" /></td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		
		<div class="admin-datatable-footer-buttons">
			<input type="button" value="Create New Assessment" onclick="document.location = '?page=checklists&amp;mode=checklist_edit';" />
		</div>
	</xsl:template>
	
	<xsl:include href="modes/dump.xsl" />
	<xsl:include href="modes/action_2_answer_edit.xsl" />
	<xsl:include href="modes/action_edit.xsl" />
	<xsl:include href="modes/answer_2_action_edit.xsl" />
	<xsl:include href="modes/answer_2_question_edit.xsl" />
	<xsl:include href="modes/answer_edit.xsl" />
	<xsl:include href="modes/certification_level_edit.xsl" />
	<xsl:include href="modes/checklist_edit.xsl" />
    <xsl:include href="modes/confirmation_edit.xsl" />
	<xsl:include href="modes/commitment_edit.xsl" />
	<xsl:include href="modes/metric_edit.xsl" />
	<xsl:include href="modes/metric_group_edit.xsl" />
	<xsl:include href="modes/orphans.xsl" />
	<xsl:include href="modes/page_edit.xsl" />
	<xsl:include href="modes/page_list.xsl" />
	<xsl:include href="modes/page_section_edit.xsl" />
	<xsl:include href="modes/page_section_list.xsl" />
	<xsl:include href="modes/question_edit.xsl" />
	<xsl:include href="modes/report_section_edit.xsl" />
	<xsl:include href="modes/report_section_list.xsl" />
	<xsl:include href="modes/search.xsl" />
	<xsl:include href="modes/variation_edit.xsl" />
	<xsl:include href="modes/variation_list.xsl" />
	<xsl:include href="modes/audit_edit.xsl" />
	<xsl:include href="modes/audit_list.xsl" />
	<xsl:include href="modes/question_import.xsl" />
	<xsl:include href="modes/resource_edit.xsl" />
	<xsl:include href="modes/form_group_edit.xsl" />
	
	<!-- //International Report Content -->
	<xsl:include href="modes/international_report_section_edit.xsl" />
	<xsl:include href="modes/international_action_edit.xsl" />
	<xsl:include href="modes/international_confirmation_edit.xsl" />

</xsl:stylesheet>