<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">
	
	<!-- //Client Checklist Table -->
	<xsl:template match="/config/plugin[@plugin='checklist'][@method='getAllEntries']">

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
									<th scope="col">Entry</th>
									<th scope="col">Period</th>
									<th scope="col">Status</th>
								</xsl:otherwise>
							</xsl:choose>
						</tr>
					</thead>
				</table>
			</div>
		</div>
	</xsl:template>
		
</xsl:stylesheet>