<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="func exsl"
	exclude-result-prefixes="gbc exsl">
	
	<xsl:template match="config[@mode = 'answer_edit']">
		<xsl:variable name="answer" select="answer[@answer_id = current()/globals/item[@key = 'answer_id']/@value]" />
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
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=question_edit&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}"><xsl:value-of select="$question/@question" disable-output-escaping="yes" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=answer_edit&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}&amp;answer_id={$answer/@answer_id}">
				<xsl:choose>
					<xsl:when test="$answer">Edit Answer</xsl:when>
					<xsl:otherwise>Add Answer</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Answer</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="answer_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="page_id" value="{$page/@page_id}" />
			<input type="hidden" name="question_id" value="{$question/@question_id}" />
			<input type="hidden" name="answer_id" value="{$answer/@answer_id}" />
			<input type="hidden" name="sequence">
				<xsl:attribute name="value">
					<xsl:choose>
						<xsl:when test="$answer"><xsl:value-of select="$answer/@sequence" /></xsl:when>
						<xsl:otherwise><xsl:value-of select="math:max(answer[@question_id = $question/@question_id]/@sequence)+1" /></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</input>

			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Answer" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="answer-type">Type:</label></th>
						<td>
							<xsl:variable name="options">
								<option value="checkbox" desc="Multiple choice option" />
								<option value="checkbox-other" desc="Multiple choice with other/extra text field" />
								<option value="text" desc="Single-line free text field" />
								<option value="textarea" desc="Multi-line free text field" />
								<option value="percent" desc="Percentage Range" />
								<option value="range" desc="Slider range" />
								<option value="email" desc="Email Address" />
								<option value="url" desc="Website URL" />
								<option value="date" desc="Date field" />
								<option value="int" desc="Number (Whole)" />
								<option value="float" desc="Number (Float)" />
								<option value="date-quarter" desc="Date (Quarter)" />
								<option value="date-month" desc="Date (Month)" />
								<option value="file-upload" desc="File Upload" />
								<option value="drop-down-list" desc="Drop Down List" />
								<option value="multi-site-query" desc="Multi Site Query" />
								<option value="label" desc="Label" />
							</xsl:variable>
							<select id="answer-type" name="answer_type" onchange="toggleAnswerTypes(this.options[this.selectedIndex].value);">
								<option>-- Select --</option>
								<xsl:for-each select="exsl:node-set($options)/option">
									<option value="{@value}">
										<xsl:if test="@value = $answer/@answer_type"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@desc" />
									</option>	
								</xsl:for-each>
							</select>
						</td>
					</tr>
				</tbody>
				
				<tbody id="answerType-string">
					<tr>
						<th scope="row"><label for="answer-string-id">
							<xsl:choose>
								<xsl:when test="$answer/@answer_type = 'checkbox' or $page/@display_in_table = '1'">
									String:
								</xsl:when>
								<xsl:when test="$answer/@answer_type = 'text' or $answer/@answer_type = 'textarea'">
									Placeholder:
								</xsl:when>
								<xsl:otherwise>
									String: <br />(Leave blank for 'Other')
								</xsl:otherwise>
							</xsl:choose>
						</label></th>
						<td>
							<select id="answer-string-id" name="answer_string_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="answer_string">
									<xsl:sort select="@string" data-type="text" />
									<option value="{@answer_string_id}">
										<xsl:if test="@answer_string_id = $answer/@answer_string_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@string" disable-output-escaping="yes" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
				</tbody>
				
				<!-- // Add a drop down box option to set the number of rows in a textarea field -->				
				<tbody id="answerType-textarea">
					<tr>
						<th scope="row"><label for="number-of-rows">Number of rows: (textarea only)</label></th>
						<td>
							<select id="number-of-rows" name="number_of_rows">
								<option value="">-- Select --</option>
									<option value="2">
										<xsl:if test="$answer/@number_of_rows = 2"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>2
									</option>
									<option value="3">
										<xsl:if test="$answer/@number_of_rows = 3"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>3
									</option>
									<option value="4">
										<xsl:if test="$answer/@number_of_rows = 4"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>4
									</option>
									<option value="5">
										<xsl:if test="$answer/@number_of_rows = 5"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>5
									</option>
									<option value="6">
										<xsl:if test="$answer/@number_of_rows = 6"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>6
									</option>
									<option value="7">
										<xsl:if test="$answer/@number_of_rows = 7"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>7
									</option>
									<option value="8">
										<xsl:if test="$answer/@number_of_rows = 8"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>8
									</option>
									<option value="9">
										<xsl:if test="$answer/@number_of_rows = 9"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>9
									</option>
									<option value="10">
										<xsl:if test="$answer/@number_of_rows = 10"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>10
									</option>
							</select>
						</td>
					</tr>
				</tbody>				
				<!-- //End textarea field drop box -->
				
				<tbody id="answerType-range">
					<tr>
						<th scope="row"><label for="range-min">Minimum Value:</label></th>
						<td><input type="text" id="range-min" name="range_min" value="{$answer/@range_min}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="range-max">Maximum Value:</label></th>
						<td><input type="text" id="range-max" name="range_max" value="{$answer/@range_max}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="range-step">Range Step: (percentage and range only)</label></th>
						<td><input type="text" id="range-step" name="range_step" value="{$answer/@range_step}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="range-unit">Range Unit: (range only)</label></th>
						<td><input type="text" id="range-unit" name="range_unit" value="{$answer/@range_unit}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="default-value">Default Value:</label></th>
						<td><input type="text" id="default-value" name="default_value" value="{$answer/@default_value}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="prepend_content">Prepend Content:</label></th>
						<td><input type="text" id="prepend_content" name="prepend_content" value="{$answer/@prepend_content}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="append_content">Append Content:</label></th>
						<td><input type="text" id="append_content" name="append_content" value="{$answer/@append_content}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="function">Function (Post - PHP):</label></th>
						<td>
							<textarea id="function" name="function" rows="5">
								<xsl:value-of select="$answer/@function" />
							</textarea>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="function_description">Function Description (Pseudocode):</label></th>
						<td>
							<textarea id="function_description" name="function_description" rows="5">
								<xsl:value-of select="$answer/@function_description" />
							</textarea>
						</td>
					</tr>
					<tr>
						<th scope="row">
							<label for="calculation">Calculation (Real Time - Javascript):</label></th>
						<td>
							<textarea id="calculation" name="calculation" rows="5">
								<xsl:value-of select="$answer/@calculation" />
							</textarea>
						</td>
					</tr>
					<tr>
						<th scope="row">
							<label for="alt_value">Alternate Value:</label>
						</th>
						<td>
							<input type="text" id="alt_value" name="alt_value" value="{$answer/@alt_value}" />
						</td>
					</tr>
				</tbody>
			</table>
		</form>
		
		<h1>Add New Answer String</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="answer_string_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="page_id" value="{$page/@page_id}" />
			<input type="hidden" name="question_id" value="{$question/@question_id}" />
			<input type="hidden" name="answer_id" value="{$answer/@answer_id}" />
			<table class="editTable" id="add-string-table">
				<tfoot>
					<tr>
						<th colspan="2">
							<input type="submit" value="Save String(s)" />
							<button id="add-data-row">Add another string</button>			
						</th>
					</tr>
				</tfoot>
				<tbody class="add-string-tbody">
					<tr>
						<th scope="row"><label for="string">String:</label></th>
						<td><input type="text" id="string" name="string[]" /></td>
					</tr>
				</tbody>
			</table>
		</form>
		
		<div class="hidden-data">
			<div id="template-row">
				<tr id="blank-add-string-row">
					<th scope="row"><label for="string">String:</label></th>
					<td><input type="text" id="string" name="string[]" /></td>
				</tr>
			</div>
		</div>
		
		<script type="text/javascript">
			$(function() {
				$('#add-data-row').click(function(e) {
					$('#add-string-table').append('<tr><th scope="row"><label for="string">String:</label></th><td><input type="text" id="string" name="string[]" /></td></tr>');
					e.preventDefault();
				});
			});
		</script>
		
	</xsl:template>
	
</xsl:stylesheet>