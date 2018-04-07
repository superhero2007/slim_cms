<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<!-- //Client Checklist Table -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='settings'][@setting='groups'][@mode='list']">

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
					<table class="table ajax-api-datatable table-striped dataTable" data-order="[[{$order-by},&quot;{$order-direction}&quot;]]" data-page-length="{$default-rows}" data-key="{query-data/@key}" data-timestamp="{query-data/@timestamp}" data-hash="{query-data/@hash}" data-display="{@display}" data-ajax-url="{@ajax-url}" data-ajax-method="{@ajax-method}" data-post-data="{query-data/@post-data}">
						<thead>
							<tr>
								<th></th> <!-- //Checkbox Column -->
								<xsl:choose>
									<xsl:when test="columns/column">
										<xsl:for-each select="columns/column">
											<th scope="col">
												<xsl:value-of select="@name" />
											</th>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<th scope="col">Hierarchy</th>
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
												<option value="settings-group-add" data-type="add" data-link="/members/dashboard/group/add/">Add Group</option>
												<option value="settings-group-edit" data-type="edit" data-link="/members/dashboard/group/edit/?group_id=">Edit Group</option>
												<option value="settings-group-delete" data-type="action" data-prompt="Delete group and any attached children groups">Delete Group</option>
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
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='settings'][@setting='groups'][@mode='edit']">
		<xsl:call-template name="edit-group-form">
			<xsl:with-param name="mode" select="@mode" />
		</xsl:call-template>	
	</xsl:template>
	<!--//Edit Save Form -->
	<xsl:template match="/config/plugin[@plugin = 'dashboardContent'][@method='settings'][@setting='groups'][@mode='add']">
		<xsl:call-template name="edit-group-form">
			<xsl:with-param name="mode" select="@mode" />
		</xsl:call-template>	
	</xsl:template>

	<xsl:template name="edit-group-form">

		<xsl:variable name="form-mode">
			<xsl:choose>
				<xsl:when test="@mode = 'edit'">editGroup</xsl:when>
				<xsl:otherwise>addGroup</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="client" select="/config/plugin[@plugin='clients'][@method='login']/client" />
		<xsl:variable name="group" select="/config/plugin[@plugin='dashboardContent'][@method='settings']/group[@user_defined_group_id = /config/globals/item[@key = 'group_id']/@value]" />

		<form method="post" action="" class="form-horizontal" id="entry-form" data-parsley-validate="data-parsley-validate" novalidate="novalidate" data-parsley-excluded="[disabled]">
			<input type="hidden" name="action" value="{$form-mode}" />
			<input type="hidden" name="user_defined_group_id" value="{$group/@user_defined_group_id}" />
			<input type="hidden" name="client_contact_id" value="{$client/dashboard/@client_contact_id}" />
			<input type="hidden" name="dashboard_group_id" value="{$client/dashboard/@dashboard_group_id}" />

			<div class="entry page">
				<div class="row">

					<div class="col-md-6 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">Name
										<span class="required-question text-danger error">*</span>
									</label>
									<input type="text" name="name" class="form-control" data-parsley-required="required" value="{$group/@name}" />
								</div>
							</div>
						</fieldset>
					</div>

					<div class="col-md-6 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">Parent Group
										<span class="required-question text-danger error">*</span>
									</label>
									<div class="select drop-down-list">
										<select class="form-control" data-parsley-required="required" name="parent_group_id">
											<option value="">-- Select --</option>
											<option value="0">
												<xsl:if test="$group/@parent_group_id = '0'">
													<xsl:attribute name="selected">selected</xsl:attribute>
												</xsl:if>
												No Parent Group
											</option>
											<xsl:for-each select="/config/plugin[@plugin='dashboardContent'][@method='settings']/group">
												<xsl:sort select="@hierarchy" />
												<option value="{@user_defined_group_id}">
													<xsl:if test="@attachable = '0'">
														<xsl:attribute name="disabled">disabled</xsl:attribute>
													</xsl:if>
													<xsl:if test="$group/@parent_group_id = current()/@user_defined_group_id">
														<xsl:attribute name="selected">selected</xsl:attribute>
													</xsl:if>
													<xsl:value-of select="@hierarchy" disable-output-escaping="yes" />
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

					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">Description
									</label>
									<textarea name="description" class="form-control"><xsl:value-of select="$group/@description" /></textarea>
								</div>
							</div>
						</fieldset>
					</div>

				</div>

				<!-- //If the group is set, allow access to add/remove members -->
				<xsl:if test="$group/@user_defined_group_id &gt; 0">
					
					<!-- //Members -->
					<div class="row">
						<div class="col-md-12 question">
							<fieldset class="entry question">
								<label class="entry question-content">Members</label>
								<div class="row">
									<xsl:for-each select="client">
										<div class="col-md-3">
											<div class="checkbox c-checkbox">
												<label>
													<input type="checkbox" name="member_id[]" value="{@client_id}">
														<xsl:if test="../group[@user_defined_group_id = $group/@user_defined_group_id]/member[@client_id = current()/@client_id]">
															<xsl:attribute name="checked">checked</xsl:attribute>
														</xsl:if>
														<xsl:if test="../group[@user_defined_group_id != $group/@user_defined_group_id][@attachable = '0']/member[@client_id = current()/@client_id]">
															<xsl:attribute name="checked">checked</xsl:attribute>
															<xsl:attribute name="disabled">diabled</xsl:attribute>
														</xsl:if>
													</input>
														<span class="fa fa-check"></span>
														<xsl:value-of select="@company_name" />
												</label>
											</div>
										</div>
									</xsl:for-each>
								</div>
							</fieldset>
						</div>
					</div>	

				</xsl:if>

				<div class="row">

					<!-- //Submit -->
					<div class="col-md-12">
						<div class="row">
							<div class="col-md-3">
								<a href="/members/dashboard/group/" class="btn btn-labeled btn-warning btn-block dashboard-button" data-action="cancel">
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

</xsl:stylesheet>