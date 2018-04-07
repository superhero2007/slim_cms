<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">

    <!-- //Ethical Sourcing Dashboard -->
     <xsl:template match="/config/plugin[@plugin = 'dashboards'][@method = 'davidJones']/dashboard[@group = 'ethical-sourcing']">
        <h1 style="color:red;">Ethical Sourcing Dashboard</h1>

        <!-- //User Name -->
        <xsl:call-template name="welcome-full-name" />
        <hr />

        <!-- //Action Buttons -->
        <div class="row">
            <div class="col-md-4">
                <a href="/members/add-vendor/" class="btn btn-success btn-block btn-icon fa-plus" role="button">
                    <span>Add Vendor</span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="/members/vendors/" class="btn btn-success btn-block btn-icon fa-pencil" role="button">
                    <span>Edit Vendor</span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="#" class="btn btn-success btn-block btn-icon fa-file-text" role="button">
                    <span>Create Report</span>
                </a>
            </div>
        </div>
        <hr />

        <!-- //Stat Blocks -->
        <div class="row">
            <div class="col-md-4">
                <a href="/members/report/completed-suppliers-profile/" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-flag-checkered"></i>
                        </div>

                        <h2>Completed Suppliers Profile</h2>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="/members/report/total-number-of-suppliers/" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <p class="countto-timer" data-to="{sum(component[@name='totalNumberOfSuppliers']/result/@count)}">
                            </p>
                        </div>

                        <h2>Total Number of Suppliers</h2>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="/members/report/supplier-code-of-conduct/" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-briefcase"></i>
                        </div>

                        <h2>Supplier Code of Conduct</h2>
                    </div>
                </a>
            </div>
        </div>

        <div class="row">
            <div class="col-md-4">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'completedSuppliersProfile'" />
                </xsl:call-template>
            </div>
            <div class="col-md-4">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'totalNumberOfSuppliers'" />
                </xsl:call-template>
            </div>

            <div class="col-md-4 text-center">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'supplierCodeOfConduct'" />
                </xsl:call-template>
            </div>
        </div>

        <div class="row">
            <div class="col-md-4">
                <a href="/members/report/approved-factory-program/" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-check"></i>
                        </div>

                        <h2>Approved Factory Program (Merch)</h2>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="/members/report/food-program/" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-cutlery"></i>
                        </div>

                        <h2>Approved Facility Program (Food)</h2>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="/members/report/sustainability-attributes/" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-envira"></i>
                        </div>

                        <h2>Sustainability Attributes</h2>
                    </div>
                </a>
            </div>
        </div>

        <div class="row">
            <div class="col-md-4">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'supplierApprovalStatus'" />
                </xsl:call-template>
            </div>
            <div class="col-md-4">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'foodProgram'" />
                    <xsl:with-param name="chart" select="'horizontalBar'" />
                    <xsl:with-param name="width" select="400" />
                    <xsl:with-param name="height" select="300" />
                </xsl:call-template>
            </div>

            <div class="col-md-4">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'sustainabilityAttributes'" />
                </xsl:call-template>
            </div>
        </div>

        <hr />
       <div class="row">
            <div class="col-md-4 col-md-offset-2">
                <a href="/members/import/" class="btn btn-warning btn-block btn-icon fa-upload" role="button">
                    <span>Import Data</span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="/members/export/" class="btn btn-warning btn-block btn-icon fa-download" role="button">
                    <span>Export Data</span>
                </a>
            </div>
        </div>

     </xsl:template>

    <!-- //Buyer Dashboard -->
    <xsl:template match="/config/plugin[@plugin = 'dashboards'][@method = 'davidJones']/dashboard[@group = 'buyer']">
        <h1 style="color:red;">Buyer Dashboard</h1>
        
        <!-- //User Name -->
        <xsl:call-template name="welcome-full-name" />
        <hr />

        <!-- //Action Buttons -->
        <div class="row">
            <div class="col-md-4 col-md-offset-2">
                <a href="#" class="btn btn-success btn-block btn-icon fa-pencil" role="button">
                    <span>Update My Department</span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="#" class="btn btn-success btn-block btn-icon fa-file-text" role="button">
                    <span>Create Report</span>
                </a>
            </div>
        </div>
        <hr />

        <!-- //Stat Blocks -->
        <div class="row">
            <div class="col-md-6">
                <div class="wp-block hero base">
                    <div class="thmb-img">
                        <i class="fa fa-id-card"></i>
                    </div>

                    <h2>My Suppliers Profile</h2>
                </div>
            </div>
            <div class="col-md-6">
                <div class="wp-block hero base">
                    <div class="thmb-img">
                        <i class="fa fa-users"></i>
                    </div>

                    <h2>My Suppliers</h2>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'completedSuppliersProfile'" />
                    <xsl:with-param name="height" select="'100'" />
                    <xsl:with-param name="width" select="'200'" />
                </xsl:call-template>
            </div>
            <div class="col-md-6">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'totalNumberOfSuppliers'" />
                    <xsl:with-param name="height" select="'100'" />
                    <xsl:with-param name="width" select="'200'" />
                </xsl:call-template>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6">
                <a href="/members/report/sustainability-attributes/" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-envira"></i>
                        </div>

                        <h2>Sustainability Attributes</h2>
                    </div>
                </a>
            </div>
            <div class="col-md-6">
                <div class="wp-block hero base">
                    <div class="thmb-img">
                        <i class="fa fa-check"></i>
                    </div>

                    <h2>My Factories Approval Status</h2>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="row">
                <div class="col-md-6">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'sustainabilityAttributes'" />
                    <xsl:with-param name="height" select="'100'" />
                    <xsl:with-param name="width" select="'200'" />
                </xsl:call-template>
                </div>
                <div class="col-md-6">
                    <xsl:call-template name="davidJonesStats">
                        <xsl:with-param name="name" select="'myFactoriesApprovalStatus'" />
                        <xsl:with-param name="height" select="'100'" />
                        <xsl:with-param name="width" select="'200'" />
                    </xsl:call-template>
                </div>
            </div>
        </div>

    </xsl:template>

    <!-- //Private Label Dashboard -->
    <xsl:template match="/config/plugin[@plugin = 'dashboards'][@method = 'davidJones']/dashboard[@group = 'private-label']">
        <h1 style="color:red;">Private Label Dashboard</h1>
        
        <!-- //User Name -->
        <xsl:call-template name="welcome-full-name" />
        <hr />

        <!-- //Action Buttons -->
        <div class="row">
            <div class="col-md-4">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="btn btn-success btn-block btn-icon fa-pencil" role="button">
                    <span>Edit Profile</span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="btn btn-success btn-block btn-icon fa-plus" role="button">
                    <span>Add Factory</span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="btn btn-success btn-block btn-icon fa-plus" role="button">
                    <span>Add Sustainability Attribute</span>
                </a>
            </div>
        </div>
        <hr />

        <!-- //Stat Blocks -->
        <div class="row">
            <div class="col-md-6">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-briefcase"></i>
                        </div>

                        <h2>DJ's Supplier Code of Conduct</h2>
                    </div>
                </a>
            </div>
            <div class="col-md-6">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-id-card"></i>
                        </div>

                        <h2>My Profile</h2>
                    </div>
                </a>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6 text-center">
                <xsl:call-template name="supplierCodeOfConduct" />
            </div>
            <div class="col-md-6 text-center">
                <xsl:call-template name="davidJonesPercent">
                    <xsl:with-param name="name" select="'percentCompletedProfile'" />
                    <xsl:with-param name="percent" select="clientChecklist[1]/@progress" />
                </xsl:call-template>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-check"></i>
                        </div>

                        <h2>My Factories Approval Status</h2>
                    </div>
                </a>
            </div>
            <div class="col-md-6">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-envira"></i>
                        </div>

                        <h2>Products Carry Sustainability Attribute</h2>
                    </div>
                </a>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'myFactoriesApprovalStatus'" />
                    <xsl:with-param name="width" select="'450'" />
                    <xsl:with-param name="height" select="'200'" />
                </xsl:call-template>
            </div>
            <div class="col-md-6">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'sustainabilityAttributes'" />
                    <xsl:with-param name="height" select="'200'" />
                    <xsl:with-param name="width" select="'450'" />
                </xsl:call-template>
            </div>
        </div>

    </xsl:template>

   <!-- //RBMA/Branded -->
    <xsl:template match="/config/plugin[@plugin = 'dashboards'][@method = 'davidJones']/dashboard[@group = 'rbma' or @group = 'branded']">
        <h1 style="color:red;">Branded/RBMA Dashboard</h1>
        
        <!-- //User Name -->
        <xsl:call-template name="welcome-full-name" />
        <hr />

        <!-- //Action Buttons -->
        <div class="row">
            <div class="col-md-4 col-md-offset-2">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="btn btn-success btn-block btn-icon fa-pencil" role="button">
                    <span>Edit Profile</span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="btn btn-success btn-block btn-icon fa-plus" role="button">
                    <span>Add Sustainability Attribute</span>
                </a>
            </div>
        </div>
        <hr />

        <!-- //Stat Blocks -->
        <div class="row">
            <div class="col-md-6">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-id-card"></i>
                        </div>

                        <h2>My Profile</h2>
                    </div>
                </a>
            </div>
            <div class="col-md-6">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-briefcase"></i>
                        </div>

                        <h2>DJ's Supplier Code of Conduct</h2>
                    </div>
                </a>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6 text-center">
                <xsl:call-template name="davidJonesPercent">
                    <xsl:with-param name="name" select="'percentCompletedProfile'" />
                    <xsl:with-param name="percent" select="clientChecklist[1]/@progress" />
                </xsl:call-template>
            </div>
            <div class="col-md-6 text-center">
                <xsl:call-template name="supplierCodeOfConduct" />
            </div>
        </div>

    </xsl:template>

   <!-- //Distributor -->
    <xsl:template match="/config/plugin[@plugin = 'dashboards'][@method = 'davidJones']/dashboard[@group = 'distributor']">
        <h1 style="color:red;">Distributor Dashboard</h1>
        
        <!-- //User Name -->
        <xsl:call-template name="welcome-full-name" />
        <hr />

        <!-- //Action Buttons -->
        <div class="row">
            <div class="col-md-4 col-md-offset-2">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="btn btn-success btn-block btn-icon fa-pencil" role="button">
                    <span>Edit Profile</span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="btn btn-success btn-block btn-icon fa-plus" role="button">
                    <span>Add Brand</span>
                </a>
            </div>
        </div>
        <hr />

        <!-- //Stat Blocks -->
        <div class="row">
            <div class="col-md-6">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-id-card"></i>
                        </div>

                        <h2>My Profile</h2>
                    </div>
                </a>
            </div>
            <div class="col-md-6">
                <a href="/members/entry/{clientChecklist[1]/@client_checklist_id}" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-briefcase"></i>
                        </div>

                        <h2>DJ's Supplier Code of Conduct</h2>
                    </div>
                </a>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6 text-center">
                <xsl:call-template name="davidJonesPercent">
                    <xsl:with-param name="name" select="'percentCompletedProfile'" />
                    <xsl:with-param name="percent" select="clientChecklist[1]/@progress" />
                </xsl:call-template>
            </div>
            <div class="col-md-6 text-center">
                <xsl:call-template name="supplierCodeOfConduct" />
            </div>
        </div>

    </xsl:template>

    <!-- //General Manager -->
    <xsl:template match="/config/plugin[@plugin = 'dashboards'][@method = 'davidJones']/dashboard[@group = 'general-manager']">
        <h1 style="color:red;">General Manager Dashboard</h1>
        
        <!-- //User Name -->
        <xsl:call-template name="welcome-full-name" />
        <hr />

        <!-- //Action Buttons -->
        <div class="row">
            <div class="col-md-4 col-md-offset-2">
                <a href="#" class="btn btn-success btn-block btn-icon fa-pencil" role="button">
                    <span>Update My Department</span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="#" class="btn btn-success btn-block btn-icon fa-file-text" role="button">
                    <span>Run Report</span>
                </a>
            </div>
        </div>
        <hr />

        <!-- //Stat Blocks -->
        <div class="row">
            <div class="col-md-6">
                <div class="wp-block hero base">
                    <div class="thmb-img">
                        <i class="fa fa-id-card"></i>
                    </div>

                    <h2>My Buyers Suppliers Profiles</h2>
                </div>
            </div>
            <div class="col-md-6">
                <div class="wp-block hero base">
                    <div class="thmb-img">
                        <i class="fa fa-group"></i>
                    </div>

                    <h2>My Buyers Suppliers</h2>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6">
            </div>
            <div class="col-md-6">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'totalNumberOfSuppliers'" />
                    <xsl:with-param name="height" select="'100'" />
                    <xsl:with-param name="width" select="'200'" />
                </xsl:call-template>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6">
                <a href="/members/report/sustainability-attributes/" class="dashboard-panel-link">
                    <div class="wp-block hero base">
                        <div class="thmb-img">
                            <i class="fa fa-envira"></i>
                        </div>

                        <h2>Sustainability Attributes</h2>
                    </div>
                </a>
            </div>
            <div class="col-md-6">
                <div class="wp-block hero base">
                    <div class="thmb-img">
                        <i class="fa fa-industry"></i>
                    </div>

                    <h2>My Buyers Factories</h2>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'sustainabilityAttributes'" />
                    <xsl:with-param name="height" select="'100'" />
                    <xsl:with-param name="width" select="'200'" />
                </xsl:call-template>
            </div>
            <div class="col-md-6">
                <xsl:call-template name="davidJonesStats">
                    <xsl:with-param name="name" select="'supplierApprovalStatus'" />
                    <xsl:with-param name="height" select="'100'" />
                    <xsl:with-param name="width" select="'200'" />
                </xsl:call-template>
            </div>
        </div>

    </xsl:template>

    <xsl:template name="davidJonesStats">
        <xsl:param name="name" />
        <xsl:param name="width" select="'300'" />
        <xsl:param name="height" select="'200'" />
        <xsl:param name="chart" select="'doughnut'" />

        <xsl:variable name="component" select="/config/plugin[@plugin = 'dashboards'][@method = 'davidJones']/dashboard[@group = current()/@group]/component[@type = 'answerStats'][@name = $name]" />

        <div class="david-jones-stats">
            <xsl:choose>
                <xsl:when test="count($component/result) &gt; 0">
                    <canvas class="chart-js static" width="{$width}" height="{$height}" data-type="{$chart}">
                        <xsl:attribute name="data-labels">
                            <xsl:text>[</xsl:text>
                            <xsl:for-each select="$component/result">
                                <xsl:text>"</xsl:text><xsl:value-of select="@string" /><xsl:text>"</xsl:text>
                                <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>
                            <xsl:text>]</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="data-data">
                            <xsl:text>[</xsl:text>
                            <xsl:for-each select="$component/result">
                                <xsl:text>"</xsl:text><xsl:value-of select="@count" /><xsl:text>"</xsl:text>
                                <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>
                            <xsl:text>]</xsl:text>   
                        </xsl:attribute>
                        <xsl:attribute name="data-legend">
                            <xsl:choose>
                                <xsl:when test="$component/@legend">
                                    <xsl:value-of select="$component/@legend" />
                                </xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </canvas>
                </xsl:when>
                <xsl:otherwise>
                    <div class="no-data text-center">
                        <i class="fa fa-ban" aria-hidden="true"></i>
                        <h5>No Data</h5>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="davidJonesPercent">
        <xsl:param name="name" />
        <xsl:param name="percent" />
        <canvas class="classyloader" data-classyloader="data-classyloader" data-trigger-in-view="true" data-percentage="{$percent}" data-line-width="30" data-line-color="#0E46D5" data-font-color="#0E46D5" data-remaining-line-color="#F9F9F9" data-start="top"></canvas>
    </xsl:template>

    <xsl:template name="supplierCodeOfConduct">
        <xsl:variable name="component" select="/config/plugin[@plugin = 'dashboards'][@method = 'davidJones']/dashboard[@group = current()/@group]/component[@type = 'supplierCodeOfConduct']" />
        <xsl:choose>
            <xsl:when test="$component/result[@name = 'signed']/@value = 'Yes'">
                <div class="text-success">
                    <i class="fa fa-check" style="font-size:150px;"></i>
                    <p><strong>Signed</strong></p>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="text-danger">
                    <i class="fa fa-times text-danger" style="font-size:150px;"></i>
                    <p><strong>Not Signed</strong></p>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- //Reports -->
    <xsl:template match="/config/plugin[@plugin = 'dashboards'][@method = 'davidJones'][@mode = 'report']">
        <xsl:choose>
            <xsl:when test="not(@reportType)">
                <h3>Invalid Report</h3>
                <p>You have requested an invalid report.</p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="report-table" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="report-table">

        <!-- //Filter -->
        <xsl:call-template name="filter" />

        <h3>
            <xsl:value-of select="@reportName" />
        </h3>
        <div class="row">
            <div class="col-md-12">
                <table class="table table-striped data-table static">
                    <thead>
                        <tr>
                            <xsl:for-each select="columns/column">
                                <th>
                                    <xsl:value-of select="@label" />
                                </th>
                            </xsl:for-each>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="results/result">
                            <xsl:variable name="result" select="." />
                            <tr>
                            <xsl:for-each select="../../columns/column">
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="@column = 'vendor_name'">
                                            <a href="/members/entry/{$result/@client_checklist_id}">
                                                <xsl:value-of select="$result/@*[local-name() = current()/@column]" />
                                            </a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$result/@*[local-name() = current()/@column]" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </xsl:for-each>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
            </div>
        </div>

    </xsl:template>

    <xsl:template match="/config/plugin[@plugin = 'dashboards'][@method = 'davidJones']/component[@name = 'footerMenu']">
        <hr />

        <div class="row">
            <div class="col-md-3 text-center">
                <a href="#">Profile</a>
            </div>
            <div class="col-md-3 text-center">
                <a href="#">Program Requirements</a>
            </div>
            <div class="col-md-3 text-center">
                <a href="#">Resources</a>
            </div>
            <div class="col-md-3 text-center">
                <a href="#">Newsfeed</a>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>