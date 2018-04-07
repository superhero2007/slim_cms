<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<!--//The GHG Assessment Plugin -->
	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'GHGAssessment']">
		
		<!-- //Main line chart -->
		<section>
			<section class="slice white">
				<div class="container">
					<xsl:if test="count(/config/plugin[@plugin = 'checklist'][@method = 'GHGAssessment']/report) &gt; 0">
						<h3>Tonnes CO<sub>2</sub>e</h3>
						<xsl:call-template name="overall-line-chart" />
					</xsl:if>
					<xsl:call-template name="overall-number-counter" />
				</div>
			</section>
		</section>

		<xsl:choose>
			<xsl:when test="mode/@mode = 'report'">

				<section class="slice light-gray bb bt">
			        <div class="cta-wr">
			            <div class="container">
			                <div class="row">
			                    <div class="col-md-8">
			                    </div>
			                    <div class="col-md-4">
			                        <a href="?ghg-action=add-entry" class="btn btn-base btn-lg btn-icon btn-icon-right fa-plus pull-right">
			                            <span>Add Another Entry</span>
			                        </a>
			                    </div>
			                </div>
			            </div>
			        </div>
			    </section>

			</xsl:when>
			<xsl:when test="mode/@mode = 'checklist'">

				<section class="slice light-gray bb bt" id="ghg-assessment-container">
			        <div class="cta-wr">
			            <div class="container">
			                <div class="row">
			                    <div class="col-md-8">
			                        <h1 class="text-normal">
			                           Enter Your Data
			                        </h1>
			                    </div>
			                    <div class="col-md-4">
			                    	<i class="fa fa-database pull-right" style="font-size:50px;"></i>
			                    </div>
			                </div>
			            </div>
			        </div>
			    </section>

				<section class="slice white">
					<div class="container assessment ghg-assessment">
						<xsl:call-template name="assessment-content" />
					</div>
				</section>

				<section class="slice base">
			        <div class="cta-wr">
			            <div class="container">
			                <div class="row">
			                    <div class="col-md-8">
			                        <h1 class="text-normal">
			                           
			                        </h1>
			                    </div>
			                    <div class="col-md-4">
			                        <a href="#" id="submit-assessment" class="btn btn-b-white btn-lg btn-icon btn-icon-right fa-send pull-right">
			                            <span>Submit Entry</span>
			                        </a>
			                    </div>
			                </div>
			            </div>
			        </div>
			    </section>
<!--
			    <script>
					$(document).ready(function() {
						if($('p.error').length) {
							errorLocation = $('p.error').first().position().top;
							$('html, body').animate({scrollTop: errorLocation - 20}, 1000);
						} else {
							assessmentLocation = $('#ghg-assessment-container').position().top;
							$('html, body').animate({scrollTop: assessmentLocation - 20}, 1000);
						}

				    	$('#submit-assessment').click(function(e) {
				    		e.preventDefault();
				    		$('#single-page').val('true');
				    		$('#action').val('next');
				    		$('#checklist').submit();
				    	});	  

					});		  	
			    </script>	
-->
			</xsl:when>	
		</xsl:choose>

	</xsl:template>

	<xsl:template name="overall-number-counter">

		<xsl:variable name="number-of-reports" select="count(/config/plugin[@plugin = 'checklist'][@method = 'GHGAssessment']/report)" />

		<xsl:variable name="total-ghg">
			<xsl:choose>
				<xsl:when test="$number-of-reports &gt; 0">
					<xsl:value-of select="round(sum(/config/plugin[@plugin = 'checklist'][@method = 'GHGAssessment']/report/metricGroup/clientMetric[@ghg_calculation != 'ignore']/@ghg_calculation))" />
 				</xsl:when>
 				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="total-dollars">
			<xsl:choose>
				<xsl:when test="$number-of-reports &gt; 0">
					<xsl:value-of select="round(sum(/config/plugin[@plugin = 'checklist'][@method = 'GHGAssessment']/report/metricGroup/clientMetric[@description = 'dollars']/@value))" />
 				</xsl:when>
 				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		

		<section class="slice white">
	        <div class="wp-section">
	            <div class="container">
	                <div class="row">

	                	<div class="col-md-4">
							<div class="box-element base-alt">
	                            <div class="row">
	                                <div class="col-md-12">
	                                    <h1 class="pull-right large-callout">
	                                        <span class="countto-timer" data-from="0" data-to="{$number-of-reports}" data-speed="2000"></span>
	                                    </h1>
	                                    <p class="pull-right clear large-callout">Entries</p>
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
	                                    		<xsl:when test="$number-of-reports &gt; 0">
			                                        $<span class="countto-timer" data-from="0" data-to="{($total-dollars div $number-of-reports)}" data-speed="2000"></span>
	                                    		</xsl:when>
	                                    		<xsl:otherwise>
			                                        $<span class="countto-timer" data-from="0" data-to="0" data-speed="2000"></span>
	                                    		</xsl:otherwise>
	                                    	</xsl:choose>
	                                    </h1>
	                                    <p class="pull-right clear large-callout">Average Spend</p>
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
	                                    		<xsl:when test="$number-of-reports &gt; 0">
			                                        <span class="countto-timer" data-from="0" data-to="{($total-ghg div $number-of-reports)}" data-speed="2000"></span>
	                                    		</xsl:when>
	                                    		<xsl:otherwise>
			                                        <span class="countto-timer" data-from="0" data-to="0" data-speed="2000"></span>
	                                    		</xsl:otherwise>
	                                    	</xsl:choose>	                                    
	                                    </h1>
	                                    <p class="pull-right clear large-callout">Average Tonnes CO<sub>2</sub>e</p>
	                                </div>
	                            </div>
	                        </div>
                    	</div>	                    

	                </div>
	            </div>
	        </div>
	    </section>
	</xsl:template>

	<xsl:template name="overall-line-chart">
		
		<div class="ghg-line-chart" data-series="{/config/plugin[@plugin = 'checklist'][@method = 'GHGAssessment']/mode/@formattedData}">
			<canvas class="canvas" width="300px" height="100px"></canvas>
		</div>

	</xsl:template>
	
</xsl:stylesheet>