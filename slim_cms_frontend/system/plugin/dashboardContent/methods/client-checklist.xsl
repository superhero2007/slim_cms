<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<!-- //Client Checklist Table -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entry'][@mode='list']">

		<xsl:choose>
			<xsl:when test="/config/queryPath/variable[last()]/text() = 'compare'">
				<xsl:call-template name="client-checklist-compare" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="client-checklist" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="client-checklist">
		<xsl:variable name="order-by">
			<xsl:choose>
				<xsl:when test="@order-by">
					<xsl:value-of select="@order-by" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="order-direction">
			<xsl:choose>
				<xsl:when test="@order-direction">
					<xsl:value-of select="@order-direction" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>asc</xsl:text>
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
				<form class="dashboard form" method="post">
					<table class="table ajax-datatable table-striped dataTable" data-order="[[{$order-by},&quot;{$order-direction}&quot;]]" data-page-length="{$default-rows}" data-query-id="{query-data/@query}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}" data-display="{@display}">
						<thead>
							<tr>
								<th>
									<input type="checkbox" name="row-index-toggle" data-status="off" />
								</th> <!-- //Checkbox Column -->
								<xsl:choose>
									<xsl:when test="columns/column">
										<xsl:for-each select="columns/column">
											<th scope="col">
												<xsl:value-of select="@name" />
											</th>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<th scope="col">Entity</th>
										<th scope="col">Entry</th>
									</xsl:otherwise>
								</xsl:choose>
							</tr>
						</thead>
					</table>

					<!-- //Action -->
					<xsl:choose>
						<xsl:when test="/config/plugin[@plugin='clients'][@method='login']/client/dashboard/@dashboard_role_id &lt; 3">
							<div class="row">
								<div class="col-md-12">
									<div class="row">
										<div class="col-md-3">
											<div class="select drop-down-list">
												<select class="form-control" name="action">
													<option value="">-- Choose Action --</option>
													<option value="entry-open" data-type="action">Set as Open</option>
													<option value="entry-closed" data-type="action">Set as Closed</option>
													<option value="entry-locked" data-type="action">Set as Locked</option>
													<option value="entry-archived" data-type="action">Set as Archived</option>
												</select>
											</div>
										</div>
										<div class="col-md-3">
											<button type="button" class="btn btn-labeled btn-primary btn-block dashboard-button action">
												<span class="btn-label pull-left">
													<i class="fa fa-paper-plane"></i>
												</span>
												Apply Action
											</button>
										</div>
										<xsl:if test="param[@name = 'compare']/@value = 'true'">
											<div class="col-md-3">
												<xsl:call-template name="button-compare" />
											</div>
										</xsl:if>
									</div>
								</div>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="param[@name = 'compare']/@value = 'true'">
								<div class="row">
									<div class="col-md-12">
										<div class="row">
											<div class="col-md-3">
												<xsl:call-template name="button-compare" />
											</div>
										</div>
									</div>
								</div>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</form>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="button-compare">
		<button type="button" class="btn btn-labeled btn-success btn-block dashboard-button action" data-type="compare">
			<span class="btn-label pull-left">
				<i class="fa fa-balance-scale"></i>
			</span>
			Compare Items
		</button>
	</xsl:template>

	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entryContent'][@mode='metrics']">

		<xsl:variable name="order-by">
			<xsl:choose>
				<xsl:when test="@order-by">
					<xsl:value-of select="@order-by" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="order-direction">
			<xsl:choose>
				<xsl:when test="@order-direction">
					<xsl:value-of select="@order-direction" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>asc</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="default-rows">
			<xsl:choose>
				<xsl:when test="@default-rows">
					<xsl:value-of select="@default-rows" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>-1</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="row-fluid data-table">
			<div class="table-responsive">
				<table class="table ajax-datatable table-striped dataTable" data-order="[[{$order-by},&quot;{$order-direction}&quot;]]" data-page-length="{$default-rows}" data-query-id="{query-data/@query}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}" data-display="{@display}">
					<thead>
						<tr>
							<th scope="col">Metric Group</th>
							<th scope="col">Metric</th>
							<th scope="col">Value</th>
							<th scope="col">Metric Unit</th>
						</tr>
					</thead>
				</table>
			</div>
		</div>
	</xsl:template>


	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='clientResults'][@mode='metrics']">

		<xsl:variable name="order-by">
			<xsl:choose>
				<xsl:when test="@order-by">
					<xsl:value-of select="@order-by" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="order-direction">
			<xsl:choose>
				<xsl:when test="@order-direction">
					<xsl:value-of select="@order-direction" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>asc</xsl:text>
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
				<table class="table ajax-datatable table-striped dataTable" data-order="[[{$order-by},&quot;{$order-direction}&quot;]]" data-page-length="{$default-rows}" data-query-id="{query-data/@query}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}" data-display="{@display}">
					<thead>
						<tr>
							<th scope="col">Entered</th>
							<th scope="col">Entity</th>
							<th scope="col">Metric Group</th>
							<th scope="col">Metric</th>
							<th scope="col">Value</th>
							<th scope="col">Metric Unit</th>
							<th scope="col">Period</th>
						</tr>
					</thead>
				</table>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='clientResults'][@mode='entry_results']">

		<xsl:variable name="order-by">
			<xsl:choose>
				<xsl:when test="@order-by">
					<xsl:value-of select="@order-by" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="order-direction">
			<xsl:choose>
				<xsl:when test="@order-direction">
					<xsl:value-of select="@order-direction" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>asc</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="default-rows">
			<xsl:choose>
				<xsl:when test="@default-rows">
					<xsl:value-of select="@default-rows" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>-1</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="row-fluid data-table">
			<div class="table-responsive">
				<table class="table ajax-datatable table-striped dataTable entry_results" data-order="[[{$order-by},&quot;{$order-direction}&quot;]]" data-page-length="{$default-rows}" data-query-id="{query-data/@query}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}" data-display="{@display}">
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
									<th scope="col">Answer</th>
								</xsl:otherwise>
							</xsl:choose>
						</tr>
					</thead>
				</table>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="client-checklist-name" mode="html">
		<xsl:value-of select="/config/plugin[@plugin='dashboardContent'][@method='loadContent']/client_checklist/@name" />
	</xsl:template>

	<!-- //Add Entry -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entry'][@mode='add']">
		<p>Test</p>
	</xsl:template>

	<!-- //Action Plan -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='actionPlan']">

		<div class="action-plan">

		<xsl:for-each select="reportSection[@display_in_html = '1'][@points &gt; 0]">
			<xsl:sort select="@sequence" data-type="number" />

			<xsl:variable name="reportSectionPosition" select="position()" />

			<!-- //Title -->
			<div class="row">
				<div class="col-md-12">
					<h4 class="report-section-title">
						<xsl:value-of select="@title" />
					</h4>
				</div>
			</div>

			<div class="row">
				<div class="col-md-6 actions">
					<!-- //Actions -->
					<div class="row">
						<div class="col-md-12 text-center">
							<i class="fa fa-question-circle fa-5x" />
						</div>
					</div>
					<div class="row">
						<div class="col-md-12 text-center">
							<h4 class="title">What can be done</h4>
						</div>
					</div>
					<div class="row">
						<div class="col-md-12">
							<xsl:choose>
								<xsl:when test="count(action[@commitment_id = 0]) &gt; 0">
									<ul>
										<xsl:for-each select="action[@commitment_id = 0]">
											<xsl:sort select="@sequence" data-type="number" />
											<li>
												<span class="item-number">
													<xsl:value-of select="concat($reportSectionPosition, '.', position())" />
												</span>
												<xsl:choose>
													<xsl:when test="@title != ''">
														<xsl:value-of select="@title" />
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="@summary" />
													</xsl:otherwise>
												</xsl:choose>
											</li>
										</xsl:for-each>
									</ul>
								</xsl:when>
								<xsl:otherwise>
									<p>There are no actions to implement.</p>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</div>
				<div class="col-md-6 confirmations">
					<div class="row">
						<div class="col-md-12 text-center">
							<i class="fa fa-check-circle fa-5x" />
						</div>
					</div>
					<div class="row">
						<div class="col-md-12 text-center">
							<h4 class="title">What is being done</h4>
						</div>
					</div>
					<div class="row">
						<div class="col-md-12">
							<!-- //Confirmations -->
							<ul>
								<xsl:for-each select="confirmation">
									<li>
										<i class="fa fa-check success"></i>
										<xsl:value-of select="@confirmation" />
									</li>
								</xsl:for-each>
								<!-- //Commitments -->
								<xsl:for-each select="action[@commitment_id != 0]">
									<xsl:sort select="@sequence" data-type="number" />
									<li>
										<i class="fa fa-check success"></i>
										<xsl:value-of select="commitment[@commitment_id = current()/@commitment_id]/@commitment" />
									</li>
								</xsl:for-each>
							</ul>
						</div>
					</div>
				</div>
			</div>

			<hr />
		</xsl:for-each>

		</div>

	</xsl:template>
		
</xsl:stylesheet>