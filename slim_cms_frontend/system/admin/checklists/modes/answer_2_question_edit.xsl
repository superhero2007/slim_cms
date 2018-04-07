<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">

	<xsl:template name="breadcrumbs">
		<xsl:variable name="question" select="question[@question_id = current()/globals/item[@key = 'question_id']/@value]" />
		<xsl:variable name="page" select="page[@page_id = current()/globals/item[@key = 'page_id']/@value]" />

		<!-- //Checklist Menu -->
		<xsl:call-template name="menu" />

		<!-- //Breadcrumb -->
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
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=answer_2_question_edit&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}">
				Add/Edit Link
			</a>
		</p>
	</xsl:template>
	
	<!-- //Legacy -->
	<xsl:template match="config[@mode = 'answer_2_question_edit']">
		<xsl:variable name="question" select="question[@question_id = current()/globals/item[@key = 'question_id']/@value]" />
		<xsl:variable name="page" select="page[@page_id = current()/globals/item[@key = 'page_id']/@value]" />
		<xsl:variable name="master_question_id">			
			<xsl:choose>
				<xsl:when test="globals/item[@key = 'master_question_id']">
					<xsl:value-of select="question[@question_id = current()/globals/item[@key = 'master_question_id']/@value]/@question_id" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
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
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=answer_2_question_edit&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}">
				Add/Edit Link
			</a>
		</p>
		<h1>Add / Edit Link to an answer this question depends on</h1>
		<form method="post" action="/admin/index.php?page=checklists&amp;mode=answer_2_question_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={$question/@question_id}">
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Fetch Answers" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="master-question-id">Master Question:</label></th>
						<td>
							<select id="master-question-id" name="master_question_id">

								<!-- //Get the prior pages -->
								<xsl:for-each select="page[@checklist_id = $checklist_id][@sequence &lt; $page/@sequence]">
									<xsl:sort select="@sequence" data-type="number" />
									<optgroup label="{@title}">
										<xsl:for-each select="../question[@page_id = current()/@page_id]">
											<xsl:sort select="@sequence" data-type="number" />
											<option value="{@question_id}">
												<xsl:if test="@question_id = $master_question_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
												<xsl:value-of select="substring(@question, 0, 200)" disable-output-escaping="yes" />
											</option>
										</xsl:for-each>
									</optgroup>
								</xsl:for-each>

								<!-- //Now get the prior questions on the current page -->
								<optgroup label="{$page/@title}">
									<xsl:for-each select="question[@page_id = $question/@page_id][@sequence &lt; $question/@sequence]">
										<xsl:sort select="@sequence" data-type="number" />
										<option value="{@question_id}">
											<xsl:if test="@question_id = $master_question_id">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>
											<xsl:value-of select="substring(@question, 0, 200)" disable-output-escaping="yes" />
										</option>
									</xsl:for-each>
								</optgroup>
							</select>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
		<xsl:if test="$master_question_id != ''">
			<form method="post" action="">
				<input type="hidden" name="action" value="answer_2_question_save" />
				<input type="hidden" name="checklist_id" value="{$checklist_id}" />
				<input type="hidden" name="page_id" value="{$page/@page_id}" />
				<input type="hidden" name="master_question_id" value="{$master_question_id}" />
				<input type="hidden" name="question_id" value="{$question/@question_id}" />
				
				<!-- //First list the existing links -->
				<div id="answer_2_question_container">
					<xsl:for-each select="/config/answer[@question_id = $master_question_id]">
					<xsl:for-each select="/config/answer_2_question[@answer_id = current()/@answer_id][@question_id = $question/@question_id]">
						<xsl:variable name="answer_2_question" select="current()" />
						<input type="hidden" name="answer_2_question_id[]" value="{$answer_2_question/@answer_2_question_id}" />
						<table class="editTable">
							<tbody>
								<tr>
									<th scope="row"><label for="answer-id">Answer:</label></th>
									<td>
										<select id="answer-id" name="answer_id[]">
											<xsl:for-each select="/config/answer[@question_id = $master_question_id]">
												<xsl:sort select="@sequence" data-type="number" />
												<xsl:choose>
													<xsl:when test="@answer_type = 'percent' or @answer_type = 'range'">
														<option value="{@answer_id}">RANGE</option>
													</xsl:when>
													<xsl:otherwise>
														<option value="{@answer_id}">
															<xsl:if test="@answer_id = $answer_2_question/@answer_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
															<xsl:value-of select="../answer_string[@answer_string_id = current()/@answer_string_id]/@string" disable-output-escaping="yes" />
														</option>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:for-each>
										</select>
									</td>
								</tr>
								<tr>
									<th scope="row"><label for="range-min">Range Min:</label></th>
									<td><input type="text" id="range-min" name="range_min[]" value="{$answer_2_question/@range_min}" /></td>
								</tr>
								<tr>
									<th scope="row"><label for="range-max">Range Max:</label></th>
									<td><input type="text" id="range-max" name="range_max[]" value="{$answer_2_question/@range_max}" /></td>
								</tr>
								<tr>
									<th scope="row"><label for="answer-id">Comparator</label></th>
									<td>
										<select id="comparator" name="comparator[]">
											<option value="OR">
												<xsl:if test="$answer_2_question/@comparator = 'OR'">
													<xsl:attribute name="selected" value="seleted" />
												</xsl:if>
												<xsl:text>OR</xsl:text>
											</option>
											<option value="AND">
												<xsl:if test="$answer_2_question/@comparator = 'AND'">
													<xsl:attribute name="selected" value="seleted" />
												</xsl:if>
												<xsl:text>AND</xsl:text>
											</option>
										</select>
									</td>
								</tr>
							</tbody>
						</table>
					</xsl:for-each>
					</xsl:for-each>
					
				</div>
				
				<!-- //Save Button -->
				<table class="editTable">
					<tfoot>
						<tr>
							<th colspan="2">
								<input type="submit" value="Save Link(s)" />
								<button id="add-data-table">Add a Link</button>
							</th>
						</tr>
					</tfoot>
				</table>
				
			</form>
			
			<div class="hidden-data">
				<!-- //Blank table template -->
				<table class="editTable blank-table" id="blank-data-table">
					<tbody>
						<tr>
							<th scope="row"><label for="answer-id">Answer:</label></th>
							<td>
								<select id="answer-id" name="answer_id[]">
									<xsl:for-each select="answer[@question_id = $master_question_id]">
										<xsl:sort select="@sequence" data-type="number" />
										<xsl:choose>
											<xsl:when test="@answer_type = 'percent' or @answer_type = 'range'">
												<option value="{@answer_id}">RANGE</option>
											</xsl:when>
											<xsl:otherwise>
												<option value="{@answer_id}">
													<xsl:value-of select="../answer_string[@answer_string_id = current()/@answer_string_id]/@string" disable-output-escaping="yes" />
												</option>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</select>
							</td>
						</tr>
						<tr>
							<th scope="row"><label for="range-min">Range Min:</label></th>
							<td><input type="text" id="range-min" name="range_min[]" value="" /></td>
						</tr>
						<tr>
							<th scope="row"><label for="range-max">Range Max:</label></th>
							<td><input type="text" id="range-max" name="range_max[]" value="" /></td>
						</tr>
						<tr>
							<th scope="row"><label for="answer-id">Comparator</label></th>
							<td>
								<select id="comparator" name="comparator[]">
									<option value="OR">
										<xsl:text>OR</xsl:text>
									</option>
									<option value="AND">
										<xsl:text>AND</xsl:text>
									</option>
								</select>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<!-- //Allow adding blank data table -->
			<script type="text/javascript">
				
				$(function() {
					$('#add-data-table').click(function(e) {
						$('#blank-data-table').clone().appendTo('#answer_2_question_container');
						e.preventDefault();
					});
				});
				
			</script>
		</xsl:if>
	</xsl:template>






