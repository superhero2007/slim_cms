<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'loadEntry'][@mode = 'checklist']">
		<xsl:choose>
			<xsl:when test="report/@status = 'Locked'">
				<xsl:call-template name="locked" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="loadEntry" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- //loadEntry -->
	<!--//The main assessment plugin template, rendering at all times -->
	<xsl:template name="loadEntry">

		<!-- //Set the entry section width -->
		<xsl:variable name="entry-width">
			<xsl:choose>
				<!-- //Single Page -->
				<xsl:when test="@layout_type = 'single-page'">12</xsl:when>
				<!-- //Page Sections with no matching page section for the current page -->
				<xsl:when test="@layout_type = 'page-section-navigation' and clientChecklist/page/@page_section_id = ''">12</xsl:when>
				<xsl:otherwise>9</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- //Call the assessment header -->
		<xsl:call-template name="entry-header" mode="entry" />
		
		<!-- //Call the page section navigation -->
		<xsl:if test="@layout_type = 'page-section-navigation'">
			<xsl:call-template name="page-section-navigation" mode="entry" />
		</xsl:if>

		<div class="row">

			<xsl:if test="$entry-width &lt; 12">
				<div class="col-md-{(12 - $entry-width)}">
					<xsl:choose>
						<xsl:when test="@layout_type = 'page-section-navigation'">
							<xsl:call-template name="page-section-page-navigation" mode="entry" />
						</xsl:when>
						<xsl:when test="@layout_type = 'page-navigation'">
							<xsl:call-template name="page-navigation" mode="entry" />
						</xsl:when>
					</xsl:choose>
				</div>
			</xsl:if>

			<div class="col-md-{$entry-width}">
				<!-- //The main form container -->
				<div class="load-entry-container entry-{clientChecklist/@client_checklist_id}">

					<form method="post" action="" class="form-horizontal" id="entry-form" data-parsley-validate="data-parsley-validate" novalidate="novalidate" data-parsley-excluded="[disabled]">

						<!-- //Hidden input action is used for next/previous/submit buttons -->
						<input type="hidden" name="action" id="action" value="" data-parsley-excluded="true" />
						<xsl:choose>
							<xsl:when test="@layout_type = 'page-section-navigation'">
								<xsl:call-template name="section-entry" mode="entry" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="page-entry" mode="entry" />
							</xsl:otherwise>
						</xsl:choose>

						<!-- //Page Notes -->
						<xsl:call-template name="page-notes" mode="entry" />

						<!-- //Assessment Buttons -->
						<xsl:call-template name="assessment-buttons" mode="entry" />

					</form>

						<!-- //Help content -->
						<xsl:call-template name="help-content" mode="entry" />
				</div>
			</div>
		</div>

		<!-- //Add any required data to the DOM -->
		<xsl:for-each select="clientChecklist/data">
			<div data-type="data" data-key="{@key}" data-value="{@data}" />
		</xsl:for-each>
		
	</xsl:template>

	<xsl:template name="entry-details" mode="entry">

		<xsl:variable name="display-period">
			<xsl:choose>
				<xsl:when test="@display-period and @display-period != 'false'">
					<xsl:value-of select="@display-period" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="display-company">
			<xsl:choose>
				<xsl:when test="@display-company = 'true'">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$display-company = 'true'">
			<div class="entry entry-details">
				<h6><xsl:value-of select="clientChecklist/@company_name" /></h6>
			</div>
		</xsl:if>

		<xsl:if test="$display-period != 'false'">
			<div class="entry entry-details">
				<xsl:choose>
					<xsl:when test="$display-period = 'month'">
						<p>Period:
							<xsl:choose>
								<xsl:when test="clientChecklist/@date_range_start_month != ''">
									<xsl:value-of select="concat(' ',clientChecklist/@date_range_start_month, ' ', clientChecklist/@date_range_start_year)" />
								</xsl:when>
								<xsl:otherwise>N/A</xsl:otherwise>
							</xsl:choose>
						</p>
					</xsl:when>
					<xsl:when test="$display-period = 'year' or $display-period = 'year_start'">
						<p>Period:
							<xsl:value-of select="clientChecklist/@date_range_start_year" />
							<xsl:choose>
								<xsl:when test="clientChecklist/@date_range_start_year != ''">
									<xsl:value-of select="concat(' ',date_range_start_year)" />
								</xsl:when>
								<xsl:otherwise>N/A</xsl:otherwise>
							</xsl:choose>
						</p>
					</xsl:when>
					<xsl:when test="$display-period = 'year_finish'">
						<p>Period:
							<xsl:value-of select="clientChecklist/@date_range_finish_year" />
							<xsl:choose>
								<xsl:when test="clientChecklist/@date_range_finish_year != ''">
									<xsl:value-of select="concat(' ',date_range_finish_year)" />
								</xsl:when>
								<xsl:otherwise>N/A</xsl:otherwise>
							</xsl:choose>
						</p>
					</xsl:when>
					<xsl:when test="$display-period = 'date-range'">
						<p>Period:
							<xsl:value-of select="clientChecklist/@date_range_start_year" />
							<xsl:choose>
								<xsl:when test="clientChecklist/@date_range_start_pretty != ''">
									<xsl:value-of select="concat(clientChecklist/@date_range_start_pretty, ' to ', clientChecklist/@date_range_finish_pretty)" />
								</xsl:when>
								<xsl:otherwise>N/A</xsl:otherwise>
							</xsl:choose>
						</p>
					</xsl:when>
				</xsl:choose>
			</div>
		</xsl:if>

	</xsl:template>


	<xsl:template name="entry-controls" mode="entry">
		<div class="entry entry-controls">
			<div class="row">
				<xsl:if test="clientChecklist/@progress_report = '1'">
					<div class="col-md-2 item">
						<a href="/members/entry/report/{clientChecklist/@client_checklist_id}/" class="btn btn-base btn-icon fa-file-pdf-o">
							<span>Report</span>
						</a>
					</div>
				</xsl:if>
				<xsl:if test="clientChecklist/@help_content != ''">
					<div class="col-md-2 item">
						<a href="#" class="btn btn-base btn-icon fa-question" data-toggle="modal" data-target=".entry.help-content">
							<span>Help</span>
						</a>
					</div>
				</xsl:if>
				<xsl:if test="clientChecklist/@settings = '1' and /config/plugin[@plugin='clients'][@method='login']/client/dashboard/@dashboard_role_id &lt; 3">
					<div class="col-md-2 item">
						<a href="/#" class="btn btn-base btn-icon fa-gears" data-toggle="modal" data-target=".metric-settings-modal">
							<span>Settings</span>
						</a>
					</div>
				</xsl:if>
				<div class="col-md-2 item">
					<a href="#" class="btn btn-base btn-icon fa-save entry-save-page" data-action="save">
						<span>Save</span>
					</a>
				</div>

				<!--//Check for last saved information -->
				<xsl:if test="clientChecklist/@last_active_pretty">
					<div class="col-md-4 item">
						<span class="entry last-active">
							Last saved <xsl:value-of select="clientChecklist/@last_active_pretty" />
						</span>
					</div>
				</xsl:if>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="entry-header" mode="entry">
		<!-- //Set entry header width -->
		<xsl:variable name="entry-width">
			<xsl:choose>
				<xsl:when test="@layout_type = 'single-page'">12</xsl:when>
				<xsl:otherwise>8</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="row">
			<div class="entry header controls col-md-12">
				<div class="row">
					<!--<div class="col-md-{$entry-width}">-->
					<div class="col-md-12">
						<div class="row">
							<div class="col-md-{$entry-width}">

								<!-- //Entry title -->
								<div class="entry entry-title">
									<h1><xsl:value-of select="clientChecklist/@name" /></h1>
								</div>

								<!-- //Call the entry details and entry controls-->
								<xsl:call-template name="entry-details" />
							</div>

							<!-- //Entry Progress -->
							<xsl:if test="$entry-width &lt; 12">
								<div class="col-md-{(12 - $entry-width)}">

									<xsl:variable name="default-color">
										<xsl:choose>
											<xsl:when test="/config/domain/@default_color != ''">
												<xsl:value-of select="/config/domain/@default_color" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>#3498db</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>

									<canvas class="entry classyloader pull-right" data-classyloader="data-classyloader" data-trigger-in-view="true" data-percentage="{clientChecklist/@progress}" data-speed="20" data-font-size="25px" data-diameter="40" data-line-color="{$default-color}" data-remaining-line-color="#f5f5f5" data-line-width="5" data-font-color="#515253" data-start="top" data-width="100px" data-height="100px" width="100" height="100">
									</canvas>	
								</div>
							</xsl:if>

						</div>
						<div class="row">
							<div class="col-md-12">
								<xsl:call-template name="entry-controls" />
							</div>
						</div>
					</div>
				</div>
				<div class="row">
					<div class="col-md-12">
						<div class="entry header controls footer col-md-12" />
					</div>
				</div>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="help-content" mode="entry">
		<!-- Modal -->
		<div class="modal fade entry help-content" id="help-modal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
		  <div class="modal-dialog modal-lg" role="document">
		    <div class="modal-content">
		      <div class="modal-header">
		        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">x</span></button>
		        <h4 class="modal-title" id="myModalLabel">Help</h4>
		      </div>
		      <div class="modal-body">
		      	<xsl:apply-templates select="clientChecklist/help_content/*" mode="html" />
		      </div>
		    </div>
		  </div>
		</div>
	</xsl:template>

	<xsl:template name="section-entry" mode="entry">
		<!--<xsl:apply-templates select="clientChecklist/page" mode="entry" type="page-section-page" />-->
		<xsl:apply-templates select="clientChecklist/page" mode="entry" type="page" />
	</xsl:template>

	<xsl:template match="page" mode="entry" type="page-section-page">

		<div class="entry page page-id-{@page_id} page-section-id-{@page-section-id} row" data-page-id="{@page_id}" data-page-section-id="{@page_section_id}">
							
			<!-- //Page Title -->
			<div class="entry page-title col-md-12">
				<h4><xsl:value-of select="@title" /></h4>
			</div>

			<!-- //Page Content -->
			<div class="entry page-content col-md-12">
				<fieldset>
					<xsl:apply-templates select="content/*" mode="html" />
				</fieldset>
			</div>

			<!-- //Questions -->
			<xsl:apply-templates select="question" mode="entry"/>

		</div>

	</xsl:template>

	<!-- //Choose what page layout we should use -->
	<xsl:template name="page-entry" mode="entry">
		<xsl:apply-templates select="clientChecklist/page" mode="entry" type="page" />
	</xsl:template>	

	<!-- //Standard Page Layout -->
	<xsl:template match="page" mode="entry" type="page">
		<!-- //Page -->
		<div class="entry page page-id-{@page_id} row" data-page-id="{@page_id}">

			<!-- //Page Title (Disabled on Single Page) -->
			<xsl:if test="../../@layout_type != 'single-page'">
				<div class="entry page-title col-md-12">
					<h4><xsl:value-of select="@title" /></h4>
				</div>
			</xsl:if>

			<!-- //Page Content -->
			<xsl:if test="content/@length &gt; 0 and content/@parsable = '1'">
				<div class="entry page-content col-md-12">
					<fieldset>
						<xsl:apply-templates select="content/*" mode="html" />
					</fieldset>
				</div>
			</xsl:if>

			<!-- //Questions -->
			<xsl:apply-templates select="question" mode="entry"/>

			<!-- //Metrics -->
			<xsl:apply-templates select="metricGroup" mode="entry"/>

			<!-- //Form Groups -->
			<!-- <xsl:apply-templates select="formGroup" mode="entry" /> -->

		</div>

	</xsl:template>

	<!-- //Page Section Navigation Template -->
	<xsl:template name="page-section-navigation" mode="entry">

		<!-- //Page Sections -->
		<div class="row entry page-sections-container">
			<div class="col-md-12">
				<div class="entry steps layered page-sections">
					<xsl:if test="count(clientChecklist/pageSection) &gt; 0">
						<ul class="entry sections equalize-children">
							<xsl:for-each select="clientChecklist/pageSection[@enabled = '1']">
								<xsl:sort select="@sequence" data-type="number" />

								<xsl:variable name="page-section-completed">
									<xsl:if test="count(../checklistPage[@page_section_id = current()/@page_section_id]) = count(../checklistPage[@page_section_id = current()/@page_section_id][@complete = 'yes'])">
										<xsl:text> complete</xsl:text>
									</xsl:if>
								</xsl:variable>

								<xsl:variable name="page-section-current">
									<xsl:if test="../../clientChecklist/@current_page_section = current()/@page_section_id">
										<xsl:text> current</xsl:text>
									</xsl:if>
								</xsl:variable>

								<xsl:variable name="page-section-width">
									<xsl:choose>
										<xsl:when test="@width">
											<xsl:value-of select="@width" />
										</xsl:when>
										<xsl:otherwise>20</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>

								<li class="entry sections page-section page-section-id-{@page_section_id}{$page-section-completed}{$page-section-current}" style="width:{$page-section-width}%">
									<a href="?p={../checklistPage[@page_section_id = current()/@page_section_id][1]/@token}" class="entry-page-section" data-toggle="page-section-id-{@page_section_id}">
										<span class="entry section page-count"><xsl:value-of select="position()" />.</span>
										<span class="entry section page-title"><xsl:value-of select="@title" /></span>
									</a>					
								</li>
							</xsl:for-each>
						</ul>
					</xsl:if>
				</div>
			</div>
		</div>

	</xsl:template>

	<!-- //Page Navigation Template -->
	<xsl:template name="page-section-page-navigation" mode="entry">

		<xsl:variable name="parent-position">
			<xsl:for-each select="clientChecklist/pageSection[@enabled = '1']">
				<xsl:sort select="@sequence" data-type="number" />
				<xsl:if test="@page_section_id = ../../clientChecklist/@current_page_section">
					<xsl:value-of select="position()" />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<!-- //Pages -->
		<div class="entry steps pages">
			<ul class="entry sections" role="tab">
				<xsl:for-each select="clientChecklist/checklistPage[@page_section_id = ../../clientChecklist/@current_page_section][@skipPage != '1']">
					<xsl:sort select="@sequence" data-type="number" />

						<xsl:variable name="page-completed">
							<xsl:if test="@complete = 'yes'">
								<xsl:text> complete</xsl:text>
							</xsl:if>
						</xsl:variable>

						<xsl:variable name="page-current">
							<xsl:if test="../../clientChecklist/@current_page = @page_id">
								<xsl:text> current</xsl:text>
							</xsl:if>
						</xsl:variable>

						<li class="entry sections page-section-page page-id-{@page_id} page-section-id-{@page_section_id}{$page-completed}{$page-current}">
							<a href="?p={@token}" class="entry sections page page-id-{@page_id}">
								<span class="entry section page-count"><xsl:value-of select="$parent-position" />.<xsl:value-of select="position()" />.</span>
								<span class="entry section page-title"><xsl:value-of select="@title" /></span>
							</a>
						</li>
				</xsl:for-each>
			</ul>
		</div>

	</xsl:template>

	<!-- //Page Navigation Template -->
	<xsl:template name="page-navigation" mode="entry">

		<!-- //Pages -->
		<div class="entry steps pages">
			<ul class="entry sections" role="tab">
				<xsl:for-each select="clientChecklist/checklistPage[@skipPage != '1']">
					<xsl:sort select="@sequence" data-type="number" />

					<xsl:if test="@skipPage != '1'">
						<xsl:variable name="page-completed">
							<xsl:if test="@complete = 'yes'">
								<xsl:text> complete</xsl:text>
							</xsl:if>
						</xsl:variable>

						<xsl:variable name="page-current">
							<xsl:if test="../../clientChecklist/@current_page = current()/@page_id">
								<xsl:text> current</xsl:text>
							</xsl:if>
						</xsl:variable>

						<li class="entry sections page-section-page page-id-{@page_id} page-section-id-{@page_section_id}{$page-completed}{$page-current}">
							<a href="?p={@token}" class="entry sections page page-id-{@page_id}">
								<span class="entry section page-count"><xsl:value-of select="position()" />.</span>
								<span class="entry section page-title"><xsl:value-of select="@title" /></span>
							</a>
						</li>
					</xsl:if>
				</xsl:for-each>
			</ul>
		</div>

	</xsl:template>

	<xsl:template match="question" mode="entry">
		<xsl:choose>
			<xsl:when test="@form_group_id &gt; 0">
				<xsl:if test="@question_id = ../question[@form_group_id = current()/@form_group_id][1]/@question_id">
					<xsl:call-template name="formGroup" mode="entry" />
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="question" mode="entry" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="formGroup" mode="entry">
		<xsl:variable name="formGroup" select="../formGroup[@form_group_id = current()/@form_group_id]" />

		<!-- //Additional CSS Classes -->
		<xsl:variable name="classes">
			<xsl:choose>
				<xsl:when test="$formGroup/@repeatable = '1' and $formGroup/@sortable = '1'">repeatable sortable</xsl:when>
				<xsl:when test="$formGroup/@repeatable = '1' and $formGroup/@sortable = '0'">repeatable</xsl:when>
				<xsl:when test="$formGroup/@repeatable = '0' and $formGroup/@sortable = '1'">sortable</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="col-md-12 entry formGroup {$formGroup/@css_class} {$classes}" data-page-id="{$formGroup/@page_id}">
			<xsl:for-each select="$formGroup/@*">
				<xsl:attribute name="{name()}">
					<xsl:value-of select="." />
				</xsl:attribute>
			</xsl:for-each>

			<div class="list">
				<xsl:for-each select="$formGroup/row">
					<xsl:variable name="index" select="@index" />
					<xsl:variable name="template">
						<xsl:choose>
							<xsl:when test="@template = '1'">
								<xsl:text> template</xsl:text>
							</xsl:when>
							<xsl:otherwise></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<div class="row formRow{$template}">
						<div class="col-md-11">
							<xsl:if test="$formGroup/@show_order = '1'">
								<span class="repeatable order">
									<xsl:value-of select="position()" />
								</span>
							</xsl:if>
							<xsl:for-each select="../../question[@form_group_id = $formGroup/@form_group_id]">
								<xsl:sort select="@sequence" data-type="number" />
								<xsl:call-template name="question" mode="entry">
									<xsl:with-param name="index" select="$index" />
								</xsl:call-template>				
							</xsl:for-each>
						</div>
						<div class="col-md-1">
							<xsl:if test="$formGroup/@sortable = '1'">
								<i class="fa fa-arrows repeatable move" />
							</xsl:if>
							<a href="#" class="btn btn-danger repeatable delete">
								<i class="fa fa-trash" /> 
							</a>
						</div>
					</div>
				</xsl:for-each>
			</div>

			<div class="row footer-control static">
				<xsl:if test="$formGroup/@repeatable = '1'">
					<div class="col-md-4"></div>
					<div class="col-md-4">
						<a href="#" class="btn btn-base btn-block btn-icon fa-plus repeatable add">Add <xsl:value-of select="$formGroup/@name" /></a>
					</div>
					<div class="col-md-4"></div>
				</xsl:if>
			</div>
		</div>
	</xsl:template>

	<!-- //Question template -->
	<!--<xsl:template match="question" mode="entry"> -->
	<xsl:template name="question" mode="entry">
		<xsl:param name="index" select="@index" />

		<!-- //Check to see if the question is a triggered question -->
		<xsl:variable name="dependent-question">
			<xsl:if test="@dependent_question = '1'">
				<xsl:text> dependent-question</xsl:text>
			</xsl:if>
		</xsl:variable>

		<!-- //Check to see if the question should be displayed in a table format -->
		<xsl:variable name="display-in-table">
			<xsl:if test="@display_in_table = '1' or ../../page/@display_in_table = '1'">
				<xsl:text> table-format</xsl:text>
			</xsl:if>
		</xsl:variable>

		<!-- //Check to see if the question has a grid width -->
		<xsl:variable name="grid-width">
			<xsl:choose>
				<xsl:when test="@col">
					<xsl:value-of select="@col" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'12'" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- //Table Header - Question Based -->
		<xsl:if test="@triggered = '1' and @display_in_table = '1'">
			<xsl:if test="not(preceding-sibling::*[1][self::question]) or not(preceding-sibling::question[@triggered = '1'][1]/@display_in_table = '1')">
				<div class="col-md-{$grid-width} question table-header">
					<fieldset class="entry table-header col-md-{$grid-width}{$display-in-table}">
						<div class="entry question-header"></div>
						<xsl:for-each select="answer">
							<div class="entry answer-header">
								<xsl:value-of select="@string" />
							</div>
						</xsl:for-each>
					</fieldset>
				</div>
			</xsl:if>
		</xsl:if>

		<!-- //Table Header - Page Based -->
		<xsl:if test="../../page/@display_in_table = '1'">
			<xsl:if test="not(preceding-sibling::*[1][self::question])">
				<div class="col-md-{$grid-width} question">
					<fieldset class="entry table-header col-md-{$grid-width}{$display-in-table}">
						<div class="entry question-header"></div>
						<xsl:for-each select="answer">
							<div class="entry answer-header">
								<xsl:value-of select="@string" />
							</div>
						</xsl:for-each>
					</fieldset>
				</div>
			</xsl:if>
		</xsl:if>

		<xsl:variable name="hidden">
			<xsl:if test="@hidden = '1'">
				<xsl:value-of select="'hidden'" />
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="content-block">
			<xsl:if test="@content_block = '1'">
				<xsl:value-of select="'content-block'" />
			</xsl:if>
		</xsl:variable>

		<div class="col-md-{$grid-width} question-container question {$content-block} {$hidden} {@css_class}" data-permission="{@permission}" data-question-id="{@question_id}">
			<!-- //Form Group -->
			<xsl:attribute name="formGroup">
				<xsl:value-of select="@form_group_id" />
			</xsl:attribute>

			<fieldset class="entry question question-id-{@question_id}{$dependent-question}{$display-in-table}">
				<!-- data triggered attribute -->
				<xsl:if test="@dependent_question = '1'">
					<xsl:attribute name="data-triggered">false</xsl:attribute>
				</xsl:if>

				<div class="entry question question-id-{@question_id}-{$index} form-group">
					<a id="{@question_id}"></a>
					<xsl:choose>

						<!-- //Render the question content as HTML -->
						<xsl:when test="@content_block = '1'">
							<xsl:value-of select="@question" disable-output-escaping="yes" />
						</xsl:when>

						<!-- //Standard output -->
						<xsl:otherwise>
							<label for="question-id-{@question_id}" class="entry question-content">
								<xsl:value-of select="@question" />

								<!-- //Question Options/Icons/Help -->
								<xsl:call-template name="question-options" mode="entry" />
							</label>
						</xsl:otherwise>
					</xsl:choose>

					<!-- //Get the answers -->
					<xsl:apply-templates match="answer" mode="entry">
						<xsl:with-param name="index" select="$index" />
					</xsl:apply-templates>

					<!-- //Error Message Template -->
					<div class="error-message">
						<xsl:if test="@error">
							<ul>
								<li><xsl:value-of select="@error" /></li>
							</ul>
						</xsl:if>
					</div>

				</div>

				<!-- //Get the dependencies -->
				<xsl:apply-templates match="dependency" mode="dependency-entry">
					<xsl:with-param name="index" select="$index" />
				</xsl:apply-templates>

			</fieldset>
		</div>

	</xsl:template>

	<!-- //MetricGroup Template - Type 3 -->
	<xsl:template match="metricGroup[@metric_group_type_id = '3']" mode="entry">
		<xsl:variable name="clientChecklist" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/clientChecklist" />

		<xsl:if test="position() = 1">
			<xsl:call-template name="metric-group-header" mode="entry" />
			<xsl:call-template name="metric-settings" mode="entry" />
		</xsl:if>

		<xsl:variable name="metric-group-status">
			<xsl:choose>
				<xsl:when test="count(metric[@disabled = '0']) &gt; 0">
					<xsl:value-of select="'active'" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'disabled'" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="col-md-12 metric {$metric-group-status}" data-metric-type="metric-group" data-metric-group="{@metric_group_id}">
			<fieldset class="entry metric-group metric-group-id-{@metric_group_id} group form-horizontal bg-base" data-metric-group="{@metric_group_id}">
				<div class="form-group">
					<div class="col-md-12">
						<label class="entry metric-group metric-content control-label text-left">
							<xsl:value-of select="@name" />
						</label>
					</div>
				</div>
			</fieldset>
		</div>
		<xsl:apply-templates select="metric" mode="entry" />

	</xsl:template>

	<!-- //List all of the metrics settings -->
	<xsl:template name="metric-settings">
		<div class="modal fade metric-settings-modal" tabindex="-1" role="dialog" aria-labelledby="metric-settings">
			<div class="modal-dialog modal-lg" role="document">
				<div class="modal-content">
					<div class="modal-header bg-base">
						<h4 class="modal-title" id="myModalLabel">Metrics Settings</h4>
					</div>
					<div class="modal-body">
					
						<!-- //Header -->
						<div class="row metric-settings header">
							<fieldset class="entry">
								<div class="col-md-5">
									Metric Group
								</div>
								<div class="col-md-5">
									Metric
								</div>
								<div class="col-md-2">
									Status
								</div>
							</fieldset>
						</div>
						<!-- //Body -->
						<xsl:for-each select="../metricGroup/metric">
							<div class="row metric-settings metric">
								<fieldset class="entry">
									<div class="col-md-5">
										<xsl:value-of select="../@name" />
									</div>
									<div class="col-md-5">
										<xsl:value-of select="@metric" />
									</div>
									<div class="col-md-2">
										<input type="checkbox" name="metric-settings[{@metric_id}]" class="entry toggle metric-settings switch" data-size="mini" data-metric-id="{@metric_id}" data-metric-group-id="{@metric_group_id}" data-client-id="{../../../../clientChecklist/@client_id}">
											<xsl:if test="@disabled = '0'">
												<xsl:attribute name="checked" select="'checked'" />
											</xsl:if>
										</input>
									</div>
								</fieldset>
							</div>								
						</xsl:for-each>

					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
						<!--<button type="button" class="btn btn-primary">Save changes</button>-->
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- //MetricGroup Template - Type 3 -->
	<xsl:template name="metric-group-header" mode="entry">
		<xsl:variable name="clientChecklist" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/clientChecklist" />

		<div class="col-md-12 metric">
			<fieldset class="entry metric-group form-horizontal">
				<div class="form-group">
					<div class="col-md-3">
						<!-- Large modal -->
						<input type="text" class="form-control" data-action="metric-filter" placeholder="Filter metrics" data-form-modified="false" />
					</div>
					<div class="col-md-4">
						<label class="entry metric-group metric-content control-label text-center">
							<xsl:text>Usage</xsl:text>
						</label>
					</div>
					<div class="col-md-5">
						<div class="row">
							<div class="col-md-4">
								<label class="entry metric-group metric-content control-label text-right">
									<xsl:text>Previous Month</xsl:text><br />
									<xsl:choose>
										<xsl:when test="$clientChecklist/@previous_month_month != ''">
											<xsl:value-of select="concat('(', $clientChecklist/@previous_month_month, ' ', $clientChecklist/@previous_month_year, ')')" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>(N/A)</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</label>
							</div>
							<div class="col-md-4">
								<label class="entry metric-group metric-content control-label text-right">
									<xsl:text>Previous Year</xsl:text><br />
									<xsl:choose>
										<xsl:when test="$clientChecklist/@previous_year_month != ''">
											<xsl:value-of select="concat('(', $clientChecklist/@previous_year_month, ' ', $clientChecklist/@previous_year_year, ')')" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>(N/A)</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</label>
							</div>
							<div class="col-md-4">
								<label class="entry metric-group metric-content control-label text-right">
									<xsl:text>YTD</xsl:text><br />
									<xsl:choose>
										<xsl:when test="$clientChecklist/@current_fy_au_start_month != ''">
											<xsl:value-of select="concat('(', $clientChecklist/@current_fy_au_start_month, ' ', $clientChecklist/@current_fy_au_start_year, ' - ', $clientChecklist/@current_month_month, ' ', $clientChecklist/@current_month_year, ')')" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>(N/A)</xsl:text>
										</xsl:otherwise>
									</xsl:choose>										
								</label>
							</div>
						</div>
					</div>
				</div>
			</fieldset>
		</div>
	</xsl:template>

	<xsl:template match="clientMetricData">
		<xsl:variable name="clientChecklist" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/clientChecklist" />
		<div class="metric-variation-data" data-key="{@key}" data-metric-id="{@metric_id}" data-metric-unit-type-id="{@metric_unit_type_id}" data-value="{@value}" data-metric-unit-type="{../../metricUnit[@metric_unit_type_id = current()/@metric_unit_type_id]/@metric_unit_type}" data-metric-max-variation="{../../@max_variation}" data-previous-year="{concat($clientChecklist/@previous_year_month, ' ', $clientChecklist/@previous_year_year)}" />
	</xsl:template>

	<!-- //Metric Template - Type 3 -->
	<!-- //Months set to a maximum of 1 -->
	<xsl:template match="metric[../../metricGroup[@metric_group_id = current()/@metric_group_id]/@metric_group_type_id = '3']" mode="entry">

		<xsl:variable name="clientChecklist" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/clientChecklist" />

		<xsl:variable name="metric-status">
			<xsl:choose>
				<xsl:when test="@disabled = '1'">
					<xsl:value-of select="'disabled'" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'active'" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="col-md-12 metric {$metric-status}" data-metric-type="metric" data-metric-group="{@metric_group_id}" data-metric-id="{@metric_id}">
			<fieldset class="entry metric-group metric metric-id-{@metric_id}" data-metric-label="{@metric}" data-metric-group="{@metric_group_id}" data-status="visible">
				
				<xsl:apply-templates select="previousResults/clientMetricData" />

				<div class="form-group">
					<div class="col-md-12 metric-input-container">
						<div class="row">
							<div class="col-md-3">
								<input type="hidden" name="metric[{@metric_id}][months]" value="1" />

								<div class="dropdown">
									<button class="btn btn-discreet dropdown-toggle" type="button" id="metric-{@metric_id}" data-toggle="dropdown">
										<label for="metric-id-{@metric_id}" class="entry metric metric-content metric-name control-label text-left">
											<xsl:value-of select="@metric" />
											<span class="caret"></span>
											<xsl:if test="@required = '1'">
												<span class="required-metric text-danger error">*</span>
											</xsl:if>
										</label>
									</button>
									<ul class="dropdown-menu" aria-labelledby="metric-{@metric_id}">
										<li><a href="#" class="add-sub-metric">Add Sub Metric Item</a></li>
									</ul>
								</div>

								<!-- //Metric Options -->
								<xsl:call-template name="metric-options" mode="entry" />			
							</div>

							<!-- //Get input value -->
							<xsl:variable name="value">
								<xsl:choose>
									<xsl:when test="clientMetric">
										<xsl:value-of select="clientMetric/@value" />
									</xsl:when>
									<xsl:otherwise></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<!-- //Required Bool -->
							<xsl:variable name="required">
								<xsl:choose>
									<xsl:when test="@required = '1'">true</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<div class="col-md-4">
								<!-- //Metric Value -->
								<div class="row">
									<div class="col-md-8">
										<input type="number" step="any" name="metric[{@metric_id}][value]" value="{$value}" class="form-control text-right metric-{@metric_id} metric-value" data-parsley-required="{$required}" data-metric-id="{@metric_id}">
										</input>
									</div>

									<!-- //Metric Type -->
									<div class="col-md-4">
										<div class="select drop-down-list">
											<select class="form-control metric-{@metric_id} metric-type" name="metric[{@metric_id}][metric_unit_type_id]" data-parsley-required="{@required}" data-metric-id="{@metric_id}">
												<xsl:for-each select="metricUnit">
													<option value="{@metric_unit_type_id}">
														<xsl:if test="../defaultMetricUnit/@metric_unit_type_id = current()/@metric_unit_type_id">
															<xsl:attribute name="selected">selected</xsl:attribute>
														</xsl:if>
														<xsl:value-of select="@metric_unit_type" disable-output-escaping="yes" />
													</option>
												</xsl:for-each>
											</select>
											<i></i>
										</div>
									</div>
								</div>
							</div>


							<!-- //Previous Values -->
							<div class="col-md-5">
								<div class="row">
									<div class="col-md-4">
										<label for="metric-id-{@metric_id}" class="entry metric metric-content metric-previous-month control-label">
											<div class="metric-id-{@metric_id} previous-month">
												<xsl:if test="previousResults/clientMetricData[@key = 'previous_month'][@metric_unit_type_id = ../../defaultMetricUnit/@metric_unit_type_id]/@value != ''">
													<!-- //Value -->
													<xsl:value-of select="format-number(previousResults/clientMetricData[@key = 'previous_month'][@metric_unit_type_id = ../../defaultMetricUnit/@metric_unit_type_id]/@value,'#,###.##')" />
													<!-- //Unit -->
													<xsl:text> </xsl:text><xsl:value-of select="defaultMetricUnit/@metric_unit_type" disable-output-escaping="yes"/>
												</xsl:if>
											</div>
										</label>
									</div>
									<div class="col-md-4">
										<label for="metric-id-{@metric_id}" class="entry metric metric-content metric-previous-year control-label">
											<div class="metric-id-{@metric_id} previous-year">
												<xsl:if test="previousResults/clientMetricData[@key = 'previous_year'][@metric_unit_type_id = ../../defaultMetricUnit/@metric_unit_type_id]/@value != ''">
													<!-- //Value -->
													<xsl:value-of select="format-number(previousResults/clientMetricData[@key = 'previous_year'][@metric_unit_type_id = ../../defaultMetricUnit/@metric_unit_type_id]/@value, '#,###.##')" />
													<!-- //Unit -->
													<xsl:text> </xsl:text><xsl:value-of select="defaultMetricUnit/@metric_unit_type" disable-output-escaping="yes"/>
												</xsl:if>
											</div>
										</label>
									</div>
									<div class="col-md-4">
										<label for="metric-id-{@metric_id}" class="entry metric metric-content metric-ytd control-label">
											<div class="metric-id-{@metric_id} current-fy-au">
												<xsl:if test="previousResults/clientMetricData[@key = 'current_fy_au'][@metric_unit_type_id = ../../defaultMetricUnit/@metric_unit_type_id]/@value != ''">
													<!-- //Value -->
													<xsl:value-of select="format-number(previousResults/clientMetricData[@key = 'current_fy_au'][@metric_unit_type_id = ../../defaultMetricUnit/@metric_unit_type_id]/@value, '#,###.##')" />
													<!-- //Unit -->
													<xsl:text> </xsl:text><xsl:value-of select="defaultMetricUnit/@metric_unit_type" disable-output-escaping="yes"/>
												</xsl:if>
											</div>
										</label>
									</div>
								</div>
							</div>
						</div>
					</div>

					<xsl:call-template name="metric-variation" mode="entry" />
					<xsl:call-template name="sub-metric" mode="entry" />

				</div>
			</fieldset>
		</div>
	</xsl:template>

	<!-- //All icons that are related to a question -->
	<xsl:template name="metric-options" mode="entry">
		<xsl:param name="grouping" />
		<xsl:param name="class" />
										
		<!-- //Information/Tip/Previous Results -->
		<xsl:if test="@help != ''">
			<a class="entry metric icon information fa fa-question-circle" data-toggle="modal" data-target="#metric-{@metric_id}-options-class{$class}" rel="tooltip" data-original-title="Click for help &amp; information." />
		</xsl:if>

		<!-- //Call the modal template -->
		<xsl:call-template name="metric-options-panel" mode="entry">
			<xsl:with-param name="grouping" select="$grouping" />
			<xsl:with-param name="class" select="$class" />
		</xsl:call-template>
	</xsl:template>

	<!-- //All question option content -->
	<xsl:template name="metric-options-panel" mode="entry">
		<xsl:param name="grouping" />
		<xsl:param name="class" />
		<xsl:variable name="metric" select="." />
		<div class="metric-options modal fade previous-results-modal {$class}" data-keyboard="false" data-backdrop="static" id="metric-{@metric_id}-options-class{$class}" tabindex="-1" role="dialog" aria-labelledby="metric-{@metric_id}-options-title">
			<div class="modal-dialog modal-lg" role="document">
				<div class="modal-content">
					<div class="modal-header bg-base">
						<h4 class="modal-title" id="metric-{@metric_id}-options-title">Help &amp; Information</h4>
					</div>
					<div class="modal-body">
						<div class="row">
							<!-- Help -->
							<xsl:if test="@help != ''">
								<div class="col-md-12">
									<h5>Help</h5>
									<div class="col-md-12 entry help-content">
										<xsl:value-of select="@help" disable-output-escaping="yes" />
									</div>
								</div>
							</xsl:if>
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="sub-metric" mode="entry">
		<div class="col-md-12 entry sub-metric-container">

			<div class="row">
				<div class="col-md-12 entry metric-id-{@metric_id} sub-metric-heading">
					<div class="row">
						<div class="col-md-3">
							<div class="row">
								<div class="col-md-2">
								</div>
								<div class="col-md-10 header">
									Sub Metric Details
								</div>
							</div>
						</div>
						<div class="col-md-4 header">
							Usage
						</div>
						<div class="col-md-5">
							<div class="row">
								<div class="col-md-5 header">
									Action
								</div>
								<div class="col-md-7"></div>
							</div>
						</div>
					</div>
				</div>

				<!-- //Repeatable Template -->
				<div class="col-md-12 entry metric-id-{@metric_id} sub-metric repeatable template" data-target="#sub-metric-container-{@metric_id}">
					<div class="row">
						<div class="col-md-3">
							<div class="row">
								<div class="col-md-2">
								</div>
								<div class="col-md-10">
									<input type="text" class="form-control" placeholder="example: location 1" data-parsley-required="true" disabled="disabled" name="sub_metric[{@metric_id}][description][]" />
								</div>
							</div>
						</div>
						<div class="col-md-4">
							<!-- //Get input value -->
							<xsl:variable name="value">
								<xsl:value-of select="'0'" />
							</xsl:variable>

							<!-- //Metric Value -->
							<div class="row">
								<div class="col-md-8">
									<input type="number" step="any" name="sub_metric[{@metric_id}][value][]" value="{$value}" class="form-control text-right metric-{@metric_id} metric-value" data-parsley-required="true" data-metric-id="{@metric_id}" disabled="disabled">
									</input>
								</div>

								<!-- //Metric Type -->
								<div class="col-md-4">
									<div class="select drop-down-list">
										<select class="form-control metric-{@metric_id} sub-metric-type" name="sub_metric[{@metric_id}][metric_unit_type_id][]" data-parsley-required="true" data-metric-id="{@metric_id}" disabled="disabled">
											<xsl:for-each select="metricUnit">
												<option value="{@metric_unit_type_id}">
													<xsl:if test="../defaultMetricUnit/@metric_unit_type_id = current()/@metric_unit_type_id">
														<xsl:attribute name="selected">selected</xsl:attribute>
													</xsl:if>
													<xsl:value-of select="@metric_unit_type" disable-output-escaping="yes" />
												</option>
											</xsl:for-each>
										</select>
										<i></i>
									</div>
								</div>
							</div>
						</div>
						<div class="col-md-5">
							<div class="row">
								<div class="col-md-5">
									<span class="btn btn-light delete-button" data-action="delete-sub-metric">
									    <i class="fa fa-fw fa-trash"></i>
									    <span>Delete</span>
									</span>
								</div>
								<div class="col-md-7"></div>
							</div>
						</div>
					</div>
				</div>
				
				<div id="sub-metric-container-{@metric_id}">

					<!-- //Existing Sub Metric Answers -->
					<xsl:for-each select="clientSubMetric">
						<xsl:variable name="clientSubMetric" select="." />
						<div class="col-md-12 entry metric-id-{@metric_id} sub-metric-{@client_sub_metric_id} sub-metric repeatable duplicate">
							<div class="row">
								<div class="col-md-3">
									<div class="row">
										<div class="col-md-2">
										</div>
										<div class="col-md-10">
											<input type="text" class="form-control" placeholder="example: location 1" data-parsley-required="true" value="{@description}" name="sub_metric[{@metric_id}][description][]"/>
										</div>
									</div>
								</div>
								<div class="col-md-4">

									<!-- //Metric Value -->
									<div class="row">
										<div class="col-md-8">
											<input type="number" step="any" value="{@value}" class="form-control text-right metric-{@metric_id} metric-value" data-parsley-required="true" data-metric-id="{@metric_id}" name="sub_metric[{@metric_id}][value][]">
											</input>
										</div>

										<!-- //Metric Type -->
										<div class="col-md-4">
											<div class="select drop-down-list">
												<select class="form-control metric-{@metric_id} sub-metric-type" data-parsley-required="true" data-metric-id="{@metric_id}" name="sub_metric[{@metric_id}][metric_unit_type_id][]">
													<xsl:for-each select="../metricUnit">
														<option value="{@metric_unit_type_id}">
															<xsl:if test="$clientSubMetric/@metric_unit_type_id = current()/@metric_unit_type_id">
																<xsl:attribute name="selected">selected</xsl:attribute>
															</xsl:if>
															<xsl:value-of select="@metric_unit_type" disable-output-escaping="yes" />
														</option>
													</xsl:for-each>
												</select>
												<i></i>
											</div>
										</div>
									</div>
								</div>
								<div class="col-md-5">
									<div class="row">
										<div class="col-md-5">
											<span class="btn btn-light delete-button" data-action="delete-sub-metric">
											    <i class="fa fa-fw fa-trash"></i>
											    <span>Delete</span>
											</span>
										</div>
										<div class="col-md-7"></div>
									</div>
								</div>
							</div>
						</div>
					</xsl:for-each>

				</div>

			</div>
		</div>
	</xsl:template>

	<xsl:template name="metric-variation" mode="entry">
		<xsl:variable name="clientMetricVariation" select="clientMetricVariation" />

		<div class="col-md-12 entry metric-variation metric-id-{@metric_id}-variation bg-warning">
			<div class="col-md-5">
				<label for="metric-variation-id-{@metric_id}" class="entry metric metric-content metric-variation-content control-label text-left">
					The usage value entered is <span class="percentage-change" /> than the value recorded in <span class="previous-period" />.
				</label>
			</div>
			<div class="col-md-7">
				<div class="row">
					<div class="col-md-2">
						<label for="metric-variation-id-{@metric_id}" class="entry metric metric-content metric-variation-content control-label text-left">
							<xsl:text>Justification:</xsl:text>
						</label>
					</div>
					<div class="col-md-5">
						<div class="select drop-down-list">
							<select class="form-control" name="metricVariation[{@metric_id}][metric_variation_option_id]" data-parsley-required="1" disabled="disabled">
								<option value="">-- select --</option>
								<xsl:for-each select="../../metricVariationOptions/metricVariationOption">
									<option value="{@metric_variation_option_id}">
										<xsl:if test="$clientMetricVariation/@metric_variation_option_id = current()/@metric_variation_option_id">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="@value" disable-output-escaping="yes" />
									</option>
								</xsl:for-each>
							</select>
							<i></i>
						</div>
					</div>
					<div class="col-md-5">
						<input type="text" name="metricVariation[{@metric_id}][metric_variation_value]" value="{$clientMetricVariation/@value}" class="form-control" placeholder="additional comments" disabled="disabled">
						</input>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- //Dependency Template -->
	<xsl:template match="dependency" mode="dependency-entry">
		<xsl:param name="index" select="0" />
		<div class="dependency hidden" data-answer-type="{@answer_type}" data-range-min="{@range-min}" data-range-max="{@range-max}" data-page-id="{@page_id}" data-question-id="{@question_id}" data-answer-id="{@answer_id}" data-index="{$index}" data-triggered="{@triggered}" /> 
	</xsl:template>

	<!-- //
	*
	*	Index based answer options allowing repeatable answers
	*
	-->

	<!-- Answer Template -->
	<xsl:template match="answer" mode="entry">
		<xsl:param name="index" select="0" />

		<xsl:variable name="answer-type" select="@type" />

		<xsl:variable name="hasChildren">
			<xsl:choose>
				<xsl:when test="@answer_type = 'drop-down-list' and (count(../answer[@hasChildren = '1']) &gt; 0)">
					<xsl:text>hasChildren </xsl:text>
				</xsl:when>
				<xsl:when test="@answer_type != 'drop-down-list' and @hasChildren = '1'">
					<xsl:text>hasChildren </xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="checkboxOther">
			<xsl:if test="@type = 'checkbox-other'">
				<xsl:text>checkboxOther</xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="checkboxOtherTriggered">
			<xsl:if test="@type = 'checkbox-other'">
				<xsl:choose>
					<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
						<xsl:text>1</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>0</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>

		<xsl:choose>

			<!-- //checkbox, checkbox-other, radio -->
			<xsl:when test="@type = 'checkbox' or @type = 'checkbox-other'">
				<xsl:variable name="type">
					<xsl:choose>
						<xsl:when test="../@multiple_answer = '1'">checkbox</xsl:when>
						<xsl:otherwise>radio</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<div class="{$type} c-{$type}">
					<label>
						<input name="question[{@question_id}][{$index}][]" type="{$type}" value="{@answer_id}" class="{$hasChildren}{$checkboxOther}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}">
							
							<xsl:choose>
								<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:when>
								<xsl:when test="@default_value = 'selected'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:when>
							</xsl:choose>
							<xsl:if test="@range_min &gt; 0">
								<xsl:attribute name="data-parsley-mincheck">
									<xsl:value-of select="@range_min" />
								</xsl:attribute>
							</xsl:if>
							<xsl:if test="@range_max &gt; 0">
								<xsl:attribute name="data-parsley-maxcheck">
									<xsl:value-of select="@range_max" />
								</xsl:attribute>
							</xsl:if>
						</input>
						<span class="fa fa-check"></span>
						<div class="entry answer-string">
							<xsl:value-of select="@string" disable-output-escaping="yes" />
						</div>
					</label>
				</div>

				<!-- Checkbox Other input field -->
				<xsl:if test="@type = 'checkbox-other'">

					<xsl:variable name="countable">
						<xsl:choose>
							<xsl:when test="@range_min &gt; 0 or @range_max &gt; 0">countable</xsl:when>
							<xsl:otherwise></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<input type="text" name="question-other[{@question_id}][{$index}][{@answer_id}]" placeholder="please provide more information" class="form-control question-other {$countable}" data-parsley-required="required" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-triggered="{$checkboxOtherTriggered}" data-type="question-other" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}" data-answer-type="question-other">
						<xsl:attribute name="value">
							<xsl:choose>
								<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
									<xsl:value-of select="../result[@answer_id = current()/@answer_id][@index = $index]/@value" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@default_value" />						
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>

						<!-- Word Limit -->
						<xsl:if test="@range_min &gt; 0">
							<xsl:attribute name="data-parsley-minwords">
								<xsl:value-of select="@range_min" />
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="@range_max &gt; 0">
							<xsl:attribute name="data-parsley-maxwords">
								<xsl:value-of select="@range_max" />
							</xsl:attribute>
						</xsl:if>

					</input>

					<!-- //Max Words Message -->
					<xsl:choose>
						<xsl:when test="@range_min &gt; 0 and @range_max &gt; 0">
							<div class="{@answer_id} counter-message text-right">
								Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
								Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
								<span class="word-counter">
									<xsl:text>Word count: </xsl:text><span class="counter"></span>
								</span>
							</div>
						</xsl:when>
						<xsl:when test="@range_min &gt; 0">
							<div class="{@answer_id} counter-message text-right">
								Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
								<span class="word-counter">
									<xsl:text>Word count: </xsl:text><span class="counter"></span>
								</span>
							</div>
						</xsl:when>
						<xsl:when test="@range_max &gt; 0">
							<div class="{@answer_id} counter-message text-right">
								Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
								<span class="word-counter">
									<xsl:text>Word count: </xsl:text><span class="counter"></span>
								</span>
							</div>
						</xsl:when>
					</xsl:choose>

				</xsl:if>
			</xsl:when>

			<!-- //Textbox -->
			<xsl:when test="@type = 'textarea'">

				<xsl:variable name="countable">
					<xsl:choose>
						<xsl:when test="@range_min &gt; 0 or @range_max &gt; 0">countable</xsl:when>
						<xsl:otherwise></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<textarea name="question[{@question_id}][{$index}][{@answer_id}]" rows="{@number_of_rows}" placeholder="{@string}" class="form-control {$countable}{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}">
					<xsl:if test="@range_min &gt; 0">
						<xsl:attribute name="data-parsley-minwords">
							<xsl:value-of select="@range_min" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@range_max &gt; 0">
						<xsl:attribute name="data-parsley-maxwords">
							<xsl:value-of select="@range_max" />
						</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
							<xsl:value-of select="../result[@answer_id = current()/@answer_id][@index = $index]/@value" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@default_value" />						
						</xsl:otherwise>
					</xsl:choose>
				</textarea>

				<!-- //Max Words Message -->
				<xsl:choose>
					<xsl:when test="@range_min &gt; 0 and @range_max &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
							Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
					<xsl:when test="@range_min &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
					<xsl:when test="@range_max &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
				</xsl:choose>
			</xsl:when>

			<!-- //Int -->
			<xsl:when test="@type = 'int'">
				<input type="number" step="1" name="question[{@question_id}][{$index}][{@answer_id}]" placeholder="{@string}" class="form-control{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}">
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id][@index = $index]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:if test="@range_min != ''">
						<xsl:attribute name="min">
							<xsl:value-of select="@range_min" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@range_max != ''">
						<xsl:attribute name="max">
							<xsl:value-of select="@range_max" />
						</xsl:attribute>
					</xsl:if>
				</input>
			</xsl:when>

			<!-- //Float -->
			<xsl:when test="@type = 'float'">

				<xsl:variable name="input-group-class">
					<xsl:choose>
						<xsl:when test="@prepend_content != '' and @append_content != ''">
							<xsl:value-of select="'input-group m-b prepend append'" />
						</xsl:when>
						<xsl:when test="@prepend_content != ''">
							<xsl:value-of select="'input-group m-b prepend'" />
						</xsl:when>
						<xsl:when test="@append_content != ''">
							<xsl:value-of select="'input-group m-b append'" />
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<div class="{$input-group-class}">

					<!-- //Prepend content if required -->
					<xsl:if test="@prepend_content != ''">
						<span class="input-group-addon">
							<xsl:value-of select="@prepend_content" />
						</span>
					</xsl:if>

					<input type="number" step="any" name="question[{@question_id}][{$index}][{@answer_id}]" placeholder="{@string}" class="form-control{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}">

						<!-- //Set the value to client_result or default value -->
						<xsl:attribute name="value">
							<xsl:choose>
								<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
									<xsl:value-of select="../result[@answer_id = current()/@answer_id][@index = $index]/@value" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@default_value" />						
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>

						<xsl:if test="@range_min != ''">
							<xsl:attribute name="min">
								<xsl:value-of select="@range_min" />
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="@range_max != ''">
							<xsl:attribute name="max">
								<xsl:value-of select="@range_max" />
							</xsl:attribute>
						</xsl:if>

						<!-- //Check for auto calculation -->
						<xsl:if test="@calculation != ''">
							<xsl:attribute name="data-calculation">
								<xsl:value-of select="@calculation" />
							</xsl:attribute>
						</xsl:if>

					</input>

					<!-- //Append content if required -->
					<xsl:if test="@append_content != ''">
						<span class="input-group-addon">
							<xsl:value-of select="@append_content" />
						</span>
					</xsl:if>

				</div>
			</xsl:when>

			<!-- //Range -->
			<xsl:when test="@type = 'range'">
				<input type="text" data-ui-slider="data-ui-slider" name="question[{@question_id}][{$index}][{@answer_id}]" data-slider-min="{@range_min}" data-slider-max="{@range_max}" data-slider-step="{@range_step}" data-unit="{@range_unit}" data-slider-orientation="horizontal" data-slider-value="{../result[@answer_id = current()/@answer_id]/@value}" class="slider slider-range slider-horizontal{$hasChildren}" data-slider-id="question[{@question_id}][{@answer_id}]" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}">

					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id][@index = $index]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<xsl:attribute name="data-slider-value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id][@index = $index]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

				</input>
				<div class="row">
					<div class="col-md-6">
						<small>
							<xsl:value-of select="concat(@range_min, ' ', @range_unit)" />
						</small>
					</div>
					<div class="col-md-6 text-right">
						<small>
							<xsl:value-of select="concat(@range_max, ' ', @range_unit)" />
						</small>
					</div>
				</div>
			</xsl:when>

			<!-- //Percent -->
			<xsl:when test="@type = 'percent'">
				<input type="text" data-ui-slider="data-ui-slider" name="question[{@question_id}][{$index}][{@answer_id}]" data-slider-min="0" data-slider-max="100" data-slider-step="1" data-slider-orientation="horizontal" data-slider-value="{../result[@answer_id = current()/@answer_id]/@value}" class="slider slider-percent slider-horizontal{$hasChildren}" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}">

					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id][@index = $index]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<xsl:attribute name="data-slider-value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id][@index = $index]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

				</input>
			</xsl:when>

			<!-- //URL -->
			<xsl:when test="@type = 'url'">
				<input type="url" name="question[{@question_id}][{$index}][{@answer_id}]" id="question-{../@question_id}-{@answer_id}" placeholder="{@string}" class="form-control{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}">

					<!-- //Set the value to client_result or default value -->
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id][@index = $index]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

				</input>
			</xsl:when>

			<!-- //Email -->
			<xsl:when test="@type = 'email'">
				<input type="email" name="question[{@question_id}][{$index}][{@answer_id}]" placeholder="{@string}" class="form-control{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}">

					<!-- //Set the value to client_result or default value -->
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id][@index = $index]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

				</input>
			</xsl:when>

			<!-- //Label -->
			<xsl:when test="@type = 'label'">
				<div class="entry question answer label-answer">
					<xsl:value-of select="@string" />
				</div>
			</xsl:when>

			<!-- //Drop Down List -->
			<xsl:when test="@type = 'drop-down-list'">

				<!-- //First Check to see if this is the first child answer, if not, do not render -->
				<xsl:if test="not(preceding-sibling::*[1]/@type)">
					<div class="select drop-down-list">
						<select name="question[{@question_id}][{$index}][]" class="form-control {$hasChildren} chosen-select" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}">

							<!-- //Mulitple -->
							<xsl:choose>
								<xsl:when test="../@multiple_answer = '1'">
									<xsl:attribute name="multiple">multiple</xsl:attribute>
									<xsl:attribute name="data-placeholder">-- select --</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<option value="">-- select --</option>
								</xsl:otherwise>
							</xsl:choose>

							<xsl:for-each select="../answer">
								<xsl:sort select="@sequence" data-type="number" />
								<option value="{@answer_id}">
									<xsl:choose>
										<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:when>
										<xsl:when test="@default_value = 'selected'">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:when>
										<xsl:otherwise></xsl:otherwise>
									</xsl:choose>
									<xsl:value-of select="@string" disable-output-escaping="yes" />
								</option>
							</xsl:for-each>
						</select>
						<i></i>
					</div>
				</xsl:if>
			</xsl:when>

			<!-- //File Upload -->

			<xsl:when test="@type= 'file-upload'">

				<!-- //Set the upload parameters -->
				<xsl:variable name="file" select="../result[@answer_id = current()/@answer_id][@index = $index]" />

				<div class="row">
					<div class="col-md-6 col-sm-12">

						<div class="file-upload-container file-upload">
							<!-- The fileinput-button span is used to style the file input field as button -->
							<div class="row">
								<div class="col-md-12 file-upload-button collapse">
									<span class="btn btn-success btn-icon fa-plus fileinput-button">
										<span>Select file...</span>
										<!-- The file input field used as target for the file upload widget -->
										<input type="file" name="file-upload-{@answer_id}" class="bimp file-upload" data-id="{@answer_id}" data-index="{$index}" />
										<input type="hidden" name="question[{@question_id}][{$index}][{@answer_id}]" value="{$file/@value}" data-input="file-{@answer_id}" data-name="{$file/@filename}" data-size="{$file/@filesize}" readonly="readonly" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}" />
									</span>
								</div>
								<div class="col-md-12 file-delete-button collapse">
									<span class="btn btn-danger btn-icon fa-trash delete" data-id="{@answer_id}" data-index="{$index}">
										<span>Delete file</span>
									</span>
								</div>
								<div class="col-md-12">
									<div class="file-name-status"></div>
								</div>
							</div>
							<div class="row">
								<div class="col-md-12">
									<!-- The global progress bar -->
									<div class="progress">
										<div class="progress-bar progress-bar-success"></div>
									</div>
								</div>
							</div>
						</div>

					</div>
				</div>
			</xsl:when>

			<!-- //Date -->
			<xsl:when test="@type = 'date' or @type = 'date-month' or @type = 'date-quarter'">
				<xsl:variable name="date-type">
					<xsl:choose>
						<xsl:when test="@type = 'date'"> day</xsl:when>
						<xsl:when test="@type = 'date-month'"> month</xsl:when>
						<xsl:when test="@type = 'date-quarter'"> quarter</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<div class="input-group date date-time-picker{$date-type}">
					<input type="text" name="question[{@question_id}][{$index}][{@answer_id}]" value="{../result[@answer_id = current()/@answer_id][@index = $index]/@value}" placeholder="{@string}" class="form-control{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}" />
					<span class="input-group-addon">
	                	<span class="fa fa-calendar"></span>
	             	</span>
             	</div>
			</xsl:when>

			<!-- //Text or otherwise -->
			<xsl:otherwise>

				<xsl:variable name="countable">
					<xsl:choose>
						<xsl:when test="@range_min &gt; 0 or @range_max &gt; 0">countable</xsl:when>
						<xsl:otherwise></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<input type="text" name="question[{@question_id}][{$index}][{@answer_id}]" placeholder="{@string}" class="form-control{$countable}{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-type="question" data-question-id="{@question_id}" data-index="{$index}" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}">

					<!-- //Set the value to client_result or default value -->
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id][@index = $index]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id][@index = $index]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<xsl:if test="@range_min &gt; 0">
						<xsl:attribute name="data-parsley-minwords">
							<xsl:value-of select="@range_min" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@range_max &gt; 0">
						<xsl:attribute name="data-parsley-maxwords">
							<xsl:value-of select="@range_max" />
						</xsl:attribute>
					</xsl:if>

				</input>

				<!-- //Max Words Message -->
				<xsl:choose>
					<xsl:when test="@range_min &gt; 0 and @range_max &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
							Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
					<xsl:when test="@range_min &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
					<xsl:when test="@range_max &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
				</xsl:choose>

			</xsl:otherwise>

		</xsl:choose>

	</xsl:template>


	<!-- //Additional Page Notes Field -->
	<xsl:template name="page-notes" mode="entry">
        
        <xsl:if test="clientChecklist/page/@show_notes_field = '1'">

        	<xsl:variable name="notes-field-title">
        		<xsl:choose>
        			<xsl:when test="clientChecklist/page/@notes_field_title != ''">
        				<xsl:value-of select="clientChecklist/page/@notes_field_title" />
        			</xsl:when>
        			<xsl:otherwise>
        				<xsl:text>Additional Information</xsl:text>
        			</xsl:otherwise>
        		</xsl:choose>
        	</xsl:variable>

        	<xsl:variable name="notes-field-placeholder">
        		<xsl:choose>
        			<xsl:when test="clientChecklist/page/@notes_field_placeholder != ''">
        				<xsl:value-of select="clientChecklist/page/@notes_field_placeholder" />
        			</xsl:when>
        			<xsl:otherwise>
        				<xsl:text>Add any additional information relevant to this section</xsl:text>
        			</xsl:otherwise>
        		</xsl:choose>
        	</xsl:variable>

        	<div class="row">
				<fieldset class="entry note col-md-12">
					<div class="entry note form-group">
						<label for="page-note-id-{clientChecklist/page/@page_id}" class="entry question-content">
							<xsl:value-of select="$notes-field-title" />
							<xsl:call-template name="page-notes-options" mode="entry" />
						</label>

						<textarea name="note" rows="2" class="form-control" placeholder="{$notes-field-placeholder}">
							<xsl:choose>
								<xsl:when test="/config/globals/item[@key = 'note']">
									<xsl:value-of select="/config/globals/item[@key = 'note']/@value" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="clientChecklist/page/@note" />
								</xsl:otherwise>
							</xsl:choose>
						</textarea>
					</div>
				</fieldset>
			</div>
        </xsl:if>

	</xsl:template>

	<xsl:template name="assessment-buttons" mode="entry">

        <div id="assessment-footer" class="row">

        	<!-- //Only show the previous/next buttons if there is more than 1 page -->
        	<xsl:if test="clientChecklist/@pages &gt; 1">
	            <div class="buttons navigation-buttons">

	            	<!-- //Check for the first or last page in the assessment -->
	            	<xsl:variable name="previous-button-status">
	            		<xsl:if test="clientChecklist/checklistPage[1]/@page_id = clientChecklist/@current_page">
	            			<xsl:text> disabled</xsl:text>
	            		</xsl:if>
	            	</xsl:variable>

	            	<xsl:variable name="next-button-status">
						<xsl:choose>
							<xsl:when test="clientChecklist/checklistPage[last()]/@page_id = clientChecklist/@current_page">
								<xsl:text> disabled</xsl:text>
							</xsl:when>
							<xsl:when test="clientChecklist/checklistPage[@page_id = ../page/@page_id]/@last_page = '1'">
								<xsl:text> disabled</xsl:text>
							</xsl:when>
						</xsl:choose>
	            	</xsl:variable>

	            	<!-- //Previous Button -->
	            	<div class="col-sm-6 col-md-5">
						<a class="btn btn-base btn-icon fa-chevron-left assessment-footer-buttons{$previous-button-status}" id="entry-previous-page" data-action="previous">
							<span>Previous</span>
						</a>
					</div>

					<!-- //Next Button -->
					<div class="col-sm-6 col-md-5 col-md-offset-2">
						<a class="btn btn-base btn-icon btn-icon-right fa-chevron-right pull-right assessment-footer-buttons{$next-button-status} col-md-4" id="entry-next-page" data-action="next">
							<span>Next</span>
						</a>
					</div>

	            </div>
	         </xsl:if>

			<xsl:choose>
				<xsl:when test="clientChecklist/@submitable = '1'">
					<xsl:choose>
						<xsl:when test="clientChecklist/page/@submitable = '1'">
							<div class="entry buttons submit-button col-sm-6 col-sm-offset-3 col-md-6 col-md-offset-3">
								<a class="btn btn-alt btn-icon btn-icon-right fa-paper-plane pull-right assessment-footer-buttons col-md-4" id="entry-submit" data-action="submit">
									<span>Submit</span>
								</a>                               
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div class="entry buttons submit-button col-sm-6 col-sm-offset-3 col-md-6 col-md-offset-3">
								<a href="#" class="btn btn-base btn-icon fa-save pull-right assessment-footer-buttons col-md-4 entry-save-page" data-action="save">
									<span>Save</span>
								</a>                            
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<div class="entry buttons submit-button col-sm-6 col-sm-offset-3 col-md-6 col-md-offset-3">
						<a href="#" class="btn btn-base btn-icon fa-save pull-right assessment-footer-buttons col-md-4 entry-save-page" data-action="save">
							<span>Save</span>
						</a>                            
					</div>
				</xsl:otherwise>
			</xsl:choose>

        </div>

	</xsl:template>

	<!-- //All icons that are related to a question -->
	<xsl:template name="question-options" mode="entry">
		<xsl:param name="grouping" />
		<xsl:param name="class" />
		
		<!--//Required -->
		<xsl:if test="@required = '1'">
			<span class="entry question icon required fa fa-asterisk" />
		</xsl:if>
										
		<!-- //Information/Tip/Previous Results -->
		<xsl:if test="@information != '' or @tip != '' or count(previousResults/previousResult) &gt; 0">
			<a class="entry question icon information fa fa-question-circle" data-toggle="modal" data-target="#question-{@question_id}-options-class{$class}" rel="tooltip" data-original-title="Click for help, previous results and other information." />
		</xsl:if>

		<!-- //Call the modal template -->
		<xsl:call-template name="question-options-panel" mode="entry">
			<xsl:with-param name="grouping" select="$grouping" />
			<xsl:with-param name="class" select="$class" />
		</xsl:call-template>
	</xsl:template>

	<!-- //All question option content -->
	<xsl:template name="question-options-panel" mode="entry">
		<xsl:param name="grouping" />
		<xsl:param name="class" />
		<xsl:variable name="question" select="." />
		
		<div class="question-options modal fade previous-results-modal {$class}" data-keyboard="false" data-backdrop="static" id="question-{@question_id}-options-class{$class}" tabindex="-1" role="dialog" aria-labelledby="question-{@question_id}-options-title">
			<div class="modal-dialog modal-lg" role="document">
				<div class="modal-content">
					<div class="modal-header bg-base">
						<h4 class="modal-title" id="question-{@question_id}-options-title">Help &amp; Information</h4>
					</div>
					<div class="modal-body">
						<div class="row">
							<!-- Help -->
							<xsl:if test="@tip != ''">
								<div class="col-md-12">
									<h5>Help</h5>
									<div class="col-md-12 entry help-content">
										<xsl:value-of select="@tip" disable-output-escaping="yes" />
									</div>
								</div>
							</xsl:if>
							<!-- Information -->
							<xsl:if test="@information != ''">
								<div class="col-md-12 entry information-content">
									<h5>Information</h5>
									<div class="col-md-12">
										<xsl:value-of select="@information" disable-output-escaping="yes" />
									</div>
								</div>
							</xsl:if>
							<!-- Previous Results -->
							<xsl:if test="count(previousResults/previousResult) &gt; 0">
								<div class="col-md-12">
									<h5>Previous Responses</h5>
									<div class="col-md-12">
										<xsl:for-each select="previousResults/previousResult">
											<xsl:sort select="@client_checklist_id" data-type="number" order="descending" />
											<xsl:variable name="previousResult" select="." />
											<xsl:variable name="previousNode" select="preceding-sibling::previousResult[1]" />
											<xsl:variable name="nextNode" select="following-sibling::previousResult[1]" />

											<xsl:variable name="new-client-checklist">
												<xsl:choose>
													<xsl:when test="$previousNode/@client_checklist_id != $previousResult/@client_checklist_id or not($previousNode)">
														<xsl:value-of select="'true'" />
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="'false'" />
													</xsl:otherwise>
												</xsl:choose>
											</xsl:variable>

											<xsl:variable name="end-client-checklist">
												<xsl:choose>
													<xsl:when test="$nextNode/@client_checklist_id != $previousResult/@client_checklist_id or not($nextNode)">
														<xsl:value-of select="'true'" />
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="'false'" />
													</xsl:otherwise>
												</xsl:choose>
											</xsl:variable>

											<xsl:if test="$new-client-checklist = 'true'">
												<h6>
													<span class="display-date day">
														<xsl:value-of select="@period_day" />
														<xsl:text> </xsl:text>
													</span>
													<span class="display-date month">
														<xsl:value-of select="@period_month" />
														<xsl:text> </xsl:text>
													</span>
													<span class="display-date year">
														<xsl:value-of select="@period_year" />
														<xsl:text> </xsl:text>
													</span>
													<span class="display-date separator">
														<xsl:text>to </xsl:text>
													</span>
													<span class="display-date finish_day">
														<xsl:value-of select="@period_finish_day" />
														<xsl:text> </xsl:text>
													</span>
													<span class="display-date finish_month">
														<xsl:value-of select="@period_finish_month" />
														<xsl:text> </xsl:text>
													</span>
													<span class="display-date finish_year">
														<xsl:value-of select="@period_finish_year" />
														<xsl:text> </xsl:text>
													</span>
												</h6>
											</xsl:if>
											<div class="col-md-12">
												<xsl:variable name="loop_position">
													<xsl:choose>
														<xsl:when test="position() = last()">
															<xsl:value-of select="concat('poisition-', position(), ' last')" />
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="concat('poisition-', position())" />
														</xsl:otherwise>
													</xsl:choose>
												</xsl:variable>
												<xsl:choose>
													<xsl:when test="$grouping = 'index'">
														<p class="client-checklist-{$previousResult/@client_checklist_id} question-{$previousResult/@question_id} answer-{$previousResult/@answer_id} index-{$previousResult/@index} {$loop_position} {$end-client-checklist}">
															<xsl:for-each select="../../../question/previousResults/previousResult[@client_checklist_id = $previousResult/@client_checklist_id][@index = $previousResult/@index]">
																<span class="previous-result question-id-{@question_id} answer-id-{@answer_id}">
																	<xsl:if test="position() != 1">
																		<xsl:text></xsl:text>
																	</xsl:if>
																	<xsl:choose>
																		<xsl:when test="@result != ''">
																			<xsl:value-of select="@result" />
																		</xsl:when>
																		<xsl:otherwise>
																			<xsl:text>N/A</xsl:text>
																		</xsl:otherwise>
																	</xsl:choose>
																</span>
															</xsl:for-each>
														</p>
													</xsl:when>
													<xsl:when test="$question/@index = '0'">
														<p class="client-checklist-{$previousResult/@client_checklist_id} question-{$previousResult/@question_id} answer-{$previousResult/@answer_id} index-{$previousResult/@index} {$loop_position} {$end-client-checklist}">
															<span class="previous-result question-id-{@question_id} answer-id-{@answer_id}">
																<xsl:value-of select="@result" />
															</span>
														</p>
													</xsl:when>
													<xsl:otherwise>
														<p class="client-checklist-{$previousResult/@client_checklist_id} question-{$previousResult/@question_id} answer-{$previousResult/@answer_id} index-{$previousResult/@index} {$loop_position} {$end-client-checklist}">
															<xsl:for-each select="../../../question[@index = $question/@index]/previousResults/previousResult[@client_checklist_id = $previousResult/@client_checklist_id]">
																<xsl:variable name="position">
																	<xsl:choose>
																		<xsl:when test="position() = last()">
																			<xsl:value-of select="concat('poisition-', position(), ' last')" />
																		</xsl:when>
																		<xsl:otherwise>
																			<xsl:value-of select="concat('poisition-', position())" />
																		</xsl:otherwise>
																	</xsl:choose>
																</xsl:variable>
																<span class="previous-result question-id-{@question_id} answer-id-{@answer_id}">
																	<xsl:if test="position() != 1">
																		<xsl:text></xsl:text>
																	</xsl:if>
																	<xsl:choose>
																		<xsl:when test="@result != ''">
																			<xsl:value-of select="@result" />
																		</xsl:when>
																		<xsl:otherwise>
																			<xsl:text>N/A</xsl:text>
																		</xsl:otherwise>
																	</xsl:choose>
																</span>
															</xsl:for-each>
														</p>
													</xsl:otherwise>
												</xsl:choose>
											</div>
										</xsl:for-each>
									</div>
								</div>
							</xsl:if>
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- //All icons that are related to the page notes -->
	<xsl:template name="page-notes-options" mode="entry">
										
		<!-- //Page Notes Icons -->
		<xsl:if test="count(clientChecklist/page/previousNotes/previousNote) &gt; 0">
			<a class="entry question icon information fa fa-question-circle" data-toggle="modal" data-target="#page-notes-{clientChecklist/page/@page_id}-options" rel="tooltip" data-original-title="Click for help, previous results and other information." />
		</xsl:if>

		<!-- //Call the modal template -->
		<xsl:call-template name="page-notes-options-panel" mode="entry" />
	</xsl:template>

	<!-- //All question option content -->
	<xsl:template name="page-notes-options-panel" mode="entry">									
		<div class="page-notes-options modal fade" data-keyboard="false" data-backdrop="static" id="page-notes-{clientChecklist/page/@page_id}-options" tabindex="-1" role="dialog" aria-labelledby="page-notes-{clientChecklist/page/@page_id}-options-title">
			<div class="modal-dialog modal-lg" role="document">
				<div class="modal-content">
					<div class="modal-header bg-base">
						<h4 class="modal-title" id="page-notes-{clientChecklist/page/@page_id}-options-title">Help &amp; Information</h4>
					</div>
					<div class="modal-body">
						<div class="row">
							<!-- Previous Results -->
							<xsl:if test="count(clientChecklist/page/previousNotes/previousNote) &gt; 0">
								<div class="col-md-12">
									<h5>Previous Responses</h5>
									<div class="col-md-12">
										<xsl:for-each select="clientChecklist/page/previousNotes/previousNote">
											<h6>
												<span class="display-date day">
													<xsl:value-of select="@period_day" />
													<xsl:text> </xsl:text>
												</span>
												<span class="display-date month">
													<xsl:value-of select="@period_month" />
													<xsl:text> </xsl:text>
												</span>
												<span class="display-date year">
													<xsl:value-of select="@period_year" />
													<xsl:text> </xsl:text>
												</span>
												<span class="display-date separator">
													<xsl:text>to </xsl:text>
												</span>
												<span class="display-date finish_day">
													<xsl:value-of select="@period_finish_day" />
													<xsl:text> </xsl:text>
												</span>
												<span class="display-date finish_month">
													<xsl:value-of select="@period_finish_month" />
													<xsl:text> </xsl:text>
												</span>
												<span class="display-date finish_year">
													<xsl:value-of select="@period_finish_year" />
													<xsl:text> </xsl:text>
												</span>
											</h6>
											<div class="col-md-12">
												<p>
													<xsl:value-of select="@note" />
												</p>
											</div>
										</xsl:for-each>
									</div>
								</div>
							</xsl:if>
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- //Data Validation -->
	<xsl:template match="validation" mode="html">
		<xsl:variable name="scope" select="@scope" />
		<xsl:variable name="clientChecklist" select="/config/plugin[@plugin = 'checklist'][@method = 'loadEntry']/clientChecklist" />

		<div class="data-validation">
			<xsl:choose>
				<xsl:when test="$scope = 'section'">
					<xsl:choose>
						<xsl:when test="count($clientChecklist/validation/variation/currentResponse[@page_section_id = ../../../page/@page_section_id]) &gt; 0">
							<xsl:for-each select="$clientChecklist/validation/variation">
								<xsl:if test="currentResponse/@page_section_id = ../../page/@page_section_id">
									<xsl:call-template name="validation-item">
										<xsl:with-param name="scope" select="$scope" />
									</xsl:call-template>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="no-validation" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="count($clientChecklist/validation/variation) &gt; 0">
							<xsl:for-each select="$clientChecklist/validation/variation">
								<xsl:call-template name="validation-item">
									<xsl:with-param name="scope" select="$scope" />
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="no-validation" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</div>

	</xsl:template>

	<xsl:template name="no-validation">
		<div class="well">
			<p>No data validation required.</p>
		</div>
	</xsl:template>

	<xsl:template name="validation-item">
		<xsl:param name="scope" />
		<xsl:variable name="key" select="currentResponse/@key" />

		<div class="data-validation-item">

			<div class="row">
				<div class="col-md-4">
					<label>
						<xsl:choose>
							<xsl:when test="$scope = 'section'">
								<xsl:value-of select="currentResponse/@page_title" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="currentResponse/@page_section_title != ''">
										<xsl:value-of select="concat(currentResponse/@page_section_title, ' - ', currentResponse/@page_title)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="currentResopnse/@page_title" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</label>
				</div>
				<div class="col-md-3">
					<label>Previously</label>
				</div>
				<div class="col-md-3">
					<label>Currently</label>
				</div>
				<div class="col-md-2">
					<label>Change</label>
				</div>
			</div>

			<div class="row">
				<div class="col-md-4">
					<xsl:choose>
						<xsl:when test="currentResponse/@repeatable = 1 and currentResponse/@alt_key != ''">
							<xsl:value-of select="currentResponse/@alt_key" />
						</xsl:when>
						<xsl:when test="currentResponse/@export_key != ''">
							<xsl:value-of select="currentResponse/@export_key" />
						</xsl:when>
						<xsl:when test="currentResponse/@question != ''">
							<xsl:value-of select="currentResponse/@question" />
						</xsl:when>
					</xsl:choose>
					<xsl:if test="currentResponse/@token">
						<xsl:text> </xsl:text>
						<a href="{concat('/members/entry/', ../../@client_checklist_id, '/?p=', currentResponse/@token, '#', currentResponse/@question_id)}" target="_blank">
							<i class="fa fa-link" />
						</a>
					</xsl:if>
				</div>
				<div class="col-md-3">
					<xsl:for-each select="previousResponse">
						<xsl:choose>
							<xsl:when test="@answer_type = 'checkbox' or @answer_type = 'checkbox-other' or @answer_type = 'drop-down-list'">
								<xsl:value-of select="@answer_string" />
							</xsl:when>
							<xsl:when test="@answer_type = 'percent'">
								<xsl:value-of select="@arbitrary_value" />%
							</xsl:when>
							<xsl:when test="@answer_type = 'range'">
								<xsl:value-of select="@arbitrary_value" />
								<xsl:value-of select="@range_unit" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@arbitrary_value" />
							</xsl:otherwise>
						</xsl:choose><br />
					</xsl:for-each>
				</div>
				<div class="col-md-3">
					<xsl:for-each select="currentResponse">
						<xsl:choose>
							<xsl:when test="@answer_type = 'checkbox' or @answer_type = 'checkbox-other' or @answer_type = 'drop-down-list'">
								<xsl:value-of select="@answer_string" />
							</xsl:when>
							<xsl:when test="@answer_type = 'percent'">
								<xsl:value-of select="@arbitrary_value" />%
							</xsl:when>
							<xsl:when test="@answer_type = 'range'">
								<xsl:value-of select="@arbitrary_value" />
								<xsl:value-of select="@range_unit" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@arbitrary_value" />
							</xsl:otherwise>
						</xsl:choose><br />
					</xsl:for-each>
				</div>
				<div class="col-md-2">
					<xsl:choose>
						<xsl:when test="change/@difference != '' and change/@percent != ''">
							<xsl:value-of select="change/@difference" /> (<xsl:value-of select="change/@percent" />%)
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="change/@difference" />
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<hr />

			<!-- //Input -->
			<div class="row">
				<div class="col-md-6">
					<label>Suggested reason for change</label>
				</div>
				<div class="col-md-6">
					<label>Additional Explanation</label>
				</div>
			</div>

			<div class="row">
				<div class="col-md-6">
					<select name="variation-response-option[{../../@client_checklist_id}][{currentResponse/@key}]">
						<option value="">-- select --</option>
						<xsl:for-each select="../variationResponseOption">
							<option value="{@variation_option_id}">
								<xsl:if test="../variationResponse[@key = $key]/@variation_option_id = current()/@variation_option_id">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="@variation" />
							</option>
						</xsl:for-each>
					</select>
				</div>
				<div class="col-md-6">
					<input type="text" name="variation-response-reason[{../../@client_checklist_id}][{currentResponse/@key}]" value="{../variationResponse[@key = $key]/@reason}" placeholder="Additional explanation (optional)" />
				</div>
			</div>
		</div>

	</xsl:template>

	<!-- //Legacy Templates  -->
	<!-- Answer Template -->
	<xsl:template match="answer-legacy" mode="entry">

		<!-- //Check to see if the answer has children -->
		<xsl:variable name="hasChildren">
			<xsl:if test="@hasChildren = '1'">
				<xsl:text>hasChildren </xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="checkboxOther">
			<xsl:if test="@type = 'checkbox-other'">
				<xsl:text>checkboxOther</xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="checkboxOtherTriggered">
			<xsl:if test="@type = 'checkbox-other'">
				<xsl:choose>
					<xsl:when test="../result[@answer_id = current()/@answer_id]">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>

		<xsl:choose>
			<!-- //Checkbox and Radio Buttons -->
			<xsl:when test="@type = 'checkbox' or @type = 'checkbox-other'">
				<xsl:choose>

					<!-- //Checkbox (Multiple Answers Allowed) -->
					<xsl:when test="../@multiple_answer = '1'">
						<div class="checkbox c-checkbox">
							<label>
								<input type="checkbox" data-answerId="{@answer_id}" name="question[{@question_id}][]" value="{@answer_id}" class="{$hasChildren}{$checkboxOther}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message">
									<xsl:choose>
										<xsl:when test="../result[@answer_id = current()/@answer_id]">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:when>
										<xsl:when test="@default_value = 'selected'">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:when>
										<xsl:otherwise></xsl:otherwise>
									</xsl:choose>
									<xsl:if test="@range_min &gt; 0">
										<xsl:attribute name="data-parsley-mincheck">
											<xsl:value-of select="@range_min" />
										</xsl:attribute>
									</xsl:if>
									<xsl:if test="@range_max &gt; 0">
										<xsl:attribute name="data-parsley-maxcheck">
											<xsl:value-of select="@range_max" />
										</xsl:attribute>
									</xsl:if>
								</input>
								<span class="fa fa-check"></span>
								<div class="entry answer-string">
									<xsl:value-of select="@string" disable-output-escaping="yes" />
								</div>
							</label>
						</div>

						<!-- Checkbox Other -->
						<xsl:if test="@type = 'checkbox-other'">

							<xsl:variable name="countable">
								<xsl:choose>
									<xsl:when test="@range_min &gt; 0 or @range_max &gt; 0">countable</xsl:when>
									<xsl:otherwise></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<input type="text" name="question-other[{@answer_id}]" placeholder="please provide more information" class="form-control question-other {$countable}" data-parsley-required="required" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-triggered="{$checkboxOtherTriggered}" data-questionId="{@question_id}" data-answerId="{@answer_id}" data-question-id="{@question_id}" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}">
								<xsl:attribute name="value">
									<xsl:choose>
										<xsl:when test="../result[@answer_id = current()/@answer_id]">
											<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="@default_value" />						
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>

								<!-- Word Limit -->
								<xsl:if test="@range_min &gt; 0">
									<xsl:attribute name="data-parsley-minwords">
										<xsl:value-of select="@range_min" />
									</xsl:attribute>
								</xsl:if>
								<xsl:if test="@range_max &gt; 0">
									<xsl:attribute name="data-parsley-maxwords">
										<xsl:value-of select="@range_max" />
									</xsl:attribute>
								</xsl:if>

							</input>

							<!-- //Max Words Message -->
							<xsl:choose>
								<xsl:when test="@range_min &gt; 0 and @range_max &gt; 0">
									<div class="{@answer_id} counter-message text-right">
										Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
										Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
										<span class="word-counter">
											<xsl:text>Word count: </xsl:text><span class="counter"></span>
										</span>
									</div>
								</xsl:when>
								<xsl:when test="@range_min &gt; 0">
									<div class="{@answer_id} counter-message text-right">
										Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
										<span class="word-counter">
											<xsl:text>Word count: </xsl:text><span class="counter"></span>
										</span>
									</div>
								</xsl:when>
								<xsl:when test="@range_max &gt; 0">
									<div class="{@answer_id} counter-message text-right">
										Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
										<span class="word-counter">
											<xsl:text>Word count: </xsl:text><span class="counter"></span>
										</span>
									</div>
								</xsl:when>
							</xsl:choose>

						</xsl:if>
					</xsl:when>

					<!-- //Radio Buttons (Single Answer Only) -->
					<xsl:otherwise>
						<div class="radio c-radio">
							<label>
								<input type="radio" data-answerId="{@answer_id}" data-questionId="{@question_id}" name="question[{@question_id}]" value="{@answer_id}" class="{$hasChildren}{$checkboxOther}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message">
									<xsl:choose>
										<xsl:when test="../result[@answer_id = current()/@answer_id]">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:when>
										<xsl:when test="@default_value = 'selected'">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:when>
										<xsl:otherwise></xsl:otherwise>
									</xsl:choose>
								</input>
								<span class="fa fa-check"></span>
								<div class="entry answer-string">
									<xsl:value-of select="@string" disable-output-escaping="yes" />
								</div>
							</label>
						</div>

						<!-- Checkbox Other -->
						<xsl:if test="@type = 'checkbox-other'">

							<xsl:variable name="countable">
								<xsl:choose>
									<xsl:when test="@range_min &gt; 0 or @range_max &gt; 0">countable</xsl:when>
									<xsl:otherwise></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<input type="text" name="question-other[{@answer_id}]" placeholder="please provide more information" class="form-control question-other {$countable}" data-parsley-required="required" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-triggered="{$checkboxOtherTriggered}" data-questionId="{@question_id}" data-answerId="{@answer_id}" data-question-id="{@question_id}" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}">
								<xsl:attribute name="value">
									<xsl:choose>
										<xsl:when test="../result[@answer_id = current()/@answer_id]">
											<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="@default_value" />						
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>

								<!-- Word Limit -->
								<xsl:if test="@range_min &gt; 0">
									<xsl:attribute name="data-parsley-minwords">
										<xsl:value-of select="@range_min" />
									</xsl:attribute>
								</xsl:if>
								<xsl:if test="@range_max &gt; 0">
									<xsl:attribute name="data-parsley-maxwords">
										<xsl:value-of select="@range_max" />
									</xsl:attribute>
								</xsl:if>

							</input>

							<!-- //Max Words Message -->
							<xsl:choose>
								<xsl:when test="@range_min &gt; 0 and @range_max &gt; 0">
									<div class="{@answer_id} counter-message text-right">
										Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
										Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
										<span class="word-counter">
											<xsl:text>Word count: </xsl:text><span class="counter"></span>
										</span>
									</div>
								</xsl:when>
								<xsl:when test="@range_min &gt; 0">
									<div class="{@answer_id} counter-message text-right">
										Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
										<span class="word-counter">
											<xsl:text>Word count: </xsl:text><span class="counter"></span>
										</span>
									</div>
								</xsl:when>
								<xsl:when test="@range_max &gt; 0">
									<div class="{@answer_id} counter-message text-right">
										Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
										<span class="word-counter">
											<xsl:text>Word count: </xsl:text><span class="counter"></span>
										</span>
									</div>
								</xsl:when>
							</xsl:choose>

						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- //Textbox -->
			<xsl:when test="@type = 'textarea'">

				<xsl:variable name="countable">
					<xsl:choose>
						<xsl:when test="@range_min &gt; 0 or @range_max &gt; 0">countable</xsl:when>
						<xsl:otherwise></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<textarea name="question[{@question_id}][{@answer_id}]" rows="{@number_of_rows}" placeholder="{@string}" class="form-control {$countable}{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" data-answer-id="{@answer_id}" data-answer-type="{$answer-type}">
					<xsl:if test="@range_min &gt; 0">
						<xsl:attribute name="data-parsley-minwords">
							<xsl:value-of select="@range_min" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@range_max &gt; 0">
						<xsl:attribute name="data-parsley-maxwords">
							<xsl:value-of select="@range_max" />
						</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="../result[@answer_id = current()/@answer_id]">
							<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@default_value" />						
						</xsl:otherwise>
					</xsl:choose>
				</textarea>

				<!-- //Max Words Message -->
				<xsl:choose>
					<xsl:when test="@range_min &gt; 0 and @range_max &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
							Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
					<xsl:when test="@range_min &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
					<xsl:when test="@range_max &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
				</xsl:choose>
			</xsl:when>

			<!-- //Int -->
			<xsl:when test="@type = 'int'">
				<input type="number" step="1" name="question[{@question_id}][{@answer_id}]" placeholder="{@string}" class="form-control{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message">
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:if test="@range_min != ''">
						<xsl:attribute name="min">
							<xsl:value-of select="@range_min" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@range_max != ''">
						<xsl:attribute name="max">
							<xsl:value-of select="@range_max" />
						</xsl:attribute>
					</xsl:if>
				</input>
			</xsl:when>

			<!-- //Float -->
			<xsl:when test="@type = 'float'">

				<xsl:variable name="input-group-class">
					<xsl:choose>
						<xsl:when test="@prepend_content != '' and @append_content != ''">
							<xsl:value-of select="'input-group m-b prepend append'" />
						</xsl:when>
						<xsl:when test="@prepend_content != ''">
							<xsl:value-of select="'input-group m-b prepend'" />
						</xsl:when>
						<xsl:when test="@append_content != ''">
							<xsl:value-of select="'input-group m-b append'" />
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<div class="{$input-group-class}">

					<!-- //Prepend content if required -->
					<xsl:if test="@prepend_content != ''">
						<span class="input-group-addon">
							<xsl:value-of select="@prepend_content" />
						</span>
					</xsl:if>

					<input type="number" step="any" name="question[{@question_id}][{@answer_id}]" placeholder="{@string}" class="form-control{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message">

						<!-- //Set the value to client_result or default value -->
						<xsl:attribute name="value">
							<xsl:choose>
								<xsl:when test="../result[@answer_id = current()/@answer_id]">
									<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@default_value" />						
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>

						<xsl:if test="@range_min != ''">
							<xsl:attribute name="min">
								<xsl:value-of select="@range_min" />
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="@range_max != ''">
							<xsl:attribute name="max">
								<xsl:value-of select="@range_max" />
							</xsl:attribute>
						</xsl:if>

						<!-- //Check for auto calculation -->
						<xsl:if test="@calculation != ''">
							<xsl:attribute name="data-calculation">
								<xsl:value-of select="@calculation" />
							</xsl:attribute>
						</xsl:if>

					</input>

					<!-- //Append content if required -->
					<xsl:if test="@append_content != ''">
						<span class="input-group-addon">
							<xsl:value-of select="@append_content" />
						</span>
					</xsl:if>

				</div>
			</xsl:when>

			<!-- //Range -->
			<xsl:when test="@type = 'range'">
				<input type="text" data-ui-slider="data-ui-slider" name="question[{@question_id}][{@answer_id}]" data-slider-min="{@range_min}" data-slider-max="{@range_max}" data-slider-step="{@range_step}" data-unit="{@range_unit}" data-slider-orientation="horizontal" data-slider-value="{../result[@answer_id = current()/@answer_id]/@value}" class="slider slider-range slider-horizontal{$hasChildren}" data-slider-id="question[{@question_id}][{@answer_id}]">

					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<xsl:attribute name="data-slider-value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

				</input>
				<div class="row">
					<div class="col-md-6">
						<small>
							<xsl:value-of select="concat(@range_min, ' ', @range_unit)" />
						</small>
					</div>
					<div class="col-md-6 text-right">
						<small>
							<xsl:value-of select="concat(@range_max, ' ', @range_unit)" />
						</small>
					</div>
				</div>
			</xsl:when>

			<!-- //Percent -->
			<xsl:when test="@type = 'percent'">
				<input type="text" data-ui-slider="data-ui-slider" name="question[{@question_id}][{@answer_id}]" data-slider-min="0" data-slider-max="100" data-slider-step="1" data-slider-orientation="horizontal" data-slider-value="{../result[@answer_id = current()/@answer_id]/@value}" class="slider slider-percent slider-horizontal{$hasChildren}">

					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<xsl:attribute name="data-slider-value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

				</input>
			</xsl:when>

			<!-- //URL -->
			<xsl:when test="@type = 'url'">
				<input type="url" name="question[{@question_id}][{@answer_id}]" id="question-{../@question_id}-{@answer_id}" placeholder="{@string}" class="form-control{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message">

					<!-- //Set the value to client_result or default value -->
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

				</input>
			</xsl:when>

			<!-- //Email -->
			<xsl:when test="@type = 'email'">
				<input type="email" name="question[{@question_id}][{@answer_id}]" placeholder="{@string}" class="form-control{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message">

					<!-- //Set the value to client_result or default value -->
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

				</input>
			</xsl:when>

			<!-- //Label -->
			<xsl:when test="@type = 'label'">
				<div class="entry question answer label-answer">
					<xsl:value-of select="@string" />
				</div>
			</xsl:when>

			<!-- //Drop Down List -->
			<xsl:when test="@type = 'drop-down-list'">
				<!-- //First Check to see if this is the first child answer, if not, do not render -->
				<xsl:if test="not(preceding-sibling::*[1]/@type)">
					<div class="select drop-down-list">
						<select class="form-control {$hasChildren}" data-questionId="{@question_id}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message">
							<xsl:attribute name="name">question[<xsl:value-of select="@question_id" />]</xsl:attribute>
							<option value="">-- Select --</option>
							<xsl:for-each select="../answer">
								<xsl:sort select="@sequence" data-type="number" />
								<option value="{@answer_id}">
									<xsl:choose>
										<xsl:when test="../result/@answer_id = @answer_id">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:when>
										<xsl:when test="@default_value = 'selected'">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:when>
										<xsl:otherwise></xsl:otherwise>
									</xsl:choose>
									<xsl:value-of select="@string" disable-output-escaping="yes" />
								</option>
							</xsl:for-each>
						</select>
						<i></i>
					</div>
				</xsl:if>
			</xsl:when>

			<!-- //File Upload -->

			<xsl:when test="@type= 'file-upload'">

				<!-- //Set the upload parameters -->
				<xsl:variable name="id" select="@answer_id" />
				<xsl:variable name="input-name" select="concat('question[', @question_id, '][', @answer_id , ']')" />
				<xsl:variable name="file" select="../result[@answer_id = $id]" />

				<div class="row">
					<div class="col-md-6 col-sm-12">

						<div class="file-upload-container file-upload">
							<!-- The fileinput-button span is used to style the file input field as button -->
							<div class="row">
								<div class="col-md-12 file-upload-button collapse">
									<span class="btn btn-success btn-icon fa-plus fileinput-button">
										<span>Select file...</span>
										<!-- The file input field used as target for the file upload widget -->
										<input type="file" name="file-upload-{$id}" class="bimp file-upload" data-id="{$id}" />
										<input type="hidden" name="{$input-name}" value="{$file/@value}" data-input="file-{$id}" data-name="{$file/@filename}" data-size="{$file/@filesize}" readonly="readonly" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" />
									</span>
								</div>
								<div class="col-md-12 file-delete-button collapse">
									<span class="btn btn-danger btn-icon fa-trash delete" data-id="{$id}">
										<span>Delete file</span>
									</span>
								</div>
								<div class="col-md-12">
									<div class="file-name-status"></div>
								</div>
							</div>
							<div class="row">
								<div class="col-md-12">
									<!-- The global progress bar -->
									<div class="progress">
										<div class="progress-bar progress-bar-success"></div>
									</div>
								</div>
							</div>
						</div>

					</div>
				</div>
			</xsl:when>

			<xsl:when test="@type = 'file-upload-old'">

               	<!-- The fileupload-buttonbar contains buttons to add/delete files and start/cancel the upload-->
              	<div class="file-upload-container answer-upload">
					<!-- The fileinput-button span is used to style the file input field as button -->
					<div class="row">
						<div class="col-md-4 col-sm-6 file-upload-button">
							<span class="btn btn-success fileinput-button">
							    <i class="glyphicon glyphicon-plus"></i>
							    <span>Select file...</span>
							    <!-- The file input field used as target for the file upload widget -->
							    <input type="file" id="question-answer-upload-{@question_id}-{@answer_id}" name="question-answer-upload{@answer_id}" class="bimp file-upload" data-file-name="{../../../@client_checklist_id}-{@answer_id}" data-child="question[{@question_id}][{@answer_id}]"/>
							    <input type="hidden" name="question[{@question_id}][{@answer_id}]" value="{../result[@answer_id = current()/@answer_id]/@value}" data-name="{../result[@answer_id = current()/@answer_id]/@filename}" data-size="{../result[@answer_id = current()/@answer_id]/@filesize}" placeholder="{@string}" class="form-control{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" readonly="readonly" data-parent="question[{@question_id}][{@answer_id}]" />
							</span>
						</div>
						<div class="col-md-4 col-sm-6 file-delete-button">
							<span class="btn btn-danger delete" data-child="question[{@question_id}][{@answer_id}]">
							    <i class="fa fa-fw fa-trash"></i>
							    <span>Delete file</span>
							</span>
						</div>
						<div class="col-md-8 col-sm-12">
							<div class="file-name-status"></div>
						</div>
					</div>
					<div class="row">
						<div class="col-md-12">
							<!-- The global progress bar -->
							<div class="progress">
							    <div class="progress-bar progress-bar-success"></div>
							</div>
						</div>
					</div>
           		</div>

			</xsl:when>

			<!-- //Date -->
			<xsl:when test="@type = 'date' or @type = 'date-month' or @type = 'date-quarter'">
				<xsl:variable name="date-type">
					<xsl:choose>
						<xsl:when test="@type = 'date'"> day</xsl:when>
						<xsl:when test="@type = 'date-month'"> month</xsl:when>
						<xsl:when test="@type = 'date-quarter'"> quarter</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<div class="input-group date date-time-picker{$date-type}">
					<input type="text" name="question[{@question_id}][{@answer_id}]" value="{../result[@answer_id = current()/@answer_id]/@value}" placeholder="{@string}" class="form-control{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message" />
					<span class="input-group-addon">
	                	<span class="fa fa-calendar"></span>
	             	</span>
             	</div>
			</xsl:when>

			<!-- //Text or otherwise -->
			<xsl:otherwise>

				<xsl:variable name="countable">
					<xsl:choose>
						<xsl:when test="@range_min &gt; 0 or @range_max &gt; 0">countable</xsl:when>
						<xsl:otherwise></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<input type="text" name="question[{@question_id}][{@answer_id}]" placeholder="{@string}" class="form-control{$countable}{$hasChildren}" data-parsley-required="{../@data_parsley_required}" data-parsley-errors-container=".entry.question.question-id-{@question_id}-{$index} .error-message">

					<!-- //Set the value to client_result or default value -->
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="../result[@answer_id = current()/@answer_id]">
								<xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@default_value" />						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<xsl:if test="@range_min &gt; 0">
						<xsl:attribute name="data-parsley-minwords">
							<xsl:value-of select="@range_min" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@range_max &gt; 0">
						<xsl:attribute name="data-parsley-maxwords">
							<xsl:value-of select="@range_max" />
						</xsl:attribute>
					</xsl:if>

				</input>

				<!-- //Max Words Message -->
				<xsl:choose>
					<xsl:when test="@range_min &gt; 0 and @range_max &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
							Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
					<xsl:when test="@range_min &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Min <xsl:value-of select="@range_min" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
					<xsl:when test="@range_max &gt; 0">
						<div class="{@answer_id} counter-message text-right">
							Max  <xsl:value-of select="@range_max" /><xsl:text> words. </xsl:text>
							<span class="word-counter">
								<xsl:text>Word count: </xsl:text><span class="counter"></span>
							</span>
						</div>
					</xsl:when>
				</xsl:choose>

			</xsl:otherwise>

		</xsl:choose>

	</xsl:template>

	<!--//The main assessment plugin template, rendering at all times -->
	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'assessment']">
	
		<div class="assessment-container">
			<!-- //Check to see if the user accessing the clientChecklist is the client or another entity -->
			<xsl:if test="@own_checklist = 'no'">
				<xsl:if test="clientChecklist/@status = 'report'">
					<div class="checklist-complete-message">Already Complete</div>
				</xsl:if>
				<h3>For: <a href="/members/associate/edit-client/?client_id={clientChecklist/@client_id}"><xsl:value-of select="clientChecklist/@company_name"/></a></h3>
			</xsl:if>
		
			<!-- //Call the PageSections template to render any pageSections if they exist for the current checklist -->
			<xsl:call-template name="assessmentPageSectionNav" />
		
			<!-- //Split the page into a left nav and a right content -->
			<div class="sidebar">
				<!-- //Check to see if there are pageSections or not -->
				<xsl:choose>
					<xsl:when test="count(/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/pageSection) &gt; 0">
						<xsl:call-template name="assessmentPageSections" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="assessmentPages" />
					</xsl:otherwise>
				</xsl:choose>
			
				<!-- //Call the assessment buttons -->
				<xsl:call-template name="assessmentButtons" />
			</div>
		
			<!-- //Render the main assessment content for the current page -->
			<div class="contentmain">
				<div id="assessment-container">
					<xsl:call-template name="assessment-content" />
				</div>
			</div>
		
			<!-- //Jquery for errors and auto scroll -->
			<!--
			<script type="text/javascript">
				$(document).ready(function() {
					if($('p.error').length) {
						errorLocation = $('p.error').first().position().top;
						$('html, body').animate({scrollTop: errorLocation - 20}, 1000);
					}
				});
			</script>
			-->
		</div>
		
	</xsl:template>

	<!-- //Template to render the main assessment content -->
	<xsl:template name="assessment-content">
		<form method="post" action="" id="checklist" class="checklist sky-form">
		
			<div id="assessment-header-bg">
				<div id="assessment-header">
					<input type="hidden" id="action" name="action" value="" />
					<input type="hidden" id="single-page" name="single-page" value="false" />
					
					<!--//Generic Assessment Instructions Link -->
					<a href="#" class="assessment-instructions-help"></a>
					
					<!--
					<script type="text/javascript">
						$(document).ready(function() {
							$(".assessment-instructions-help").click(function(e) {
								e.preventDefault();
								wLeft = window.screenLeft ? window.screenLeft : window.screenX;
    							wTop = window.screenTop ? window.screenTop : window.screenY;

    							var left = wLeft + (window.innerWidth / 2) - (400 / 2);
    							var top = wTop + (window.innerHeight / 2) - (400 / 2);
								window.open("/_help/assessment-instructions.html","", "width=400, height=400, left=" + left + ", top=" + top + ", location=no, menubar=no, resizable=no");
							});
						});
					</script>
					-->
					
					<h2><xsl:value-of select="clientChecklist/page/@title" /></h2><br />
					<xsl:apply-templates select="clientChecklist/page/content/*" mode="html" />
				</div>
			</div>
			
			<!-- //Check for tabled output -->
			<xsl:choose>
				<xsl:when test="clientChecklist/checklistPage[@page_id = ../page/@page_id]/@display_in_table = '1'">
					<xsl:call-template name="tabled-output" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="clientChecklist/page/question" />
					<xsl:apply-templates select="clientChecklist/page/metricGroup[@metric_group_type_id = '1']" />
					<xsl:apply-templates select="clientChecklist/page/metricGroup[@metric_group_type_id = '2']" />
				</xsl:otherwise>
			</xsl:choose>
			
            <!-- //Added option to choose if page note is visible -->
            <xsl:if test="clientChecklist/page/@show_notes_field = '1'">
            	<div id="assessment-body">
					<fieldset id="page-note">
						<p>
							<label>
								<strong>Add a comment/note to this page</strong>
								<xsl:text> (Optional)</xsl:text>
								<textarea name="note" rows="2" cols="45">
									<xsl:choose>
										<xsl:when test="/config/globals/item[@key = 'note']"><xsl:value-of select="/config/globals/item[@key = 'note']/@value" /></xsl:when>
										<xsl:otherwise><xsl:value-of select="clientChecklist/page/@note" /></xsl:otherwise>
									</xsl:choose>
								</textarea>
							</label>
						</p>
					</fieldset>
				</div>
            </xsl:if>
            <div id="assessment-footer">
                <div class="buttons navigation-buttons">
                    <!-- //New Button Format -->
                	<!-- //Show Previous, Next and if 100%, Submit -->
                
                	<!-- //Previous Button -->
                	<input type="submit" id="previous" value="Previous Page" onclick="document.getElementById('action').value = 'previous';return(true);" class="previousButton" title="Save current page and go back to the last page">
	                	<xsl:if test="clientChecklist/page/@page_id = clientChecklist/checklistPage[1]/@page_id">
	                		<xsl:attribute name="disabled">true</xsl:attribute>
	                		<xsl:attribute name="class">previousButton disabled</xsl:attribute>
						</xsl:if>
					</input>

					<!-- //Next Button -->
					<input type="submit" id="next" value="Next Page" onclick="document.getElementById('action').value = 'next';return(true);" class="nextButton" title="Save current page and go forward to the next page.">
						<xsl:if test="clientChecklist/page/@page_id = clientChecklist/checklistPage[last()]/@page_id">
							<xsl:attribute name="disabled">true</xsl:attribute>
	                		<xsl:attribute name="class">nextButton disabled</xsl:attribute>
						</xsl:if>
					</input>
                </div>
                
                <!-- //Only display the submit button once all required questions are answered -->
                <!-- //Once submit button is available display on all pages -->
                <xsl:if test="clientChecklist/@pageProgress &gt;= 100">
					<div class="buttons submit-button">
						<input type="submit" id="submit-assessment" value="Submit Assessment" onclick="document.getElementById('action').value = 'submit';return(true);" class="submitButton" title="Finish the assessment and submit the results." />                                      
					</div>
                </xsl:if>
			</div>

            <xsl:if test="/config/domain/@server_env = 'local'">
            	<p><xsl:value-of select="@loadTime" /></p>
            	<p>
            		<span>Debug</span>
            		<input type="checkbox" name="debug" value="now" />
            		<input type="checkbox" name="pass" value="gr33n" />
            	</p>
            </xsl:if>

		</form>
	</xsl:template>

	<xsl:template match="metricGroup">
		<div id="assessment-body">
		<fieldset>
			<div class="table-responsive">
				<table class="table table-striped">
					<col style="width: 20em;" />
					<col style="width: 15em;" />
					<col style="width: 10em;" />
					<col style="width: 10em;" />
					<thead>
						<tr>
							<th scope="col" style="padding: .5em;"><strong><xsl:value-of select="@name" /></strong></th>
							<th scope="col" style="padding: .5em;"><strong>Metric</strong></th>
							<th scope="col" style="padding: .5em;"><strong>Units</strong></th>
							<th scope="col" style="padding: .5em;"><strong>Duration</strong></th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="metric">
							<xsl:if test="@error">
								<tr class="error">
									<td>&#160;</td>
									<td colspan="3"><xsl:value-of select="@error" /></td>
								</tr>
							</xsl:if>
							<tr>
								<th scope="row" style="padding: .5em;">
									<xsl:if test="@error"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
									<label for="metric-{@metric_id}"><xsl:value-of select="@metric" /></label>
								</th>
								<td style="padding: .5em;">
									<input type="text" id="metric-{@metric_id}" name="metric[{@metric_id}][value]" value="{@value}" style="text-align: right;" />
								</td>
								<td style="padding: .5em;">
									<label class="select">
										<select name="metric[{@metric_id}][metric_unit_type_id]">
											<xsl:for-each select="metricUnitType">
												<xsl:sort select="@order" />
												<option value="{@metric_unit_type_id}">
													<xsl:if test="@metric_unit_type_id = ../@metric_unit_type_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
													<xsl:value-of select="@metric_unit_type" disable-output-escaping="yes" />
												</option>
											</xsl:for-each>
										</select>
										<i></i>
									</label>
								</td>
								<td style="padding: .5em;">
									<label class="select">
										<select name="metric[{@metric_id}][months]">
	                                    	<xsl:if test="@max_duration &gt;= 12">
	                                            <option value="12">
	                                                <xsl:if test="@months = '12'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
	                                                <xsl:text>annum</xsl:text>
	                                            </option>
	                                        </xsl:if>
	                                        <xsl:if test="@max_duration &gt;= 3">
	                                            <option value="3">
	                                                <xsl:if test="@months = '3'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
	                                                <xsl:text>quarter</xsl:text>
	                                            </option>
	                                        </xsl:if>
	                                        <xsl:if test="@max_duration &gt;= 1">
	                                            <option value="1">
	                                                <xsl:if test="@months = '1'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
	                                                <xsl:text>month</xsl:text>
	                                            </option>
	                                        </xsl:if>
										</select>
										<i></i>
									</label>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
		</fieldset>
		<br />
		</div>
	</xsl:template>
	
	<!-- //Separate Metric Group for GHG Input -->
	<xsl:template match="metricGroup[@metric_group_type_id = 2]">
		<div id="assessment-body">
		<fieldset>
			<table class="ghg-metrics-table">
				<col style="width: 30%;" />
				<col style="width: 50%;" />
				<col style="width: 20%;" />
				<thead>
					<tr>
						<th scope="col"><strong><xsl:value-of select="@name" /></strong></th>
						<th scope="col"><strong>Metric</strong></th>
						<th scope="col"><strong>Units</strong></th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="metric">
						<xsl:if test="@error">
							<tr class="error">
								<td>&#160;</td>
								<td colspan="3"><xsl:value-of select="@error" /></td>
							</tr>
						</xsl:if>
						<tr>
							<th scope="row">
								<xsl:if test="@error"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
								<label for="metric-{@metric_id}"><xsl:value-of select="@metric" /></label>
							</th>
							<td>
								<input type="text" id="metric-{@metric_id}" name="metric[{@metric_id}][value]" value="{@value}" style="text-align: right;" />
							</td>
							<td>
								<label class="select">
									<select name="metric[{@metric_id}][metric_unit_type_id]">
										<xsl:for-each select="metricUnitType">
											<option value="{@metric_unit_type_id}">
												<xsl:if test="@metric_unit_type_id = ../@metric_unit_type_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
												<xsl:value-of select="@metric_unit_type" disable-output-escaping="yes" />
											</option>
										</xsl:for-each>
									</select>
									<i></i>
								</label>
								<!-- //Hidden field to capture the duration is a quarter -->
								<input type="hidden" name="metric[{@metric_id}][months]" value="1" />
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</fieldset>
		<br />
		</div>
	</xsl:template>
	
	<!--//Display the email icon -->
	<xsl:template name="emailQuestion">
			<a id="show_email_question_{@question_id}" href="#" tabindex="-1" class="question-help-icons email-question">
		   		<img class="email_icon" src="/_images/emailIcon.png" alt="Email Question" title="Click here to email this question" />
		   	</a>
		   	
		   	<!-- //script for the tool tip -->
		   	<script type="text/javascript">
			$(document).ready(function() {
				$('#show_email_question_<xsl:value-of select="@question_id" />').click(function(event) {
					event.preventDefault();
					$('#show_email_body_question_<xsl:value-of select="@question_id" />').toggle('slow');
				});
			});
			</script>
		   	
	</xsl:template>
	
	<!--//Display the email body -->
	<xsl:template name="emailQuestionBody">
		<xsl:param name="question_id" />
		<div id="show_email_body_question_{$question_id}" style="display:none;" class="show_email_body_question">
			<p>Email this question to another team member to get the answer:<br />
				<input type="email" name="email_recipient_question_{$question_id}" id="email_recipient_question_{$question_id}" placeholder="email address" />
				<input type="button" value="send email" name="email_submit_question_{$question_id}" id="email_submit_question_{$question_id}" />
				<span id="show_email_body_indicator_question_{$question_id}" class="show_email_body_indicator_question" />
			</p>
				
			<!-- //script to send email via ajax -->
			<script type="text/javascript">
			$(document).ready(function() {
				$('#email_submit_question_<xsl:value-of select="$question_id" />').click(function(event) {
					event.preventDefault();
					
					//Start the indicator
					$('#show_email_body_indicator_question_<xsl:value-of select="$question_id" />').toggleClass('working');
				
					var url_string = {
					'sender' : '<xsl:value-of select="/config/plugin[@plugin='clients'][@method='login']/client/@client_contact_id" />',
					'recipient' : $('#email_recipient_question_<xsl:value-of select="$question_id" />').val(),
					'question_id' : '<xsl:value-of select="$question_id" />'};
					
					$.ajax({
						type: 'POST',
						url: '/_tools/email_to_staff.php',
						data: {data: JSON.stringify(url_string)},
						success: function(data) {
							$('#show_email_body_question_<xsl:value-of select="@question_id" />').delay(1000).toggle('slow');
							$('#show_email_body_indicator_question_<xsl:value-of select="$question_id" />').toggleClass('working');
							//alert(data);
						}
					});
				});
			});
			</script>
		   	
			
		</div>
	</xsl:template>
	
	<!--//If there is a tip to display render the help icon -->
	<xsl:template name="questionTip">
		<xsl:if test="@tip != ''">
			<xsl:choose>
				<xsl:when test="/config/domain/@domain_id != '64'">
					<span id="a_{@question_id}_close"> </span>
					<a id="a_{@question_id}_down" href="#" class="question-help-icons question-tip">
						<img class="questionmark_image" src="/_images/QuestionMark.png" alt="Question Tip" />
					</a>
					
					<div id="tip_{@question_id}_down" style="display:none;">
						<span class="tip_text">
							<xsl:value-of select="@tip" disable-output-escaping="yes" />
							<br />
							<a href="#" id="#tip_{@question_id}_close" class="tip-close">close</a>
						</span>
					</div>
					
					<!-- //script for the tool tip -->
					<script type="text/javascript">
					$(document).ready(function() {
						$('#a_<xsl:value-of select="@question_id" />_down').click(function(e) {
							e.preventDefault();
						});
					
						$('#a_<xsl:value-of select="@question_id" />_down').bubbletip($('#tip_<xsl:value-of select="@question_id" />_down'), {
							deltaDirection: 'down',
							offsetTop: 10,
						});
						
						$('.tip-close').click(function(e) {
							e.preventDefault();
							$(e.target).closest('.bubbletip').hide();
						});
					});
					</script>
				</xsl:when>
				<xsl:otherwise>
					<p><xsl:value-of select="@tip" disable-output-escaping="yes" /></p>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- //Generic template for all questions -->
	<xsl:template match="question">
		<div id="assessment-body">
			<xsl:if test="@error">
				<xsl:attribute name="class">assessment-body answer-error</xsl:attribute>
				<p class="error"><xsl:value-of select="@error" /></p>
			</xsl:if>
			<fieldset>
				<p>
					<label for="question-{@question_id}-{answer/@answer_id}">
					<strong><xsl:value-of select="@question" disable-output-escaping="yes" />
					<xsl:if test="@required = 'yes'"><span style="color:red;"> * </span></xsl:if></strong>
			
					<!--<xsl:call-template name="emailQuestion" />-->
					<xsl:call-template name="questionTip" />
				  </label>
				</p>
				
				<!-- //Call the hidden email drop down -->
				<!--
				<xsl:call-template name="emailQuestionBody">
					<xsl:with-param name="question_id" select="@question_id" />
				</xsl:call-template>
				-->
				
				<!-- //Now apply templates for answers -->
				<xsl:choose>
					<xsl:when test="(@multi_site = 'yes') and (/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/@siteCount &gt; 0)">
						<!-- //Create the multisite answer container -->
						<xsl:variable name="question_id" select="@question_id" />
						<div class="multi-site-container question-id-{@question_id}">
							<xsl:for-each select="/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/clientSite">
							
								<!-- //Check to see if the question is trigged and if the client_site is required -->
								<xsl:choose>
									<xsl:when test="../page/question[@question_id = $question_id]/@triggered_question = '1'">
										<xsl:if test="../page/question[@question_id = $question_id]/client_site_trigger[@client_site_id = current()/@client_site_id]">
											<xsl:variable name="client_site_id" select="@client_site_id" />
											<h3><xsl:value-of select="@site_name" /></h3>
											<div>
												<xsl:apply-templates select="../page/question[@question_id = $question_id]/answer">
													<xsl:with-param name="client_site_id" select="$client_site_id" />
												</xsl:apply-templates>
											</div>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="client_site_id" select="@client_site_id" />
										<h3><xsl:value-of select="@site_name" /></h3>
										<div>
											<xsl:apply-templates select="../page/question[@question_id = $question_id]/answer">
												<xsl:with-param name="client_site_id" select="$client_site_id" />
											</xsl:apply-templates>
										</div>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</div>
						
						<!-- //Accordian the multi_site container -->
						<script type="text/javascript">
							$(document).ready(function() {				
								$('.multi-site-container').accordion({
									heightStyle: "content"
								});
							});
						</script>
					
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates />
					</xsl:otherwise>
				</xsl:choose>
				
			</fieldset>
			</div>
		<div id="assessment-question-footer" />
	</xsl:template>

	
	<xsl:template match="answer[@type = 'date']">
		<p>
			<input type="text" name="question[{../@question_id}][{@answer_id}]" id="question-{../@question_id}-{@answer_id}" value="{../result/@value}" />
			<script type="text/javascript">
			$(function() {
				$("#question-<xsl:value-of select="concat(../@question_id,'-',@answer_id)" />").datepicker({
					dateFormat: 'yy-mm-dd',
								showOn: 'button',
								buttonImage: '/_images/calendar.gif',
								buttonImageOnly: true
				});
			});
			</script>
			(YYYY-MM-DD)
		</p>
	</xsl:template>
	
	<!-- //Template for selecting a date/month -->
	<xsl:template match="answer[@type = 'date-month']">
		<p>
			<table class="date-quarter">
				<tr>
					<td>
						Year:
					</td>
					<td>
						<label class="select">
							<select id="date-month-year-question-{../@question_id}">
								<xsl:call-template name="year-loop">
									<xsl:with-param name="year-start" select="/config/datetime/@year" />
									<xsl:with-param name="year" select="/config/datetime/@year" />
									<xsl:with-param name="years-to-loop" select="'10'" />
								</xsl:call-template>
							</select>
							<i></i>
						</label>
					</td>
					<td>
						Month:
					</td>
					<td>
						<label class="select">
							<select id="date-month-period-question-{../@question_id}">
								<option value="1">January</option>
								<option value="2">February</option>
								<option value="3">March</option>
								<option value="4">April</option>
								<option value="5">May</option>
								<option value="6">June</option>
								<option value="7">July</option>
								<option value="8">August</option>
								<option value="9">September</option>
								<option value="10">October</option>
								<option value="11">November</option>
								<option value="12">December</option>
							</select>
							<i></i>
						</label>
					</td>
				</tr>
			</table>
			<input type="hidden" name="question[{../@question_id}][{@answer_id}]" id="question-{../@question_id}-{@answer_id}" value="{../result/@value}" />
		</p>
	</xsl:template>
	
	<!-- //Template for selecting a date/quarter -->
	<xsl:template match="answer[@type = 'date-quarter']">
		<p>
			<table class="date-quarter">
				<tr>
					<td>
						Year:
					</td>
					<td>
						<label class="select">
							<select id="date-quarter-year-question-{../@question_id}">
								<xsl:call-template name="year-loop">
									<xsl:with-param name="year-start" select="/config/datetime/@year" />
									<xsl:with-param name="year" select="/config/datetime/@year" />
									<xsl:with-param name="years-to-loop" select="'10'" />
								</xsl:call-template>
							</select>
							<i></i>
						</label>
					</td>
					<td>
						Period:
					</td>
					<td>
						<label class="select">
							<select id="date-quarter-period-question-{../@question_id}">
								<option value="1">Quarter 1 (Jan 1 - Mar 31)</option>
								<option value="2">Quarter 2 (Apr 1 - Jun 30)</option>
								<option value="3">Quarter 3 (Jul 1 - Sep 30)</option>
								<option value="4">Quarter 4 (Oct 1 - Dec 31)</option>
							</select>
							<i></i>
						</label>
					</td>
				</tr>
			</table>
			<input type="hidden" name="question[{../@question_id}][{@answer_id}]" id="question-{../@question_id}-{@answer_id}" value="{../result/@value}" />
			<script type="text/javascript">
			$(function() {
			
				var selectedDate;
				function getDate(question_id) {	
					
					var selectedYear = $("#date-quarter-year-question-<xsl:value-of select="../@question_id" />").val();
					var selectedQuarter = '';
					
					switch($("#date-quarter-period-question-<xsl:value-of select="../@question_id" />").val()) {
						case '1':	selectedQuarter = '-03-31';
									break;
						case '2':	selectedQuarter = '-06-30';
									break;
						case '3':	selectedQuarter = '-09-30';
									break;
						case '4':	selectedQuarter = '-12-31';
									break;
				
					}
					
					return (selectedYear + selectedQuarter);
				}
				
				//Set the default
				
				//If date has not been set yet
				if($("#question-<xsl:value-of select="concat(../@question_id,'-',@answer_id)" />").val() == '') {
					selectedDate = getDate(<xsl:value-of select="../@question_id" />);
					$("#question-<xsl:value-of select="concat(../@question_id,'-',@answer_id)" />").val(selectedDate);
				}
				else {
					var year = $("#question-<xsl:value-of select="concat(../@question_id,'-',@answer_id)" />").val().substring(0,4);
					$("#date-quarter-year-question-<xsl:value-of select="../@question_id" />").val(year);
					
					var quarter = $("#question-<xsl:value-of select="concat(../@question_id,'-',@answer_id)" />").val().substring(5,7);
					switch(quarter) {
						case '03':	$("#date-quarter-period-question-<xsl:value-of select="../@question_id" />").val('1');
									break;
						case '06':	$("#date-quarter-period-question-<xsl:value-of select="../@question_id" />").val('2');
									break;
						case '09':	$("#date-quarter-period-question-<xsl:value-of select="../@question_id" />").val('3');
									break;
						case '12':	$("#date-quarter-period-question-<xsl:value-of select="../@question_id" />").val('4');
									break;
					}
				}
				
				//On Year Change
				$("#date-quarter-year-question-<xsl:value-of select="../@question_id" />").change(function(){
					selectedDate = getDate(<xsl:value-of select="../@question_id" />);
					$("#question-<xsl:value-of select="concat(../@question_id,'-',@answer_id)" />").val(selectedDate);
				});
				
				//On Period Change
				$("#date-quarter-period-question-<xsl:value-of select="../@question_id" />").change(function(){
					selectedDate = getDate(<xsl:value-of select="../@question_id" />);
					$("#question-<xsl:value-of select="concat(../@question_id,'-',@answer_id)" />").val(selectedDate);
				});
				
			});
			</script>
		</p>
	</xsl:template>
	
	<!-- //Year Date Loop for date-quarter -->
	<xsl:template name="year-loop">
		<xsl:param name="year-start" />
		<xsl:param name="year" />
		<xsl:param name="years-to-loop" />
		<!-- Do the process here -->
			<option value="{$year}">
				<xsl:value-of select="$year" />
			</option>
		<xsl:variable name="previous-year" select="$year - 1" />
		<xsl:if test="$previous-year &gt; ($year-start - $years-to-loop)">
			<xsl:call-template name="year-loop">
				<xsl:with-param name="year-start" select="$year-start" />
				<xsl:with-param name="year" select="$previous-year" />
				<xsl:with-param name="years-to-loop" select="$years-to-loop" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- // ANSWER TYPE: percent -->
	<xsl:template match="answer[@type = 'percent']">
		<xsl:param name="client_site_id" />
		<div class="percentage-container">
			<xsl:choose>
				<xsl:when test="$client_site_id">
					<input type="text" id="slider-result-{../@question_id}-{$client_site_id}" name="question[{../@question_id}][{@answer_id}][{$client_site_id}]" value="{../result[@client_site_id = $client_site_id]/@value}" data-angleOffset="-125" data-angleArc="250" data-width="150" data-thickness=".4" data-fgColor="#3498db" data-bgColor="#ccc" data-height="120"/>
				</xsl:when>
				<xsl:otherwise>
					<input type="text" id="slider-result-{../@question_id}" name="question[{../@question_id}][{@answer_id}]" value="{../result/@value}" data-angleOffset="-125" data-angleArc="250" data-width="150" data-thickness=".4" data-fgColor="#3498db" data-bgColor="#ccc" data-height="120"/>			
				</xsl:otherwise>
			</xsl:choose>

			<!--
			<script type="text/javascript">
				$(function() {
				<xsl:choose>
					<xsl:when test="$client_site_id">
						$('#slider-result-<xsl:value-of select="../@question_id" />-<xsl:value-of select="$client_site_id" />').knob({
					</xsl:when>
					<xsl:otherwise>
						$('#slider-result-<xsl:value-of select="../@question_id" />').knob({
					</xsl:otherwise>
				</xsl:choose>
						 'draw' : function () {
							if(isNaN(this.cv)) {
								this.i.val( 0 + '%');
							} else {
								this.i.val( this.cv + '%');
							}
						}
					});
				});
			</script>
			-->
		</div>
	</xsl:template>

	<!-- // ANSWER TYPE: range -->
	<xsl:template match="answer[@type = 'range']">
		<xsl:param name="client_site_id" />
		<div class="percentage-container">
			<xsl:choose>
				<xsl:when test="$client_site_id">
					<input type="text" id="slider-result-{../@question_id}-{$client_site_id}" name="question[{../@question_id}][{@answer_id}][{$client_site_id}]" value="{../result[@client_site_id = $client_site_id]/@value}" data-angleOffset="-125" data-angleArc="250" data-width="150" data-thickness=".4" data-fgColor="#3498db" data-bgColor="#ccc" data-height="120" data-min="{@range_min}" data-max="{@range_max}" data-step="{@range_step}" />
				</xsl:when>
				<xsl:otherwise>
					<input type="text" id="slider-result-{../@question_id}" name="question[{../@question_id}][{@answer_id}]" value="{../result/@value}" data-angleOffset="-125" data-angleArc="250" data-width="150" data-thickness=".4" data-fgColor="#3498db" data-bgColor="#ccc" data-height="120" data-min="{@range_min}" data-max="{@range_max}" data-step="{@range_step}" />
				</xsl:otherwise>
			</xsl:choose>
		<!--		
			<script type="text/javascript">
				$(function() {
					<xsl:choose>
						<xsl:when test="$client_site_id">
							$('#slider-result-<xsl:value-of select="../@question_id" />-<xsl:value-of select="$client_site_id" />').knob({
						</xsl:when>
						<xsl:otherwise>
							$('#slider-result-<xsl:value-of select="../@question_id" />').knob({
						</xsl:otherwise>
					</xsl:choose>
						 'draw' : function () {
						 	if(isNaN(this.cv)) {
						 		this.i.val( 0 );
						 	} else {
  		      					this.i.val( this.cv );
  		      				}
    					}
					});
				});
			</script>
		
			<div class="range-unit-label">
				<xsl:value-of select="@range_unit" />
			</div>-->
		</div>
	</xsl:template>

	<!-- // ANSWER TYPE: checkbox -->
	<xsl:template match="answer[@type = 'checkbox']">
		<xsl:param name="client_site_id" />
		<p>
			<label class="css-checkbox-radio">
				<input>
					<xsl:choose>
						<xsl:when test="../@multiple = 'yes'">
							<xsl:attribute name="type">checkbox</xsl:attribute>
							<xsl:choose>
								<xsl:when test="$client_site_id">
									<xsl:attribute name="name">question[<xsl:value-of select="../@question_id" />][<xsl:value-of select="$client_site_id" />][]</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="name">question[<xsl:value-of select="../@question_id" />][]</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="type">radio</xsl:attribute>
							<xsl:choose>
								<xsl:when test="$client_site_id">
									<xsl:attribute name="name">question[<xsl:value-of select="../@question_id" />][<xsl:value-of select="$client_site_id" />]</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="name">question[<xsl:value-of select="../@question_id" />]</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:attribute name="value"><xsl:value-of select="@answer_id" /></xsl:attribute>
					<xsl:choose>
						<xsl:when test="$client_site_id">
							<xsl:if test="../result[@client_site_id = $client_site_id]/@answer_id = @answer_id"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="../result/@answer_id = @answer_id"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
						</xsl:otherwise>
					</xsl:choose>
					<span>
						<xsl:choose>
							<xsl:when test="../@multiple = 'yes'">
								<xsl:attribute name="class">css-checkbox-radio-image checkbox</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="class">css-checkbox-radio-image radio</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</span>
				</input>
				<span>
					<xsl:choose>
						<xsl:when test="../@multiple = 'yes'">
							<xsl:attribute name="class">css-checkbox-radio-label checkbox</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">css-checkbox-radio-label radio</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="@string" disable-output-escaping="yes" />
				</span>
			</label>
		</p>
	</xsl:template>
	
	<!-- // ANSWER TYPE: checkbox-other -->
	<xsl:template match="answer[@type = 'checkbox-other']">

		<xsl:param name="client_site_id" />
		<p class="checkbox-other">
			<label class="css-checkbox-radio">
				<input>
					<xsl:choose>
						<xsl:when test="../@multiple = 'yes'">
							<xsl:attribute name="type">checkbox</xsl:attribute>
							<xsl:choose>
								<xsl:when test="$client_site_id">
									<xsl:attribute name="name">question[<xsl:value-of select="../@question_id" />][<xsl:value-of select="$client_site_id" />][]</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="name">question[<xsl:value-of select="../@question_id" />][]</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="type">radio</xsl:attribute>
							<xsl:choose>
								<xsl:when test="$client_site_id">
									<xsl:attribute name="name">question[<xsl:value-of select="../@question_id" />][<xsl:value-of select="$client_site_id" />]</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="name">question[<xsl:value-of select="../@question_id" />]</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:attribute name="value"><xsl:value-of select="@answer_id" /></xsl:attribute>
					<xsl:choose>
						<xsl:when test="$client_site_id">
							<xsl:if test="../result[@client_site_id = $client_site_id]/@answer_id = @answer_id"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="../result/@answer_id = @answer_id"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
						</xsl:otherwise>
					</xsl:choose>

					<span>
						<xsl:choose>
							<xsl:when test="../@multiple = 'yes'">
								<xsl:attribute name="class">css-checkbox-radio-image checkbox</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="class">css-checkbox-radio-image radio</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</span>
				</input>
				<span>
					<xsl:choose>
						<xsl:when test="../@multiple = 'yes'">
							<xsl:attribute name="class">css-checkbox-radio-label checkbox</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">css-checkbox-radio-label radio</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="@string != ''">
							<xsl:value-of select="@string" disable-output-escaping="yes" />
						</xsl:when>
						<xsl:otherwise>
							other
						</xsl:otherwise>
					</xsl:choose>	
				</span>
			</label>
			<xsl:choose>
				<xsl:when test="$client_site_id">
					<input type="text" name="question-other[{$client_site_id}][{@answer_id}]" value="{../result[@client_site_id = $client_site_id][@answer_id = current()/@answer_id]/@value}" class="checkbox-other-text" />
				</xsl:when>
				<xsl:otherwise>
					<input type="text" name="question-other[{@answer_id}]" value="{../result[@answer_id = current()/@answer_id]/@value}" class="checkbox-other-text" />
				</xsl:otherwise>
			</xsl:choose>
		</p>
	</xsl:template>
	
	<!-- // ANSWER TYPE: drop-down-list -->
	<xsl:template match="answer[@type = 'drop-down-list']">
		<xsl:param name="client_site_id" />	
		<!-- //First Check to see if this is the first child answer, if not, do not render -->
		<xsl:if test="not(preceding-sibling::*[1]/@type)">
			<p>
				
				<label class="select">
					<select>
						<xsl:choose>
							<xsl:when test="@multiple = 'yes'">
								<xsl:attribute name="name">question[<xsl:value-of select="../@question_id" />][]</xsl:attribute>
								<xsl:attribute name="multiple">multiple</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="name">question[<xsl:value-of select="../@question_id" />]</xsl:attribute>
								<option value="">-- Select --</option>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:for-each select="../answer">
							<xsl:sort select="@sequence" />
							<option value="{@answer_id}">
								<xsl:if test="../result/@answer_id = @answer_id">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="@string" disable-output-escaping="yes" />
							</option>
						</xsl:for-each>
					</select>
					<i></i>
				</label>
			</p>
		</xsl:if>
	</xsl:template>
	
	<!-- //Default Answer Types -->
	<xsl:template match="answer">
		<xsl:param name="client_site_id" />
		<p>
			<xsl:choose>
				<xsl:when test="$client_site_id">
					<xsl:choose>
						<xsl:when test="@type = 'textarea'">
							<textarea name="question[{../@question_id}][{@answer_id}][{$client_site_id}]" id="question-{../@question_id}-{@answer_id}-{$client_site_id}" rows="{@number_of_rows}" cols="45" placeholder="{@string}"><xsl:value-of select="../result[@answer_id = current()/@answer_id][@client_site_id = $client_site_id]/@value" /></textarea>
						</xsl:when>
						<xsl:otherwise>
							<input type="text" name="question[{../@question_id}][{@answer_id}][{$client_site_id}]" id="question-{../@question_id}-{@answer_id}-{$client_site_id}" value="{../result[@answer_id = current()/@answer_id][@client_site_id = $client_site_id]/@value}" placeholder="{@string}" style="width:100%" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type = 'textarea'">
							<textarea name="question[{../@question_id}][{@answer_id}]" id="question-{../@question_id}-{@answer_id}" rows="{@number_of_rows}" cols="45" placeholder="{@string}"><xsl:value-of select="../result[@answer_id = current()/@answer_id]/@value" /></textarea>
						</xsl:when>
						<xsl:otherwise>
							<input type="text" name="question[{../@question_id}][{@answer_id}]" id="question-{../@question_id}-{@answer_id}" value="{../result[@answer_id = current()/@answer_id]/@value}" placeholder="{@string}" style="width:100%" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</p>
	</xsl:template>
	
	<!-- //Displays the page content in a tabled format -->
	<xsl:template name="tabled-output">
		<div id="assessment-body">
			<fieldset>
			
				<xsl:variable name="headerColWidth">
					<xsl:choose>
						<xsl:when test="clientChecklist/page/question[1]/answer[1]/@type = 'float'">
							<xsl:value-of select="'50%'" />
						</xsl:when>
							<xsl:when test="clientChecklist/page/question[1]/answer[1]/@type = 'checkbox'">
						<xsl:value-of select="'50%'" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'auto'" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="colWidth">
					<xsl:choose>
						<xsl:when test="clientChecklist/page/question[1]/answer[1]/@type = 'float'">
							<xsl:value-of select="50 div (count(clientChecklist/page/question[1]/answer))" />%
						</xsl:when>
						<xsl:when test="clientChecklist/page/question[1]/answer[1]/@type = 'checkbox'">
							<xsl:value-of select="50 div (count(clientChecklist/page/question[1]/answer))" />%
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'auto'" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
			
				<div class="table-responsive">
					<table class="table table-striped tabled-questions">
						<thead>
							<th scope="col" class="question-col" style="width:{$headerColWidth};"></th>
							<xsl:for-each select="clientChecklist/page/question[1]/answer">
								<th scope="col" class="answer-col" style="width:{$colWidth};"><xsl:value-of select="@string" /></th>
							</xsl:for-each>
						</thead>
						<tbody>
							<xsl:apply-templates select="clientChecklist/page/question[answer/@type != 'algorithm']" mode="tabled" />
						</tbody>
					</table>
				</div>
			</fieldset>
		</div>
		<div id="assessment-question-footer" />
	</xsl:template>
	
	<xsl:template match="question" mode="tabled">
		<tr>
			<th scope="row" class="question-col">
				<xsl:value-of select="@question" disable-output-escaping="yes" />
				<xsl:if test="@required = 'yes'"><span style="color:red;"> * </span></xsl:if>
				<xsl:if test="@error"><span style="color:red;"> <xsl:value-of select="@error" /></span></xsl:if>
			</th>
			<xsl:apply-templates select="answer" mode="tabled" />
		</tr>
	</xsl:template>
	
	<!-- //Generic Tabled Answer Output -->
	<xsl:template match="answer" mode="tabled">
		<td class="answer-col" onClick="$('#question_{@answer_id}').attr('checked', true);">
			<label class="css-checkbox-radio">
				<input type="radio" name="question[{../@question_id}]" id="question_{@answer_id}" value="{@answer_id}" class="css-checkbox-radio">
					<xsl:if test="../result/@answer_id = @answer_id"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
					<span class="css-checkbox-radio-image radio"></span>
				</input>
			</label>
		</td>
	</xsl:template>
	
	<!-- //Float Tabled Answer Output or Text-->
	<xsl:template match="answer[@type = 'float' or @type = 'text']" mode="tabled">
		<td class="answer-col">
			<input type="text" name="question[{../@question_id}][{@answer_id}]" id="question-{../@question_id}-{@answer_id}" value="{../result[@answer_id = current()/@answer_id]/@value}" style="width:100%" />
		</td>
	</xsl:template>

	<xsl:template match="assessment-checklist-name" mode="html">
		<xsl:value-of select="/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/@name" />
	</xsl:template>

	<!-- //Download Report Link -->
	<xsl:template match="assessment-progress" mode="html">
		<xsl:variable name="class" select="@class" />
		<xsl:variable name="text" select="@text" />
		<xsl:variable name="assessmentProgress" select="/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/@pageProgress" />

    	<span class="{$class}">
    		<xsl:value-of select="concat($assessmentProgress, $text)" />
    	</span>
	</xsl:template>
	
	<!-- //Template to render the PageSection navigation. Positioned at the top of the page -->
	<xsl:template name="assessmentPageSectionNav" mode="html">
	
		<!-- //First check to see if there are any pageSections, if there are render the content -->
		<xsl:if test="count(/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/pageSection) > 0">
		
		<!-- //Get the width of the individual page sections as a percentage -->
		<xsl:variable name="pageSectionWidth">
			<xsl:value-of select="(100 div count(/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/pageSection))" />
		</xsl:variable>
		
		<xsl:variable name="selected_page_section_id">
			<xsl:value-of select="/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/pageSectionPage[@page_id = ../page/@page_id]/@page_section_id" />
		</xsl:variable>
		
			<div id="header-nav">
				<ul class="main-nav">
					<xsl:for-each select="/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/pageSection">
						<li style="width:{$pageSectionWidth}%">
							<xsl:if test="position() = 1">
								<xsl:attribute name="class">first</xsl:attribute>
							</xsl:if>
							<xsl:if test="position() = last()">
								<xsl:attribute name="class">last</xsl:attribute>
							</xsl:if>
							<xsl:if test="@page_section_id = $selected_page_section_id">
								<xsl:attribute name="class">selected</xsl:attribute>
							</xsl:if>
						
							<!-- //Get the class attribute for the link -->
							<xsl:variable name="classAttribute">
								<xsl:value-of select="translate(translate(translate(@title, ' ', ''), ' &amp; ', ''),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />
							
								<xsl:if test="@allPagesComplete = 'yes'">
									<xsl:text> done</xsl:text>
								</xsl:if>
							</xsl:variable>
						
							<a href="?p={../checklistPage[@page_id = current()/@first_page_id]/@token}" style="width:{$pageSectionWidth}%">
								<xsl:attribute name="class"><xsl:value-of select="$classAttribute" /></xsl:attribute>
								<div class="before-text" />
								<span><xsl:value-of select="@title" /></span>
								<span class="after-text" />
							</a>
							
							<xsl:if test="@page_section_id = $selected_page_section_id">
								<div class="page-section-indicator-arrow-container">
									<div class="page-section-indicator-arrow-outer" />
								</div>
							</xsl:if>
						</li>
					</xsl:for-each>
				</ul>
			</div>
			
			<xsl:call-template name="assessmentPageSectionIndicator" />
			
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="assessmentProgress" mode="html">
		<div class="assessmentProgress">
			<div class="assessmentProgressNumber">
				<xsl:value-of select="/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/@pageProgress" />
			</div>
			<div class="assessmentProgressText">
			%<br />complete
			</div>
		</div>
	</xsl:template>
	
	<!-- //Template to render to the PageSection indicator bar under the PageSection navigation -->
	<xsl:template name="assessmentPageSectionIndicator" mode="html">
		<div class="page-section-indicator-line" />
	</xsl:template>
	
	<!-- //Use when there are pageSections available, otherwise use assessmentPages -->
	<xsl:template name="assessmentPageSections" mode="html">
	
		<xsl:for-each select="/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/pageSection">
			<xsl:if test="../pageSectionPage[@page_section_id = current()/@page_section_id][@page_id = ../page/@page_id]">
					<h2><xsl:value-of select="@title" /></h2>
				<ul class="checklistPages pageSections">
					<xsl:for-each select="../pageSectionPage[@page_section_id = current()/@page_section_id]">
						<xsl:if test="../checklistPage[@page_id = current()/@page_id]/@skipPage != '1'">
							<xsl:variable name="currentPage">
								<xsl:value-of select="../checklistPage[@page_id = current()/@page_id]" />
							</xsl:variable>
					
							<li>
								<xsl:choose>
									<xsl:when test="@page_id = ../page/@page_id"><xsl:attribute name="class">selected</xsl:attribute></xsl:when>
									<xsl:when test="../checklistPage[@page_id = current()/@page_id]/@complete = 'yes'"><xsl:attribute name="class">page-complete</xsl:attribute></xsl:when>
								</xsl:choose>
								<a href="?p={../checklistPage[@page_id = current()/@page_id]/@token}" class="page-title">
									<xsl:value-of select="@page_title" />
								</a>
							</li>
						</xsl:if>
					</xsl:for-each>
				</ul>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<!-- //Use when there are no pageSections -->
	<xsl:template name="assessmentPages" mode="html">
		<div class="checklist-name-container">
			<h2><xsl:value-of select="/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/@name" /></h2>
		</div>
		<ul class="checklistPages">
			<xsl:for-each select="/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/checklistPage[@skipPage != '1']">		
				<li>
					<xsl:choose>
						<xsl:when test="@page_id = ../page/@page_id"><xsl:attribute name="class">selected</xsl:attribute></xsl:when>
						<xsl:when test="@complete = 'yes'"><xsl:attribute name="class">page-complete</xsl:attribute></xsl:when>
					</xsl:choose>
					<a href="?p={@token}" class="page-title">
						<xsl:value-of select="@title" />
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>
	
	<xsl:template name="assessmentButtons">
		<!-- //Buttons for Save and Exit and Start Again - Submits the checklist form -->
		<div class="assessmentActionButtons">
			<input type="submit" value="Save" onclick="saveAssessment();" title="Save current page." />
			<input type="submit" value="Save &amp; Exit" onclick="saveAndExit();" title="Save current page and exit the assessment." />
			<input type="submit" value="Start Again" onclick="startAgain();" title="Save current page and return to the first page." />
		</div>
		
		<script type="text/javascript">
			
			function saveAssessment() {
				document.getElementById('action').value = 'saveProgress';
				document.getElementById('checklist').submit();
				return(true);
			}
			
			function saveAndExit() {
				document.getElementById('action').value = 'save';
				document.getElementById('checklist').submit();
				return(true);
			}
			
			function startAgain() {
				document.getElementById('action').value = 'first';
				document.getElementById('checklist').submit();
				return(true);
			}
		</script>
		<!--//End of buttons -->
	</xsl:template>
	
	<!-- //Multi Site Query Answer Type -->
	<xsl:template match="answer[@type = 'multi-site-query']">
		
		<!-- Table for multi-site-query -->
		<div class="table-responsive">
			<table class="table table-striped multi-site-query" id="multi-site-query">
				
				<thead>
					<tr>
						<th>Site Name</th>
						<th>Number of Staff</th>
						<th>Floor Space (area)</th>
						<th>Unit</th>
						<th></th>
					</tr>
				</thead>
				
				<tbody>
					<!-- //First list any existing client sites for this client checklist -->
					<xsl:choose>
						<xsl:when test="count(/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/clientSite) &gt; 0">
						
							<xsl:for-each select="/config/plugin[@plugin = 'checklist'][@method = 'assessment']/clientChecklist/clientSite">
								<tr>
									<td class="site-name">
										<input type="text" value="{@site_name}" name="site[name][]" />
									</td>
									<td class="number-of-staff">
										<input type="text" value="{@staff_number}" name="site[staff][]" />
									</td>
									<td class="office-space">
										<input type="text" value="{@office_space}" name="site[space][]" />
									</td>
									<td class="office-space-unit">
										<label class="select">
											<select name="site[unit][]">
												<option value="m2">
													<xsl:if test="@office_space_unit = 'm2'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
													<xsl:text>m2</xsl:text>
												</option>
												<option value="square feet">
													<xsl:if test="@office_space_unit = 'square feet'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
													<xsl:text>square feet</xsl:text>
												</option>
											</select>
											<i></i>
										</label>
									</td>
									<td>
										<input type="hidden" name="site[client_site_id][]" value="{@client_site_id}" />
										<button class="delete-site-button" value="Delete">Delete</button>
									</td>
								</tr>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<!-- //Default Rows -->
							<tr>
								<td class="site-name">
									<input type="text" value="" name="site[name][]" />
								</td>
								<td class="number-of-staff">
									<input type="text" value="" name="site[staff][]" />
								</td>
								<td class="office-space">
									<input type="text" value="" name="site[space][]" />
								</td>
								<td class="office-space-unit">
									<label class="select">
										<select name="site[unit][]">
											<option value="m2">m2</option>
											<option value="square feet">square feet</option>
										</select>
										<i></i>
									</label>
								</td>
								<td>
									<button class="delete-site-button" value="Delete">Delete</button>
									<input type="hidden" name="site[client_site_id][]" value="" />
								</td>
							</tr>
						</xsl:otherwise>
					</xsl:choose>
				</tbody>
				
				<tfoot>
					<tr class="add-site-row">
						<td colspan="5">
							<button id="add-site-button" value="Add Another Site">Add Another Site</button>
						</td>
					</tr>
				</tfoot>
			
			</table>
		</div>
				
		<script type="text/javascript">
			$(function() {
				$('#add-site-button').click(function(e) {
					$('#multi-site-query').append('<tr class="template-row"><td class="site-name"><input type="text" value="" name="site[name][]" /></td><td class="number-of-staff"><input type="text" value="" name="site[staff][]" /></td><td class="office-space"><input type="text" value="" name="site[space][]" /></td><td class="office-space-unit"><label class="select"><select name="site[unit][]"><option value="m2">m2</option><option value="square feet">square feet</option></select><i></i></label></td><td><button class="delete-site-button" value="Delete">Delete</button><input type="hidden" name="site[client_site_id][]" value="" /></td></tr>');
					e.preventDefault();
				});
				
				$(document).on('click', '.delete-site-button', function(e) {
					$(this).closest('tr').remove();
					
					//If the deleted item was the last, add a new row 
					if($('#multi-site-query tr').length == 2) {
						$('#multi-site-query').append('<tr class="template-row"><td class="site-name"><input type="text" value="" name="site[name][]" /></td><td class="number-of-staff"><input type="text" value="" name="site[staff][]" /></td><td class="office-space"><input type="text" value="" name="site[space][]" /></td><td class="office-space-unit"><label class="select"><select name="site[unit][]"><option value="m2">m2</option><option value="square feet">square feet</option></select><i></i></label></td><td><button class="delete-site-button" value="Delete">Delete</button><input type="hidden" name="site[client_site_id][]" value="" /></td></tr>');
					}
					e.preventDefault();
				});
			});

		</script>
		
	</xsl:template>

</xsl:stylesheet>