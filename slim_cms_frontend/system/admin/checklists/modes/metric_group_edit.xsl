<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'metric_group_edit']">
		<xsl:variable name="page" select="page[@page_id = current()/globals/item[@key = 'page_id']/@value]" />
		<xsl:variable name="metric_group" select="metric_group[@metric_group_id = current()/globals/item[@key = 'metric_group_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=checklist_edit">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_list">Page List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_edit&amp;page_id={$page/@page_id}"><xsl:value-of select="$page/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=metric_group_edit&amp;page_id={$page/@page_id}&amp;metric_group_id={$metric_group/@metric_group_id}">
				<xsl:choose>
					<xsl:when test="$metric_group">Edit Metric Group: <xsl:value-of select="$metric_group/@name" /></xsl:when>
					<xsl:otherwise>Add Metric Group</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Metric Group</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="metric_group_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="page_id" value="{$page/@page_id}" />
			<input type="hidden" name="metric_group_id" value="{$metric_group/@metric_group_id}" />
			<input type="hidden" name="sequence" value="{$metric_group/@sequence}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Metric Group" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="name">Name:</label></th>
						<td><input type="text" id="name" name="name" value="{$metric_group/@name}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="metric_group_type_id">Metric Group Type:</label></th>
						<td>
							<select name="metric_group_type_id">
								<xsl:for-each select="metric_group_type">
									<xsl:sort select="@metric_group_type_id" data-type="number" />
									<option value="{@metric_group_type_id}">
										<xsl:if test="$metric_group/@metric_group_type_id = @metric_group_type_id">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="concat(@metric_group_type_id, ' - ', @description)" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="description">Description:<br />(XHTML)</label></th>
						<td><textarea id="description" name="description" rows="4" cols="45"><xsl:value-of select="$metric_group/@description" /></textarea></td>
					</tr>
				</tbody>
			</table>
		</form>
		<h1>Metrics</h1>
		<table id="table-single-metric-list">
			<thead>
				<tr>
					<th scope="col">Metric</th>
					<th scope="col">Unit Types</th>
					<th scope="col">Default</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="3"><input type="button" value="Add Metric" onclick="document.location = '?page=checklists&amp;mode=metric_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;metric_group_id={$metric_group/@metric_group_id}';" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="metric[@metric_group_id = $metric_group/@metric_group_id]">
				<xsl:sort select="@sequence" data-type="number" />
					<tr id="id-{@metric_id}">
						<td>
							<xsl:value-of select="@metric" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=metric_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;metric_group_id={$metric_group/@metric_group_id}&amp;metric_id={@metric_id}">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=metric_group_edit&amp;action=metric_delete&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;metric_group_id={$metric_group/@metric_group_id}&amp;metric_id={@metric_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td>
							<xsl:for-each select="../metric_unit_type_2_metric[@metric_id = current()/@metric_id]">
								<xsl:value-of select="../metric_unit_type[@metric_unit_type_id = current()/@metric_unit_type_id]/@metric_unit_type" disable-output-escaping="yes" />
								<xsl:if test="position() != last()">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</td>
						<td>
							<xsl:for-each select="../metric_unit_type_2_metric[@metric_id = current()/@metric_id][@default = 1]">
								<xsl:value-of select="../metric_unit_type[@metric_unit_type_id = current()/@metric_unit_type_id]/@metric_unit_type" disable-output-escaping="yes" />
								<xsl:if test="position() != last()">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		
		<script type="text/javascript"><xsl:comment>
			$(document).ready(function() {
				// Initialise the table
				$("#table-single-metric-list").tableDnD({
					onDrop: function(tbody, row) {
						$.get('/admin/index.php?page=checklists&amp;action=single_metric_reorder&amp;'+$.tableDnD.serialize());
					}
				});
			});
		</xsl:comment></script>
		
	</xsl:template>
</xsl:stylesheet>