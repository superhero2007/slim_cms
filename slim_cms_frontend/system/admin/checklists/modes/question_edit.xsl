<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'question_edit']">
		<xsl:variable name="question" select="question[@question_id = current()/globals/item[@key = 'question_id']/@value]" />
		<xsl:variable name="page" select="page[@page_id = current()/globals/item[@key = 'page_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=checklist_edit">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_list">Page List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_edit&amp;page_id={$page/@page_id}"><xsl:value-of select="$page/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=question_edit&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}">
				<xsl:choose>
					<xsl:when test="$question"><xsl:value-of select="$question/@question" disable-output-escaping="yes" /></xsl:when>
					<xsl:otherwise>Add Question</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Question</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="question_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="question_id" value="{$question/@question_id}" />
			<input type="hidden" name="sequence">
				<xsl:attribute name="value">
					<xsl:choose>
						<xsl:when test="$question"><xsl:value-of select="$question/@sequence" /></xsl:when>
						<xsl:otherwise><xsl:value-of select="math:max(question[@page_id = $page/@page_id]/@sequence)+1" /></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</input>
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Question" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="col"><label for="page-id">Page:</label></th>
						<td>
							<select id="page-id" name="page_id">
								<option>-- Select --</option>
								<xsl:for-each select="page[@checklist_id = $checklist_id]">
									<xsl:sort select="@sequence" data-type="number" order="ascending" />
									<option value="{@page_id}">
										<xsl:if test="($question = true() and $question/@page_id = current()/@page_id) or ($question = false() and $page/@page_id = current()/@page_id)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="concat(position(),' - ',@title)" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="question">Question (XHTML):</label>
							<p style="font-weight:normal;">If content block option checked this field will be rendered as a content block instead of a question</p>
						</th>
						<td><textarea id="question" name="question" rows="8" cols="45"><xsl:value-of select="$question/@question" /></textarea></td>
					</tr>
					<tr>
						<th scope="col"><label for="tip">Help (XHTML):</label></th>
						<td><textarea id="tip" name="tip" rows="8" cols="45"><xsl:value-of select="$question/@tip" /></textarea></td>
					</tr>
					<tr>
						<th scope="col"><label for="multiple-answer">Multiple Answers:</label></th>
						<td>
							<input type="hidden" name="multiple_answer" value="0" />
							<label>
								<input type="checkbox" id="multiple-answer" name="multiple_answer" value="1">
									<xsl:if test="$question/@multiple_answer = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="required">Required:</label></th>
						<td>
							<input type="hidden" name="required" value="0" />
							<label>
								<input type="checkbox" id="required" name="required" value="1">
									<xsl:if test="$question/@required = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="multi-site">Multi-Site:</label></th>
						<td>
							<input type="hidden" name="multi_site" value="0" />
							<label>
								<input type="checkbox" id="multi-site" name="multi_site" value="1">
									<xsl:if test="$question/@multi_site = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="content-block">Content Block:</label>
						</th>
						<td>
							<input type="hidden" name="content_block" value="0" />
							<label>
								<input type="checkbox" id="content-block" name="content_block" value="1">
									<xsl:if test="$question/@content_block = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="content-block">Display in table:</label>
						</th>
						<td>
							<input type="hidden" name="display_in_table" value="0" />
							<label>
								<input type="checkbox" id="display-in-table" name="display_in_table" value="1">
									<xsl:if test="$question/@display_in_table = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="content-block">Index:</label>
						</th>
						<td>
							<input type="number" id="index" name="index" value="{$question/@index}" />
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="content-block">Width:</label>
						</th>
						<td>
							<select id="grid_layout_id" name="grid_layout_id">
								<xsl:for-each select="/config/grid_layout">
									<option value="{@col}">
										<xsl:if test="$question/@grid_layout_id = @grid_layout_id">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="@width" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="hidden">Hidden Question:</label>
						</th>
						<td>
							<input type="hidden" name="hidden" value="0" />
							<label>
								<input type="checkbox" id="hidden" name="hidden" value="1">
									<xsl:if test="$question/@hidden = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="hidden">Import Key:</label>
						</th>
						<td>
							<input type="text" name="import_key" value="{$question/@import_key}" />
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="hidden">Export Key:</label>
						</th>
						<td>
							<input type="text" name="export_key" value="{$question/@export_key}" />
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="hidden">Alt Key:</label>
						</th>
						<td>
							<input type="text" name="alt_key" value="{$question/@alt_key}" />
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="hidden">Show in analytics:</label>
						</th>
						<td>
							<input type="hidden" name="show_in_analytics" value="0" />
							<label>
								<input type="checkbox" id="show_in_analytics" name="show_in_analytics" value="1">
									<xsl:if test="$question/@show_in_analytics = '1'">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="hidden">Repeatable:</label>
						</th>
						<td>
							<input type="hidden" name="repeatable" value="0" />
							<label>
								<input type="checkbox" id="repeatable" name="repeatable" value="1">
									<xsl:if test="$question/@repeatable = '1'">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="hidden">Validate:</label>
						</th>
						<td>
							<input type="hidden" name="validate" value="0" />
							<label>
								<input type="checkbox" id="valiate" name="validate" value="1">
									<xsl:if test="$question/@validate = '1'">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="form-group-id">Form Group:</label></th>
						<td>
							<select id="form-group-id" name="form_group_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="form_group[@page_id = $page/@page_id]">
									<xsl:sort select="@name" order="ascending" />
									<option value="{@form_group_id}">
										<xsl:if test="@form_group_id = $question/@form_group_id">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="@name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="col">
							<label for="hidden">CSS Class:</label>
						</th>
						<td>
							<input type="text" name="css_class" value="{$question/@css_class}" />
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="field-permission-id">Field Permission:</label></th>
						<td>
							<select id="field-permission-id" name="field_permission_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="field_permission">
									<xsl:sort select="@field_permission_id" order="ascending" />
									<option value="{@field_permission_id}">
										<xsl:if test="@field_permission_id = $question/@field_permission_id">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="@permission" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
		<xsl:if test="$question">
			<h1>Available Answers</h1>
			<table id="table-answer-list">
				<thead>
					<tr>
						<th scope="col">Answer Type</th>
						<th scope="col">Answer String</th>
						<th scope="col">Answer ID</th>
						<th scope="col">Default Value</th>
						<th scope="col">Function (Post - PHP)</th>
						<th scope="col">Calculation (Real Time - Javascript)</th>
						<th scope="col">Alternate Value</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="7">
							<input type="button" value="Create Answer" onclick="document.location = '?page=checklists&amp;mode=answer_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}';" />
							<xsl:if test="answer[@question_id = $question/@question_id] = false()">
								<input type="button" value="Create Yes/No Combo" onclick="document.location = '?page=checklists&amp;mode=question_edit&amp;action=answer_yes_no_combo&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}';" />
							</xsl:if>
						</th>
					</tr>
				</tfoot>
				<tbody>
					<xsl:for-each select="answer[@question_id = $question/@question_id]">
						<xsl:sort select="@sequence" data-type="number" />
						<tr id="id-{@answer_id}">
							<td>
								<xsl:value-of select="@answer_type" />
								<br />
								<span class="options">
									<a href="?page=checklists&amp;mode=answer_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}&amp;answer_id={@answer_id}" title="Edit Answer">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=checklists&amp;mode=question_edit&amp;action=answer_delete&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}&amp;answer_id={@answer_id}" title="Delete Answer" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
							<td>
								<xsl:value-of select="../answer_string[@answer_string_id = current()/@answer_string_id]/@string" />
							</td>
							<td>
								<xsl:value-of select="@answer_id" />
							</td>
							<td>
								<xsl:value-of select="@default_value" />
							</td>
							<td>
								<xsl:value-of select="@function" />
							</td>
							<td>
								<xsl:value-of select="@calculation" />
							</td>
							<td>
								<xsl:value-of select="@alt_value" />
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
<script type="text/javascript"><xsl:comment>
$(document).ready(function() {
	// Initialise the table
	$("#table-answer-list").tableDnD({
		onDrop: function(tbody, row) {
			$.get('/admin/index.php?page=checklists&amp;action=answer_reorder&amp;'+$.tableDnD.serialize());
		}
	});
});
</xsl:comment></script>
			<h1>Answers that this question depends on</h1>
			<table>
			<form method="post" action="">
				<input type="hidden" name="action" value="answer_2_question_delete" />
				<input type="hidden" name="checklist_id" value="{$checklist_id}" />
				<input type="hidden" name="page_id" value="{$page/@page_id}" />
				<input type="hidden" name="question_id" value="{$question/@question_id}" />
			
				<col style="width: 60%;" />
				<col style="width: 30%;" />
				<thead>
					<tr>
						<th scope="col">Question</th>
						<th scope="col">Page</th>
						<th scope="col">Answer</th>
						<th scope="col">Comparator</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="4">
							<input type="button" value="Create Link" onclick="document.location = '?page=checklists&amp;mode=answer_2_question_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}';" />
							<input type="submit" value="Delete Links" onclick="return(confirm('Did you really mean to click delete?'))" />						
						</th>
					</tr>
				</tfoot>
				<tbody>
					<xsl:for-each select="answer_2_question[@question_id = $question/@question_id]">
						<xsl:variable name="answer" select="../answer[@answer_id = current()/@answer_id]" />
						<tr>
							<td>
								<input type="checkbox" name="answer_2_question_id[]" value="{@answer_2_question_id}" />
								<xsl:value-of select="../question[@question_id = $answer/@question_id]/@question" />
								<br />
								<span class="options">
									<a href="?page=checklists&amp;mode=answer_2_question_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}&amp;master_question_id={/config/question[@question_id = /config/answer[@answer_id = current()/@answer_id]/@question_id]/@question_id}">edit link</a>
								</span>
							</td>
							<td><xsl:value-of select="../page[@page_id = ../question[@question_id = $answer/@question_id]/@page_id]/@title" /></td>
							<td><xsl:value-of select="../answer_string[@answer_string_id = $answer/@answer_string_id]/@string" /></td>
							<td><xsl:value-of select="@comparator" /></td>
						</tr>
					</xsl:for-each>
				</tbody>
				</form>
			</table>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>