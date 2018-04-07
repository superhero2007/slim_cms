<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'assessmentList']">
		<!--<h2><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> Assessments</h2>-->
		<xsl:if test="not(clientChecklist)">
			<p>You do not have any assessments available to you at this time.</p>
		</xsl:if>
		<xsl:if test="/config/plugin[@plugin = 'clients']/client/@complimentary_consult = '1' or /config/plugin[@plugin = 'clients']/client/@nswbc_preferred_time != ''">
			<h3>Green Consult</h3>
			<p>Thank-you for registering for your free one hour consult. A consultant will be in contact with you shortly to arrange a time suitable with you. Please <a href="/free-office-assessment">click here</a> to complete a free trial assessment.</p>
			<p>Your consult will include:
				<ul>
					<li>a FREE trial assessment</li>
					<li>an energy savings estimate (please have your electricity bill on hand)</li>
					<li>a lighting efficiency comparison</li>
					<li>a FREE copy of the home ebook</li>
				</ul>
			</p>
		</xsl:if>
		<xsl:if test="/config/globals/item[@key = 'saved']">
			<p style="text-align: center;"><strong>Your assessment has been successfully saved</strong></p>
		</xsl:if>
		<xsl:if test="clientChecklist[@status = 'incomplete']">
			
			<!-- //Choose section title based on domain -->
			<xsl:choose>
				<xsl:when test="/config/domain/@domain_id = '63'">
					<h3>Assessments - Incomplete</h3>
				</xsl:when>
				<xsl:otherwise>
					<h3>Incomplete Assessments</h3>
				</xsl:otherwise>
			</xsl:choose>
			
			<p>In this section you will find all uncompleted assessments. Click on the relevant assessment, answer all of the questions and you will instantly receive your full report.</p>
			<p>Your report will be available below after you have completed the assessment. To view PDF files, download the most recent version of Adobe Reader from the <a href="http://get.adobe.com/reader/" target="_blank">Adobe website</a> for free.</p>
			<xsl:for-each select="clientChecklist[@status = 'incomplete']">
				<p>
					<a href="{concat($root_path,'assessment-checklist/',@client_checklist_id,'/')}" class="assessment_report_title">
                    	<xsl:value-of select="@name" />
                    </a>
                    <xsl:if test="@expired = 'yes'">
                        <span style="color:red;"> - Expired</span>
                    </xsl:if>                    
                    <br /><xsl:value-of select="@progress" />% completed<br />
					<xsl:if test="@last_modified != ''">
						Last Modified: <xsl:value-of select="@last_modified" /><br />
					</xsl:if>
                    <xsl:if test="@audit = 1">
						Expiry Date: <xsl:value-of select="@expiry_date" /><br />
					</xsl:if>
					<xsl:if test="client_checklist_permission">
						<xsl:text>Responsible Contacts: </xsl:text>
						<xsl:for-each select="client_checklist_permission">
							<xsl:value-of select="@contact_full_name"/>
							<xsl:text> </xsl:text>
						</xsl:for-each><br />
					</xsl:if>
					<xsl:if test="/config/plugin[@plugin = 'clients']/client/@client_type_id = '2'">
						<a class="assessment_completed_links" href="/members/?client_checklist_id={@client_checklist_id}&amp;action=delete_assessment" onclick="return(confirm('Did you really mean to click delete?'))">Delete Assessment</a>	
					</xsl:if>
				</p>
				
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="clientChecklist[@status != 'incomplete']">
		
			<!-- //Choose section title based on domain -->
			<xsl:choose>
				<xsl:when test="/config/domain/@domain_id = '63'">
					<h3>Assessments - Completed/Reports</h3>
				</xsl:when>
				<xsl:otherwise>
					<h3>Reports / Complete Assessments</h3>
				</xsl:otherwise>
			</xsl:choose>
		
			<p>This section contains all your reports - click on any highlighted report to view the suggested actions and measures.</p>
			<xsl:for-each select="clientChecklist[@status != 'incomplete'][@parent_checklist_id = '']">
				<xsl:call-template name="renderCompletedClientChecklist" />
			
				<!-- //IF the assessment is a parent_grouped and the client checklist is a child add do hidden/indented -->
				<xsl:if test="@report_type = 'parent_grouped' and count(../clientChecklist[@status != 'incomplete'][@parent_checklist_id = current()/@client_checklist_id]) > 0">
					<div class="child_checklist child_checklists_of_{@client_checklist_id}" style="display:none;">
						<p>
							<a href="#" id="hide_children_checklist_for_{current()/@client_checklist_id}">Hide Previous Updates</a>
						</p>
						<xsl:for-each select="../clientChecklist[@status != 'incomplete'][@parent_checklist_id = current()/@client_checklist_id]">
							<xsl:call-template name="renderCompletedClientChecklist" />
						</xsl:for-each>
					</div>
					
					<!-- //Jquery to show child checklist results -->
					<script type="text/javascript">
					$(document).ready(function() {
						$('#hide_children_checklist_for_<xsl:value-of select="current()/@client_checklist_id" />').click(function(event) {
							$('.child_checklists_of_<xsl:value-of select="current()/@client_checklist_id" />').slideUp();
							event.preventDefault();
						});
					});
					</script>	
				</xsl:if>
			
			</xsl:for-each>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template name="renderCompletedClientChecklist">
	
		<p>
			<xsl:choose>
				<xsl:when test="@report_type = 'answers'">
					<a class="assessment_report_title" href="{concat($root_path,'assessment-answers/',@client_checklist_id,'/')}">
						<xsl:value-of select="@name" />
					</a>
					<xsl:if test="@expired = 'yes'">
						<span style="color:red;"> - Expired</span>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<a class="assessment_report_title" href="{concat($root_path,'assessment-report/',@client_checklist_id,'/')}">
						<xsl:value-of select="@name" />
					</a>
					<xsl:if test="@expired = 'yes'">
						<span style="color:red;"> - Expired</span>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose><br />
						
			<xsl:if test="client_checklist_permission">
				Responsible Contacts: 
				<xsl:for-each select="client_checklist_permission">
					<xsl:value-of select="@contact_full_name"/>
					<xsl:text> </xsl:text>
				</xsl:for-each><br />
			</xsl:if>
			<xsl:text> Completed: </xsl:text>
			<xsl:value-of select="@completed" /><br />
			<xsl:if test="@audit = 1">
				Expiry Date: <xsl:value-of select="@expiry_date" /><br />
			</xsl:if>
			
			<!-- //Check to see if the assessment is a scorable assessment -->
			<xsl:if test="@scorable_assessment = '1' and @multi_site != 'yes'">
				<xsl:choose>
					<xsl:when test="@initial_score != @current_score">
						<xsl:text>Initial Score: </xsl:text>
						<xsl:choose>
							<xsl:when test="@report_type = 'answers'">
								<xsl:text>"N/A</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="format-number(@initial_score,'##%')" />
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text> Current Score: </xsl:text>
						<xsl:choose>
							<xsl:when test="@report_type = 'answers'">
								<xsl:text>N/A</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="format-number(@current_score,'##%')" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Score: </xsl:text>
						<xsl:choose>
							<xsl:when test="@report_type = 'answers'">
								<xsl:text>"N/A</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="format-number(@initial_score,'##%')" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<br />
			</xsl:if>
			
			<!-- //don't do for the children -->
			<xsl:choose>
				<xsl:when test="@parent_checklist_id = '' and @multi_site = 'no'">
					<xsl:if test="@audit_required = '1' or @report_type = 'answers' or @downloadable_reports = '1' or @exportable_actions = '1' or /config/plugin[@plugin = 'clients']/client/@client_type_id = '2'">
						<!--<strong>Actions:</strong>-->
					</xsl:if>
					<!--<br /> -->
					
					<!-- //Check to see if the assessment is auditable -->
					<xsl:if test="@audit_required = '1' and @current_score &gt; '0.69999'">
						<a class="assessment_completed_links" href="{concat($root_path,'assessment-audit/',@client_checklist_id)}">
							<img src="/_images/icons/upload-icon.png" class="actions-icons" alt="Upload Documents" title="Upload Documents" />
						</a>
					</xsl:if>
					
					<xsl:choose>
						<xsl:when test="@report_type = 'answers'">
							<a class="assessment_completed_links" href="{concat($root_path,'assessment-answers/',@client_checklist_id,'?pdf')}">
								<img src="/_images/icons/check-answers-icon.png" class="actions-icons" alt="Check Answers" title="Check Answers" />
							</a>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="@downloadable_reports = '1'">
								<xsl:choose>
									<xsl:when test="@report_type = 'grouped'">
										<a class="assessment_completed_links" href="{concat($root_path,'grouped-report-pdf/',@checklist_id, '?client_checklist_id=', @client_checklist_id, '&amp;group_type=grouped', '&amp;report_type=full')}">
											<img src="/_images/icons/pdf-icon.png" class="actions-icons" alt="Download PDF Report" title="Download PDF Report" />
										</a>
									</xsl:when>
									<xsl:when test="@report_type = 'parent_grouped'">
										<a class="assessment_completed_links" href="{concat($root_path,'grouped-report-pdf/',@checklist_id, '?client_checklist_id=', @client_checklist_id, '&amp;group_type=parent_grouped', '&amp;report_type=full')}">
											<img src="/_images/icons/pdf-icon.png" class="actions-icons" alt="Download PDF Report" title="Download PDF Report" />
										</a>
									</xsl:when>
									<xsl:otherwise>
										<a class="assessment_completed_links" href="{concat($root_path,'report-pdf/',@client_checklist_id,'?report_type=full')}">
											<img src="/_images/icons/pdf-icon.png" class="actions-icons" alt="Download PDF Report" title="Download PDF Report" />
										</a>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							
							<xsl:if test="(@assessment_certificate = '1' and @current_score >= 0.6999) or (@assessment_certificate = '1' and @scorable_assessment = '0')">
								<xsl:if test="@audit_required != '1'">
										<a class="assessment_completed_links" href="{concat('/certificate-pdf/',@client_checklist_id_md5)}">
											<img src="/_images/icons/pdf-icon.png" class="actions-icons" alt="Download PDF Certificate" title="Download PDF Certificate" />
										</a>
								</xsl:if>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="@exportable_actions = '1'">
						
						<a class="assessment_completed_links" href="{concat($root_path,'report-pdf/',@client_checklist_id,'?action=export-actions')}">
							<img src="/_images/icons/export-icon.png" class="actions-icons" alt="Export Actions" title="Export Actions" />
						</a>
					</xsl:if>
					
					<!-- //If the client is a business owner/associate allow them to delete the assessmenmt -->
					<xsl:if test="/config/plugin[@plugin = 'clients']/client/@client_type_id = '2'">
						
						<a class="assessment_completed_links" href="/members/?client_checklist_id={@client_checklist_id}&amp;action=delete_assessment" onclick="return(confirm('Did you really mean to click delete?'))">
							<img src="/_images/icons/delete-icon.png" class="actions-icons" alt="Delete Assessment" title="Delete Assessment" />
						</a>
					</xsl:if>
					
					<a href="#" id="rename_client_checklist_{@client_checklist_id}">
						<img src="/_images/icons/rename-icon.png" class="actions-icons" alt="Rename Assessment" title="Rename Assessment" />
					</a>
					
					<!-- //If the assessment is a parent_grouped and the current client_checklist is a parent add some links -->
					<xsl:if test="@report_type = 'parent_grouped'">
						<xsl:if test="count(../clientChecklist[@status != 'incomplete'][@parent_checklist_id = current()/@client_checklist_id]) > 0">
							<a class="assessment_completed_links" href="#" id="show_children_checklist_for_{current()/@client_checklist_id}">
								<img src="/_images/icons/show-more-icon.png" class="actions-icons" alt="Show Previous Updates" title="Show Previous Updates" />
							</a>
							
							<!-- //Jquery to show child checklist results -->
							<script type="text/javascript">
							$(document).ready(function() {
								$('#show_children_checklist_for_<xsl:value-of select="current()/@client_checklist_id" />').click(function(event) {
									$('.child_checklists_of_<xsl:value-of select="current()/@client_checklist_id" />').slideDown();
									event.preventDefault();
								});
							});
							</script>		
							
						</xsl:if>
						
						<xsl:if test="@is_parent = '1' or @parent_checklist_id = ''">
							<xsl:choose>
								<xsl:when test="@checklist_id = '76'">
									<a class="assessment_completed_links" href="/members/?checklist_id={@checklist_id}&amp;client_checklist_id={@client_checklist_id}&amp;action=create_child_checklist&amp;page_id=1545">
										<img src="/_images/icons/update-icon.png" class="actions-icons" alt="Update your Results" title="Update your Results" />
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a class="assessment_completed_links" href="/members/?checklist_id={@checklist_id}&amp;client_checklist_id={@client_checklist_id}&amp;action=create_child_checklist">
										<img src="/_images/icons/update-icon.png" class="actions-icons" alt="Update your Results" title="Update your Results" />
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<!-- //Add hidden rename client checklist form -->
					<xsl:if test="@multi_site = 'no'">
						<strong>Actions:</strong><br />
						<a href="#" id="rename_client_checklist_{@client_checklist_id}">Rename</a>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<style>
				img.actions-icons {
				padding-right:10px;
				}
			</style>
		</p>
		
		<!--//Call the rename client checklist template -->
		<xsl:call-template name="renameClientChecklist" />
	
	</xsl:template>
	
	<xsl:template name="renameClientChecklist">
		<div class="rename_client_checklist rename_client_checklist_{@client_checklist_id}_form" style="display:none;">
			<form name="rename_client_checklist" method="post">
				<table class="rename_client_checklist_table">
					<tr>
						<td>
							<label>Rename this checklist to: </label>
						</td>
						<td>
							<input type="text" name="checklist_name" />
						</td>
						<td>
							<input type="hidden" name="client_checklist_id" value="{@client_checklist_id}" />
							<input type="hidden" name="action" value="rename_client_checklist" />
							<input type="submit" value="rename" />
						</td>
					</tr>
				</table>
			</form>
		</div>
		
		<!-- //Jquery to show child checklist results -->
		<script type="text/javascript">
		$(document).ready(function() {
			$('#rename_client_checklist_<xsl:value-of select="current()/@client_checklist_id" />').click(function(event) {
				$('.rename_client_checklist_<xsl:value-of select="current()/@client_checklist_id" />_form').slideDown();
				event.preventDefault();
			});
		});
		</script>	
	</xsl:template>
		
</xsl:stylesheet>