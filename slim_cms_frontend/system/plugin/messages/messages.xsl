<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">

	<!-- //Message > Message Plugin -->
	<xsl:template match="/config/plugin[@plugin = 'messages'][@method = 'index']">
		<xsl:choose>
			<xsl:when test="@mode = 'add'">
				<xsl:call-template name="add" />
			</xsl:when>
			<xsl:when test="@mode = 'edit'">
				<xsl:call-template name="edit" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="index" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- //Index message mode -->
	<xsl:template name="index">
		<div class="row">
			<div class="col-md-12">
				<table class="table table-striped data-table static" data-column-defs="[{{&quot;sortable&quot;: false, &quot;targets&quot;: [1]}}]">
					<thead>
						<tr>
							<th>ID</th>
							<th>Message</th>
							<th>Type</th>
							<th>Created</th>
							<th>Updated</th>
							<th class="text-right">Action</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="messages/message">
							<tr>
								<td>
									<xsl:value-of select="@message_id" />
								</td>
								<td>
									<xsl:value-of select="@message_subject" />
								</td>
								<td>
									<xsl:value-of select="@message_type" />
								</td>
								<td>
									<xsl:value-of select="@created_date" />
								</td>
								<td>
									<xsl:value-of select="@updated_date" />
								</td>
								<td class="text-right" width="100px">
									<a href="{concat(@url,'edit/', @message_id)}" role="button" class="btn btn-base btn-space" title="Edit">
										<i class="fa fa-pencil"></i>
									</a>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
		</div>
		<hr />
		<xsl:call-template name="index-buttons" />
	</xsl:template>

	<!-- //Index buttons -->
	<xsl:template name="index-buttons">
		<div class="row">
			<div class="col-md-2">
				<a href="{concat(@url,'add/')}" class="btn btn-success btn-block" role="button">Add Message</a>
			</div>
		</div>
	</xsl:template>

	<!-- //Add message mode -->
	<xsl:template name="add">
		<h3>Add Message</h3>
		<xsl:call-template name="message-view" />
	</xsl:template>

	<!-- //Edit message mode -->
	<xsl:template name="edit">
		<h3>Edit Message</h3>
		<xsl:call-template name="message-view" />
	</xsl:template>

	<!-- //Message view -->
	<xsl:template name="message-view">
		<xsl:choose>
			<xsl:when test="success">
				<div class="col-md-12">
					<div class="alert alert-success">
						<p><strong>Success</strong></p>
						<ul>
							<xsl:for-each select="success/item">
								<li>
									<xsl:value-of select="@message" disable-output-escaping="yes" />
								</li>
							</xsl:for-each>
						</ul>
					</div>
				</div>
			</xsl:when>
			<xsl:when test="error">
				<div class="col-md-12">
					<div class="alert alert-danger">
						<p><strong>Error</strong></p>
						<ul>
							<xsl:for-each select="error/item">
								<li>
									<xsl:value-of select="@message" />
								</li>
							</xsl:for-each>
						</ul>
					</div>
				</div>
			</xsl:when>
		</xsl:choose>
		<xsl:call-template name="message-form" />
	</xsl:template>

	<!-- //Add/Edit message form -->
	<xsl:template name="message-form" >
		<form method="post" data-parsley-validate="data-parsley-validate">
			<input type="hidden" name="mode" value="message-{@mode}" />
			<div class="row">
				<div class="col-md-12">
					<div class="form-group">
						<label class="control-label" for="message_subject">Subject *</label>
						<input type="text" class="form-control" id="message_subject" name="message_subject" required="required">
							<xsl:attribute name="value">
								<xsl:choose>
									<xsl:when test="input/@message_subject">
										<xsl:value-of select="input/@message_subject" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="messages/message[@message_id = current()/@message_id]/@message_subject" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</input>
					</div>
				</div>
			</div>

			<!-- //Row - Message Type -->
			<xsl:if test="count(client_emails/client_email) &gt; 0">
				<xsl:call-template name="clientEmail" />
			</xsl:if>

			<!-- //Row - Message Type -->
			<xsl:if test="count(message_types/message_type) &gt; 0">
				<xsl:call-template name="messageType" />
			</xsl:if>

			<!-- //Row - Message Content -->
			<div class="row">
				<div class="col-md-12">
					<div class="form-group">
						<label class="control-label" for="message_content">Message *</label>
						<textarea name="message_content" class="form-control" id="message_content" required="required" rows="5" cols="45">
							<xsl:choose>
								<xsl:when test="input/@message_content">
									<xsl:value-of select="input/@message_content" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="messages/message[@message_id = current()/@message_id]/@message_content" />
								</xsl:otherwise>
							</xsl:choose>
						</textarea>
					</div>
				</div>
			</div>

			<!-- //Row - Message SQL Query -->
			<div class="row">
				<div class="col-md-12">
					<div class="form-group">
						<label class="control-label" for="message_sql_query">Message Trigger (SQL)</label>
						<textarea class="form-control" id="message_sql_query" name="message_sql_query" rows="3" cols="45">
							<xsl:choose>
								<xsl:when test="input/@message_sql_query">
									<xsl:value-of select="input/@message_sql_query" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="messages/message[@message_id = current()/@message_id]/@message_sql_query" />
								</xsl:otherwise>
							</xsl:choose>
						</textarea>
					</div>
				</div>
			</div>

			<!-- //Row - Active field -->
			<div class="row">
				<div class="col-md-12">
					<div class="checkbox">
						<label>
							<input type="checkbox" class="form-check-input" id="message_active" name="message_active">
								<xsl:choose>
									<xsl:when test="input/@message_active">
										<xsl:if test="(input/@message_active = '0') = false">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<xsl:if test="(messages/message[@message_id = current()/@message_id]/@message_active = '0') = false">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
							</input>
							Active
						</label>
					</div>
				</div>
			</div>

			<hr />
			<xsl:call-template name="message-form-buttons" />
		</form>
	</xsl:template>

	<!-- //Message form buttons -->
	<xsl:template name="message-form-buttons">
		<div class="row">
			<div class="col-md-2">
				<button type="submit" class="btn btn-success btn-block" role="button" title="Save">Save</button>
			</div>
			<div class="col-md-2">
				<a href="{@url}" class="btn btn-warning btn-block" role="button" title="Cancel">Cancel</a>
			</div>
		</div>
	</xsl:template>

	<!-- //Row - Message Type -->
	<xsl:template name="messageType">
		<div class="row">
			<div class="col-md-12">
				<div class="form-group">
					<label class="control-label" for="message_type">Type *</label>
					<select class="form-control chosen-select message_type" id="message_type" name="message_type" required="required">
						<xsl:if test="count(message_types/message_type) &gt; 1">
							<option value="">-- Select --</option>
						</xsl:if>
						<xsl:for-each select="message_types/message_type">
							<option value="{@message_type_id}">
								<xsl:if test="../../messages/message[@message_type_id = current()/@message_type_id]/@message_type=@message_type">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="@message_type" />
							</option>
						</xsl:for-each>
					</select>
				</div>
			</div>
		</div>

	</xsl:template>

	<!-- //Row - Message Type -->
	<xsl:template name="clientEmail">
		<div class="row">
			<div class="col-md-12">
				<div class="form-group">
					<label class="control-label" for="client_email">Recipients *</label>
					<select id="client_email" name="client_email[]" class="form-control chosen-select client_email" required="required" multiple="multiple" data-placeholder="-- select --">
						<xsl:for-each select="client_emails/client_email">
							<xsl:sort select="@company_name"/>
							<xsl:sort select="@firstname"/>
							<xsl:sort select="@lastname"/>
							<xsl:sort select="@email"/>
							<option value="{@client_contact_id}">
								<xsl:if test="../../selected_client_emails/selected_client_email[@client_contact_id=@client_contact_id]/@client_contact_id = @client_contact_id">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="@company_name" />
								<xsl:value-of select="@firstname" />
								<xsl:value-of select="@lastname" />
								<xsl:value-of select="@email" />
							</option>
						</xsl:for-each>
					</select>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>