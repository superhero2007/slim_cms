<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- //Include methods -->
	<xsl:include href="methods/david-jones.xsl" />

	<!-- //Filter HTML match -->
	<xsl:template match="filter" mode="html">
		<xsl:call-template name="filter" />
	</xsl:template>

	<!-- //Filter -->
	<xsl:template name="filter">
		<div class="filter-results">
			<xsl:call-template name="filter-button" />
			<div class="filter-container collapse">
				<div class="filters">
				</div>
				<div class="template hidden">
					<xsl:call-template name="filter-row" />
				</div>
				<div class="controls">
					<xsl:call-template name="filter-control-buttons" />
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- //Filter Button -->
	<xsl:template name="filter-button">
		<div class="row">
			<div class="col-md-3 col-md-offset-9 ">
				<button class="btn btn-primary btn-block pull-right" data-toggle="collapse" data-target=".filter-results .filter-container">
					Filters
				</button>
			</div>
		</div>
	</xsl:template>

	<!-- //Control Buttons -->
	<xsl:template name="filter-control-buttons">
		<div class="row">
			<div class="col-md-3 col-md-offset-3">
				<button class="btn btn-primary btn-block add-filter">
					Add Filter
				</button>
			</div>
			<div class="col-md-3">
				<button class="btn btn-success btn-block apply-filter">
					Apply Filter
				</button>
			</div>
		</div>
	</xsl:template>

	<!-- //Filter Row -->
	<xsl:template name="filter-row">
		<div class="row filter-row">
			<fieldset disabled="disabled">
				<div class="col-md-4">
					<div class="row">
						<div class="col-md-2">
							<p class="comparator">AND</p>
						</div>
						<div class="col-md-10">
							<div class="form-group">
								<label class="field">Data source</label>
								<input type="email" class="form-control" placeholder="Email" />
							</div>
						</div>
					</div>
				</div>
				<div class="col-md-4">
					<div class="form-group">
						<label class="field">Query</label>
						<input type="email" class="form-control" placeholder="Email" />
					</div>
				</div>
				<div class="col-md-4">
					<div class="row">
						<div class="col-md-10">
							<div class="form-group">
								<label class="field">Value</label>
								<input type="email" class="form-control" placeholder="Email" />
							</div>
						</div>
						<div class="col-md-2">
							<button class="btn btn-danger delete-filter">
								<i class="fa fa-trash" />
							</button>
						</div>
					</div>
				</div>
			</fieldset>
		</div>
	</xsl:template>
	
</xsl:stylesheet>