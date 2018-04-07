<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="config[@mode = 'certification_level_edit']">
		<xsl:variable name="certification_level" select="certification_level[@certification_level_id = current()/globals/item[@key = 'certification_level_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=checklist_edit">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=certification_level_edit&amp;certification_level_id={$certification_level/@certification_level_id}">
				<xsl:choose>
					<xsl:when test="$certification_level"><xsl:value-of select="$certification_level/@name" /></xsl:when>
					<xsl:otherwise>Add Certification Level</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Certification Level</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="certification_level_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="certification_level_id" value="{$certification_level/@certification_level_id}" />
			<table class="editTable">
				<thead>
					<tr>
						<th colspan="2"></th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Certification Level" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="name">Name:</label></th>
						<td><input type="text" id="name" name="name" value="{$certification_level/@name}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="target">Target %:</label></th>
						<td><input type="text" id="target" name="target" value="{$certification_level/@target}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="progress-bar-color">Color (6 character hex, no hash):</label></th>
						<td><input type="text" id="progress-bar-color" name="progress_bar_color" value="{$certification_level/@progress_bar_color}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="audit-required">Audit Required:</label></th>
						<td>
                        	<input type="hidden" name="audit_required" value="0" /> 
                            <input type="checkbox" name="audit_required" value="1">
                            	<xsl:if test="$certification_level/@audit_required= '1'">
                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input>
                            <xsl:text>Yes</xsl:text>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="audit_item_count">Audit Item Count:</label></th>
						<td><input type="text" id="audit_item_count" name="audit_item_count" value="{$certification_level/@audit_item_count}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
	
</xsl:stylesheet>