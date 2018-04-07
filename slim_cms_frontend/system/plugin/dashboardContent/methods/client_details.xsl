<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">
	
	<!-- All Client Details for the dashboard -->
	<xsl:variable name="client_id" select="/config/globals/item[@key = 'client_id']/@value" />
	<xsl:variable name="client" select="(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/client[@client_id = $client_id] | /config/plugin[@plugin = 'dashboardContent'][@method = 'loadContent']/client[@client_id = $client_id])" />

	<xsl:variable name="client_address">
		<xsl:if test="$client/@address_line_1 != ''">
			<xsl:value-of select="concat($client/@address_line_1, ', ')" />
		</xsl:if>
		<xsl:if test="$client/@address_line_2 != ''">
			<xsl:value-of select="concat($client/@address_line_2, ', ')" />
		</xsl:if>
		<xsl:if test="$client/@suburb != ''">
			<xsl:value-of select="concat($client/@suburb, ', ')" />
		</xsl:if>
		<xsl:if test="$client/@state != ''">
			<xsl:value-of select="concat($client/@state, ', ')" />
		</xsl:if>
		<xsl:if test="$client/@country != ''">
			<xsl:value-of select="$client/@country" />
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="client_address_opt_1">
		<xsl:if test="$client/@address_line_1 != ''">
			<xsl:value-of select="concat($client/@address_line_1, ', ')" />
		</xsl:if>
		<xsl:if test="$client/@address_line_2 != ''">
			<xsl:value-of select="$client/@address_line_2" />
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="client_address_opt_2">
		<xsl:if test="$client/@suburb != ''">
			<xsl:value-of select="concat($client/@suburb, ', ')" />
		</xsl:if>
		<xsl:if test="$client/@state != ''">
			<xsl:value-of select="concat($client/@state, ', ')" />
		</xsl:if>
		<xsl:if test="$client/@country != ''">
			<xsl:value-of select="$client/@country" />
		</xsl:if>
	</xsl:variable>

	<!-- //Google Map -->
	<xsl:template name="google-map-classic">
		<xsl:choose>
			<xsl:when test="$client">
				<xsl:variable name="client_address" select="concat($client/@address_line_1, ' ', $client/@address_line_2, ' ', $client/@suburb, ' ', $client/@state, ' ', $client/@postcode, ' ', $client/@country)" />
				<div data-gmap="" data-address="{$client_address}" class="gmap"></div>
			</xsl:when>
			<xsl:otherwise>
				<p>Invalid Client</p>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>

	<xsl:template match="company-name" mode="html">
		<xsl:value-of select="$client/@company_name" />
	</xsl:template>

	<xsl:template match="company-address" mode="html">
		<xsl:choose>
			<xsl:when test="$client_address != ''">
				<xsl:value-of select="$client_address" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>No address supplied</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="client-last-active" mode="html">
		<xsl:value-of select="$client/@last_active_pretty_date_word" />
	</xsl:template>

	<xsl:template match="count-client-contacts" mode="html">
		<xsl:call-template name="renderNumber">
			<xsl:with-param name="number" select="count(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/client/client_contact[@client_id = $client_id])" />
			<xsl:with-param name="animated" select="@animated" />
			<xsl:with-param name="speed" select="@speed" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="count-documents" mode="html">
		<xsl:call-template name="renderNumber">
			<xsl:with-param name="number" select="count(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@client_id = $client_id]/client_result[@answer_type = 'file-upload'][@arbitrary_value != ''])" />
			<xsl:with-param name="animated" select="@animated" />
			<xsl:with-param name="speed" select="@speed" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="count-client-checklists" mode="html">
		<xsl:call-template name="renderNumber">
			<xsl:with-param name="number" select="count(/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist[@client_id = $client_id])" />
			<xsl:with-param name="animated" select="@animated" />
			<xsl:with-param name="speed" select="@speed" />
		</xsl:call-template>
	</xsl:template>

	<!-- //Google Map -->
	<xsl:template match="google-map-classic" mode="html">
		<xsl:call-template name="goole-map-classic" />
	</xsl:template>

	<xsl:template match="client-map-widget" mode="html">
		<xsl:choose>
			<xsl:when test="$client">
				<!-- START widget-->
				<div class="panel panel-primary">
				<div class="panel-heading">Location</div>
				<div class="panel-body">
					<xsl:call-template name="google-map-classic" />
				</div>
				 <div class="panel-footer bg-gray-dark">
				    <div class="row row-table">
				       <div class="col-xs-1">
				          <em class="fa fa-map-marker fa-3x"></em>
				       </div>
				       <div class="col-xs-11">
				          <p class="m0"><xsl:value-of select="$client_address_opt_1" /></p>
				          <p class="m0"><xsl:value-of select="$client_address_opt_2" /></p>
				       </div>
				    </div>
				 </div>
				</div>
				<!-- END widget-->
			</xsl:when>
			<xsl:otherwise>
				<p>Invalid Client</p>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>

	<xsl:template match="client-contact-data-table" mode="html">
		<xsl:call-template name="client-contact-data-table" />
	</xsl:template>

	<!-- //Client Contact Data Table -->
	<xsl:template name="client-contact-data-table">
		<xsl:choose>
			<xsl:when test="$client">
				<div class="table-responsive gbc-data-table">
					<table class="table table-striped">
						<thead>
							<tr>
								<th scope="col">First Name</th>
								<th scope="col">Last Name</th>
								<th scope="col">Phone</th>
								<th scope="col">Email</th>
								<th scope="col">Last Active</th>
							</tr>
						</thead>
						<tbody>
							<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/client/client_contact">
								<xsl:sort select="@lastname" />
								<tr>
									<td><xsl:value-of select="@firstname" /></td>
									<td><xsl:value-of select="@lastname" /></td>
									<td><xsl:value-of select="@phone" /></td>
									<td><a href="{concat('mailto:', @email)}"><xsl:value-of select="@email" /></a></td>
									<td><xsl:value-of select="@last_active_date" /></td>
								</tr>
							</xsl:for-each>
						</tbody>
					</table>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<p>Invalid Client</p>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<xsl:template match="single-client-checklist-data-table" mode="html">
		<xsl:call-template name="single-client-checklist-data-table" mode="html" />
	</xsl:template>

	<!-- //Filter Links -->
	<xsl:template name="single-client-checklist-data-table">
		<div class="row-fluid">
			<div class="table-responsive gbc-data-table">
				<table id="supplier-data-table" class="table admin-datatable table-striped dataTable" data-order="[[ 2, &quot;desc&quot; ]]">
					<thead>
						<tr>
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
								<td>
									<a href="assessment/?client_id={@client_id}&amp;client_checklist_id={@client_checklist_id}" title="more information">
										<xsl:value-of select="@checklist_name" />
									</a>
								</td>
								<td><xsl:value-of select="@score" /></td>
								<td data-order="{@created}"><xsl:value-of select="@started_date" /></td>
								<td data-order="{@completed}"><xsl:value-of select="@completed_date" /></td>
								<td><xsl:value-of select="@finished" /></td>
				
								<td class="center">
									<a class="btn btn-success" href="assessment/?client_id={@client_id}&amp;client_checklist_id={@client_checklist_id}" title="more information">
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

	<xsl:template match="client-documents-data-table" mode="html">
		<xsl:call-template name="client-documents-data-table" mode="html" />
	</xsl:template>

	<!-- //Filter Links -->
	<xsl:template name="client-documents-data-table">
		<div class="row-fluid">
			<div class="table-responsive gbc-data-table">
				<table id="supplier-data-table"  class="table admin-datatable table-striped dataTable" data-order="[[ 2, &quot;desc&quot; ]]">
					<thead>
						<tr>
							<th scope="col">Question</th>
							<th scope="col">Document</th>
							<th scope="col">Date</th>
							<th scope="col" class="action-col">Actions</th>
						</tr>
					</thead>
					<thead>
						<tr class="data-filter">
							<th class="filter" scope="col">Question</th>
							<th class="filter" scope="col">Document</th>
							<th class="filter" scope="col">Date</th>
							<th scope="col"></th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getContent']/clientChecklist/client_result[@answer_type = 'file-upload'][@arbitrary_value != '']">
							<tr>
								<td><xsl:value-of select="../question[@question_id = current()/@question_id]/@question" /></td>
								<td><xsl:value-of select="@arbitrary_value" /></td>
								<td data-order="{@timestamp}"><xsl:value-of select="@timestamp_date" /></td>
				
								<td class="center">
									<a class="btn btn-info" href="http://www.greenbizcheck.com/download?action=download-file&amp;file-type=answer_document&amp;file-name={@arbitrary_value}" title="download">
										<em class="fa fa-download"></em>                                            
									</a>
								</td>
			
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
	
		</div><!--/row-->
		
	</xsl:template>

</xsl:stylesheet>