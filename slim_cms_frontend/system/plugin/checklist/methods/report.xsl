<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'report']">
		<div id="report-header" />
			<div id="report-header-background">
				<h2 class="report-title"><xsl:value-of select="report/@checklist" /></h2>
				<xsl:if test="/config/plugin[@plugin = 'checklist'][@method = 'report']/report/currentClientSite">
					<br />
					<p>
						This is a multi-site assessment for <strong><xsl:value-of select="/config/plugin[@plugin = 'checklist'][@method = 'report']/report/currentClientSite/@site_name" /></strong>. <a href="/members/assessment-report/{/config/plugin[@plugin = 'checklist'][@method = 'report']/report/currentClientSite/@client_checklist_id}/">Return to the all sites overview page.</a>
					</p>
				</xsl:if>
				</div>
					<form method="post" action="" id="reportForm" class="checklist-id-{/config/plugin[@plugin = 'checklist'][@method = 'report']/report/@checklist_id}">
					  	<input type="hidden" id="linkAfter" name="linkAfter" value="" />
						<input type="hidden" name="action" value="reEvaluateReport" id="action" />
						<input type="hidden" name="current_action_id" id="current_action_id" />

						<input type="hidden" id="linkafter-parent" name="linkafter-parent" value="" />
			
						<!-- Added filter to stop rendering of empty report sections -->
						<xsl:choose>
							<xsl:when test="count(report/clientSite) &gt; 0">

								<!-- //Multi Site Content -->
								<xsl:for-each select="report/reportSection[(@display_in_html = '1' and @multi_site = '1' and @demerits != '0') or (@display_in_html = '1' and @multi_site = '1' and count(content/*) &gt; '0')]">
									<div class="reportSection">
					
										<div class="report-section-count" style="display:none"><xsl:value-of select="position()" /></div>
										<!-- //If there is no title to display do not display the title at all -->
										<xsl:if test="@title != ''">
										<div id="report-sectoin-title-header" />
										<div id="report-section-title-body-background">
											<h3><a id="section-{position()}"></a><figure class="base"><xsl:value-of select="concat(position(),'. ')" /></figure><span class="title"><xsl:value-of select="@title" /></span></h3>
										</div>
										</xsl:if>
										<div id="report-body">
											<xsl:apply-templates select="content/*" mode="html" />					
											<xsl:if test="../confirmation[@report_section_id = current()/@report_section_id]">
												<ul class="ticks2">
													<xsl:for-each select="../confirmation[@report_section_id = current()/@report_section_id]">
														<li><xsl:value-of select="@confirmation"  disable-output-escaping="yes" /></li>
													</xsl:for-each>
												</ul>
											</xsl:if>
											<xsl:apply-templates select="../action[@report_section_id = current()/@report_section_id]">
												<xsl:with-param name="pos" select="position()" />
												<xsl:with-param name="output" select="'list'" />
											</xsl:apply-templates>
										</div>
									</div>
								</xsl:for-each>

							</xsl:when>
							<xsl:otherwise>
			
								<!-- //Regular content -->
								<xsl:for-each select="report/reportSection[(@display_in_html = '1' and @multi_site = '0' and @demerits != '0') or (@display_in_html = '1' and @multi_site = '0' and count(content/*) &gt; '0')]">
									<div class="reportSection">
					
										<div class="report-section-count" style="display:none"><xsl:value-of select="position()" /></div>
										<!-- //If there is no title to display do not display the title at all -->
										<xsl:if test="@title != ''">
										<div id="report-sectoin-title-header" />
										<div id="report-section-title-body-background" class="bullet">
										<h3>
											<a id="section-{position()}"></a>
											<figure class="base">
												<span class="section-number">
													<xsl:value-of select="position()" />
												</span>
											</figure>
											<span class="section-number-separator">.</span>
											<span class="title"><xsl:value-of select="@title" /></span>
										</h3>
										</div>
										</xsl:if>
										<div id="report-body">
											<xsl:apply-templates select="content/*" mode="html" />					
											<xsl:if test="../confirmation[@report_section_id = current()/@report_section_id]">
												<ul class="ticks2">
													<xsl:for-each select="../confirmation[@report_section_id = current()/@report_section_id]">
														<li><xsl:value-of select="@confirmation"  disable-output-escaping="yes" /></li>
													</xsl:for-each>
												</ul>
											</xsl:if>
											<xsl:apply-templates select="../action[@report_section_id = current()/@report_section_id]">
												<xsl:with-param name="pos" select="position()" />
												<xsl:with-param name="output" select="'list'" />
											</xsl:apply-templates>
										</div>
									</div>
								</xsl:for-each>
			
							</xsl:otherwise>
						</xsl:choose>
					<div id="report-footer-top" />
				<div id="report-footer-background" />
			<div id="report-footer" />
		</form>
	</xsl:template>
	
	<xsl:template match="action">
		<xsl:param name="pos" />
		<xsl:param name="output" />
		<xsl:param name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@points)" />

		<xsl:choose>
			<xsl:when test="$output = 'list'">
				<ul class="reportAction">
					<xsl:if test="@commitment_id != '0'">
						<xsl:attribute name="class">ticks</xsl:attribute>
					</xsl:if>
					<!--<li id="action-{@action_id}-head" style="cursor: pointer; list-style-type: none;">-->
					<li id="action-{@action_id}-head">
						<strong>
							<xsl:value-of select="concat($pos,'.',position())" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="@summary" disable-output-escaping="yes" />
						</strong>
						<xsl:if test="@demerits &gt; 0 and /config/plugin[@plugin = 'checklist']/report/@scorable_assessment = '1'">
							<span class="actionDemeritValue"><xsl:value-of select="format-number(@demerits div $points,' (#.##%)')" /></span>
						</xsl:if>
					</li>
				</ul>
				<div id="action-{@action_id}-body" style="display:none;">
					<div class="measure">	
						<xsl:apply-templates select="proposed_measure[. != '']" />
					</div>
				</div>
				
				<!-- //Call the Add/Edit/Delete Action Owners Form -->
				<div id="owner-action-{@action_id}-body" style="display:none;">
					<xsl:call-template name="action_owner_edit">
						<xsl:with-param name="action_id" select="@action_id" />
					</xsl:call-template>
				</div>
			</xsl:when>
			
			<!-- //Otherwise it is a table output -->
			<xsl:otherwise>
				<tr>
					<td>
						<!--<xsl:value-of select="proposed_measure" disable-output-escaping="yes" />-->
						<xsl:apply-templates select="proposed_measure/*" mode="html" />
					</td>
					<td>
						<xsl:choose>
							<xsl:when test="@summary != ''">
								<a href="{@summary}" target="_blank">
								link
									<!--<xsl:value-of select="@title" disable-output-escaping="yes" />-->
								</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@title" disable-output-escaping="yes" />
							</xsl:otherwise>
						</xsl:choose>
					</td>
					<td>
						<label>
							<input type="radio" name="commitment[{@action_id}]" value="0">
								<xsl:if test="@commitment_id = 0"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
							</input>
							<xsl:text> No</xsl:text>
						</label>
						<label>
							<input type="radio" name="commitment[{@action_id}]" value="{../commitment[@action_id = current()/@action_id]/@commitment_id}">
								<xsl:if test="../commitment[@action_id = current()/@action_id]/@commitment_id = current()/@commitment_id">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<xsl:text> Yes</xsl:text>
						</label>
						<input type="image" src="/_images/icons/save.png" value="Submit" onclick="$('#linkAfter').attr('value', 'action-{@action_id}-head'); return true;" />
					</td>
				</tr>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="proposed_measure">
		<xsl:param name="action" select=".." />
		<xsl:if test="./*">
			<h3>Action</h3>
			<div style="font-weight: bold;">
				<xsl:apply-templates select="./*" mode="html" />
			</div>
			<hr />
		</xsl:if>
		<xsl:if test="../comments/*">
			<h3>Facts</h3>
			<xsl:apply-templates select="../comments/*" mode="html" />
			<hr />
		</xsl:if>
		<xsl:if test="../../commitment[@action_id = $action/@action_id]">
			<fieldset class="commitments">
				<h3>Your Commitment Options</h3>
				<xsl:for-each select="../../commitment[@action_id = $action/@action_id]">
					<p>
						<label>
							<input type="radio" name="commitment[{@action_id}]" value="{@commitment_id}">
								<xsl:if test="$action/@commitment_id = current()/@commitment_id">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<xsl:text> </xsl:text>
							<xsl:value-of select="@commitment" disable-output-escaping="yes" />
						</label>
					</p>
				</xsl:for-each>
				<p>
					<label>
						<input type="radio" name="commitment[{$action/@action_id}]" value="0">
							<xsl:if test="$action/@commitment_id = 0"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
						</input>
						<xsl:text> We can not commit to this action.</xsl:text>
					</label>
				</p>
				<!--<div style="text-align: center;"><input type="submit" value="Submit" onclick="$('#linkAfter').attr('value', 'action-{$action/@action_id}-head'); return true;" /></div> -->
                
                <!-- //Add the ability to assign the action to person -->
                <hr />
                <h3>Assign Action (optional)</h3>
                <p>You can assign this action to a member of your team and email the action details to them for completion.</p>
				<div id="assign_action">
                	<style>
						#ui-datepicker-div { display: none; } 
					</style>
					<script type="text/javascript">
					
						$(function() {
						 
						 	$( "#action-<xsl:value-of select="$action/@action_id" />-due-date" ).datepicker();
							$( "#action-<xsl:value-of select="$action/@action_id" />-due-date" ).datepicker("option","dateFormat","yy-mm-dd");
							
							<xsl:if test="substring(/config/plugin[@plugin = 'checklist']/report/owner2Action[@action_id = $action/@action_id]/@due_date,1,10) != '0000-00-00'">
							var queryDate = '<xsl:value-of select="substring(/config/plugin[@plugin = 'checklist']/report/owner2Action[@action_id = $action/@action_id]/@due_date,1,10)" />';
							var parsedDate = $.datepicker.parseDate('yy-mm-dd', queryDate);
								$( "#action-<xsl:value-of select="$action/@action_id" />-due-date" ).datepicker("setDate", parsedDate);
							</xsl:if>
						});
						
						$(function() {
						    $('#action_owner_id_<xsl:value-of select="$action/@action_id" />_edit').change(function(){
        						if($("#action_owner_id_<xsl:value-of select="$action/@action_id" />_edit").val() == 'edit') {
        							$("#owner-action-<xsl:value-of select="$action/@action_id" />-body").toggle('slow');
        						}
        						else {
									$("#owner-action-<xsl:value-of select="$action/@action_id" />-body").hide('slow');
								}
    						});
						});
						
						$(function() {
						    $('#btnAdd_<xsl:value-of select="$action/@action_id" />').click(function() {
						        $('#blank_row_<xsl:value-of select="$action/@action_id" />').clone().appendTo('#action_owner_edit_table_<xsl:value-of select="$action/@action_id" />');
						    });
						});
						
					</script>
					<table class="assignActionTable">
						<tr>
							<th width="70%">Assign to</th>
							<th>Due Date</th>
						</tr>
						<tr>
							<td width="70%">
								<select name="action_{$action/@action_id}_owner_id" id="action_owner_id_{$action/@action_id}_edit">
									<option value="">-- None --</option>
									<option value="edit">-- Edit Action Owners --</option>
									<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/actionOwner">
										<option value="{@action_owner_id}">
											<xsl:if test="/config/plugin[@plugin = 'checklist']/report/owner2Action[(@owner_id = current()/@action_owner_id) and (@action_id = $action/@action_id)]">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>
											<xsl:if test="@first_name != ''">
												<xsl:value-of select="@first_name" /><xsl:text> </xsl:text>
											</xsl:if>
											<xsl:if test="@last_name != ''">
												<xsl:value-of select="@last_name" /><xsl:text> </xsl:text>
											</xsl:if>
											<xsl:if test="@email != ''">
												<xsl:text>[</xsl:text><xsl:value-of select="@email" /><xsl:text>]</xsl:text>
											</xsl:if>
										</option>
									</xsl:for-each>
								</select>
							</td>
							<td>
								<input type="text" name="action_{$action/@action_id}_due_date" id="action-{$action/@action_id}-due-date" />
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<p><center><img src="/_images/emailIcon.png" style="padding-right:10px;" />
								<input type="hidden" name="action_{$action/@action_id}_email" value="0" />
								<input type="checkbox" name="action_{$action/@action_id}_email" value="1" checked="checked" />
								Email action to team member</center></p>
							</td>
						</tr>
					</table>
				</div>
				<input type="hidden" name="action_{$action/@action_id}_owner_2_action_id" value="{/config/plugin[@plugin = 'checklist']/report/owner2Action[@action_id = $action/@action_id]/@owner_2_action_id}" />
				<input type="hidden" name="action_{$action/@action_id}_assigned_by" value="{/config/plugin[@plugin = 'clients']/client/@client_contact_id}" />
				<div style="text-align: center;padding-top:10px;"><input type="submit" value="Update" onclick="$('#linkAfter').attr('value', 'action-{$action/@action_id}-head'); document.getElementById('current_action_id').value='{$action/@action_id}'; return true;" /></div>
                
			</fieldset>
		</xsl:if>							
	</xsl:template>
	
	<xsl:template name="action_owner_edit">
		<xsl:param name="action_id" />
		<xsl:variable name="action" select="/config/plugin[@plugin = 'checklist']/report/action[@action_id = $action_id]" />
		<!--<form name="action_owner_edit_form">-->
		<div id="action_owner_edit">
			<table id="action_owner_edit_table_{$action/@action_id}" class="actionOwnerEditTable">
				<tr>
					<th>First Name</th>
					<th>Last Name</th>
					<th>Email</th>
					<th><div id="trashbin" /></th>
				</tr>
				<!-- //First list all of the possible account owners -->
				<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/actionOwner">
					<tr>
						<td>
							<input type="text" name="first_name[]" value="{@first_name}" />
						</td>
						<td>
							<input type="text" name="last_name[]" value="{@last_name}" />
						</td>
						<td>
							<input type="text" name="email[]" value="{@email}" />
						</td>
						<td>
							<input type="checkbox" name="delete[]" value="{@action_owner_id}" />
							<input type="hidden" name="existing_action_owner_id[]" value="{@action_owner_id}" />
						</td>
					</tr>
				</xsl:for-each>
				<!-- //Now show the add field -->
				<tr id="blank_row_{$action/@action_id}">
					<td>
						<input type="text" name="first_name[]" />
					</td>
					<td>
						<input type="text" name="last_name[]" />
					</td>
					<td>
						<input type="text" name="email[]" />
					</td>
					<td>
						<input type="hidden" name="existing_action_owner_id[]" value="0" />
					</td>
				</tr>
			</table>
			<div style="text-align: center;padding-top:10px;">
				<input type="hidden" name="action_owner_client_id" value="{/config/plugin[@plugin = 'checklist']/report/@client_id}" />
				<button type="button" id="btnAdd_{$action/@action_id}">Add Row</button> 
				<input type="submit" value="Update" onclick="$('#linkAfter').attr('value', 'action-{$action/@action_id}-head'); document.getElementById('action').value='update_action_owners'; document.getElementById('current_action_id').value='{$action/@action_id}'; return true;"/>
			</div>
		</div>
	<!-- </form> -->
	</xsl:template>
	
	<xsl:template match="certificationLevels" mode="html">
		<xsl:choose>
			<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@variation_id = '2'">
				<p>There are no certification levels for this assessment</p>
			</xsl:when>
			<xsl:otherwise>
		
				<!--JQuery Knob variables -->
				<xsl:variable name="overlay_width" select="180" />
				<xsl:variable name="overlay_height" select="144" />
				<xsl:variable name="base_offset" select="-125" />
				<xsl:variable name="base_arc" select="250" />
		
				<div class="certification-levels-container">
			
					<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/certificationLevel">
						<div class="certification-level-container percentage-container">
							<xsl:variable name="certification_level" select="@certification_level_id" />
							<!-- //Actual Value -->
							<div class="certification-level-target-{@certification_level_id} percentage-container-inner">
								<input type="text" id="certification-level-target-{@certification_level_id}" name="certification-level-target-{@certification_level_id}" value="{@target}" 
								data-angleOffset="-125" data-angleArc="250" data-width="150" data-thickness=".4" data-fgColor="#00b1b2" data-bgColor="#ccc" data-height="120" data-readOnly="true" />
								<script type="text/javascript">
									$(function() {
										$('#certification-level-target-<xsl:value-of select="@certification_level_id" />').knob({
											 'draw' : function () {
												if(isNaN(this.cv)) {
													this.i.val( 0 + '%');
												} else {
													this.i.val( this.cv + '%');
												}
											}
										});
									});
								</script>
							</div>
			
							<div class="section-title">
								<p><xsl:value-of select="@name" /></p>
							</div>
			
							<!-- //For Each Certification Level -->
							<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/certificationLevel">
								<xsl:sort select="@target" data-type="number" />
				
								<!-- Set the current arc, if there is a sibling next, limit the arc -->
								<xsl:variable name="dataAngleArc">
									<xsl:choose>
										<xsl:when test="following-sibling::certificationLevel[1]">
											<xsl:value-of select="((((100 - @target) div 100) * $base_arc) - (((100 - following-sibling::certificationLevel[1]/@target) div 100) * $base_arc))" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="(((100 - @target) div 100) * $base_arc)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
				
								<xsl:variable name="dataAngleOffset" select="((($base_arc div 100) * @target) - ($base_arc div 2))" />
								<div class="score-overlay-container certification-level-target-{@certification_level_id}-{$certification_level}">
									<input type="text" id="certification-level-target-{@certification_level_id}-{$certification_level}"
									name="certification-level-target-{@certification_level_id}-{$certification_level}" value=""
									data-angleOffset="{$dataAngleOffset}" data-angleArc="{$dataAngleArc}" data-width="{$overlay_width}" data-thickness=".1"
									data-fgColor="transparent" data-bgColor="#{@color}" data-height="{$overlay_height}" data-readOnly="true" />
									<script type="text/javascript">
										$(function() {
											$('#certification-level-target-<xsl:value-of select="@certification_level_id" />-<xsl:value-of select="$certification_level" />').knob();
										});
									</script>
								</div>
							</xsl:for-each>
						</div>
					</xsl:for-each>
				
				</div>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- //Check the assessment to see if there are certification levels -->
	<xsl:template match="overallScore" mode="html">
		
		<xsl:choose>
			<xsl:when test="count(/config/plugin[@plugin = 'checklist']/report/certificationLevel) &gt; 0">
				<xsl:call-template name="overallScoreWithCertificationLevels" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="overallScoreGeneric" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<!-- //If there are no certification levels, break into 5 segments of color blocks -->
	<xsl:template name="overallScoreGeneric">
		<xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@points)" />
		<xsl:variable name="demerits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@demerits)" />
		<xsl:variable name="merits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@merits)" />
		<xsl:variable name="initial_rate" select="($points - $demerits) div $points" />
		<xsl:variable name="current_rate" select="($points - $demerits + $merits) div $points" />
		
		<!--JQuery Knob variables -->
		<xsl:variable name="overlay_width" select="180" />
		<xsl:variable name="overlay_height" select="144" />
		<xsl:variable name="base_offset" select="-125" />
		<xsl:variable name="base_arc" select="250" />
		
		<div class="overall-score-container">
			<div class="initial-score percentage-container">
			
				<!-- //Actual Value -->
				<div class="initial-score">
					<input type="text" id="initial-score" name="initial-score" value="{format-number(($initial_rate*100),'##')}" 
					data-angleOffset="-125" data-angleArc="250" data-width="150" data-thickness=".4" data-fgColor="#00b1b2" data-bgColor="#ccc" data-height="120" data-readOnly="true" />
					<script type="text/javascript">
						$(function() {
							$('#initial-score').knob({
								 'draw' : function () {
									if(isNaN(this.cv)) {
										this.i.val( 0 + '%');
									} else {
										this.i.val( this.cv + '%');
									}
								}
							});
						});
					</script>
				</div>
				
				<div class="section-title">
					<p>Initial Score</p>
				</div>
				
				<!-- //For Each Certification Level -->
				<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/genericCertificationLevel">
					<xsl:sort select="@target" data-type="number" />
					
					<!-- Set the current arc, if there is a sibling next, limit the arc -->
					<xsl:variable name="dataAngleArc">
						<xsl:choose>
							<xsl:when test="following-sibling::genericCertificationLevel[1]">
								<xsl:value-of select="((((100 - @target) div 100) * $base_arc) - (((100 - following-sibling::genericCertificationLevel[1]/@target) div 100) * $base_arc))" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="(((100 - @target) div 100) * $base_arc)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="dataAngleOffset" select="((($base_arc div 100) * @target) - ($base_arc div 2))" />
					<div class="initial-score-overlay-container certification-level-{@level_id}">
						<input type="text" id="initial-score-{@level_id}" name="initial-score-{@level_id}" value=""
						data-angleOffset="{$dataAngleOffset}" data-angleArc="{$dataAngleArc}" data-width="{$overlay_width}" data-thickness=".1"
						data-fgColor="transparent" data-bgColor="#{@color}" data-height="{$overlay_height}" data-readOnly="true" />
						<script type="text/javascript">
							$(function() {
								$('#initial-score-<xsl:value-of select='@level_id' />').knob();
							});
						</script>
					</div>
				</xsl:for-each>
				
			</div>
			
			<div class="current-score percentage-container">
			
				<!-- //Actual Value -->
				<div class="current-score">
					<input type="text" id="current-score" name="current-score" value="{format-number(($current_rate*100),'##')}" 
					data-angleOffset="-125" data-angleArc="250" data-width="150" data-thickness=".4" data-fgColor="#00b1b2" data-bgColor="#ccc" data-height="120" data-readOnly="true" />
					<script type="text/javascript">
						$(function() {
							$('#current-score').knob({
								 'draw' : function () {
									if(isNaN(this.cv)) {
										this.i.val( 0 + '%');
									} else {
										this.i.val( this.cv + '%');
									}
								}
							});
						});
					</script>
				</div>
				
				<div class="section-title">
					<p>Current Score</p>
				</div>
				
				<!-- //For Each Certification Level -->
				<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/genericCertificationLevel">
					<xsl:sort select="@target" data-type="number" />
					
					<!-- Set the current arc, if there is a sibling next, limit the arc -->
					<xsl:variable name="dataAngleArc">
						<xsl:choose>
							<xsl:when test="following-sibling::genericCertificationLevel[1]">
								<xsl:value-of select="((((100 - @target) div 100) * $base_arc) - (((100 - following-sibling::genericCertificationLevel[1]/@target) div 100) * $base_arc))" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="(((100 - @target) div 100) * $base_arc)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="dataAngleOffset" select="((($base_arc div 100) * @target) - ($base_arc div 2))" />
					<div class="current-score-overlay-container certification-level-{@level_id}">
						<input type="text" id="current-score-{@level_id}" name="current-score-{@level_id}" value=""
						data-angleOffset="{$dataAngleOffset}" data-angleArc="{$dataAngleArc}" data-width="{$overlay_width}" data-thickness=".1"
						data-fgColor="transparent" data-bgColor="#{@color}" data-height="{$overlay_height}" data-readOnly="true" />
						<script type="text/javascript">
							$(function() {
								$('#current-score-<xsl:value-of select='@level_id' />').knob();
							});
						</script>
					</div>
				</xsl:for-each>
				
			</div>
		</div>
	</xsl:template>
	
	<!-- //If there are certification levels to render do so with this dial showing the different colourss -->
	<xsl:template name="overallScoreWithCertificationLevels">
		<xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@points)" />
		<xsl:variable name="demerits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@demerits)" />
		<xsl:variable name="merits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection/@merits)" />
		<xsl:variable name="initial_rate" select="($points - $demerits) div $points" />
		<xsl:variable name="current_rate" select="($points - $demerits + $merits) div $points" />
		
		<!--JQuery Knob variables -->
		<xsl:variable name="overlay_width" select="180" />
		<xsl:variable name="overlay_height" select="144" />
		<xsl:variable name="base_offset" select="-125" />
		<xsl:variable name="base_arc" select="250" />
		
		<div class="overall-score-container">
			<div class="initial-score percentage-container">
			
				<!-- //Actual Value -->
				<div class="initial-score">
					<input type="text" id="initial-score" name="initial-score" value="{format-number(($initial_rate*100),'##')}" 
					data-angleOffset="-125" data-angleArc="250" data-width="150" data-thickness=".4" data-fgColor="#00b1b2" data-bgColor="#ccc" data-height="120" data-readOnly="true" />
					<script type="text/javascript">
						$(function() {
							$('#initial-score').knob({
								 'draw' : function () {
									if(isNaN(this.cv)) {
										this.i.val( 0 + '%');
									} else {
										this.i.val( this.cv + '%');
									}
								}
							});
						});
					</script>
				</div>
				
				<div class="section-title">
					<p>Initial Score</p>
				</div>
				
				<!-- //For Each Certification Level -->
				<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/certificationLevel">
					<xsl:sort select="@target" data-type="number" />
					
					<!-- Set the current arc, if there is a sibling next, limit the arc -->
					<xsl:variable name="dataAngleArc">
						<xsl:choose>
							<xsl:when test="following-sibling::certificationLevel[1]">
								<xsl:value-of select="((((100 - @target) div 100) * $base_arc) - (((100 - following-sibling::certificationLevel[1]/@target) div 100) * $base_arc))" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="(((100 - @target) div 100) * $base_arc)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="dataAngleOffset" select="((($base_arc div 100) * @target) - ($base_arc div 2))" />
					<div class="initial-score-overlay-container certification-level-{@name}">
						<input type="text" id="initial-score-{@name}" name="initial-score-{@name}" value=""
						data-angleOffset="{$dataAngleOffset}" data-angleArc="{$dataAngleArc}" data-width="{$overlay_width}" data-thickness=".1"
						data-fgColor="transparent" data-bgColor="#{@color}" data-height="{$overlay_height}" data-readOnly="true" />
						<script type="text/javascript">
							$(function() {
								$('#initial-score-<xsl:value-of select='@name' />').knob();
							});
						</script>
					</div>
				</xsl:for-each>
				
			</div>
			
			<div class="current-score percentage-container">
			
				<!-- //Actual Value -->
				<div class="current-score">
					<input type="text" id="current-score" name="current-score" value="{format-number(($current_rate*100),'##')}" 
					data-angleOffset="-125" data-angleArc="250" data-width="150" data-thickness=".4" data-fgColor="#00b1b2" data-bgColor="#ccc" data-height="120" data-readOnly="true" />
					<script type="text/javascript">
						$(function() {
							$('#current-score').knob({
								 'draw' : function () {
									if(isNaN(this.cv)) {
										this.i.val( 0 + '%');
									} else {
										this.i.val( this.cv + '%');
									}
								}
							});
						});
					</script>
				</div>
				
				<div class="section-title">
					<p>Current Score</p>
				</div>
				
				<!-- //For Each Certification Level -->
				<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/certificationLevel">
					<xsl:sort select="@target" data-type="number" />
					
					<!-- Set the current arc, if there is a sibling next, limit the arc -->
					<xsl:variable name="dataAngleArc">
						<xsl:choose>
							<xsl:when test="following-sibling::certificationLevel[1]">
								<xsl:value-of select="((((100 - @target) div 100) * $base_arc) - (((100 - following-sibling::certificationLevel[1]/@target) div 100) * $base_arc))" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="(((100 - @target) div 100) * $base_arc)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="dataAngleOffset" select="((($base_arc div 100) * @target) - ($base_arc div 2))" />
					<div class="current-score-overlay-container certification-level-{@name}">
						<input type="text" id="current-score-{@name}" name="current-score-{@name}" value=""
						data-angleOffset="{$dataAngleOffset}" data-angleArc="{$dataAngleArc}" data-width="{$overlay_width}" data-thickness=".1"
						data-fgColor="transparent" data-bgColor="#{@color}" data-height="{$overlay_height}" data-readOnly="true" />
						<script type="text/javascript">
							$(function() {
								$('#current-score-<xsl:value-of select='@name' />').knob();
							});
						</script>
					</div>
				</xsl:for-each>
				
			</div>
			
			<!-- //Current Stamp -->
			<div class="current-score percentage-container">
				<img src="https://www.greenbizcheck.com/stamp/?cclid={/config/plugin[@plugin = 'checklist']/report/@client_checklist_id}&amp;w=150" class="current-certification-level" style="padding-left:20px;"/>
			</div>
			
		</div>
	</xsl:template>
	
	<!-- //If there are certification levels to render do so with this dial showing the different colourss -->
	<xsl:template match="clientSiteOverallScores" mode="html">
		<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/clientSite">
			<h3><xsl:value-of select="@site_name" /></h3>
			<xsl:variable name="initial_rate" select="@initial_score" />
			<xsl:variable name="current_rate" select="@current_score" />
			<xsl:variable name="client_site_id" select="@client_site_id" />
		
			<!--JQuery Knob variables -->
			<xsl:variable name="overlay_width" select="180" />
			<xsl:variable name="overlay_height" select="144" />
			<xsl:variable name="base_offset" select="-125" />
			<xsl:variable name="base_arc" select="250" />
		
			<div class="overall-score-container">
				<div class="initial-score percentage-container">
			
					<!-- //Actual Value -->
					<div class="initial-score">
						<input type="text" id="initial-score-{@client_site_id}" name="initial-score-{@client_site_id}" value="{format-number(($initial_rate*100),'##')}" 
						data-angleOffset="-125" data-angleArc="250" data-width="150" data-thickness=".4" data-fgColor="#00b1b2" data-bgColor="#ccc" data-height="120" data-readOnly="true" />
						<script type="text/javascript">
							$(function() {
								$('#initial-score-<xsl:value-of select="@client_site_id" />').knob({
									 'draw' : function () {
										if(isNaN(this.cv)) {
											this.i.val( 0 + '%');
										} else {
											this.i.val( this.cv + '%');
										}
									}
								});
							});
						</script>
					</div>
				
					<div class="section-title">
						<p>Initial Score</p>
					</div>
				
					<!-- //For Each Certification Level -->
					<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/certificationLevel">
						<xsl:sort select="@target" data-type="number" />
					
						<!-- Set the current arc, if there is a sibling next, limit the arc -->
						<xsl:variable name="dataAngleArc">
							<xsl:choose>
								<xsl:when test="following-sibling::certificationLevel[1]">
									<xsl:value-of select="((((100 - @target) div 100) * $base_arc) - (((100 - following-sibling::certificationLevel[1]/@target) div 100) * $base_arc))" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="(((100 - @target) div 100) * $base_arc)" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
					
						<xsl:variable name="dataAngleOffset" select="((($base_arc div 100) * @target) - ($base_arc div 2))" />
						<div class="initial-score-overlay-container certification-level-{@name}">
							<input type="text" id="initial-score-{@name}-{$client_site_id}" name="initial-score-{@name}-{$client_site_id}" value=""
							data-angleOffset="{$dataAngleOffset}" data-angleArc="{$dataAngleArc}" data-width="{$overlay_width}" data-thickness=".1"
							data-fgColor="transparent" data-bgColor="#{@color}" data-height="{$overlay_height}" data-readOnly="true" />
							<script type="text/javascript">
								$(function() {
									$('#initial-score-<xsl:value-of select='@name' />-<xsl:value-of select='$client_site_id' />').knob();
								});
							</script>
						</div>
					</xsl:for-each>
				
				</div>
			
				<div class="current-score percentage-container">
			
					<!-- //Actual Value -->
					<div class="current-score">
						<input type="text" id="current-score-{@client_site_id}" name="current-score-{@client_site_id}" value="{format-number(($current_rate*100),'##')}" 
						data-angleOffset="-125" data-angleArc="250" data-width="150" data-thickness=".4" data-fgColor="#00b1b2" data-bgColor="#ccc" data-height="120" data-readOnly="true" />
						<script type="text/javascript">
							$(function() {
								$('#current-score-<xsl:value-of select="@client_site_id" />').knob({
									 'draw' : function () {
										if(isNaN(this.cv)) {
											this.i.val( 0 + '%');
										} else {
											this.i.val( this.cv + '%');
										}
									}
								});
							});
						</script>
					</div>
				
					<div class="section-title">
						<p>Current Score</p>
					</div>
				
					<!-- //For Each Certification Level -->
					<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/certificationLevel">
						<xsl:sort select="@target" data-type="number" />
					
						<!-- Set the current arc, if there is a sibling next, limit the arc -->
						<xsl:variable name="dataAngleArc">
							<xsl:choose>
								<xsl:when test="following-sibling::certificationLevel[1]">
									<xsl:value-of select="((((100 - @target) div 100) * $base_arc) - (((100 - following-sibling::certificationLevel[1]/@target) div 100) * $base_arc))" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="(((100 - @target) div 100) * $base_arc)" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
					
						<xsl:variable name="dataAngleOffset" select="((($base_arc div 100) * @target) - ($base_arc div 2))" />
						<div class="current-score-overlay-container certification-level-{@name}">
							<input type="text" id="current-score-{@name}-{$client_site_id}" name="current-score-{@name}-{$client_site_id}" value=""
							data-angleOffset="{$dataAngleOffset}" data-angleArc="{$dataAngleArc}" data-width="{$overlay_width}" data-thickness=".1"
							data-fgColor="transparent" data-bgColor="#{@color}" data-height="{$overlay_height}" data-readOnly="true" />
							<script type="text/javascript">
								$(function() {
									$('#current-score-<xsl:value-of select='@name' />-<xsl:value-of select='$client_site_id' />').knob();
								});
							</script>
						</div>
					</xsl:for-each>
				
				</div>
			
				<!-- //Current Stamp -->
				<div class="current-score percentage-container">
					<img src="https://www.greenbizcheck.com/stamp/?cclid={@child_client_checklist_id}&amp;w=150" class="current-certification-level" style="padding-left:20px;"/>
				</div>
			
			</div>
			
			<br />
			<a href="/members/assessment-report/{@child_client_checklist_id}/" class="button-link">
				<button type="button">More Information</button>
			</a>
			<br />
			
		</xsl:for-each>
	</xsl:template>
	
	<!-- //Catagory score with dials -->
	<xsl:template match="categoryScores" mode="html">
		<!--JQuery Knob variables -->
		<xsl:variable name="overlay_width" select="90" />
		<xsl:variable name="overlay_height" select="72" />
		<xsl:variable name="base_offset" select="-125" />
		<xsl:variable name="base_arc" select="250" />
		
		<div class="category-scores-container">
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/reportSection[@points &gt; 0]">
				<xsl:variable name="initial_rate" select="(@points - @demerits) div @points" />
				<xsl:variable name="current_rate" select="(@points - @demerits + @merits) div @points" />
				<xsl:variable name="report-section-id" select="@report_section_id" />
				<div class="category-score-container">
					
					<!-- //Report Section Name -->
					<div class="report-section-title">
						<p><xsl:value-of select="@title" /></p>
					</div>
				
					<div class="initial-score percentage-container">
			
						<!-- //Actual Value -->
						<div class="initial-score">
							<input type="text" id="initial-score-{@report_section_id}" name="initial-score-{@report_section_id}" value="{format-number(($initial_rate*100),'##')}" 
							data-angleOffset="-125" data-angleArc="250" data-width="75" data-thickness=".4" data-fgColor="#00b1b2" data-bgColor="#ccc" data-height="60" data-readOnly="true" />
							<script type="text/javascript">
								$(function() {
									$('#initial-score-<xsl:value-of select="@report_section_id" />').knob({
										 'draw' : function () {
											if(isNaN(this.cv)) {
												this.i.val( 0 + '%');
											} else {
												this.i.val( this.cv + '%');
											}
										}
									});
								});
							</script>
						</div>
				
						<div class="section-title">
							<p>Initial Score</p>
						</div>
				
						<!-- //For Each Certification Level -->
						<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/genericCertificationLevel">
							<xsl:sort select="@target" data-type="number" />
					
							<!-- Set the current arc, if there is a sibling next, limit the arc -->
							<xsl:variable name="dataAngleArc">
								<xsl:choose>
									<xsl:when test="following-sibling::genericCertificationLevel[1]">
										<xsl:value-of select="((((100 - @target) div 100) * $base_arc) - (((100 - following-sibling::genericCertificationLevel[1]/@target) div 100) * $base_arc))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="(((100 - @target) div 100) * $base_arc)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
					
							<xsl:variable name="dataAngleOffset" select="((($base_arc div 100) * @target) - ($base_arc div 2))" />
							<div class="initial-score-overlay-container certification-level-{@level_id}-{$report-section-id}">
								<input type="text" id="initial-score-{@level_id}-{$report-section-id}" name="initial-score-{@level_id}-{$report-section-id}" value=""
								data-angleOffset="{$dataAngleOffset}" data-angleArc="{$dataAngleArc}" data-width="{$overlay_width}" data-thickness=".1"
								data-fgColor="transparent" data-bgColor="#{@color}" data-height="{$overlay_height}" data-readOnly="true" />
								<script type="text/javascript">
									$(function() {
										$('#initial-score-<xsl:value-of select='@level_id' />-<xsl:value-of select="$report-section-id" />').knob();
									});
								</script>
							</div>
						</xsl:for-each>
				
					</div>
			
					<div class="current-score percentage-container">
			
						<!-- //Actual Value -->
						<div class="current-score">
							<input type="text" id="current-score-{@report_section_id}" name="current-score-{@report_section_id}" value="{format-number(($current_rate*100),'##')}" 
							data-angleOffset="-125" data-angleArc="250" data-width="75" data-thickness=".4" data-fgColor="#00b1b2" data-bgColor="#ccc" data-height="60" data-readOnly="true" />
							<script type="text/javascript">
								$(function() {
									$('#current-score-<xsl:value-of select="@report_section_id" />').knob({
										 'draw' : function () {
											if(isNaN(this.cv)) {
												this.i.val( 0 + '%');
											} else {
												this.i.val( this.cv + '%');
											}
										}
									});
								});
							</script>
						</div>
				
						<div class="section-title">
							<p>Current Score</p>
						</div>
				
						<!-- //For Each Certification Level -->
						<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/genericCertificationLevel">
							<xsl:sort select="@target" data-type="number" />
					
							<!-- Set the current arc, if there is a sibling next, limit the arc -->
							<xsl:variable name="dataAngleArc">
								<xsl:choose>
									<xsl:when test="following-sibling::genericCertificationLevel[1]">
										<xsl:value-of select="((((100 - @target) div 100) * $base_arc) - (((100 - following-sibling::genericCertificationLevel[1]/@target) div 100) * $base_arc))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="(((100 - @target) div 100) * $base_arc)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
					
							<xsl:variable name="dataAngleOffset" select="((($base_arc div 100) * @target) - ($base_arc div 2))" />
							<div class="current-score-overlay-container certification-level-{@level_id}-{$report-section-id}">
								<input type="text" id="current-score-{@level_id}-{$report-section-id}" name="current-score-{@level_id}-{$report-section-id}" value=""
								data-angleOffset="{$dataAngleOffset}" data-angleArc="{$dataAngleArc}" data-width="{$overlay_width}" data-thickness=".1"
								data-fgColor="transparent" data-bgColor="#{@color}" data-height="{$overlay_height}" data-readOnly="true" />
								<script type="text/javascript">
									$(function() {
										$('#current-score-<xsl:value-of select='@level_id' />-<xsl:value-of select="$report-section-id" />').knob();
									});
								</script>
							</div>
						</xsl:for-each>
				
					</div>
				</div>
			</xsl:for-each>
		</div>
	</xsl:template>
	
	<!-- //Radar Graph Category Scores -->
	<xsl:template match="radarGraphCategoryScores" mode="html">
		
		<!--//Call the rdar graph with the scores of the assessment -->
		<!-- //Build the URL for the graph image -->
		<xsl:variable name="graph_url">
			<xsl:text>https://www.greenbizcheck.com/graph/?g=radarGraph&amp;w=700&amp;h=500&amp;graphTitle=Category-Scores&amp;unique_time_stamp=</xsl:text>
			<xsl:variable name="unique_time_stamp" select="concat(/config/datetime/@year,/config/datetime/@month,/config/datetime/@day,/config/datetime/@hour,/config/datetime/@minute,/config/datetime/@second)" />
			<xsl:value-of select="$unique_time_stamp" />
			<xsl:text>-category-scores</xsl:text>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/reportSection">
				<xsl:if test="(count(../action[@report_section_id = current()/@report_section_id]) &gt; 0) or (count(../confirmation[@report_section_id = current()/@report_section_id]) &gt; 0)">
					<xsl:variable name="current_score" select="format-number(((@points - @demerits + @merits) div @points)*100,'#')" />
					<xsl:text>&amp;xdata[</xsl:text><xsl:value-of select="@report_section_id" /><xsl:text>]=</xsl:text><xsl:value-of select="translate(@safe_title,' ','-')" />
					<xsl:text>&amp;ydata[</xsl:text><xsl:value-of select="@report_section_id" /><xsl:text>]=</xsl:text><xsl:value-of select="$current_score" />		
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
        
        <div class="radar-graph">
        	<img src="{$graph_url}" class="radar-graph" />
        </div>
		
		<xsl:call-template name="assignedActions" />
	</xsl:template>
	
	<!-- //GHG HTML REPORT TEMPLATE -->
	<xsl:template match="ghgMetricAnswers" mode="html">
		
		<!-- //Loop through all of the metric groups - then through the metrics -->
		
		<xsl:for-each select="/config/plugin[@plugin = 'checklist'][@method = 'report']/report/metricGroup">
			<xsl:sort select="@sequence" data-type="number" />
			<xsl:if test="count(clientMetric[@ghg_calculation != 'ignore']) &gt; 0">
				<h4 class="report-output"><xsl:value-of select="@name" /></h4>
			
				<table class="audit_table">
					<col style="width: 70%;" />
					<col style="width: 30%;" />
					<thead>
						<tr>
							<th scope="col">Scope Item</th>
							<th scope="col">CO2-e</th>
						</tr>
					</thead>
			
				<!-- //Now loop through all of the metrics in the current merticGroup -->
					<tbody>
						<xsl:for-each select="clientMetric[@ghg_calculation != 'ignore']">
							<tr>
								<td>
							
								<!-- //We need to get the corect metric label and in Weight x Distance case we need to change the label text -->
									<xsl:choose>
										<xsl:when test="@metric = 'Road Freight Weight'">
											<xsl:text>Road Freight</xsl:text>
										</xsl:when>
										<xsl:when test="@metric = 'Rail Freight Weight'">
											<xsl:text>Rail Freight</xsl:text>
										</xsl:when>
										<xsl:when test="@metric = 'Sea Freight Weight'">
											<xsl:text>Sea Freight</xsl:text>
										</xsl:when>
										<xsl:when test="@metric = 'Air Freight Weight'">
											<xsl:text>Air Freight</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="@metric" />
										</xsl:otherwise>
									</xsl:choose>
								</td>
								<td align="right">
									<xsl:value-of select="format-number(((@ghg_calculation*12)), '###,##0.000')" />
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				
					<!--// Provide the total for the current scope -->
					<tfoot>
						<td align="right">Total</td>
						<td align="right">
							<xsl:value-of select="format-number(((sum(clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation)*12)), '###,##0.000')" />
						</td>
					</tfoot>
				</table>
			</xsl:if>
		</xsl:for-each>
		
		<!-- //Provide the total for all scopes -->
		<h4 class="report-output"><span style="float:left;">
			Annualised GHG Emissions for Reported Month (Tonnes CO2-e)
		</span>
		
		<span style="float:right; padding-right:8px;">
			<xsl:value-of select="format-number(((sum(/config/plugin[@plugin = 'checklist'][@method = 'report']/report/metricGroup/clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation)*12)), '###,##0.000')" />
		</span></h4>
		
	</xsl:template>
	
	<!-- //Compare the current result of GHG with the average -->
	<xsl:template match="averageGHGResult" mode="html">
		<xsl:variable name="averageResult" select="0.0129" />
		<xsl:variable name="floorSpace" select="/config/plugin[@plugin = 'checklist'][@method = 'report']/report/questionAnswer/answer[@answer_id = '23373' or @answer_id = '18869']/@arbitrary_value" />
		<xsl:variable name="ghgResult" select="format-number(((sum(/config/plugin[@plugin = 'checklist'][@method = 'report']/report/metricGroup/clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation)*12)), '###,##0.000')" />
		<xsl:variable name="ghgFloorSpaceResult" select="$ghgResult div $floorSpace" />
		
		<div class="averageResults ghgCalculator">
			<xsl:choose>
				<xsl:when test="$averageResult &gt; $ghgFloorSpaceResult">
					<p class="average-rate">Your result is below average.</p>
				</xsl:when>
				<xsl:otherwise>
					<p class="average-rate">Your result is above average.</p>
				</xsl:otherwise>
			</xsl:choose>
			
			<p>The average result is <xsl:value-of select="format-number($averageResult,'###,##0.000')" /> Tonnes CO2-e per square metre of floor space. Your result is <xsl:value-of select="format-number($ghgFloorSpaceResult, '###,##0.000')" /> Tonnes CO2-e per square metre of floor space.</p>
			
		</div>
		
	</xsl:template>
	
	
	<!-- //End of the GHG Protocol Scope Questions -->
	
	<xsl:template match="confirmations" mode="html">
		<ul>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/confirmation">
				<li><xsl:value-of select="@confirmation" disable-output-escaping="yes" /></li>
			</xsl:for-each>
		</ul>
	</xsl:template>
	
	<xsl:template match="questionAnswers" mode="html">
		<table class="audit_table">
			<thead>
				<tr>
					<th scope="col">Question</th>
					<th scope="col">Your Answer</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/questionAnswer">
					<tr>
						<td class="question"><xsl:value-of select="@question" disable-output-escaping="yes" /></td>
						<td class="answer">
							<xsl:for-each select="answer">
								<xsl:choose>
									<xsl:when test="@answer_type = 'checkbox'"><xsl:value-of select="@answer_string" disable-output-escaping="yes" /></xsl:when>
									<xsl:when test="@answer_type = 'percent'"><xsl:value-of select="@arbitrary_value" />%</xsl:when>
									<xsl:when test="@answer_type = 'text' or @answer_type = 'textarea'">
										<xsl:if test="@answer_string != ''">
											<xsl:value-of select="concat(@answer_string, ': ')" />
										</xsl:if>
										<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
									</xsl:when>
									<xsl:when test="@answer_type = 'checkbox-other'">Other: <xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:when>
									<xsl:when test="@answer_type = 'date-quarter'">Quarter ending <xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:when>
									<xsl:when test="@answer_type = 'float'">
										<xsl:if test="@answer_string != ''">
											<xsl:value-of select="concat(@answer_string, ': ')" />
										</xsl:if>
										<xsl:value-of select='format-number(@arbitrary_value, "###,###,##0.00")' />
									</xsl:when>
									<xsl:when test="@answer_type = 'file-upload'">
										<a href="/download/?hash={@arbitrary_value}"><xsl:value-of select="@arbitrary_value" /></a>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
									</xsl:otherwise>
								</xsl:choose>
								<br />
							</xsl:for-each>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="metricsList" mode="html">
		<div class="checklist-metrics">
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/metricGroup">
				<xsl:sort select="@sequence" />
				<xsl:variable name="metricGroup" select="."/>
				<h4 class="report-output"><xsl:value-of select="@name" /></h4>
				<table class="audit_table">
					<thead>
						<tr>
							<th scope="col">Metric</th>
							<th scope="col">Value</th>
							<th scope="col">Description</th>
							<th scope="col">Duration</th>
						</tr>
					</thead>
					<xsl:for-each select="$metricGroup/clientMetric">
						<tr>
							<td><xsl:value-of select="@metric" /></td>
							<td><xsl:value-of select="@value" /></td>
							<td><xsl:value-of select="@description" /></td>
							<td><xsl:value-of select="@months" /> months</td>
						</tr>
					</xsl:for-each>
				</table><br /><br />
			</xsl:for-each>
		</div>

	</xsl:template>
	
	<xsl:template match="keyActions" mode="html">
	</xsl:template>
	
	<!-- //Assigned Actions -->
	<xsl:template name="assignedActions">
		<h2>Assigned Actions</h2>
		<xsl:choose>
			<xsl:when test="count(/config/plugin[@plugin = 'checklist']/report/owner2Action) > 0">
			<p>Below are a list of actions that have been assigned for completion.</p>
				<!-- //Setup the table header -->
				<table id="highPriorityActions">
					<tr>
						<th><strong>Action</strong></th>
						<th><strong>Owner</strong></th>
						<th width="80px"><strong>Due Date</strong></th>
					</tr>
			
					<!-- //get the actions that are ranked as high, then sort descending by demerits -->
					<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/action[@commitment_id = '0']">
						<xsl:sort select="@demerits" />
						
						<xsl:if test="count(/config/plugin[@plugin = 'checklist']/report/owner2Action[@action_id = current()/@action_id]) > 0">
						
							<xsl:variable name="actionOwnerId" select="/config/plugin[@plugin = 'checklist']/report/owner2Action[@action_id = current()/@action_id]/@owner_id" />
							<xsl:variable name="actionOwner" select="/config/plugin[@plugin = 'checklist']/report/actionOwner[@action_owner_id = $actionOwnerId]" />
							<xsl:variable name="dueDate" select="/config/plugin[@plugin = 'checklist']/report/owner2Action[@action_id = current()/@action_id]/@due_date" />
							
							<!--//Now render the actions to complete -->
							<tr>
								<td>
									<a href="#action-{@action_id}-head">
										<xsl:value-of select="@summary" />
									</a>
								</td>
								<td>
									<!-- //First Name -->
									<xsl:if test="$actionOwner/@first_name != ''">
										<xsl:value-of select="$actionOwner/@first_name" /><xsl:text> </xsl:text>
									</xsl:if>
									<!-- //Last Name -->
									<xsl:if test="$actionOwner/@last_name != ''">
										<xsl:value-of select="$actionOwner/@last_name" /><xsl:text> </xsl:text>
									</xsl:if>
									<!-- //Last Name -->
									<xsl:if test="$actionOwner/@email != ''">
										<xsl:text>[</xsl:text>
											<a href="mailto:{$actionOwner/@email}">
												<xsl:value-of select="$actionOwner/@email" />
											</a>
										<xsl:text>]</xsl:text>
									</xsl:if>
								</td>
								<td>
									<xsl:choose>
										<xsl:when test="substring($dueDate,1,10) != '0000-00-00'">
											<xsl:value-of select="substring($dueDate,1,10)" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>N/A</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>
						
						</xsl:if>
					</xsl:for-each>
				</table>
			</xsl:when>
			<xsl:otherwise>
				<p>There are no actions that have been assigned for completion.</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="groupedReportUrl" mode="html">
		
		<xsl:variable name="urlText">
			<xsl:value-of select="@urlText" />
		</xsl:variable>
		
		<xsl:variable name="checklistId">
			<xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@checklist_id" />
		</xsl:variable>
		
		<a href="/members/grouped-report-pdf/{$checklistId}?report_type=full">
			<xsl:value-of select="$urlText" />
		</a>
		
	</xsl:template>
	
	<xsl:template match="reportUrl" mode="html">
		
		<xsl:variable name="urlText">
			<xsl:value-of select="@urlText" />
		</xsl:variable>
		
		<xsl:variable name="checklistId">
			<xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@client_checklist_id" />
		</xsl:variable>
		
		<a href="/members/report-pdf/{$checklistId}?report_type=full">
			<xsl:value-of select="$urlText" />
		</a>
		
	</xsl:template>
	
	<!-- //Parent Grouped Url -->
	<xsl:template match="parentGroupedReportUrl" mode="html">
		
		<xsl:variable name="urlText">
			<xsl:value-of select="@urlText" />
		</xsl:variable>
		
		<xsl:variable name="imageUrl">
			<xsl:value-of select="@imageUrl" />
		</xsl:variable>
		
		<xsl:variable name="checklistId">
			<xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@checklist_id" />
		</xsl:variable>
		
		<xsl:variable name="parent_checklist_id">
			<xsl:choose>
				<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@is_parent = '1'">
					<xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@client_checklist_id" />
				</xsl:when>
				<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@parent_checklist_id = '' and /config/plugin[@plugin = 'checklist']/report/@is_parent = ''">
					<xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@client_checklist_id" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@parent_checklist_id" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<a href="/members/grouped-report-pdf/{$checklistId}?client_checklist_id={$parent_checklist_id}&amp;group_type=parent_grouped&amp;report_type=full">
			<xsl:choose>
				<xsl:when test="$imageUrl != ''">
					<img src="{$imageUrl}" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$urlText" />
				</xsl:otherwise>
			</xsl:choose>
		</a>
		
	</xsl:template>
	
		<!-- //Parent Grouped Url -->
	<xsl:template match="updateResultsLink" mode="html">

		<xsl:variable name="urlText">
			<xsl:value-of select="@urlText" />
		</xsl:variable>
		
		<xsl:variable name="page_id">
			<xsl:value-of select="@page_id" />
		</xsl:variable>

		<xsl:variable name="checklistId">
			<xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@checklist_id" />
		</xsl:variable>
		
		<xsl:variable name="parent_checklist_id">
			<xsl:choose>
				<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@is_parent = '1'">
					<xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@client_checklist_id" />
				</xsl:when>
				<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@parent_checklist_id = '' and /config/plugin[@plugin = 'checklist']/report/@is_parent = ''">
					<xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@client_checklist_id" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@parent_checklist_id" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="url">
			<xsl:choose>
				<xsl:when test="$page_id != ''">
					<xsl:value-of select="concat('/members/?checklist_id=',$checklistId,'&amp;client_checklist_id=',$parent_checklist_id,'&amp;action=create_child_checklist','&amp;page_id=',$page_id)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$url" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<a href="{$url}">
			<button type="button"><xsl:value-of select="$urlText" /></button>
		</a>
		
	</xsl:template>
	
	<xsl:template match="report-instructions" mode="html">
		<div class="report-instructions">
		<ul> 
		<li> <img src="/_images/tick2.gif" /> <strong>Light green check</strong>: confirmation of actions already in place.</li>
		<li> <img src="/_images/tick.gif" /> <strong>Dark green bolded check</strong>: depicts actions that your organisation has implemented since its assessment and which have affected your overall scores.</li>
		<li><strong><span class="blue-action-link">Blue, underscored actions</span></strong> are the suggested remedial actions without a check.</li>
		</ul>

		<p>Click on any <strong><span class="blue-action-link">blue action item</span></strong> and a drop-down window will appear with a suggested action and your commitment options. Once you have implemented an action the system automatically updates your score and adds a <img src="/_images/tick.gif" />  check to the action. You can also nominate someone in your organisation to complete the action within a specific timeframe.</p>
		</div>
	</xsl:template>
	
	<!-- //Download Report Button Link -->
	<xsl:template match="downloadReportButton" mode="html">
		<a href="/members/report-pdf/{/config/plugin[@plugin = 'checklist']/report/@client_checklist_id}?report_type=full" class="download-report-button button-link">
			<button type="button">Download Report</button>
		</a>
	</xsl:template>
	
	<!-- //Download Report Link with Merge File -->
	<xsl:template match="downloadReportButtonMerge" mode="html">
	
		<xsl:variable name="mergeFile">
			<xsl:value-of select="@mergeFile" />
		</xsl:variable>
		
		<a href="/members/report-pdf/{/config/plugin[@plugin = 'checklist']/report/@client_checklist_id}?report_type=full&amp;mergefile={$mergeFile}" class="download-report-button button-link">
			<button type="button">Download Report</button>
		</a>
	</xsl:template>
	
	<!-- //arrow based category scores -->
	<xsl:template match="categoryScoresArrowTable" mode="html">
	  <style><![CDATA[
	    #scoreTable2 {
        width: 690px; 
	      margin-top: 20px;
	      margin-bottom: 15px;
	      border:10px solid rgb(221, 221, 221);
	      background-color: rgb(221, 221, 221);
	      margin:0 auto;
	    }
	    
  	  #scoreTable2 th { 
  	    font-weight: normal; 
  	  }
  	  
  	  #scoreTable2 .score-title { 
  	    width: 180px; 
  	    padding-left:10px;
  	    text-align: left;
  	  }
  	  
  	  #scoreTable2 th.score-head {
  	    width: 70px;
  	    text-align: center;
  	    padding-top: 10px;
  	  }
  	  
  	  #scoreTable2 th.arrow-head {
  	    width: 20px;
  	  }
  	  
  	  #scoreTable2 .score-arrow {
  	    height: 45px;
  	    
  	  }
  	  
  	  #scoreTable2 .arrow {
  	    background: url(/_images/indicator_arrow.png) no-repeat;
  	  	background-size:100%;
  	  }
  	  
  	  #scoreTable2 .arrow-indicator {
  	    position: relative;
  	    width: 21px;
  	    height: 29px;
  	    background: url(/_images/arrow.png) no-repeat;
  	    top:1px;
  	  }
  	  
  	  #scoreTable2 th.score-title {
  	  	font-weight:bold;
  	  }
  	]]></style>
  	
	  <table id="scoreTable2">
	    <thead>
				<th class="score-title">&#160;</th>
				<th scope="col" class="score-head right-border">Poor</th>
				<th scope="col" class="score-head right-border">Fair</th>
				<th scope="col" class="score-head right-border">Good</th>
				<th scope="col" class="score-head right-border">Very Good</th>
				<th scope="col" class="score-head">Excellent</th>
				<th scope="col" class="arrow-head">&#160;</th>
			</thead>
			<tbody valign="center">
			
				<!-- //For each report section -->
			  <xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/reportSection[@points &gt; 0]">
					<xsl:variable name="points" select="@points" />
					<xsl:variable name="demerits" select="@demerits" />
					<xsl:variable name="merits" select="@merits" />
					<xsl:variable name="rate">
					  <xsl:choose>
					    <xsl:when test="((@points - @demerits + @merits) div @points) * 100 &lt; 0">0</xsl:when>
					    <xsl:when test="((@points - @demerits + @merits) div @points) * 100 &gt; 100">100</xsl:when>
					    <xsl:otherwise><xsl:value-of select="((@points - @demerits + @merits) div @points) * 100" /></xsl:otherwise>
					  </xsl:choose>
					</xsl:variable>
					<xsl:if test="$points > 0">
					  <tr>
					    <th scope="row" class="score-title"><xsl:value-of select="@title" /></th>
					    <td colspan="6" class="score-arrow">
					      <div class="arrow">
					        <div class="arrow-indicator" style="left: {(round(($rate div 100) * 440))-10}px;">&#160;</div>
					      </div>
					    </td>
					  </tr>
				  </xsl:if>
				</xsl:for-each>
				
				<!-- //For the overall score -->
			<xsl:variable name="overall_rate" select="/config/plugin[@plugin = 'checklist']/report/@current_score" />
			  <tr>
			    <th scope="row" class="score-title">Overall Result</th>
			    <td colspan="6" class="score-arrow">
			      <div class="arrow">
			        <div class="arrow-indicator" style="left: {(round(($overall_rate div 100) * 440))-10}px;">&#160;</div>
			      </div>
			    </td>
			  </tr>
				
			</tbody>
	  </table>
	</xsl:template>
	
	<!-- //arrow based category scores, 5 Col default  -->
	<xsl:template match="categoryScoresArrow" mode="html">
		<xsl:variable name="cols">
			<xsl:choose>
				<xsl:when test="@cols"><xsl:value-of select="@cols" /></xsl:when>
				<xsl:otherwise>5</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
  	
		<div class="catScoresArrow">
			<div class="cat-row">
				<div class="label-col">
				</div>
				<div class="score-col">
					<div class="score-label col-count-{$cols}">Poor</div>
					<div class="score-label col-count-{$cols}">Fair</div>
					<div class="score-label col-count-{$cols}">Good</div>
					<xsl:if test="$cols = '5'">
						<div class="score-label col-count-{$cols}">Very Good</div>
					</xsl:if>
					<div class="score-label col-count-{$cols}">Excellent</div>
				</div>
			</div>
		
			<!-- //For each category -->
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/reportSection[@points &gt; 0]">
				<xsl:variable name="points" select="@points" />
				<xsl:variable name="demerits" select="@demerits" />
				<xsl:variable name="merits" select="@merits" />
				<xsl:variable name="rate">
				  <xsl:choose>
					<xsl:when test="((@points - @demerits + @merits) div @points) * 100 &lt; 0">0</xsl:when>
					<xsl:when test="((@points - @demerits + @merits) div @points) * 100 &gt; 100">100</xsl:when>
					<xsl:otherwise><xsl:value-of select="((@points - @demerits + @merits) div @points) * 100" /></xsl:otherwise>
				  </xsl:choose>
				</xsl:variable>
				<div class="cat-row">
					<div class="label-col">
						<xsl:value-of select="@title" />
					</div>
					<div class="score-col">
						<div class="arrow">
							<div class="arrow-indicator" style="left: {round($rate) - 2.5}%;">&#160;</div>
						</div>
					</div>
				</div>
			</xsl:for-each>
		
			<!-- //For the overall score -->
			<xsl:variable name="overall_rate" select="/config/plugin[@plugin = 'checklist']/report/@current_score" />
			<div class="cat-row">
				<div class="label-col">
					Overall Result
				</div>
				<div class="score-col">
					<div class="arrow">
						<div class="arrow-indicator" style="left: {round($overall_rate) - 2.5}%;">&#160;</div>
					</div>
				</div>
			</div>

		</div>
	</xsl:template>
		
		
		
		
		
	<!-- //Report v2 Components -->
	<!--//
	//
	//
	// -->

	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'loadEntry'][@mode='report']">
		<xsl:choose>
			<xsl:when test="report/@status = 'Locked'">
				<xsl:call-template name="locked" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="report" mode="entry">
					<xsl:with-param name="type" select="'loadEntry'" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- //Template for report-v2 -->	
	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'reportv2']">
		<xsl:call-template name="report" mode="entry">
			<xsl:with-param name="type" select="'reportv2'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="report" mode="entry">
		<xsl:param name="type" />

		<xsl:if test="$type = 'loadEntry'">
			<xsl:call-template name="report-control-buttons" />
		</xsl:if>

		<div class="reportContainer">
			
			<div class="report-section-control-buttons">
				<a href="#" class="openall" title="Open all report sections">
					<i class="fa fa-plus-square"></i>
				</a>
				<xsl:text> </xsl:text>
				<a href="#" class="closeall" title="Close all report sections">
					<i class="fa fa-minus-square"></i>
				</a>
			</div>
			
			<!-- //Set the Form for post back -->
			<form method="post" action="" id="reportForm" class="checklist-id-{/config/plugin[@plugin = 'checklist'][@method = 'report']/report/@checklist_id}">
				<!--<input type="hidden" id="linkAfter" name="linkAfter" value="" />-->
				<input type="hidden" name="action" value="reEvaluateReport" id="action" />
				<!--<input type="hidden" name="current_action_id" id="current_action_id" />-->

				<input type="hidden" name="linkafter" id="linkafter" value="" />
				<input type="hidden" name="current-action-id" id="current-action-id" value="" />
				<xsl:if test="/config/globals/item[@key='linkafter']">
					<div data-scroll-to="{/config/globals/item[@key='linkafter']/@value}" />
				</xsl:if>

				<!-- Added filter to stop rendering of empty report sections -->
				<xsl:choose>
					<xsl:when test="count(report/clientSite) &gt; 0">

						<!-- //Multi Site Content -->
						<xsl:for-each select="report/reportSection[@display_in_html = '1' and @multi_site = '1']">

							<!-- //Render the content -->
							<xsl:apply-templates select="content/*" mode="html" />	

						</xsl:for-each>

					</xsl:when>
					<xsl:otherwise>

						<!-- //For each report section -->
						<div class="panel-group" id="reportSectionAccordion">
							<xsl:for-each select="report/reportSection[@display_in_html = '1' and @multi_site = '0']">
								<div class="panel panel-default" id="report-section-{@report_section_id}">
									
									<!-- //Report Section Title -->
									<div class="panel-heading bullet report-section-title">
										<h4 class="panel-title">
											<a id="section-{position()}"></a>
											<a class="report-section-title-link" data-toggle="collapse" data-parent="#reportSectionAccordion" href="#collapse-report-section-{position()}">
												<figure class="base">
													<span class="section-number">
														<xsl:value-of select="position()" />
													</span>
												</figure>
												<span class="section-number-separator">.</span>
												<span class="title report-section-title"><xsl:value-of select="@title" /></span>
											</a>
										</h4>
									</div>
									
									<!-- //Report Section Body -->
									<div id="collapse-report-section-{position()}" class="panel-collapse collapse in">
										<div class="panel-body">
											<div class="row">
												<div class="col-md-12">
													<!-- //Report section Content -->
													<xsl:apply-templates select="content/*" mode="html" />
													
													<xsl:choose>
														<xsl:when test="@output = 'confirmations-negative'">
															<xsl:call-template name="confirmations-negative" output="single" />
														</xsl:when>
														<xsl:when test="@output = 'twe-action-plan'">
															<xsl:call-template name="twe-action-plan">
																<xsl:with-param name="reportSectionPosition" select="position()" />
															</xsl:call-template>
														</xsl:when>
														<xsl:otherwise>
															<xsl:call-template name="actions" output="standard" />
														</xsl:otherwise>
													</xsl:choose>
												</div>
											</div>
										</div>
									</div>
									
								</div>
							</xsl:for-each>
						</div>
					</xsl:otherwise>
				</xsl:choose>
				
			</form>
        </div>

		<!--
		<script type="text/javascript">
			<xsl:if test="/config/globals/item[@key='linkAfter']/@value != ''">
			  setTimeout(function(){
				$("html,body").animate({scrollTop: $("#<xsl:value-of select="/config/globals/item[@key='linkAfter']/@value" />").offset().top}, 500);  
			  },200);
			</xsl:if>
        </script>
		-->
        
        <!-- //hidden modal loader -->
		<!--
        <div class="reportLoaderModal">
        	<div class="modal-text">
        		<p>Now generating your report, please wait a moment.</p>
        		<p>Your download will begin shortly.</p>
        	</div>
        </div>
		<script type='text/javascript'>
			$('.download-report-button').click(function() {
				$(document.body).addClass('loading');
				setTimeout(function() {
					$(document.body).removeClass('loading');
				},5000);
			});
		</script>
		-->
		
		<!-- //Allow show/hide all on the accordion -->
		<!--
		<script type='text/javascript'>
			$('.closeall').click(function(){
			  $('.panel-collapse.in')
				.collapse('hide');
			});
			$('.openall').click(function(){
			  $('.panel-collapse:not(".in")')
				.collapse('show');
			});
		</script>
		-->

	</xsl:template>

	<xsl:template name="confirmations-negative" output="single">
	
		<div class="row-fluid confirmations-negative">
			<div class="col-md-12 wp-block no-space light">
				<div class="wp-block-body">
					<div class="img-icon">
						<i class="fa fa-times-circle" aria-hidden="true"></i>
					</div>
					<h1>What you are doing</h1>
					<xsl:choose>
						<xsl:when test="count(../confirmation[@report_section_id = current()/@report_section_id]) > 0">
							<xsl:call-template name="report-section-confirmations">
								<xsl:with-param name="reportSectionId" select="@report_section_id" />
								<xsl:with-param name="output" select="@output" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</div>

	</xsl:template>


	<xsl:template name="actions" output="standard">

		<xsl:if test="count(../action[@report_section_id = current()/@report_section_id]) > 0 or count(../confirmation[@report_section_id = current()/@report_section_id]) > 0">
			<!-- Category Scores -->
			<div class="row report-section-score-title">

				<!-- //Description -->
				<div class="col-md-6">
					<h6>Initial Score</h6>
				</div>

				<!-- //Progress Bar -->
				<div class="col-md-6">
					<h6>Current Score</h6>
				</div>

			</div>
			<div class="row report-section-score">

				<!-- //Description -->
				<div class="col-md-6">
					<xsl:call-template name="category-score-initial-rate">
						<xsl:with-param name="reportSectionId" select="@report_section_id" />
					</xsl:call-template>
				</div>

				<!-- //Progress Bar -->
				<div class="col-md-6">
					<xsl:call-template name="category-score-current-rate">
						<xsl:with-param name="reportSectionId" select="@report_section_id" />
					</xsl:call-template>
				</div>
			</div>
		
			<!-- // Actions, Confirmations and Commitments -->
			<!-- Category Scores -->
			
			<div class="row-fluid actions-confirmations-commitments-container">
			
				<!-- //Actions -->
				<div class="col-md-6 wp-block no-space arrow-right base no-margin current-actions-container">
					<div class="wp-block-body">
						<div class="img-icon">
							<span class="glyphicon glyphicon-question-sign actions-icon" aria-hidden="true"></span>
						</div>
						<h1>What you can do</h1>					
						<xsl:call-template name="report-section-actions">
							<xsl:with-param name="reportSectionId" select="@report_section_id" />
						</xsl:call-template>			
					</div>
				</div>
				
				<!-- //Confirmations and Commitments -->
				<div class="col-md-6 wp-block no-space light current-commitments-container">
					<div class="wp-block-body">
						<div class="img-icon">
							<span class="glyphicon glyphicon-ok-sign confirmations-icon" aria-hidden="true"></span>
						</div>
						<h1>What you are doing</h1>
						<xsl:call-template name="report-section-confirmations">
							<xsl:with-param name="reportSectionId" select="@report_section_id" />
						</xsl:call-template>
						<xsl:call-template name="report-section-commitments">
							<xsl:with-param name="reportSectionId" select="@report_section_id" />
						</xsl:call-template>
					</div>
				</div>
			</div>
		</xsl:if>

	</xsl:template>

	<xsl:template name="report-control-buttons">

		<div class="row">
			<div class="col-md-12">
				<div class="row">

					<!--// Back to report -->
					<xsl:if test="/config/plugin[@plugin = 'checklist']/report/@status_code = '1'">
						<div class="col-md-3 entry-header-button">
							<a href="/members/entry/{/config/plugin[@plugin = 'checklist']/report/@client_checklist_id}/" class="btn btn-base btn-icon fa-reply col-md-12" data-action="back-to-entry">
								<span>Back to Entry</span>
							</a>
						</div>
					</xsl:if>

					<!--// PDF Report -->
					<xsl:if test="/config/plugin[@plugin = 'checklist']/report/@downloadable_reports = '1'">
						<div class="col-md-3 entry-header-button">
							<a href="/members/entry/report-pdf/{/config/plugin[@plugin = 'checklist']/report/@client_checklist_id}/" class="btn btn-base btn-icon fa-file-pdf-o col-md-12" data-action="pdf-download">
								<span>Download PDF</span>
							</a>
						</div>
					</xsl:if>

					<!--// CSV Export -->
					<xsl:if test="/config/plugin[@plugin = 'checklist']/report/@downloadable_reports = '1'">
						<div class="col-md-3 entry-header-button">
							<a href="/members/entry/export/{/config/plugin[@plugin = 'checklist']/report/@client_checklist_id}/" class="btn btn-base btn-icon fa-file-excel-o col-md-12" data-action="excel-download">
								<span>Download CSV</span>
							</a>
						</div>
					</xsl:if>

					<!--// Export Actions -->
					
					<xsl:if test="/config/plugin[@plugin = 'checklist']/report/@exportable_actions = '1'">
						<div class="col-md-3 entry-header-button">
							<a href="/members/entry/export-actions/{/config/plugin[@plugin = 'checklist']/report/@client_checklist_id}/" class="btn btn-base btn-icon fa-file-excel-o col-md-12">
								<span>Export Actions</span>
							</a>
						</div>
					</xsl:if>

					<!--// Export Actions -->
					<!--
					<xsl:if test="/config/plugin[@plugin = 'checklist']/report/@audit = '1'">
						<div class="col-md-3 entry-header-button">
							<a href="/members/entry/audit/{/config/plugin[@plugin = 'checklist']/report/@client_checklist_id}/" class="btn btn-base btn-icon fa-balance-scale col-md-12">
								<span>Audit</span>
							</a>
						</div>
					</xsl:if>
					-->

					<!--// Export Actions -->
					<!--
					<xsl:if test="/config/plugin[@plugin = 'checklist']/report/@audit = '1'">
						<div class="col-md-3 entry-header-button">
							<a href="/members/entry/media/{/config/plugin[@plugin = 'checklist']/report/@client_checklist_id}/" class="btn btn-base btn-icon fa-file-image-o col-md-12">
								<span>Certification Media</span>
							</a>
						</div>
					</xsl:if>
					-->

				</div>

			</div>
		</div>

	</xsl:template>

	<!-- //Overall Score Targets -->
	<xsl:template name="overall-score-targets">
		<div class="progress report-progress-bar">

			<!-- //Check for certificationLevels first -->
			<xsl:choose>
		 		<xsl:when test="count(/config/plugin[@plugin = 'checklist']/report/certificationLevel) &gt; 0">
		 			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/certificationLevel">
		 				<xsl:sort select="@target" />
		 				<xsl:variable name="upper-bound">
		 					<xsl:choose>
		 						<xsl:when test="following-sibling::*[1][self::certificationLevel]/@target">
		 							<xsl:value-of select="following-sibling::*[1][self::certificationLevel]/@target" />
		 						</xsl:when>
		 						<xsl:otherwise>100</xsl:otherwise>
		 					</xsl:choose>	
		 				</xsl:variable>

		 				<div class="progress-bar certification-level-progress-bar progress-bar-{@certification_level_id} progress-bar-striped" style="width: {($upper-bound - @target)}%; background-color:#{@color};">
							<xsl:value-of select="@target" />%
							<xsl:text> </xsl:text>
							<xsl:value-of select="@name" />
						</div>
		 			</xsl:for-each>
		 		</xsl:when>
		 		<xsl:otherwise>
		 			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/genericCertificationLevel">
		 				<xsl:sort select="@target" />
		 				<xsl:variable name="upper-bound">
		 					<xsl:choose>
		 						<xsl:when test="following-sibling::*[1][self::genericCertificationLevel]/@target">
		 							<xsl:value-of select="following-sibling::*[1][self::genericCertificationLevel]/@target" />
		 						</xsl:when>
		 						<xsl:otherwise>100</xsl:otherwise>
		 					</xsl:choose>	
		 				</xsl:variable>
		 				
		 				<div class="progress-bar certification-level-progress-bar progress-bar-{@level_id} progress-bar-striped" style="width: {($upper-bound - @target)}%; background-color:#{@color};">
							<span class="sr-only">
								<xsl:value-of select="@target" />%
								<xsl:text> </xsl:text>
								<xsl:value-of select="@name" />
							</span>
						</div>
		 			</xsl:for-each>
		 		</xsl:otherwise>
			</xsl:choose>

		</div>

	</xsl:template>
	
	<!-- //HTML match on template -->
	<xsl:template match="overall-score-targets" mode="html">
		<xsl:call-template name="overall-score-targets" />
	</xsl:template>
	
	<!-- //Overall Score Initial Rate -->
	<xsl:template name="overall-score-initial-rate">
		<xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id != '']/@points)" />
		<xsl:variable name="demerits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id != '']/@demerits)" />
		<xsl:variable name="merits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id != '']/@merits)" />
		<xsl:variable name="initial_rate" select="($points - $demerits) div $points" />
			
		<div class="progress report-progress-bar">
		  <div class="progress-bar progress-bar-striped initial-score" role="progressbar" aria-valuenow="{$initial_rate * 100}" aria-valuemin="0" aria-valuemax="100" style="min-width: 2em; width:{floor($initial_rate * 100)}%">
			<xsl:value-of select="floor($initial_rate * 100)" />%
		  </div>
		</div>

	</xsl:template>
	
	<!-- //HTML match on template -->
	<xsl:template match="overall-score-initial-rate" mode="html">
		<xsl:call-template name="overall-score-initial-rate" />
	</xsl:template>
	
	<!-- //Overall Score Current Rate -->
	<xsl:template name="overall-score-current-rate">
		<xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id != '']/@points)" />
		<xsl:variable name="demerits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id != '']/@demerits)" />
		<xsl:variable name="merits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id != '']/@merits)" />
		<xsl:variable name="current_rate">
			<xsl:choose>
				<xsl:when test="$points &gt; 0">
					<xsl:value-of select="($points - $demerits + $merits) div $points" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
			
		<div class="progress report-progress-bar">
		  <div class="progress-bar progress-bar-striped current-score" role="progressbar" aria-valuenow="{floor($current_rate * 100)}" aria-valuemin="0" aria-valuemax="100" style="min-width: 2em; width:{floor($current_rate * 100)}%">
			<xsl:value-of select="floor($current_rate * 100)" />%
		  </div>
		</div>

	</xsl:template>
	
	<!-- //HTML match on template -->
	<xsl:template match="overall-score-current-rate" mode="html">
		<xsl:call-template name="overall-score-current-rate" />
	</xsl:template>
	
	<!-- //Category Score Initial Rate -->
	<xsl:template name="category-score-initial-rate">
		<xsl:param name="reportSectionId" />
		<xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id = $reportSectionId]/@points)" />
		<xsl:variable name="demerits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id = $reportSectionId]/@demerits)" />
		<xsl:variable name="merits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id = $reportSectionId]/@merits)" />
		<xsl:variable name="initial_rate">
			<xsl:choose>
				<xsl:when test="$points &gt; 0">
					<xsl:value-of select="($points - $demerits) div $points" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
			
		<div class="progress report-progress-bar">
		  <div class="progress-bar progress-bar-striped initial-score" role="progressbar" aria-valuenow="{floor($initial_rate * 100)}" aria-valuemin="0" aria-valuemax="100" style="min-width: 2em; width:{floor($initial_rate * 100)}%">
			<xsl:value-of select="floor($initial_rate * 100)" />%
		  </div>
		</div>

	</xsl:template>
	
	<!-- //HTML match on template -->
	<xsl:template match="category-score-initial-rate" mode="html">
		<xsl:variable name="reportSectionId">
			<xsl:value-of select="ancestor::reportSection[1]/@report_section_id" />
		</xsl:variable>
	
		<xsl:call-template name="category-score-initial-rate" >
			<xsl:with-param name="reportSectionId" select="$reportSectionId" />
		</xsl:call-template>
	</xsl:template>
		
	<!-- //Category Score Current Rate -->
	<xsl:template name="category-score-current-rate">
		<xsl:param name="reportSectionId" />
		<xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id = $reportSectionId]/@points)" />
		<xsl:variable name="demerits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id = $reportSectionId]/@demerits)" />
		<xsl:variable name="merits" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id = $reportSectionId]/@merits)" />
		<xsl:variable name="current_rate">
			<xsl:choose>
				<xsl:when test="$points &gt; 0">
					<xsl:value-of select="($points - $demerits + $merits) div $points" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
			
		<div class="progress report-progress-bar">
		  <div class="progress-bar progress-bar-striped current-score" role="progressbar" aria-valuenow="{$current_rate * 100}" aria-valuemin="0" aria-valuemax="100" style="min-width: 2em; width:{floor($current_rate * 100)}%">
			<xsl:value-of select="floor($current_rate * 100)" />%
		  </div>
		</div>

	</xsl:template>

	<!-- //Category Scores -->
	<xsl:template match="category-scores" mode="html">

		<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/reportSection[@points &gt; 0][@display_in_html = 1]">
			<div class="row">
				<div class="col-md-4 progress-bar-title">
					<h6>
						<xsl:value-of select="@title" />
					</h6>
				</div>
				<div class="col-md-8">
					<xsl:call-template name="category-score-current-rate" >
						<xsl:with-param name="reportSectionId" select="@report_section_id" />
					</xsl:call-template>
				</div>
			</div>
		</xsl:for-each>

	</xsl:template>
	
	<!-- //HTML match on template -->
	<xsl:template match="category-score-current-rate" mode="html">
		<xsl:variable name="reportSectionId">
			<xsl:value-of select="ancestor::reportSection[1]/@report_section_id" />
		</xsl:variable>
	
		<xsl:call-template name="category-score-current-rate" >
			<xsl:with-param name="reportSectionId" select="$reportSectionId" />
		</xsl:call-template>
	</xsl:template>
	
	<!-- //Generic Overall Score v2 -->
	<xsl:template match="overallScoreGenericv2" mode="html">
		<div class="row">
			<div class="col-md-4 progress-bar-title">
				<h6>Initial Score</h6>
			</div>
			<div class="col-md-8">
				<xsl:call-template name="overall-score-initial-rate" />
			</div>
		</div>
		<div class="row">
			<div class="col-md-4 progress-bar-title">
				<h6>Current Score</h6>
			</div>
			<div class="col-md-8">
				<xsl:call-template name="overall-score-current-rate" />
			</div>
		</div>			
	</xsl:template>

	<!-- //Generic Overall Score v2 -->
	<xsl:template match="certificationLevelsv2" mode="html">
		<div class="row">
			<div class="col-md-4">
				<h6>Targets</h6>
			</div>
			<div class="col-md-8">
				<xsl:call-template name="overall-score-targets" />
			</div>
		</div>
	</xsl:template>

	<!-- //HTML match on template -->
	<xsl:template match="report-section-actions" mode="html">
		<xsl:variable name="reportSectionId">
			<xsl:value-of select="ancestor::reportSection[1]/@report_section_id" />
		</xsl:variable>
	
		<xsl:call-template name="report-section-actions" >
			<xsl:with-param name="reportSectionId" select="$reportSectionId" />
		</xsl:call-template>
	</xsl:template>

	<!-- //Current Report Section Actions -->
	<xsl:template name="report-section-actions">
		<xsl:param name="reportSectionId" />
		<xsl:variable name="pos" select="position()" />
		<xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id = $reportSectionId]/@points)" />
		<xsl:variable name="reportPoints" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id != '']/@points)" />
		
		<xsl:if test="count(/config/plugin[@plugin = 'checklist']/report/action[@report_section_id = $reportSectionId]) &gt; 0">
			<ul class="current-actions">
				<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/action[@report_section_id = $reportSectionId]">

					<!-- //Variable for current commitment -->
					<xsl:variable name="commitment" select="../commitment[@commitment_id = current()/@commitment_id]" />
					<xsl:variable name="merits">
						<xsl:choose>
							<xsl:when test="$commitment">
								<xsl:value-of select="$commitment/@merits" />
							</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>	
					</xsl:variable>

					<xsl:if test="not($commitment) or $commitment/@merits &lt; @demerits">
						<li class="current-action-item" id="action-{@action_id}-head">
							<span class="action-item-label" data-toggle="collapse" data-target="#action-{@action_id}-body" aria-expanded="false">
								<span class="item-list-count">
									<xsl:value-of select="concat($pos,'.',position())" />
								</span>
								<span data-toggle="tooltip" title="Click on this action to reveal more options.">
									<xsl:value-of select="@summary" disable-output-escaping="yes" />
								</span>
								<xsl:if test="@demerits &gt; 0 and /config/plugin[@plugin = 'checklist']/report/@scorable_assessment = '1'">
									<xsl:text> </xsl:text><span class="actionDemeritValue">
									<!--<xsl:value-of select="format-number((@demerits - $merits) div $points,' (#.##%)')" />-->
									<xsl:value-of select="format-number(@demerits div $reportPoints,' (#.##%)')" />
								</span>
								</xsl:if>
							</span>

							<!-- //Check for action proposed measure content -->
							<xsl:if test="./*">
								<div id="action-{@action_id}-body" class="proposed-action-container collapse">
									<xsl:call-template name="proposed-measure">
										<xsl:with-param name="action_id" select="@action_id" />
									</xsl:call-template>
								</div>
							</xsl:if>
						</li>
					</xsl:if>
				</xsl:for-each>
			</ul>
		</xsl:if>

		<!-- //If there are no actions to implement, state so -->
		<xsl:if test="/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id = $reportSectionId]/@merits = /config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id = $reportSectionId]/@demerits">
			<p class="text-white">There are no actions to implement.</p>
		</xsl:if>
	
	</xsl:template>
	
	<!-- //HTML match on template -->
	<xsl:template match="report-section-confirmations" mode="html">
		<xsl:param name="report_section_id" />
		<xsl:value-of select="$report_section_id" />

		<xsl:variable name="reportSectionId">
			<xsl:value-of select="ancestor::reportSection[1]/@report_section_id" />
		</xsl:variable>

		<xsl:variable name="output">
			<xsl:value-of select="ancestor::reportSection[1]/@output" />
		</xsl:variable>
	
		<xsl:call-template name="report-section-confirmations" >
			<xsl:with-param name="reportSectionId" select="$reportSectionId" />
			<xsl:with-param name="output" select="$output" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="report-section-confirmations">
		<xsl:param name="reportSectionId" />
		<xsl:param name="output" />

		<xsl:if test="/config/plugin[@plugin = 'checklist']/report/confirmation[@report_section_id = $reportSectionId]">
			<ul class="current-confirmations">
				<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/confirmation[@report_section_id = $reportSectionId]">
					<li>
						<xsl:choose>
							<xsl:when test="$output = 'confirmations-negative'">
								<i class="fa fa-times negative"></i>
							</xsl:when>
							<xsl:otherwise>
								<i class="fa fa-check"></i>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="@confirmation"  disable-output-escaping="yes" />
					</li>
				</xsl:for-each>
			</ul>
		</xsl:if>

	</xsl:template>
	
	<!-- //HTML match on template -->
	<xsl:template match="report-section-commitments" mode="html">
		<xsl:variable name="reportSectionId">
			<xsl:value-of select="ancestor::reportSection[1]/@report_section_id" />
		</xsl:variable>
	
		<xsl:call-template name="report-section-commitments" >
			<xsl:with-param name="reportSectionId" select="$reportSectionId" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="report-section-commitments">
		<xsl:param name="reportSectionId" />
		<xsl:variable name="points" select="sum(/config/plugin[@plugin = 'checklist']/report/reportSection[@report_section_id = $reportSectionId]/@points)" />
		
		<ul class="current-commitments">
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/action[@report_section_id = $reportSectionId][@commitment_id != 0]">
				<li>
					<i class="fa fa-check"></i>
					<xsl:value-of select="../commitment[@commitment_id = current()/@commitment_id]/@commitment"  disable-output-escaping="yes" />
				</li>
			</xsl:for-each>
		</ul>
	
	</xsl:template>

	<!-- //Proposed Measure and Comments Content -->
	<xsl:template name="proposed-measure">
		<xsl:param name="action_id" select="action_id" />
		<xsl:variable name="proposedMeasure" select="/config/plugin[@plugin = 'checklist']/report/action[@action_id = $action_id]/proposed_measure" />
		<xsl:variable name="comments" select="/config/plugin[@plugin = 'checklist']/report/action[@action_id = $action_id]/comments" />
		
		<xsl:if test="./*">
			<div class="action-content-container well">

				<xsl:if test="$proposedMeasure">
					<div class="proposed-measure">
						<h6>Action</h6>
						<div class="proposed-measure-content">		
							<xsl:apply-templates select="$proposedMeasure/*" mode="html" />
						</div>
					</div>
				</xsl:if>

				<xsl:if test="$comments and $comments/* != '' ">
					<div class="facts">
						<h6>Facts</h6>
						<xsl:apply-templates select="$comments/*" mode="html" />
					</div>
				</xsl:if>

				<xsl:if test="count(/config/plugin[@plugin = 'checklist']/report/resource[@action_id = $action_id]) &gt; 0">
					<div class="action-resources">
						<h6>Resources</h6>
						<ul>
							<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/resource[@action_id = $action_id]">
								<xsl:sort select="@sequence" data-type="number" />
								<li>
									<xsl:apply-templates select="../resource_type[@resource_type_id = current()/@resource_type_id]/icon/*" mode="html" />
									<a href="{@url}" target="_blank" class="resource-link">
										<xsl:value-of select="@description" />
									</a>
								</li>
							</xsl:for-each>
						</ul>
					</div>
				</xsl:if>

				<xsl:if test="/config/plugin[@plugin = 'checklist']/report/commitment[@action_id = $action_id]">
					<div class="commitment-options">
						<fieldset class="commitments">
							<h6>Your Commitment Options</h6>
							<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/commitment[@action_id = $action_id]">
								<label>
									<input type="radio" name="commitment[{@action_id}]" value="{@commitment_id}" data-setvalue="true" data-target="#current-action-id" data-value="{@action_id}">
										<xsl:if test="/config/plugin[@plugin = 'checklist']/report/action[@action_id = $action_id]/@commitment_id = current()/@commitment_id">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
									</input>
									<xsl:value-of select="@commitment" disable-output-escaping="yes" />
								</label>
							</xsl:for-each>
							<label>
								<input type="radio" name="commitment[{$action_id}]" value="0" data-setvalue="true" data-target="#current-action-id" data-value="{@action_id}">
									<xsl:if test="/config/plugin[@plugin = 'checklist']/report/action[@action_id = $action_id]/@commitment_id = 0">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>
								<xsl:text>We can not commit to this action.</xsl:text>
							</label>
						</fieldset>
					</div>
				</xsl:if>

				<!-- //Action submit button -->
				<div class="text-center">

					<!-- //Empty fields for assign_action_owner -->
					<input type="hidden" name="action_{$action_id}_owner_id" value="" />
					<input type="hidden" name="action_{$action_id}_due_date" value="" />
					<input type="hidden" name="action_{$action_id}_email" value="" />


					<input type="hidden" name="action_{$action_id}_owner_2_action_id" value="{/config/plugin[@plugin = 'checklist']/report/owner2Action[@action_id = $action_id]/@owner_2_action_id}" />
					<input type="hidden" name="action_{$action_id}_assigned_by" value="{/config/plugin[@plugin = 'clients']/client/@client_contact_id}" />
					<button type="submit" class="btn btn-base btn-icon fa-refresh" data-setvalue="true" data-target="#linkafter" data-value="#report-section-{/config/plugin[@plugin = 'checklist']/report/action[@action_id = $action_id]/@report_section_id}">update</button>
            	</div>

			</div>
		</xsl:if>				
	</xsl:template>

	<xsl:template name="assign-action-table">
                <!-- //Add the ability to assign the action to person -->
                <hr />
                <h3>Assign Action (optional)</h3>
                <p>You can assign this action to a member of your team and email the action details to them for completion.</p>
				<div id="assign_action">
                	<style>
						#ui-datepicker-div { display: none; } 
					</style>
					<script type="text/javascript">
					
						$(function() {
						 
						 	$( "#action-<xsl:value-of select="$action/@action_id" />-due-date" ).datepicker();
							$( "#action-<xsl:value-of select="$action/@action_id" />-due-date" ).datepicker("option","dateFormat","yy-mm-dd");
							
							<xsl:if test="substring(/config/plugin[@plugin = 'checklist']/report/owner2Action[@action_id = $action/@action_id]/@due_date,1,10) != '0000-00-00'">
							var queryDate = '<xsl:value-of select="substring(/config/plugin[@plugin = 'checklist']/report/owner2Action[@action_id = $action/@action_id]/@due_date,1,10)" />';
							var parsedDate = $.datepicker.parseDate('yy-mm-dd', queryDate);
								$( "#action-<xsl:value-of select="$action/@action_id" />-due-date" ).datepicker("setDate", parsedDate);
							</xsl:if>
						});
						
						$(function() {
						    $('#action_owner_id_<xsl:value-of select="$action/@action_id" />_edit').change(function(){
        						if($("#action_owner_id_<xsl:value-of select="$action/@action_id" />_edit").val() == 'edit') {
        							$("#owner-action-<xsl:value-of select="$action/@action_id" />-body").toggle('slow');
        						}
        						else {
									$("#owner-action-<xsl:value-of select="$action/@action_id" />-body").hide('slow');
								}
    						});
						});
						
						$(function() {
						    $('#btnAdd_<xsl:value-of select="$action/@action_id" />').click(function() {
						        $('#blank_row_<xsl:value-of select="$action/@action_id" />').clone().appendTo('#action_owner_edit_table_<xsl:value-of select="$action/@action_id" />');
						    });
						});
						
					</script>
					<table class="assignActionTable">
						<tr>
							<th width="70%">Assign to</th>
							<th>Due Date</th>
						</tr>
						<tr>
							<td width="70%">
								<select name="action_{$action/@action_id}_owner_id" id="action_owner_id_{$action/@action_id}_edit">
									<option value="">-- None --</option>
									<option value="edit">-- Edit Action Owners --</option>
									<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/actionOwner">
										<option value="{@action_owner_id}">
											<xsl:if test="/config/plugin[@plugin = 'checklist']/report/owner2Action[(@owner_id = current()/@action_owner_id) and (@action_id = $action/@action_id)]">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>
											<xsl:if test="@first_name != ''">
												<xsl:value-of select="@first_name" /><xsl:text> </xsl:text>
											</xsl:if>
											<xsl:if test="@last_name != ''">
												<xsl:value-of select="@last_name" /><xsl:text> </xsl:text>
											</xsl:if>
											<xsl:if test="@email != ''">
												<xsl:text>[</xsl:text><xsl:value-of select="@email" /><xsl:text>]</xsl:text>
											</xsl:if>
										</option>
									</xsl:for-each>
								</select>
							</td>
							<td>
								<input type="text" name="action_{$action/@action_id}_due_date" id="action-{$action/@action_id}-due-date" />
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<p><center><img src="/_images/emailIcon.png" style="padding-right:10px;" />
								<input type="hidden" name="action_{$action/@action_id}_email" value="0" />
								<input type="checkbox" name="action_{$action/@action_id}_email" value="1" checked="checked" />
								Email action to team member</center></p>
							</td>
						</tr>
					</table>
				</div>
				<input type="hidden" name="action_{$action/@action_id}_owner_2_action_id" value="{/config/plugin[@plugin = 'checklist']/report/owner2Action[@action_id = $action/@action_id]/@owner_2_action_id}" />
				<input type="hidden" name="action_{$action/@action_id}_assigned_by" value="{/config/plugin[@plugin = 'clients']/client/@client_contact_id}" />
				<div style="text-align: center;padding-top:10px;"><input type="submit" value="Update" onclick="$('#linkAfter').attr('value', 'action-{$action/@action_id}-head'); document.getElementById('current_action_id').value='{$action/@action_id}'; return true;" /></div>
	</xsl:template>

	<xsl:template match="checklist-name" mode="html">
		<xsl:value-of select="/config/plugin[@plugin = 'checklist'][@method = 'reportv2']/report/@checklist" />
	</xsl:template>

	<!-- //Download Report Link -->
	<xsl:template match="download-report-link" mode="html">
		<xsl:variable name="class" select="@class" />
		<xsl:variable name="text" select="@text" />
		<xsl:variable name="link" select="concat('/members/report-pdf/',/config/plugin[@plugin = 'checklist']/report/@client_checklist_id, '/', '?report_type=full')" />

		<!-- //First check to see if the report is multi-site and if the report has a download option -->
		<xsl:if test="count(/config/plugin[@plugin = 'checklist']/report/clientSite) = 0">
			<a href="{$link}" class="{$class}">
	        	<span>
	        		<xsl:value-of select="$text" />
	        	</span>
	        </a>
    	</xsl:if>
	</xsl:template>

	<!-- //Export Actions Link -->
	<xsl:template match="export-actions-link" mode="html">
		<xsl:variable name="class" select="@class" />
		<xsl:variable name="text" select="@text" />
		<xsl:variable name="link" select="concat('/members/report-pdf/',/config/plugin[@plugin = 'checklist']/report/@client_checklist_id, '/', '?action=export-actions')" />

		<!-- //First check to see if the report is multi-site and if the export has a download option -->
		<xsl:if test="count(/config/plugin[@plugin = 'checklist']/report/clientSite) = 0">
			<a href="{$link}" class="{$class}">
	        	<span>
	        		<xsl:value-of select="$text" />
	        	</span>
	        </a>
    	</xsl:if>
	</xsl:template>	


	<!-- //Audit Assessment Link -->
	<xsl:template match="audit-assessment-link" mode="html">
		<xsl:variable name="class" select="@class" />
		<xsl:variable name="text" select="@text" />
		<xsl:variable name="link" select="concat('/members/assessment-audit/',/config/plugin[@plugin = 'checklist']/report/@client_checklist_id,'/')" />

		<!-- //First check to see if the report is multi-site and if the report has an audit option -->
		<xsl:if test="count(/config/plugin[@plugin = 'checklist']/report/clientSite) = 0">
			<a href="{$link}" class="{$class}">
	        	<span>
	        		<xsl:value-of select="$text" />
	        	</span>
	        </a>
    	</xsl:if>
	</xsl:template>

	<!-- //Audit Certification Logo Link -->
	<xsl:template match="certification-logo-link" mode="html">
		<xsl:variable name="class" select="@class" />
		<xsl:variable name="text" select="@text" />
		<xsl:variable name="link" select="concat('/members/certification-logos/',/config/plugin[@plugin = 'checklist']/report/@client_checklist_id, '/', '#certification-logo-',/config/plugin[@plugin = 'checklist']/report/@client_checklist_id)" />

		<!-- //First check to see if the report is multi-site and if the report has an audit option -->
		<xsl:if test="count(/config/plugin[@plugin = 'checklist']/report/clientSite) = 0">
			<a href="{$link}" class="{$class}">
	        	<span>
	        		<xsl:value-of select="$text" />
	        	</span>
	        </a>
    	</xsl:if>
	</xsl:template>	

	<!-- //If there are certification levels to render do so with this dial showing the different colourss -->
	<xsl:template match="clientSiteOverallScoresv2" mode="html">
		<div class="panel-group" id="reportSectionAccordion">
			<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/clientSite">
					
				<div class="panel panel-default" id="report-section-{@client_site_id}">
					
					<!-- //Report Section Title -->
					<div class="panel-heading bullet report-section-title">
						<h4 class="panel-title">
							<a id="section-{position()}"></a>
							<a class="report-section-title-link" data-toggle="collapse" data-parent="#reportSectionAccordion" href="#collapse-report-section-{position()}">
								<figure class="base">
									<span class="section-number">
										<xsl:value-of select="position()" />
									</span>
								</figure>
								<span class="section-number-separator">.</span>
								<span class="title report-section-title"><xsl:value-of select="@site_name" /></span>
							</a>
						</h4>
					</div>
					
					<!-- //Report Section Body -->
					<div id="collapse-report-section-{position()}" class="panel-collapse collapse in">
						<div class="panel-body">
							
							<!-- Initial Score -->
							<div class="row">
								<!-- //Description -->
								<div class="col-md-5">
									<h6>Initial Score</h6>
								</div>
								<!-- //Progress Bar -->
								<div class="col-md-7">
									<xsl:call-template name="overall-score-initial-rate-client-site">
										<xsl:with-param name="client-site-id" select="@client_site_id" />
									</xsl:call-template>
								</div>
							</div>
							<!-- Current Score -->
							<div class="row">
								<!-- //Description -->
								<div class="col-md-5">
									<h6>Current Score</h6>
								</div>
								<!-- //Progress Bar -->
								<div class="col-md-7">
									<xsl:call-template name="overall-score-current-rate-client-site">
										<xsl:with-param name="client-site-id" select="@client_site_id" />
									</xsl:call-template>
								</div>
							</div>
							<!-- Targets -->
							<div class="row">
								<!-- //Description -->
								<div class="col-md-5">
									<h6>Targets</h6>
								</div>
								<!-- //Progress Bar -->
								<div class="col-md-7">
									<xsl:call-template name="overall-score-targets" />
								</div>
							</div>			
								
							<br />
							<a href="/members/assessment-report/{@child_client_checklist_id}/" class="button-link">
								<button type="button">More Information</button>
							</a>
							<br />

						</div>
					</div>
					
				</div>
			
			</xsl:for-each>
		</div>
	</xsl:template>

	<!-- //Overall Score Initial Rate -->
	<xsl:template name="overall-score-initial-rate-client-site">
		<xsl:param name="client-site-id" /> 
		<xsl:variable name="initial_rate" select="/config/plugin[@plugin = 'checklist']/report/clientSite[@client_site_id = $client-site-id]/@initial_score" />
			
		<div class="progress report-progress-bar">
		  <div class="progress-bar progress-bar-striped initial-score" role="progressbar" aria-valuenow="{$initial_rate * 100}" aria-valuemin="0" aria-valuemax="100" style="min-width: 2em; width:{floor($initial_rate * 100)}%">
			<xsl:value-of select="floor($initial_rate * 100)" />%
		  </div>
		</div>

	</xsl:template>
	
	<!-- //Overall Score Current Rate -->
	<xsl:template name="overall-score-current-rate-client-site">
		<xsl:param name="client-site-id" /> 
		<xsl:variable name="current_rate" select="/config/plugin[@plugin = 'checklist']/report/clientSite[@client_site_id = $client-site-id]/@current_score" />
			
		<div class="progress report-progress-bar">
		  <div class="progress-bar progress-bar-striped current-score" role="progressbar" aria-valuenow="{floor($current_rate * 100)}" aria-valuemin="0" aria-valuemax="100" style="min-width: 2em; width:{floor($current_rate * 100)}%">
			<xsl:value-of select="floor($current_rate * 100)" />%
		  </div>
		</div>
	</xsl:template>

	<!-- //
	//	Category Scores Chart
	//  Change 'type' attribute to change chart: radar, polarArea
	// -->
    <xsl:template match="category-scores-chart" mode="html">

		<!-- //Chart Type -->
		<xsl:param name="type">
			<xsl:choose>
				<xsl:when test="@type">
					<xsl:value-of select="@type" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'radar'" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>

        <canvas class="chart-js static" width="500" height="250" data-type="{$type}" data-background-colour-opacity="{@background-colour-opacity}">
            <xsl:attribute name="data-labels">
                <xsl:text>[</xsl:text>
                <xsl:for-each select="$report/reportSection[@points &gt; 0]">
                    <xsl:text>"</xsl:text><xsl:value-of select="@title" /><xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
                <xsl:text>]</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="data-data">
                <xsl:text>[</xsl:text>
                <xsl:for-each select="$report/reportSection[@points &gt; 0]">
                    <xsl:text>"</xsl:text><xsl:value-of select="format-number((((@points - @demerits) + @merits) div @points) * 100, '0.00')" /><xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
                <xsl:text>]</xsl:text>   
            </xsl:attribute>
        </canvas>

    </xsl:template>

	<!-- //
	//	TWE Action Plan Summary
	//  Change 'report_section_id' attribute to change limit the actions, default show all report sections
	// -->
    <xsl:template match="twe-action-plan-summary" mode="html">
		<div class="row data-table">
			<table class="table table-striped data-table static" data-order-col="4">
				<thead>
					<tr>
						<th>Sustainability Pilar</th>
						<th>Item</th>
						<th>Description</th>
						<th>Category</th>
						<th>Level</th>
						<th>Priority</th>
						<th>Responsibility</th>
						<th>Timing</th>
						<th>Manager Sign off on completion</th>
						<th>Outcome</th>
					</tr>
				</thead>

				<tbody>
					<xsl:for-each select="$report/reportSection">
						<xsl:variable name="reportSection" select="$report/reportSection[@report_section_id = current()/@report_section_id]" />
						<xsl:variable name="reportSectionPosition" select="position()" />

						<!-- // Actions -->
						<xsl:for-each select="$report/action[@report_section_id = $reportSection/@report_section_id][@comments = 'Minimum']">
							<tr>
								<td>
									<xsl:value-of select="$reportSection/@title" />
								</td>
								<td>
									<a href="{concat('#',$reportSectionPosition, '.', position())}" data-toggle="tooltip" title="Drill down to further information on this action.">
										<xsl:value-of select="concat($reportSectionPosition, '.', position())" />
									</a>
								</td>
								<td>
									<a href="{concat('#',$reportSectionPosition, '.', position())}" data-toggle="tooltip" title="Drill down to further information on this action.">
										<xsl:value-of select="@title" />
									</a>
								</td>
								<td>
									<xsl:value-of select="@summary" />
								</td>
								<td>
									<xsl:choose>
										<xsl:when test="proposed_measure/text() = 'Minimum'">
											<xsl:value-of select="proposed_measure/text()" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Best Practice</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</td>
								<td>
									<xsl:choose>
										<xsl:when test="proposed_measure/text() = 'Minimum' and @demerits &gt; 0">
											<xsl:text>High</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Medium</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</td>
								<td>
									<xsl:value-of select="../client_action_note[@action_id = current()/@action_id]/@extension5" />
								</td>
								<td>
									<xsl:value-of select="../client_action_note[@action_id = current()/@action_id]/@extension6" />
								</td>
								<td>
									<xsl:value-of select="../client_action_note[@action_id = current()/@action_id]/@extension7" />
								</td>
								<td>
									<xsl:value-of select="../client_action_note[@action_id = current()/@action_id]/@extension8" />
								</td>
							</tr>
						</xsl:for-each>

						<!-- // Client Action Notes -->
						<xsl:for-each select="$report/client_action_note[@report_section_id = $reportSection/@report_section_id][@action_id = 0]">
							<tr>
								<td>
									<xsl:value-of select="$reportSection/@title" />
								</td>
								<td>
									<a href="{concat('#',$reportSectionPosition, '.', (count($report/action[@report_section_id = $reportSection/@report_section_id][@comments = 'Minimum']) + position()) )}" data-toggle="tooltip" title="Drill down to further information on this action.">
										<xsl:value-of select="concat($reportSectionPosition, '.', (count($report/action[@report_section_id = $reportSection/@report_section_id][@comments = 'Minimum']) + position()) )" />
									</a>
								</td>
								<td>
									<a href="{concat('#',$reportSectionPosition, '.', (count($report/action[@report_section_id = $reportSection/@report_section_id][@comments = 'Minimum']) + position()) )}" data-toggle="tooltip" title="Drill down to further information on this action.">
										<xsl:value-of select="@extension1" />
									</a>
								</td>
								<td>
									<xsl:value-of select="@extension2" />
								</td>
								<td>
									<xsl:value-of select="@extension3" />
								</td>
								<td>
									<xsl:value-of select="@extension4" />
								</td>
								<td>
									<xsl:value-of select="@extension5" />
								</td>
								<td>
									<xsl:value-of select="@extension6" />
								</td>
								<td>
									<xsl:value-of select="@extension7" />
								</td>
								<td>
									<xsl:value-of select="@extension8" />
								</td>
							</tr>
						</xsl:for-each>
					</xsl:for-each>
				</tbody>

			</table>
		</div>

    </xsl:template>

	<xsl:template name="twe-action-plan">
		<xsl:param name="reportSectionPosition" />

		<xsl:if test="(count(../action[@report_section_id = current()/@report_section_id][@comments = 'Minimum'][@extension7 = 'Completed']) &gt; 0) or (count(../client_action_note[@report_section_id = current()/@report_section_id][@action_id = 0][@extension7 = 'Completed']) &gt; 0)">
			<div class="row">
				<div class="col-md-12">
					<a href=".{concat($reportSectionPosition, '-completed')}" class="btn btn-sml btn-warning pull-right mb-20" data-toggle="collapse">Toggle completed actions</a>
				</div>
			</div>
		</xsl:if>


		<!-- //Actions -->
		<xsl:for-each select="../action[@report_section_id = current()/@report_section_id][@comments = 'Minimum']">
			<xsl:call-template name="twe-action-plan-item">
				<xsl:with-param name="reportSectionPosition" select="$reportSectionPosition" />
				<xsl:with-param name="position" select="position()" />
			</xsl:call-template>
		</xsl:for-each>

		<!-- //Action notes in this report section that are not actions -->
		<xsl:for-each select="../client_action_note[@report_section_id = current()/@report_section_id][@action_id = 0]">
			<xsl:call-template name="twe-action-plan-item">
				<xsl:with-param name="reportSectionPosition" select="$reportSectionPosition" />
				<xsl:with-param name="position" select="count(../action[@report_section_id = current()/@report_section_id][@comments = 'Minimum']) + position()" />
			</xsl:call-template>
		</xsl:for-each>

		<!-- //Call the template -->
		<xsl:call-template name="twe-action-plan-template" />

	</xsl:template>

	<xsl:template name="twe-action-plan-item">
		<xsl:param name="reportSectionPosition" />
		<xsl:param name="position" />

		<!-- //Title -->
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="@title"><xsl:value-of select="@title" /></xsl:when>
				<xsl:otherwise><xsl:value-of select="@extension1" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- //Category -->
		<xsl:variable name="category">
			<xsl:choose>
				<xsl:when test="@summary"><xsl:value-of select="@summary" /></xsl:when>
				<xsl:otherwise><xsl:value-of select="@extension2" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- //Level -->
		<xsl:variable name="level">
			<xsl:choose>
				<xsl:when test="@comments"><xsl:value-of select="@comments" /></xsl:when>
				<xsl:otherwise><xsl:value-of select="@extension3" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- //Priority-->
		<xsl:variable name="priority">
			<xsl:choose>
				<xsl:when test="@demerits &gt; 0">High</xsl:when>
				<xsl:otherwise><xsl:value-of select="@extension4" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- //Completed Collapse -->
		<xsl:variable name="completed">
			<xsl:choose>
				<xsl:when test="../client_action_note[@action_id = current()/@action_id]/@extension7 = 'Completed'"><xsl:value-of select="concat($reportSectionPosition, '-completed collapse')" /></xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="col-md-12 wp-block no-space light twe-action-item {$completed}">
			<div class="wp-block-body">
				<a id="{concat($reportSectionPosition,'.',$position)}" />
				<input type="hidden" name="client_action_note[action_id][]" value="{@action_id}" />
				<input type="hidden" name="client_action_note[report_section_id][]" value="{@report_section_id}" />

				<!-- //Description -->
				<div class="row">
					<div class="col-md-12">
						<h5>
							<span class="action-item-count">
								<xsl:value-of select="concat($reportSectionPosition,'.',$position)" />
							</span>
							<input type="hidden" name="client_action_note[extension1][]" value="{$title}" />
							<xsl:value-of select="$title" />
						</h5>
					</div>
				</div>

				<!-- //Information -->
				<div class="row">
					<div class="col-md-12">
						<hr />
					</div>
					<div class="col-md-4">
						<div class="row">
							<div class="col-md-12 font-weight-700">
								Category
							</div>
							<div class="col-md-12">
								<input type="hidden" name="client_action_note[extension2][]" value="{$category}" />
								<xsl:value-of select="$category" />
							</div>
						</div>
					</div>
					<div class="col-md-4">
						<div class="row">
							<div class="col-md-12 font-weight-700">
								Level
							</div>
							<div class="col-md-12">
								<xsl:value-of select="$level" />
								<input type="hidden" name="client_action_note[extension3][]" value="{$level}" />
							</div>
						</div>
					</div>
					<div class="col-md-4">
						<div class="row">
							<div class="col-md-12 font-weight-700">
								Priority
							</div>
							<div class="col-md-12">
								<xsl:value-of select="$priority" />
								<input type="hidden" name="client_action_note[extension4][]" value="{$priority}" />
							</div>
						</div>
					</div>
				</div>

				<!-- //Input -->
				<div class="row">
					<div class="col-md-12">
						<hr />
					</div>
					<div class="col-md-4">
						<div class="row">
							<div class="col-md-12 font-weight-700">
								Responsibility
							</div>
							<div class="col-md-12">
								<input type="text" class="form-control" name="client_action_note[extension5][]" value="{../client_action_note[@action_id = current()/@action_id]/@extension5}" />
							</div>
						</div>
					</div>
					<div class="col-md-4">
						<div class="row">
							<div class="col-md-12 font-weight-700">
								Timing
							</div>
							<div class="col-md-12">
								<div class="input-group date date-time-picker day">
									<input type="text" class="form-control" name="client_action_note[extension6][]" value="{../client_action_note[@action_id = current()/@action_id]/@extension6}" />
									<span class="input-group-addon">
										<span class="fa fa-calendar"></span>
									</span>
								</div>
							</div>
						</div>
					</div>
					<div class="col-md-4">
						<div class="row">
							<div class="col-md-12 font-weight-700">
								Manager Sign Off
							</div>
							<div class="col-md-12">
								<select class="form-control" name="client_action_note[extension7][]">
									<option value="Incomplete">
										<xsl:if test="../client_action_note[@action_id = current()/@action_id]/@extension7 = 'Incomplete'">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										Incomplete
									</option>
									<option value="Completed">
										<xsl:if test="../client_action_note[@action_id = current()/@action_id]/@extension7 = 'Completed'">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										Completed
									</option>
								</select>
							</div>
						</div>
					</div>
				</div>

				<!-- //Outcome -->
				<div class="row">
					<div class="col-md-12">
						<hr />
					</div>
					<div class="col-md-12 font-weight-700">
						Outcome
					</div>
					<div class="col-md-12">
						<textarea name="client_action_note[extension8][]"><xsl:value-of select="../client_action_note[@action_id = current()/@action_id]/@extension8" /></textarea>
					</div>
				</div>

				<!-- //Save -->
				<div class="row">
					<div class="col-md-12">
						<hr />
					</div>
					<div class="col-md-4"></div>
					<div class="col-md-4 text-center">
						<button type="submit" class="btn btn-base btn-icon btn-block fa-save">Save</button>
					</div>
					<div class="col-md-4"></div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="twe-action-plan-template">

		<div class="repeatable">
			<div class="repeatable target"></div>
			<div class="col-md-12 wp-block no-space light twe-action-item repeatable template hidden">
				<div class="wp-block-body">
					<input type="hidden" name="client_action_note[action_id][]" value="" disabled="disabled" />
					<input type="hidden" name="client_action_note[report_section_id][]" value="{@report_section_id}" disabled="disabled" />
					
					<!-- //Description -->
					<div class="row">
						<div class="col-md-12 font-weight-700">
							Action Name
						</div>
						<div class="col-md-12">
							<input type="text" name="client_action_note[extension1][]" disabled="disabled" />
						</div>
					</div>

					<!-- //Information -->
					<div class="row">
						<div class="col-md-12">
							<hr />
						</div>
						<div class="col-md-4">
							<div class="row">
								<div class="col-md-12 font-weight-700">
									Category
								</div>
								<div class="col-md-12">
									<select class="form-control" name="client_action_note[extension2][]" disabled="disabled">
										<option value="Community">Community</option>
										<option value="Compliance">Compliance</option>
										<option value="Compliance with all laws and regulations on bribery, corruption and prohibited business practices">Compliance with all laws and regulations on bribery, corruption and prohibited business practices</option>
										<option value="Measuring &amp; Monitoring">Measuring &amp; Monitoring</option>
										<option value="Planning">Planning</option>
										<option value="Records">Records</option>
										<option value="Risk Assessment">Risk Assessment</option>
										<option value="Training">Training</option>
									</select>
								</div>
							</div>
						</div>
						<div class="col-md-4">
							<div class="row">
								<div class="col-md-12 font-weight-700">
									Level
								</div>
								<div class="col-md-12">
									Voluntary
									<input type="hidden" name="client_action_note[extension3][]" value="Voluntary" disabled="disabled" />
								</div>
							</div>
						</div>
						<div class="col-md-4">
							<div class="row">
								<div class="col-md-12 font-weight-700">
									Priority
								</div>
								<div class="col-md-12">
									<select class="form-control" name="client_action_note[extension4][]" disabled="disabled">
										<option value="Low">Low</option>
										<option value="Medium">Medium</option>
										<option value="High">High</option>
									</select>
								</div>
							</div>
						</div>
					</div>

					<!-- //Input -->
					<div class="row">
						<div class="col-md-12">
							<hr />
						</div>
						<div class="col-md-4">
							<div class="row">
								<div class="col-md-12 font-weight-700">
									Responsibility
								</div>
								<div class="col-md-12">
									<input type="text" class="form-control" name="client_action_note[extension5][]" value="{../client_action_note[@action_id = current()/@action_id]/@extension5}" disabled="disabled" />
								</div>
							</div>
						</div>
						<div class="col-md-4">
							<div class="row">
								<div class="col-md-12 font-weight-700">
									Timing
								</div>
								<div class="col-md-12">
									<div class="input-group date date-time-picker day">
										<input type="text" class="form-control" name="client_action_note[extension6][]" value="{../client_action_note[@action_id = current()/@action_id]/@extension6}" disabled="disabled" />
										<span class="input-group-addon">
											<span class="fa fa-calendar"></span>
										</span>
									</div>
								</div>
							</div>
						</div>
						<div class="col-md-4">
							<div class="row">
								<div class="col-md-12 font-weight-700">
									Manager Sign Off
								</div>
								<div class="col-md-12">
									<select class="form-control" name="client_action_note[extension7][]" disabled="disabled">
										<option value="Incomplete">
											<xsl:if test="../client_action_note[@action_id = current()/@action_id]/@extension7 = 'Incomplete'">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>
											Incomplete
										</option>
										<option value="Completed">
											<xsl:if test="../client_action_note[@action_id = current()/@action_id]/@extension7 = 'Completed'">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>
											Completed
										</option>
									</select>
								</div>
							</div>
						</div>
					</div>

					<!-- //Outcome -->
					<div class="row">
						<div class="col-md-12">
							<hr />
						</div>
						<div class="col-md-12 font-weight-700">
							Outcome
						</div>
						<div class="col-md-12">
							<textarea name="client_action_note[extension8][]" disabled="disabled"><xsl:value-of select="../client_action_note[@action_id = current()/@action_id]/@extension8" /></textarea>
						</div>
					</div>

					<!-- //Save -->
					<div class="row">
						<div class="col-md-12">
							<hr />
						</div>
						<div class="col-md-4"></div>
						<div class="col-md-4 text-center">
							<button type="submit" class="btn btn-base btn-icon btn-block fa-save">Save</button>
						</div>
						<div class="col-md-4"></div>
					</div>
				</div>
			</div>

			<div class="col-md-12">
				<div class="row">
					<div class="col-md-4"></div>
					<div class="col-md-4">
						<a href="#" class="btn btn-success btn-icon btn-block fa-plus add">Add voluntary action</a>
					</div>
					<div class="col-md-4"></div>
				</div>
			</div>

		</div>

	</xsl:template>
	

</xsl:stylesheet>