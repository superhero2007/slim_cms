<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'answer_2_action_edit']">
		<xsl:variable name="page" select="page[@page_id = current()/globals/item[@key = 'page_id']/@value]" />
		<xsl:variable name="question" select="question[@question_id = current()/globals/item[@key = 'question_id']/@value]" />
		<xsl:variable name="answer" select="answer[@answer_id = current()/globals/item[@key = 'answer_id']/@value]" />
		<xsl:variable name="action_2_answer" select="action_2_answer[@action_2_answer_id = current()/globals/item[@key = 'action_2_answer_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=page_list&amp;checklist_id={$checklist_id}">Page List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=page_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}"><xsl:value-of select="$page/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=question_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}"><xsl:value-of select="$question/@question" disable-output-escaping="yes" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=answer_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}&amp;answer_id={$answer/@answer_id}">Edit Answer</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=answer_2_action_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}&amp;answer_id={$answer/@answer_id}&amp;action_2_answer_id={$action_2_answer/@action_2_answer_id}">
				<xsl:choose>
					<xsl:when test="$action_2_answer">Edit Trigger</xsl:when>
					<xsl:otherwise>Create Trigger</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Question &amp; Answer Trigger</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="action_2_answer_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="page_id" value="{$page/@page_id}" />
			<input type="hidden" name="question_id" value="{$question/@question_id}" />
			<input type="hidden" name="answer_id" value="{$answer/@answer_id}" />
			<input type="hidden" name="action_2_answer_id" value="{$action_2_answer/@action_2_answer_id}" />
			<input type="hidden" name="range_min" value="0" />
			<input type="hidden" name="range_max" value="0" />
			<table>
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Trigger" /></th>
					</tr>
				</tfoot>
				<tbody>
					<xsl:if test="$answer/@answer_type = 'percent'">
						<tr>
							<th scope="row"><label for="range-min">Range Min:</label></th>
							<td><input type="text" id="range-min" name="range_min" value="{$action_2_answer/@range_min}" /></td>
						</tr>
						<tr>
							<th scope="row"><label for="range-max">Range Max:</label></th>
							<td><input type="text" id="range-max" name="range_max" value="{$action_2_answer/@range_max}" /></td>
						</tr>
					</xsl:if>
					<tr>
						<th scope="row"><label for="action-id">Action:</label></th>
						<td>
							<select id="action-id" name="action_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="report_section[@checklist_id = $checklist_id]">
									<xsl:sort select="@sequence" data-type="number" />
									<optgroup label="{@title}">
										<xsl:for-each select="../action[@report_section_id = current()/@report_section_id]">
											<xsl:sort select="@sequence" data-type="number" />
											<option value="{@action_id}">
												<xsl:if test="@action_id = $action_2_answer/@action_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
												<xsl:value-of select="@summary" disable-output-escaping="yes" />
											</option>
										</xsl:for-each>
									</optgroup>
								</xsl:for-each>
							</select>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>

</xsl:stylesheet>