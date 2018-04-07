<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">
	
	<!-- //Metric List -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entryContent'][@mode = 'metric-list']">

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
								<th></th>
								<th scope="col">Metric</th>
								<th scope="col">Metric Group</th>
								<th scope="col">Default Unit</th>
								<th scope="col">Other Units</th>
							</tr>
						</thead>
					</table>

					<!-- //Action -->
					<xsl:if test="/config/plugin[@plugin='clients'][@method='login']/client/dashboard/@dashboard_role_id &lt; 3">
						<div class="row">
							<div class="col-md-2">
								<div class="select drop-down-list">
									<select class="form-control" name="action">
										<option value="">-- Choose Action --</option>
										<option value="metric-delete">Delete Metric</option>
									</select>
								</div>
							</div>
							<div class="col-md-2">
								<button type="button" class="btn btn-labeled btn-primary dashboard-button action">
                           			<span class="btn-label">
                           				<i class="fa fa-paper-plane"></i>
                           			</span>
                           			Apply Action
                           		</button>
							</div>
							<div class="col-md-8">
							</div>
						</div>
					</xsl:if>

				</form>
			</div>
		</div>
	</xsl:template>

	<!-- //Metric List -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entry'][@mode = 'client_metric_results']">

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
					<table class="table ajax-datatable table-striped dataTable" data-order="[[ 2, &quot;desc&quot; ]]" data-page-length="{$default-rows}" data-query-id="{query-data/@query}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}" data-display="{@display}">
						<thead>
							<tr>
								<th scope="col">Entity</th>
								<th scope="col">Period</th>
								<th scope="col">Date</th>
								<th scope="col">Metric Group</th>
								<th scope="col">Metric</th>
								<th scope="col">Value</th>
								<th scope="col">Unit</th>
								<th scope="col">Default Value</th>
								<th scope="col">Default Unit</th>
								<th scope="col">Justification</th>
								<th scope="col">Comment</th>
							</tr>
						</thead>
					</table>

				</form>

			</div>
		</div>
	</xsl:template>

	<!-- //Metric Emissions -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entry'][@mode = 'client_metric_emissions']">

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
		
		<xsl:variable name="order-by">
			<xsl:choose>
				<xsl:when test="@order-by">
					<xsl:value-of select="@order-by" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>2</xsl:text>
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

		<div class="row-fluid data-table">
			<div class="table-responsive">
				<form class="dashboard form" method="post">
					<table class="table ajax-datatable table-striped dataTable" data-order="[[{$order-by},&quot;{$order-direction}&quot;]]" data-page-length="{$default-rows}" data-query-id="{query-data/@query}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}" data-display="{@display}">
						<thead>
							<tr>
								<th scope="col">Entity</th>
								<th scope="col">Period</th>
								<th scope="col">Date</th>
								<th scope="col">Value</th>
								<th scope="col">Unit</th>
								<th scope="col">Category</th>
								<th scope="col">Type</th>
								<th scope="col">Scope</th>
							</tr>
						</thead>
					</table>

				</form>

			</div>
		</div>
	</xsl:template>
		
</xsl:stylesheet>