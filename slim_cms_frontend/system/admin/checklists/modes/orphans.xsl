<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'orphans']">
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=orphans&amp;checklist_id={$checklist_id}">Orphans</a>
		</p>
		<h1>Questions without Actions</h1>
		<table>
			<col style="width: 50%;" />
			<thead>
				<tr>
					<th scope="col">Question</th>
					<th scope="col">Page</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="question[@page_id = ../page[@checklist_id = $checklist_id]/@page_id]">
					<xsl:sort select="../page[@page_id = current()/@page_id]/@sequence" data-type="number" />
					<xsl:sort select="@sequence" />
					<xsl:variable name="answers" select="../answer[@question_id = current()/@question_id]" />
					<xsl:if test="../action_2_answer[@answer_id = $answers/@answer_id] = false()">
						<tr>
							<td>
								<xsl:value-of select="@question" disable-output-escaping="yes" />
								<br />
								<span class="options">
									<a href="?page=checklists&amp;mode=question_edit&amp;checklist_id={$checklist_id}&amp;page_id={@page_id}&amp;question_id={@question_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=checklists&amp;mode=orphans&amp;action=question_delete&amp;checklist_id={$checklist_id}&amp;question_id={@question_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
							<td><xsl:value-of select="../page[@page_id = current()/@page_id]/@title" /></td>
						</tr>
					</xsl:if>
				</xsl:for-each>
			</tbody>
		</table>
		<h1>Actions without Questions</h1>
		<table>
			<col style="width: 50%;" />
			<thead>
				<tr>
					<th scope="col">Action</th>
					<th scope="col">Report Section</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="action[@report_section_id = ../report_section[@checklist_id = $checklist_id]/@report_section_id]">
					<xsl:sort select="../report_section[@report_section_id = current()/@report_section_id]/@sequence" data-type="number" />
					<xsl:sort select="@sequence" />
					<xsl:if test="../action_2_answer[@action_id = current()/@action_id] = false()">
						<tr>
							<td>
								<xsl:value-of select="@title" />
								<br />
								<span class="options">
									<a href="?page=checklists&amp;mode=action_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={@report_section_id}&amp;action_id={@action_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=checklists&amp;mode=orphans&amp;action=action_delete&amp;checklist_id={$checklist_id}&amp;action_id={@action_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
							<td><xsl:value-of select="../report_section[@report_section_id = current()/@report_section_id]/@title" /></td>
						</tr>
					</xsl:if>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

</xsl:stylesheet>