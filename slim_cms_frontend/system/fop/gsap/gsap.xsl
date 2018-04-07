<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			extension-element-prefixes="date str">

	<xsl:output indent="yes"/>
	
<!-- ============================ RAW XSL =============================== -->
<xsl:include href="../util/graph.xsl" />
<xsl:include href="../util/xhtml.xsl" />
<xsl:include href="../util/auditQuestions.xsl" />
<xsl:include href="../util/ghg.xsl" />
<xsl:include href="../util/certificationLevels.xsl" />
<xsl:include href="../util/stamp.xsl" />
<xsl:include href="../util/categoryScores.xsl" />
<xsl:include href="../util/overallScore.xsl" />

<!-- //All Content that the assessment report needs -->

  <xsl:param name="XFCrtLocalDate">2009-10-30</xsl:param>
  <xsl:param name="XFCrtLocalTime">17:37:59.017</xsl:param>
  <xsl:param name="XFCrtLocalDateTime">2009-10-30T17:37:59.017</xsl:param>
  <xsl:param name="XFCrtUTCDate">2009-10-30</xsl:param>
  <xsl:param name="XFCrtUTCTime">07:37:59.997</xsl:param>
  <xsl:param name="XFCrtUTCDateTime">2009-10-30T07:37:59.997</xsl:param>
  <!-- ============================ RAW XSL =============================== -->

