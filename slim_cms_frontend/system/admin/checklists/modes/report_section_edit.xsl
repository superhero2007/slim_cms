<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'report_section_edit']">
		<xsl:variable name="report_section" select="report_section[@report_section_id = current()/globals/item[@key = 'report_section_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_list&amp;checklist_id={$checklist_id}">Report Section List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}">
				<xsl:choose>
					<xsl:when test="$report_section"><xsl:value-of select="$report_section/@title" /></xsl:when>
					<xsl:otherwise>Add Report Section</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Report Section</h1>
		<p>Edit the report section here, by entering the "Title" and the "Content". The "Content" must be well formed XHTML.</p>
		<p>The "Default Content" section is the default text that will be displayed in reports.  You can can choose to customise this further by choosing to add country specific content. If the user is located in a country which has country specific content they will see the country content if it is set, otherwise they will see the default content.</p>
		<form method="post" action="">
			<input type="hidden" name="action" value="report_section_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="report_section_id" value="{$report_section/@report_section_id}" />
			<input type="hidden" name="sequence" value="{$report_section/@sequence}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Report Section" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="title">Title:</label></th>
						<td><input type="text" id="title" name="title" value="{$report_section/@title}" /></td>
					</tr>
					<tr>
						<th scope="row" rowspan="2"><label for="content">Default Content:<br />(XHTML)</label></th>
						<td>
							<textarea cols="45" rows="8" id="content" name="content"><xsl:value-of select="$report_section/@content" /></textarea>
							<!-- //Insert the CKEditor
							<script type="text/javascript">
								<xsl:comment><![CDATA[
									CKEDITOR.replace( 'content',
									{
										contentsCss : 'assets/output_xhtml.css'
									});
								]]></xsl:comment>
							</script>
							 //End of CKEditor -->
						</td>
					</tr>
					<tr>
						<td>
							<xsl:text>There are a few special tags that you can use in addition to XHTML.</xsl:text>
							<dl>
								<dt><strong>&lt;companyName /&gt;</strong></dt>
								<dd>Shows the Client's Company Name</dd>
								<dt><strong>&lt;overallScore /&gt;</strong></dt>
								<dd>Shows the overall score graph bars.</dd>
								<dt><strong>&lt;categoryScores /&gt;</strong></dt>
								<dd>Shows the scores by category (Report Section).</dd>
								<dt><strong>&lt;keyActions /&gt;</strong></dt>
								<dd>Lists the key actions for the clients report.</dd>
								<dt><strong>&lt;auditQuestions /&gt;</strong></dt>
								<dd>Lists the questions/Answers that have triggered an audit.</dd>
							</dl>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="display-in-pdf">Display in PDF:</label></th>
						<td>
							<input type="hidden" name="display_in_pdf" value="0" />
							<label>
								<input type="checkbox" id="display-in-pdf" name="display_in_pdf" value="1">
									<xsl:if test="$report_section/@display_in_pdf = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="display-in-html">Display in HTML:</label></th>
						<td>
							<input type="hidden" name="display_in_html" value="0" />
							<label>
								<input type="checkbox" id="display-in-html" name="display_in_html" value="1">
									<xsl:if test="$report_section/@display_in_html = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="multi_site">Multi-Site Content:</label></th>
						<td>
							<input type="hidden" name="multi_site" value="0" />
							<label>
								<input type="checkbox" id="multi_site" name="multi_site" value="1">
									<xsl:if test="$report_section/@multi_site = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="title">Output:</label></th>
						<td><input type="text" id="output" name="output" value="{$report_section/@output}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
		
		<!-- //International Report Section list -->
				<h1>International Report Section List</h1>	
		<p>Below is the list of international report section custom content. click 'add' at the bottom to create a new international report section content listing. Click edit to modify an existing listing. Click delete to remove an existing listing.</p>
		<table id="table-international-action-list">
			<thead>
				<tr>
					<th scope="col">Country</th>
					<th scope="col">Content Summary</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="2"><input type="button" value="Add International Report Section Content" onclick="document.location = '?page=checklists&amp;mode=international_report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}'" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="international_report_section[@report_section_id = $report_section/@report_section_id]">
					<tr id="id-{@international_report_section_id}">
						<td>
							<xsl:value-of select="../country[@country_id = current()/@country_id]/@country" disable-output-escaping="yes" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=international_report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;international_report_section_id={@international_report_section_id}" title="Edit Content">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=international_report_section_delete&amp;action=international_report_section_delete&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;international_report_section_id={@international_report_section_id}" title="Delete Content" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td>
							<xsl:value-of select="@content" disable-output-escaping="yes" />
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		
		<h1>Action List</h1>	
		<p>Below is the list of actions associated to this report section, to edit or to view the available commitment options to an action click "edit", reordering works by dragging the row into the appropriate order and is listed in the current order.</p>
		<table id="table-action-list">
			<col style="width: 40%;" />
			<col />
			<col style="width: 8em;" />
			<col style="width: 8em;" />
			<thead>
				<tr>
					<th scope="col">Title/Summary</th>
					<th scope="col">Q&amp;A Trigger</th>
					<th scope="col">Demerit Points</th>
					<th scope="col">No. of Commitment Options</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="4"><input type="button" value="Create New Action" onclick="document.location = '?page=checklists&amp;mode=action_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}'" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="action[@report_section_id = $report_section/@report_section_id]">
					<xsl:sort select="@sequence" data-type="number" />
					<tr id="id-{@action_id}">
						<td>
							<strong>Title: </strong><xsl:value-of select="@title" disable-output-escaping="yes" /><br /><br />
							<strong>Summary: </strong><xsl:value-of select="@summary" disable-output-escaping="yes" /><br /><br />
							<span class="options">
								<a href="?page=checklists&amp;mode=action_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={@action_id}" title="Edit action">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=report_section_edit&amp;action=action_delete&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={@action_id}" title="Delete Action" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td>
							<xsl:for-each select="../action_2_answer[@action_id = current()/@action_id]">
								<xsl:variable name="answer" select="../answer[@answer_id = current()/@answer_id]" />
								<xsl:choose>
									<xsl:when test="@answer_id = '-1'">
										<xsl:value-of select="../question[@question_id = current()/@question_id]/@question" disable-output-escaping="yes" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="../question[@question_id = $answer/@question_id]/@question" disable-output-escaping="yes" />
									</xsl:otherwise>
								</xsl:choose>
								<br />
								<em style="margin-left: 1em;">
									<xsl:text> &gt; </xsl:text>
									<xsl:choose>
										<xsl:when test="@answer_id = '-1'"><xsl:text>Count all answers. </xsl:text><xsl:value-of select="concat('Range: ',@range_min,' - ',@range_max)" /></xsl:when>
										<xsl:when test="$answer/@answer_type = 'percent'"><xsl:value-of select="concat('Range: ',@range_min,' - ',@range_max)" /></xsl:when>
										<xsl:when test="$answer/@answer_type = 'text'"><xsl:text>single-line textbox</xsl:text></xsl:when>
										<xsl:when test="$answer/@answer_type = 'textarea'"><xsl:text>multi-line textbox</xsl:text></xsl:when>
										<xsl:otherwise><xsl:value-of select="../answer_string[@answer_string_id = $answer/@answer_string_id]/@string" disable-output-escaping="yes" /></xsl:otherwise>
									</xsl:choose>
								</em>
								<br />
							</xsl:for-each>
						</td>
						<td><xsl:value-of select="@demerits" /></td>
						<td><xsl:value-of select="count(../commitment[@action_id = current()/@action_id])" /></td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
<script type="text/javascript"><xsl:comment>
$(document).ready(function() {
	// Initialise the table
	$("#table-action-list").tableDnD({
		onDrop: function(tbody, row) {
			$.get('/admin/index.php?page=checklists&amp;action=action_reorder&amp;'+$.tableDnD.serialize());
		}
	});
});
</xsl:comment></script>
		<h1>Confirmation List</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">Confirmation</th>
					<th scope="col">Q&amp;A Trigger</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="2"><input type="submit" value="Add Confirmation" onclick="document.location = '?page=checklists&amp;mode=confirmation_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}';" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="confirmation[@report_section_id = $report_section/@report_section_id]">
					<tr>
						<td>
							<xsl:value-of select="@confirmation" disable-output-escaping="yes" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=confirmation_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;confirmation_id={@confirmation_id}" title="Edit confirmation">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=report_section_edit&amp;action=confirmation_delete&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;confirmation_id={@confirmation_id}" title="Delete confirmation" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td>
							<xsl:variable name="answer" select="../answer[@answer_id = current()/@answer_id]" />
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
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
</xsl:stylesheet>