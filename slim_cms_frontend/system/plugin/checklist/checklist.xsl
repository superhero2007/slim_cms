<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">
	
	<xsl:include href="methods/certificate.xsl" />
	<xsl:include href="methods/assessment_list.xsl" />
	<xsl:include href="methods/assessment.xsl" />
	<xsl:include href="methods/assessment_answers.xsl" />
	<xsl:include href="methods/report.xsl" />
	<xsl:include href="methods/assessment_metrics.xsl" />
	<xsl:include href="methods/audit.xsl" />
	<xsl:include href="methods/audit_list.xsl" />
	<xsl:include href="methods/incompleteAssessments.xsl" />
	<xsl:include href="methods/completeAssessments.xsl" />
	<xsl:include href="methods/ghg_assessment.xsl" />
	<xsl:include href="methods/client-checklist.xsl" />
	<xsl:include href="methods/add-entry-wizard.xsl" />
	<xsl:include href="methods/auslsa-templates.xsl" />
	<xsl:include href="methods/analytics.xsl" />
	<xsl:include href="methods/vivid-sydney-templates.xsl" />
	
	<xsl:template match="companyName" mode="html">
		<xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" />
	</xsl:template>
	
	<xsl:template match="tableOfContents" mode="html">
		<ol>
			<xsl:for-each select="/config/plugin[@plugin = 'checklist'][@method = 'clientChecklists']/report/reportSection">
				<li><a href="#section-{position()}"><xsl:value-of select="@title" /></a></li>
			</xsl:for-each>
		</ol>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'auto_issue_checklist']">
		<p><xsl:value-of select="/config/message/@message" /></p>
	</xsl:template>
	
	
	<xsl:template name="contactName">
		<xsl:param name="checklist"/>
		<xsl:value-of select="$checklist/@client_contact_salutation"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$checklist/@client_contact_firstname"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$checklist/@client_contact_lastname"/>
	</xsl:template>

	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'getEntryVariation']">
		
		<xsl:variable name="order-by">
			<xsl:choose>
				<xsl:when test="@order-by">
					<xsl:value-of select="@order-by" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>6</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="order-direction">
			<xsl:choose>
				<xsl:when test="@order-direction">
					<xsl:value-of select="@order-direction" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>desc</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="default-rows">
			<xsl:choose>
				<xsl:when test="@default-rows">
					<xsl:value-of select="@default-rows" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>10</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="row-fluid data-table">
			<div class="table-responsive">
				<table class="table ajax-datatable table-striped dataTable" data-order="[[{$order-by},&quot;{$order-direction}&quot;]]" data-page-length="{$default-rows}" data-display="{@display}" data-query-id="{query-data/@query}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}">
					<thead>
						<tr>
							<xsl:choose>
								<xsl:when test="columns/column">
									<xsl:for-each select="columns/column">
										<th scope="col">
											<xsl:value-of select="@name" />
										</th>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<th scope="col">Section</th>
									<th scope="col">Question</th>
									<th scope="col">Current Period</th>
									<th scope="col">Current Value</th>
									<th scope="col">Previous Period</th>
									<th scope="col">Previous Value</th>
									<th scope="col">Variation</th>
								</xsl:otherwise>
							</xsl:choose>
						</tr>
					</thead>
				</table>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="locked">
		<div class="row">
			<div class="col-md-12">
				<div class="alert alert-danger">
					This entry has been locked.
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="data-field" mode="html">
		<xsl:param name="type" select="@type" />
		<xsl:param name="id" select="@id" />
		<xsl:param name="attribute" select="@attribute" />

		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<xsl:choose>
			<xsl:when test="$type = 'answer_id'">
				<xsl:choose>
					<xsl:when test="$attribute = 'answer_string'">
						<xsl:value-of select="$report/questionAnswer/answer[@answer_id = $id]/@answer_string" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$report/questionAnswer/answer[@answer_id = $id]/@arbitrary_value" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>

	</xsl:template>
	
</xsl:stylesheet>