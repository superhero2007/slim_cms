<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:variable name="vs-report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

    <!-- //Vivid Sydney Plugin -->
    <!-- //Environment Charts -->
    <xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='vividSydney'][@mode='environment-charts']">

        <div id="reportForm">
            <div class="row">
                <!-- //Generator -->
                <xsl:call-template name="consumption-details">
                    <xsl:with-param name="category" select="'Generator'" />
                    <xsl:with-param name="color" select="'danger'" />
                </xsl:call-template>

                <!-- //Electricity -->
                <xsl:call-template name="consumption-details">
                    <xsl:with-param name="category" select="'Electricity'" />
                    <xsl:with-param name="color" select="'warning'" />
                </xsl:call-template>

                <!-- //Waste -->
                <xsl:call-template name="consumption-details">
                    <xsl:with-param name="category" select="'Waste'" />
                    <xsl:with-param name="color" select="'success'" />
                </xsl:call-template>

                <!-- //Emissions -->
                <xsl:call-template name="consumption-details">
                    <xsl:with-param name="category" select="'Emissions'" />
                    <xsl:with-param name="color" select="'primary'" />
                </xsl:call-template>
            </div>
        </div>

    </xsl:template>

    <!-- //Environment - Generator -->
    <xsl:template name="consumption-details">
        <xsl:param name="category" />
        <xsl:param name="color" />

       <div class="col-md-12 environment-panel">
            <div class="row-fluid">
                <div class="col-md-12 wp-block no-space arrow-down {$color} no-margin">
                    <div class="wp-block-body">
                        <h5>
                            <span class="pull-left">
                                <xsl:value-of select="$category" />
                            </span>
                            <span class="fa fa-tint pull-right" />
                        </h5>
                    </div>
                </div>
                <div class="col-md-12 wp-block no-space light">
                    <div class="wp-block-body">
                        <div class="animated flipInX">
                            <div class="row">
                                <div class="col-md-6">
                                    <xsl:for-each select="resource[@category=$category]">
                                        <xsl:variable name="resource_name" select="@name" />

                                        <!-- //Summary -->
                                        <div class="row data-row">
                                            <div class="col-xs-6 font-weight-700">
                                                <xsl:choose>
                                                    <xsl:when test="/config/plugin[@plugin='dashboardContent'][@method='loadContent']/client_checklist">
                                                        <xsl:value-of select="@name" />
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <a href=".{$category}-{position()}" data-toggle="collapse">
                                                            <span data-toggle="tooltip" title="Click to show/hide detail">
                                                                <xsl:value-of select="@name" />
                                                            </span>
                                                        </a>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </div>
                                            <div class="col-xs-6 text-right font-weight-700">
                                                <div class="{$category}-{position()} collapse in">
                                                    <span class="countto-timer" data-from="0" data-to="{sum(consumption/@value)}" data-speed="2000" data-custom-formatter="comma" data-decimals="2"></span>
                                                    <xsl:value-of select="concat(' ', @unit)" />
                                                </div>
                                            </div>
                                        </div>

                                        <!-- //Detail -->
                                        <!--
                                        <div class="{$category}-{position()} collapse padding-left-20">                            
                                            <xsl:for-each select="consumption[@value &lt; -1 or @value &gt; 1]">
                                                <xsl:sort select="@value" data-type="number" order="descending" />
                                                <div class="row data-row">   
                                                    <div class="col-xs-6">
                                                        <a href="/members/dashboard/entry/view/?client_id={@client_id}&amp;client_checklist_id={@client_checklist_id}" data-toggle="tooltip" title="Click to drill down into this activation.">
                                                            <xsl:value-of select="@company_name" />
                                                        </a>
                                                    </div>
                                                    <div class="col-xs-6 text-right">
                                                        <span class="countto-timer" data-from="0" data-to="{@value}" data-speed="2000" data-custom-formatter="comma"></span>
                                                        <xsl:value-of select="concat(' ', ../@unit)" />
                                                    </div>
                                                </div>
                                            </xsl:for-each>
                                            <div class="row data-row">   
                                                <div class="col-xs-6 font-weight-700">
                                                    Total <xsl:value-of select="@name" />
                                                </div>
                                                <div class="col-xs-6 text-right font-weight-700">
                                                    <span class="countto-timer" data-from="0" data-to="{sum(consumption/@value)}" data-speed="2000" data-custom-formatter="comma"></span>
                                                    <xsl:value-of select="concat(' ', @unit)" />
                                                </div>
                                            </div>
                                        </div>
                                        -->

                                        <div class="{$category}-{position()} collapse padding-left-20">
                                            <xsl:for-each select="../precincts/precinct">
                                                <xsl:variable name="precinct_id" select="@precinct_id" />
                                                <xsl:if test="count(../../resource[@category=$category][@name=$resource_name]/consumption[@precinct_id=$precinct_id][@value != '0']) &gt; 0">
                                                    <div class="row data-row">   
                                                        <div class="col-xs-12 font-weight-700">
                                                            <xsl:value-of select="@precinct" />
                                                        </div>
                                                    </div>
                                                    <div class="padding-left-20">
                                                        <xsl:for-each select="../../resource[@category=$category][@name=$resource_name]/consumption[@precinct_id=$precinct_id][@value != '0']">
                                                            <xsl:sort select="@company_name" data-type="text" />
                                                            <div class="row data-row">   
                                                                <div class="col-xs-6">
                                                                    <a href="/members/dashboard/entry/view/?client_id={@client_id}&amp;client_checklist_id={@client_checklist_id}" data-toggle="tooltip" title="Click to drill down into this activation.">
                                                                        <xsl:value-of select="@company_name" />
                                                                    </a>
                                                                </div>
                                                                <div class="col-xs-6 text-right">
                                                                    <span class="countto-timer" data-from="0" data-to="{@value}" data-speed="2000" data-custom-formatter="comma" data-decimals="2"></span>
                                                                    <xsl:value-of select="concat(' ', ../@unit)" />
                                                                </div>
                                                            </div>
                                                        </xsl:for-each>
                                                        
                                                        <!-- //Precinct Total -->
                                                        <div class="row data-row total">   
                                                            <div class="col-xs-6">
                                                                Total
                                                            </div>
                                                            <div class="col-xs-6 text-right">
                                                                <span class="countto-timer" data-from="0" data-to="{sum(../../resource[@category=$category][@name=$resource_name]/consumption[@precinct_id=$precinct_id]/@value)}" data-speed="2000" data-custom-formatter="comma" data-decimals="2"></span>
                                                                <xsl:value-of select="concat(' ',../../resource[@category=$category][@name=$resource_name]/@unit)" />
                                                            </div>
                                                        </div>

                                                    </div>
                                                </xsl:if>
                                            </xsl:for-each>

                                            <!-- //Resource Total -->
                                            <div class="row data-row total">   
                                                <div class="col-xs-6 font-weight-700">
                                                    Total <xsl:value-of select="$resource_name" />
                                                </div>
                                                <div class="col-xs-6 text-right font-weight-700">
                                                    <span class="countto-timer" data-from="0" data-to="{sum(consumption/@value)}" data-speed="2000" data-custom-formatter="comma" data-decimals="2"></span>
                                                    <xsl:value-of select="concat(' ',@unit)" />
                                                </div>
                                            </div>
                                        </div>                          

                                    </xsl:for-each>
                                   <div class="row data-row total font-weight-700">
                                        <div class="col-xs-6">Total <xsl:value-of select="$category" /></div>
                                        <div class="col-xs-6 text-right">
                                            <span class="countto-timer" data-from="0" data-to="{sum(resource[@category=$category]/consumption[@value &gt; 0]/@value)}" data-speed="2000" data-custom-formatter="comma"></span>
                                            <xsl:value-of select="concat(' ', resource[@category=$category]/@unit)" />
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-6 text-center">
                                    <canvas class="chart-js static" width="500" height="200" data-type="doughnut">
                                        <xsl:attribute name="data-labels">
                                            <xsl:text>[</xsl:text>
                                            <xsl:for-each select="resource[@category=$category]">
                                                <xsl:text>"</xsl:text><xsl:value-of select="@name" /><xsl:text>"</xsl:text>
                                                <xsl:if test="position() != last()">,</xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>]</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="data-data">
                                            <xsl:text>[</xsl:text>
                                            <xsl:for-each select="resource[@category=$category]">
                                                <xsl:text>"</xsl:text><xsl:value-of select="format-number(sum(consumption/@value),'#.##')" /><xsl:text>"</xsl:text>
                                                <xsl:if test="position() != last()">,</xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>]</xsl:text>   
                                        </xsl:attribute>
                                    </canvas>
                                </div>
                            </div>

                            <!-- //Help Content -->
                            <xsl:if test="$category = 'Emissions'">
                                <div class="col-md-12">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <a href="#emissions-help-text" data-toggle="collapse" class="pull-right">
                                                <i class="fa fa-question-circle" />
                                            </a>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <div id="emissions-help-text" class="collapse">
                                                <hr />
                                                <p class="summary-text">Note: the absolute value of the Commingled data is represented in the graph above.</p>
                                                <p class="summary-text">The following conversion factors were used in the CO2e calculations:</p>
                                                <ul class="summary-text">
                                                    <li>Landfill: 2.5060983 kgCO2e/kg (Category: Waste treatment, municipal waste average, at landfill/AU)</li>
                                                    <li>Paper and Cardboard 0.20136607 kgCO2e/kg (Category: Recycling paper &amp; board, kerbside/AU)</li>
                                                    <li>Organic 4.7306311 kgCO2e/kg (Category: Waste treatment, food, at landfill/AU) - Note: the organic waste is not composted, directed to wormfarms or similarly recycled</li>
                                                    <li>Commingled Recycling: -2.726936492 kgCO2e/kg (55% PET, 35% Glass, 5% HDPE, 5% Aluminium (by weight))
                                                        <ul>
                                                            <li>Glass: -0.485500105 kgCO2e/kg derived from 50 / 50:
                                                                <ul>
                                                                    <li>Recycling glass, 30% cullet/AU: -0.41595985 kgCO2e/kg</li>
                                                                    <li>Recycling glass, 0% cullet/AU: -0.55504036 kgCO2e/kg</li>
                                                                </ul>
                                                            </li>
                                                            <li>HDPE: -2.2572242 kgCO2e/kg (Recycling HDPE/AU)</li>
                                                            <li>PET: -2.7633569 kgCO2e/kg (Recycling PET/AU)</li>
                                                            <li>Aluminium/AU: -18.486079 kgCO2e/kg (Recycling aluminium AU)</li>
                                                        </ul>
                                                    </li>
                                                </ul>
                                                <p class="summary-text">Source: Australian National Life Cycle Inventory Database (AusLCI)</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </xsl:if>

                        </div>
                    </div>
                </div>
            </div>
        </div>

    </xsl:template>


    <!-- //Facts -->
    <xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='vividSydney'][@mode='facts']">
        <xsl:choose>
            <xsl:when test="@display = 'facts'">
                <xsl:call-template name="vivid-sydney-facts" />
            </xsl:when>
            <xsl:when test="@display = 'activation-facts'">
                <xsl:call-template name="vivid-sydney-activation-facts" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="vivid-sydney-facts" />
                <xsl:call-template name="vivid-sydney-activation-facts" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="vivid-sydney-facts">
        <xsl:variable name="total-emissions" select="sum(/config/pugin[@plugin = 'dashboardContent'][@method = 'vividSydney'][@mode='environment-charts']/emission/@value)" />
        
        <!-- //Row 1 -->
        <div class="row">
            <div class="col-lg-4 col-md-6">

                <div class="panel bg-success">
                    <div class="panel-heading">
                        <div class="row">
                            <div class="col-xs-3">
                                <i class="fa fa-user fa-4x"></i>
                            </div>
                            <div class="col-xs-9 text-right">
                                <div class="h1 m0">
                                    <span class="countto-timer" data-from="0" data-to="2330000" data-speed="2000" data-custom-formatter="comma"></span>
                                </div>
                                <div class="">Attendees</div>
                            </div>
                        </div>
                    </div>
                    <div class="panel-footer bg-success-dark bt0 text-right">
                        <span class="countto-timer" data-from="0" data-to="{fact[@key='emissions-per-visitor']/@value}" data-speed="2000" data-custom-formatter="decimal" data-decimals="3"></span> kg CO2-e / visitor
                    </div>
                </div>
            </div>
            <div class="col-lg-4 col-md-6">
                <div class="panel bg-warning">
                    <div class="panel-heading">
                        <div class="row">
                            <div class="col-xs-3">
                                <i class="fa fa-usd fa-4x"></i>
                            </div>
                            <div class="col-xs-9 text-right">
                                <div class="h1 m0">
                                    <span class="countto-timer" data-from="0" data-to="143000000" data-speed="2000" data-custom-formatter="comma"></span>
                                </div>
                                <div class="">Dollars into NSW economy</div>
                            </div>
                        </div>
                    </div>
                    <div class="panel-footer bg-warning-dark bt0 text-right">
                        $<span class="countto-timer" data-from="0" data-to="{fact[@key='dollars-per-visitor']/@value}" data-speed="2000" data-custom-formatter="decimal" data-decimals="2"></span> / visitor
                    </div>
                </div>
            </div>
            <div class="col-lg-4 col-md-12">
                <div class="panel bg-danger">
                    <div class="panel-heading">
                        <div class="row">
                            <div class="col-xs-3">
                                <i class="fa fa-paint-brush fa-4x"></i>
                            </div>
                            <div class="col-xs-9 text-right">
                                <div class="h1 m0">
                                    <span class="countto-timer" data-from="0" data-to="185" data-speed="2000" data-custom-formatter="comma"></span>
                                </div>
                                <div class="">Artists</div>
                            </div>
                        </div>
                    </div>
                    <div class="panel-footer bg-danger-dark bt0 text-right">
                        <span class="countto-timer" data-from="0" data-to="{fact[@key='emissions-per-artist']/@value}" data-speed="2000" data-custom-formatter="comma" data-decimals="2"></span> kg CO2-e / artist
                    </div>
                </div>
            </div>
        </div>
   
    </xsl:template>

    <xsl:template name="vivid-sydney-activation-facts">
        <xsl:variable name="total-emissions" select="sum(/config/pugin[@plugin = 'dashboardContent'][@method = 'vividSydney'][@mode='environment-charts']/emission/@value)" />

       <div class="row">
            <div class="col-lg-4 col-md-6">

                <div class="panel bg-info">
                    <div class="panel-heading">
                        <div class="row">
                            <div class="col-xs-3">
                                <i class="fa fa-check-circle-o fa-4x"></i>
                            </div>
                            <div class="col-xs-9 text-right">
                                <div class="h1 m0">
                                    <span class="countto-timer" data-from="0" data-to="{fact[@key='activations']/@value}" data-speed="2000" data-custom-formatter="comma"></span>
                                </div>
                                <div class="">Activations</div>
                            </div>
                        </div>
                    </div>
                    <div class="panel-footer bg-info-dark bt0 text-right">
                        <span class="countto-timer" data-from="0" data-to="{fact[@key='activations']/@emission-value}" data-speed="2000" data-custom-formatter="decimal" data-decimals="3"></span> kg CO2-e / activation
                    </div>
                </div>
            </div>
            <div class="col-lg-4 col-md-6">
                <div class="panel bg-green">
                    <div class="panel-heading">
                        <div class="row">
                            <div class="col-xs-3">
                                <i class="fa fa-clock-o fa-4x"></i>
                            </div>
                            <div class="col-xs-9 text-right">
                                <div class="h1 m0">
                                    <span class="countto-timer" data-from="0" data-to="{fact[@key='activated-hours']/@value}" data-speed="2000" data-custom-formatter="comma"></span>
                                </div>
                                <div class="">Activated Hours</div>
                            </div>
                        </div>
                    </div>
                    <div class="panel-footer bg-green-dark bt0 text-right">
                        <span class="countto-timer" data-from="0" data-to="{fact[@key='activated-hours']/@emission-value}" data-speed="2000" data-custom-formatter="decimal" data-decimals="3"></span> kg CO2-e / activated hour
                    </div>
                </div>
            </div>
            <div class="col-lg-4 col-md-12">
                <div class="panel bg-purple">
                    <div class="panel-heading">
                        <div class="row">
                            <div class="col-xs-3">
                                <i class="fa fa-map-marker fa-4x"></i>
                            </div>
                            <div class="col-xs-9 text-right">
                                <div class="h1 m0">
                                    <span class="countto-timer" data-from="0" data-to="{fact[@key='area']/@value}" data-speed="2000" data-custom-formatter="comma"></span>
                                </div>
                                <div class="">Activated Area</div>
                            </div>
                        </div>
                    </div>
                    <div class="panel-footer bg-purple-dark bt0 text-right">
                        <span class="countto-timer" data-from="0" data-to="{fact[@key='area']/@emission-value}" data-speed="2000" data-custom-formatter="comma" data-decimals="2"></span> kg CO2-e / activated area (m2)
                    </div>
                </div>
            </div>
        </div>        
    </xsl:template>

</xsl:stylesheet>