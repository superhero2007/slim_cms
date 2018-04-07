<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'audit_list']">
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=audit_list&amp;checklist_id={$checklist_id}">Audit List</a>
		</p>
		<h1>Add / Edit Audit Items</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">Audit Type</th>
					<th scope="col">Q&amp;A Trigger</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="2"><input type="submit" value="Add Audit Item" onclick="document.location = '?page=checklists&amp;mode=audit_edit&amp;checklist_id={$checklist_id}';" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="audit">
				<xsl:variable name="answer" select="../answer[@answer_id = current()/@answer_id]" />
				<xsl:if test="../question[@question_id = $answer/@question_id]/@checklist_id = $checklist_id">
					<tr>
						<td width="20%">
							<xsl:value-of select="@audit_type" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=audit_edit&amp;checklist_id={$checklist_id}&amp;audit_id={@audit_id}" title="Edit">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=audit_edit&amp;action=audit_delete&amp;checklist_id={$checklist_id}&amp;audit_id={@audit_id}" title="Delete" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td>
							<xsl:value-of select="../question[@question_id = $answer/@question_id]/@question" disable-output-escaping="yes" />
							<br />
							<em style="margin-left: 1em;">
								<xsl:text> &gt; </xsl:text>
								<xsl:choose>
									<xsl:when test="$answer/@answer_type = 'percent'"><xsl:value-of select="@arbitrary_value" />%</xsl:when>
									<xsl:when test="$answer/@answer_type = 'text'"><xsl:value-of select="@arbitrary_value" /></xsl:when>
									<xsl:when test="$answer/@answer_type = 'textarea'"><xsl:value-of select="@arbitrary_value" /></xsl:when>
									<xsl:otherwise><xsl:value-of select="../answer_string[@answer_string_id = $answer/@answer_string_id]/@string" disable-output-escaping="yes" /></xsl:otherwise>
								</xsl:choose>
							</em>								
						</td>
					</tr>
				</xsl:if>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
</xsl:stylesheet>