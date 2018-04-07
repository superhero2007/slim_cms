<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'checklist_edit']">
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
		</p>
		<h1>Checklist Details</h1>
		<p>This form is used to change the basic checklist details. Please ensure well formed XHTML is used for the "Description" field and the "Report Delay" is in seconds.</p>
		<p>Use the tabs above to navigate to other areas with in the checklist system, they are for management of this current checklist.</p>
		<form method="post" action="">
			<input type="hidden" name="action" value="checklist_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<table class="editTable">
				<thead>
					<tr>
						<th colspan="10" />
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="10"><input type="submit" value="Save Assessment" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="name">Assessment Name:</label></th>
						<td colspan="9"><input type="text" id="name" name="name" value="{checklist[@checklist_id = $checklist_id]/@name}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="description">Description:<br />(XHTML)</label></th>
						<td colspan="9"><textarea id="description" name="description" rows="4" cols="45"><xsl:value-of select="checklist[@checklist_id = $checklist_id]/@description" /></textarea></td>
					</tr>
					<tr>
						<th scope="row"><label for="logo">Logo:</label></th>
						<td colspan="9"><input type="text" id="logo" name="logo" value="{checklist[@checklist_id = $checklist_id]/@logo}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="company_logo">Company Logo:</label></th>
						<td colspan="9"><input type="text" id="company_logo" name="company_logo" value="{checklist[@checklist_id = $checklist_id]/@company_logo}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="help_content">Help Content:<br />(XHTML)</label></th>
						<td colspan="9"><textarea id="help_content" name="help_content" rows="4" cols="45"><xsl:value-of select="checklist[@checklist_id = $checklist_id]/@help_content" /></textarea></td>
					</tr>			

					<tr>
                    	<th scope="row"><label for="checklist_options">Checklist Options:</label></th>
                        	<td>
                            	<table border="0px;">
                                	<tr>
                                    	<td>
                                        	<label for="send_trigger_emails">Auto Emails: </label>
                                        	<input type="hidden" name="send_trigger_emails" value="0" /> 
                                            <input type="checkbox" name="send_trigger_emails" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@send_trigger_emails = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                        <td>
                                        	<label for="assessment_certificate">Certificate: </label>
                                        	<input type="hidden" name="assessment_certificate" value="0" /> 
                                            <input type="checkbox" name="assessment_certificate" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@assessment_certificate = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                        <td>
                                        	<label for="audit">Audit: </label>
                                        	<input type="hidden" name="audit" value="0" /> 
                                            <input type="checkbox" name="audit" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@audit = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                        <td>
                                        	<label for="audit">Scored: </label>
                                        	<input type="hidden" name="scorable_assessment" value="0" /> 
                                            <input type="checkbox" name="scorable_assessment" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@scorable_assessment = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                        <td>
                                        	<label for="audit">PDF Report: </label>
                                        	<input type="hidden" name="downloadable_reports" value="0" /> 
                                            <input type="checkbox" name="downloadable_reports" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@downloadable_reports = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                    </tr>
                                    <tr>
                                        <td>
                                        	<label for="audit">Actions: </label>
                                        	<input type="hidden" name="exportable_actions" value="0" /> 
                                            <input type="checkbox" name="exportable_actions" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@exportable_actions = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                        <td>
                                        	<label for="audit">Archived: </label>
                                        	<input type="hidden" name="archived" value="0" /> 
                                            <input type="checkbox" name="archived" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@archived = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                        <td>
                                        	<label for="audit">Submittable: </label>
                                        	<input type="hidden" name="submitable" value="0" /> 
                                            <input type="checkbox" name="submitable" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@submitable = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                        <td>
                                        	<label for="audit">Show Previous Results: </label>
                                        	<input type="hidden" name="show_previous_results" value="0" /> 
                                            <input type="checkbox" name="show_previous_results" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@show_previous_results = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                        <td>
                                        	<label for="audit">Show Progress Report: </label>
                                        	<input type="hidden" name="progress_report" value="0" /> 
                                            <input type="checkbox" name="progress_report" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@progress_report = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                    </tr>
                                    <tr>
                                        <td>
                                        	<label for="audit">Last Page Submit: </label>
                                        	<input type="hidden" name="last_page_submit" value="0" /> 
                                            <input type="checkbox" name="last_page_submit" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@last_page_submit = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                        <td>
                                        	<label for="require_page_complete">Require Page Complete:<br />(Warning for mandatory questions)</label>
                                        	<input type="hidden" name="require_page_complete" value="0" /> 
                                            <input type="checkbox" name="require_page_complete" value="1">
                                            	<xsl:if test="checklist[@checklist_id = $checklist_id]/@require_page_complete = '1'">
                                            		<xsl:attribute name="checked">checked</xsl:attribute>
                                                </xsl:if>
                                            </input>
                                            <xsl:text>Yes</xsl:text>
                                    	</td>
                                    </tr>
                                </table>
                            </td>
					</tr>

					<!-- //Report Options -->
					<tr>
						<th scope="row" colspan="2">Report Options</th>
					</tr>
					<tr>
						<th scope="row"><label for="report-name">Report Name:</label></th>
						<td colspan="9"><input type="text" id="report-name" name="report_name" value="{checklist[@checklist_id = $checklist_id]/@report_name}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="company_logo">Report Type:</label></th>
						<td colspan="9"><input type="text" id="report_type" name="report_type" value="{checklist[@checklist_id = $checklist_id]/@report_type}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="report_template">Report Template:</label></th>
						<td colspan="9"><input type="text" id="report_template" name="report_template" value="{checklist[@checklist_id = $checklist_id]/@report_template}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="report-cover-color">Report Cover Page Colour:</label></th>
						<td colspan="9"><input type="text" id="report-cover-color" name="report_cover_color" value="{checklist[@checklist_id = $checklist_id]/@report_cover_color}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="report-primary-color">Report Primary Colour:</label></th>
						<td colspan="9"><input type="text" id="report-primary-color" name="report_primary_color" value="{checklist[@checklist_id = $checklist_id]/@report_primary_color}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="report-cover-color">Report Secondary Colour:</label></th>
						<td colspan="9"><input type="text" id="report-secondary-color" name="report_secondary_color" value="{checklist[@checklist_id = $checklist_id]/@report_secondary_color}" /></td>
					</tr>
					
					<!-- //Email Answer Report -->
					<tr>
						<th scope="row" colspan="2">
						Select if an answer report is to be sent via email on each completed assessment and the recipients<br />
						Recipients can be in the format: info@greenbizcheck.com or info@greenbizcheck.com, email@greenbizcheck.com for multiple recipients.
						</th>
					</tr>
					<tr>
						<th scope="row"><label for="email_report">Email Report:</label></th>
						<td>
							<input type="hidden" name="email_report" value="0" /> 
							<input type="checkbox" name="email_report" value="1">
								<xsl:if test="checklist[@checklist_id = $checklist_id]/@email_report = '1'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<xsl:text>Yes</xsl:text>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="email_report_address">Email Report Address:</label></th>
						<td><input type="text" id="email_report_address" name="email_report_address" value="{checklist[@checklist_id = $checklist_id]/@email_report_address}" /></td>
					</tr>
					<!-- //Submit Options -->
					<tr>
						<th scope="row" colspan="2">Submit Options</th>
					</tr>
					<tr>
						<th scope="row"><label for="followup_call">Followup Call:</label></th>
						<td><input type="text" id="followup_call" name="followup_call" value="{checklist[@checklist_id = $checklist_id]/@followup_call}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="followup_sql">Followup SQL:</label></th>
						<td colspan="9"><textarea id="followup_sql" name="followup_sql" rows="4" cols="45"><xsl:value-of select="checklist[@checklist_id = $checklist_id]/@followup_sql" /></textarea></td>
					</tr>	
					<tr>
						<th scope="row"><label for="md5">Checklist Key:</label></th>
						<td><input type="text" id="md5" name="md5" value="{checklist[@checklist_id = $checklist_id]/@md5}" readonly="readonly"/></td>
					</tr>
                    
				</tbody>
			</table>
		</form>
		<xsl:if test="$checklist_id">
			<h2>Certification Levels</h2>
			<table class="editTable">
				<thead>
					<tr>
						<th scope="col">Name</th>
						<th scope="col">Target</th>
						<th scope="col">Color</th>
					</tr>
				</thead>
				<thead>
					<tr>
						<th colspan="3"></th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="3"><input type="button" value="Add Certification Level" onclick="document.location = '?page=checklists&amp;mode=certification_level_edit&amp;checklist_id={$checklist_id}'" /></th>
					</tr>
				</tfoot>
				<tbody>
					<xsl:for-each select="certification_level[@checklist_id = $checklist_id]">
						<tr>
							<td>
								<xsl:value-of select="@name" />
								<br />
								<span class="options">
									<a href="?page=checklists&amp;mode=certification_level_edit&amp;checklist_id={$checklist_id}&amp;certification_level_id={@certification_level_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={@checklist_id}&amp;certification_level_id={@certification_level_id}" onclick="return(confirm('Do you really want to delete {@name}?'))">delete</a>
								</span>
							</td>
							<td><xsl:value-of select="@target" />%</td>
							<td>
								<span style="background-color:#{@progress_bar_color};  display: inline-block;width: 100%;padding: 5px;box-sizing: border-box;">
									<xsl:value-of select="@progress_bar_color" />
								</span>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>

			<!-- //Import Content -->
			<h2>Import Content</h2>
			<form method="post" enctype="multipart/form-data">
				<input type="hidden" name="action" value="import_content" />
				<input type="hidden" name="checklist_id" value="{$checklist_id}" />
				<table class="editTable">
					<thead>
						<tr>
							<th scope="col">File</th>
							<th scope="col">Action</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<th>
								<input type="file" name="import_content_file" />
							</th>
							<td>
								<input type="submit" value="Import Content" />
							</td>
						</tr>
					</tbody>
				</table>
			</form>
			<p>Note: File should be a CSV using <a href="/admin/checklist_import_template.csv" target="_blank">this template</a>.</p>


			<h2>Copy Assessment</h2>
			<form method="post" action="">
				<input type="hidden" name="action" value="checklist_copy" />
				<input type="hidden" name="checklist_id" value="{$checklist_id}" />
				<table class="editTable">
					<thead>
						<tr>
							<th colspan="2"></th>
						</tr>
					</thead>
					<tfoot>
						<tr>
							<th colspan="2"><input type="submit" value="Copy Assessment" /></th>
						</tr>
					</tfoot>
					<tbody>
						<tr>
							<th scope="row"><label for="new-checklist">New Checklist Name:</label></th>
							<td><input type="text" id="new-checklist" name="name" /></td>
						</tr>
						<tr>
							<th scope="row"><label for="new-checklist-db">New Checklist Database:</label></th>
							<td>
								<select name="new-checklist-db">
									<option value="greenbiz_checklist">greenbiz_checklist</option>
									<option value="ecobiz_checklist">ecobiz_checklist</option>
								</select>
							</td>
						</tr>
					</tbody>
				</table>
			</form>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>