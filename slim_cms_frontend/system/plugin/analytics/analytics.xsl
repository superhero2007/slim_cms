<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">
	
	<xsl:template match="/config/plugin[@plugin = 'analytics'][@method = 'analytics']">

		<xsl:call-template name="analytics-form" />

	</xsl:template>

	<xsl:template name="analytics-form">
		<div class="load-entry-container">

			<form method="post" action="" class="form-horizontal" id="entry-form" data-parsley-validate="data-parsley-validate" novalidate="novalidate" data-parsley-excluded="[disabled]">

				<div class="row">

					<!-- //From -->
					<div class="col-md-6">
						<div class="row">
							<div class="col-md-12">
								<label class="entry question-content">Data Type</label>
							</div>
							<div class="col-md-12 entry question">
								<div class="input-group date date-time-picker day">
									<input type="text" name="date-range-from" value="" class="form-control" />
									<span class="input-group-addon">
					                	<span class="fa fa-calendar"></span>
					             	</span>
				             	</div>
							</div>
						</div>
					</div>

				</div>

				<div class="row">

					<!-- //From -->
					<div class="col-md-3">
						<div class="row">
							<div class="col-md-12">
								<label class="entry question-content">From</label>
							</div>
							<div class="col-md-12 entry question">
								<div class="input-group date date-time-picker day">
									<input type="text" name="date-range-from" value="" class="form-control" />
									<span class="input-group-addon">
					                	<span class="fa fa-calendar"></span>
					             	</span>
				             	</div>
							</div>
						</div>
					</div>

					<!-- //TO -->
					<div class="col-md-3">
						<div class="row">
							<div class="col-md-12">
								<label class="entry question-content">To</label>
							</div>
							<div class="col-md-12 entry question">
								<div class="input-group date date-time-picker day">
									<input type="text" name="date-range-to" value="" class="form-control" />
									<span class="input-group-addon">
					                	<span class="fa fa-calendar"></span>
					             	</span>
				             	</div>
							</div>
						</div>
					</div>
				</div>

			</form>
		</div>
	</xsl:template>

</xsl:stylesheet>