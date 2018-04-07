<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="/config/plugin[@plugin = 'savingscalc'][@method = 'display']">

		<div class="row">

			<!-- //Inputs -->
			<div class="col-md-5">
				<form method="post" action="" class="form-horizontal" id="savings-calc" data-parsley-validate="data-parsley-validate" novalidate="" data-parsley-excluded="[disabled]">
					<input type="hidden" name="action" id="action" value="" data-parsley-excluded="true" />
					<div class="entry page row">

						<!-- //Question 1 -->
						<div class="col-md-12 question">
							<fieldset class="entry question">
								<div class="entry question form-group">
									<label class="entry question-content">What is your organization's approximate electricity bill?</label>
								</div>

								<div class="row">
									<div class="col-md-6">
										<div class="input-group m-b prepend">
											<span class="input-group-addon">$</span>
											<input type="number" step="any" name="electricity-bill" id="electricity-bill" class="form-control" />
										</div>
									</div>
									<div class="col-md-6">
										<div class="select drop-down-list">
											<select class="form-control" data-questionid="electricity-bill-period"  name="electricity-bill-period" id="electricity-bill-period">
												<option value="12" selected="selected">Annum</option>
												<option value="3">Quarter</option>
												<option value="1">Month</option>
											</select>
											<i></i>
										</div>
									</div>
								</div>
								

							</fieldset>
						</div>

						<!-- //Question 2 -->
						<div class="col-md-12 question">
							<fieldset class="entry question">
								<div class="entry question form-group">
									<label class="entry question-content">What percentage of IT equipment is left on after hours?</label>
								</div>
								<input type="text" data-ui-slider="data-ui-slider" name="percent-computers-left-on" id="percent-computers-left-on" data-slider-min="0" data-slider-max="100" data-slider-step="5" data-unit="%" data-slider-orientation="horizontal" data-slider-value="100" class="slider slider-range slider-horizontal" data-slider-id="slider-percent-computers-left-on" />
							</fieldset>
						</div>

						<!-- //Question 3 -->
						<div class="col-md-12 question">
							<fieldset class="entry question">
								<div class="entry question form-group">
									<label class="entry question-content">Does your organization use air-conditioners to cool or heat your office?</label>
								</div>
								<div class="radio c-radio">
									<label>
										<input type="radio" id="air-con-on" name="air_con" value="1" checked="checked" />
										<span class="fa fa-check"></span>
										<div class="entry answer-string">Yes</div>
									</label>
								</div>
								<div class="radio c-radio">
									<label>
										<input type="radio" id="air-con-on" name="air_con" value="0" />
										<span class="fa fa-check"></span>
										<div class="entry answer-string">No</div>
									</label>
								</div>
							</fieldset>
						</div>

						<div id="air-con" style="display: none;">
							<!-- //Question 4 -->
							<div class="col-md-12 question">
								<fieldset class="entry question">
									<div class="entry question form-group">
										<label class="entry question-content">What is the temperature set on hot days?</label>
									</div>
									<input type="text" data-ui-slider="data-ui-slider" name="hot-day-temp" id="hot-day-temp" data-slider-min="18" data-slider-max="26" data-slider-step="1" data-unit="&#176;C" data-slider-orientation="horizontal" data-slider-value="22" class="slider slider-range slider-horizontal" data-slider-id="slider-hot-day-temp" />
								</fieldset>
							</div>

							<!-- //Question 5 -->
							<div class="col-md-12 question">
								<fieldset class="entry question">
									<div class="entry question form-group">
										<label class="entry question-content">What is the temperature set on cold days?</label>
									</div>
									<input type="text" data-ui-slider="data-ui-slider" name="cold-day-temp" id="cold-day-temp" data-slider-min="18" data-slider-max="26" data-slider-step="1" data-unit="&#176;C" data-slider-orientation="horizontal" data-slider-value="24" class="slider slider-range slider-horizontal" data-slider-id="slider-cold-day-temp" />
								</fieldset>
							</div>
						</div>

						<!-- //Question 6 -->
						<div class="col-md-12 question">
							<fieldset class="entry question">
								<div class="entry question form-group">
									<label class="entry question-content">What percentage of lighting uses energy efficient bulbs and/or has motion sensors to switch them on and off?</label>
								</div>
								<input type="text" data-ui-slider="data-ui-slider" name="percent-efficient-lighting" id="percent-efficient-lighting" data-slider-min="0" data-slider-max="100" data-slider-step="5" data-unit="%" data-slider-orientation="horizontal" data-slider-value="0" class="slider slider-range slider-horizontal" data-slider-id="slider-percent-efficient-lighting" />
							</fieldset>
						</div>

						<!-- //Question 7 -->
						<div class="col-md-12 question">
							<fieldset class="entry question">
								<div class="entry question form-group">
									<label class="entry question-content">What percentage of electric appliances are left on (not standby) after hours?</label>
								</div>
								<input type="text" data-ui-slider="data-ui-slider" name="percent-appliances-left-on" id="percent-appliances-left-on" data-slider-min="0" data-slider-max="100" data-slider-step="5" data-unit="%" data-slider-orientation="horizontal" data-slider-value="100" class="slider slider-range slider-horizontal" data-slider-id="slider-percent-appliances-left-on" />
							</fieldset>
						</div>

					</div>
				</form>
			</div>				


			<div class="col-md-offset-1 col-md-6 bg-base">

				<!-- //Right Half -->
				<br /><br />
				<h4>Your Potential Savings</h4>
				<fieldset>
					<h6>Your potential IT, cooling / heating, lighting and electrical appliances savings:</h6>
					<div class="well">
						<h2 style="color:rgb(51,51,51) !important;">
							<xsl:text>$</xsl:text>
							<span id="savings">0</span>
							<xsl:text> per year</xsl:text>
						</h2>
					</div>
				</fieldset>
				<h6>Maximise Savings with GreenBizCheck's CSR Certification</h6>
				<fieldset>
					<div class="clear">
						<p>Our fast, low-cost CSR Certification could save you an additional 50% or:</p>
						<div class="well">
							<h2 style="color:rgb(51,51,51) !important;">
								<xsl:text>$</xsl:text>
								<span id="potential-savings">0</span>
								<xsl:text> per year</xsl:text>
							</h2>
						</div>
					</div>
					
					<div class="text-center clear">
						<a href="/csr-certification/" class="btn btn-lg btn-alt center">Learn More</a>
					</div>
				</fieldset>

				<h6 class="pt40">Suggestions to Save Money</h6>
				<div id="suggestions" />
				<br class="clear" />

				<h6>Underlying Assumptions</h6>
			
				<p>These calculations are based on the following energy use assumptions in the office:</p>
				<table class="table table-responsive">
					<tbody>
						<tr>
							<td>Cooling / heating</td>
							<td>35%</td>
						</tr>
						<tr>
							<td>IT</td>
							<td>18%</td>
						</tr>
						<tr>
							<td>Electrical appliances</td>
							<td>9%</td>
						</tr>
						<tr>
							<td>Lighting</td>
							<td>25%</td>
						</tr>
						<tr>
							<td>Ventilation</td>
							<td>5%</td>
						</tr>
						<tr>
							<td>Other</td>
							<td>8%</td>
						</tr>
					</tbody>
				</table>
				<p>These calculations do not take into account the possibility of your company using highly inefficient servers, PCs, electrical appliances, etc. If this is the case you can achieve even greater savings by replacing inefficient appliances with energy efficient ones.</p>

				<br class="clear" />
				<h6>Disclaimer</h6>
				<p>This savings calculator has been provided to you by GreenBizCheck. It is solely intended for informational purposes. Actual savings may vary substantially from business to business. GreenBizCheck accepts no liability with regards to the accuracy of the calculations and/or potential savings.</p>

			</div>
		</div>

	</xsl:template>



	<xsl:template match="/config/plugin[@plugin = 'savingscalc'][@method = 'displayLegacy']">

		<div class="row-fluid">
			<h2>Energy Savings Calculator</h2>

			<div class="col-md-6 wp-block">
				<div class="wp-block-body">

					<!-- //Left half for input -->
					<div class="contentmain">
						<div id="assessment-container" class="assessment-container">
							<form method="post" action="" id="checklist" class="checklist">
								<div id="assessment-body">
									<fieldset>

										<!-- //Question -->
										<p>
											<label>
												<strong>What is your organization's approximate electricity bill?</strong>
											</label>
										</p>
												<span class="error" id="electricity-bill-error"></span>
												<div class="col-md-1 wp-block">
													<span class="form-text">
														<xsl:text>$</xsl:text>
													</span>
												</div>

												<div class="col-md-5 wp-block">
													<input type="text" id="electricity-bill" size="8" maxlength="8" />
												</div>
	
												<div class="col-md-1 wp-block">
													<span class="form-text">
														<xsl:text>per</xsl:text>
													</span>
												</div>

												<div class="col-md-5 wp-block">
													<select id="electricity-bill-period">
														<option value="12">annum</option>
														<option value="3">quarter</option>
														<option value="1">month</option>
													</select>
												</div>

									</fieldset>
								</div>
								<div id="assessment-question-footer" />

								<div id="assessment-body">
									<fieldset>
										<p><strong>What percentage of IT equipment is left on after hours?</strong></p>

                                    
        									<div class="slider-container">
												<div id="slider-computers">
													<input type="hidden" id="percent-computers-left-on" value="100" />
												</div>
											</div>
									
									</fieldset>
								</div>
								<div id="assessment-question-footer" />

								<div id="assessment-body">
									<fieldset>
										<p>
											<label>
												<strong>Does your organization use air-conditioners to cool or heat your office?</strong>
											</label>
										</p>

										<p>
											<label class="css-checkbox-radio">
                            					<input type="radio" id="air-con-on" name="air_con" value="1" checked="checked" />
                              					<span class="css-checkbox-radio-image radio"></span>
                            					<span class="css-checkbox-radio-label radio">Yes</span>
                          					</label>

											<label class="css-checkbox-radio">
                            					<input type="radio" id="air-con-off" name="air_con" value="0" />
                              					<span class="css-checkbox-radio-image radio"></span>
                            					<span class="css-checkbox-radio-label radio">No</span>
                          					</label>
										</p>
									</fieldset>
								</div>
								<div id="assessment-question-footer" />

								<div id="assessment-body">
									<fieldset>

										<!-- //Celsius -->
										<div id="air-con" style="display: none;">

											<p><strong>What is the temperature set on hot days?</strong></p>

        									<div class="slider-container double-height">
												<div id="slider-hot-day">
													<input type="hidden" id="hot-day-temp" />
												</div>
											</div>

											<br class="clear" />
											<div id="assessment-question-footer" />

											<p><strong>What is the temperature set on cold days?</strong></p>

        									<div class="slider-container double-height">
												<div id="slider-cold-day">
													<input type="hidden" id="cold-day-temp" />
												</div>
											</div>

											<br class="clear" />
											<div id="assessment-question-footer" />
										</div>
									</fieldset>
								</div>
								
								<div id="assessment-body">
									<fieldset>
										<p><strong>What percentage of lighting uses energy efficient bulbs and/or has motion sensors to switch them on and off?</strong></p>

    									<div class="slider-container">
											<div id="slider-lighting">
												<input type="hidden" id="percent-efficient-lighting" />
											</div>
										</div>

									</fieldset>
								</div>
								<div id="assessment-question-footer" />
								
								<div id="assessment-body">
									<fieldset>
										<p><strong>What percentage of electric appliances are left on (not standby) after hours?</strong></p>

    									<div class="slider-container">
											<div id="slider-appliances">
												<input type="hidden" id="percent-appliances-left-on" />
											</div>
										</div>

									</fieldset>
								</div>
								<div id="assessment-question-footer" />

							</form>

						</div>
					</div>
				</div>
			</div>
			<div class="col-md-6 wp-block base">
				<div class="wp-block-body">

					<!-- //Right Half -->
					<h4>Your Potential Savings</h4>
					<fieldset>
						<h6>Your potential IT, cooling / heating, lighting and electrical appliances savings:</h6>
						<div class="well">
							<h2 style="color:rgb(51,51,51) !important;">
								<xsl:text>$</xsl:text>
								<span id="savings">0</span>
								<xsl:text> per year</xsl:text>
							</h2>
						</div>
					</fieldset>
					<h6>Maximise Savings with GreenBizCheck's CSR Certification</h6>
					<fieldset>
						<div class="clear">
							<p>Our fast, low-cost CSR Certification could save you an additional 50% or:</p>
							<div class="well">
								<h2 style="color:rgb(51,51,51) !important;">
									<xsl:text>$</xsl:text>
									<span id="potential-savings">0</span>
									<xsl:text> per year</xsl:text>
								</h2>
							</div>
						</div>
						
						<div class="text-center clear">
							<a href="/csr-certification/" class="btn btn-lg btn-alt center">Learn More</a>
						</div>
					</fieldset>

					<h6 class="pt40">Suggestions to Save Money</h6>
					<div id="suggestions" />
					<br class="clear" />

					<h6>Underlying Assumptions</h6>
				
					<p>These calculations are based on the following energy use assumptions in the office:</p>
					<table class="table table-responsive">
						<tbody>
							<tr>
								<td>Cooling / heating</td>
								<td>35%</td>
							</tr>
							<tr>
								<td>IT</td>
								<td>18%</td>
							</tr>
							<tr>
								<td>Electrical appliances</td>
								<td>9%</td>
							</tr>
							<tr>
								<td>Lighting</td>
								<td>25%</td>
							</tr>
							<tr>
								<td>Ventilation</td>
								<td>5%</td>
							</tr>
							<tr>
								<td>Other</td>
								<td>8%</td>
							</tr>
						</tbody>
					</table>
					<p>These calculations do not take into account the possibility of your company using highly inefficient servers, PCs, electrical appliances, etc. If this is the case you can achieve even greater savings by replacing inefficient appliances with energy efficient ones.</p>
	
					<br class="clear" />
					<h6>Disclaimer</h6>
					<p>This savings calculator has been provided to you by GreenBizCheck. It is solely intended for informational purposes. Actual savings may vary substantially from business to business. GreenBizCheck accepts no liability with regards to the accuracy of the calculations and/or potential savings.</p>


				</div>
			</div>
		</div>

	</xsl:template>

</xsl:stylesheet>