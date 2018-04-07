<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:php="http://php.net/xsl"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">

	<xsl:template match="config[@mode = 'audit_edit']">
		
		<xsl:variable name="audit" select="audit[@audit_id = current()/globals/item[@key = 'audit_id']/@value]" />
		
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=audit">Audit List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=audit&amp;mode=audit_edit&amp;audit_id={$audit/@audit_id}">
				<xsl:value-of select="$audit/@company_name" />
			</a>
		</p>
		<h1>Edit Assessment Audit</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="audit_save" />
			<input type="hidden" name="audit_id" value="{$audit/@audit_id}" />
			<table class="editTable">
				<tbody>
					<tr>
						<th scope="row">Client Name:</th>
						<td><xsl:value-of select="$audit/@company_name" /></td>
					</tr>
					<tr>
						<th scope="row">Address Line 1:</th>
						<td><xsl:value-of select="/config/client[@client_id = $audit/@client_id]/@address_line_1" /></td>
					</tr>
					<tr>
						<th scope="row">Address Line 2:</th>
						<td><xsl:value-of select="/config/client[@client_id = $audit/@client_id]/@address_line_2" /></td>
					</tr>
					<tr>
						<th scope="row">Suburb:</th>
						<td><xsl:value-of select="/config/client[@client_id = $audit/@client_id]/@suburb" /></td>
					</tr>
					<tr>
						<th scope="row">State:</th>
						<td><xsl:value-of select="/config/client[@client_id = $audit/@client_id]/@state" /></td>
					</tr>
					<tr>
						<th scope="row">Post Code:</th>
						<td><xsl:value-of select="/config/client[@client_id = $audit/@client_id]/@postcode" /></td>
					</tr>
					<tr>
						<th scope="row">Country:</th>
						<td><xsl:value-of select="/config/client[@client_id = $audit/@client_id]/@country" /></td>
					</tr>
					<tr>
						<th scope="row">Primary Contact:</th>
						<td><a href="mailto:{/config/client_contact[@client_contact_id = $audit/@client_contact_id]/@email}?subject=GreenBizCheck Assessment Audit"><xsl:value-of select="/config/client_contact[@client_contact_id = $audit/@client_contact_id]/@firstname" /><xsl:text> </xsl:text><xsl:value-of select="/config/client_contact[@client_contact_id = $audit/@client_contact_id]/@lastname" /></a></td>
					</tr>
					
					<!-- //Allow output of number of staff -->
					<tr>
						<th scope="row">Number of Staff:</th>
						<td>
							<xsl:choose>
								<xsl:when test="$audit/@number_of_staff != ''">
									<xsl:value-of select="$audit/@number_of_staff" />
								</xsl:when>
								<xsl:otherwise>
									No Information
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<th scope="row">Audit Score:</th>
						<td><xsl:value-of select="format-number($audit/@audit_score, '###%')" /></td>
					</tr>
					<tr>
						<th scope="row">Audit Level:</th>
						<td><xsl:value-of select="/config/certification_level[@certification_level_id = $audit/@certification_level_id]/@name" /></td>
					</tr>
					<tr>
						<th scope="row">Audit Start Date:</th>
						<td><xsl:apply-templates select="$audit/@audit_start_date" /></td>
					</tr>
					<tr>
						<th scope="row">Audit Complete Date:</th>
						<td>
							<xsl:if test="$audit/@audited = '1' and $audit/@certified = '1'">
								<xsl:apply-templates select="$audit/@audit_finish_date" />
							</xsl:if>
						</td>
					</tr>
					<tr>
						<th scope="row">Assessment/Audit Expiry Date:</th>
						<td>
							<xsl:value-of select="$audit/@expiry" />
						</td>
					</tr>
					<tr>
						<th scope="row">Audit Cost:</th>
						<td>
							<xsl:value-of select="concat('$',format-number($audit/@audit_cost,'0.00'))" />
						</td>
					</tr>
				</tbody>
			</table>
			
			<h1>Auditor Notes</h1>
			<p>Based on the current score of this assessment, <xsl:value-of select="format-number($audit/@audit_score, '###%')" />, there are <xsl:value-of select="/config/certification_level[@certification_level_id = $audit/@certification_level_id]/@audit_item_count" /> documentary audit items required for certification. Please review the documentation provided below and compare it to the question shown. Once all documentation is satisfactory enter complete the fields below and submit the audit to finish.</p>
			
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Audit" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row">Audit Status:</th>
						<td>
							<select id="status-id" name="status_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="/config/audit_status">
									<xsl:sort select="@status" />
									<option value="{@status_id}">
										<xsl:if test="$audit/@status = @status_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@status" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row">Audit Type:</th>
						<td>
							<select id="audit-type" name="audit_type">
								<option value="0">-- Select --</option>
								<xsl:for-each select="/config/audit_type">
									<xsl:sort select="@audit_type" />
									<option value="{@audit_type_id}">
										<xsl:if test="$audit/@audit_type = @audit_type_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@audit_type" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row">Audited:</th>
						<td>
							<input name="audited" type="checkbox" value="1">
								<xsl:if test="$audit/@audited = '1'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
						</td>
					</tr>
					<tr>
						<th scope="row">Certificate Submited:</th>
						<td>
							<input name="certified" type="checkbox" value="1">
								<xsl:if test="$audit/@certified = '1'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
						</td>
					</tr>
					<tr>
						<th scope="row">Assessor Name:</th>
						<td><input type="text" name="auditor_name" value="{$audit/@auditor_name}" /></td>
					</tr>
					<tr>
						<th scope="row">Assessor Email:</th>
						<td><input type="text" name="auditor_email" value="{$audit/@auditor_email}" /></td>
					</tr>
					<tr>
						<th scope="row">Assessor Phone:</th>
						<td><input type="text" name="auditor_phone" value="{$audit/@auditor_phone}" /></td>
					</tr>
					<tr>
						<th scope="row">Assessor Notes:</th>
						<td><textarea name="notes" rows="5"><xsl:value-of select="$audit/@notes" /></textarea></td>
					</tr>
				</tbody>
			</table>
		</form>
		
		<!-- //List the documents available for this client -->
		<h1>Audit Documents</h1>
		<table class="audit_table">
			<col style="width: 10%;" />
			<col style="width: 60%;" />
			<col style="width: 30%;" />
			<thead>
				<tr>
					<th scope="col">Question Id</th>
					<th scope="col">Question</th>
					<th scope="col">Document</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="/config/audit_evidence[@client_checklist_id = $audit/@client_checklist_id]">
					<tr>
						<td><xsl:value-of select="/config/audit_question[@audit_id = current()/@audit_id]/@question_id" /></td>
						<td><xsl:value-of select="/config/audit_question[@audit_id = current()/@audit_id]/@question" /></td>
						<td>
							<a href="https://www.greenbizcheck.com/download/?hash={@hash}">
								<xsl:value-of select="@name" /> (<xsl:value-of select="@readable_size" />)
							</a>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		
					<!-- //List all of the audits that are based on the same clientChecklistId -->
			<xsl:if test="count(audit[@client_checklist_id = $audit/@client_checklist_id]) > 1">
			<h1>Related Assessment Audits</h1>
			<p>The following audits are related to the same client assessment as this audit:</p>
			<table id="accountlist">
			<thead>
				<tr>
					<th scope="col">Company Name</th>
					<th scope="col">Checklist</th>
					<th scope="col">Audit Score</th>
					<th scope="col">Audit Level</th>
					<th scope="col">Audited</th>
					<th scope="col">Certified</th>
					<th scope="col">Audit Start Date</th>
					<th scope="col">Audit Complete Date</th>
					<th scope="col">Audit Status</th>
				</tr>
			</thead>
			<tbody>
			<xsl:for-each select="audit[@client_checklist_id = $audit/@client_checklist_id and @audit_id != $audit/@audit_id]">
			<tr>
				<xsl:choose>
					<xsl:when test="position() mod 2 = 0">
						<xsl:attribute name="class">even</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="class">odd</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<td>
					<xsl:value-of select="@company_name" />
					<br />
					<span class="options">
						<a href="?page=audit&amp;mode=audit_edit&amp;audit_id={@audit_id}" title="Audit Assessment">audit</a>
					</span>
				</td>
				<td>
					<xsl:value-of select="@name" />
				</td>
				<td>
					<xsl:value-of select="format-number(@audit_score, '###%')" />
				</td>
				<td>
					<!--//Get the current certification level for the checklist id -->
					<xsl:variable name="related_audit_certification_level">
						<xsl:choose>
							<xsl:when test="@audit_score &gt; '0.80000' or @audit_score = '0.80000'">Gold</xsl:when>
							<xsl:when test="@audit_score &gt; '0.70000' or @audit_score = '0.70000'">Silver</xsl:when>
							<xsl:when test="@audit_score &gt; '0.60000' or @audit_score = '0.60000'">Bronze</xsl:when>
							<xsl:otherwise>invalid</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:value-of select="$related_audit_certification_level" />
				</td>
				<td>
					<xsl:choose>
						<xsl:when test="@audited = '0'">
							<xsl:text>No</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>Yes</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</td>
				<td>
					<xsl:choose>
						<xsl:when test="@certified = '0'">
							<xsl:text>No</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>Yes</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</td>
				<td><xsl:apply-templates select="@audit_start_date" /></td>
				<td>
					<xsl:if test="@audited = '1' and @certified = '1'">
						<xsl:apply-templates select="@audit_finish_date" />
					</xsl:if>
				</td>
				<td>
					<xsl:value-of select="/config/audit_status[@status_id = current()/@status]/@status" />
				</td>
			</tr>
			</xsl:for-each>
			</tbody>
			</table>
			</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="audit/@audit_start_date[. = '0000-00-00'] | audit/@audit_finish_date[. = '']" />
	
</xsl:stylesheet>