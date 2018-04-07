<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">

	<!-- //AusLSA Templates -->
	<!--//HTML -->
	<xsl:template match="auslsa-report-summary-information" mode="html">
		<xsl:call-template name="auslsa-report-summary-information" />
	</xsl:template>

	<!--//PDF -->
	<xsl:template match="auslsa-report-summary-information" mode="xhtml">
		<xsl:call-template name="auslsa-report-summary-information-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-summary-information">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="number_of_employees" select="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value" />
		<xsl:variable name="floor_area" select="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value" />
		<div class="row">
			<div class="col-md-4">
				<div class="box-element base">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$report/@date_range_finish_year &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{$report/@date_range_finish_year}" data-speed="2000" data-custom-formatter="year"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000" data-custom-formatter="year"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Reporting Year</p>
	                    </div>
	                </div>
	            </div>
	        </div>
			<div class="col-md-4">
				<div class="box-element base">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$number_of_employees &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{$number_of_employees}" data-speed="2000"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Number of employees</p>
	                    </div>
	                </div>
	            </div>
	        </div>
			<div class="col-md-4">
				<div class="box-element base">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$floor_area &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{$floor_area}" data-speed="2000"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Floor area <xsl:text> </xsl:text>m<sup>2</sup></p>
	                    </div>
	                </div>
	            </div>
	        </div>
    	</div>
	</xsl:template>

	<xsl:template name="auslsa-report-summary-information-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="number_of_employees" select="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value" />
		<xsl:variable name="floor_area" select="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value" />
        
        <fo:table margin-bottom="20px">
        	<fo:table-body>
	        	<fo:table-row>
	        		<fo:table-cell background-color="#77a837" padding="10px" border-right="10px solid #ffffff">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$report/@date_range_finish_year &gt; 0">
				        			<xsl:value-of select="$report/@date_range_finish_year"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				        		</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">Reporting Year</fo:block>
				    </fo:table-cell>
	        		<fo:table-cell background-color="#77a837" padding="10px" border-right="10px solid #ffffff">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$number_of_employees &gt; 0">
				        			<xsl:value-of select="$number_of_employees"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				        		</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">Number of Employees</fo:block>
				    </fo:table-cell>
	        		<fo:table-cell background-color="#77a837" padding="10px">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$floor_area &gt; 0">
				        			<xsl:value-of select="$floor_area"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				       			</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">Floor Area m2</fo:block>
				    </fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>

	</xsl:template>


	<xsl:template match="auslsa-report-carbon-emission-sources-table" mode="html">
		<xsl:call-template name="auslsa-report-carbon-emission-sources-table" />
	</xsl:template>
	<xsl:template match="auslsa-report-carbon-emission-sources-table" mode="xhtml">
		<xsl:call-template name="auslsa-report-carbon-emission-sources-table-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-carbon-emission-sources-table-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="gross_emissions" select="sum($report/additionalValues/additionalValue[@group = 'Emmission']/@value)" />
		<xsl:variable name="refrigerants" select="sum($report/additionalValues/additionalValue[@key = 'Refrigerants']/@value)" />
		<xsl:variable name="purchased_electricity" select="sum($report/additionalValues/additionalValue[@key = 'Purchased Electricity']/@value)" />
		<xsl:variable name="green_tariff_electricity" select="sum($report/additionalValues/additionalValue[@key = 'Green Tariff Electricity']/@value)" />
		<xsl:variable name="flights" select="sum($report/additionalValues/additionalValue[@key = 'Flights - Short Haul']/@value) + sum($report/additionalValues/additionalValue[@key = 'Flights - International']/@value)" />
		<xsl:variable name="taxis" select="sum($report/additionalValues/additionalValue[@key = 'Taxis']/@value)" />
		
		<xsl:variable name="onsite_combustion" select="sum($report/additionalValues/additionalValue[@key = 'On-Site Combustion']/@value)" />
		<xsl:variable name="company_vehicles" select="sum($report/additionalValues/additionalValue[@key = 'Company Vehicles']/@value)" />
		<xsl:variable name="hire_cars" select="sum($report/additionalValues/additionalValue[@key = 'Hire Cars']/@value)" />
		<xsl:variable name="personal_vehicles" select="sum($report/additionalValues/additionalValue[@key = 'Personal Vehicles']/@value)" />
		

		<xsl:variable name="number_of_employees">
			<xsl:choose>
				<xsl:when test="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value">
					<xsl:value-of select="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="floor_area">
			<xsl:choose>
				<xsl:when test="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value">
					<xsl:value-of select="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="20%" />
			<fo:table-column column-width="20%" />
			<fo:table-column column-width="20%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Scope 1</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Tonnes CO2e</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Per employee</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Per floor area</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">On-Site Combustion</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($onsite_combustion, '#,##0.00')" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($onsite_combustion div $number_of_employees, '#,##0.0000')" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($onsite_combustion div $floor_area, '#,##0.0000')" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Company Vehicles</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($company_vehicles, '#,##0.00')" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($company_vehicles div $number_of_employees, '#,##0.0000')" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($company_vehicles div $floor_area, '#,##0.0000')" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>			
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Refrigerants</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($refrigerants, '#,##0.00')" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($refrigerants div $number_of_employees, '#,##0.0000')" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($refrigerants div $floor_area, '#,##0.0000')" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>							
			</fo:table-body>
		</fo:table>

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="20%" />
			<fo:table-column column-width="20%" />
			<fo:table-column column-width="20%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Scope 3</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Tonnes CO2e</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Per employee</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Per floor area</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Purchased Electricity</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($purchased_electricity, '#,##0.00')" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($purchased_electricity div $number_of_employees, '#,##0.0000')" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($purchased_electricity div $floor_area, '#,##0.0000')" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Green Tariff Electricity</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($green_tariff_electricity, '#,##0.00')" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($green_tariff_electricity div $number_of_employees, '#,##0.0000')" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($green_tariff_electricity div $floor_area, '#,##0.0000')" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>								
			</fo:table-body>
		</fo:table>

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="20%" />
			<fo:table-column column-width="20%" />
			<fo:table-column column-width="20%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Scope 3</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Tonnes CO2e</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Per employee</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Per floor area</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Flights</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$flights &gt; -1">
									<xsl:value-of select="format-number($flights, '#,##0.00')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$flights &gt; -1">
									<xsl:value-of select="format-number($flights div $number_of_employees, '#,##0.0000')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$flights &gt; -1">
									<xsl:value-of select="format-number($flights div $floor_area, '#,##0.0000')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Taxis</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$taxis &gt; -1">
									<xsl:value-of select="format-number($taxis, '#,##0.00')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$taxis &gt; -1">
									<xsl:value-of select="format-number($taxis div $number_of_employees, '#,##0.0000')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$taxis &gt; -1">
									<xsl:value-of select="format-number($taxis div $floor_area, '#,##0.0000')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>			
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Hire Cars</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$hire_cars &gt; -1">
									<xsl:value-of select="format-number($hire_cars, '#,##0.00')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$hire_cars &gt; -1">
									<xsl:value-of select="format-number($hire_cars div $number_of_employees, '#,##0.0000')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$hire_cars &gt; -1">
									<xsl:value-of select="format-number($hire_cars div $floor_area, '#,##0.0000')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Personal Vehicles</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$personal_vehicles &gt; -1">
									<xsl:value-of select="format-number($personal_vehicles, '#,##0.00')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$personal_vehicles &gt; -1">
									<xsl:value-of select="format-number($personal_vehicles div $number_of_employees, '#,##0.0000')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$personal_vehicles &gt; -1">
									<xsl:value-of select="format-number($personal_vehicles div $floor_area, '#,##0.0000')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>									
			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template name="auslsa-report-carbon-emission-sources-table">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="gross_emissions" select="sum($report/additionalValues/additionalValue[@group = 'Emmission']/@value)" />
		<xsl:variable name="refrigerants" select="sum($report/additionalValues/additionalValue[@key = 'Refrigerants']/@value)" />
		<xsl:variable name="purchased_electricity" select="sum($report/additionalValues/additionalValue[@key = 'Purchased Electricity']/@value)" />
		<xsl:variable name="green_tariff_electricity" select="sum($report/additionalValues/additionalValue[@key = 'Green Tariff Electricity']/@value)" />
		<xsl:variable name="flights" select="sum($report/additionalValues/additionalValue[@key = 'Flights - Short Haul']/@value) + sum($report/additionalValues/additionalValue[@key = 'Flights - International']/@value)" />
		<xsl:variable name="taxis" select="sum($report/additionalValues/additionalValue[@key = 'Taxis']/@value)" />
		
		<xsl:variable name="onsite_combustion" select="sum($report/additionalValues/additionalValue[@key = 'On-Site Combustion']/@value)" />
		<xsl:variable name="company_vehicles" select="sum($report/additionalValues/additionalValue[@key = 'Company Vehicles']/@value)" />
		<xsl:variable name="hire_cars" select="sum($report/additionalValues/additionalValue[@key = 'Hire Cars']/@value)" />
		<xsl:variable name="personal_vehicles" select="sum($report/additionalValues/additionalValue[@key = 'Personal Vehicles']/@value)" />
		

		<xsl:variable name="number_of_employees">
			<xsl:choose>
				<xsl:when test="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value">
					<xsl:value-of select="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="floor_area">
			<xsl:choose>
				<xsl:when test="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value">
					<xsl:value-of select="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>


		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th>
								Scope 1
							</th>
							<th width="20%" class="text-right">
								Tonnes CO2e
							</th>
							<th width="20%" class="text-right">
								Per employee
							</th>
							<th width="20%" class="text-right">
								Per floor area
							</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>
								On-Site Combustion
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($onsite_combustion, '#,##0.00')" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($onsite_combustion div $number_of_employees, '#,##0.0000')" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($onsite_combustion div $floor_area, '#,##0.0000')" />
							</td>
						</tr>
						<tr>
							<td>
								Company Vehicles
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($company_vehicles, '#,##0.00')" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($company_vehicles div $number_of_employees, '#,##0.0000')" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($company_vehicles div $floor_area, '#,##0.0000')" />
							</td>
						</tr>
						<tr>
							<td>
								Refrigerants
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($refrigerants, '#,##0.00')" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($refrigerants div $number_of_employees, '#,##0.0000')" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($refrigerants div $floor_area, '#,##0.0000')" />
							</td>
						</tr>
					</tbody>
				</table>

				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th>
								Scope 2
							</th>
							<th width="20%" class="text-right">
								Tonnes CO2e
							</th>
							<th width="20%" class="text-right">
								Per employee
							</th>
							<th width="20%" class="text-right">
								Per floor area
							</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>
								Purchased Electricity
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($purchased_electricity, '#,##0.00')" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($purchased_electricity div $number_of_employees, '#,##0.0000')" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($purchased_electricity div $floor_area, '#,##0.0000')" />
							</td>
						</tr>
						<tr>
							<td>
								Green Tariff Electricity
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($green_tariff_electricity, '#,##0.00')" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($green_tariff_electricity div $number_of_employees, '#,##0.0000')" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($green_tariff_electricity div $floor_area, '#,##0.0000')" />
							</td>
						</tr>
					</tbody>
				</table>

				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th>
								Scope 3
							</th>
							<th width="20%" class="text-right">
								Tonnes CO2e
							</th>
							<th width="20%" class="text-right">
								Per employee
							</th>
							<th width="20%" class="text-right">
								Per floor area
							</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>
								Flights
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$flights &gt; -1">
										<xsl:value-of select="format-number($flights, '#,##0.00')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$flights &gt; -1">
										<xsl:value-of select="format-number($flights div $number_of_employees, '#,##0.0000')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$flights &gt; -1">
										<xsl:value-of select="format-number($flights div $floor_area, '#,##0.0000')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td>
								Taxis
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$taxis &gt; -1">
										<xsl:value-of select="format-number($taxis, '#,##0.00')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$taxis &gt; -1">
										<xsl:value-of select="format-number($taxis div $number_of_employees, '#,##0.0000')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$taxis &gt; -1">
										<xsl:value-of select="format-number($taxis div $floor_area, '#,##0.0000')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td>
								Hire Cars
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$hire_cars &gt; -1">
										<xsl:value-of select="format-number($hire_cars, '#,##0.00')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$hire_cars &gt; -1">
										<xsl:value-of select="format-number($hire_cars div $number_of_employees, '#,##0.0000')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$hire_cars &gt; -1">
										<xsl:value-of select="format-number($hire_cars div $floor_area, '#,##0.0000')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td>
								Personal Vehicles
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$personal_vehicles &gt; -1">
										<xsl:value-of select="format-number($personal_vehicles, '#,##0.00')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$personal_vehicles &gt; -1">
										<xsl:value-of select="format-number($personal_vehicles div $number_of_employees, '#,##0.0000')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$personal_vehicles &gt; -1">
										<xsl:value-of select="format-number($personal_vehicles div $floor_area, '#,##0.0000')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</tbody>
				</table>

			</div>
		</div>

	</xsl:template>


	<xsl:template match="auslsa-report-carbon-emission-sources" mode="html">
		<xsl:call-template name="auslsa-report-carbon-emission-sources" />
	</xsl:template>

	<xsl:template match="auslsa-report-carbon-emission-sources" mode="xhtml">
		<xsl:call-template name="auslsa-report-carbon-emission-sources-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-carbon-emission-sources">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="gross_emissions" select="sum($report/additionalValues/additionalValue[@group = 'Emmission']/@value)" />
		<xsl:variable name="refrigerants" select="sum($report/additionalValues/additionalValue[@key = 'Refrigerants']/@value)" />
		<xsl:variable name="purchased_electricity" select="sum($report/additionalValues/additionalValue[@key = 'Purchased Electricity']/@value)" />
		<xsl:variable name="green_tariff_electricity" select="sum($report/additionalValues/additionalValue[@key = 'Green Tariff Electricity']/@value)" />
		<xsl:variable name="flights" select="sum($report/additionalValues/additionalValue[@key = 'Flights - Short Haul']/@value) + sum($report/additionalValues/additionalValue[@key = 'Flights - International']/@value)" />
		<xsl:variable name="taxis" select="sum($report/additionalValues/additionalValue[@key = 'Taxis']/@value)" />
		
		<xsl:variable name="onsite_combustion" select="sum($report/additionalValues/additionalValue[@key = 'On-Site Combustion']/@value)" />
		<xsl:variable name="company_vehicles" select="sum($report/additionalValues/additionalValue[@key = 'Company Vehicles']/@value)" />
		<xsl:variable name="hire_cars" select="sum($report/additionalValues/additionalValue[@key = 'Hire Cars']/@value)" />
		<xsl:variable name="personal_vehicles" select="sum($report/additionalValues/additionalValue[@key = 'Personal Vehicles']/@value)" />
		

		<xsl:variable name="number_of_employees">
			<xsl:choose>
				<xsl:when test="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value">
					<xsl:value-of select="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="floor_area">
			<xsl:choose>
				<xsl:when test="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value">
					<xsl:value-of select="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="row padding-bottom-30">

			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$gross_emissions &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($gross_emissions, '#.##')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Gross total emissions CO<sub>2</sub>e</p>
	                    </div>
	                </div>
	            </div>
	        </div>
			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$gross_emissions &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($gross_emissions div $number_of_employees, '#.###')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Gross emissions per employee CO<sub>2</sub>e</p>
	                    </div>
	                </div>
	            </div>
	        </div>
			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$gross_emissions &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($gross_emissions div $floor_area, '#.###')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Gross emissions per floor area CO<sub>2</sub>e</p>
	                    </div>
	                </div>
	            </div>
	        </div>
    	</div>

	</xsl:template>

	<xsl:template name="auslsa-report-carbon-emission-sources-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="gross_emissions" select="sum($report/additionalValues/additionalValue[@group = 'Emmission']/@value)" />
		<xsl:variable name="refrigerants" select="sum($report/additionalValues/additionalValue[@key = 'Refrigerants']/@value)" />
		<xsl:variable name="purchased_electricity" select="sum($report/additionalValues/additionalValue[@key = 'Purchased Electricity']/@value)" />
		<xsl:variable name="green_tariff_electricity" select="sum($report/additionalValues/additionalValue[@key = 'Green Tariff Electricity']/@value)" />
		<xsl:variable name="flights" select="sum($report/additionalValues/additionalValue[@key = 'Flights - Short Haul']/@value) + sum($report/additionalValues/additionalValue[@key = 'Flights - International']/@value)" />
		<xsl:variable name="taxis" select="sum($report/additionalValues/additionalValue[@key = 'Taxis']/@value)" />
		
		<xsl:variable name="onsite_combustion" select="sum($report/additionalValues/additionalValue[@key = 'On-Site Combustion']/@value)" />
		<xsl:variable name="company_vehicles" select="sum($report/additionalValues/additionalValue[@key = 'Company Vehicles']/@value)" />
		<xsl:variable name="hire_cars" select="sum($report/additionalValues/additionalValue[@key = 'Hire Cars']/@value)" />
		<xsl:variable name="personal_vehicles" select="sum($report/additionalValues/additionalValue[@key = 'Personal Vehicles']/@value)" />
		

		<xsl:variable name="number_of_employees">
			<xsl:choose>
				<xsl:when test="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value">
					<xsl:value-of select="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="floor_area">
			<xsl:choose>
				<xsl:when test="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value">
					<xsl:value-of select="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

        <fo:table margin-bottom="20px">
        	<fo:table-body>
	        	<fo:table-row keep-together.within-page="always">
	        		<fo:table-cell background-color="#77a837" padding="10px" border-right="10px solid #ffffff">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$gross_emissions &gt; 0">
				        			<xsl:value-of select="format-number($gross_emissions, '#.##')"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				        		</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">Gross total emissions CO2e</fo:block>
				    </fo:table-cell>
	        		<fo:table-cell background-color="#77a837" padding="10px" border-right="10px solid #ffffff">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$gross_emissions &gt; 0">
				        			<xsl:value-of select="format-number($gross_emissions div $number_of_employees, '#.##')"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				        		</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">Gross emissions per employee CO2e</fo:block>
				    </fo:table-cell>
	        		<fo:table-cell background-color="#77a837" padding="10px">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$gross_emissions &gt; 0">
				        			<xsl:value-of select="format-number($gross_emissions div $floor_area, '#.##')"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				       			</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">Gross emissions per floor area CO2e</fo:block>
				    </fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template match="auslsa-report-carbon-mitigation-activities" mode="html">
		<xsl:call-template name="auslsa-report-carbon-mitigation-activities" />
	</xsl:template>

	<xsl:template match="auslsa-report-carbon-mitigation-activities" mode="xhtml">
		<xsl:call-template name="auslsa-report-carbon-mitigation-activities-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-carbon-mitigation-activities-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="green_tariff_electricity" select="sum($report/additionalValues/additionalValue[@key = 'Green Tariff Electricity']/@value)" />
		<xsl:variable name="gross_emissions" select="sum($report/additionalValues/additionalValue[@group = 'Emmission']/@value)" />
		<xsl:variable name="carbon_credits" select="sum($report/questionAnswer/answer[@answer_id = '33162']/@arbitrary_value)" />
		<xsl:variable name="total_offsetting" select="$carbon_credits + $green_tariff_electricity" />
		<xsl:variable name="net_emissions" select="$gross_emissions - $total_offsetting" />
		<xsl:variable name="number_of_employees" select="sum($report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value)" />
		<xsl:variable name="floor_area" select="sum($report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value)" />

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="80%" />
			<fo:table-column column-width="20%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Activity</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Tonnes CO2e</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Green tariff electricity</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($green_tariff_electricity, '0.0000')" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Voluntary carbon offsetting</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="format-number($carbon_credits, '0.0000')" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>								
			</fo:table-body>
		</fo:table>

        <fo:table margin-bottom="20px">
        	<fo:table-body>
	        	<fo:table-row keep-together.within-page="always">
	        		<fo:table-cell background-color="#77a837" padding="10px" border-right="10px solid #ffffff">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$gross_emissions &gt; 0">
				        			<xsl:value-of select="format-number($net_emissions, '0.00')"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				        		</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">Net total emissions CO2e</fo:block>
				    </fo:table-cell>
	        		<fo:table-cell background-color="#77a837" padding="10px" border-right="10px solid #ffffff">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$gross_emissions &gt; 0">
				        			<xsl:value-of select="format-number($net_emissions div $number_of_employees, '0.00')"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				        		</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">Net total emissions per employee CO2e</fo:block>
				    </fo:table-cell>
	        		<fo:table-cell background-color="#77a837" padding="10px">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$gross_emissions &gt; 0">
				        			<xsl:value-of select="format-number($net_emissions div $floor_area, '0.00')"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				       			</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">Net emissions per floor area CO2e</fo:block>
				    </fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>

		<div class="row padding-bottom-30">

			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$gross_emissions &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($net_emissions, '0.00')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Net total emissions CO<sub>2</sub>e</p>
	                    </div>
	                </div>
	            </div>
	        </div>
			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$gross_emissions &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($net_emissions div $number_of_employees, '0.00')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Net total emissions per employee CO<sub>2</sub>e</p>
	                    </div>
	                </div>
	            </div>
	        </div>
			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$gross_emissions &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($net_emissions div $floor_area, '0.00')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Net emissions per floor area CO<sub>2</sub>e</p>
	                    </div>
	                </div>
	            </div>
	        </div>
    	</div>

	</xsl:template>


	<xsl:template name="auslsa-report-carbon-mitigation-activities">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="green_tariff_electricity" select="sum($report/additionalValues/additionalValue[@key = 'Green Tariff Electricity']/@value)" />
		<xsl:variable name="gross_emissions" select="sum($report/additionalValues/additionalValue[@group = 'Emmission']/@value)" />
		<xsl:variable name="carbon_credits" select="sum($report/questionAnswer/answer[@answer_id = '33162']/@arbitrary_value)" />
		<xsl:variable name="total_offsetting" select="$carbon_credits + $green_tariff_electricity" />
		<xsl:variable name="net_emissions" select="$gross_emissions - $total_offsetting" />
		<xsl:variable name="number_of_employees" select="sum($report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value)" />
		<xsl:variable name="floor_area" select="sum($report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value)" />

		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th>
								Activity
							</th>
							<th width="20%" class="text-right">
								Tonnes CO2e
							</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>
								Green tariff electricity
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($green_tariff_electricity, '0.0000')" />
							</td>
						</tr>
						<tr>
							<td>
								Voluntary carbon offsetting
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="format-number($carbon_credits, '0.0000')" />
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div class="row padding-bottom-30">

			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$gross_emissions &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($net_emissions, '0.00')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Net total emissions CO<sub>2</sub>e</p>
	                    </div>
	                </div>
	            </div>
	        </div>
			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$gross_emissions &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($net_emissions div $number_of_employees, '0.00')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Net total emissions per employee CO<sub>2</sub>e</p>
	                    </div>
	                </div>
	            </div>
	        </div>
			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$gross_emissions &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($net_emissions div $floor_area, '0.00')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Net emissions per floor area CO<sub>2</sub>e</p>
	                    </div>
	                </div>
	            </div>
	        </div>
    	</div>

	</xsl:template>

	<xsl:template match="auslsa-report-paper-consumption" mode="html">
		<xsl:call-template name="auslsa-report-paper-consumption" />
	</xsl:template>

	<xsl:template match="auslsa-report-paper-consumption" mode="xhtml">
		<xsl:call-template name="auslsa-report-paper-consumption-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-paper-consumption-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<xsl:variable name="outsourced_paper_index" select="'100'" />

		<xsl:variable name="total_ream_consumption">
			<xsl:value-of select="sum($report/additionalValues/additionalValue[@key = 'GrossWeight'][@index != $outsourced_paper_index]/@value)" />
		</xsl:variable>
		<xsl:variable name="total_recycled_ream_consumption">
			<xsl:value-of select="sum($report/additionalValues/additionalValue[@key = 'RecycledWeight'][@index != $outsourced_paper_index]/@value)" />
		</xsl:variable>

		<xsl:variable name="total_impression_consumption">
			<xsl:value-of select="sum($report/additionalValues/additionalValue[@key = 'GrossWeight'][@index = $outsourced_paper_index]/@value)" />
		</xsl:variable>

		<xsl:variable name="total_recycled_paper_weight">
			<xsl:value-of select="sum($report/additionalValues/additionalValue[@group = 'Paper'][@key = 'RecycledWeight']/@value)" />
		</xsl:variable>

		<xsl:variable name="total_paper_weight" select="$total_ream_consumption + $total_impression_consumption" />
		<!--<xsl:variable name="reams_recycled" select="format-number(($total_recycled_paper_weight div $total_paper_weight)*100,'0.00')" />-->
		<xsl:variable name="reams_recycled" select="format-number(($total_recycled_ream_consumption div $total_ream_consumption)*100,'0.00')" />

		<xsl:variable name="number_of_employees" select="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value" />
		<xsl:variable name="floor_area" select="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value" />


		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="60%" />
			<fo:table-column column-width="40%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Type</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Paper Consumption (kg)</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Ream consumption</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$total_ream_consumption &gt; -1">
									<xsl:value-of select="format-number($total_ream_consumption, '#,##0.00')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Outsourced Printing</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$total_impression_consumption &gt; -1">
									<xsl:value-of select="format-number($total_impression_consumption, '#,##0.00')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>		
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Total paper consumption</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:choose>
								<xsl:when test="$total_paper_weight &gt; -1">
									<xsl:value-of select="format-number($total_paper_weight, '#,##0.00')" />
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>					
			</fo:table-body>
		</fo:table>

        <fo:table margin-bottom="20px">
        	<fo:table-body>
	        	<fo:table-row keep-together.within-page="always">
	        		<fo:table-cell background-color="#77a837" padding="10px" border-right="10px solid #ffffff">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$reams_recycled &gt; 0">
				        			<xsl:value-of select="format-number($reams_recycled, '0.00')"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				        		</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">% reams of paper recycled</fo:block>
				    </fo:table-cell>
	        		<fo:table-cell background-color="#77a837" padding="10px" border-right="10px solid #ffffff">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$total_paper_weight &gt; 0">
				        			<xsl:value-of select="format-number($total_paper_weight div $number_of_employees, '0.00')"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				        		</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">Total paper consumption per employee</fo:block>
				    </fo:table-cell>
	        		<fo:table-cell background-color="#77a837" padding="10px">
				        <fo:block font-size="30px" text-align="right" line-height="25px" color="#ffffff">
				        	<xsl:choose>
				        		<xsl:when test="$total_paper_weight &gt; 0">
				        			<xsl:value-of select="format-number($total_paper_weight div $floor_area, '0.00')"/>
				        		</xsl:when>
				        		<xsl:otherwise>0
				       			</xsl:otherwise>
				        	</xsl:choose>	                                    
				        </fo:block>
				        <fo:block text-align="right" color="#ffffff">Total paper consumption per floor area</fo:block>
				    </fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template name="auslsa-report-paper-consumption">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<xsl:variable name="outsourced_paper_index" select="'100'" />

		<xsl:variable name="total_ream_consumption">
			<xsl:value-of select="sum($report/additionalValues/additionalValue[@key = 'GrossWeight'][@index != $outsourced_paper_index]/@value)" />
		</xsl:variable>

		<xsl:variable name="total_recycled_ream_consumption">
			<xsl:value-of select="sum($report/additionalValues/additionalValue[@key = 'RecycledWeight'][@index != $outsourced_paper_index]/@value)" />
		</xsl:variable>

		<xsl:variable name="total_impression_consumption">
			<xsl:value-of select="sum($report/additionalValues/additionalValue[@key = 'GrossWeight'][@index = $outsourced_paper_index]/@value)" />
		</xsl:variable>

		<xsl:variable name="total_recycled_paper_weight">
			<xsl:value-of select="sum($report/additionalValues/additionalValue[@group = 'Paper'][@key = 'RecycledWeight']/@value)" />
		</xsl:variable>

		<xsl:variable name="total_paper_weight" select="$total_ream_consumption + $total_impression_consumption" />
		<!--<xsl:variable name="reams_recycled" select="($total_recycled_paper_weight div $total_paper_weight)*100" />-->
		<xsl:variable name="reams_recycled" select="($total_recycled_ream_consumption div $total_ream_consumption)*100" />

		<xsl:variable name="number_of_employees" select="$report/questionAnswer/answer[@answer_id = '33160']/@arbitrary_value" />
		<xsl:variable name="floor_area" select="$report/questionAnswer/answer[@answer_id = '33161']/@arbitrary_value" />

		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th>
								Type
							</th>
							<th width="20%" class="text-right">
								Paper Consumption (kg)
							</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>
								Ream consumption
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$total_ream_consumption &gt; -1">
										<xsl:value-of select="format-number($total_ream_consumption, '#,##0.00')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td>
								Outsourced Printing
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$total_impression_consumption &gt; -1">
										<xsl:value-of select="format-number($total_impression_consumption, '#,##0.00')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td>
								Total paper consumption
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$total_paper_weight &gt; -1">
										<xsl:value-of select="format-number($total_paper_weight, '#,##0.00')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div class="row padding-bottom-30">

			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$reams_recycled &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($reams_recycled, '0.00')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">% reams of paper recycled</p>
	                    </div>
	                </div>
	            </div>
	        </div>
			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$total_paper_weight &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($total_paper_weight div $number_of_employees, '0.00')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Total paper consumption per employee</p>
	                    </div>
	                </div>
	            </div>
	        </div>
			<div class="col-md-4">
				<div class="box-element base-alt">
	                <div class="row">
	                    <div class="col-md-12">
	                        <h1 class="pull-right large-callout">
	                        	<xsl:choose>
	                        		<xsl:when test="$total_paper_weight &gt; 0">
	                                    <span class="countto-timer" data-from="0" data-to="{format-number($total_paper_weight div $floor_area, '0.00')}" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:when>
	                        		<xsl:otherwise>
	                                    <span class="countto-timer" data-from="0" data-to="0" data-speed="2000" data-decimals="2"></span>
	                        		</xsl:otherwise>
	                        	</xsl:choose>	                                    
	                        </h1>
	                        <p class="pull-right clear large-callout">Total paper consumption per floor area</p>
	                    </div>
	                </div>
	            </div>
	        </div>
    	</div>

	</xsl:template>

	<xsl:template match="auslsa-report-purchased-electricity-consumption" mode="html">
		<xsl:call-template name="auslsa-report-purchased-electricity-consumption" />
	</xsl:template>

	<xsl:template match="auslsa-report-purchased-electricity-consumption" mode="xhtml">
		<xsl:call-template name="auslsa-report-purchased-electricity-consumption-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-purchased-electricity-consumption">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="electricity_type" select="$report/questionAnswer[@question_id = '13755']" />
		<xsl:variable name="electricity_state" select="$report/questionAnswer[@question_id = '13756']" />
		<xsl:variable name="electricity_consumption" select="$report/questionAnswer[@question_id = '13757']" />
		<xsl:variable name="electricity_unit" select="$report/questionAnswer[@question_id = '13758']" />

		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th width="40%">
								Electricity Type
							</th>
							<th width="30%" class="text-right">
								State
							</th>
							<th width="30%" class="text-right">
								Consumption (kWh)
							</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="$electricity_type/answer">
							<xsl:sort select="@index" data-type="number" />
							<xsl:variable name="index" select="@index" />
							<tr>
								<td width="40%">
									<xsl:value-of select="$electricity_type/answer[@index = $index]/@answer_string" />
								</td>
								<td width="30%" class="text-right">
									<xsl:value-of select="$electricity_state/answer[@index = $index]/@answer_string" />
								</td>
								<td width="30%" class="text-right">
									<xsl:value-of select="format-number($electricity_consumption/answer[@index = $index]/@arbitrary_value, '#,##0')" />
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="auslsa-report-purchased-electricity-consumption-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="electricity_type" select="$report/questionAnswer[@question_id = '13755']" />
		<xsl:variable name="electricity_state" select="$report/questionAnswer[@question_id = '13756']" />
		<xsl:variable name="electricity_consumption" select="$report/questionAnswer[@question_id = '13757']" />
		<xsl:variable name="electricity_unit" select="$report/questionAnswer[@question_id = '13758']" />

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="30%" />
			<fo:table-column column-width="30%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Electricity Type</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">State</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Consumption (kWh)</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<xsl:choose>
					<xsl:when test="count($electricity_type/answer) &gt; 0">
						<xsl:for-each select="$electricity_type/answer">
							<xsl:sort select="@index" data-type="number" />
							<xsl:variable name="index" select="@index" />
							<fo:table-row>
								<fo:table-cell>
									<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="$electricity_type/answer[@index = $index]/@answer_string" /></fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right">
									<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="$electricity_state/answer[@index = $index]/@answer_string" /></fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right">
									<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($electricity_consumption/answer[@index = $index]/@arbitrary_value, '#,##0')" /></fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<fo:table-row>
							<fo:table-cell number-columns-spanned="3">
								<fo:block padding="8px" border-top="1px solid #ddd">No data available.</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:otherwise>
				</xsl:choose>				
			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template match="auslsa-report-purchased-natural-gas-consumption" mode="html">
		<xsl:call-template name="auslsa-report-purchased-natural-gas-consumption" />
	</xsl:template>

	<xsl:template match="auslsa-report-purchased-natural-gas-consumption" mode="xhtml">
		<xsl:call-template name="auslsa-report-purchased-natural-gas-consumption-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-purchased-natural-gas-consumption">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="gas_state" select="$report/questionAnswer[@question_id = '13764']" />
		<xsl:variable name="gas_consumption" select="$report/questionAnswer[@question_id = '13765']" />
		<xsl:variable name="gas_unit" select="$report/questionAnswer[@question_id = '13766']" />

		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th width="40%">
								Gas Type
							</th>
							<th width="30%" class="text-right">
								State
							</th>
							<th width="30%" class="text-right">
								Consumption (MJ)
							</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="$gas_consumption/answer">
							<xsl:sort select="@index" data-type="number" />
							<xsl:variable name="index" select="@index" />
							<tr>
								<td width="40%">
									Natural Gas
								</td>
								<td width="30%" class="text-right">
									<xsl:value-of select="$gas_state/answer[@index = $index]/@answer_string" />
								</td>
								<td width="30%" class="text-right">
									<xsl:value-of select="format-number($gas_consumption/answer[@index = $index]/@arbitrary_value, '#,##0')" />
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="auslsa-report-purchased-natural-gas-consumption-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="gas_state" select="$report/questionAnswer[@question_id = '13764']" />
		<xsl:variable name="gas_consumption" select="$report/questionAnswer[@question_id = '13765']" />
		<xsl:variable name="gas_unit" select="$report/questionAnswer[@question_id = '13766']" />

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="30%" />
			<fo:table-column column-width="30%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Gas Type</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">State</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Consumption (MJ)</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<xsl:choose>
					<xsl:when test="count($gas_consumption/answer) > 0">
						<xsl:for-each select="$gas_consumption/answer">
							<xsl:sort select="@index" data-type="number" />
							<xsl:variable name="index" select="@index" />
							<fo:table-row>
								<fo:table-cell>
									<fo:block padding="8px" border-top="1px solid #ddd">Natural Gas</fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right">
									<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="$gas_state/answer[@index = $index]/@answer_string" /></fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right">
									<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($gas_consumption/answer[@index = $index]/@arbitrary_value, '#,##0.00')" /></fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<fo:table-row>
							<fo:table-cell>
								<fo:block padding="8px" border-top="1px solid #ddd">No data available.</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block padding="8px" border-top="1px solid #ddd"></fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block padding="8px" border-top="1px solid #ddd"></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:otherwise>
				</xsl:choose>
			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template match="auslsa-report-domestic-air-travel" mode="html">
		<xsl:call-template name="auslsa-report-domestic-air-travel" />
	</xsl:template>

	<xsl:template match="auslsa-report-domestic-air-travel" mode="xhtml">
		<xsl:call-template name="auslsa-report-domestic-air-travel-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-domestic-air-travel">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th width="40%">
								Seat Class
							</th>
							<th width="30%" class="text-right">
								Distance (km)
							</th>
							<th width="30%" class="text-right">
								Number of flights
							</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td width="40%">
								Economy
							</td>
							<td width="30%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13767']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13767']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="30%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13775']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13775']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td width="40%">
								Business
							</td>
							<td width="30%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13776']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13776']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="30%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13778']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13778']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="auslsa-report-domestic-air-travel-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="30%" />
			<fo:table-column column-width="30%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Seat Class</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Distance (km)</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Number of Flights</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Economy</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13767']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13767']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13775']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13775']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Business</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13776']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13776']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13778']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13778']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template match="auslsa-report-international-air-travel" mode="html">
		<xsl:call-template name="auslsa-report-international-air-travel" />
	</xsl:template>

	<xsl:template match="auslsa-report-international-air-travel" mode="xhtml">
		<xsl:call-template name="auslsa-report-international-air-travel-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-international-air-travel">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th width="40%">
								Seat Class
							</th>
							<th width="30%" class="text-right">
								Distance (km)
							</th>
							<th width="30%" class="text-right">
								Number of flights
							</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td width="40%">
								Economy
							</td>
							<td width="30%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13773']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13773']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="30%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13769']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13769']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td width="40%">
								Business
							</td>
							<td width="30%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13770']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13770']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="30%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13772']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13772']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td width="40%">
								First Class
							</td>
							<td width="30%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13807']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13807']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="30%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13809']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13809']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="auslsa-report-international-air-travel-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="30%" />
			<fo:table-column column-width="30%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Seat Class</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Distance (km)</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Number of Flights</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Economy</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13773']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13773']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13769']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13769']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Business</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13770']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13770']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13772']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13772']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">First Class</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13807']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13807']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13809']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13809']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template match="auslsa-report-car-travel" mode="html">
		<xsl:call-template name="auslsa-report-car-travel" />
	</xsl:template>

	<xsl:template match="auslsa-report-car-travel" mode="xhtml">
		<xsl:call-template name="auslsa-report-car-travel-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-car-travel">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th width="40%">
								Vehicle Type
							</th>
							<th width="20%" class="text-right">
								Number of journeys
							</th>
							<th width="20%" class="text-right">
								Distance (km)
							</th>
							<th width="20%" class="text-right">
								Spend (AUD)
							</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td width="40%">
								Taxi
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13781']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13781']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13779']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13779']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13791']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13791']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td width="40%">
								Hire Cars
							</td>
							<td width="20%" class="text-right">
								<xsl:text>N/A</xsl:text>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '14040']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '14040']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '14043']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '14043']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td width="40%">
								Company Cars
							</td>
							<td width="20%" class="text-right">
								<xsl:text>N/A</xsl:text>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '14048']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '14048']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '14050']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '14050']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td width="40%">
								Personal Cars
							</td>
							<td width="20%" class="text-right">
								<xsl:text>N/A</xsl:text>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '14055']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '14055']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '14057']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '14057']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>N/A</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="auslsa-report-car-travel-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="20%" />
			<fo:table-column column-width="20%" />
			<fo:table-column column-width="20%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Vehicle Type</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Number of journeys</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Distance (km)</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Spend (AUD)</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Taxi</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13781']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13781']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13779']">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13779']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13791']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13791']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Hire Cars</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '14040']">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '14040']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '14043']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '14043']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Company Cars</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '14048']">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '14048']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '14050']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '14050']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Personal Cars</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '14055']">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '14055']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '14057']/answer/@arbitrary_value &gt; -1">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '14057']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd">N/A</fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template match="auslsa-report-refrigerant-use-and-fridges" mode="html">
		<xsl:call-template name="auslsa-report-refrigerant-use-and-fridges" />
	</xsl:template>

	<xsl:template match="auslsa-report-refrigerant-use-and-fridges" mode="xhtml">
		<xsl:call-template name="auslsa-report-refrigerant-use-and-fridges-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-refrigerant-use-and-fridges">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th width="80%">
								Fridge Type
							</th>
							<th width="20%" class="text-right">
								Number of units
							</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td width="80%">
								<xsl:text>Bar Fridges/freezers</xsl:text>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13850']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13850']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td width="80%">
								<xsl:text>Standard Fridges/freezers</xsl:text>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13851']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13851']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td width="80%">
								<xsl:text>Commercial Fridges/freezers</xsl:text>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13852']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13852']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td width="80%">
								<xsl:text>Standalone Air Conditioning Units</xsl:text>
							</td>
							<td width="20%" class="text-right">
								<xsl:choose>
									<xsl:when test="$report/questionAnswer[@question_id = '13853']/answer/@arbitrary_value &gt; -1">
										<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13853']/answer/@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="auslsa-report-refrigerant-use-and-fridges-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="80%" />
			<fo:table-column column-width="20%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Fridge Type</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Number of Units</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Bar Fridges/freezers</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13850']/answer/@arbitrary_value != ''">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13850']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd"></fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Standard Fridges/freezers</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13851']/answer/@arbitrary_value != ''">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13851']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd"></fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Commercial Fridges/freezers</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13852']/answer/@arbitrary_value != ''">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13852']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd"></fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Standalone Air Conditioning Units</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<xsl:choose>
							<xsl:when test="$report/questionAnswer[@question_id = '13853']/answer/@arbitrary_value != ''">
								<fo:block padding="8px" border-top="1px solid #ddd"><xsl:value-of select="format-number($report/questionAnswer[@question_id = '13853']/answer/@arbitrary_value, '#,###')" /></fo:block>
							</xsl:when>
							<xsl:otherwise><fo:block padding="8px" border-top="1px solid #ddd"></fo:block></xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>

	</xsl:template>


	<xsl:template match="auslsa-report-paper-consumption-by-reams" mode="html">
		<xsl:call-template name="auslsa-report-paper-consumption-by-reams" />
	</xsl:template>

	<xsl:template match="auslsa-report-paper-consumption-by-reams" mode="xhtml">
		<xsl:call-template name="auslsa-report-paper-consumption-by-reams-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-paper-consumption-by-reams">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th width="20%">
								Paper size
							</th>
							<th width="20%" class="text-right">
								Paper weight (gsm)
							</th>
							<th width="20%" class="text-right">
								Paper purchased (reams)
							</th>
							<th width="20%" class="text-right">
								Green label
							</th>
							<th width="20%" class="text-right">
								% recycled content
							</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="$report/questionAnswer[@question_id = '13854']/answer">
							<xsl:sort select="@index" data-type="number" />
							<xsl:variable name="index" select="@index" />
							<tr>
								<td width="20%">
									<xsl:value-of select="$report/questionAnswer[@question_id = '13854']/answer[@index = $index]/@answer_string" />
								</td>
								<td width="20%" class="text-right">
									<xsl:choose>
										<xsl:when test="$report/questionAnswer[@question_id = '13855']/answer[@index = $index]/@arbitrary_value &gt; -1">
											<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13855']/answer[@index = $index]/@arbitrary_value, '#,###')" />
										</xsl:when>
										<xsl:otherwise>0</xsl:otherwise>
									</xsl:choose>
								</td>
								<td width="20%" class="text-right">
									<xsl:choose>
										<xsl:when test="$report/questionAnswer[@question_id = '13856']/answer[@index = $index]/@arbitrary_value &gt; -1">
											<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13856']/answer[@index = $index]/@arbitrary_value, '#,###')" />
										</xsl:when>
										<xsl:otherwise>0</xsl:otherwise>
									</xsl:choose>
								</td>
								<td width="20%" class="text-right">
									<xsl:value-of select="$report/questionAnswer[@question_id = '13857']/answer[@index = $index]/@answer_string" />
								</td>
								<td width="20%" class="text-right">
									<xsl:choose>
										<xsl:when test="$report/questionAnswer[@question_id = '13858']/answer[@index = $index]/@arbitrary_value &gt; -1">
											<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13858']/answer[@index = $index]/@arbitrary_value, '#,###')" />
										</xsl:when>
										<xsl:otherwise>0</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="auslsa-report-paper-consumption-by-reams-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="12%" />
			<fo:table-column column-width="20%" />
			<fo:table-column column-width="26%" />
			<fo:table-column column-width="20%" />
			<fo:table-column column-width="22%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Paper size</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Paper weight (gsm)</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Paper purchased (reams)</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Green label</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">% recycled content</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>

				<xsl:choose>
					<xsl:when test="count($report/questionAnswer[@question_id = '13860']/answer[@answer_id = '33290']) &gt; 0">
						<xsl:for-each select="$report/questionAnswer[@question_id = '13854']/answer">
							<xsl:sort select="@index" data-type="number" />
							<xsl:variable name="index" select="@index" />
							<fo:table-row>
								<fo:table-cell>
									<fo:block padding="8px" border-top="1px solid #ddd">
										<xsl:value-of select="$report/questionAnswer[@question_id = '13854']/answer[@index = $index]/@answer_string" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right">
									<xsl:choose>
										<xsl:when test="$report/questionAnswer[@question_id = '13855']/answer[@index = $index]/@arbitrary_value &gt; -1">
											<fo:block padding="8px" border-top="1px solid #ddd">
												<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13855']/answer[@index = $index]/@arbitrary_value, '#,###')" />
											</fo:block>
										</xsl:when>
										<xsl:otherwise>
											<fo:block padding="8px" border-top="1px solid #ddd">0</fo:block>
										</xsl:otherwise>
									</xsl:choose>
								</fo:table-cell>
								<fo:table-cell text-align="right">
									<xsl:choose>
										<xsl:when test="$report/questionAnswer[@question_id = '13856']/answer[@index = $index]/@arbitrary_value &gt; -1">
											<fo:block padding="8px" border-top="1px solid #ddd">
												<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13856']/answer[@index = $index]/@arbitrary_value, '#,###')" />
											</fo:block>
										</xsl:when>
										<xsl:otherwise>
											<fo:block padding="8px" border-top="1px solid #ddd">0</fo:block>
										</xsl:otherwise>
									</xsl:choose>
								</fo:table-cell>
								<fo:table-cell text-align="right">
									<fo:block padding="8px" border-top="1px solid #ddd">
										<xsl:value-of select="$report/questionAnswer[@question_id = '13857']/answer[@index = $index]/@answer_string" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right">
									<xsl:choose>
										<xsl:when test="$report/questionAnswer[@question_id = '13858']/answer[@index = $index]/@arbitrary_value &gt; -1">
											<fo:block padding="8px" border-top="1px solid #ddd">
												<xsl:value-of select="format-number($report/questionAnswer[@question_id = '13858']/answer[@index = $index]/@arbitrary_value, '#,###')" />
											</fo:block>
										</xsl:when>
										<xsl:otherwise>
											<fo:block padding="8px" border-top="1px solid #ddd">0</fo:block>
										</xsl:otherwise>
									</xsl:choose>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<fo:table-row>
							<fo:table-cell number-columns-spanned="5">
								<fo:block padding="8px" border-top="1px solid #ddd">No data available.</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:otherwise>
				</xsl:choose>

			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template match="auslsa-report-paper-consumption-by-number-of-impressions" mode="html">
		<xsl:call-template name="auslsa-report-paper-consumption-by-number-of-impressions" />
	</xsl:template>

	<xsl:template match="auslsa-report-paper-consumption-by-number-of-impressions" mode="xhtml">
		<xsl:call-template name="auslsa-report-paper-consumption-by-number-of-impressions-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-paper-consumption-by-number-of-impressions">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th width="50%">
								No of impressions (sheets)
							</th>
							<th width="50%">
								% of impressions that are printed double sided
							</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="$report/questionAnswer[@question_id = '24181']/answer">
							<xsl:sort select="@index" data-type="number" />
								<xsl:variable name="index" select="@index" />
								<tr>
									<td>
										<xsl:choose>
											<xsl:when test="$report/questionAnswer[@question_id = '24181']/answer[@index = $index]/@arbitrary_value &gt; -1">
												<xsl:value-of select="format-number($report/questionAnswer[@question_id = '24181']/answer[@index = $index]/@arbitrary_value, '###,###,###')" />
											</xsl:when>
											<xsl:otherwise>0</xsl:otherwise>
										</xsl:choose>
									</td>
									<td>
										<xsl:choose>
											<xsl:when test="$report/questionAnswer[@question_id = '24184']/answer[@index = $index]/@arbitrary_value &gt; -1">
												<xsl:value-of select="format-number($report/questionAnswer[@question_id = '24184']/answer[@index = $index]/@arbitrary_value, '###')" />
											</xsl:when>
											<xsl:otherwise>0</xsl:otherwise>
										</xsl:choose>
									</td>
								</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="auslsa-report-paper-consumption-by-number-of-impressions-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="50%" />
			<fo:table-column column-width="50%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">No of impressions (sheets)</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">% of impressions that are printed double sided</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>

			<xsl:choose>
				<xsl:when test="count($report/questionAnswer[@question_id = '24181']) &gt; 0">
					<xsl:for-each select="$report/questionAnswer[@question_id = '24181']/answer">
						<xsl:sort select="@index" data-type="number" />
							<xsl:variable name="index" select="@index" />
							<fo:table-row>
								<fo:table-cell>
									<xsl:choose>
										<xsl:when test="$report/questionAnswer[@question_id = '24181']/answer[@index = $index]/@arbitrary_value &gt; -1">
											<fo:block padding="8px" border-top="1px solid #ddd">
												<xsl:value-of select="format-number($report/questionAnswer[@question_id = '24181']/answer[@index = $index]/@arbitrary_value, '###,###,###')" />
											</fo:block>
										</xsl:when>
										<xsl:otherwise>
											<fo:block padding="8px" border-top="1px solid #ddd">0</fo:block>
										</xsl:otherwise>
									</xsl:choose>
								</fo:table-cell>
								<fo:table-cell>
									<xsl:choose>
										<xsl:when test="$report/questionAnswer[@question_id = '24184']/answer[@index = $index]/@arbitrary_value &gt; -1">
											<fo:block padding="8px" border-top="1px solid #ddd">
												<xsl:value-of select="format-number($report/questionAnswer[@question_id = '24184']/answer[@index = $index]/@arbitrary_value, '###')" />
											</fo:block>
										</xsl:when>
										<xsl:otherwise>
											<fo:block padding="8px" border-top="1px solid #ddd">0</fo:block>
										</xsl:otherwise>
									</xsl:choose>
								</fo:table-cell>
							</fo:table-row>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<fo:table-row>
						<fo:table-cell>
							<fo:block padding="8px" border-top="1px solid #ddd">No data available.</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block padding="8px" border-top="1px solid #ddd"></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:otherwise>
			</xsl:choose>
			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template match="auslsa-report-waste-facilities" mode="html">
		<xsl:call-template name="auslsa-report-waste-facilities" />
	</xsl:template>

	<xsl:template match="auslsa-report-waste-facilities" mode="xhtml">
		<xsl:call-template name="auslsa-report-waste-facilities-pdf" />
	</xsl:template>

	<xsl:template name="auslsa-report-waste-facilities">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<div class="row">
			<div class="col-md-12">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th width="60%">
								Waste type
							</th>
							<th width="20%" class="text-right">
								Facilities available
							</th>
							<th width="20%" class="text-right">
								No of sites where available
							</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td width="60%">
								<xsl:text>Paper &amp; cardboard recycling</xsl:text>
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="$report/questionAnswer[@question_id = '13864']/answer/@answer_string" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="$report/questionAnswer[@question_id = '13865']/answer/@arbitrary_value" />
							</td>
						</tr>

						<tr>
							<td width="60%">
								<xsl:text>Comingles recyclng</xsl:text>
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="$report/questionAnswer[@question_id = '13867']/answer/@answer_string" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="$report/questionAnswer[@question_id = '13868']/answer/@arbitrary_value" />
							</td>
						</tr>

						<tr>
							<td width="60%">
								<xsl:text>Organic waste treatment/recycling</xsl:text>
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="$report/questionAnswer[@question_id = '13876']/answer/@answer_string" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="$report/questionAnswer[@question_id = '13877']/answer/@arbitrary_value" />
							</td>
						</tr>

						<tr>
							<td width="60%">
								<xsl:text>e-Waste reuse or recycling</xsl:text>
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="$report/questionAnswer[@question_id = '13879']/answer/@answer_string" />
							</td>
							<td width="20%" class="text-right">
								<xsl:value-of select="$report/questionAnswer[@question_id = '13880']/answer/@arbitrary_value" />
							</td>
						</tr>

					</tbody>
				</table>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="auslsa-report-waste-facilities-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="30%" />
			<fo:table-column column-width="30%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Waste type</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Facilities available</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">No of sites where available</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>

				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Paper &amp; cardboard recycling</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="$report/questionAnswer[@question_id = '13864']/answer/@answer_string" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="$report/questionAnswer[@question_id = '13865']/answer/@arbitrary_value" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>

				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Comingles recycling</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="$report/questionAnswer[@question_id = '13867']/answer/@answer_string" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="$report/questionAnswer[@question_id = '13868']/answer/@arbitrary_value" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>

				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">Organic waste treatment/recycling</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="$report/questionAnswer[@question_id = '13876']/answer/@answer_string" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="$report/questionAnswer[@question_id = '13877']/answer/@arbitrary_value" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>

				<fo:table-row>
					<fo:table-cell>
						<fo:block padding="8px" border-top="1px solid #ddd">e-Waste reuse or recycling</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="$report/questionAnswer[@question_id = '13879']/answer/@answer_string" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block padding="8px" border-top="1px solid #ddd">
							<xsl:value-of select="$report/questionAnswer[@question_id = '13880']/answer/@arbitrary_value" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>

			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template match="auslsa-report-questions-answers" mode="html">
		<xsl:call-template name="auslsa-report-questions-answers">
			<xsl:with-param name="page_id" select="@page_id" />
			<xsl:with-param name="title" select="@title" />
		</xsl:call-template>
	</xsl:template>

	<!--//PDF -->
	<xsl:template match="auslsa-report-questions-answers" mode="xhtml">
		<xsl:call-template name="auslsa-report-questions-answers-pdf">
			<xsl:with-param name="page_id" select="@page_id" />
			<xsl:with-param name="title" select="@title" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="auslsa-report-questions-answers">
		<xsl:param name="page_id" select="@page_id" />
		<xsl:param name="title" select="@title" />

		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<xsl:if test="$title != ''">
			<h4 class="text-light">
				<xsl:value-of select="$title" />
			</h4>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="count($report/questionAnswer[@page_id = $page_id]) &gt; 0">
				<table class="table table-responsive table-hover">
					<thead>
						<tr>
							<th width="70%">Question</th>
							<th width="30%">Answer</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="$report/questionAnswer[@page_id = $page_id]">
							<xsl:sort select="@sequence" data-type="number" />

							<tr>
								<td>
									<xsl:value-of select="@question" />
								</td>
								<td>
									<xsl:for-each select="answer">
										<xsl:choose>
											<xsl:when test="@answer_type = 'percent'">
												<xsl:value-of select="concat(@arbitrary_value, '%')" />
											</xsl:when>
											<xsl:when test="@answer_type = 'range'">
												<xsl:value-of select="concat(@arbitrary_value, @range_unit)" />
											</xsl:when>
											<xsl:when test="@answer_type = 'checkbox-other'">
												<xsl:value-of select="concat(@answer_string, ': ', @arbitrary_value)" />
											</xsl:when>
											<xsl:when test="@answer_string != ''">
												<xsl:value-of select="@answer_string" />
											</xsl:when>
											<xsl:when test="@answer_type = 'file-upload' and @hash != ''">
												<a class="default-link" href="https://www.greenbizcheck.com/download/?hash={@hash}">
													<xsl:value-of select="concat(@name,' (',@readable_size,')')" />
												</a>
											</xsl:when>
											<xsl:otherwise>
												<span class="output pre-wrap">
													<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
												</span>
											</xsl:otherwise>
										</xsl:choose>
										<br />
									</xsl:for-each>
								</td>
							</tr>

						</xsl:for-each>

						<!-- //Notes Field -->
						<tr>
							<td>
								<xsl:value-of select="$report/checklistPage[@page_id = $page_id]/@notes_field_title" />
							</td>
							<td>
								<xsl:value-of select="$report/checklistPage[@page_id = $page_id]/@note" />
							</td>
						</tr>

					</tbody>
				</table>
			</xsl:when>
			<xsl:otherwise>
				<p>No data available.</p>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="auslsa-report-questions-answers-pdf">
		<xsl:param name="page_id" select="@page_id" />
		<xsl:param name="title" select="@title" />

		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:if test="$title != ''">
			<fo:block>
				<xsl:value-of select="$title" />
			</fo:block>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="count($report/questionAnswer[@page_id = $page_id]) &gt; 0">
				<fo:table margin="4px" margin-bottom="20px">
					<fo:table-column column-width="70%" />
					<fo:table-column column-width="30%" />
					<fo:table-header>
						<fo:table-row>
							<fo:table-cell>
								<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Question</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Answer</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-header>
					<fo:table-body>
						<xsl:for-each select="$report/questionAnswer[@page_id = $page_id]">
							<xsl:sort select="@sequence" data-type="number" />

							<fo:table-row>
								<fo:table-cell>
									<fo:block padding="8px" border-top="1px solid #ddd">
										<xsl:value-of select="@question" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block padding="8px" border-top="1px solid #ddd">
										<xsl:for-each select="answer">
											<fo:block linefeed-treatment="preserve">
												<xsl:choose>
													<xsl:when test="@answer_type = 'percent'">
														<xsl:value-of select="concat(@arbitrary_value, '%')" />
													</xsl:when>
													<xsl:when test="@answer_type = 'range'">
														<xsl:value-of select="concat(@arbitrary_value, @range_unit)" />
													</xsl:when>
													<xsl:when test="@answer_type = 'checkbox-other'">
														<xsl:value-of select="concat(@answer_string, ': ', @arbitrary_value)" />
													</xsl:when>
													<xsl:when test="@answer_string != ''">
														<xsl:value-of select="@answer_string" />
													</xsl:when>
													<xsl:when test="@answer_type = 'file-upload' and @hash != ''">
														<fo:basic-link color="blue" external-destination="https://www.greenbizcheck.com/download/?hash={@hash}">
															<xsl:value-of select="concat(@name,' (',@readable_size,')')" />
														</fo:basic-link>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="@arbitrary_value" />
													</xsl:otherwise>
												</xsl:choose>
											</fo:block>
										</xsl:for-each>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>

						</xsl:for-each>

						<!-- //Notes Field -->
						<fo:table-row>
							<fo:table-cell>
								<fo:block padding="8px" border-top="1px solid #ddd">
									<xsl:value-of select="$report/checklistPage[@page_id = $page_id]/@notes_field_title" />
								</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block padding="8px" border-top="1px solid #ddd">
									<xsl:value-of select="$report/checklistPage[@page_id = $page_id]/@note" />
								</fo:block>
							</fo:table-cell>
						</fo:table-row>

					</fo:table-body>
				</fo:table>
			</xsl:when>
			<xsl:otherwise>
				<fo:block>No data available.</fo:block>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<!-- //2017 Report -->
	<!-- //Our Firm -->
	<xsl:template match="auslsa-our-firm" mode="html">

		<!-- //Header -->
		<xsl:call-template name="report-header" type="component">
			<xsl:with-param name="company_name" select="$report/@company_name" />
			<xsl:with-param name="year" select="$report/@date_range_finish_year" />
			<xsl:with-param name="company_logo" select="''" />
		</xsl:call-template>

		<!-- //Header -->
		<xsl:call-template name="section-header" type="component">
			<xsl:with-param name="title" select="'Our Firm'" />
		</xsl:call-template>

		<!-- //Page -->
		<xsl:call-template name="section-page" type="component">
			<xsl:with-param name="title" select="'About Our Firm'" />
		</xsl:call-template>

		<!-- //About -->
		<xsl:call-template name="section-textarea" type="component">
			<xsl:with-param name="content" select="$report/questionAnswer[@question_id = '13753']/answer/@arbitrary_value" />
		</xsl:call-template>

		<!-- //Firm Details -->
		<xsl:call-template name="section-page" type="component">
			<xsl:with-param name="title" select="'Firm Details'" />
		</xsl:call-template>

		<!--//Answer Grid Header -->
		<xsl:call-template name="section-grid-header" type="component" />

		<!-- //Name of Firm -->
		<xsl:call-template name="section-grid-question">
			<xsl:with-param name="question_id" select="'13746'" />
		</xsl:call-template>

		<!-- //Number of Employees -->
		<xsl:call-template name="section-grid-question">
			<xsl:with-param name="question_id" select="'13750'" />
		</xsl:call-template>

		<!-- //Floor Area -->
		<xsl:call-template name="section-grid-question">
			<xsl:with-param name="question_id" select="'13751'" />
		</xsl:call-template>

		<!-- //Number of Offices -->
		<xsl:call-template name="section-grid-question">
			<xsl:with-param name="question_id" select="'13964'" />
		</xsl:call-template>

		<!-- //File Upload -->
		<xsl:call-template name="section-grid-question">
			<xsl:with-param name="question_id" select="'14089'" />
		</xsl:call-template>

		<!--//Answer Grid Footer -->
		<xsl:call-template name="section-grid-footer" type="component" />

		<!-- //Intro -->
		<xsl:call-template name="section-inline" type="component">
			<xsl:with-param name="title" select="'Person responsible for reporting'" />
		</xsl:call-template>

		<!-- //Name -->
		<xsl:call-template name="section-inline" type="component">
			<xsl:with-param name="title" select="'Name:'" />
			<xsl:with-param name="content" select="concat($report/questionAnswer[@question_id = '13747']/answer/@arbitrary_value, ' ', $report/questionAnswer[@question_id = '13748']/answer/@arbitrary_value)" />
		</xsl:call-template>

		<!-- //Position -->
		<xsl:call-template name="section-inline" type="component">
			<xsl:with-param name="title" select="'Title:'" />
			<xsl:with-param name="content" select="$report/questionAnswer[@question_id = '13881']/answer/@arbitrary_value" />
		</xsl:call-template>

		<!-- //Email -->
		<xsl:call-template name="section-inline" type="component">
			<xsl:with-param name="title" select="'Email:'" />
			<xsl:with-param name="content" select="$report/questionAnswer[@question_id = '13749']/answer/@arbitrary_value" />
		</xsl:call-template>

		<!-- //Notes -->
		<xsl:call-template name="section-textarea" type="component">
			<xsl:with-param name="title" select="'User comments and notes'" />
			<xsl:with-param name="content" select="$report/checklistPage[@page_id = '2575']/@note" />
			<xsl:with-param name="answer-type" select="'comment'" />
		</xsl:call-template>

	</xsl:template>

	<xsl:template match="auslsa-environment" mode="html">

		<!-- //Header -->
		<xsl:call-template name="section-header" type="component">
			<xsl:with-param name="title" select="'Environment'" />
		</xsl:call-template>

		<!-- Page -->
		<xsl:call-template name="auslsa-page-template">
			<xsl:with-param name="page" select="$report/checklistPage[@page_id = '2596']" />
		</xsl:call-template>
	</xsl:template>

	<!-- //Generic Template -->
	<xsl:template match="auslsa-section-template" mode="html">
		<xsl:variable name="page_section_id" select="@page_section_id" />

		<!-- //Header -->
		<xsl:call-template name="section-header" type="component">
			<xsl:with-param name="title" select="$report/checklistPageSection[@page_section_id = $page_section_id]/@title" />
		</xsl:call-template>

		<!-- //Each Page -->
		<xsl:for-each select="$report/checklistPage[@page_section_id = $page_section_id]">
			<xsl:sort select="@sequence" data-type="number" />

			<xsl:call-template name="auslsa-page-template">
				<xsl:with-param name="page" select="." />
				<xsl:with-param name="checklist-page-position" select="position()" />
			</xsl:call-template>
		</xsl:for-each>

	</xsl:template>

	<xsl:template name="auslsa-page-template">
		<xsl:param name="page" />
		<xsl:param name="checklist-page-position" select="1" />

		<!-- //Page -->
		<xsl:call-template name="section-page" type="component">
			<xsl:with-param name="title" select="$page/@title" />
		</xsl:call-template>

		<!-- //About -->
		<xsl:if test="$checklist-page-position = 1">
			<xsl:call-template name="section-textarea" type="component">
				<xsl:with-param name="content" select="$report/questionAnswer[@page_id = $page/@page_id][@sequence = '1']/answer[@answer_type = 'textarea']/@arbitrary_value" />
			</xsl:call-template>
		</xsl:if>

		<!--//Answer Grid Header -->
		<xsl:call-template name="section-grid-header" type="component" />

		<!-- //Questions -->
		<xsl:choose>
			<xsl:when test="count($report/questionAnswer[@page_id = $page/@page_id]) &gt; 0">
				<xsl:for-each select="$report/questionAnswer[@page_id = $page/@page_id]">
					<xsl:sort select="sequence" data-type="number" />

					<xsl:if test="@sequence != '1' or (@sequence = '1' and answer/@answer_type != 'textarea')">
						<xsl:call-template name="section-grid-question">
							<xsl:with-param name="question_id" select="@question_id" />
						</xsl:call-template>
					</xsl:if>

				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<div class="row section-grid-question">
					<div class="col-md-12 cell text-center">
						No responses provided.
					</div>
				</div>			
			</xsl:otherwise>
		</xsl:choose>

		<!--//Answer Grid Footer -->
		<xsl:call-template name="section-grid-footer" type="component" />

		<!-- //Notes -->
		<xsl:call-template name="section-textarea" type="component">
			<xsl:with-param name="title" select="'User comments and notes'" />
			<xsl:with-param name="content" select="$report/checklistPage[@page_id = $page/@page_id]/@note" />
			<xsl:with-param name="answer-type" select="'comment'" />
		</xsl:call-template>

	</xsl:template>

	<xsl:template name="report-header" type="component">
		<xsl:param name="company_name" />
		<xsl:param name="year" />
		<xsl:param name="company_logo" />

		<div class="row report-header">
			<div class="col-md-4"></div>
			<div class="col-md-4 logo text-center">
				<xsl:if test="$company_logo != ''">
					<img src="{$company_logo}" class="img-responsive" />
				</xsl:if>
			</div>
			<div class="col-md-4"></div>
		</div>

		<div class="row report-header">
			<div class="col-md-8 company">
				<xsl:value-of select="$company_name" />
			</div>
			<div class="col-md-4 year">
				<div class="pull-right">
					<xsl:value-of select="$year" />
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="section-header" type="component">
		<xsl:param name="title" />

		<div class="row section-header">
			<div class="col-md-12 title">
				<xsl:value-of select="$title" />
			</div>
		</div>
	</xsl:template>

	<xsl:template name="section-textarea" type="component">
		<xsl:param name="title" />
		<xsl:param name="content" />
		<xsl:param name="answer-type" />
		<xsl:param name="url" />

		<div class="row section-textarea">
			<div class="col-md-12 title">
				<xsl:value-of select="$title" />
			</div>
		</div>
		<div class="row section-textarea">
			<div class="col-md-12 content">
				<xsl:choose>
					<xsl:when test="$answer-type = 'file' and $url != ''">
						<a href="{$url}">
							<xsl:value-of select="$content" />
						</a>
					</xsl:when>
					<xsl:when test="count($content) = 0 or $content = ''">
						Nil
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$content" />
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="section-inline" type="component">
		<xsl:param name="title" />
		<xsl:param name="content" />

		<div class="row section-inline">
			<div class="col-md-12">
				<div class="title">
					<xsl:value-of select="$title" />
				</div>
				<div class="content">
					<xsl:value-of select="$content" />
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="section-page" type="component">
		<xsl:param name="title" />

		<div class="row section-page">
			<div class="col-md-12 title">
				<xsl:value-of select="$title" />
			</div>
		</div>
	</xsl:template>

	<xsl:template name="section-grid-header">
		<div class="row section-grid-header">
			<div class="col-md-3 cell">Question</div>
			<div class="col-md-3 cell">
				<xsl:choose>
					<xsl:when test="$report/@date_range_finish_year != ''">
						<xsl:value-of select="$report/@date_range_finish_year - 1" /> Response
					</xsl:when>
					<xsl:otherwise>
						Previous Response
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="col-md-3 cell">
				<xsl:choose>
					<xsl:when test="$report/@date_range_finish_year != ''">
						<xsl:value-of select="$report/@date_range_finish_year" /> Response
					</xsl:when>
					<xsl:otherwise>
						Response
					</xsl:otherwise>
				</xsl:choose>			
			</div>
			<div class="col-md-3 cell">
				<xsl:choose>
					<xsl:when test="$report/@date_range_finish_year != ''">
						<xsl:value-of select="$report/@date_range_finish_year - 1" /> Benchmark
					</xsl:when>
					<xsl:otherwise>
						Benchmark
					</xsl:otherwise>
				</xsl:choose>			
			</div>
		</div>
	</xsl:template>

	<xsl:template name="section-grid-footer" type="component">
		<div class="section-grid-footer" />
	</xsl:template>

	<xsl:template name="section-grid-question">
		<xsl:param name="question_id" />
		<xsl:param name="question" />
		<xsl:param name="previousResponse" />
		<xsl:param name="currentResponse" />

		<xsl:variable name="currentYear" select="$report/@date_range_finish_year" />
		<xsl:variable name="previousYear" select="$report/@date_range_finish_year - 1" />

		<div class="row section-grid-question">
			<div class="col-md-3 cell">
				<xsl:choose>
					<xsl:when test="$report/questionAnswer[@question_id = $question_id]/answer/@answer_type = 'file-upload'">
						Supporting files uploaded
					</xsl:when>
					<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'file-upload'">
						Supporting files uploaded
					</xsl:when>
					<xsl:when test="$report/questionAnswer[@question_id = $question_id]/@export_key != ''">
						<a href="#" class="question-help-trigger" data-toggle="modal" data-target="#question-help-{$question_id}" rel="tooltip" data-original-title="Click for more information">
							<xsl:value-of select="$report/questionAnswer[@question_id = $question_id]/@export_key" />
						</a>
						<xsl:call-template name="section-question-help">
							<xsl:with-param name="question" select="$report/questionAnswer[@question_id = $question_id]" />
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$report/questionAnswer[@question_id = $question_id]/@question != ''">
						<xsl:value-of select="$report/questionAnswer[@question_id = $question_id]/@question" />
					</xsl:when>
					<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@export_key != ''">
						<xsl:value-of select="$report/benchmarks/answer[@question_id = $question_id]/@export_key" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$report/questionAnswer[@question_id = $question_id]/@question" />
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="col-md-3 cell">
				<xsl:choose>
					<xsl:when test="count($report/previousClientChecklists/clientChecklist[@year = ($report/@date_range_finish_year - 1)]/clientResult[@question_id = $question_id]) &gt; 0">
						<xsl:for-each select="$report/previousClientChecklists/clientChecklist[@year = ($report/@date_range_finish_year - 1)]/clientResult[@question_id = $question_id]">
							<xsl:sort select="@sequence" data-type="number" />
							<div class="answer">
								<xsl:choose>
									<xsl:when test="@answer_type = 'file-upload'">
										<xsl:choose>
											<xsl:when test="@name != ''">
												<a href="{concat('https://www.greenbizcheck.com/download/?hash=',@hash)}">
													<xsl:value-of select="concat(@name, ' (', @readable_size, ')')" />
												</a>
											</xsl:when>
											<xsl:otherwise>
												Nil
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="@answer_type = 'float' or @answer_type = 'int'">
										<xsl:value-of select="format-number(@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:when test="@answer_type = 'checkbox' or @answer_type = 'drop-down-list'">
										<xsl:value-of select="@string" />
									</xsl:when>
									<xsl:when test="@answer_type = 'range'">
										<xsl:value-of select="concat(@arbitrary_value, @range_unit)" />
									</xsl:when>
									<xsl:when test="@answer_type = 'percent'">
										<xsl:value-of select="concat(@arbitrary_value, '%')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@arbitrary_value" />
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						N/A
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="col-md-3 cell">
				<xsl:for-each select="$report/questionAnswer[@question_id = $question_id]/answer">
					<xsl:sort select="@answer_sequence" data-type="number" />
					<div class="answer">
						<xsl:choose>
							<xsl:when test="@answer_type = 'file-upload'">
								<xsl:choose>
									<xsl:when test="@name != ''">
										<a href="{concat('https://www.greenbizcheck.com/download/?hash=',@hash)}">
											<xsl:value-of select="concat(@name, ' (', @readable_size, ')')" />
										</a>
									</xsl:when>
									<xsl:otherwise>
										Nil
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="@answer_type = 'float' or @answer_type = 'int'">
								<xsl:value-of select="format-number(@arbitrary_value, '#,###')" />
							</xsl:when>
							<xsl:when test="@answer_type = 'checkbox' or @answer_type = 'drop-down-list'">
								<xsl:value-of select="@answer_string" />
							</xsl:when>
							<xsl:when test="@answer_type = 'range'">
								<xsl:value-of select="concat(@arbitrary_value, @range_unit)" />
							</xsl:when>
							<xsl:when test="@answer_type = 'percent'">
								<xsl:value-of select="concat(@arbitrary_value, '%')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@arbitrary_value" />
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</xsl:for-each>
			</div>
			<div class="col-md-3 cell">
				<xsl:choose>

					<!-- //Number (int, float, percent, range) -->
					<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'int' or $report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'float' or $report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'range'  or $report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'percent'">
						<div class="row benchmark">
							<div class="col-xs-6">Lowest:</div>
							<div class="col-xs-6 text-right">
								<xsl:value-of select="format-number($report/benchmarks/answer[@question_id = $question_id]/result[@year = $previousYear]/@min, '#,###')" />
								<xsl:choose>
									<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'range'">
										<xsl:value-of select="$report/benchmarks/answer[@question_id = $question_id]/@range_unit" />
									</xsl:when>
									<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'percent'">
										%
									</xsl:when>
								</xsl:choose>
							</div>
						</div>
						<div class="row benchmark">
							<div class="col-xs-6">Highest:</div>
							<div class="col-xs-6 text-right">
								<xsl:value-of select="format-number($report/benchmarks/answer[@question_id = $question_id]/result[@year = $previousYear]/@max, '#,###')" />
								<xsl:choose>
									<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'range'">
										<xsl:value-of select="$report/benchmarks/answer[@question_id = $question_id]/@range_unit" />
									</xsl:when>
									<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'percent'">
										%
									</xsl:when>
								</xsl:choose>
							</div>
						</div>
						<div class="row benchmark">
							<div class="col-xs-6">Average:</div>
							<div class="col-xs-6 text-right">
								<xsl:value-of select="format-number($report/benchmarks/answer[@question_id = $question_id]/result[@year = $previousYear]/@avg, '#,###')" />
								<xsl:choose>
									<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'range'">
										<xsl:value-of select="$report/benchmarks/answer[@question_id = $question_id]/@range_unit" />
									</xsl:when>
									<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'percent'">
										%
									</xsl:when>
								</xsl:choose>
							</div>
						</div>
					</xsl:when>

					<!-- //Answer String (Checkbox, Checkbox-other, Drop Down List -->
					<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'checkbox' or $report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'checkbox-other' or $report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'drop-down-list'">
						<xsl:variable name="total" select="sum($report/benchmarks/answer[@question_id = $question_id]/result[@year = $previousYear]/@count)" />
						<xsl:for-each select="$report/benchmarks/answer[@question_id = $question_id and $question_id != '14394']">
							<xsl:sort select="@sequence" data-type="number" />
							<div class="row benchmark">
								<div class="col-xs-10">
									<xsl:value-of select="@answer_string" />
								</div>
								<div class="col-xs-2 text-right">
									<xsl:choose>
										<xsl:when test="$total &gt; 0">
											<xsl:choose>
												<xsl:when test="result[@year = $previousYear]/@count &gt; 0">
													<xsl:choose>
														<xsl:when test="result[@year = $previousYear]/@multiple_answer = 1">
															<xsl:value-of select="round((result[@year = $previousYear]/@count div result[@year = $previousYear]/@respondents)*100)" />%
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="round((result[@year = $previousYear]/@count div $total)*100)" />%
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:otherwise>
													0%
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											N/A
										</xsl:otherwise>
									</xsl:choose>
								</div>
							</div>
						</xsl:for-each>
					</xsl:when>

				</xsl:choose>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="section-question-help">
		<xsl:param name="question" />

		<div class="modal fade question-help" tabindex="-1" role="dialog" id="question-help-{$question/@question_id}">
			<div class="modal-dialog" role="document">
				<div class="modal-content">
					<div class="modal-body">
						<p class="title">Question</p>
						<p><xsl:value-of select="$question/@question" /></p>
						<p class="title">Information</p>
						<p>
							<xsl:choose>
								<xsl:when test="$question/@tip != ''">
									<xsl:value-of select="$question/@tip" disable-output-escaping="yes" />
								</xsl:when>
								<xsl:otherwise>
									No further information is available.
								</xsl:otherwise>
							</xsl:choose>
						</p>
						<xsl:if test="$question/@show_in_analytics = '1'">
							<p class="title">Analytics</p>
							<p>Further information on this question can be found in the <a href="/members/analytics/?checklist_id={$report/@checklist_id}&amp;question_id={$question/@question_id}" target="_blank">analytics tool</a>.</p>
						</xsl:if>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>

	</xsl:template>

	<!-- // 2017 Report PDF -->
	<!-- //Our Firm -->
	<xsl:template match="auslsa-our-firm" mode="xhtml">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<!-- //Header -->
		<xsl:call-template name="report-header-pdf" type="component">
			<xsl:with-param name="company_name" select="$report/@company_name" />
			<xsl:with-param name="year" select="$report/@date_range_finish_year" />
			<xsl:with-param name="company_logo" select="''" />
		</xsl:call-template>

		<!-- //Page -->
		<xsl:call-template name="section-page-pdf" type="component">
			<xsl:with-param name="title" select="'About Our Firm'" />
		</xsl:call-template>

		<!-- //About -->
		<xsl:call-template name="section-textarea-pdf" type="component">
			<xsl:with-param name="content" select="$report/questionAnswer[@question_id = '13753']/answer/@arbitrary_value" />
		</xsl:call-template>

		<!-- //Firm Details -->
		<xsl:call-template name="section-page-pdf" type="component">
			<xsl:with-param name="title" select="'Firm Details'" />
		</xsl:call-template>

		<!--//Answer Grid Header -->
		<xsl:call-template name="section-grid-header-pdf" type="component" />

		<!-- //Name of Firm -->
		<xsl:call-template name="section-grid-question-pdf">
			<xsl:with-param name="question_id" select="'13746'" />
		</xsl:call-template>

		<!-- //Number of Employees -->
		<xsl:call-template name="section-grid-question-pdf">
			<xsl:with-param name="question_id" select="'13750'" />
		</xsl:call-template>

		<!-- //Floor Area -->
		<xsl:call-template name="section-grid-question-pdf">
			<xsl:with-param name="question_id" select="'13751'" />
		</xsl:call-template>

		<!-- //Number of Offices -->
		<xsl:call-template name="section-grid-question-pdf">
			<xsl:with-param name="question_id" select="'13964'" />
		</xsl:call-template>

		<!-- //File Upload -->
		<xsl:call-template name="section-grid-question-pdf">
			<xsl:with-param name="question_id" select="'14089'" />
		</xsl:call-template>

		<!--//Answer Grid Footer -->
		<xsl:call-template name="section-grid-footer-pdf" type="component" />

		<!-- //Intro -->
		<xsl:call-template name="section-inline-pdf" type="component">
			<xsl:with-param name="title" select="'Person responsible for reporting'" />
		</xsl:call-template>

		<!-- //Name -->
		<xsl:call-template name="section-inline-pdf" type="component">
			<xsl:with-param name="title" select="'Name:'" />
			<xsl:with-param name="content" select="concat($report/questionAnswer[@question_id = '13747']/answer/@arbitrary_value, ' ', $report/questionAnswer[@question_id = '13748']/answer/@arbitrary_value)" />
		</xsl:call-template>

		<!-- //Position -->
		<xsl:call-template name="section-inline-pdf" type="component">
			<xsl:with-param name="title" select="'Title:'" />
			<xsl:with-param name="content" select="$report/questionAnswer[@question_id = '13881']/answer/@arbitrary_value" />
		</xsl:call-template>

		<!-- //Email -->
		<xsl:call-template name="section-inline-pdf" type="component">
			<xsl:with-param name="title" select="'Email:'" />
			<xsl:with-param name="content" select="$report/questionAnswer[@question_id = '13749']/answer/@arbitrary_value" />
		</xsl:call-template>

		<!-- //Notes -->
		<xsl:call-template name="section-textarea-pdf" type="component">
			<xsl:with-param name="title" select="'User comments and notes'" />
			<xsl:with-param name="content" select="$report/checklistPage[@page_id = '2575']/@note" />
			<xsl:with-param name="answer-type" select="'comment'" />
		</xsl:call-template>

	</xsl:template>

	<xsl:template match="auslsa-environment" mode="xhtml">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:call-template name="auslsa-page-template-pdf">
			<xsl:with-param name="page" select="$report/checklistPage[@page_id = '2596']" />
		</xsl:call-template>
	</xsl:template>

	<!-- //Generic Template -->
	<xsl:template match="auslsa-section-template" mode="xhtml">
		<xsl:variable name="page_section_id" select="@page_section_id" />
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<!-- //Each Page -->
		<xsl:for-each select="$report/checklistPage[@page_section_id = $page_section_id]">
			<xsl:sort select="@sequence" data-type="number" />

			<xsl:call-template name="auslsa-page-template-pdf">
				<xsl:with-param name="page" select="." />
				<xsl:with-param name="checklist-page-position" select="position()" />
			</xsl:call-template>
		</xsl:for-each>

	</xsl:template>

	<xsl:template name="auslsa-page-template-pdf">
		<xsl:param name="page" />
		<xsl:param name="checklist-page-position" select="1" />
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

		<fo:block page-break-after="auto">

			<!-- //Page -->
			<xsl:call-template name="section-page-pdf" type="component">
				<xsl:with-param name="title" select="$page/@title" />
			</xsl:call-template>

			<!-- //About -->
			<xsl:if test="$checklist-page-position = 1">
				<xsl:call-template name="section-textarea-pdf" type="component">
					<xsl:with-param name="content" select="$report/questionAnswer[@page_id = $page/@page_id][@sequence = '1']/answer[@answer_type = 'textarea']/@arbitrary_value" />
				</xsl:call-template>
			</xsl:if>

			<!--//Answer Grid Header -->
			<xsl:call-template name="section-grid-header-pdf" type="component" />

			<!-- //Questions -->
			<xsl:choose>
				<xsl:when test="count($report/questionAnswer[@page_id = $page/@page_id]) &gt; 0">
					<xsl:for-each select="$report/questionAnswer[@page_id = $page/@page_id]">
						<xsl:sort select="sequence" data-type="number" />

						<xsl:if test="@sequence != '1' or (@sequence = '1' and answer/@answer_type != 'textarea')">
							<xsl:call-template name="section-grid-question-pdf">
								<xsl:with-param name="question_id" select="@question_id" />
							</xsl:call-template>
						</xsl:if>

					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<fo:block text-align="center" padding="7px">
						No responses provided.
					</fo:block>	
				</xsl:otherwise>
			</xsl:choose>

			<!--//Answer Grid Footer -->
			<xsl:call-template name="section-grid-footer-pdf" type="component" />

			<!-- //Notes -->
			<xsl:call-template name="section-textarea-pdf" type="component">
				<xsl:with-param name="title" select="'User comments and notes'" />
				<xsl:with-param name="content" select="$report/checklistPage[@page_id = $page/@page_id]/@note" />
				<xsl:with-param name="answer-type" select="'comment'" />
			</xsl:call-template>

		</fo:block>

	</xsl:template>

	<xsl:template name="report-header-pdf" type="component">
		<xsl:param name="company_name" />
		<xsl:param name="year" />
		<xsl:param name="company_logo" />

		<fo:table>
			<fo:table-column column-width="80%" />
			<fo:table-column column-width="20%" />

			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-size="18px" font-weight="bold" margin-top="10px" margin-bottom="5px">
							<xsl:value-of select="$company_name" />
						</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block text-align="right" font-size="18px" font-weight="bold" margin-top="10px" margin-bottom="5px">
							<xsl:value-of select="$year" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>

	<xsl:template name="section-header-pdf" type="component">
		<xsl:param name="title" />
		<fo:block margin-top="30px">
			<xsl:value-of select="$title" />
		</fo:block>
	</xsl:template>

	<xsl:template name="section-grid-footer-pdf" type="component">
		<fo:block margin-bottom="25px">
		</fo:block>
	</xsl:template>

	<xsl:template name="section-textarea-pdf" type="component">
		<xsl:param name="title" />
		<xsl:param name="content" />
		<xsl:param name="answer-type" />
		<xsl:param name="url" />

		<fo:block margin-top="10px" font-weight="bold" margin-bottom="7px">
			<xsl:value-of select="$title" />
		</fo:block>
		<fo:block margin-bottom="20px" text-align="justify" line-height="150%">
			<xsl:choose>
				<xsl:when test="$answer-type = 'file' and $url != ''">
					<a href="{$url}">
						<xsl:value-of select="$content" />
					</a>
				</xsl:when>
				<xsl:when test="count($content) = 0 or $content = ''">
					Nil
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$content" />
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>

	<xsl:template name="section-inline-pdf" type="component">
		<xsl:param name="title" />
		<xsl:param name="content" />

		<fo:block padding-bottom="7px">
			<fo:inline font-weight="bold" padding-right="10px">
				<xsl:value-of select="$title" />
			</fo:inline>
			<fo:inline>
				<xsl:value-of select="$content" />
			</fo:inline>
		</fo:block>
	</xsl:template>

	<xsl:template match="page-title" mode="xhtml">
		<xsl:param name="title" select="@title" />
		<xsl:call-template name="section-page-pdf">
			<xsl:with-param name="title" select="$title" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="section-page-pdf" type="component">
		<xsl:param name="title" />
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<fo:block font-weight="bold" margin-bottom="10px" margin-top="30px" font-size="14px" color="{$report/@report_primary_color}">
			<xsl:value-of select="$title" />
		</fo:block>
	</xsl:template>

	<xsl:template name="section-grid-header-pdf">
		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<fo:table>
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block background-color="#f3f3f3" font-weight="bold" padding="7px" border-bottom-width="1px" border-bottom-color="#ddd" border-bottom-style="solid" margin-left="0px">
							Question	
						</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block background-color="#f3f3f3" font-weight="bold" padding="7px" border-bottom-width="1px" border-bottom-color="#ddd" border-bottom-style="solid">
							<xsl:choose>
								<xsl:when test="$report/@date_range_finish_year != ''">
									<xsl:value-of select="$report/@date_range_finish_year - 1" /> Response
								</xsl:when>
								<xsl:otherwise>
									Previous Response
								</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block background-color="#f3f3f3" font-weight="bold" padding="7px" border-bottom-width="1px" border-bottom-color="#ddd" border-bottom-style="solid">
							<xsl:choose>
								<xsl:when test="$report/@date_range_finish_year != ''">
									<xsl:value-of select="$report/@date_range_finish_year" /> Response
								</xsl:when>
								<xsl:otherwise>
									Response
								</xsl:otherwise>
							</xsl:choose>	
						</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block background-color="#f3f3f3" font-weight="bold" padding="7px" border-bottom-width="1px" border-bottom-color="#ddd" border-bottom-style="solid" margin-right="0px">
							<xsl:choose>
								<xsl:when test="$report/@date_range_finish_year != ''">
									<xsl:value-of select="$report/@date_range_finish_year - 1" /> Benchmark
								</xsl:when>
								<xsl:otherwise>
									Benchmark
								</xsl:otherwise>
							</xsl:choose>		
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>

	<xsl:template name="section-grid-question-pdf">
		<xsl:param name="question_id" />
		<xsl:param name="question" />
		<xsl:param name="previousResponse" />
		<xsl:param name="currentResponse" />

		<xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />
		<xsl:variable name="currentYear" select="$report/@date_range_finish_year" />
		<xsl:variable name="previousYear" select="$report/@date_range_finish_year - 1" />

		<fo:table>
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-body>
				<fo:table-row border-bottom-width="1px" border-bottom-style="solid" border-bottom-color="#ececec">
					<fo:table-cell padding-right="3px">
						<fo:block padding-top="7px" padding-bottom="7px">
							<xsl:choose>
								<xsl:when test="$report/questionAnswer[@question_id = $question_id]/answer/@answer_type = 'file-upload'">
									Supporting files uploaded
								</xsl:when>
								<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'file-upload'">
									Supporting files uploaded
								</xsl:when>
								<xsl:when test="$report/questionAnswer[@question_id = $question_id]/@export_key != ''">
									<xsl:value-of select="$report/questionAnswer[@question_id = $question_id]/@export_key" />
								</xsl:when>
								<xsl:when test="$report/questionAnswer[@question_id = $question_id]/@question != ''">
									<xsl:value-of select="$report/questionAnswer[@question_id = $question_id]/@question" />
								</xsl:when>
								<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@export_key != ''">
									<xsl:value-of select="$report/benchmarks/answer[@question_id = $question_id]/@export_key" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$report/questionAnswer[@question_id = $question_id]/@question" />
								</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell padding-right="3px">
						<fo:block padding-top="5px"></fo:block>
						<xsl:choose>
							<xsl:when test="count($report/previousClientChecklists/clientChecklist[@year = ($report/@date_range_finish_year - 1)]/clientResult[@question_id = $question_id]) &gt; 0">
								<xsl:for-each select="$report/previousClientChecklists/clientChecklist[@year = ($report/@date_range_finish_year - 1)]/clientResult[@question_id = $question_id]">
									<xsl:sort select="@sequence" data-type="number" />
									<fo:block padding-top="2px" padding-bottom="2px">
										<xsl:choose>
											<xsl:when test="@answer_type = 'file-upload'">
												<xsl:choose>
													<xsl:when test="@name != ''">
														<a href="{concat('https://www.greenbizcheck.com/download/?hash=',@hash)}">
															<xsl:value-of select="concat(@name, ' (', @readable_size, ')')" />
														</a>
													</xsl:when>
													<xsl:otherwise>
														Nil
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:when test="@answer_type = 'float' or @answer_type = 'int'">
												<xsl:value-of select="format-number(@arbitrary_value, '#,###')" />
											</xsl:when>
											<xsl:when test="@answer_type = 'checkbox' or @answer_type = 'drop-down-list'">
												<xsl:value-of select="@string" />
											</xsl:when>
											<xsl:when test="@answer_type = 'range'">
												<xsl:value-of select="concat(@arbitrary_value, @range_unit)" />
											</xsl:when>
											<xsl:when test="@answer_type = 'percent'">
												<xsl:value-of select="concat(@arbitrary_value, '%')" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="@arbitrary_value" />
											</xsl:otherwise>
										</xsl:choose>
									</fo:block>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<fo:block>N/A</fo:block>
							</xsl:otherwise>
						</xsl:choose>
						<fo:block padding-bottom="5px"></fo:block>
					</fo:table-cell>
					<fo:table-cell padding-right="3px">
						<fo:block padding-top="5px"></fo:block>
						<xsl:for-each select="$report/questionAnswer[@question_id = $question_id]/answer">
							<xsl:sort select="@answer_sequence" data-type="number" />
							<fo:block padding-top="2px" padding-bottom="2px">
								<xsl:choose>
									<xsl:when test="@answer_type = 'file-upload'">
										<xsl:choose>
											<xsl:when test="@name != ''">
												<a href="{concat('https://www.greenbizcheck.com/download/?hash=',@hash)}">
													<xsl:value-of select="concat(@name, ' (', @readable_size, ')')" />
												</a>
											</xsl:when>
											<xsl:otherwise>
												Nil
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="@answer_type = 'float' or @answer_type = 'int'">
										<xsl:value-of select="format-number(@arbitrary_value, '#,###')" />
									</xsl:when>
									<xsl:when test="@answer_type = 'checkbox' or @answer_type = 'drop-down-list'">
										<xsl:value-of select="@answer_string" />
									</xsl:when>
									<xsl:when test="@answer_type = 'range'">
										<xsl:value-of select="concat(@arbitrary_value, @range_unit)" />
									</xsl:when>
									<xsl:when test="@answer_type = 'percent'">
										<xsl:value-of select="concat(@arbitrary_value, '%')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@arbitrary_value" />
									</xsl:otherwise>
								</xsl:choose>
							</fo:block>
						</xsl:for-each>
						<fo:block padding-bottom="5px"></fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block padding-top="5px" padding-bottom="5px">
							<xsl:choose>

								<!-- //Number (int, float, percent, range) -->
								<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'int' or $report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'float' or $report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'range'  or $report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'percent'">
									<fo:table>
										<fo:table-column column-width="60%" />
										<fo:table-column column-width="40%" />
										<fo:table-body>
											<fo:table-row>
												<fo:table-cell>
													<fo:block padding-top="2px" padding-bottom="2px">
														Lowest:
													</fo:block>
												</fo:table-cell>
												<fo:table-cell>
													<fo:block text-align="right" padding-top="2px" padding-bottom="2px">
														<xsl:value-of select="format-number($report/benchmarks/answer[@question_id = $question_id]/result[@year = $previousYear]/@min, '#,###')" />
														<xsl:choose>
															<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'range'">
																<xsl:value-of select="$report/benchmarks/answer[@question_id = $question_id]/@range_unit" />
															</xsl:when>
															<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'percent'">
																%
															</xsl:when>
														</xsl:choose>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell>
													<fo:block padding-top="2px" padding-bottom="2px">
														Highest:
													</fo:block>
												</fo:table-cell>
												<fo:table-cell>
													<fo:block text-align="right" padding-top="2px" padding-bottom="2px">
														<xsl:value-of select="format-number($report/benchmarks/answer[@question_id = $question_id]/result[@year = $previousYear]/@max, '#,###')" />
														<xsl:choose>
															<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'range'">
																<xsl:value-of select="$report/benchmarks/answer[@question_id = $question_id]/@range_unit" />
															</xsl:when>
															<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'percent'">
																%
															</xsl:when>
														</xsl:choose>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell>
													<fo:block padding-top="2px" padding-bottom="2px">
														Average:
													</fo:block>
												</fo:table-cell>
												<fo:table-cell>
													<fo:block text-align="right" padding-top="2px" padding-bottom="2px">
														<xsl:value-of select="format-number($report/benchmarks/answer[@question_id = $question_id]/result[@year = $previousYear]/@avg, '#,###')" />
														<xsl:choose>
															<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'range'">
																<xsl:value-of select="$report/benchmarks/answer[@question_id = $question_id]/@range_unit" />
															</xsl:when>
															<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'percent'">
																%
															</xsl:when>
														</xsl:choose>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
										</fo:table-body>
									</fo:table>
								</xsl:when>

								<!-- //Answer String (Checkbox, Checkbox-other, Drop Down List -->
								<xsl:when test="$report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'checkbox' or $report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'checkbox-other' or $report/benchmarks/answer[@question_id = $question_id]/@answer_type = 'drop-down-list'">
									<xsl:variable name="total" select="sum($report/benchmarks/answer[@question_id = $question_id]/result[@year = $previousYear]/@count)" />
									
									<fo:table>
										<fo:table-column column-width="75%" />
										<fo:table-column column-width="25%" />
										<fo:table-body>
											<fo:table-row>
												<fo:table-cell>
													<fo:block></fo:block>
												</fo:table-cell>
											</fo:table-row>
											<xsl:for-each select="$report/benchmarks/answer[@question_id = $question_id and $question_id != '14394']">
												<xsl:sort select="@sequence" data-type="number" />
												<fo:table-row>
													<fo:table-cell>
														<fo:block padding-top="2px" padding-bottom="2px">
															<xsl:value-of select="@answer_string" />
														</fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block text-align="right" padding-top="2px" padding-bottom="2px">
															<xsl:choose>
																<xsl:when test="$total &gt; 0">
																	<xsl:choose>
																		<xsl:when test="result[@year = $previousYear]/@count &gt; 0">
																			<xsl:choose>
																				<xsl:when test="result[@year = $previousYear]/@multiple_answer = 1">
																					<xsl:value-of select="round((result[@year = $previousYear]/@count div result[@year = $previousYear]/@respondents)*100)" />%
																				</xsl:when>
																				<xsl:otherwise>
																					<xsl:value-of select="round((result[@year = $previousYear]/@count div $total)*100)" />%
																				</xsl:otherwise>
																			</xsl:choose>
																		</xsl:when>
																		<xsl:otherwise>
																			0%
																		</xsl:otherwise>
																	</xsl:choose>
																</xsl:when>
																<xsl:otherwise>
																	N/A
																</xsl:otherwise>
															</xsl:choose>
														</fo:block>
													</fo:table-cell>
												</fo:table-row>
											</xsl:for-each>
										</fo:table-body>
									</fo:table>
								
								</xsl:when>

							</xsl:choose>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>

	</xsl:template>

</xsl:stylesheet>