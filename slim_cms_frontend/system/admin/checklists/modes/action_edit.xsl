<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'action_edit']">
		<xsl:variable name="report_section" select="report_section[@report_section_id = current()/globals/item[@key = 'report_section_id']/@value]" />
		<xsl:variable name="action" select="action[@action_id = current()/globals/item[@key = 'action_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_list&amp;checklist_id={$checklist_id}">Report Section List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}"><xsl:value-of select="$report_section/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=action_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}">
				<xsl:choose>
					<xsl:when test="$action"><xsl:value-of select="$action/@title" /></xsl:when>
					<xsl:otherwise>Create Action</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Action</h1>
		<p>Here you can edit this action by changeing the "Title", "Summary", "Proposed Measure", "Comments" and "Demerits". The "Proposed Measure" and "Comments" must be well formed XHTML.</p>
		<form method="post" action="">
			<input type="hidden" name="action" value="action_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="action_id" value="{$action/@action_id}" />
			<input type="hidden" name="sequence">
				<xsl:attribute name="value">
					<xsl:choose>
						<xsl:when test="$action">
							<xsl:value-of select="$action/@sequence" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="math:max(action[@report_section_id = $report_section/@report_section_id]/@sequence)+1" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</input>
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Action" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="report-section-id">Report Section:</label></th>
						<td>
							<select id="report-section-id" name="report_section_id">
								<xsl:for-each select="report_section[@checklist_id = $checklist_id]">
									<xsl:sort select="@sequence" data-type="number" />
									<option value="{@report_section_id}">
										<xsl:if test="@report_section_id = $report_section/@report_section_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="concat(position(),' - ',@title)" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="title">Title:</label></th>
						<td><input type="text" id="title" name="title" value="{$action/@title}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="summary">Summary:</label></th>
						<td><input type="text" id="summary" name="summary" value="{$action/@summary}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="proposed-measure">Proposed Measure:<br />(XHTML)</label></th>
						<td><textarea cols="45" rows="8" id="proposed-measure" name="proposed_measure"><xsl:value-of select="$action/@proposed_measure" /></textarea></td>
					<!-- //Insert the CKEditor 
					<script type="text/javascript">
					<xsl:comment><![CDATA[
						CKEDITOR.replace( 'proposed-measure',
						{
							contentsCss : 'assets/output_xhtml.css'
						});

					]]></xsl:comment>
					</script>
					 //End of CKEditor -->
					
					</tr>
					<tr>
						<th scope="row"><label for="comments">Comments:<br />(XHTML)</label></th>
						<td><textarea cols="45" rows="8" id="comments" name="comments"><xsl:value-of select="$action/@comments" /></textarea></td>
						<!-- //Insert the CKEditor 
							<script type="text/javascript">
							<xsl:comment><![CDATA[
							CKEDITOR.replace( 'comments',
							{
								contentsCss : 'assets/output_xhtml.css'
							});
						]]></xsl:comment>
						</script>
						 //End of CKEditor -->
					</tr>
					<tr>
						<th scope="row"><label for="demerits">Demerit Points:</label></th>
						<td><input type="text" id="demerits" name="demerits" value="{$action/@demerits}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="fail_factor">Fail Factor:</label>
						<br /><span class="regular">Set the multiplier on a demerit for increased demerit weighting. Default:0. Number value only.</span>
						</th>
						<td><input type="number" min="0" id="fail_factor" name="fail_factor" value="{$action/@fail_factor}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="insta_fail">Insta Fail:</label>
						<br /><span class="regular">Sets the assessment to fail when triggered. Report will provide a zero score.</span>
						</th>
						<td>
							<input type="hidden" name="insta_fail" value="0" /> 
							<input type="checkbox" name="insta_fail" value="1">
								<xsl:if test="$action/@insta_fail = '1'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<xsl:text>Yes</xsl:text>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="demerits">Fail Point:</label>
						<br /><span class="regular">Sets the action as a fail point, a tally of these points is attached to the client checklist.</span>
						</th>
						<td>
							<input type="hidden" name="fail_point" value="0" /> 
							<input type="checkbox" name="fail_point" value="1">
								<xsl:if test="$action/@fail_point = '1'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<xsl:text>Yes</xsl:text>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
		
		<!-- //International Action list -->
				<h1>International Action List</h1>	
		<p>Below is the list of international action custom content. click 'add' at the bottom to create a new international action content listing. Click edit to modify an existing listing. Click delete to remove an existing listing.</p>
		<table id="table-action-list">
			<thead>
				<tr>
					<th scope="col">Country</th>
					<th scope="col">Propsed Measure</th>
					<th scope="col">Comments</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="3"><input type="button" value="Add International Action Content" onclick="document.location = '?page=checklists&amp;mode=international_action_edit&amp;checklist_id={$checklist_id}&amp;action_id={$action/@action_id}&amp;report_section_id={$report_section/@report_section_id}'" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="international_action[@report_section_id = $report_section/@report_section_id and @action_id = $action/@action_id]">
					<tr id="id-{@international_action_id}">
						<td>
							<xsl:value-of select="../country[@country_id = current()/@country_id]/@country" disable-output-escaping="yes" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=international_action_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}&amp;international_action_id={@international_action_id}" title="Edit Content">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=international_action_delete&amp;action=international_action_delete&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}&amp;international_action_id={@international_action_id}" title="Delete Content" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td>
							<xsl:value-of select="@proposed_measure" disable-output-escaping="yes" />
						</td>
						<td>
							<xsl:value-of select="@comments" disable-output-escaping="yes" />
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		
		<h1>Question &amp; Answer Triggers</h1>
		<table>
			<col />
			<col style="width: 10em;" />
			<thead>
				<tr>
					<th scope="col">Question</th>
					<th scope="col">Answer</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="2"><input type="button" value="Create New Trigger" onclick="document.location = '?page=checklists&amp;mode=action_2_answer_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}';" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="action_2_answer[@action_id = $action/@action_id]">
					<xsl:variable name="answer" select="../answer[@answer_id = current()/@answer_id]" />
					<tr>
						<td>
							<xsl:choose>
								<xsl:when test="@answer_id = '-1'">
									<xsl:value-of select="../question[@question_id = current()/@question_id]/@question" disable-output-escaping="yes" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="../question[@question_id = $answer/@question_id]/@question" disable-output-escaping="yes" />
								</xsl:otherwise>
							</xsl:choose>
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=action_2_answer_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}&amp;action_2_answer_id={@action_2_answer_id}">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=action_edit&amp;action=action_2_answer_delete&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}&amp;action_2_answer_id={@action_2_answer_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td>
							<xsl:choose>
								<xsl:when test="@answer_id = '-1'"><xsl:text>Count all answers. </xsl:text><xsl:value-of select="concat('Range: ',@range_min,' - ',@range_max)" /></xsl:when>
								<xsl:when test="$answer/@answer_type = 'percent'"><xsl:value-of select="concat('Range: ',@range_min,' - ',@range_max)" /></xsl:when>
								<xsl:when test="$answer/@answer_type = 'text'"><xsl:text>single-line textbox</xsl:text></xsl:when>
								<xsl:when test="$answer/@answer_type = 'textarea'"><xsl:text>multi-line textbox</xsl:text></xsl:when>
								<xsl:otherwise><xsl:value-of select="../answer_string[@answer_string_id = $answer/@answer_string_id]/@string" disable-output-escaping="yes" /></xsl:otherwise>
							</xsl:choose>	
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		<h1>Commitment Options</h1>
		<table id="table-commitment-list">
			<col />
			<col style="width: 10em;" />
			<thead>
				<tr>
					<th scope="col">Option</th>
					<th scope="col">Merit Points</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="2"><input type="button" value="Create New Commitment Option" onclick="document.location='?page=checklists&amp;mode=commitment_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}';" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="commitment[@action_id = $action/@action_id]">
					<xsl:sort select="@sequence" data-type="number" />
					<tr id="id-{@commitment_id}">
						<td>
							<xsl:value-of select="@commitment" disable-output-escaping="yes" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=commitment_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}&amp;commitment_id={@commitment_id}" title="Edit Commitment">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=action_edit&amp;action=commitment_delete&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}&amp;commitment_id={@commitment_id}" title="Delete Commitment" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>	
						</td>
						<td><xsl:value-of select="@merits" /></td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
