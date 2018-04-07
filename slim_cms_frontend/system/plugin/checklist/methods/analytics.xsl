<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'analytics']">
		<xsl:call-template name="analytics" mode="default" />
	</xsl:template>

	<xsl:variable name="data" select="/config/plugin[@plugin = 'checklist'][@method = 'analytics']" />

	<!-- //Default Analytics Options -->
	<xsl:template name="analytics" mode="default">
		<div class="analytics-api" data-key="{$data/query-data/@key}" data-timestamp="{$data/query-data/@timestamp}" data-hash="{$data/query-data/@hash}" data-mode="{@mode}" data-additional-values="{@additional_values}"/>
		<div class="col-md-12">

			<xsl:variable name="query-cols">
				<xsl:choose>
					<xsl:when test="count(checklists/checklist) &gt; 1">5</xsl:when>
					<xsl:otherwise>10</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="checklist-display">
				<xsl:choose>
					<xsl:when test="count(checklists/checklist) &gt; 1"> </xsl:when>
					<xsl:otherwise> hidden</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- //Form Output -->
			<div class="row padding-bottom-10">
				<form class="form analytics" method="post">
					<input type="hidden" name="client_array" value="{$data/query-data/@client_array}" />
					<input type="hidden" name="client_checklist_array" value="{$data/query-data/@client_checklist_array}" />
					<input type="hidden" name="client_id" value="{$data/query-data/@client_id}" />
					<div class="row">
						<div class="col-md-5{$checklist-display}">
							<select class="chosen-select input-md form-control" name="checklist_id">
								<xsl:if test="count(checklists/checklist) &gt; 1">
									<option value="">-- Choose Entry --</option>
								</xsl:if>
								<xsl:for-each select="checklists/checklist">
									<option value="{@checklist_id}">
										<xsl:if test="/config/globals/item[@key = 'checklist_id']/@value = @checklist_id">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="@name" />
									</option>
								</xsl:for-each>
							</select>
						</div>
						<div class="col-md-{$query-cols}">
							<select class="chosen-select input-md form-control" name="question_id">
								<option value="">-- Choose Query --</option>
							</select>
						</div>
						<div class="col-md-2">
							<a href="#" class="btn btn-base btn-icon fa-paper-plane col-md-12 margin-top-7" data-action="get-analytics">
		                      <span>Get Results</span>
		                    </a>
						</div>
					</div>
				</form>
			</div>
		</div>

		<xsl:choose>
			<xsl:when test="@mode = 'benchmark'">
				<xsl:call-template name="analytics-chart" />
				<xsl:call-template name="analytics-benchmark" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="analytics-chart" />
				<xsl:call-template name="analytics-datatable" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<!-- //Analytics Chart -->
	<xsl:template name="analytics-chart">
		<div class="row padding-bottom-10">

			<div class="col-md-12">

				<xsl:variable name="height">
					<xsl:choose>
						<xsl:when test="$data/@height">
							<xsl:value-of select="$data/@height" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>10</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="width">
					<xsl:choose>
						<xsl:when test="$data/@width">
							<xsl:value-of select="$data/@width" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>30</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<div class="analytics chartjs">
					<div class="col-md-12 text-center">
						<strong>Click on the legend boxes to selectively view or hide different sections.</strong>
					</div>
					<canvas class="chartjs" data-query-id="" data-key="{$data/query-data/@key}" data-timestamp="{$data/query-data/@timestamp}" data-hash="{$data/query-data/@hash}" width="{$width}" height="{$height}" data-type="{$data/@type}" data-colors="{$data/@colors}" data-data-options="{$data/@data-options}" data-chart-options="{$data/@chart-options}">
					</canvas>
				</div>

			</div>
		</div>
	</xsl:template>

	<!-- //Analytics Data Table -->
	<xsl:template name="analytics-datatable">
		<div class="row">

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

			<div class="analytics row-fluid data-table">
				<div class="col-md-12">
					<div class="table-responsive">
						<table class="table analytics datatable table-striped dataTable" data-order="[]" data-page-length="{$default-rows}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}" data-display="analytics-table">
							<thead>
								<tr>
									<th scope="col">Entry</th>
									<th scope="col">Query</th>
									<th scope="col">Period</th>
									<th scope="col">Response</th>
								</tr>
							</thead>
						</table>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- //Analytics Benchmark -->
	<xsl:template name="analytics-benchmark">
		<div class="analytics benchmark">
			<table class="table table-striped table-bordered"></table>
		</div>
	</xsl:template>

</xsl:stylesheet>