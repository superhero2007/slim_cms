<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'resource_edit']">
		<xsl:variable name="report_section" select="report_section[@report_section_id = current()/globals/item[@key = 'report_section_id']/@value]" />
		<xsl:variable name="action" select="action[@action_id = current()/globals/item[@key = 'action_id']/@value]" />
		<xsl:variable name="resource" select="resource[@resource_id = current()/globals/item[@key = 'resource_id']/@value]" />

		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_list&amp;checklist_id={$checklist_id}">Report Section List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}"><xsl:value-of select="$report_section/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=action_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}"><xsl:value-of select="$action/@title" disable-output-escaping="yes" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=resource_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}&amp;resource_id={$resource/@resource_id}">
				<xsl:choose>
					<xsl:when test="$resource">Edit Resource</xsl:when>
					<xsl:otherwise>Create Resource</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Resource</h1>

			<form method="post" action="">
				<input type="hidden" name="action" value="resource_save" />
				<input type="hidden" name="checklist_id" value="{$checklist_id}" />
				<input type="hidden" name="report_section_id" value="{$report_section/@report_section_id}" />
				<input type="hidden" name="action_id" value="{$action/@action_id}" />
				<input type="hidden" name="resource_id" value="{$resource/@resource_id}" />
				<input type="hidden" name="sequence">
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="$resource">
								<xsl:value-of select="$resource/@sequence" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="math:max(resource[@action_id = $action/@action_id]/@sequence)+1" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</input>
				<table class="editTable">
					<tfoot>
						<tr>
							<th colspan="2"><input type="submit" value="Save Resource" /></th>
						</tr>
					</tfoot>
					<tbody>
						<tr>
							<th scope="row"><label for="resource-type-id">Resource Type:</label></th>
							<td>
								<select id="resource_type_id" name="resource_type_id">
									<option value="0">-- Select --</option>
									<xsl:for-each select="resource_type">
										<option value="{@resource_type_id}">
											<xsl:if test="@resource_type_id = $resource/@resource_type_id">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>
											<xsl:value-of select="@description" />
										</option>
									</xsl:for-each>
								</select>
							</td>
						</tr>
						<tr>
							<th scope="row"><label for="description">Description:</label></th>
							<td>
								<input type="text" name="description" value="{$resource/@description}" />
							</td>
						</tr>
						<tr>
							<th scope="row"><label for="url">URL:</label></th>
							<td>
								<input type="text" name="url" value="{$resource/@url}" />
							</td>
						</tr>
					</tbody>
				</table>
			</form>

			<br class="clear" />
			<h3>Resource Hints</h3>
			
			<xsl:for-each select="resource_type">
				<p>
					<strong><i><xsl:value-of select="@description" /></i></strong>
				</p>
				<p>
					<xsl:value-of select="@hint" />
				</p>
			</xsl:for-each>

	</xsl:template>
	
</xsl:stylesheet>