<!-- //NEW -->

	<xsl:template match="config[@mode = 'answer_2_question_edit'][@mode='new']">
		<div class="prv_key" value="{/config/api/@prv}"/>
		<div lass="pub_key" value="{/config/api/@pub}" />
		<xsl:call-template name="breadcrumbs" />

		<div class="container answer_2_question_edit">
			<p>When the following conditions are met:</p>

			<div class="repeatable container">
				<table class="answer_2_question">
					<tr>
						<th width="22.5%">Connector</th>
						<th width="22.5%">Question</th>
						<th width="22.5%">Comparator</th>
						<th width="22.5%">Value</th>
						<th></th>
					</tr>

					<!-- //Template row -->
					<xsl:call-template name="condition-row">
						<xsl:with-param name="type" select="'template'" />
					</xsl:call-template>
				</table>

				<!-- //Add Button -->
				<div class="text-center padding-top-20">
					<button class="repeatable add">Add Condition</button>
				</div>

			</div>

		</div>
		
	</xsl:template>

	<xsl:template name="condition-row">
		<xsl:param name="type" select="'clone'" />
		<!-- //Repeatable -->
		<tr class="repeatable {$type}">
			<td>
				<select name="connector">
					<option value="AND">AND</option>
					<option value="OR">OR</option>
				</select>
			</td>
			<td>
				<select name="question" data-child="value">
					<option>Select One</option>
					<xsl:call-template name="questions" />
				</select>						
			</td>
			<td>
				<select name="comparator">
					<option>Select One</option>
					<optgroup label="Fixed Input">
						<option value="selected">Has Selected</option>
						<option value="not-selected">Does Not Have Selected</option>
					</optgroup>
					<optgroup label="Variable Input">
						<option value="=">Equals</option>
						<option value="!=">Does Not Equal</option>
						<option value="%">Contains</option>
						<option value="!%">Does Not Contain</option>
						<option value="&gt;">Greater Than</option>
						<option value="&lt;">Less Than</option>
					</optgroup>
				</select>							
			</td>
			<td>
				<select name="value" class="fixed-input">
					<option>Select One</option>
				</select>
				<input name="value" class="variable-input" />				
			</td>
			<td>
				<button class="repeatable delete">Delete</button>
			</td>
		</tr>
	</xsl:template>

	<xsl:template name="questions">
		<xsl:variable name="page" select="page[@page_id = current()/globals/item[@key = 'page_id']/@value]" />
		<xsl:for-each select="page[@checklist_id = $checklist_id][@sequence &lt; $page/@sequence]">
			<xsl:sort select="@sequence" data-type="number" />
			<xsl:if test="count(../question[@page_id = current()/@page_id]) &gt; 0">
				<optgroup label="{@title}">
					<xsl:for-each select="../question[@page_id = current()/@page_id]">
						<xsl:sort select="@sequence" data-type="number" />
						<option value="{@question_id}">
							<xsl:value-of select="@question" disable-output-escaping="yes" />
						</option>
					</xsl:for-each>
				</optgroup>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>