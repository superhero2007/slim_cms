<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:variable name="report" select="/config/plugin[@plugin='checklist'][@method='loadEntry']/report" />

    <!-- //Details -->
    <xsl:template match="vivid-sydney-2017-details" mode="html">
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-black padding-25">
                    <div class="row">
                        <div class="col-md-6">
                            <img class="img-responsive" src="/images/vivid-sydney-white.png" />
                        </div>
                        <div class="col-md-6">
                            <div class="row">
                                <div class="col-md-12">
                                    <h1 class="pull-right large-callout">
                                        <span class="countto-timer" data-from="0" data-to="2017" data-speed="2000"></span>
                                    </h1>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <h2 class="pull-right">
                                        <xsl:value-of select="$report/questionAnswer/answer[@answer_id = '37731']/@arbitrary_value" />
                                    </h2>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <h5 class="pull-right">
                                        <xsl:if test="$report/questionAnswer[@question_id ='15459']/answer/@answer_string != ''">
                                            <xsl:value-of select="$report/questionAnswer[@question_id ='15459']/answer/@answer_string" />
                                            <xsl:text> &amp; </xsl:text>
                                        </xsl:if>
                                        <xsl:if test="$report/questionAnswer[@question_id ='15505']/answer/@answer_string != ''">
                                            <xsl:value-of select="$report/questionAnswer[@question_id ='15505']/answer/@answer_string" />
                                        </xsl:if>
                                    </h5>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>

    <!-- //Environment -->
    <xsl:template match="vivid-sydney-2017-environment" mode="html">

        <div class="row">
            <xsl:if test="$report/questionAnswer/answer[@answer_id = '38324']">
                <div class="col-md-12">
                    <div class="row-fluid">
                        <div class="col-md-12 wp-block no-space arrow-down danger no-margin">
                            <div class="wp-block-body">
                                <h5>
                                    <span class="pull-left">Generator</span>
                                    <span class="fa fa-tint pull-right" />
                                </h5>
                            </div>
                        </div>
                        <div class="col-md-12 wp-block no-space light">
                            <div class="wp-block-body">
                                <div class="animated flipInX">
                                    <xsl:call-template name="vivid-sydney-2017-environment-generator" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </xsl:if>

            <xsl:if test="$report/questionAnswer/answer[@answer_id = '38328']">
                <div class="col-md-12">
                    <div class="row-fluid">
                        <div class="col-md-12 wp-block no-space arrow-down warning no-margin">
                            <div class="wp-block-body">
                                <h5>
                                    <span class="pull-left">Electricity</span>
                                    <span class="fa fa-bolt pull-right" />
                                </h5>
                            </div>
                        </div>
                        <div class="col-md-12 wp-block no-space light">
                            <div class="wp-block-body">
                                <div class="animated flipInX">
                                    <xsl:call-template name="vivid-sydney-2017-environment-electricity" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </xsl:if>

            <xsl:if test="$report/questionAnswer/answer[@answer_id = '37856']">
                <div class="col-md-12">
                    <div class="row-fluid">
                        <div class="col-md-12 wp-block no-space arrow-down success no-margin">
                            <div class="wp-block-body">
                                <h5>
                                    <span class="pull-left">Waste</span>
                                    <span class="fa fa-trash pull-right" />
                                </h5>
                            </div>
                        </div>
                        <div class="col-md-12 wp-block no-space light">
                            <div class="wp-block-body">
                                <div class="animated flipInX">
                                    <xsl:call-template name="vivid-sydney-2017-environment-waste" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </xsl:if>

            <xsl:if test="count($report/emission) &gt; 0">
                <div class="col-md-12">
                    <div class="row-fluid">
                        <div class="col-md-12 wp-block no-space arrow-down primary no-margin">
                            <div class="wp-block-body">
                                <h5>
                                    <span class="pull-left">Emissions</span>
                                    <span class="fa fa-leaf pull-right" />
                                </h5>
                            </div>
                        </div>
                        <div class="col-md-12 wp-block no-space light">
                            <div class="wp-block-body">
                                <div class="animated flipInX">
                                    <xsl:call-template name="vivid-sydney-2017-environment-ghg" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </xsl:if>

            <xsl:if test="count($report/questionAnswer[@page_section_id='115']) &gt; 0">
                <div class="col-md-12">
                    <div class="row-fluid">
                        <div class="col-md-12 wp-block no-space arrow-down info no-margin">
                            <div class="wp-block-body">
                                <h5>
                                    <span class="pull-left">Social</span>
                                    <span class="fa fa-group pull-right" />
                                </h5>
                            </div>
                        </div>
                        <div class="col-md-12 wp-block no-space light">
                            <div class="wp-block-body">
                                <div class="animated flipInX">
                                    <xsl:call-template name="vivid-sydney-2017-social" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </xsl:if>

        </div>

    </xsl:template>

    <!-- //Emissions -->
    <xsl:template name="vivid-sydney-2017-environment-ghg">

        <!-- //Output -->
        <div class="row">
            <div class="col-md-6">
                <xsl:for-each select="$report/emission">
                    <div class="row data-row">
                        <div class="col-xs-6">
                            <xsl:value-of select="@type" />
                        </div>
                        <div class="col-xs-6 text-right">
                            <span class="countto-timer" data-from="0" data-to="{@value}" data-speed="2000" data-custom-formatter="comma"></span>
                            <xsl:text> kg C02-e</xsl:text>
                        </div>
                    </div>
                </xsl:for-each>
                <div class="row data-row total font-weight-700">
                    <div class="col-xs-6">Total</div>
                    <div class="col-xs-6 text-right">
                        <xsl:variable name="total" select="sum($report/emission[@value &gt; 0]/@value)" />
                        <span class="countto-timer" data-from="0" data-to="{$total}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> kg C02-e</xsl:text>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6 text-center">
                <canvas class="chart-js static" width="400" height="200" data-type="doughnut" data-modifier="abs">
                    <xsl:attribute name="data-labels">[
                        <xsl:for-each select="$report/emission">
                            "<xsl:value-of select="@type" />"
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>
                    ]</xsl:attribute>
                    <xsl:attribute name="data-data">[
                        <xsl:for-each select="$report/emission">
                            "<xsl:value-of select="format-number(@value, '#.00')" />"
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>
                    ]</xsl:attribute>
                </canvas>
            </div>
            <div class="col-md-12">

                <div class="row">
                    <div class="col-md-12">
                        <a href="#emission-help-text" data-toggle="collapse" class="pull-right">
                            <i class="fa fa-question-circle" />
                        </a>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <div id="emission-help-text" class="collapse">
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
        </div>

    </xsl:template>

    <!-- //Environment - Generator -->
    <xsl:template name="vivid-sydney-2017-environment-generator">

        <!-- //Petrol -->
        <xsl:variable name="petrol">
            <xsl:choose>    
                <xsl:when test="$report/questionAnswer[@question_id = '15549']/answer/@answer_string = 'kL'">
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38324']/@arbitrary_value) * 1000" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38324']/@arbitrary_value)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- //Diesel -->
        <xsl:variable name="diesel">
            <xsl:choose>    
                <xsl:when test="$report/questionAnswer[@question_id = '15560']/answer/@answer_string = 'kL'">
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38325']/@arbitrary_value) * 1000" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38325']/@arbitrary_value)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- //LPG -->
        <xsl:variable name="lpg">
            <xsl:choose>    
                <xsl:when test="$report/questionAnswer[@question_id = '15565']/answer/@answer_string = 'kL'">
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38326']/@arbitrary_value) * 1000" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38326']/@arbitrary_value)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- //LNG -->
        <xsl:variable name="lng">
            <xsl:choose>    
                <xsl:when test="$report/questionAnswer[@question_id = '15570']/answer/@answer_string = 'kL'">
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38327']/@arbitrary_value) * 1000" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38327']/@arbitrary_value)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- //Output -->
        <div class="row">
            <div class="col-md-6">
                <div class="row data-row">
                    <div class="col-xs-6">Petrol</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$petrol}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> L</xsl:text>
                    </div>
                </div>
                <div class="row data-row">
                    <div class="col-xs-6">Diesel</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$diesel}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> L</xsl:text>
                    </div>
                </div>
                <div class="row data-row">
                    <div class="col-xs-6">LPG</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$lpg}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> L</xsl:text>
                    </div>
                </div>
                <div class="row data-row">
                    <div class="col-xs-6">LNG</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$lng}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> L</xsl:text>
                    </div>
                </div>
                <div class="row data-row total font-weight-700">
                    <div class="col-xs-6">Total</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$petrol + $diesel + $lpg + $lng}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> L</xsl:text>
                    </div>
                </div>
            </div>
            <div class="col-md-6 text-center">
                <canvas class="chart-js static" width="500" height="200" data-type="doughnut">
                    <xsl:attribute name="data-labels">["Petrol", "Diesel", "LPG", "LNG"]</xsl:attribute>
                    <xsl:attribute name="data-data">[<xsl:value-of select="$petrol" />, <xsl:value-of select="$diesel" />, <xsl:value-of select="$lpg" />, <xsl:value-of select="$lng" />]</xsl:attribute>
                </canvas>
            </div>
        </div>

    </xsl:template>


    <!-- //Environment - Electricity -->
    <xsl:template name="vivid-sydney-2017-environment-electricity">

        <!-- //Electricity -->
        <xsl:variable name="electricity">
            <xsl:choose>    
                <xsl:when test="$report/questionAnswer[@question_id = '15538']/answer/@answer_string = 'GJ'">
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38449']/@arbitrary_value) * 277.77" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38449']/@arbitrary_value)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- //Green Power Percent -->
        <xsl:variable name="green-power">
            <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38384']/@arbitrary_value) div 100" />
        </xsl:variable>

        <!-- //Output -->
        <div class="row">
            <div class="col-md-6">
                <div class="row data-row">
                    <div class="col-xs-6">Electricity</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$electricity * (1 - $green-power)}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> kWh</xsl:text>
                    </div>
                </div>
                <div class="row data-row">
                    <div class="col-xs-6">GreenPower</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$electricity * $green-power}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> kWh</xsl:text>
                    </div>
                </div>
                <div class="row data-row total font-weight-700">
                    <div class="col-xs-6">Total</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$electricity}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> kWh</xsl:text>
                    </div>
                </div>
            </div>
            <div class="col-md-6 text-center">
                <canvas class="chart-js static" width="500" height="200" data-type="doughnut">
                    <xsl:attribute name="data-labels">["Electricity", "GreenPower"]</xsl:attribute>
                    <xsl:attribute name="data-data">[<xsl:value-of select="$electricity * (1 - $green-power)" />, <xsl:value-of select="$electricity * $green-power" />]</xsl:attribute>
                </canvas>
            </div>
        </div>

    </xsl:template>

    <!-- //Environment - Waste -->
    <xsl:template name="vivid-sydney-2017-environment-waste">

        <!-- //General Waste -->
        <xsl:variable name="general-waste">
            <xsl:choose>    
                <xsl:when test="$report/questionAnswer[@question_id = '15512']/answer/@answer_string = 'Tonnes'">
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38385']/@arbitrary_value) * 1000" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38385']/@arbitrary_value)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- //Commingled -->
        <xsl:variable name="commingled">
            <xsl:choose>    
                <xsl:when test="$report/questionAnswer[@question_id = '15517']/answer/@answer_string = 'Tonnes'">
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38386']/@arbitrary_value) * 1000" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38386']/@arbitrary_value)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- //Paper and Cardboard -->
        <xsl:variable name="paper-and-cardboard">
            <xsl:choose>    
                <xsl:when test="$report/questionAnswer[@question_id = '15521']/answer/@answer_string = 'Tonnes'">
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38387']/@arbitrary_value) * 1000" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38387']/@arbitrary_value)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- //Organic -->
        <xsl:variable name="organic">
            <xsl:choose>    
                <xsl:when test="$report/questionAnswer[@question_id = '15525']/answer/@answer_string = 'Tonnes'">
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38388']/@arbitrary_value) * 1000" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="sum($report/questionAnswer/answer[@answer_id = '38388']/@arbitrary_value)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- //Output -->
        <div class="row">
            <div class="col-md-6">
                <div class="row data-row">
                    <div class="col-xs-6">General Waste</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$general-waste}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> kg</xsl:text>
                    </div>
                </div>
                <div class="row data-row">
                    <div class="col-xs-6">Commingled</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$commingled}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> kg</xsl:text>
                    </div>
                </div>
                <div class="row data-row">
                    <div class="col-xs-6">Paper &amp; Cardboard</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$paper-and-cardboard}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> kg</xsl:text>
                    </div>
                </div>
                <div class="row data-row">
                    <div class="col-xs-6">Organic</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$organic}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> kg</xsl:text>
                    </div>
                </div>
                <div class="row data-row total font-weight-700">
                    <div class="col-xs-6">Total</div>
                    <div class="col-xs-6 text-right">
                        <span class="countto-timer" data-from="0" data-to="{$general-waste + $commingled + $paper-and-cardboard + $organic}" data-speed="2000" data-custom-formatter="comma"></span>
                        <xsl:text> kg</xsl:text>
                    </div>
                </div>
            </div>
            <div class="col-md-6 text-center">
                <canvas class="chart-js static" width="500" height="200" data-type="doughnut">
                    <xsl:attribute name="data-labels">["General Waste", "Commingled", "Paper &amp; Cardboard", "Organic"]</xsl:attribute>
                    <xsl:attribute name="data-data">[<xsl:value-of select="$general-waste" />, <xsl:value-of select="$commingled" />, <xsl:value-of select="$paper-and-cardboard" />, <xsl:value-of select="$organic" />]</xsl:attribute>
                </canvas>
            </div>
        </div>

    </xsl:template>

    <!-- //Social -->
    <xsl:template name="vivid-sydney-2017-social">
        <xsl:for-each select="$report/checklistPage[@page_section_id = '115']">
            <xsl:sort select="@sequence" data-type="number" />
            <xsl:if test="count($report/questionAnswer[@page_id = current()/@page_id]) &gt; 0">
                <div class="report page">
                    <div class="row">
                        <div class="col-md-12">
                            <h5 class="report page-title">
                                <xsl:value-of select="@title" />
                            </h5>
                        </div>
                    </div>
                    <xsl:for-each select="$report/questionAnswer[@page_id = current()/@page_id]">
                        <xsl:sort select="@sequence" data-type="number" />
                        <div class="row">
                            <div class="col-md-12">
                                <p class="report question">
                                    <xsl:value-of select="@question" />
                                </p>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12">
                                <xsl:for-each select="answer">
                                    <xsl:sort select="@answer_sequence" data-type="number" />
                                    <p class="report answer">
                                        <xsl:choose>
                                            <xsl:when test="@answer_type = 'text'">
                                                <xsl:value-of select="@arbitrary_value" />
                                            </xsl:when>
                                            <xsl:when test="@answer_type = 'email'">
                                                <xsl:value-of select="@arbitrary_value" />
                                            </xsl:when>
                                            <xsl:when test="@answer_type = 'float'">
                                                <xsl:value-of select="@arbitrary_value" />
                                            </xsl:when>
                                            <xsl:when test="@answer_type = 'textarea'">
                                                <xsl:value-of select="@arbitrary_value" />
                                            </xsl:when>
                                            <xsl:when test="@answer_type = 'percent'">
                                                <xsl:value-of select="@arbitrary_value" />%
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="@answer_string" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </p>
                                </xsl:for-each>
                            </div>
                        </div>
                    </xsl:for-each>
                    <hr />
                </div>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>