<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<!-- //Client Checklist Table -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entity'][@mode = 'list']">

		<xsl:variable name="order-by">
			<xsl:choose>
				<xsl:when test="@order-by">
					<xsl:value-of select="@order-by" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="order-direction">
			<xsl:choose>
				<xsl:when test="@order-direction">
					<xsl:value-of select="@order-direction" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>asc</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="default-rows">
			<xsl:choose>
				<xsl:when test="@default-rows">
					<xsl:value-of select="@default-rows" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>10</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="row-fluid data-table">
			<div class="table-responsive">
				<form class="dashboard form" method="post">
					<table class="table ajax-datatable table-striped dataTable" data-order="[[{$order-by},&quot;{$order-direction}&quot;]]" data-page-length="{$default-rows}" data-query-id="{query-data/@query}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}" data-display="{@display}">
						<thead>
							<tr>
								<th>
									<input type="checkbox" name="row-index-toggle" data-status="off" />
								</th> <!-- //Checkbox Column -->
								<xsl:choose>
									<xsl:when test="columns/column">
										<xsl:for-each select="columns/column">
											<th scope="col">
												<xsl:value-of select="@name" />
											</th>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<th scope="col">Entity</th>
										<th scope="col">Created</th>
										<th scope="col">Last Active</th>
									</xsl:otherwise>
								</xsl:choose>
							</tr>
						</thead>
					</table>

					<!-- //Action -->
					<xsl:if test="/config/plugin[@plugin='clients'][@method='login']/client/dashboard/@dashboard_role_id &lt; 3">
						<div class="row">
							<div class="col-md-12">
								<div class="row">
									<div class="col-md-3">
										<div class="select drop-down-list">
											<select class="form-control" name="action">
												<option value="">-- Choose Action --</option>
												<option value="entity-add" data-type="add" data-link="/members/dashboard/account/add/">Add Account</option>
												<option value="entity-edit" data-type="edit" data-link="/members/dashboard/account/edit/?client_id=">Edit Account</option>
												<option value="entity-archive" data-type="action">Archive Account</option>
											</select>
										</div>
									</div>
									<div class="col-md-3">
										<button type="button" class="btn btn-labeled btn-primary btn-block dashboard-button action">
											<span class="btn-label pull-left">
												<i class="fa fa-paper-plane"></i>
											</span>
											Apply Action
										</button>
									</div>
								</div>
							</div>
						</div>
					</xsl:if>

				</form>
			</div>
		</div>
	</xsl:template>

	<!--//Edit Save Form -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entity'][@mode = 'edit']">
		<xsl:call-template name="edit-entity-form">
			<xsl:with-param name="mode" select="@mode" />
		</xsl:call-template>	
	</xsl:template>
	<!--//Edit Save Form -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='entity'][@mode = 'add']">
		<xsl:call-template name="edit-entity-form">
			<xsl:with-param name="mode" select="@mode" />
		</xsl:call-template>	
	</xsl:template>

	<xsl:template name="edit-entity-form">

		<xsl:variable name="form-mode">
			<xsl:choose>
				<xsl:when test="@mode = 'edit'">editEntity</xsl:when>
				<xsl:otherwise>addEntity</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--<xsl:variable name="client_id" select="/config/pathSet/path[last()]/text()" />-->
		<xsl:variable name="client_id" select="/config/plugin[@plugin='dashboardContent'][@method='loadContent']/client/@client_id" />
		<xsl:variable name="client" select="/config/plugin[@plugin='dashboardContent'][@method='loadContent']/client[@client_id = $client_id]" />

		<form method="post" action="" class="form-horizontal" id="entry-form" data-parsley-validate="data-parsley-validate" novalidate="novalidate" data-parsley-excluded="[disabled]">
			<input type="hidden" name="action" value="{$form-mode}" />
			<input type="hidden" name="client_id" value="{$client/@client_id}" />

			<div class="entry page">
				<div class="row">

					<div class="col-md-6 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">Entity Name
										<span class="required-question text-danger error">*</span>
									</label>
									<input type="text" name="company_name" class="form-control" data-parsley-required="required" value="{$client/@company_name}" />
								</div>
							</div>
						</fieldset>
					</div>

					<div class="col-md-6 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">Entity Type
										<span class="required-question text-danger error">*</span>
									</label>
									<div class="select drop-down-list">
										<select class="form-control" data-parsley-required="required" name="client_type_id">
											<xsl:if test="count(/config/plugin[@plugin='dashboardContent'][@method='loadContent']/client_type) &gt; 1">
												<option value="">-- Select --</option>
											</xsl:if>
											<xsl:for-each select="/config/plugin[@plugin='dashboardContent'][@method='loadContent']/client_type">
												<option value="{@client_type_id}">
													<xsl:if test="$client/@client_type_id = current()/@client_type_id">
														<xsl:attribute name="selected">selected</xsl:attribute>
													</xsl:if>
													<xsl:value-of select="@client_type" disable-output-escaping="yes" />
												</option>
											</xsl:for-each>
										</select>
										<i></i>
									</div>
								</div>
							</div>
						</fieldset>
					</div>

				</div>
				<div class="row">

					<div class="col-md-6 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">Address Line 1
									</label>
									<input type="text" name="address_line_1" class="form-control" value="{$client/@address_line_1}" />
								</div>
							</div>
						</fieldset>
					</div>

					<div class="col-md-6 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">Address Line 2
									</label>
									<input type="text" name="address_line_2" class="form-control"  value="{$client/@address_line_2}" />
								</div>
							</div>
						</fieldset>
					</div>

				</div>
				<div class="row">

					<div class="col-md-6 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">City
									</label>
									<input type="text" name="suburb" class="form-control" value="{$client/@suburb}" />
								</div>
							</div>
						</fieldset>
					</div>

					<div class="col-md-6 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">State
									</label>
									<input type="text" name="state" class="form-control" value="{$client/@state}" />
								</div>
							</div>
						</fieldset>
					</div>

				</div>
				<div class="row">

					<div class="col-md-6 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">Post Code
									</label>
									<input type="text" name="postcode" class="form-control" value="{$client/@postcode}" />
								</div>
							</div>
						</fieldset>
					</div>

					<div class="col-md-6 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">Country
									</label>
									<input type="text" name="country" class="form-control" value="{$client/@country}" />
								</div>
							</div>
						</fieldset>
					</div>

				</div>
				<div class="row">
					<div class="col-md-12">
						<div class="row">
							<div class="col-md-3">
								<a href="/members/dashboard/account/" class="btn btn-labeled btn-warning btn-block dashboard-button" data-action="cancel">
                           			<span class="btn-label pull-left">
                           				<i class="fa fa-times"></i>
                           			</span>
                           			Cancel
                           		</a>
							</div>
							<div class="col-md-3">
								<a href="#" class="btn btn-labeled btn-success btn-block dashboard-button" data-action="submit">
                           			<span class="btn-label pull-left">
                           				<i class="fa fa-plus"></i>
                           			</span>
                           			Save
                           		</a>
							</div>
						</div>
					</div>
				</div>

			</div>
		</form>
	</xsl:template>

	<xsl:template match="company-name" mode="html">
		<xsl:value-of select="/config/plugin[@plugin='dashboardContent'][@method='loadContent']/client/@company_name" />
	</xsl:template>
		
</xsl:stylesheet>