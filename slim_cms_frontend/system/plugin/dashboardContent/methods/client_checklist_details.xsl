<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">
	
	<!-- All Client Details for the dashboard -->
	<xsl:variable name="clientChecklist" select="(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@client_id = $client_id] | /config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/client_checklist[@client_id = $client_id])" />

	<xsl:template match="client-checklist-name" mode="html">
		<xsl:value-of select="$clientChecklist/@name" />
	</xsl:template>

	<xsl:template name="client-checklist-export-answers-button">
        <a href="?client_id={$clientChecklist/@client_id}&amp;client_checklist_id={$clientChecklist/@client_checklist_id}&amp;action=export-answers" class="mb-sm btn btn-labeled btn-inverse bg-inverse-light form-control height-control">
        	<span class="btn-label pull-left"><i class="fa fa-download"></i></span>
			Export Answers
		</a>
	</xsl:template>

	<xsl:template name="client-checklist-reopen-assessment-button">
        <a href="?client_id={$clientChecklist/@client_id}&amp;client_checklist_id={$clientChecklist/@client_checklist_id}&amp;action=reopen-assessment" class="mb-sm btn btn-labeled btn-inverse bg-inverse-light form-control height-control">
        	<span class="btn-label pull-left"><i class="fa fa-undo"></i></span>
            Re-open Assessment
		</a>
	</xsl:template>

	<!-- //Client Checklist Action bar -->
	<xsl:template match="client-checklist-action-bar" mode="html">
		<xsl:param name="buttons" select="@buttons" />

		<xsl:choose>
			<xsl:when test="$buttons = 'export-reopen'">
				<div class="row">
			      <div class="form-group">
			        <div class="col-md-4 col-md-offset-2">
			        	<xsl:call-template name="client-checklist-export-answers-button" />
			        </div>
			        <div class="col-md-4">
			        	<xsl:call-template name="client-checklist-reopen-assessment-button" />
			        </div>
			      </div>
			    </div>
			</xsl:when>
			<xsl:when test="$buttons = 'export'">
				<div class="row">
			      <div class="form-group">
			        <div class="col-md-4 col-md-offset-4">
			        	<xsl:call-template name="client-checklist-export-answers-button" />
			        </div>
			      </div>
			    </div>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<!-- // ClientChecklist -->
	<xsl:template match="client-checklist-query" mode="html">
		<xsl:param name="attribute" select="@attribute" />

		<xsl:choose>
			<xsl:when test="$attribute = 'started_date'">
				<xsl:choose>
					<xsl:when test="$clientChecklist/@started_date = ''">
						N/A
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$clientChecklist/@started_date" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$attribute = 'completed_date'">
				<xsl:choose>
					<xsl:when test="$clientChecklist/@completed_date = ''">
						N/A
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$clientChecklist/@completed_date" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$attribute = 'date_range_start_month_year'">
				<xsl:choose>
					<xsl:when test="$clientChecklist/@date_range_start_month = ''">
						N/A
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($clientChecklist/@date_range_start_month, ' ', $clientChecklist/@date_range_start_year)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$attribute = 'status'">
				<xsl:choose>
					<xsl:when test="$clientChecklist/@completed = ''">
						Open
					</xsl:when>
					<xsl:otherwise>
						Submitted
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$attribute = 'last_active'">
				<xsl:choose>
					<xsl:when test="$clientChecklist/@last_active_pretty = ''">
						N/A
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$clientChecklist/@last_active_pretty" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$attribute = 'progress'">
				<xsl:value-of select="$clientChecklist/@progress" />%
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="client-checklist-answer-report" mode="html">
		<xsl:call-template name="client-checklist-answer-report-grid" />
	</xsl:template>

	<xsl:template match="client-checklist-answer-value" mode="html">
		<xsl:call-template name="client-checklist-answer-value">
			<xsl:with-param name="question_id" select="@question_id" />
			<xsl:with-param name="prepend" select="@prepend" />
			<xsl:with-param name="append" select="@append" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="client-checklist-answer-value">
		<xsl:param name="question_id" select="@question_id" />
		<xsl:variable name="answer_id" select="$clientChecklist/client_result[@question_id = $question_id]/@answer_id" />

		<xsl:if test="$clientChecklist/answer[@answer_id = $answer_id]/@string != ''">
			<xsl:value-of select="@prepend" />
			<xsl:value-of select="$clientChecklist/answer[@answer_id = $answer_id]/@string" />
			<xsl:value-of select="@append" />
		</xsl:if>
	</xsl:template>

	<!-- //Overall Score Current Rate -->
	<xsl:template name="dashboard-category-score-current-rate">
		<xsl:param name="reportSectionId" />
		<xsl:variable name="points" select="sum($clientChecklist/reportSection[@report_section_id = $reportSectionId]/@points)" />
		<xsl:variable name="demerits" select="sum($clientChecklist/reportSection[@report_section_id = $reportSectionId]/@demerits)" />
		<xsl:variable name="merits" select="sum($clientChecklist/reportSection[@report_section_id = $reportSectionId]/@merits)" />
		<xsl:variable name="current_rate" select="($points - $demerits + $merits) div $points" />

		<div class="col-md-4">
			<div class="dashboard-report-progress-bar-title">
				<xsl:value-of select="$clientChecklist/reportSection[@report_section_id = $reportSectionId]/@title" />
			</div>
		</div>
		<div class="col-md-8">
			<div class="progress dashboard-report-progress-bar">
			  <div class="progress-bar dashboard-report-progress-bar bg-success progress-bar-striped current-score" role="progressbar" aria-valuenow="{$current_rate * 100}" aria-valuemin="0" aria-valuemax="100" style="min-width: 2em; width:{floor($current_rate * 100)}%">
				<xsl:value-of select="floor($current_rate * 100)" />%
			  </div>
			</div>
		</div>

	</xsl:template>

	<!-- //Tag Flag Answer Report -->
	<xsl:template match="tag-flag-answer-report" mode="html">
	</xsl:template>

	<!-- //Category Scores Current Rate HTML template -->
	<xsl:template match="category-scores-current-rate" mode="html">
		<xsl:for-each select="$clientChecklist/reportSection[@points &gt; 0]">
			<xsl:call-template name="dashboard-category-score-current-rate" >
				<xsl:with-param name="reportSectionId" select="@report_section_id" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="client-checklist-answer-report">

		<xsl:for-each select="$clientChecklist/checklistPage">
			<xsl:if test="count($clientChecklist/client_result[@page_id = current()/@page_id]) &gt; 0">
				<div class="table-responsive gbc-data-table answer-report">
					<table class="table table-striped">
						<tbody>
							<tr>
								<th scope="col" colspan="2" class="bg-gray-dark">
									<xsl:if test="@page_section_title != ''">
										<xsl:value-of select="concat(@page_section_title, ' - ')" />
									</xsl:if>
									<xsl:value-of select="@title" />
								</th>
							</tr>
							<tr>
								<th scope="col">Question</th>
								<th scope="col">Answer</th>
							</tr>
							<xsl:for-each select="$clientChecklist/question[@page_id = current()/@page_id]">
								<xsl:sort select="@sequence" data-type="number" />
								
								<xsl:if test="count($clientChecklist/client_result[@page_id = current()/@page_id]) &gt; 0">
									<!-- //Check to see if the answer_type is a text area, if so break over 2 rows -->
									<xsl:choose>
										<xsl:when test="$clientChecklist/client_result[@question_id = current()/@question_id]/@answer_type = 'textarea'">
											<tr>
												<td colspan="2" class="question">
													<xsl:value-of select="@question" disable-output-escaping="yes" />
												</td>
											</tr>
											<tr>
												<td colspan="2" class="answer">
													<xsl:for-each select="$clientChecklist/client_result[@question_id = current()/@question_id]">
														<xsl:choose>
															<xsl:when test="@answer_type = 'checkbox' or @answer_type= 'drop-down-list'"><xsl:value-of select="$clientChecklist/answer[@answer_id = current()/@answer_id]/@string" disable-output-escaping="yes" /></xsl:when>
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
																<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
															</xsl:when>
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
																Downloadable File: <a href="/download?action=download-file&amp;file-type=answer_document&amp;file-name={@arbitrary_value}"><xsl:value-of select="@arbitrary_value" /></a>
															</xsl:when>
															<xsl:otherwise><xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:otherwise>
														</xsl:choose>
														<br /><br /></xsl:for-each>
												</td>
											</tr>
										</xsl:when>
										<xsl:otherwise>
											<tr>
												<td class="question">
													<xsl:value-of select="@question" disable-output-escaping="yes" />
												</td>
												<td class="answer">
													<xsl:for-each select="$clientChecklist/client_result[@question_id = current()/@question_id]">
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
																<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
															</xsl:when>
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
																Downloadable File: <a href="/download?action=download-file&amp;file-type=answer_document&amp;file-name={@arbitrary_value}"><xsl:value-of select="@arbitrary_value" /></a>
															</xsl:when>
															<xsl:otherwise><xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:otherwise>
														</xsl:choose>
														<br />
													</xsl:for-each>
												</td>
											</tr>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
							</xsl:for-each>

							<!-- //Client Page Note / Comment -->
							<xsl:if test="@note != ''">
								<tr>
									<th scope="col" colspan="2">Client Comment/Note</th>
								</tr>
								<tr>
									<td colspan="2"><xsl:value-of select="@note" /></td>
								</tr>	
							</xsl:if>

						</tbody>
					</table>
				</div>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- //Client Checklist Answer Report - Grid Based Layout -->
	<xsl:template name="client-checklist-answer-report-grid">

		<xsl:for-each select="$clientChecklist/checklistPage">
			<xsl:if test="count($clientChecklist/client_result[@page_id = current()/@page_id]) &gt; 0">
				<div class="gbc-dashboard-answer-report">
					<div class="page-title-container">
						<div class="col-md-12 bg-gray-dark page-title">
							<xsl:if test="@page_section_title != ''">
								<xsl:value-of select="concat(@page_section_title, ' - ')" />
							</xsl:if>
							<xsl:value-of select="@title" />
						</div>
					</div>
					<div class="question-answer-container">
						<div class="col-md-8 question header">
							Question
						</div>
						<div class="col-md-4 answer header">
							Answer
						</div>
					</div>
					<xsl:for-each select="$clientChecklist/question[@page_id = current()/@page_id]">
						<xsl:sort select="@sequence" data-type="number" />
						
						<xsl:if test="count($clientChecklist/client_result[@page_id = current()/@page_id]) &gt; 0">
							<!-- //Check to see if the answer_type is a text area, if so break over 2 rows -->
							<xsl:choose>
								<xsl:when test="$clientChecklist/client_result[@question_id = current()/@question_id]/@answer_type = 'textarea'">

									<div class="question-answer-container">
										<div class="col-md-12 question single-row">
											<xsl:value-of select="@question" disable-output-escaping="yes" />
										</div>
										<div class="col-md-12 answer single-row">
											<xsl:for-each select="$clientChecklist/client_result[@question_id = current()/@question_id]">
												<xsl:choose>
													<xsl:when test="@answer_type = 'checkbox' or @answer_type= 'drop-down-list'"><xsl:value-of select="$clientChecklist/answer[@answer_id = current()/@answer_id]/@string" disable-output-escaping="yes" /></xsl:when>
													<xsl:when test="@answer_type = 'percent'"><xsl:value-of select="@arbitrary_value" />%</xsl:when>
													<xsl:when test="@answer_type = 'text' or @answer_type = 'textarea'">
														<xsl:if test="$clientChecklist/answer[@answer_id = current()/@answer_id]/@string!= ''">
															<xsl:value-of select="concat($clientChecklist/answer[@answer_id = current()/@answer_id]/@string, ': ')" />
														</xsl:if>
														<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
													</xsl:when>
														<xsl:value-of select="$clientChecklist/answer[@answer_id = current()/@answer_id]/@string" disable-output-escaping="yes" />
														<xsl:text>: </xsl:text>
														<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
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
												<br /><br />
											</xsl:for-each>
										</div>
									</div>
								</xsl:when>
								<xsl:otherwise>
									<div class="question-answer-container">
										<div class="col-md-8 question">
											<xsl:value-of select="@question" disable-output-escaping="yes" />
										</div>
										<div class="col-md-4 answer">
											<xsl:for-each select="$clientChecklist/client_result[@question_id = current()/@question_id]">
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
														<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
													</xsl:when>
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
										</div>
									</div>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</xsl:for-each>

					<!-- //Client Page Note / Comment -->
					<xsl:if test="@note != ''">
						<div class="question-answer-container">
							<div class="col-md-12 question header single-row">
								Client Comment/Note
							</div>
							<div class="col-md-12 answer">
								<xsl:value-of select="@note" />
							</div>
						</div>
					</xsl:if>

				</div>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>