<!-- ========================= ROOT TEMPLATE =========================== -->
	<xsl:template match="/">
		
		<xsl:variable name="client" select="/config/plugin[@plugin = 'clients']/user" />
		<xsl:variable name="companyName" select="/config/plugin[@plugin = 'checklist']/report/reportSection[1]/@company_name" />
		<xsl:variable name="report" select="/config/plugin[@plugin = 'checklist']/report" />
		
		<fo:root>
			<fo:layout-master-set>
	
				<fo:simple-page-master master-name="all-pages" page-height="297mm" page-width="210mm" margin="10mm">
					<fo:region-body padding="0%" margin-top="25mm" margin-bottom="10mm" region-name="xsl-region-body" />
					<fo:region-before padding="0%" region-name="region-before" display-align="after" extent="10mm" />
					<fo:region-after padding="0%" region-name="region-after" display-align="after" extent="2mm" />
        		</fo:simple-page-master>
        		
			</fo:layout-master-set>
			
			<!-- //All Pages Template -->
			<fo:page-sequence master-reference="all-pages">

				<!-- //All Pages Header -->
				<fo:static-content flow-name="region-before" font-family="Harmony Text">
				
					<!-- //Header image -->
					<fo:block-container position="absolute" overflow="hidden">
				   		<fo:block>
				   			<xsl:choose>
				   				<xsl:when test="/config/plugin[@plugin = 'clients']/client/@client_type_id = '19'">
				   					<fo:external-graphic src="url('fujitsu-logo.svg')" scaling="non-uniform" content-height="15mm" />
				   				</xsl:when>
				   				<xsl:when test="/config/plugin[@plugin = 'clients']/client/@client_type_id = '20'">
				   					<fo:external-graphic src="url('staples-logo.svg')" scaling="non-uniform" content-height="15mm" />
				   				</xsl:when>
				   				<xsl:when test="/config/plugin[@plugin = 'clients']/client/@client_type_id = '21'">
				   					<fo:external-graphic src="url('banyan-tree-logo.svg')" scaling="non-uniform" content-height="15mm" />
				   				</xsl:when>
				   				<xsl:when test="/config/plugin[@plugin = 'clients']/client/@client_type_id = '22'">
				   					<fo:external-graphic src="url('fred-hollows-logo.svg')" scaling="non-uniform" content-height="15mm" />
				   				</xsl:when>
				   				<xsl:when test="/config/plugin[@plugin = 'clients']/client/@client_type_id = '23'">
				   					<fo:external-graphic src="url('anz-logo.svg')" scaling="non-uniform" content-height="15mm" />
				   				</xsl:when>
				   				<xsl:when test="/config/plugin[@plugin = 'clients']/client/@client_type_id = '24'">
				   					<fo:external-graphic src="url('manpower-logo.svg')" scaling="non-uniform" content-height="15mm" />
				   				</xsl:when>
				   				<xsl:otherwise>
				   					<fo:external-graphic src="url('ipbiz-logo.svg')" scaling="non-uniform" content-height="15mm" />
				   				</xsl:otherwise>
				   			</xsl:choose>
			    		</fo:block>
					</fo:block-container>
				
					<fo:block-container position="absolute" overflow="hidden">
						<fo:block text-align="right" color="#000000" font-size="16pt" font-weight="bold" margin-top="4mm" margin-right="2mm">
							<xsl:value-of select="translate(/config/plugin/report/@name,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
						</fo:block>
					</fo:block-container>
					
					<fo:block-container position="absolute" overflow="hidden">
				   		<fo:block text-align="right" color="#000000" font-size="12pt" font-weight="bold" margin-top="10mm" margin-right="2mm">
				   			<xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name"/>
				   		</fo:block>
					</fo:block-container>
					
				</fo:static-content>
				
				<!-- //All Pages Footer -->
				<fo:static-content flow-name="region-after" font-family="Harmony Text">

					<fo:block-container position="absolute" overflow="hidden">
				   		<fo:block color="#000000" font-size="8pt">
				   			<xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name"/>
				   		</fo:block>
					</fo:block-container>
				
					<fo:block-container position="absolute" overflow="hidden">
						<fo:block text-align="right" color="#000000" font-size="8pt">
							Page <fo:page-number />
						</fo:block>
					</fo:block-container>

				</fo:static-content>
							
				<fo:flow flow-name="xsl-region-body" font-family="Harmony Text" font-size="10pt">

					<!-- //Main Report Content - Loop for each report section -->
					<fo:block>
						<xsl:for-each select="/config/plugin[@plugin='checklist']/report[1]/reportSection[@display_in_pdf = '1']">
					  		<fo:block margin-bottom="20pt" keep-together="auto">
					  			
					  			<!-- //After the 3rd report section, Category Scores, Insert a page breack to get all actions on a separate page -->
					  			<xsl:if test="position() = 4">
					  				<fo:block break-after="page"></fo:block>
					  			</xsl:if>
					  			
					  			
								<fo:block>
									<fo:block font-size="16pt" font-weight="bold" color="rgb(41,91,170)"><fo:inline><xsl:value-of select="@title"/></fo:inline></fo:block>
										<fo:block margin-top="0pt" >
											<xsl:call-template name="renderXHTML">
												<xsl:with-param name="xhtml" select="content"/>
											</xsl:call-template>
										</fo:block>
									</fo:block>
					
									<!-- //Confirmation for the current report section -->
									<xsl:choose>
										<xsl:when test="../confirmation[@report_section_id = current()/@report_section_id]">
											<fo:block color="#000000">
												<xsl:for-each select="../confirmation[@report_section_id = current()/@report_section_id]">
													<fo:block color="#000000">
														<fo:list-block>
															<fo:list-item margin-bottom="1pt" keep-together.within-page="always">
																<fo:list-item-label start-indent="0cm">
																	<fo:block>
																		<fo:external-graphic src="url(tick2.png)" />
																	</fo:block>
																</fo:list-item-label>
																<fo:list-item-body start-indent="4mm">
																	<fo:block color="#000000">
																		<xsl:value-of select="@confirmation" disable-output-escaping="yes" />
																	</fo:block>
																</fo:list-item-body>
															</fo:list-item>
														</fo:list-block>
													</fo:block>
												</xsl:for-each>
											</fo:block>
										</xsl:when>
									</xsl:choose>
									
									<!-- //Commitments for the current report section -->
									<xsl:for-each select="../action[@report_section_id = current()/@report_section_id]">                              
										<xsl:sort select="@sequence"/>
										<xsl:for-each select="../commitment[@action_id = current()/@action_id]">
											<xsl:if test="../action[@action_id = current()/@action_id]/@commitment_id = current()/@commitment_id">
												<fo:block color="#000000">
													<fo:list-block>
					                            		<fo:list-item margin-bottom="1pt">
					                              			<fo:list-item-label>
					                                			<fo:block>
					                                  				<fo:external-graphic src="url(./tick.png)"/>
					                                			</fo:block>
					                              			</fo:list-item-label>
					                              			<fo:list-item-body start-indent="4mm">
					                                			<fo:block color="#000000">
					                                  				<xsl:value-of select="@commitment" disable-output-escaping="yes" />
					                                			</fo:block>
					                              			</fo:list-item-body>
					                            		</fo:list-item>
					                          		</fo:list-block>
												</fo:block>
                                			</xsl:if>
                              			</xsl:for-each>
			                      </xsl:for-each>
					
								<!-- //Actions for the current report section -->
								<xsl:choose>
									<xsl:when test="../action[@report_section_id = current()/@report_section_id]">
										<fo:block>
											<xsl:for-each select="../action[@report_section_id = current()/@report_section_id]">
												<xsl:sort select="@sequence"/>
												<xsl:if test="/config/plugin[@plugin = 'checklist']/@report_type = 'full' or @demerits &gt; 0">
													<fo:block>
														<xsl:choose>
															<xsl:when test="@demerits &gt; 0">
																<fo:block margin-top="2pt" margin-left="4mm" color="rgb(41,91,170)" text-decoration="underline">
																	<xsl:value-of select="@summary" disable-output-escaping="yes"/>
																</fo:block>
															</xsl:when>
															<xsl:otherwise>
																<fo:block margin-top="2pt" margin-left="4mm" color="rgb(41,91,170)" text-decoration="underline">
																	<fo:character character=" "/><xsl:value-of select="@summary" disable-output-escaping="yes"/>
																</fo:block>
															</xsl:otherwise>
														</xsl:choose>
													</fo:block>
												</xsl:if>
											</xsl:for-each>                                    
										</fo:block>
									</xsl:when>
								</xsl:choose>
								
								
								<!-- //On the last report section, insert the GBC stamp -->
					  			<!-- <xsl:if test="position() = last()"> -->
									<fo:block-container overflow="hidden" position="absolute" top="245mm" left="80mm">
										<fo:block>
											<fo:external-graphic src="url('../util/powered-by-greenbizcheck.svg')" scaling="non-uniform" content-height="10mm" />
										</fo:block>
									</fo:block-container>
					  			<!-- </xsl:if> -->
								
							</fo:block>
						</xsl:for-each>
					</fo:block>
				</fo:flow>
			</fo:page-sequence>	
		</fo:root>
	</xsl:template>
				
				
	<!-- ============================ END OF MAIN CONTENT =================================== -->
	
	<xsl:template match="instructions" mode="xhtml">
		<fo:block keep-together.within-page="always">
			<fo:block margin-top="4pt" font-weight="bold">Summary Report</fo:block>
			<fo:block margin-top="4pt" margin-left="20pt">• Overall Score (initial score and current score): The difference between the two scores reflects the actions you have implemented</fo:block>
			<fo:block margin-top="4pt" margin-left="20pt">• Category Scores: Provides you with a radar graph of your individual section scores</fo:block>
			<fo:block margin-top="4pt" margin-left="20pt">• Section 1-line summaries:</fo:block>
			<fo:block margin-top="4pt" margin-left="40pt">• <fo:external-graphic src="url(tick2.png)"/> <fo:inline font-weight="bold"> Light green check</fo:inline>: confirmation of actions already in place.</fo:block>
			<fo:block margin-top="4pt" margin-left="40pt">• <fo:external-graphic src="url(tick.png)" /> <fo:inline font-weight="bold"> Dark green bolded check</fo:inline>: depicts actions that your organisation has implemented since its assessment and which have affected your overall scores.</fo:block>
			<fo:block margin-top="4pt" margin-left="40pt">• <fo:inline font-weight="bold"> Suggested remedial actions </fo:inline> are without a check in <fo:inline color="rgb(41,91,170)" text-decoration="underline">blue and are underscored</fo:inline>.</fo:block>
			<fo:block margin-top="4pt">Please log into your online account for more information and details of the suggested actions.</fo:block>
		</fo:block>
	</xsl:template>
	
	
