<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'action_2_answer_edit']">
		<xsl:variable name="report_section" select="report_section[@report_section_id = current()/globals/item[@key = 'report_section_id']/@value]" />
		<xsl:variable name="action" select="action[@action_id = current()/globals/item[@key = 'action_id']/@value]" />
		<xsl:variable name="action_2_answer" select="action_2_answer[@action_2_answer_id = current()/globals/item[@key = 'action_2_answer_id']/@value]" />
		<xsl:variable name="question_id">			
			<xsl:choose>
				<xsl:when test="globals/item[@key = 'question_id']">
					<xsl:value-of select="question[@question_id = current()/globals/item[@key = 'question_id']/@value]/@question_id" />
				</xsl:when>
				<xsl:when test="$action_2_answer/@answer_id = '-1'">
					<xsl:value-of select="$action_2_answer/@question_id" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="current()/answer[@answer_id = $action_2_answer/@answer_id]/@question_id" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
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
			<a href="?page=checklists&amp;mode=action_2_answer_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}&amp;action_2_answer_id={$action_2_answer/@action_2_answer_id}">
				<xsl:choose>
					<xsl:when test="$action_2_answer">Edit Trigger</xsl:when>
					<xsl:otherwise>Create Trigger</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Question &amp; Answer Trigger</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="fetch_answers" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Fetch Answers" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="question-id">Question:</label></th>
						<td>
							<select id="question-id" name="question_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="page[@checklist_id = $checklist_id]">
									<xsl:sort select="@sequence" data-type="number" />
									<optgroup label="{@title}">
										<xsl:for-each select="../question[@page_id = current()/@page_id]">
											<xsl:sort select="@sequence"  data-type="number" />
											<option value="{@question_id}">
												<xsl:if test="@question_id = $question_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
												<xsl:value-of select="concat(@question_id,' - ',substring(@question,1,50),'...')" disable-output-escaping="yes" />
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
		<xsl:if test="$question_id != ''">
			<form method="post" action="">
				<input type="hidden" name="action" value="action_2_answer_save" />
				<input type="hidden" name="checklist_id" value="{$checklist_id}" />
				<input type="hidden" name="report_section_id" value="{$report_section/@report_section_id}" />
				<input type="hidden" name="action_id" value="{$action/@action_id}" />
				<input type="hidden" name="action_2_answer_id" value="{$action_2_answer/@action_2_answer_id}" />
				<input type="hidden" name="question_id" value="{$question_id}" />
				<table class="editTable">
					<tfoot>
						<tr>
							<th colspan="2"><input type="submit" value="Save Trigger" /></th>
						</tr>
					</tfoot>
					<tbody>
						<tr>
							<th scope="row"><label for="answer-id">Answer:</label></th>
							<td>
								<select id="answer-id" name="answer_id">
									<option value="0">-- Select --</option>
									<xsl:for-each select="answer[@question_id = $question_id]">
										<option value="{@answer_id}">
											<xsl:if test="@answer_id = $action_2_answer/@answer_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
											<xsl:choose>
												<xsl:when test="@answer_type = 'percent'">RANGE</xsl:when>
												<xsl:otherwise><xsl:value-of select="../answer_string[@answer_string_id = current()/@answer_string_id]/@string" disable-output-escaping="yes" /></xsl:otherwise>
											</xsl:choose>
										</option>
									</xsl:for-each>
										<!-- //If the question allows multiple answers, allow the ability to trigger based on the number of results provided -->
									<xsl:if test="/config/question[@question_id = $question_id]/@multiple_answer = '1'">
										<option value="-1">
											<xsl:if test="$action_2_answer/@answer_id = '-1'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
											<xsl:text>All Answers (Count Number of Responses for given question)</xsl:text>
										</option>
									</xsl:if>
								</select>
							</td>
						</tr>
						<tr>
							<th scope="row"><label for="range-min">Range Min:</label></th>
							<td><input type="text" id="range-min" name="range_min" value="{$action_2_answer/@range_min}" /></td>
						</tr>
						<tr>
							<th scope="row"><label for="range-max">Range Max:</label></th>
							<td><input type="text" id="range-max" name="range_max" value="{$action_2_answer/@range_max}" /></td>
						</tr>
					</tbody>
				</table>
			</form>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>