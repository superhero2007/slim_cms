<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'variation_edit']">
		<xsl:variable name="checklist_variation" select="checklist_variation[@checklist_variation_id = current()/globals/item[@key = 'checklist_variation_id']/@value]" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=variation_list">Variation List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=variation_edit&amp;checklist_variation_id={$checklist_variation/@checklist_variation_id}">
				<xsl:choose>
					<xsl:when test="$checklist_variation"><xsl:value-of select="$checklist_variation/@name" /></xsl:when>
					<xsl:otherwise>Add Variation</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Variation</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="checklist_variation_save" />
			<input type="hidden" name="checklist_variation_id" value="{$checklist_variation/@checklist_variation_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Variation" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="name">Variation Name:</label></th>
						<td><input type="text" id="name" name="name" value="{$checklist_variation/@name}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="description">Description:<br />(XHTML)</label></th>
						<td><textarea id="description" name="description" rows="4" cols="45"><xsl:value-of select="$checklist_variation/@description" /></textarea></td>
					</tr>
					<tr>
						<th scope="row"><label for="logo">Logo:</label></th>
						<td><input type="text" id="logo" name="logo" value="{$checklist_variation/@logo}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="company_logo">Company Logo:</label></th>
						<td><input type="text" id="company_logo" name="company_logo" value="{$checklist_variation/@company_logo}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
	
</xsl:stylesheet>