<script type="text/javascript"><xsl:comment>
$(document).ready(function() {
	// Initialise the table
	$("#table-commitment-list").tableDnD({
		onDrop: function(tbody, row) {
			$.get('/admin/index.php?page=checklists&amp;action=commitment_reorder&amp;'+$.tableDnD.serialize());
		}
	});
});
</xsl:comment></script>


		<h1>Action Resources</h1>
		<table id="table-resource-list">
			<col />
			<col />
			<col style="width: 15em;" />
			<thead>
				<tr>
					<th scope="col">Description</th>
					<th scope="col">URL</th>
					<th scope="col">Type</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="3"><input type="button" value="Create Resource" onclick="document.location = '?page=checklists&amp;mode=resource_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}';" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="resource[@action_id = $action/@action_id]">
					<xsl:sort select="@sequence" data-type="number" />
					<tr id="id-{@resource_id}">
						<td>
							<xsl:value-of select="@description" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=resource_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}&amp;resource_id={@resource_id}" title="Edit Resource">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=resource_delete&amp;action=resource_delete&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$action/@action_id}&amp;resource_id={@resource_id}" title="Delete Resource" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>	
						</td>
						<td>
							<a href="{@url}" target="_blank">
								<xsl:value-of select="@url" />
							</a>
						</td>
						<td>
							<xsl:value-of select="../resource_type[@resource_type_id = current()/@resource_type_id]/@description" />
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		<script type="text/javascript"><xsl:comment>
		$(document).ready(function() {
			// Initialise the table
			$("#table-resource-list").tableDnD({
				onDrop: function(tbody, row) {
					$.get('/admin/index.php?page=checklists&amp;action=resource_reorder&amp;'+$.tableDnD.serialize());
				}
			});
		});
		</xsl:comment></script>

		<br class="clear" />

		<form method="post" action="">
			<input type="hidden" name="action" value="action_duplicate" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="report_section_id" value="{$report_section/@report_section_id}" />
			<input type="hidden" name="action_id" value="{$action/@action_id}" />
			<center><input type="submit" value="Duplicate Action" /></center>
		</form>
	</xsl:template>
	
</xsl:stylesheet>