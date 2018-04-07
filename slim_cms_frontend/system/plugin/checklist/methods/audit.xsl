<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">
	
	<!-- //Choose what template we need to display -->
	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'audit']">
	<h2><xsl:value-of select="clientChecklist/@checklist" /> Assessment Audit</h2>

	<xsl:variable name="audit-mode" select="/config/globals/item[@key = 'audit-mode']/@value" />

	<xsl:choose>
		<xsl:when test="$audit-mode = 'upload'">
			<xsl:call-template name='upload' />
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name='audit-list' />
		</xsl:otherwise>
	</xsl:choose>
	</xsl:template>

	<!-- //Template to list all of the audit items -->
	<xsl:template name="audit-list-legacy">
	
	<!--//Get the current certification level for the checklist id -->
	<xsl:variable name="required_audit_count">
		<xsl:choose>
			<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@certified_level = 'gold'">10</xsl:when>
			<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@certified_level = 'silver'">8</xsl:when>
			<xsl:otherwise>6</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

		<p><img src="/_images/public-v4/bureau_veritas_logo.png" align="right" width="85px" height="100px" margin="5px" />Your assessment is currently at <xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@certified_level" /> certification level. In order to access your certification tools you are required to upload a minimum of <xsl:value-of select="$required_audit_count" /> documentary evidence items for auditing.</p>
		<p>Once you have attached <xsl:value-of select="$required_audit_count" /> items below you will be able to submit your evidence to an assessor for auditing.</p>
		<p>Documentary Evidence can be an image, a scanned invoice or any other documentation that shows proof of action. Please upload low resolution scans or photographs.</p>
		<xsl:call-template name="submitAuditTest" />
		<!--//List all of the audits available that are 'Documentary Evidence' -->
		<table class="audit_table">
			<col style="width: 5%;" />
			<col style="width: 65%;" />
			<col style="width: 23%;" />
			<col style="width: 7%;" />
			<thead>
				<tr>
					<th scope="col">Question ID</th>
					<th scope="col">Question</th>
					<th scope="col">Document</th>
					<th scope="col">Upload/Delete</th>
				</tr>
			</thead>
			<tbody>
			
				<!-- //Loop through the questions that were answerd positively during the assessment -->
				<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/audit">
				<xsl:variable name="audit_doc_info" select="/config/plugin[@plugin = 'checklist']/audit_documents[@audit_id = current()/@audit_id]" />
					<tr id="audit_{@audit_id}">
						<td><xsl:value-of select="@question_id" /></td>
						<td><xsl:value-of select="@question" /></td>
						
						<!--// If there is a valid document already display the details and delete option -->
						<xsl:choose>
							<xsl:when test="$audit_doc_info/@document_name != ''">
								<td><a href="?audit-mode=download&amp;audit-document-id={$audit_doc_info/@document_id}"><xsl:value-of select="$audit_doc_info/@document_name" /></a></td>
								<td><a href="?audit-mode=delete&amp;audit-id={@audit_id}"><img src="/_images/icons/delete.png" alt="Delete" /></a></td>
							</xsl:when>
							<xsl:otherwise>
								<td></td>
								<td><a href="?audit-mode=upload&amp;audit-id={@audit_id}"><img src="/_images/icons/add.png" alt="Add" /></a></td>
							</xsl:otherwise>
						</xsl:choose>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		<br class="clear" />
		
		<xsl:call-template name="submitAuditTest" />

		
		<xsl:if test="/config/plugin[@plugin = 'checklist']/client_audit">
			<xsl:call-template name="audit_status" />
		</xsl:if>
		<br class="clear" />
	</xsl:template>
	
			<!-- //Check to see if the required document count has been reached -->
		<!--//Get the current certification level for the checklist id -->
		<xsl:template name="submitAuditTest">
			<!--//Get the current certification level for the checklist id -->
	<xsl:variable name="required_audit_count">
		<xsl:choose>
			<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@certified_level = 'gold'">10</xsl:when>
			<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@certified_level = 'silver'">8</xsl:when>
			<xsl:otherwise>6</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
		<xsl:if test="count(/config/plugin[@plugin = 'checklist']/audit_documents) &gt; $required_audit_count or count(/config/plugin[@plugin = 'checklist']/audit_documents) = $required_audit_count">
			
			<!-- //Get the audit score bounds -->
			<xsl:variable name="upper_bound">
				<xsl:choose>
					<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@certified_level = 'gold'">0.9</xsl:when>
					<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@certified_level = 'silver'">0.8</xsl:when>
					<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@certified_level = 'bronze'">0.7</xsl:when>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="lower_bound" select="$upper_bound - 0.10001" />
			
			<!-- Check to see if there has been a previous submit for this certification level first -->
			<xsl:if test="count(/config/plugin[@plugin = 'checklist']/client_audit[@audit_score &gt; $lower_bound and @audit_score &lt; $upper_bound]) = 0">
				<xsl:call-template name="submitAudit" />
			</xsl:if>
		</xsl:if>
		</xsl:template>
	
	<xsl:template name="submitAudit">
		<p><strong>You have enough documentary evidence to submit for auditing at <xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@certified_level" /> certification level, please submit this evidence for auditing below:</strong></p>
			<form name="submit-for-auditing" method="post">
				<input type="hidden" name="audit-mode" value="submit" />
				<input type="hidden" name="current_score" value="{(/config/plugin[@plugin = 'checklist']/report/@current_score div 100)}" />
				<input type="hidden" name="client_contact_id" value="{/config/plugin[@plugin = 'clients']/client/contact/@client_contact_id}" />
				<input type="submit" value="submit" />
			</form>
				<br />
	</xsl:template>
	
	<!-- //Template to submit the documents for auditing, only available once the required document count has been reached -->
	<xsl:template name="audit_status">
		<p>You have submitted this assessment for auditing, below are the details of the audit.</p>
		<table class="audit_table">
			<thead>
				<tr>
					<th scope="col">Date Submitted</th>
					<th scope="col">Level</th>
					<th scope="col">Score</th>
					<th scope="col">Status</th>
					<th scope="col">Date Completed</th>
				</tr>
				<tbody>
					<xsl:for-each select="/config/plugin[@plugin = 'checklist']/client_audit">
					
						<!-- //Get the current certification level -->
						<xsl:variable name="certification_level">
							<xsl:choose>
								<xsl:when test="@audit_score &gt; '0.79999'">Gold</xsl:when>
								<xsl:when test="@audit_score &gt; '0.69999'">Silver</xsl:when>
								<xsl:when test="@audit_score &gt; '0.59999'">Bronze</xsl:when>
								<xsl:otherwise>None</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<tr>
						<td><xsl:value-of select="@audit_start_date" /></td>
						<td><xsl:value-of select="$certification_level" /></td>
						<td><xsl:value-of select="format-number(@audit_score, '###%')" /></td>
						<td>
							<xsl:choose>
								<xsl:when test="@status = '5' or @status = '6'">
									<form name="submit-for-auditing" method="post">
										<xsl:value-of select="@audit_status" />
										<input type="hidden" name="audit-mode" value="resubmit" />
										<input type="hidden" name="audit_id" value="{@audit_id}" />
										<input type="submit" value="resubmit" style="float:right" />
									</form>
								</xsl:when>
								<xsl:when test="@status = '1' or @status = '2'">
									<form name="delay-audit" method="post">
										<xsl:value-of select="@audit_status" />
										<input type="hidden" name="audit-mode" value="delayed" />
										<input type="hidden" name="status" value="6" />
										<input type="hidden" name="audit_id" value="{@audit_id}" />
										<input type="image" src="/_images/icons/delayed.png" height="20px" width="20px" style="float:right"/>
									</form>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@audit_status" />
								</xsl:otherwise>
							</xsl:choose>
						</td>
						<td>
							<xsl:if test="@status = '3' or @status = '4'">
								<xsl:value-of select="@audit_finish_date" />
							</xsl:if>
						</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</thead>
		</table>
		<p>You can delay a submitted or resubmitted audit if you need to make change by clicking the <img src="/_images/icons/delayed.png" height="20px" width="20px" /> icon above.</p>
	</xsl:template>

	<!-- //Check to see if the required document count has been reached -->
	<!--//Get the current certification level for the checklist id -->
	<xsl:template name="submit-audit-test">
		<xsl:variable name="clientChecklist" select="/config/plugin[@plugin = 'checklist']/report" />

		<xsl:variable name="required_audit_count">
			<xsl:choose>
				<xsl:when test="$clientChecklist/@certified_level = 'gold'">10</xsl:when>
				<xsl:when test="$clientChecklist/@certified_level = 'silver'">8</xsl:when>
				<xsl:otherwise>6</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="count($clientChecklist/auditEvidence) &gt; $required_audit_count or count($clientChecklist/auditEvidence) = $required_audit_count">

			<xsl:variable name="certificationLevel" select="$clientChecklist/certificationLevel[@certification_level_id = $clientChecklist/@certification_level_id]" />

			<xsl:if test="count($clientChecklist/client_audit[(@audit_score * 100) &gt; ($certificationLevel/@target - 0.00001)]) = 0">
				<xsl:call-template name="submit-audit" />
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="submit-audit">
		<div class="row">
			<div class="col-md-12">
				<p class="text-center">
					<strong>You have enough documentary evidence to submit for auditing at <xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/@certified_level" /> certification level, please submit this evidence for auditing.</strong>
				</p>
			</div>
		</div>
		<div class="row">
			<div class="col-md-12 text center margin-bottom-20">
				<form name="submit-for-auditing" method="post">
					<input type="hidden" name="audit-mode" value="submit" />
					<input type="hidden" name="current_score" value="{(/config/plugin[@plugin = 'checklist']/report/@current_score div 100)}" />
					<input type="hidden" name="client_contact_id" value="{/config/plugin[@plugin = 'clients']/client/contact/@client_contact_id}" />
					<button type="submit" class="btn btn-base">Submit Audit</button>
				</form>
			</div>
		</div>
	</xsl:template>

	<!-- //Template to submit the documents for auditing, only available once the required document count has been reached -->
	<xsl:template name="audit-status">

		<div class="row">
			<div class="col-md-12 text-center margin-bottom-20">
				<p>
					<strong>You have submitted this assessment for auditing, below are the details of the audit.</strong>
				</p>
			</div>
		</div>

		<div class="row">
			<div class="col-md-12 margin-bottom-20">
				<div class="table-responsive">
					<table class="table table-striped">
						<thead>
							<tr>
								<th>Submitted</th>
								<th>Level</th>
								<th>Score</th>
								<th>Status</th>
								<th>Completed</th>
							</tr>
							<tbody>
								<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/client_audit">
								
									<!-- //Get the current certification level -->
									<xsl:variable name="certification_level">
										<xsl:choose>
											<xsl:when test="@audit_score &gt; '0.79999'">Gold</xsl:when>
											<xsl:when test="@audit_score &gt; '0.69999'">Silver</xsl:when>
											<xsl:when test="@audit_score &gt; '0.59999'">Bronze</xsl:when>
											<xsl:otherwise>None</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<tr>
									<td><xsl:value-of select="@audit_start_date" /></td>
									<td><xsl:value-of select="$certification_level" /></td>
									<td><xsl:value-of select="format-number(@audit_score, '###%')" /></td>
									<td>
										<xsl:choose>
											<xsl:when test="@status = '5' or @status = '6'">
												<form name="submit-for-auditing" method="post">
													<xsl:value-of select="@audit_status" />
													<input type="hidden" name="audit-mode" value="resubmit" />
													<input type="hidden" name="audit_id" value="{@audit_id}" />
													<input type="submit" value="resubmit" style="float:right" />
												</form>
											</xsl:when>
											<xsl:when test="@status = '1' or @status = '2'">
												<form name="delay-audit" method="post">
													<xsl:value-of select="@audit_status" />
													<input type="hidden" name="audit-mode" value="delayed" />
													<input type="hidden" name="status" value="6" />
													<input type="hidden" name="audit_id" value="{@audit_id}" />
													<input type="image" src="/_images/icons/delayed.png" height="20px" width="20px" style="float:right"/>
												</form>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="@audit_status" />
											</xsl:otherwise>
										</xsl:choose>
									</td>
									<td>
										<xsl:if test="@status = '3' or @status = '4'">
											<xsl:value-of select="@audit_finish_date" />
										</xsl:if>
									</td>
									</tr>
								</xsl:for-each>
							</tbody>
						</thead>
					</table>
				</div>
			</div>
		</div>

	</xsl:template>




	<!-- Refactored 20170426 -->
	
	<!-- //Template for Audit Questions -->
	<xsl:template match="auditQuestions" mode="html">

		<xsl:choose>
			<xsl:when test="/config/plugin[@plugin = 'checklist']/report/@audit_required = '1' and count(/config/plugin[@plugin = 'checklist']/report/certificationLevel[@audit_required = '1']) > 0">
				<div id="#entry-audit" name="entry-audit"></div>

				<div class="row">
					<div class="col-md-12 margin-bottom-20">
						<p><img src="/_images/public-v4/bureau_veritas_logo.png" align="right" width="85px" height="100px" margin="5px" />In order to access your certification tools you are required to upload evidence items for auditing.</p>
						<p>Once you have uploaded enough evidence items below you will be able to submit your evidence to an assessor for auditing.</p>
						<p>Documentary Evidence can be an image, a scanned invoice or any other documentation that shows proof of action.</p>
					</div>
				</div>

				<!-- //Audit Questions -->
				<xsl:call-template name="audit-questions" />

				<!-- //Audit List -->
				<xsl:call-template name="audit-list" />

			</xsl:when>
			<xsl:otherwise>
				<p>You are not required to submit any audit documentation.</p>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="audit-questions">

		<xsl:variable name="upload-ready">
			<xsl:choose>
				<xsl:when test="count(/config/plugin[@plugin = 'checklist']/report/certificationLevel[@audit_required = 1][@required_score_reached = 1][@required_audit_items_reached = 1]) &lt; 1">0</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="row">
			<div class="col-md-12">
				<div class="table-responsive">
					<table class="table table-striped">
						<thead>
							<th width="70%">Question</th>
							<th width="30%">Evidence</th>
						</thead>
						<tbody>
							<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/audit">
								<tr>
									<td>
										<xsl:value-of select="@question" />
									</td>
									<td>
										<xsl:choose>
											<xsl:when test="$upload-ready = '1'">
												<xsl:call-template name="audit-file-upload">
													<xsl:with-param name="id" select="@audit_id" />
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<p>Not available yet.</p>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</tr>
							</xsl:for-each>
						</tbody>
					</table>
				</div>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="audit-list">
		<div class="table-responsive" id="certification-level-table">
			<table class="table table-striped">
				<thead>
					<tr>
						<th>Certification Level</th>
						<th>Target Score</th>
						<th>Required Evidence Items</th>
						<th>Status</th>
						<th>Action</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="/config/plugin[@plugin = 'checklist']/report/certificationLevel[@audit_required = '1']">
						<xsl:sort select="@target" order="descending" data-type="number" />
						<tr>
							<td><xsl:value-of select="@name" /></td>
							<td><xsl:value-of select="@target" /></td>
							<td><xsl:value-of select="@audit_item_count" /></td>
							<td>
								<xsl:choose>
									<xsl:when test="/config/plugin[@plugin = 'checklist']/report/client_audit[@certification_level_id = current()/@certification_level_id]/@certified = 1">
										Certified
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="/config/plugin[@plugin = 'checklist']/report/client_audit[@certification_level_id = current()/@certification_level_id]/@audit_status" />
									</xsl:otherwise>
								</xsl:choose>			
							</td>
							<td>
								<xsl:if test="@required_audit_items_reached = '1' and @required_score_reached = '1'">
									<xsl:choose>
										<xsl:when test="/config/plugin[@plugin = 'checklist']/report/certificationLevel[@target &gt; current()/@target][@required_audit_items_reached = 1][@required_score_reached = 1]">
										</xsl:when>
										<xsl:when test="/config/plugin[@plugin = 'checklist']/report/client_audit[@certification_level_id = current()/@certification_level_id]/@status &lt; 5">
										</xsl:when>
										<xsl:when test="/config/plugin[@plugin = 'checklist']/report/client_audit[@certification_level_id = @certification_level_id]/@status = 5">
											<input name="certification_level_id" type="hidden" value="{@certification_level_id}" />
											<input name="audit_id" type="hidden" value="{/config/plugin[@plugin = 'checklist']/report/client_audit[@certification_level_id = current()/@certification_level_id]/@audit_id}" />
											<button type="submit" class="btn btn-success btn-icon fa-paper-plane" data-setvalue="true" data-target="#linkafter" data-value="#certification-level-table">Resubmit for auditing</button>
										</xsl:when>
										<xsl:otherwise>
											<input name="certification_level_id" type="hidden" value="{@certification_level_id}" />
											<button type="submit" class="btn btn-success btn-icon fa-paper-plane" data-setvalue="true" data-target="#linkafter" data-value="#certification-level-table">Submit for auditing</button>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</div>	
	</xsl:template>

	<xsl:template name="audit-file-upload">

		<!-- //Set the upload parameters -->
		<xsl:param name="id" />
		<xsl:variable name="input-name" select="concat('audit-file[',$id,']')" />
		<xsl:variable name="file" select="/config/plugin[@plugin = 'checklist']/report/auditEvidence[@audit_id = $id]" />
		<xsl:variable name="audit_id" select="$id" />
		<xsl:variable name="client_checklist_id" select="/config/plugin[@plugin = 'checklist']/report/@client_checklist_id" />
		
		<div class="file-upload-container file-upload">
			<!-- The fileinput-button span is used to style the file input field as button -->
			<div class="row">
				<div class="col-md-12 file-upload-button collapse">
					<span class="btn btn-success btn-icon fa-plus fileinput-button">
						<span>Select file...</span>
						<!-- The file input field used as target for the file upload widget -->
						<input type="file" name="file-upload-{$id}" class="bimp file-upload" data-id="{$id}" data-audit-input="{$id}" />
						<input type="hidden" name="{$input-name}" value="{$file/@value}" data-input="file-{$id}" data-name="{$file/@name}" data-size="{$file/@size}" data-audit="{$id}" readonly="readonly" />
					</span>
				</div>
				<div class="col-md-12 file-delete-button collapse">
					<span class="btn btn-danger btn-icon fa-trash delete" data-id="{$id}">
						<span>Delete file</span>
					</span>
				</div>
				<div class="col-md-12">
					<div class="file-name-status"></div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<!-- The global progress bar -->
					<div class="progress">
						<div class="progress-bar progress-bar-success"></div>
					</div>
				</div>
			</div>
		</div>

	</xsl:template>


</xsl:stylesheet>