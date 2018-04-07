<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'auditList']">
		<h2><xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" /> Assessments</h2>
		<xsl:if test="count(clientChecklist[@status != 'incomplete' and @audit_required  = '1' and (@current_score &gt; '0.6' or @current_score = '0.6')]) = 0">
			<p>You do not have any auditable assessments available to you at this time.</p>
		</xsl:if>
		<xsl:if test="/config/globals/item[@key = 'saved']">
			<p style="text-align: center;"><strong>Your assessment has been successfully saved</strong></p>
		</xsl:if>
		<xsl:if test="count(clientChecklist[@status != 'incomplete' and @audit_required  = '1' and (@current_score &gt; '0.6' or @current_score = '0.6')]) &gt; 0">
			<h3>Auditable Assessments</h3>
			<p>This section contains all your auditable assessments - click on any highlighted assessment to start the audit process.</p>
			<xsl:for-each select="clientChecklist[@status != 'incomplete' and @audit_required  = '1' and (@current_score &gt; '0.6' or @current_score = '0.6')]">
			<p>
				<a class="assessment_report_title" href="{concat('/members/assessment-audit/',@client_checklist_id)}">
					<xsl:value-of select="@name" />
				</a>
                <xsl:if test="@expired = 'yes'">
                    <span style="color:red;"> - Expired</span>
                </xsl:if>
				<br />
				<xsl:if test="client_checklist_permission">
					Responsible Contacts: 
					<xsl:for-each select="client_checklist_permission">
						<xsl:value-of select="@contact_full_name"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:if>
				<xsl:text> Completed: </xsl:text>
				<xsl:value-of select="@completed" /><br />
			</p>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
		
</xsl:stylesheet>