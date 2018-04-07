<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'commitment_edit']">
		<xsl:variable name="report_section" select="report_section[@report_section_id = current()/globals/item[@key = 'report_section_id']/@value]" />
		<xsl:variable name="action" select="action[@action_id = current()/globals/item[@key = 'action_id']/@value]" />
		<xsl:variable name="commitment" select="commitment[@commitment_id = current()/globals/item[@key = 'commitment_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_list&amp;checklist_id={$checklist_id}">Report Section List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}"><xsl:value-of select="$report_section/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=action_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}"><xsl:value-of select="$action/@summary" disable-output-escaping="yes" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=commitment_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}&amp;commitment_id={$commitment/@commitment_id}">
				<xsl:choose>
					<xsl:when test="$commitment"><xsl:value-of select="$commitment/@commitment" disable-output-escaping="yes" /></xsl:when>
					<xsl:otherwise>Add Commitment Option</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Commitment</h1>
		<p>Commitments are options presented to the user in their report that we suggest they commit to.</p>
		<form method="post" action="">
			<input type="hidden" name="action" value="commitment_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="report_section_id" value="{$report_section/@report_section_id}" />
			<input type="hidden" name="action_id" value="{$action/@action_id}" />
			<input type="hidden" name="commitment_id" value="{$commitment/@commitment_id}" />
			<input type="hidden" name="sequence">
				<xsl:attribute name="value">
					<xsl:choose>
						<xsl:when test="$commitment"><xsl:value-of select="$commitment/@sequence" /></xsl:when>
						<xsl:otherwise><xsl:value-of select="math:max(commitment[@action_id = $action/@action_id]/@sequence)+1" /></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</input>
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Commitment" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="commitment">Commitment:</label></th>
						<td><input type="text" id="commitment" name="commitment" value="{$commitment/@commitment}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="merits">Merit Points:</label></th>
						<td><input type="text" id="merits" name="merits" value="{$commitment/@merits}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="commitment-fieldset-id">Commitment Fieldset:</label></th>
						<td>
							<select id="commitment-fieldset-id" name="commitment_fieldset_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="commitment_fieldset">
									<option value="{@commitment_fieldset_id}">
										<xsl:if test="@commitment_fieldset_id = $commitment/@commitment_fieldset_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@fieldset" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
		<h2>Attached Action</h2>
		<p><strong>Demerits Points: </strong><xsl:value-of select="$action/@demerits" /></p>
		<xsl:value-of select="$action/@proposed_measure" disable-output-escaping="yes" />
		<div style="border: 1px dotted #999; padding: 0 1em;"><xsl:value-of select="$action/@comments" disable-output-escaping="yes" /></div>
	</xsl:template>
	
</xsl:stylesheet>