<!-- ========================= NUMBER FORMATS ========================= -->
<!-- ========================= EXSLT TEMPLATES [str.padding.template.xsl] ========================= -->
	<xsl:template name="str:padding">
		<xsl:param name="length" select="0"/>
		<xsl:param name="chars" select="' '"/>
		<xsl:choose>
			<xsl:when test="not($length) or not($chars)"/>
			<xsl:otherwise>
				<xsl:variable name="string" select="concat($chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars)"/>
				<xsl:choose>
					<xsl:when test="string-length($string) &gt;= $length">
						<xsl:value-of select="substring($string, 1, $length)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="str:padding">
							<xsl:with-param name="length" select="$length"/>
							<xsl:with-param name="chars" select="$string"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
<!-- ========================= EXSLT TEMPLATES [date.format-date.template.xsl] ========================= -->
	<date:months>
		<date:month length="31" abbr="Jan">January</date:month>
		<date:month length="28" abbr="Feb">February</date:month>
		<date:month length="31" abbr="Mar">March</date:month>
		<date:month length="30" abbr="Apr">April</date:month>
		<date:month length="31" abbr="May">May</date:month>
		<date:month length="30" abbr="Jun">June</date:month>
		<date:month length="31" abbr="Jul">July</date:month>
		<date:month length="31" abbr="Aug">August</date:month>
		<date:month length="30" abbr="Sep">September</date:month>
		<date:month length="31" abbr="Oct">October</date:month>
		<date:month length="30" abbr="Nov">November</date:month>
		<date:month length="31" abbr="Dec">December</date:month>
	</date:months>
	<date:days>
		<date:day abbr="Sun">Sunday</date:day>
		<date:day abbr="Mon">Monday</date:day>
		<date:day abbr="Tue">Tuesday</date:day>
		<date:day abbr="Wed">Wednesday</date:day>
		<date:day abbr="Thu">Thursday</date:day>
		<date:day abbr="Fri">Friday</date:day>
		<date:day abbr="Sat">Saturday</date:day>
	</date:days>
	<xsl:template name="date:format-date">
		<xsl:param name="date-time"/>
		<xsl:param name="pattern"/>
		<xsl:variable name="formatted">
			<xsl:choose>
				<xsl:when test="starts-with($date-time, '---')">
					<xsl:call-template name="date:_format-date">
						<xsl:with-param name="year" select="'NaN'"/>
						<xsl:with-param name="month" select="'NaN'"/>
						<xsl:with-param name="day" select="number(substring($date-time, 4, 2))"/>
						<xsl:with-param name="pattern" select="$pattern"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="starts-with($date-time, '--')">
					<xsl:call-template name="date:_format-date">
						<xsl:with-param name="year" select="'NaN'"/>
						<xsl:with-param name="month" select="number(substring($date-time, 3, 2))"/>
						<xsl:with-param name="day" select="number(substring($date-time, 6, 2))"/>
						<xsl:with-param name="pattern" select="$pattern"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="neg" select="starts-with($date-time, '-')"/>
					<xsl:variable name="no-neg">
						<xsl:choose>
							<xsl:when test="$neg or starts-with($date-time, '+')">
								<xsl:value-of select="substring($date-time, 2)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$date-time"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="no-neg-length" select="string-length($no-neg)"/>
					<xsl:variable name="timezone">
						<xsl:choose>
							<xsl:when test="substring($no-neg, $no-neg-length) = 'Z'">Z</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="tz" select="substring($no-neg, $no-neg-length - 5)"/>
								<xsl:if test="(substring($tz, 1, 1) = '-' or                                      substring($tz, 1, 1) = '+') and                                    substring($tz, 4, 1) = ':'">
									<xsl:value-of select="$tz"/>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:if test="not(string($timezone)) or                           $timezone = 'Z' or                            (substring($timezone, 2, 2) &lt;= 23 and                            substring($timezone, 5, 2) &lt;= 59)">
						<xsl:variable name="dt" select="substring($no-neg, 1, $no-neg-length - string-length($timezone))"/>
						<xsl:variable name="dt-length" select="string-length($dt)"/>
						<xsl:choose>
							<xsl:when test="substring($dt, 3, 1) = ':' and                                   substring($dt, 6, 1) = ':'">
								<xsl:variable name="hour" select="substring($dt, 1, 2)"/>
								<xsl:variable name="min" select="substring($dt, 4, 2)"/>
								<xsl:variable name="sec" select="substring($dt, 7)"/>
								<xsl:if test="$hour &lt;= 23 and                                    $min &lt;= 59 and                                    $sec &lt;= 60">
									<xsl:call-template name="date:_format-date">
										<xsl:with-param name="year" select="'NaN'"/>
										<xsl:with-param name="month" select="'NaN'"/>
										<xsl:with-param name="day" select="'NaN'"/>
										<xsl:with-param name="hour" select="$hour"/>
										<xsl:with-param name="minute" select="$min"/>
										<xsl:with-param name="second" select="$sec"/>
										<xsl:with-param name="timezone" select="$timezone"/>
										<xsl:with-param name="pattern" select="$pattern"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="year" select="substring($dt, 1, 4) * (($neg * -2) + 1)"/>
								<xsl:choose>
									<xsl:when test="not(number($year))"/>
									<xsl:when test="$dt-length = 4">
										<xsl:call-template name="date:_format-date">
											<xsl:with-param name="year" select="$year"/>
											<xsl:with-param name="timezone" select="$timezone"/>
											<xsl:with-param name="pattern" select="$pattern"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="substring($dt, 5, 1) = '-'">
										<xsl:variable name="month" select="substring($dt, 6, 2)"/>
										<xsl:choose>
											<xsl:when test="not($month &lt;= 12)"/>
											<xsl:when test="$dt-length = 7">
												<xsl:call-template name="date:_format-date">
													<xsl:with-param name="year" select="$year"/>
													<xsl:with-param name="month" select="$month"/>
													<xsl:with-param name="timezone" select="$timezone"/>
													<xsl:with-param name="pattern" select="$pattern"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:when test="substring($dt, 8, 1) = '-'">
												<xsl:variable name="day" select="substring($dt, 9, 2)"/>
												<xsl:if test="$day &lt;= 31">
													<xsl:choose>
														<xsl:when test="$dt-length = 10">
															<xsl:call-template name="date:_format-date">
																<xsl:with-param name="year" select="$year"/>
																<xsl:with-param name="month" select="$month"/>
																<xsl:with-param name="day" select="$day"/>
																<xsl:with-param name="timezone" select="$timezone"/>
																<xsl:with-param name="pattern" select="$pattern"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:when test="substring($dt, 11, 1) = 'T' and                                                        substring($dt, 14, 1) = ':' and                                                        substring($dt, 17, 1) = ':'">
															<xsl:variable name="hour" select="substring($dt, 12, 2)"/>
															<xsl:variable name="min" select="substring($dt, 15, 2)"/>
															<xsl:variable name="sec" select="substring($dt, 18)"/>
															<xsl:if test="$hour &lt;= 23 and                                                         $min &lt;= 59 and                                                         $sec &lt;= 60">
																<xsl:call-template name="date:_format-date">
																	<xsl:with-param name="year" select="$year"/>
																	<xsl:with-param name="month" select="$month"/>
																	<xsl:with-param name="day" select="$day"/>
																	<xsl:with-param name="hour" select="$hour"/>
																	<xsl:with-param name="minute" select="$min"/>
																	<xsl:with-param name="second" select="$sec"/>
																	<xsl:with-param name="timezone" select="$timezone"/>
																	<xsl:with-param name="pattern" select="$pattern"/>
																</xsl:call-template>
															</xsl:if>
														</xsl:when>
													</xsl:choose>
												</xsl:if>
											</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="string(number(substring($dt,5,1)))!='NaN'">
										<xsl:variable name="month" select="substring($dt, 5, 2)"/>
										<xsl:choose>
											<xsl:when test="not($month &lt;= 12)"/>
											<xsl:when test="$dt-length = 6">
												<xsl:call-template name="date:_format-date">
													<xsl:with-param name="year" select="$year"/>
													<xsl:with-param name="month" select="$month"/>
													<xsl:with-param name="timezone" select="$timezone"/>
													<xsl:with-param name="pattern" select="$pattern"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:variable name="day" select="substring($dt, 7, 2)"/>
												<xsl:if test="$day &lt;= 31">
													<xsl:choose>
														<xsl:when test="$dt-length = 8">
															<xsl:call-template name="date:_format-date">
																<xsl:with-param name="year" select="$year"/>
																<xsl:with-param name="month" select="$month"/>
																<xsl:with-param name="day" select="$day"/>
																<xsl:with-param name="timezone" select="$timezone"/>
																<xsl:with-param name="pattern" select="$pattern"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:when test="substring($dt, 9, 1) = 'T' and  substring($dt, 12, 1) = ':' and  substring($dt, 15, 1) = ':'">
															<xsl:variable name="hour" select="substring($dt, 10, 2)"/>
															<xsl:variable name="min" select="substring($dt, 13, 2)"/>
															<xsl:variable name="sec" select="substring($dt, 16)"/>
															<xsl:if test="$hour &lt;= 23 and                                                         $min &lt;= 59 and                                                         $sec &lt;= 60">
																<xsl:call-template name="date:_format-date">
																	<xsl:with-param name="year" select="$year"/>
																	<xsl:with-param name="month" select="$month"/>
																	<xsl:with-param name="day" select="$day"/>
																	<xsl:with-param name="hour" select="$hour"/>
																	<xsl:with-param name="minute" select="$min"/>
																	<xsl:with-param name="second" select="$sec"/>
																	<xsl:with-param name="timezone" select="$timezone"/>
																	<xsl:with-param name="pattern" select="$pattern"/>
																</xsl:call-template>
															</xsl:if>
														</xsl:when>
													</xsl:choose>
												</xsl:if>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$formatted"/>
	</xsl:template>
	<xsl:template name="date:_format-date">
		<xsl:param name="year"/>
		<xsl:param name="month" select="1"/>
		<xsl:param name="day" select="1"/>
		<xsl:param name="hour" select="0"/>
		<xsl:param name="minute" select="0"/>
		<xsl:param name="second" select="0"/>
		<xsl:param name="timezone" select="'Z'"/>
		<xsl:param name="pattern" select="''"/>
		<xsl:variable name="char" select="substring($pattern, 1, 1)"/>
		<xsl:choose>
			<xsl:when test="not($pattern)"/>
			<xsl:when test="$char = &quot;'&quot;">
				<xsl:choose>
					<xsl:when test="substring($pattern, 2, 1) = &quot;'&quot;">
						<xsl:text>'</xsl:text>
						<xsl:call-template name="date:_format-date">
							<xsl:with-param name="year" select="$year"/>
							<xsl:with-param name="month" select="$month"/>
							<xsl:with-param name="day" select="$day"/>
							<xsl:with-param name="hour" select="$hour"/>
							<xsl:with-param name="minute" select="$minute"/>
							<xsl:with-param name="second" select="$second"/>
							<xsl:with-param name="timezone" select="$timezone"/>
							<xsl:with-param name="pattern" select="substring($pattern, 3)"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="literal-value" select="substring-before(substring($pattern, 2), &quot;'&quot;)"/>
						<xsl:value-of select="$literal-value"/>
						<xsl:call-template name="date:_format-date">
							<xsl:with-param name="year" select="$year"/>
							<xsl:with-param name="month" select="$month"/>
							<xsl:with-param name="day" select="$day"/>
							<xsl:with-param name="hour" select="$hour"/>
							<xsl:with-param name="minute" select="$minute"/>
							<xsl:with-param name="second" select="$second"/>
							<xsl:with-param name="timezone" select="$timezone"/>
							<xsl:with-param name="pattern" select="substring($pattern, string-length($literal-value) + 2)"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="not(contains('abcdefghjiklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', $char))">
				<xsl:value-of select="$char"/>
				<xsl:call-template name="date:_format-date">
					<xsl:with-param name="year" select="$year"/>
					<xsl:with-param name="month" select="$month"/>
					<xsl:with-param name="day" select="$day"/>
					<xsl:with-param name="hour" select="$hour"/>
					<xsl:with-param name="minute" select="$minute"/>
					<xsl:with-param name="second" select="$second"/>
					<xsl:with-param name="timezone" select="$timezone"/>
					<xsl:with-param name="pattern" select="substring($pattern, 2)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not(contains('GyMdhHmsSEDFwWakKz', $char))">
				<xsl:message>
              Invalid token in format string: <xsl:value-of select="$char"/></xsl:message>
				<xsl:call-template name="date:_format-date">
					<xsl:with-param name="year" select="$year"/>
					<xsl:with-param name="month" select="$month"/>
					<xsl:with-param name="day" select="$day"/>
					<xsl:with-param name="hour" select="$hour"/>
					<xsl:with-param name="minute" select="$minute"/>
					<xsl:with-param name="second" select="$second"/>
					<xsl:with-param name="timezone" select="$timezone"/>
					<xsl:with-param name="pattern" select="substring($pattern, 2)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="next-different-char" select="substring(translate($pattern, $char, ''), 1, 1)"/>
				<xsl:variable name="pattern-length">
					<xsl:choose>
						<xsl:when test="$next-different-char">
							<xsl:value-of select="string-length(substring-before($pattern, $next-different-char))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="string-length($pattern)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$char = 'G'">
						<xsl:choose>
							<xsl:when test="string($year) = 'NaN'"/>
							<xsl:when test="$year &gt; 0">AD</xsl:when>
							<xsl:otherwise>BC</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$char = 'M'">
						<xsl:choose>
							<xsl:when test="string($month) = 'NaN'"/>
							<xsl:when test="$pattern-length &gt;= 3">
								<xsl:variable name="month-node" select="document('')/*/date:months/date:month[number($month)]"/>
								<xsl:choose>
									<xsl:when test="$pattern-length &gt;= 4">
										<xsl:value-of select="$month-node"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$month-node/@abbr"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$pattern-length = 2">
								<xsl:value-of select="format-number($month, '00')"/>
							</xsl:when>
							<xsl:when test="$pattern-length = 1">
								<xsl:value-of select="format-number($month, '0')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$month"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$char = 'E'">
						<xsl:choose>
							<xsl:when test="string($year) = 'NaN' or string($month) = 'NaN' or string($day) = 'NaN'"/>
							<xsl:otherwise>
								<xsl:variable name="month-days" select="sum(document('')/*/date:months/date:month[position() &lt; $month]/@length)"/>
								<xsl:variable name="days" select="$month-days + $day + boolean(((not($year mod 4) and $year mod 100) or not($year mod 400)) and $month &gt; 2)"/>
								<xsl:variable name="y-1" select="$year - 1"/>
								<xsl:variable name="dow" select="(($y-1 + floor($y-1 div 4) -                                              floor($y-1 div 100) + floor($y-1 div 400) +                                              $days)                                              mod 7) + 1"/>
								<xsl:variable name="day-node" select="document('')/*/date:days/date:day[number($dow)]"/>
								<xsl:choose>
									<xsl:when test="$pattern-length &gt;= 4">
										<xsl:value-of select="$day-node"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$day-node/@abbr"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$char = 'a'">
						<xsl:choose>
							<xsl:when test="string($hour) = 'NaN'"/>
							<xsl:when test="$hour &gt;= 12">PM</xsl:when>
							<xsl:otherwise>AM</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$char = 'z'">
						<xsl:choose>
							<xsl:when test="$timezone = 'Z'">UTC</xsl:when>
							<xsl:otherwise>
                    UTC<xsl:value-of select="$timezone"/></xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="padding">
							<xsl:choose>
								<xsl:when test="$pattern-length &gt; 10">
									<xsl:call-template name="str:padding">
										<xsl:with-param name="length" select="$pattern-length"/>
										<xsl:with-param name="chars" select="'0'"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring('58585a0000', 1, $pattern-length)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$char = 'y'">
								<xsl:choose>
									<xsl:when test="string($year) = 'NaN'"/>
									<xsl:when test="$pattern-length &gt; 2">
										<xsl:value-of select="format-number($year, $padding)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="format-number(substring($year, string-length($year) - 1), $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'd'">
								<xsl:choose>
									<xsl:when test="string($day) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number($day, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'h'">
								<xsl:variable name="h" select="$hour mod 12"/>
								<xsl:choose>
									<xsl:when test="string($hour) = 'NaN'"/>
									<xsl:when test="$h">
										<xsl:value-of select="format-number($h, $padding)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="format-number(12, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'H'">
								<xsl:choose>
									<xsl:when test="string($hour) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number($hour, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'k'">
								<xsl:choose>
									<xsl:when test="string($hour) = 'NaN'"/>
									<xsl:when test="$hour">
										<xsl:value-of select="format-number($hour, $padding)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="format-number(24, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'K'">
								<xsl:choose>
									<xsl:when test="string($hour) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number($hour mod 12, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'm'">
								<xsl:choose>
									<xsl:when test="string($minute) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number($minute, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 's'">
								<xsl:choose>
									<xsl:when test="string($second) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number($second, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'S'">
								<xsl:choose>
									<xsl:when test="string($second) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number(substring-after($second, '.'), $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'F'">
								<xsl:choose>
									<xsl:when test="string($day) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="floor($day div 7) + 1"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="string($year) = 'NaN' or string($month) = 'NaN' or string($day) = 'NaN'"/>
							<xsl:otherwise>
								<xsl:variable name="month-days" select="sum(document('')/*/date:months/date:month[position() &lt; $month]/@length)"/>
								<xsl:variable name="days" select="$month-days + $day + boolean(((not($year mod 4) and $year mod 100) or not($year mod 400)) and $month &gt; 2)"/>
								<xsl:choose>
									<xsl:when test="$char = 'D'">
										<xsl:value-of select="format-number($days, $padding)"/>
									</xsl:when>
									<xsl:when test="$char = 'w'">
										<xsl:call-template name="date:_week-in-year">
											<xsl:with-param name="days" select="$days"/>
											<xsl:with-param name="year" select="$year"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="$char = 'W'">
										<xsl:variable name="y-1" select="$year - 1"/>
										<xsl:variable name="day-of-week" select="(($y-1 + floor($y-1 div 4) -                                                   floor($y-1 div 100) + floor($y-1 div 400) +                                                   $days)                                                    mod 7) + 1"/>
										<xsl:choose>
											<xsl:when test="($day - $day-of-week) mod 7">
												<xsl:value-of select="floor(($day - $day-of-week) div 7) + 2"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="floor(($day - $day-of-week) div 7) + 1"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="date:_format-date">
					<xsl:with-param name="year" select="$year"/>
					<xsl:with-param name="month" select="$month"/>
					<xsl:with-param name="day" select="$day"/>
					<xsl:with-param name="hour" select="$hour"/>
					<xsl:with-param name="minute" select="$minute"/>
					<xsl:with-param name="second" select="$second"/>
					<xsl:with-param name="timezone" select="$timezone"/>
					<xsl:with-param name="pattern" select="substring($pattern, $pattern-length + 1)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="date:_week-in-year">
		<xsl:param name="days"/>
		<xsl:param name="year"/>
		<xsl:variable name="y-1" select="$year - 1"/>
		<xsl:variable name="day-of-week" select="($y-1 + floor($y-1 div 4) -                           floor($y-1 div 100) + floor($y-1 div 400) +                           $days)                           mod 7"/>
		<xsl:variable name="dow">
			<xsl:choose>
				<xsl:when test="$day-of-week">
					<xsl:value-of select="$day-of-week"/>
				</xsl:when>
				<xsl:otherwise>7</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="start-day" select="($days - $dow + 7) mod 7"/>
		<xsl:variable name="week-number" select="floor(($days - $dow + 7) div 7)"/>
		<xsl:choose>
			<xsl:when test="$start-day &gt;= 4">
				<xsl:value-of select="$week-number + 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="not($week-number)">
						<xsl:call-template name="date:_week-in-year">
							<xsl:with-param name="days" select="365 + ((not($y-1 mod 4) and $y-1 mod 100) or not($y-1 mod 400))"/>
							<xsl:with-param name="year" select="$y-1"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$week-number"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
<!-- ========================= END OF STYLESHEET ========================= -->
</xsl:stylesheet>
