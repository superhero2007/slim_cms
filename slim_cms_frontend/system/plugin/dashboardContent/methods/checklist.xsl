<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<!-- //Client Checklist Table -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entry'][@mode='emission_factors_list']">

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
								<xsl:choose>
									<xsl:when test="columns/column">
										<xsl:for-each select="columns/column">
											<th scope="col">
												<xsl:value-of select="@name" />
											</th>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<th scope="col">Category</th>
										<th scope="col">Sub Category</th>
										<th scope="col">Key</th>
										<th scope="col">Factor</th>
										<th scope="col">Unit</th>
										<th scope="col">Default Unit</th>
									</xsl:otherwise>
								</xsl:choose>
							</tr>
						</thead>
					</table>

				</form>
			</div>
		</div>
	</xsl:template>

	<!-- //Client Checklist Table -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entry'][@mode='entry_answer_functions']">

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
								<xsl:choose>
									<xsl:when test="columns/column">
										<xsl:for-each select="columns/column">
											<th scope="col">
												<xsl:value-of select="@name" />
											</th>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<th scope="col">Type</th>
										<th scope="col">Field</th>
										<th scope="col">Equation</th>
									</xsl:otherwise>
								</xsl:choose>
							</tr>
						</thead>
					</table>

				</form>
			</div>
		</div>
	</xsl:template>


	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entry'][@mode='entry_variation']">
		
		<xsl:variable name="order-by">
			<xsl:choose>
				<xsl:when test="@order-by">
					<xsl:value-of select="@order-by" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>7</xsl:text>
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
									<th scope="col">Entity</th>
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

	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entry'][@mode='entry_validation']">
		
		<xsl:variable name="order-by">
			<xsl:choose>
				<xsl:when test="@order-by">
					<xsl:value-of select="@order-by" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>8</xsl:text>
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
				<table class="table table-striped data-table static" data-order="[[{$order-by},&quot;{$order-direction}&quot;]]" data-page-length="{$default-rows}" data-display="{@display}" data-query-id="{query-data/@query}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}">
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
									<th scope="col">Entity</th>
									<th scope="col">Section</th>
									<th scope="col">Question</th>
									<th scope="col">Current Period</th>
									<th scope="col">Current Value</th>
									<th scope="col">Previous Period</th>
									<th scope="col">Previous Value</th>
									<th scope="col">Change</th>
									<th scope="col">Change (%)</th>
									<th scope="col">Reason</th>
									<th scope="col">Explanation</th>
								</xsl:otherwise>
							</xsl:choose>
						</tr>
					</thead>

					<tbody>
						<xsl:for-each select="validations/validation">
							<tr>
								<td>
									<xsl:value-of select="@company_name" />
								</td>
								<td>
									<xsl:value-of select="concat(@section, ' &gt; ', @page)" />
								</td>
								<td>
									<xsl:value-of select="@question" />
								</td>
								<td>
									<xsl:value-of select="@current_period" />
								</td>
								<td>
									<xsl:value-of select="@current_response" />
								</td>
								<td>
									<xsl:value-of select="@previous_period" />
								</td>
								<td>
									<xsl:value-of select="@previous_response" />
								</td>
								<td>
									<xsl:value-of select="@difference" />
								</td>
								<td>
									<xsl:value-of select="@percent" />
								</td>
								<td>
									<xsl:value-of select="@validation" />
								</td>
								<td>
									<xsl:value-of select="@reason" />
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
		</div>

	</xsl:template>

</xsl:stylesheet>