<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:exsl="http://exslt.org/common"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-extension-prefixes="exsl">

	<xsl:template name="menu">
		<h1>Analytics</h1>
	</xsl:template>
	
	<xsl:template match="config">
        
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=analytics">Analytics</a>
		</p>
        
		<xsl:call-template name="customReports" />
		<br /><hr /><br />
		<xsl:call-template name="standardReports" />
		
	</xsl:template>
	
	<xsl:template name="customReports">
	
    	<!-- //Get the variables for the checklist and questions -->
        <xsl:variable name="checklist_id" select="/config/globals/item[@key = 'checklist_id']/@value" />
        <xsl:variable name="question_id" select="/config/globals/item[@key = 'question_id']/@value" />
	
        <!-- //Custom Reports -->
        <h1>Custom Reports and Statistics</h1>
        <p><strong>Instructions:</strong><br />Select the desired checklist and associated questions to return a breakdown of client answers.</p>
		
		<form method="get" action="?page=analytics">
			<input type="hidden" name="action" value="query" />
			<input type="hidden" name="page" value="analytics" />
			<fieldset>
				<legend>Build your analytical query</legend>
                <table class="editTable">
                	<tbody>
                        <tr>
                            <th scope="row">Checklist:</th>
                            <td>
                                <!-- //Select Checklist -->
                                <select name="checklist_id">
                                	<option value="0">-- Select --</option>
                                    <xsl:for-each select="/config/checklist">
                                        <xsl:if test="@name != ''">
                                            <option value="{@checklist_id}">
												<xsl:if test="@checklist_id = $checklist_id">
                                                    <xsl:attribute name="selected">
                                                        <xsl:text>selected</xsl:text>
                                                    </xsl:attribute>
                                                </xsl:if>
                                                <xsl:value-of select="@name" />
                                            </option>
                                        </xsl:if>
                                    </xsl:for-each>
                                </select>
                            </td>
                        </tr>
                        
                        <!-- //If the checklist_id is set then get the report sections and questions -->
                        <xsl:if test="$checklist_id &gt; 0">
                            <tr>
                                <th scope="row">Question:</th>
                                <td>
                                    <!-- //Select Checklist -->
                                    <select name="question_id" style="width:100%">
                                        <option value="0">-- Select --</option>
                                        <xsl:for-each select="/config/page">
                                        	<xsl:sort select="@sequence" />
                                            <xsl:if test="(@title != '') and (count(/config/question[@page_id = current()/@page_id]) &gt; 0)">
                                                <optgroup label="{@title}">
                                                	<xsl:for-each select="/config/question[@page_id = current()/@page_id]">
                                                    	<xsl:sort select="@sequence" /> 
                                                        <option value="{@question_id}">
                                                        	<xsl:if test="@question_id = $question_id">
                                                                <xsl:attribute name="selected">
                                                                    <xsl:text>selected</xsl:text>
                                                                </xsl:attribute>
                                                            </xsl:if>
                                                            <xsl:value-of select="concat(@question_id, ' - ', @question)" />
                                                        </option>
                                                	</xsl:for-each>
                                                </optgroup>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </select>
                                </td>
                            </tr>
                        </xsl:if>
                        
                	</tbody>
                </table>
                
                <input type="submit">
                	<!-- Decide on the button content -->
                    <xsl:attribute name="value">
                    	<xsl:choose>
                        	<xsl:when test="$checklist_id &gt; '0'">Get Analytics</xsl:when>
                            <xsl:otherwise>Get Questions</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </input>
                	
			</fieldset>
		</form>
		
		<!-- //We now have to show the results -->
        <xsl:if test="$question_id &gt; 0">
        	<br class="clear" /><br class="clear" />
            <fieldset>
                <legend>Your results</legend>
                        
                <!-- //Now get all of the possible answers -->
                <xsl:choose>
                
                    <!-- //answer_type = checkbox, checkbox-other -->
                    <xsl:when test="/config/answer[1][@answer_type = 'checkbox']">
                        <table class="editTable">
                            <tbody>
                                <tr>
                                    <th style="width:90%">Answer</th>
                                    <th>Count</th>
                                    <th>Percent</th>
                                </tr>
                                <xsl:for-each select="/config/answer">
                                    <tr>
                                        <td>
                                            <xsl:value-of select="@string" />
                                        </td>
                                        <td style="text-align:right">
                                            <xsl:value-of select="count(/config/client_result[@answer_id = current()/@answer_id])" />
                                        </td>
                                        <td style="text-align:right">
                                            <xsl:value-of select="format-number(count(/config/client_result[@answer_id = current()/@answer_id]) div count(/config/client_result), '#%')" />
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                        <p><i>Total client results: <xsl:value-of select="count(/config/client_result)" /></i></p>
                    </xsl:when>
                                        
                    <!-- //answer_type = int, float, range -->
                    <xsl:when test="/config/answer[1][@answer_type = 'range'] or /config/answer[1][@answer_type = 'int'] or /config/answer[1][@answer_type = 'float'] or /config/answer[1][@answer_type = 'percent']">
                    	
                        <!-- //Get the range min and range max -->
                        <xsl:variable name="range_min">
							<xsl:for-each select="/config/client_result">
                            	<xsl:sort select="@arbitrary_value" data-type="number" />
                                <xsl:if test="position()=1">
                                	<xsl:value-of select="@arbitrary_value" />
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        
                        <xsl:variable name="range_max">
							<xsl:for-each select="/config/client_result">
                            	<xsl:sort select="@arbitrary_value" data-type="number" />
                                <xsl:if test="position()=last()">
                                	<xsl:value-of select="@arbitrary_value" />
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
						
						<xsl:if test="/config/result_count/@band_bound &gt; 0">
						   <table class="editTable">
								<tbody>
									<tr>
										<th style="width:90%">Answer</th>
										<th>Count</th>
										<th>Percent</th>
									</tr>
									
									<!-- Loop through the results 10 times -->
									<xsl:call-template name="row-loop">
										<xsl:with-param name="counter" select="0" />
										<xsl:with-param name="bands" select="/config/result_count/@bands" />
										<xsl:with-param name="band_bound" select="/config/result_count/@band_bound" />
									</xsl:call-template>

								</tbody>
							</table>
						</xsl:if>
                        
                        <p><i>Lowest value: <xsl:value-of select="concat($range_min, /config/result_count/@character)" /></i></p>
                        <p><i>Highest value: <xsl:value-of select="concat($range_max, /config/result_count/@character)" /></i></p>
                        <p><i>Average value: <xsl:value-of select="concat(format-number(/config/result_count/@result_average,'#.##'), /config/result_count/@character)" /></i></p>
                        <p><i>Total client results: <xsl:value-of select="/config/result_count/@result_count" /></i></p>
                    </xsl:when>
                    
                    <!-- //answer_type = email, text, textarea, date, url -->
                    <xsl:otherwise>
                        <p>The question that you have selected does not have quantifiable answers.</p>
                    </xsl:otherwise>
                </xsl:choose>
            </fieldset>
        
        </xsl:if>
	</xsl:template>
	
	<xsl:template name="standardReports">
		<h1>Standard Reports</h1>
		
        <!-- //Allow date picker to set the date range of the report queries below -->

        <form method="get" action="?page=analytics">
            <input type="hidden" name="action" value="report" />
            <input type="hidden" name="page" value="analytics" />
            <fieldset>
                <legend>Select a date range for the reports below</legend>
                
                <p>
                    From: <input type="text" name="from" id="from-report-datepicker" value="{/config/globals/item[@key = 'from']/@value}" /> to: <input type="text" name="to" id="to-report-datepicker" value="{/config/globals/item[@key = 'to']/@value}" />
                    <xsl:text> </xsl:text>
                    <button id="set-report-dates">Set Dates</button>
                    <xsl:text> </xsl:text>
                    <button id="reset-report-dates">Reset Dates</button>
                </p>

                <xsl:choose>
                    <xsl:when test="/config/globals/item[@key = 'from']/@value !='' and /config/globals/item[@key = 'to']/@value != ''">
                        <p><i>Showing all results between <xsl:value-of select="/config/globals/item[@key = 'from']/@value" /> and <xsl:value-of select="/config/globals/item[@key = 'to']/@value" />.</i></p>
                    </xsl:when>
                    <xsl:when test="/config/globals/item[@key = 'from']/@value !=''">
                        <p><i>Showing all results after <xsl:value-of select="/config/globals/item[@key = 'from']/@value" />.</i></p>
                    </xsl:when>
                    <xsl:when test="/config/globals/item[@key = 'to']/@value !=''">
                        <p><i>Showing all results before <xsl:value-of select="/config/globals/item[@key = 'to']/@value" />.</i></p>
                    </xsl:when>
                    <xsl:otherwise>
                        <p><i>Showing all results.</i></p>
                    </xsl:otherwise>
                </xsl:choose>
            </fieldset>
        </form>

        <script>
            $(function() {
                $.datepicker.setDefaults($.datepicker.regional['en-AU']);
                $("#from-report-datepicker").datepicker({dateFormat: 'dd-mm-yy'});
                $("#to-report-datepicker").datepicker({dateFormat: 'dd-mm-yy'});

                $("#reset-report-dates").click(function() {
                    window.location.replace("?page=analytics");
                    return false;
                });
            });
        </script>


		<!--Checklist pivotTable Reports -->
		<p><strong>Checklist Pivot Table</strong></p>
		
        <!-- //Construct URL -->
        <xsl:variable name="report-dates">
            <xsl:choose>
                <xsl:when test="/config/globals/item[@key = 'from']/@value !='' and /config/globals/item[@key = 'to']/@value != ''">
                    <xsl:value-of select="concat('&amp;from=',/config/globals/item[@key = 'from']/@value,'&amp;to=',/config/globals/item[@key = 'to']/@value)" />
                </xsl:when>
                <xsl:when test="/config/globals/item[@key = 'from']/@value !=''">
                    <xsl:value-of select="concat('&amp;from=',/config/globals/item[@key = 'from']/@value)" />
                </xsl:when>
                <xsl:when test="/config/globals/item[@key = 'to']/@value !=''">
                    <xsl:value-of select="concat('&amp;to=',/config/globals/item[@key = 'to']/@value)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text></xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>    



		<ul>
			<xsl:for-each select="/config/checklist">
				<xsl:sort select="@name" />
				<li>
					<a href="index.php?page=analytics&amp;report=checklistPivotTableReport&amp;checklist_id={@checklist_id}{$report-dates}">
						<xsl:value-of select="@name" />
					</a>
				</li>
			</xsl:for-each>
		</ul>

        <!--Checklist pivotTable Reports -->
        <p><strong>Client Checklists</strong></p>
        
        <ul>
            <xsl:for-each select="/config/checklist">
                <xsl:sort select="@name" />
                <li>
                    <a href="index.php?page=analytics&amp;report=clientChecklistReport&amp;checklist_id={@checklist_id}{$report-dates}">
                        <xsl:value-of select="@name" />
                    </a>
                </li>
            </xsl:for-each>

            <!-- //Now one option to download all at once -->
            <li>
                <a href="index.php?page=analytics&amp;report=clientChecklistReport&amp;checklist_id=0{$report-dates}">All Checklists</a>
            </li>


        </ul>
		
	</xsl:template>
	
	<xsl:template name="row-loop">
		<xsl:param name="counter" />
		<xsl:param name="bands" />
		<xsl:param name="band_bound" />
		<!-- //The row content -->
		
		<tr>
			<td>
				<xsl:value-of select="concat(($band_bound*$counter), /config/result_count/@character)" />
				<xsl:choose>
					<xsl:when test="($counter+1) = $bands">
						<xsl:text>+</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> - </xsl:text>
						<xsl:value-of select="concat(($band_bound*($counter+1))-1, /config/result_count/@character)" />
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style="text-align:right">
				<xsl:choose>
					<xsl:when test="($counter+1) = $bands">
						<xsl:value-of select="count(/config/client_result[@arbitrary_value &gt; (($band_bound*$counter)-1)])" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count(/config/client_result[@arbitrary_value &lt; ($band_bound*($counter+1)+1) and @arbitrary_value &gt; (($band_bound*$counter)-1)])" />
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style="text-align:right">
				<xsl:choose>
					<xsl:when test="($counter+1) = $bands">
						<xsl:value-of select="format-number(count(/config/client_result[@arbitrary_value &gt; (($band_bound*$counter)-1)]) div count(/config/client_result), '#%')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(count(/config/client_result[@arbitrary_value &lt; ($band_bound*($counter+1)+1) and @arbitrary_value &gt; (($band_bound*$counter)-1)]) div count(/config/client_result), '#%')" />
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
		
		<!-- //End of the row content -->
		<xsl:variable name="next" select="$counter + 1" />
		<xsl:if test="$next &lt; $bands">
			<xsl:call-template name="row-loop">
				<xsl:with-param name="counter" select="$next" />
				<xsl:with-param name="bands" select="$bands" />
				<xsl:with-param name="band_bound" select="$band_bound" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>