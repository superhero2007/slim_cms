<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<!-- //Get the variable for the plugin name -->
	<xsl:variable name="plugin_id">
		<xsl:choose>
			<xsl:when test="/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']">
				<xsl:value-of select="/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/@plugin_id" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/@plugin_id" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- //Get the variable for the plugin mode -->
	<xsl:variable name="plugin_mode">
		<xsl:choose>
			<xsl:when test="/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']">current</xsl:when>
			<xsl:otherwise>legacy</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- //Get the variable for the plugin call id -->
	<xsl:variable name="plugin_method_call_id">
		<xsl:value-of select="/config/plugin[@plugin = 'dashboardContent'][@method = 'resultFilter']/@plugin_method_call_id" />
	</xsl:variable>

	<!-- //Set a variable to see if we need to display the form on postback -->
	<xsl:variable name="display">
		<xsl:choose>
			<xsl:when test="/config/globals/item[@key = 'action']/@value = 'filter-results' and count(/config/plugin[@plugin_id = $plugin_id]/filterSetting) &gt; 0">
				<xsl:text> postback</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text></xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template name="filter-link">
		<div class="row padding-bottom">
			<div class="col-md-3 col-md-offset-9">
				<button type="submit" class="btn btn-primary btn-labeled btn-default form-control height-control toggle-filter-panel pull-right">
					<span class="btn-label pull-left">
						<i class="fa fa-filter"></i>
					</span>
					<span class="show-more-filters">
						<xsl:choose>
							<xsl:when test="count(/config/plugin[@plugin_id = $plugin_id]/filterSetting) &gt; 0">
								Filters (<xsl:value-of select="count(/config/plugin[@plugin_id = $plugin_id]/filterSetting)" />)
							</xsl:when>
							<xsl:otherwise>
								Filters
							</xsl:otherwise>
						</xsl:choose>
					</span>
				</button>
			</div>
		</div>
	</xsl:template>

	<!-- //Plugin Match -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method = 'resultFilter']">
		<xsl:call-template name="result-filter-panel" />
	</xsl:template>

	<!-- //HTML template Match -->
	<xsl:template match="result-filter-panel" mode="html">
		<xsl:call-template name="result-filter-panel" />
	</xsl:template>

	<xsl:template name="result-filter-panel">

		<!-- //Filter Results Panel Link -->
		<div class="row">
			<div class="col-md-12">
				<xsl:call-template name="filter-link" />
			</div>
		</div>


		<!-- //Filter Results Panel -->
		<div class="row">
			<div class="col-md-12">
				<xsl:choose>
					<xsl:when test="$plugin_mode = 'current'">
						<xsl:call-template name="filter-results-panel" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="filter-results-panel-legacy" />
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="filter-results-panel">
		<xsl:variable name="query-data" select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/query-data" />
		<xsl:variable name="data-json-post" select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@data-json-post" />

		<!-- //Set the node from which we will run the jQuery -->
		<div class="dashboard result-filter" data-key="{$query-data/@key}" data-timestamp="{$query-data/@timestamp}" data-hash="{$query-data/@hash}" data-post-data="{$query-data/@post-data}" data-json-post="{$data-json-post}" />

		<div class="filter-results-panel{$display}">
		
			<form class="filter-results-form" method="post" action="">
				<input type="hidden" name="action" value="filter-results" />

				<!-- //All Filters go in this container -->
				<div id="data-filter-container" class="data-filter-container">

				</div>

				
				<!-- //Controls -->
				<fieldset>
					<div class="row filter-results-container-footer-buttons">
	    				<div class="form-group">
							<div class="col-md-2 col-md-offset-4">
								<button type="button" id="add-filter-row" class="btn btn-labeled btn-warning form-control height-control">
									<span class="btn-label pull-left">
										<i class="fa fa-plus"></i>
									</span>
									Add Filter
								</button>
							</div>
							<div class="col-md-2">
								<button type="submit" class="btn btn-labeled btn-success form-control height-control">
									<span class="btn-label pull-left">
										<i class="fa fa-filter"></i>
									</span>Apply Filter
								</button>
							</div>
						</div>
					</div>
				</fieldset>
			</form>
		
			
			<!-- //Template Row -->
			<div class="dashboard hidden">
				<div id="data-filter-template-row">
					<div class="row inline-form-container">
						<div class="col-md-12">
							<fieldset>
								<div class="row">
                					<div class="col-md-10">
                						<div class="row filter-field group-row">
                    						<div class="form-group">
												<div class="col-md-1 comparator">
													<label>AND</label>
												</div>
												<div class="col-md-4">
													<label class="col-md-12 control-label">Choose data field</label>
													<select class="chosen-select-dynamic input-md form-control result-filter filter-field" name="filter-field[]" id="filter-field[]">
														<option value=""> -- Select Field -- </option>
													</select>
												</div>
											</div>
											<div class="form-group">
												<div class="col-md-3">
													<label class="col-md-12 control-label">Choose query type</label>
													<select class="chosen-select-dynamic input-md form-control result-filter filter-query" name="filter-type[]" id="filter-type[]">
														<option value=""> -- Select Query -- </option>
													</select>
												</div>
											</div>
											<div class="form-group">
												<div class="col-md-4 search text">
													<label class="col-md-12 control-label">Choose search value</label>
													<input type="text" class="input form-control result-filter filter-search text" name="filter-value[]" id="filter-value[]" placeholder="Search Value" />
												</div>
												<div class="col-md-4 search select hidden">
													<label class="col-md-12 control-label">Choose search value</label>
													<select class="chosen-select-dynamic input-md form-control result-filter filter-search select" name="filter-value[][]" id="filter-value[][]" multiple="multiple" disabled="disabled">
													</select>
												</div>
											</div>
										</div>
									</div>
									<div class="form-group">
										<div class="col-md-2">
											<button type="button" class="btn btn-labeled btn-danger form-control height-control remove-filter-row" title="Remove Filter">
												<span class="btn-label pull-left">
													<i class="fa fa-trash"></i>
												</span>
												Remove Filter
											</button>
										</div>
									</div>
								</div>
							</fieldset>		
						</div>
					</div>
				</div>
			</div>

			<div class="row">
				<div class="col-md-12 hidden">
					<div class="well">
						<xsl:call-template name="filter-results-permalink" />
					</div>	
				</div>	
			</div>

		</div>
	</xsl:template>
	
	<xsl:template name="filter-results-panel-legacy">
	
		<div class="filter-results-panel{$display}">
			<div class="row hidden">
					<div class="col-md-4">
						<div class="pull-right">
							<xsl:call-template name="filter-results-permalink" />
						</div>	
					</div>	
			</div>
		
			<form class="filter-results-form" method="post" action="">
				<input type="hidden" name="action" value="filter-results" />

				<div id="data-filter-container" class="data-filter-container">
					<xsl:choose>
						<xsl:when test="/config/globals/item[@key = 'action']/@value = 'filter-results'">
							<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/filterSetting">
								<xsl:variable name="filterSetting" select="." />
								
								<div class="row inline-form-container">
									<div class="col-md-12">
										<fieldset>
											<div class="row">
												<div class="col-md-10">
													<div class="row">
				                        				<div class="form-group">
															<div class="col-md-4">
																<label class="col-md-12 control-label">Choose data field</label>
																<select class="chosen-select input-md form-control" name="filter-field[]" id="filter-field[]">
																	<option value=""> -- Select Field -- </option>
														
																	<!-- //For each available filter field -->
																	<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/filterFieldGroup">
																		<xsl:if test="count(/config/plugin[@plugin_id = $plugin_id]/filterField[@filter_field_group_id = current()/@filter_field_group_id]) &gt; 0">
																			<optgroup label="{@description}" class="optgroup-level-1">
																				<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/filterField[@filter_field_group_id = current()/@filter_field_group_id]">
																					<option value="{@filter_fields_id}">
																						<xsl:if test="@filter_fields_id  = $filterSetting/@filter-field">
																							<xsl:attribute name="selected">selected</xsl:attribute>
																						</xsl:if>
																						<xsl:value-of select="@label" />
																					</option>
																				</xsl:for-each>
																			</optgroup>
																		</xsl:if>
																	</xsl:for-each>
																	
																	<!-- //Assessment Question/Answers Filters -->
																	<!-- //For Each assessment -->
																	<optgroup label="Assessment Answers" class="optgroup-level-1">
																		<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/checklist">
																			<optgroup label="{@name}" class="optgroup-level-2">
																				<!-- //For Each assessment Page -->
																				<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/page[@checklist_id = current()/@checklist_id]">
																					<optgroup label="{@title}" class="optgroup-level-3">
																						<!-- //For Each assessment Page Question -->
																						<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/question[@page_id = current()/@page_id]">
																							<option value="{concat('qid-',@question_id)}" class="option-level-4">
																								<xsl:if test="concat('qid-',@question_id) = $filterSetting/@filter-field">
																									<xsl:attribute name="selected">selected</xsl:attribute>
																								</xsl:if>
																								<xsl:value-of select="@question" />
																							</option>
																						</xsl:for-each>											
																					</optgroup>
																				</xsl:for-each>
																			</optgroup>
																		</xsl:for-each>
																	</optgroup>
																</select>
															</div>
														</div>
				                        				<div class="form-group">
															<div class="col-md-4">
																<label class="col-md-12 control-label">Choose query type</label>
																<select class="chosen-select input-md form-control" name="filter-type[]" id="filter-type[]">
																	<option value=""> -- Select Query -- </option>
														
																	<!-- //For each available filter -->
																	<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/filterQuery">
																		<option value="{@filter_query_id}">
																			<xsl:if test="@filter_query_id  = $filterSetting/@filter-type">
																				<xsl:attribute name="selected">selected</xsl:attribute>
																			</xsl:if>
																			<xsl:value-of select="@explanation" />
																		</option>
																	</xsl:for-each>
																</select>
															</div>
														</div>
				                        				<div class="form-group">
															<div class="col-md-4">
																<label class="col-md-12 control-label">Enter search value</label>
																<input type="text" class="filter-field input form-control" name="filter-value[]" id="filter-value[]" placeholder="Search Value" value="{$filterSetting/@filter-value}" />
															</div>
														</div>
													</div>
												</div>
												<div class="form-group">
													<div class="col-md-2">
														<button type="button" class="btn btn-labeled btn-danger form-control height-control remove-filter-row" title="Remove Filter">
															<span class="btn-label pull-left">
																<i class="fa fa-trash"></i>
															</span>
															Remove Filter
														</button>
													</div>
												</div>
											</div>
										</fieldset>		
									</div>
								</div>	

							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>

							<!-- //Empty Row -->
							<div class="row inline-form-container">
								<div class="col-md-12">
									<fieldset>
										<div class="row">
											<div class="col-md-10">
												<div class="row">
			                        				<div class="form-group">
														<div class="col-md-4">
															<label class="col-md-12 control-label">Choose data field</label>
															<select class="chosen-select input-md form-control" name="filter-field[]" id="filter-field[]">
																<option value=""> -- Select Field -- </option>
													
																<!-- //For each available filter field -->
																<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/filterFieldGroup">
																	<xsl:if test="count(/config/plugin[@plugin_id = $plugin_id]/filterField[@filter_field_group_id = current()/@filter_field_group_id]) &gt; 0">
																		<optgroup label="{@description}" class="optgroup-level-1">
																			<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/filterField[@filter_field_group_id = current()/@filter_field_group_id]">
																				<option value="{@filter_fields_id}">
																					<xsl:value-of select="@label" />
																				</option>
																			</xsl:for-each>
																		</optgroup>
																	</xsl:if>
																</xsl:for-each>
																<!-- //For Each assessment -->
																<optgroup label="Assessment Answers" class="optgroup-level-1">
																	<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/checklist">
																		<optgroup label="{@name}" class="optgroup-level-2">
																			<!-- //For Each assessment Page -->
																			<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/page[@checklist_id = current()/@checklist_id]">
																				<optgroup label="{@title}" class="optgroup-level-3">
																					<!-- //For Each assessment Page Question -->
																					<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/question[@page_id = current()/@page_id]">
																						<option value="{concat('qid-',@question_id)}" class="option-level-4">
																							<xsl:value-of select="@question" />
																						</option>
																					</xsl:for-each>											
																				</optgroup>
																			</xsl:for-each>
																		</optgroup>
																	</xsl:for-each>
																</optgroup>
															</select>
														</div>
													</div>
													<div class="form-group">
														<div class="col-md-4">
															<label class="col-md-12 control-label">Choose query type</label>
															<select class="chosen-select input-md form-control" name="filter-type[]" id="filter-type[]">
																<option value=""> -- Select Query -- </option>
														
																<!-- //For each available filter -->
																<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/filterQuery">
																	<option value="{@filter_query_id}">
																		<xsl:value-of select="@explanation" />
																	</option>
																</xsl:for-each>
															</select>
														</div>
													</div>
													<div class="form-group">
														<div class="col-md-4">
															<label class="col-md-12 control-label">Enter search value</label>
															<input type="text" class="filter-field input form-control" name="filter-value[]" id="filter-value[]" placeholder="Search Value" />
														</div>
													</div>
												</div>
											</div>
											<div class="form-group">
												<div class="col-md-2">
													<button type="button" class="btn btn-danger btn-labeled btn-default form-control height-control remove-filter-row" title="Remove Filter">
														<span class="btn-label pull-left">
															<i class="fa fa-trash"></i>
														</span>
														Remove Filter
													</button>
												</div>
											</div>	
										</div>	
									</fieldset>		
								</div>
							</div>	
						</xsl:otherwise>
					</xsl:choose>
				</div>

				
				<!-- //Controls -->
				<fieldset>
					<div class="row filter-results-container-footer-buttons">
	    				<div class="form-group">
							<div class="col-md-2 col-md-offset-4">
								<button type="button" id="add-filter-row" class="btn btn-labeled btn-warning form-control height-control">
									<span class="btn-label pull-left">
										<i class="fa fa-plus"></i>
									</span>
									Add Filter
								</button>
							</div>
							<div class="col-md-2">
								<button type="submit" class="btn btn-labeled btn-success form-control height-control">
									<span class="btn-label pull-left">
										<i class="fa fa-filter"></i>
									</span>Apply Filter
								</button>
							</div>
						</div>
					</div>
				</fieldset>
			</form>
		
			
			<!-- //Template Row -->
			<div class="dashboard hidden">
				<div id="data-filter-template-row">
					<div class="row inline-form-container">
						<div class="col-md-12">
							<fieldset>
								<div class="row">
                					<div class="col-md-10">
                						<div class="row">
                    						<div class="form-group">
												<div class="col-md-4">
													<label class="col-md-12 control-label">Choose data field</label>
													<select class="chosen-select-dynamic input-md form-control" name="filter-field[]" id="filter-field[]">
														<option value=""> -- Select Field -- </option>
											
														<!-- //For each available filter field -->
														<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/filterFieldGroup">
															<xsl:if test="count(/config/plugin[@plugin_id = $plugin_id]/filterField[@filter_field_group_id = current()/@filter_field_group_id]) &gt; 0">
																<optgroup label="{@description}" class="optgroup-level-1">
																	<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/filterField[@filter_field_group_id = current()/@filter_field_group_id]">
																		<option value="{@filter_fields_id}">
																			<xsl:value-of select="@label" />
																		</option>
																	</xsl:for-each>
																</optgroup>
															</xsl:if>
														</xsl:for-each>
														
														<optgroup label="Assessment Answers" class="optgroup-level-1">
															<!-- //For Each assessment -->
															<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/checklist">
																<optgroup label="{@name}" class="optgroup-level-2">
																	<!-- //For Each assessment Page -->
																	<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/page[@checklist_id = current()/@checklist_id]">
																		<optgroup label="{@title}" class="optgroup-level-3">
																			<!-- //For Each assessment Page Question -->
																			<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/question[@page_id = current()/@page_id]">
																				<option value="{concat('qid-',@question_id)}" class="option-level-4">
																					<xsl:value-of select="@question" />
																				</option>
																			</xsl:for-each>											
																		</optgroup>
																	</xsl:for-each>
																</optgroup>
															</xsl:for-each>
														</optgroup>
													</select>
												</div>
											</div>
											<div class="form-group">
												<div class="col-md-4">
													<label class="col-md-12 control-label">Choose query type</label>
													<select class="chosen-select-dynamic input-md form-control" name="filter-type[]" id="filter-type[]">
														<option value=""> -- Select Query -- </option>
														
														<!-- //For each available filter -->
														<xsl:for-each select="/config/plugin[@plugin_id = $plugin_id]/filterQuery">
															<option value="{@filter_query_id}">
																<xsl:value-of select="@explanation" />
															</option>
														</xsl:for-each>
													</select>
												</div>
											</div>
											<div class="form-group">
												<div class="col-md-4">
													<label class="col-md-12 control-label">Enter search value</label>
													<input type="text" class="filter-field input form-control" name="filter-value[]" id="filter-value[]" placeholder="Search Value" />
												</div>
											</div>
										</div>
									</div>
									<div class="form-group">
										<div class="col-md-2">
											<button type="button" class="btn btn-labeled btn-danger form-control height-control remove-filter-row" title="Remove Filter">
												<span class="btn-label pull-left">
													<i class="fa fa-trash"></i>
												</span>
												Remove Filter
											</button>
										</div>
									</div>
								</div>
							</fieldset>		
						</div>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="filter-results-permalink" mode="html">
		<xsl:call-template name="filter-results-permalink" />
	</xsl:template>

	<xsl:template name="filter-results-permalink">
		<xsl:value-of select="/config/plugin[@plugin_id = $plugin_id]/filterPermalink/@link" />
	</xsl:template>

</xsl:stylesheet>