<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'page_edit']">
		<xsl:variable name="page" select="page[@page_id = current()/globals/item[@key = 'page_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=checklist_edit">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_list">Page List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_edit&amp;page_id={$page/@page_id}">
				<xsl:choose>
					<xsl:when test="$page"><xsl:value-of select="$page/@title" /></xsl:when>
					<xsl:otherwise>Add Page</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Page</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="page_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="page_id" value="{$page/@page_id}" />
			<input type="hidden" name="sequence">
				<xsl:attribute name="value">
					<xsl:choose>
						<xsl:when test="$page"><xsl:value-of select="$page/@sequence" /></xsl:when>
						<xsl:otherwise><xsl:value-of select="math:max(page[@checklist_id = $checklist_id]/@sequence)+1" /></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</input>
			<table class="editTable">
				<thead>
					<tr>
						<th colspan="2"></th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Page" /></th>
					</tr>
				</tfoot>
				<tbody>
					<!-- //Add in select field for page section -->
					<tr>
						<th scope="row"><label for="title">Page Section:</label></th>
						<td>
							<select name="page_section_id">
								<option value="0"> -- Select -- </option>
								<xsl:for-each select="/config/page_section">
									<option value="{@page_section_id}">
										<xsl:if test="/config/page_section_2_page[@page_id = $page/@page_id][@page_section_id = current()/@page_section_id]">
											<xsl:attribute name="selected" value="selected" />
										</xsl:if>
										<xsl:value-of select="@title" />
									</option>
								</xsl:for-each>
							</select>
							<input type="hidden" name="page_section_2_page_id" value="{/config/page_section_2_page[@page_id = $page/@page_id]/@page_section_2_page_id}" />
						</td>
					</tr>


					<tr>
						<th scope="row"><label for="title">Title:</label></th>
						<td><input type="text" id="title" name="title" value="{$page/@title}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="content">Content:<br />(XHTML)</label></th>
						<td>
							<textarea rows="8" cols="45" id="content" name="content"><xsl:value-of select="$page/@content" /></textarea>
						</td>
					</tr>			
					<tr>
						<th scope="row"><label for="enable-skipping">Enable Skipping:</label></th>
						<td>
							<input type="hidden" name="enable_skipping" value="0" />
							<label>
								<input type="checkbox" id="enable-skipping" name="enable_skipping" value="1">
									<xsl:if test="$page/@enable_skipping = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
                    
                    <!-- //Added a section to allow a checkbox that specifies if the notes field is used -->
                    <tr>
                    	<th scope="row" colspan="2">
                    		<label><center>Page Notes Field</center></label>
                    	</th>
                    </tr>
					<tr>
						<th scope="row"><label for="show-notes-field">Disable Notes Field:</label></th>
						<td>
							<input type="hidden" name="show_notes_field" value="1" />
							<label>
								<input type="checkbox" id="show-notes-field" name="show_notes_field" value="0">
									<xsl:if test="$page/@show_notes_field = '0'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="notes_field_title">Page Notes Field Label:</label></th>
						<td><input type="text" id="notes_field_title" name="notes_field_title" value="{$page/@notes_field_title}" /></td>
					</tr>	
					<tr>
						<th scope="row"><label for="notes_field_placeholder">Page Notes Field Pleaceholder:</label></th>
						<td><input type="text" id="notes_field_placeholder" name="notes_field_placeholder" value="{$page/@notes_field_placeholder}" /></td>
					</tr>		
                    
                    <!-- //End Checkbox for notes field option -->
                    <tr>
                    	<th scope="row" colspan="2">
                    		<label><center>Page Layout</center></label>
                    	</th>
                    </tr>
					<tr>
						<th scope="row"><label for="display-in-table">Display in Table:</label></th>
						<td>
							<input type="hidden" name="display_in_table" value="0" />
							<label>
								<input type="checkbox" id="display_in_table" name="display_in_table" value="1">
									<xsl:if test="$page/@display_in_table = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="table-columns">Table Columns <br />(number of columns):</label></th>
						<td><input type="text" id="table_columns" name="table_columns" value="{$page/@table_columns}" /></td>
					</tr>	
					<tr>
						<th scope="row"><label for="page-layout">Page Layout: <br />Optional:</label></th>
						<td><input type="text" id="page_layout" name="page_layout" value="{$page/@page_layout}" /></td>
					</tr>				
				</tbody>
			</table>
		</form>
		<xsl:if test="$page">
			<form method="post" action="">
				<input type="hidden" name="action" value="question_delete" />
				<input type="hidden" name="checklist_id" value="{$checklist_id}" />
				<input type="hidden" name="page_id" value="{$page/@page_id}" />
				<h1>Question List</h1>
				<table id="table-question-list" class="editTable">
					<col />
					<col style="width: 10em;" />
					<thead>
						<tr>
							<th scope="col">Question</th>
							<th scope="col">Question ID</th>
							<th scope="col">Index</th>
							<th scope="col">No. of Answers</th>
							<th scope="col">Form Group</th>
							<th scope="col">Permission</th>
						</tr>
					</thead>
					<tfoot>
						<tr>
							<th colspan="6">
								<input type="button" value="Add Question" onclick="document.location = '?page=checklists&amp;mode=question_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}';" />
								<input type="submit" value="Delete Questions" onclick="return(confirm('Did you really mean to click delete?'))" />	
							</th>
						</tr>
					</tfoot>
					<tbody>
						<xsl:for-each select="question[@page_id = $page/@page_id]">
							<xsl:sort select="@sequence" data-type="number" />
							<tr id="id-{@question_id}">
								<td>
									<input type="checkbox" name="question_id[]" value="{@question_id}" />
									<label>
										<xsl:value-of select="@question" disable-output-escaping="yes" />
									</label>
									<br />
									<span class="options">
										<a href="?page=checklists&amp;mode=question_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={@question_id}" title="Edit Question">edit</a>
									</span>	
								</td>
								<td><xsl:value-of select="@question_id" disable-output-escaping="yes" /></td>
								<td><xsl:value-of select="@index" disable-output-escaping="yes" /></td>
								<td><xsl:value-of select="count(/config/answer[@question_id = current()/@question_id])" /></td>
								<td><xsl:value-of select="../form_group[@form_group_id = current()/@form_group_id]/@name" /></td>
								<td><xsl:value-of select="../field_permission[@field_permission_id = current()/@field_permission_id]/@permission" /></td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</form>
			
			<!-- //Insert link to import questions into this report checklist page -->
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=question_import&amp;page_id={$page/@page_id}">Import question from another assessment</a>
			<br /><br />
			
			<script type="text/javascript"><xsl:comment>
			$(document).ready(function() {
				// Initialise the table
				$("#table-question-list").tableDnD({
					onDrop: function(tbody, row) {
						$.get('/admin/index.php?page=checklists&amp;action=question_reorder&amp;'+$.tableDnD.serialize());
					}
				});
			});
			</xsl:comment></script>

			<h1>Metric Groups</h1>
			<table id="table-metric-list" class="editTable">
				<thead>
					<tr>
						<th scope="col">Name</th>
						<th scope="col">No. of Metrics</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="2"><input type="button" value="Add Metic Group" onclick="document.location = '?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=metric_group_edit&amp;page_id={$page/@page_id}';" /></th>
					</tr>
				</tfoot>
				<tbody>
					<xsl:for-each select="metric_group[@page_id = $page/@page_id]">
					<xsl:sort select="@sequence" data-type="number" />
						<tr id="id-{@metric_group_id}">
							<td>
								<xsl:value-of select="@name" />
								<br />
								<span class="options">
									<a href="?page=checklists&amp;mode=metric_group_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;metric_group_id={@metric_group_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=checklists&amp;mode=page_edit&amp;action=metric_group_delete&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;metric_group_id={@metric_group_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
							<td><xsl:value-of select="count(../metric[@metric_group_id = current()/@metric_group_id])" /></td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>

			<!-- //Form Group -->
			<h1>Form Groups</h1>
			<table id="table-form-group" class="editTable">
				<thead>
					<tr>
						<th scope="col">Name</th>
						<th scope="col">Form Group ID</th>
						<th scope="col">Repeatable</th>
						<th scope="col">Min Rows</th>
						<th scope="col">Max Rows</th>
						<th scope="col">Questions</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="6"><input type="button" value="Add Form Group" onclick="document.location = '?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=form_group_edit&amp;page_id={$page/@page_id}';" /></th>
					</tr>
				</tfoot>
				<tbody>
					<xsl:for-each select="form_group[@page_id = $page/@page_id]">
						<tr id="id-{@form_group_id}">
							<td>
								<xsl:value-of select="@name" />
								<br />
								<span class="options">
									<a href="?page=checklists&amp;mode=form_group_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;form_group_id={@form_group_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=checklists&amp;mode=page_edit&amp;action=form_group_delete&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;form_group_id={@form_group_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
							<td>
								<xsl:value-of select="@form_group_id" />
							</td>
							<td>
								<xsl:choose>
									<xsl:when test="@repeatable = '1'">Yes</xsl:when>
									<xsl:otherwise>No</xsl:otherwise>
								</xsl:choose>
							</td>
							<td>
								<xsl:choose>
									<xsl:when test="@min_rows &gt; 0">
										<xsl:value-of select="@min_rows" />
									</xsl:when>
									<xsl:otherwise>
										N/A
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<td>
								<xsl:choose>
									<xsl:when test="@max_rows &gt; 0">
										<xsl:value-of select="@max_rows" />
									</xsl:when>
									<xsl:otherwise>
										N/A
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<td>
								<xsl:value-of select="count(../question[@form_group_id = current()/@form_group_id])" />
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
			
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>