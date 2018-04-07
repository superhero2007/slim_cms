<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

    <xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='import']">
		<xsl:call-template name="data-import-form" />
    </xsl:template>

    <!-- //Data Import Form -->
	<xsl:template name="data-import-form">

		<form method="post" action="" class="form-horizontal" id="data-import-form" data-parsley-validate="data-parsley-validate" novalidate="novalidate" data-parsley-excluded="[disabled]">
			<input type="hidden" name="action" value="data-import" />

			<div class="entry page api import" data-url="{/config/domain/@gbc_api}">

				<div class="input-panel">

					<!-- //Client Type ID -->
					<div class="row">
						<div class="col-md-12 question client_type">
							<fieldset class="entry question">
								<div class="row">
									<div class="col-md-12">
										<label class="entry question-content">1. Select Client Type
											<span class="required-question text-danger error">*</span>
										</label>
										<div class="select drop-down-list">
											<select class="form-control" data-parsley-required="required" name="client_type_id">
												<option>-- Select --</option>
											</select>
											<i></i>
										</div>
									</div>
								</div>
							</fieldset>
						</div>
					</div>

					<!-- //Checklist ID -->
					<div class="row">
						<div class="col-md-12 question checklist">
							<fieldset class="entry question">
								<div class="row">
									<div class="col-md-12">
										<label class="entry question-content">2. Select Entry
											<span class="required-question text-danger error">*</span>
										</label>
										<div class="select drop-down-list">
											<select class="form-control" data-parsley-required="required" name="checklist_id">
												<option>-- Select --</option>
											</select>
											<i></i>
										</div>
									</div>
								</div>
							</fieldset>
						</div>
					</div>

					<!-- //Import Profile ID -->
					<div class="row">
						<div class="col-md-12 question profile">
							<fieldset class="entry question">
								<div class="row">
									<div class="col-md-12">
										<label class="entry question-content">3. Select Import Profile
											<span class="required-question text-danger error">*</span>
										</label>
										<div class="select drop-down-list">
											<select class="form-control" data-parsley-required="required" name="import_profile_id">
												<option>-- Select --</option>
											</select>
											<i></i>
										</div>
									</div>
								</div>
							</fieldset>
						</div>
					</div>

					<!-- //Upload File -->
					<div class="row">
						<div class="col-md-12 question data-file">
							<fieldset class="entry question">
								<div class="row">
									<div class="col-md-12">
										<label class="entry question-content">4. Select Data File
											<span class="required-question text-danger error">*</span>
										</label>
										<input type="file" id="data-file" accept=".csv,.xls,.xlsx" />
									</div>
								</div>
							</fieldset>
						</div>
					</div>

					<!-- //Start Import Button -->
					<div class="row">
						<div class="col-md-12 question data-file">
							<fieldset class="entry question">
								<div class="row">
									<div class="col-md-12">
										<button type="button" class="btn btn-success start-import">Start Import</button>
									</div>
								</div>
							</fieldset>
							<hr />
						</div>
					</div>
				</div>

				<div class="result-panel">
					<!-- //Import Progress Bar -->
					<div class="row">
						<div class="col-md-12">
							<label class="entry question-content">Import Progress</label>
							<div class="progress">
							<div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width:0%">
								<span class="import-progress">0</span>% Complete
							</div>
							</div>
						</div>
					</div>

					<!-- //Import Progress Feedback -->
					<div class="row">
						<div class="col-md-12">
							<div class="well import-feedback" style="max-height:300px; overflow:scroll;"></div>
						</div>
					</div>

				</div>

			</div>
		</form>
	</xsl:template>

</xsl:stylesheet>