<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'incompleteAssessments']">
		<xsl:choose>
			<xsl:when test="count(clientChecklist[@display_in_list != '0']) > 0">
				<xsl:for-each select="clientChecklist[@display_in_list != '0']">
					<div class="col-md-6 col-sm-6 assessment-list incomplete-assessments client-checklist-list">
						<div class="icon-block icon-block-2">
							<a href="{concat($root_path,'assessment-checklist/',@client_checklist_id,'/')}" class="assessment_report_title">
								<div class="icon-block-item green-biz-check-dark-green">
									<i class="fa fa fa-pencil-square-o "></i>
								</div>
							</a>
							<div class="icon-block-body">
								<a href="{concat($root_path,'assessment-checklist/',@client_checklist_id,'/')}" class="assessment_report_title">
									<h4 class="checklsit-title">
										<xsl:value-of select="@name" />
									</h4>
								</a>
								<p>
								<xsl:value-of select="@progress" />% completed<br />
								<xsl:if test="@last_modified != ''">
									Updated: <xsl:value-of select="@last_modified" /><br />
								</xsl:if>
								<xsl:if test="/config/plugin[@plugin = 'clients']/client/@client_type_id = '2'">
									<a class="assessment_completed_links" href="/members/?client_checklist_id={@client_checklist_id}&amp;action=delete_assessment" onclick="return(confirm('Did you really mean to click delete?'))">Delete Assessment</a>	
								</xsl:if>
								</p>
							</div>
						</div>
					</div>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<div class="col-md-6 col-sm-6">
					<p>You have no incomplete assessments. Please check your reports.</p>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
</xsl:stylesheet>