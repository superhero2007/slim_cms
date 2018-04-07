<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='user'][@mode = 'log']">

		<xsl:variable name="order-by">
			<xsl:choose>
				<xsl:when test="@order-by">
					<xsl:value-of select="@order-by" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>3</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="order-direction">
			<xsl:choose>
				<xsl:when test="@order-direction">
					<xsl:value-of select="@order-direction" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>desc</xsl:text>
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
								<th scope="col">User</th>
								<th scope="col">Entity</th>
								<th scope="col">IP Address</th>
								<th scope="col">Date</th>
								<th scope="col" width="40%">Request</th>
							</tr>
						</thead>
					</table>
				</form>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='user'][@mode = 'list']">

		<xsl:variable name="order-by">
			<xsl:choose>
				<xsl:when test="@order-by">
					<xsl:value-of select="@order-by" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>1</xsl:text>
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
								<th></th>
								<th scope="col">User</th>
								<th scope="col">Email</th>
								<th scope="col">Entity</th>
								<th scope="col">Last Active</th>
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
												<option value="user-add" data-type="add" data-link="/members/dashboard/user/add/">Add User</option>
												<option value="user-edit" data-type="edit" data-link="/members/dashboard/user/edit/?client_contact_id=">Edit User</option>
												<option value="user-delete" data-type="action">Delete User</option>
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

	<!--//Add User Form Template -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='user'][@mode = 'add']">
		<xsl:call-template name="edit-user-form">
			<xsl:with-param name="mode" select="@mode" />
			<xsl:with-param name="query-data" select="query-data" />
		</xsl:call-template>
	</xsl:template>

	<!--//Edit User Form Template -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='user'][@mode = 'edit']">
		<xsl:call-template name="edit-user-form">
			<xsl:with-param name="mode" select="@mode" />
			<xsl:with-param name="query-data" select="query-data" />
		</xsl:call-template>
	</xsl:template>

	<!-- //Register Form -->
	<xsl:template name="edit-user-form">
		<xsl:param name="mode" />
		<xsl:param name="query-data" />

		<xsl:variable name="form-mode">
			<xsl:choose>
				<xsl:when test="@mode = 'edit'">editUser</xsl:when>
				<xsl:otherwise>addUser</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="password-form">
			<xsl:if test="@mode = 'add'"> in</xsl:if>
		</xsl:variable>

		<xsl:variable name="dashboard-form">
			<xsl:if test="clientContact/dashboard"> in</xsl:if>
		</xsl:variable>

		<form method="post" class="enquiry sky-form" autocomplete="off" data-parsley-validate="data-parsley-validate" data-parsley-excluded="[disabled]">

			<!-- //Hidden Fields -->
			<input type="hidden" name="action" value="{$form-mode}" />
			<input type="hidden" name="client_contact_id" value="{clientContact/@client_contact_id}" />
			<input type="hidden" name="set_by_client_contact_id" value="{/config/plugin[@plugin='clients'][@method='login']/client/dashboard/@client_contact_id}" />
			<input type="hidden" name="dashboard_group_id" value="{/config/plugin[@plugin='clients'][@method='login']/client/dashboard/@dashboard_group_id}" />

			<div class="entry page row">

				<!-- //User Details -->
				<div class="panel">
					<div class="panel-heading bg-gray-light">
						<h4 class="panel-title">
							User Details
						</h4>
					</div>
					<div class="panel-body">
						<xsl:call-template name="user-detail-fields">
							<xsl:with-param name="mode" select="$mode" />
							<xsl:with-param name="query-data" select="$query-data" />
						</xsl:call-template>
					</div>
				</div>

				<!-- //User Details -->
				<div class="panel">
					<div class="panel-heading bg-gray-light">
						<h4 class="panel-title">
							<xsl:choose>
								<xsl:when test="$password-form = 'in'">
									User Password
								</xsl:when>
								<xsl:otherwise>
									<a data-toggle="collapse" href="#password-form">User Password</a>
								</xsl:otherwise>
							</xsl:choose>
						</h4>
					</div>
					<div id="password-form" class="panel-collapse collapse{$password-form}">
						<div class="panel-body">
							<xsl:call-template name="user-password-fields" />
						</div>
					</div>
				</div>

				<!-- //User Details -->
				<div class="panel">
					<div class="panel-heading bg-gray-light">
						<h4 class="panel-title">
							<xsl:choose>
								<xsl:when test="$dashboard-form = 'in'">
									User Dashboard Access
								</xsl:when>
								<xsl:otherwise>
									<a data-toggle="collapse" href="#dashboard-form">User Dashboard Access</a>
								</xsl:otherwise>
							</xsl:choose>
						</h4>
					</div>
					<div id="dashboard-form" class="panel-collapse collapse{$dashboard-form}">
						<div class="panel-body">
							<xsl:call-template name="user-dashboard-fields" />
						</div>
					</div>
				</div>

				<!-- //Row -->
				<div class="row">
					<div class="col-md-12">
						<div class="row">
							<div class="col-md-3">
								<a href="/members/dashboard/user/" class="btn btn-labeled btn-warning btn-block dashboard-button" data-action="cancel">
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

	<xsl:template name="user-detail-fields">
		<xsl:param name="mode" />
		<xsl:param name="query-data" />

		<!-- //Row -->
		<div class="col-md-12 question">
			<fieldset class="entry question">
				<div class="row">
					<div class="col-md-6">
						<label class="entry question-content">
							First Name
							<span class="entry question icon required fa fa-asterisk" />
						</label>
						<input type="text" name="firstname" data-parsley-required="required" class="form-control">
							<xsl:attribute name="value">
								<xsl:choose>
									<xsl:when test="/config/globals/item[@key = 'firstname']/@value">
										<xsl:value-of select="/config/globals/item[@key = 'firstname']/@value" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="clientContact/@firstname" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</input>
					</div>
					<div class="col-md-6">
						<label class="entry question-content">
							Last Name
							<span class="entry question icon required fa fa-asterisk" />
						</label>
						<input type="text" name="lastname" data-parsley-required="required" class="form-control">
							<xsl:attribute name="value">
								<xsl:choose>
									<xsl:when test="/config/globals/item[@key = 'lastname']/@value">
										<xsl:value-of select="/config/globals/item[@key = 'lastname']/@value" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="clientContact/@lastname" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</input>
					</div>
				</div>
			</fieldset>
		</div>
		<!-- //Row -->
		<div class="col-md-12 question">
			<fieldset class="entry question">
				<div class="row">
					<div class="col-md-6">
						<label class="entry question-content">
							Email
							<span class="entry question icon required fa fa-asterisk" />
						</label>
						<input type="email" name="email" data-parsley-required="required" class="form-control unique-user-lookup" data-parsley-unique-user-lookup="1" data-key="{$query-data/@key}" data-timestamp="{$query-data/@timestamp}" data-hash="{$query-data/@hash}" data-selected="{clientContact/@email}">
							<xsl:attribute name="value">
								<xsl:choose>
									<xsl:when test="/config/globals/item[@key = 'email']/@value">
										<xsl:value-of select="/config/globals/item[@key = 'email']/@value" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="clientContact/@email" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</input>
					</div>
					<div class="col-md-6">
						<label class="entry question-content">
							Entity
							<span class="entry question icon required fa fa-asterisk" />
						</label>

						<select class="chosen-select form-control" data-parsley-required="required" name="client_id">
							<option value="">-- Select --</option>
							<xsl:for-each select="clients/client">
								<option value="{@option_value}">
									<xsl:if test="@option_value = ../../clientContact/@client_id">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="@option_label" />
								</option>
							</xsl:for-each>
						</select>									
					</div>
				</div>
			</fieldset>
		</div>
		<!-- //Row -->
		<div class="col-md-12 question">
			<fieldset class="entry question">
				<div class="row">
					<div class="col-md-3">
						<div class="checkbox c-checkbox">
							<label>
								<input type="hidden" name="locked_out" value="0" />
								<input type="checkbox" name="locked_out" value="1">
									<xsl:choose>
										<xsl:when test="/config/globals/item[@key = 'locked_out']/@value = '1'">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:when>
										<xsl:when test="clientContact/@locked_out = '1'">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:when>
									</xsl:choose>
								</input>
								<span class="fa fa-check"></span>
								<xsl:text>Lock User Account</xsl:text>
							</label>
						</div>
					</div>
				</div>
			</fieldset>
		</div>

	</xsl:template>

	<xsl:template name="user-password-fields">
		<div class="col-md-12 question">
			<fieldset class="entry question">
				<div class="row">
					<div class="col-md-6">
						<label class="entry question-content">
							Password
							<span class="entry question icon required fa fa-asterisk" />
							<span class="entry question icon information fa fa-info-circle" title="Information" data-container="body" data-toggle="popover" data-trigger="hover" data-placement="auto top" data-content="Password must be between 8 and 60 characters and contain an upper case letter, a lower case letter, a number and a non-alphanumeric character"/>
						</label>
						<input type="password" name="password" id="password" data-parsley-required="required" class="form-control" data-parsley-pattern="/((?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W]).{{8,60}})/g" data-parsley-pattern-message="Password complexity requirement not met." />
					</div>
					<div class="col-md-6">
						<label class="entry question-content">
							Confirm Password
							<span class="entry question icon required fa fa-asterisk" />
							<span class="entry question icon information fa fa-info-circle" title="Information" data-container="body" data-toggle="popover" data-trigger="hover" data-placement="auto top" data-content="Password must be between 8 and 60 characters and contain an upper case letter, a lower case letter, a number and a non-alphanumeric character"/>
						</label>
						<input type="password" name="password_confirm" id="password_confirm" data-parsley-required="required" data-parsley-equalto="#password" class="form-control" data-parsley-equalto-message="This value should match the password field." />
					</div>
				</div>
			</fieldset>
		</div>
	</xsl:template>

	<xsl:template name="user-dashboard-fields">
		<!-- //Row -->
		<div class="col-md-12 question">
			<fieldset class="entry question">
				<div class="row">
					<div class="col-md-6">
						<label class="entry question-content">
							Dashboard Access
							<span class="entry question icon required fa fa-asterisk" />
							<span class="entry question icon information fa fa-info-circle" title="Information" data-container="body" data-toggle="popover" data-trigger="hover" data-placement="auto top" data-content="Select if this user should have access to the dashboard."/>
						</label>

						<select class="chosen-select form-control" name="dashboard_access">
							<option value="1">Enabled</option>
							<option value="0">
								<xsl:if test="not(clientContact/dashboard)">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								Disabled
							</option>
						</select>									
					</div>
					<div class="col-md-6">
						<label class="entry question-content">
							Dashboard Role
							<span class="entry question icon required fa fa-asterisk" />
							<span class="entry question icon information fa fa-info-circle" title="Information" data-container="body" data-toggle="popover" data-trigger="hover" data-placement="auto top" data-content="Select the role which this user should have when access to the dashboard is allowed."/>
						</label>

						<select class="chosen-select form-control" data-parsley-required="required" name="dashboard_role_id">
							<xsl:for-each select="roles/role">
								<option value="{@dashboard_role_id}">
									<xsl:choose>
										<xsl:when test="../../clientContact/dashboard">
											<xsl:if test="@dashboard_role_id = ../../clientContact/dashboard/@dashboard_role_id">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>
										</xsl:when>
										<xsl:otherwise>
											<xsl:if test="@dashboard_role_id = '3'"> <!-- //Default to User Role -->
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:value-of select="@name" />
								</option>
							</xsl:for-each>
						</select>									
					</div>
				</div>
			</fieldset>
		</div>

		<!-- //Row -->
		<div class="col-md-12 question">
			<fieldset class="entry question">
				<div class="row">
					<div class="col-md-6">
						<label class="entry question-content">
							Entity Restriction
							<span class="entry question icon information fa fa-info-circle" title="Information" data-container="body" data-toggle="popover" data-trigger="hover" data-placement="auto top" data-content="Select which entities this user should be restricted to. Leave empty for access to all entities."/>
						</label>

						<select class="chosen-select form-control" name="entity_restriction[]" multiple="multiple">
							<option value="">-- Select --</option>
							<xsl:for-each select="clients/client">
								<option value="{@option_value}">
									<xsl:if test="@option_value = ../../clientRestrictions/client/@client_id">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="@option_label" />
								</option>
							</xsl:for-each>
						</select>									
					</div>
					<div class="col-md-6">
						<label class="entry question-content">
							Entry Restriction
							<span class="entry question icon information fa fa-info-circle" title="Information" data-container="body" data-toggle="popover" data-trigger="hover" data-placement="auto top" data-content="Select which entries this user should be restricted to. Leave empty for access to all entries."/>
						</label>

						<select class="chosen-select form-control" name="entry_restriction[]" multiple="multiple">
							<option value="">-- Select --</option>
							<xsl:for-each select="checklists/checklist">
								<option value="{@checklist_id}">
									<xsl:if test="@checklist_id = ../../checklistRestrictions/checklist/@checklist_id">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="@name" />
								</option>
							</xsl:for-each>
						</select>									
					</div>
				</div>
			</fieldset>
		</div>
	</xsl:template>

</xsl:stylesheet>