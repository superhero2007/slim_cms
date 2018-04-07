<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'addEntryWizard']">

		<xsl:choose>
			<xsl:when test="not(@mode) and count(checklists/checklist) &gt; 0">
				<xsl:call-template name="add-entry-form" />
			</xsl:when>
			<xsl:when test="@mode = 'dashboard_admin' and /config/plugin[@plugin='clients'][@method='login']/client/dashboard/@dashboard_role_id &lt; 3 and count(checklists/checklist) &gt; 0">
				<xsl:call-template name="add-entry-form" />
			</xsl:when>
			<xsl:otherwise>
				<p>There are currently no entries that can be added to your account.</p>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="add-entry-form">
		<form method="post" action="" class="form-horizontal" id="entry-form" data-parsley-validate="data-parsley-validate" novalidate="novalidate" data-parsley-excluded="[disabled]">
			<input type="hidden" name="action" value="addEntry" />

			<xsl:variable name="period">
				<xsl:choose>
					<xsl:when test="param[@name = 'period']">
						<xsl:value-of select="param[@name = 'period']/@value" />
					</xsl:when>
					<xsl:otherwise>month</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<input type="hidden" name="period" value="{$period}" />

			<!-- //Available Checklists -->
			<div class="entry page">
				<div class="row">

					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">Entity<span class="required-question text-danger error">*</span></label>
									<div class="select drop-down-list">
										<select class="form-control" data-parsley-required="required" name="client_id">
											<xsl:if test="count(entities/entity) &gt; 1">
												<option value="">-- Select --</option>
											</xsl:if>
											<xsl:for-each select="entities/entity">
												<option value="{@client_id}">
													<xsl:value-of select="@company_name" disable-output-escaping="yes" />
												</option>
											</xsl:for-each>
										</select>
										<i></i>
									</div>
								</div>
							</div>
						</fieldset>
					</div>

					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">Entry type<span class="required-question text-danger error">*</span></label>
									<div class="select drop-down-list">
										<select class="form-control" data-parsley-required="required" name="checklist_id">
											<xsl:if test="count(checklists/checklist) &gt; 1">
												<option value="">-- Select --</option>
											</xsl:if>
											<xsl:for-each select="checklists/checklist">
												<option value="{@md5}">
													<xsl:value-of select="@name" disable-output-escaping="yes" />
												</option>
											</xsl:for-each>
										</select>
										<i></i>
									</div>
								</div>
							</div>
						</fieldset>
					</div>

					<!-- //Report period -->
					<xsl:if test="count(periods) &gt; 0">
						<div class="col-md-12 question">
							<fieldset class="entry question">
								<div class="row">
									<div class="col-md-12">
										<label class="entry question-content">Period<span class="required-question text-danger error">*</span></label>
										<div class="select drop-down-list">
											<select class="form-control" data-parsley-required="required" name="date_range_start">
												<xsl:if test="count(periods/period) &gt; 1">
													<option value="">-- Select --</option>
												</xsl:if>
												<xsl:for-each select="periods/period">
													<option value="{@date_range_start}">
														<xsl:value-of select="@label" disable-output-escaping="yes" />
													</option>
												</xsl:for-each>
											</select>
											<i></i>
										</div>
									</div>
								</div>
							</fieldset>
						</div>
					</xsl:if>

					<!-- //Submit -->
					<div class="col-md-12">
						<div class="row">
							<div class="col-md-12">
								<a class="btn btn-base btn-icon btn-icon-right fa-plus col-sm-6 submit-form-button" data-action="submit">
									<span>Start new entry</span>
								</a>  
							</div>
						</div>
					</div>
				</div>

			</div>
		</form>
	</xsl:template>
		
</xsl:stylesheet>