<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<!-- //Include other method templates -->
	<xsl:include href="methods/client_details.xsl" />
	<xsl:include href="methods/client_checklist_details.xsl" />
	<xsl:include href="methods/filter-results.xsl" />
	<xsl:include href="methods/client-map.xsl" />
	<xsl:include href="methods/client-checklist-compare.xsl" />
	<xsl:include href="methods/analytics.xsl" />
	<xsl:include href="methods/client-checklist.xsl" />
	<xsl:include href="methods/client.xsl" />
	<xsl:include href="methods/metric.xsl" />
	<xsl:include href="methods/user.xsl" />
	<xsl:include href="methods/checklist.xsl" />
	<xsl:include href="methods/settings.xsl" />
	<xsl:include href="methods/leaflet-map.xsl" />
	<xsl:include href="methods/import.xsl" />

	<!-- //Custom Templates -->
	<xsl:include href="methods/vivid-sydney.xsl" />
	
	<!-- //Choose if we are sending the number back as text or as an animated number -->
	<xsl:template name="renderNumber">
		<xsl:param name="number" select="@number" />
		<xsl:param name="animated" select="@animated" />
		<xsl:param name="speed" select="@speed" />

		<xsl:variable name="data-speed">
			<xsl:choose>
				<xsl:when test="$speed != ''">
					<xsl:value-of select="$speed" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'2000'" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>	

		<xsl:choose>
			<xsl:when test="$animated = 'true'">
				<span class="countto-timer" data-from="0" data-to="{$number}" data-speed="{$data-speed}"></span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$number" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="renderNumber" mode="html">
		<xsl:param name="number" select="@number" />
		<xsl:param name="animated" select="@animated" />

		<xsl:call-template name="renderNumber">
			<xsl:with-param name="number" select="$number" />
			<xsl:with-param name="animated" select="$animated" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="classy-loader">
		<xsl:param name="percentage" select="@percentage" />
		<canvas data-classyloader="data-classyloader" data-trigger-in-view="{@trigger-in-view}" data-percentage="{$percentage}" data-speed="{@speed}" data-font-size="{@font-size}" data-diameter="{@diameter}" data-line-color="{@line-color}" data-remaining-line-color="{@remaining-line-color}" data-line-width="{@line-width}" data-font-color="{@font-color}" data-start="{@start}" data-width="{@width}" data-height="{@height}">
		</canvas>
	</xsl:template>

	<xsl:template match="classy-loader" mode="html">
		<xsl:param name="identifier" select="@identifier" />
		<xsl:param name="score" select="@score" />

		<xsl:variable name="plugin_method_call_id">
			<xsl:choose>
				<xsl:when test="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']">
					<xsl:value-of select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/@plugin_method_call_id" />
				</xsl:when>
				<xsl:when test="/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']">
					<xsl:value-of select="/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/@plugin_method_call_id" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="percentage">
			<xsl:choose>

				<!-- // Legacy -->
				<xsl:when test="@node = 'checklist'">
					<xsl:choose>
						<xsl:when test="@node-attribute = 'average_score'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $identifier]/@average_score" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'average_score_whole'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $identifier]/@average_score_whole" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'filtered_average_score'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $identifier]/@filtered_average_score" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'filtered_average_score_whole'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $identifier]/@filtered_average_score_whole" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'completion_rate'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $identifier]/@completion_rate" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'pass_rate'">
							<xsl:value-of select="(count(/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/clientChecklist[@checklist_id = $identifier][@current_score = $score or @current_score &gt; $score]) div count(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@checklist_id = $identifier])) * 100" />
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="@node = 'clientChecklist'">
					<xsl:variable name="checklist_id" select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/clientChecklist[@client_checklist_id = /config/globals/item[@key = 'client_checklist_id']/@value]/@checklist_id" />
					<xsl:choose>
						<xsl:when test="@node-attribute = 'current_score'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/clientChecklist[@client_checklist_id = /config/globals/item[@key = 'client_checklist_id']/@value]/@score_formatted" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'average_score'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $checklist_id]/@average_score" />
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="@node = 'client_checklist'">
					<xsl:variable name="checklist_id" select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/client_checklist[@client_checklist_id = /config/globals/item[@key = 'client_checklist_id']/@value]/@checklist_id" />
					<xsl:choose>
						<xsl:when test="@node-attribute = 'current_score'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/client_checklist[@client_checklist_id = /config/globals/item[@key = 'client_checklist_id']/@value]/@score_formatted" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'average_score_whole'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $checklist_id]/@average_score_whole" />
						</xsl:when>
					</xsl:choose>
				</xsl:when>

				<xsl:when test="@node = 'entry'">
					<xsl:choose>
						<xsl:when test="@node-attribute = 'average'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $identifier]/@average" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'average_score_whole'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $identifier]/@average_score_whole" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'filtered_average'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $identifier]/@filtered_average" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'filtered_average_score_whole'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $identifier]/@filtered_average_score_whole" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'completion_rate'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $identifier]/@completion_rate" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'completion_rate_whole'">
							<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/checklist[@checklist_id = $identifier]/@completion_rate_whole" />
						</xsl:when>
						<xsl:when test="@node-attribute = 'pass_rate'">
							<xsl:value-of select="(count(/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/clientChecklist[@checklist_id = $identifier][@current_score = $score or @current_score &gt; $score]) div count(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@checklist_id = $identifier])) * 100" />
						</xsl:when>
					</xsl:choose>
				</xsl:when>

				<xsl:when test="@node = 'static'">
					<xsl:value-of select="$score" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:call-template name="classy-loader">
			<xsl:with-param name="trigger-in-view" select="@trigger-in-view" />
			<xsl:with-param name="percentage" select="$percentage" />
			<xsl:with-param name="speed" select="@speed" />
			<xsl:with-param name="font-size" select="@font-size" />
			<xsl:with-param name="diameter" select="@diameter" />
			<xsl:with-param name="line-color" select="@line-color" />
			<xsl:with-param name="remaining-line-color" select="@remaining-line-color" />
			<xsl:with-param name="line-width" select="@line-width" />
			<xsl:with-param name="font-color" select="@font-color" />
			<xsl:with-param name="start" select="@start" />
			<xsl:with-param name="width" select="@width" />
			<xsl:with-param name="height" select="@height" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="dashboard-query" mode="html">
		<xsl:param name="query" select="@query" />
		<xsl:param name="node" select="@node" />
		<xsl:param name="identifier" select="@identifier" />
		<xsl:param name="animated" select="@animated" />

		<xsl:choose>
			<xsl:when test="$query = 'count'">
				<xsl:choose>

					<!-- //Get Content based counter (Legacy) -->
					<xsl:when test="$node = 'client'">
						<xsl:choose>
							<xsl:when test="$identifier != ''">
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="count(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/client[@client_type_id = $identifier])" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="count(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/client)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$node = 'clientChecklist'">
						<xsl:choose>
							<xsl:when test="$identifier != ''">
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="count(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@checklist_id = $identifier])" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="count(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<!-- //Load content based counter -->
					<xsl:when test="$node = 'client_type'">
						<xsl:choose>
							<xsl:when test="$identifier != ''">
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="sum(/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/client_type[@client_type_id = $identifier]/@count)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="sum(/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/client_type/@count)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$node = 'entry'">
						<xsl:choose>
							<xsl:when test="$identifier != ''">
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="sum(/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/checklist[@checklist_id = $identifier]/@count)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="sum(/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/checklist/@count)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$node = 'client-entry'">
						<xsl:choose>
							<xsl:when test="$identifier != ''">
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="sum(/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/client[@client_id = $identifier]/@entries)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="sum(/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/client/@entries)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$node = 'client-user' or $node = 'users'">
						<xsl:choose>
							<xsl:when test="$identifier != ''">
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="sum(/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/client_type[@client_type_id = $identifier]/@users)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="sum(/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/client_type/@users)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!--<xsl:when test="$node = 'client-user'">
						<xsl:choose>
							<xsl:when test="$identifier != ''">
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="sum(/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/client[@client_id = $identifier]/@users)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="renderNumber">
									<xsl:with-param name="number" select="sum(/config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/client/@users)" />
									<xsl:with-param name="animated" select="$animated" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>-->

				</xsl:choose>

			</xsl:when>
			<xsl:when test="$query = 'static'">
				<xsl:call-template name="renderNumber">
					<xsl:with-param name="number" select="$identifier" />
					<xsl:with-param name="animated" select="$animated" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<!-- //Filter Links -->
	<xsl:template match="client-data-table" mode="html">
		<div class="row-fluid">
			<div class="table-responsive gbc-data-table">
				<table id="supplier-data-table" class="table admin-datatable table-striped dataTable">
					<thead>
						<tr>
							<th scope="col">Company Name</th>
							<th scope="col">City</th>
							<th scope="col">State</th>
							<th scope="col">Country</th>
							<th scope="col" class="action-col">Actions</th>
						</tr>
					</thead>
					<thead>
						<tr class="data-filter">
							<th class="filter" scope="col">Company Name</th>
							<th class="filter" scope="col">City</th>
							<th class="filter" scope="col">State</th>
							<th class="filter" scope="col">Country</th>
							<th scope="col"></th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/client">
							<tr>
								<td>
									<a href="details/?client_id={@client_id}" title="more information">
										<xsl:value-of select="@company_name" />     
									</a>
								</td>
								<td><xsl:value-of select="@suburb" /></td>
								<td><xsl:value-of select="@state" /></td>
								<td><xsl:value-of select="@country" /></td>
				
								<td class="center">
									<a class="btn btn-success" href="details/?client_id={@client_id}" title="more information">
										<em class="fa fa-search"></em>                                            
									</a>
								</td>
			
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
	
		</div><!--/row-->
		
	</xsl:template>

	<!-- //Filter Links -->
	<xsl:template match="client-checklist-data-table" mode="html">

		<div class="row-fluid">
			<div class="table-responsive gbc-data-table">
				<table id="supplier-data-table" class="table admin-datatable table-striped dataTable" data-order="[[ 3, &quot;desc&quot; ]]">
					<thead>
						<tr>
							<th scope="col" class="action-col">Compare</th>
							<th scope="col">Company Name</th>
							<th scope="col">Assessment</th>
							<th scope="col">Score</th>
							<th scope="col">Started</th>
							<th scope="col">Finished</th>
							<th scope="col">Completed</th>
							<th scope="col" class="action-col">Actions</th>
						</tr>
					</thead>
					<thead>
						<tr class="data-filter">
							<th scope="col">
								<a class="btn btn-default disabled" id="submit-compare-options" title="Compare items">
									<i class="fa fa-balance-scale"></i>
								</a>
							</th>
							<th class="filter" scope="col">Company Name</th>
							<th class="filter" scope="col">Assessment</th>
							<th class="filter" scope="col">Score</th>
							<th class="filter" scope="col">Started</th>
							<th class="filter" scope="col">Finished</th>
							<th class="filter" scope="col">Completed</th>
							<th scope="col"></th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist">
							<tr>
								<td><input type="checkbox" name="compare-assessments-[]" id="{concat('compare-assessments-', @client_checklist_id)}" class="compare-assessments checkbox" value="{@client_checklist_id}" /></td>
								<td data-order="{@company_name}">
									<a href="details/?client_id={@client_id}&amp;client_checklist_id={@client_checklist_id}" title="more information">
										<xsl:value-of select="@company_name" />    
									</a>
								</td>
								<td><xsl:value-of select="@checklist_name" /></td>
								<td><xsl:value-of select="@score" /></td>
								<td data-order="{@created}"><xsl:value-of select="@started_date" /></td>
								<td data-order="{@completed}"><xsl:value-of select="@completed_date" /></td>
								<td><xsl:value-of select="@finished" /></td>
								<td class="center">
									<a class="btn btn-success" href="details/?client_id={@client_id}&amp;client_checklist_id={@client_checklist_id}" title="more information">
										<em class="fa fa-search"></em>                                            
									</a>
								</td>
			
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
	
		</div><!--/row-->

		<xsl:call-template name="compare-assessments-form" />
		
	</xsl:template>

	<!-- //Compare form and options -->
	<xsl:template name="compare-assessments-form">
		<div class="hidden">
			<form name="compare-form" method="post" action="compare" id="compare-form">
				<input type="hidden" name="action" value="compare-checklists" />
			</form>	
		</div>
	</xsl:template>

	<xsl:template name="supplier-info">
		<div class="client-address-container">
			<i class="icon-map-marker"></i>
			<xsl:variable name="client" select="/config/client[@client_id = /config/globals/item[@key = 'client_id']/@value]" />
			<a href="http://maps.google.com/?q={translate(concat($client/@address_line_1, '+', $client/@address_line_2, '+', $client/@suburb, '+', $client/@state, '+', $client/@country),' ','+')}" target="blank">
				<xsl:if test="$client/@address_line_1 != ''">
					<xsl:value-of select="$client/@address_line_1" />
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:if test="$client/@address_line_2 != ''">
					<xsl:value-of select="$client/@address_line_2" />
					<xsl:text>, </xsl:text> 
				</xsl:if>
				<xsl:if test="$client/@suburb != ''">
					<xsl:value-of select="$client/@suburb" />
					<xsl:text>, </xsl:text> 
				</xsl:if>
				<xsl:if test="$client/@state != ''">
					<xsl:value-of select="$client/@state" />
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:value-of select="$client/@country" />
			</a>
		</div>
	</xsl:template>
	
</xsl:stylesheet>