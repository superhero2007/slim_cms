<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:variable name="base-checklist-id">
		<xsl:value-of select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@client_checklist_id = /config/globals/item[@key = 'compare_client_checklist_id']/item[@key = '0']/@value]/@checklist_id" />
	</xsl:variable>

	<xsl:variable name="base-client-checklist-id">
		<xsl:value-of select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@client_checklist_id = /config/globals/item[@key = 'compare_client_checklist_id']/item[@key = '0']/@value]/@client_checklist_id" />
	</xsl:variable>

	<xsl:template match="client-checklist-compare" mode="html">
		<xsl:call-template name="client-checklist-compare" />
	</xsl:template>

	<!-- //Client Checklist Answer Report - Grid Based Layout -->
	<xsl:template name="client-checklist-compare-legacy">

		<div class="client-checklist-compare">
			
			<div class="table-responsive">

				<!-- //Get the assessment deails -->
				<div class="gbc-dashboard-answer-report assessment details">
					<div class="row page-title-container">
						<div class="col-xs-12 bg-gray-dark page-title">
							Assessment Details
						</div>
					</div>
					<div class="row question-answer-container">
						<div class="col-xs-4 question">Company Name</div>
						<div class="row col-xs-8 answer">
							<div class="row col-xs-12">
								<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@compare-this-checklist = '1'][@checklist_id = $base-checklist-id]">
									<xsl:sort select="@current_score" data-type="number" order="descending" />
									<div class="col-xs-2 data-col">
										<a href="/members/dashboard/assessments/details/?client_id={@client_id}&amp;client_checklist_id={@client_checklist_id}">
											<xsl:value-of select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/client[@client_id = current()/@client_id]/@company_name" />
										</a>
									</div>
								</xsl:for-each>
							</div>
						</div>
					</div>
					<div class="row question-answer-container">
						<div class="col-xs-4 question">Assessment ID</div>
						<div class="row col-xs-8 answer">
							<div class="row col-xs-12">
								<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@compare-this-checklist = '1'][@checklist_id = $base-checklist-id]">
									<xsl:sort select="@current_score" data-type="number" order="descending" />
									<div class="col-xs-2 data-col">
										<xsl:value-of select="@client_checklist_id" />
									</div>
								</xsl:for-each>
							</div>
						</div>
					</div>
					<div class="row question-answer-container">
						<div class="col-xs-4 question">Score</div>
						<div class="row col-xs-8 answer">
							<div class="row col-xs-12">
								<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@compare-this-checklist = '1'][@checklist_id = $base-checklist-id]">
									<xsl:sort select="@current_score" data-type="number" order="descending" />
									<div class="col-xs-2 data-col">
										<xsl:value-of select="@score_round_formatted" />
									</div>
								</xsl:for-each>
							</div>
						</div>
					</div>
					<div class="row page-title-container">
						<div class="col-xs-12 bg-gray-dark page-title">
							Category Scores
						</div>
					</div>
					<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@client_checklist_id = $base-client-checklist-id]/reportSection[@points &gt; 0]">
						<xsl:variable name="reportSectionId" select="@report_section_id" />
 						<div class="row question-answer-container">
							<div class="col-xs-4 question">
								<xsl:value-of select="@title" />
							</div>
							<div class="row col-xs-8 answer">
								<div class="row col-xs-12">
									<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@compare-this-checklist = '1'][@checklist_id = $base-checklist-id]">	
										<xsl:sort select="@current_score" data-type="number" order="descending" />

										<xsl:variable name="clientChecklist" select="current()" />		
										<!-- //Get the current report section and client_checklist_id calculation -->
										<xsl:variable name="points" select="sum($clientChecklist/reportSection[@report_section_id = $reportSectionId]/@points)" />
										<xsl:variable name="demerits" select="sum($clientChecklist/reportSection[@report_section_id = $reportSectionId]/@demerits)" />
										<xsl:variable name="merits" select="sum($clientChecklist/reportSection[@report_section_id = $reportSectionId]/@merits)" />
										<xsl:variable name="current_rate" select="($points - $demerits + $merits) div $points" />

										<div class="col-xs-2 data-col">
											<xsl:value-of select="floor($current_rate * 100)" />%
										</div>
									</xsl:for-each>
								</div>
							</div>
						</div>
					</xsl:for-each>
				</div>

				<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/page[@checklist_id = $base-checklist-id]">
					<xsl:if test="count(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/question[@page_id = current()/@page_id]) &gt; 0">
						<div class="gbc-dashboard-answer-report">
							<div class="row page-title-container">
								<div class="col-xs-12 bg-gray-dark page-title">
									<xsl:if test="@page_section_title != ''">
										<xsl:value-of select="concat(@page_section_title, ' - ')" />
									</xsl:if>
									<xsl:value-of select="@title" />
								</div>
							</div>
							<div class="row question-answer-container">
								<div class="col-xs-4 question header">
									Question
								</div>
								<div class="col-xs-8 answer header">
									Answer
								</div>
							</div>
							<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/question[@page_id = current()/@page_id]">
								<xsl:sort select="@sequence" data-type="number" />
								<xsl:variable name="current-question-id" select="@question_id" />
								
								<div class="row question-answer-container">
									<div class="col-xs-4 question">
										<xsl:value-of select="@question" disable-output-escaping="yes" />
									</div>
									<div class="row col-xs-8 answer">
										<div class="row col-xs-12">
											<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@compare-this-checklist = '1'][@checklist_id = $base-checklist-id]">
												<xsl:sort select="@current_score" data-type="number" order="descending" />
												<xsl:variable name="clientChecklist" select="current()" />

												<div class="col-xs-2 data-col">
													<xsl:choose>
														<xsl:when test="count(client_result[@question_id = $current-question-id]) &gt; 0">
															<xsl:for-each select="client_result[@question_id = $current-question-id]">
																<xsl:choose>
																	<xsl:when test="@answer_type = 'checkbox' or @answer_type = 'drop-down-list'"><xsl:value-of select="$clientChecklist/answer[@answer_id = current()/@answer_id]/@string" disable-output-escaping="yes" /></xsl:when>
																	<xsl:when test="@answer_type = 'percent'"><xsl:value-of select="@arbitrary_value" />%</xsl:when>
																	<xsl:when test="@answer_type = 'text' or @answer_type = 'textarea'">
																		<xsl:if test="$clientChecklist/answer[@answer_id = current()/@answer_id]/@string!= ''">
																			<xsl:value-of select="concat($clientChecklist/answer[@answer_id = current()/@answer_id]/@string, ': ')" />
																		</xsl:if>
																		<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
																	</xsl:when>
																	<xsl:when test="@answer_type = 'checkbox-other'">
																		<xsl:value-of select="$clientChecklist/answer[@answer_id = current()/@answer_id]/@string" disable-output-escaping="yes" />
																		<xsl:text>: </xsl:text>
																		<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:when>
																	<xsl:when test="@answer_type = 'date-quarter'">Quarter ending <xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:when>
																	<xsl:when test="@answer_type = 'float'">
																		<xsl:if test="$clientChecklist/answer[@answer_id = current()/@answer_id]/@string != ''">
																			<xsl:value-of select="concat($clientChecklist/answer[@answer_id = current()/@answer_id]/@string, ': ')" />
																		</xsl:if>
																		<xsl:choose>
																			<xsl:when test="string(number(myNode)) != 'NaN'">
																				<xsl:value-of select='format-number(@arbitrary_value, "###,###,###.00")' />
																			</xsl:when>
																			<xsl:otherwise>
																				<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
																			</xsl:otherwise>
																		</xsl:choose>
																	</xsl:when>
																	<xsl:when test="@answer_type = 'file-upload'">
																		<xsl:choose>
																			<xsl:when test="@arbitrary_value != ''">
																				Downloadable File: <a href="/download?action=download-file&amp;file-type=answer_document&amp;file-name={@arbitrary_value}"><xsl:value-of select="@arbitrary_value" /></a>
																			</xsl:when>
																			<xsl:otherwise>
																				Downloadable File: No file uploaded
																			</xsl:otherwise>
																		</xsl:choose>
																	</xsl:when>
																	<xsl:otherwise><xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:otherwise>
																</xsl:choose>
																<br />
															</xsl:for-each>
														</xsl:when>
														<xsl:otherwise>
															<span class="no-answer">-</span>
														</xsl:otherwise>
													</xsl:choose>
												</div>

											</xsl:for-each>
										</div>
									</div>
								</div>
							</xsl:for-each>
						</div>
					</xsl:if>
				</xsl:for-each>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="client-checklist-compare">

		<div class="row-fluid data-table">
			<div class="table-responsive">
				<table class="table ajax-datatable table-striped dataTable" data-order="-1" data-page-length="-1" data-query-url="{query-data/@url}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}" data-display="{@display}">
				</table>
			</div>
		</div>

	</xsl:template>


	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entry'][@mode='compare']">
		<div class="client-checklist-compare">
			
			<div class="table-responsive">

				<!-- //Get the assessment deails -->
				<div class="gbc-dashboard-answer-report assessment details">
					<div class="row page-title-container">
						<div class="col-xs-12 bg-gray-dark page-title">
							Assessment Details
						</div>
					</div>
					<div class="row question-answer-container">
						<div class="col-xs-4 question">Company Name</div>
						<div class="row col-xs-8 answer">
							<div class="row col-xs-12">
								<xsl:for-each select="clientChecklist">
									<div class="col-xs-4 data-col">
										<xsl:value-of select="@company_name" />
									</div>
								</xsl:for-each>
							</div>
						</div>
					</div>
					<div class="row question-answer-container">
						<div class="col-xs-4 question">Entry</div>
						<div class="row col-xs-8 answer">
							<div class="row col-xs-12">
								<xsl:for-each select="clientChecklist">
									<div class="col-xs-4 data-col">
										<a href="/members/dashboard/entry/view/?client_id={@client_id}&amp;client_checklist_id={@client_checklist_id}">
											<xsl:value-of select="@name" />
										</a>
									</div>
								</xsl:for-each>
							</div>
						</div>
					</div>
					<div class="row question-answer-container">
						<div class="col-xs-4 question">Score</div>
						<div class="row col-xs-8 answer">
							<div class="row col-xs-12">
								<xsl:for-each select="clientChecklist">
									<div class="col-xs-4 data-col">
										<xsl:value-of select="@score" />
									</div>
								</xsl:for-each>
							</div>
						</div>
					</div>
					<div class="row question-answer-container">
						<div class="col-xs-4 question">Started</div>
						<div class="row col-xs-8 answer">
							<div class="row col-xs-12">
								<xsl:for-each select="clientChecklist">
									<div class="col-xs-4 data-col">
										<xsl:value-of select="@start" />
									</div>
								</xsl:for-each>
							</div>
						</div>
					</div>
					<div class="row question-answer-container">
						<div class="col-xs-4 question">Finished</div>
						<div class="row col-xs-8 answer">
							<div class="row col-xs-12">
								<xsl:for-each select="clientChecklist">
									<div class="col-xs-4 data-col">
										<xsl:value-of select="@finish" />
									</div>
								</xsl:for-each>
							</div>
						</div>
					</div>
				</div>

				<xsl:for-each select="page">
					<xsl:if test="count(question[@page_id = current()/@page_id]) &gt; 0">
						<div class="gbc-dashboard-answer-report">
							<div class="row page-title-container">
								<div class="col-xs-12 bg-gray-dark page-title">
									<xsl:if test="@page_section_title != ''">
										<xsl:value-of select="concat(@page_section_title, ' - ')" />
									</xsl:if>
									<xsl:value-of select="@title" />
								</div>
							</div>
							<div class="row question-answer-container">
								<div class="col-xs-4 question header">
									Question
								</div>
								<div class="col-xs-8 answer header">
									Answer
								</div>
							</div>
							<xsl:for-each select="question[@page_id = current()/@page_id]">
								<xsl:variable name="question_id" select="@question_id" />
								
								<div class="row question-answer-container">
									<div class="col-xs-4 question">
										<xsl:value-of select="@question" disable-output-escaping="yes" />
									</div>
									<div class="row col-xs-8 answer">
										<div class="row col-xs-12">
											<xsl:for-each select="../../clientChecklist">
												<xsl:variable name="clientChecklistId" select="@client_checklist_id" />
												<div class="col-xs-4 data-col">
													<xsl:choose>
														<xsl:when test="count(answer[@question_id = $question_id]) &gt; 0">
															<xsl:for-each select="answer[@question_id = $question_id]">
																<xsl:choose>
																	<xsl:when test="@answer_type = 'checkbox' or @answer_type = 'drop-down-list'">
																		<xsl:value-of select="@answer_string" disable-output-escaping="yes" />
																	</xsl:when>
																	<xsl:when test="@answer_type = 'percent'">
																		<xsl:value-of select="@arbitrary_value" />%
																	</xsl:when>
																	<xsl:when test="@answer_type = 'text' or @answer_type = 'textarea'">
																		<xsl:choose>
																			<xsl:when test="string-length(@arbitrary_value) &gt; 100">
																				<span class="collapse in client-result-{$clientChecklistId}-{@answer_id}">
																					<xsl:value-of select="concat(substring(@arbitrary_value,0,97),'...')" disable-output-escaping="yes" />
																				</span>
																				<span class="collapse client-result-{$clientChecklistId}-{@answer_id}">
																					<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
																				</span>
																				<a href=".client-result-{$clientChecklistId}-{@answer_id}" data-toggle="collapse" rel="tooltip" data-original-title="Show/hide content.">
																					<i class="fa fa-info-circle" />
																				</a>
																			</xsl:when>
																			<xsl:otherwise>
																				<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
																			</xsl:otherwise>
																		</xsl:choose>
																	</xsl:when>
																	<xsl:when test="@answer_type = 'checkbox-other'">
																		<xsl:value-of select="@answer_string" disable-output-escaping="yes" />
																		<xsl:text>: </xsl:text>
																		<br /><br />
																		<xsl:choose>
																			<xsl:when test="string-length(@arbitrary_value) &gt; 100">
																				<span class="collapse in client-result-{$clientChecklistId}-{@answer_id}">
																					<xsl:value-of select="concat(substring(@arbitrary_value,0,97),'...')" disable-output-escaping="yes" />
																				</span>
																				<span class="collapse client-result-{$clientChecklistId}-{@answer_id}">
																					<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
																				</span>
																				<a href=".client-result-{$clientChecklistId}-{@answer_id}" data-toggle="collapse" rel="tooltip" data-original-title="Show/hide content.">
																					<i class="fa fa-info-circle" />
																				</a>
																			</xsl:when>
																			<xsl:otherwise>
																				<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
																			</xsl:otherwise>
																		</xsl:choose>
																	</xsl:when>
																	<xsl:when test="@answer_type = 'float'">
																		<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
																	</xsl:when>
																	<xsl:when test="@answer_type = 'file-upload'">
																		<xsl:choose>
																			<xsl:when test="@name != ''">
																				<a href="https://www.greenbizcheck.com/download/?hash={@hash}">
																					<xsl:value-of select="@name" />
																					<xsl:if test="@readable_size !=''">
																						<xsl:value-of select="concat(' (', @readable_size,')')" />
																					</xsl:if>
																				</a>
																			</xsl:when>
																			<xsl:otherwise>
																				No file uploaded
																			</xsl:otherwise>
																		</xsl:choose>
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
																	</xsl:otherwise>
																</xsl:choose>
																<br />
															</xsl:for-each>
														</xsl:when>
														<xsl:otherwise>
															<span class="no-answer">-</span>
														</xsl:otherwise>
													</xsl:choose>
												</div>
											</xsl:for-each>
										</div>
									</div>
								</div>
							</xsl:for-each>
						</div>
					</xsl:if>
				</xsl:for-each>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>