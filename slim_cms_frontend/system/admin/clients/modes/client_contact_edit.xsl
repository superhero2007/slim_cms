<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:str="http://exslt.org/strings"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config[@mode = 'client_contact_edit']">
		<xsl:variable name="client" select="client[@client_id = current()/globals/item[@key = 'client_id']/@value]" />
		<xsl:variable name="client_contact" select="client_contact[@client_contact_id = current()/globals/item[@key = 'client_contact_id']/@value]" />
		<xsl:variable name="return_values" select="return_values" />
		<xsl:variable name="password_return_values" select="password_return_values" />
		<xsl:variable name="error" select="error" />
		
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=clients">Client List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_edit&amp;client_id={$client/@client_id}"><xsl:value-of select="$client/@company_name" /></a>
			<xsl:text> &gt; </xsl:text>
			
			<a href="?page=clients&amp;mode=client_contact_edit&amp;client_id={$client/@client_id}&amp;client_contact_id={$client_contact/@client_contact_id}">
				<xsl:choose>
					<xsl:when test="$client_contact">
						<!--<xsl:value-of select="concat($client_contact/@salutation,' ',$client_contact/@firstname,' ',$client_contact/@lastname)" />-->
						<xsl:value-of select="concat($client_contact/@firstname,' ',$client_contact/@lastname)" />
					</xsl:when>
					<xsl:otherwise>Add Client Contact</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Client Contact</h1>
		<form method="post" action="" enctype="multipart/form-data">
			<input type="hidden" name="action" value="client_contact_save" />
			<input type="hidden" name="client_contact_id" value="{$client_contact/@client_contact_id}" />
			<input type="hidden" name="client_id" value="{$client/@client_id}" />
			<input type="hidden" name="sequence" value="{$client_contact/@sequence}" />
			<table class="editTable">
				<thead>
					<tr>
						<th colspan="2">
						</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Client Contact" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="col"><label for="firstname">First Name:</label></th>
						<td>
							<xsl:choose>
								<xsl:when test="$error/@firstname">
									<span class="error"><xsl:value-of select="$error/@firstname" /></span><br />
									<input type="text" id="firstname" name="firstname" class="form_error" value="{$return_values/@firstname}" />
								</xsl:when>
								<xsl:when test="$return_values">
									<input type="text" id="firstname" name="firstname" value="{$return_values/@firstname}" />
								</xsl:when>
								<xsl:otherwise>
									<input type="text" id="firstname" name="firstname" value="{$client_contact/@firstname}" />
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="lastname">Last Name:</label></th>
						<td>
							<xsl:choose>
								<xsl:when test="$error/@lastname">
									<span class="error"><xsl:value-of select="$error/@lastname" /></span><br />
									<input type="text" id="lastname" name="lastname" class="form_error" value="{$return_values/@lastname}" />
								</xsl:when>
								<xsl:when test="$return_values">
									<input type="text" id="lastname" name="lastname" value="{$return_values/@lastname}" />
								</xsl:when>
								<xsl:otherwise>
									<input type="text" id="lastname" name="lastname" value="{$client_contact/@lastname}" />
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="position">Title / Position:</label></th>
						<td>
							<xsl:choose>
								<xsl:when test="$error/@position">
									<span class="error"><xsl:value-of select="$error/@position" /></span><br />
									<input type="text" id="position" name="position" class="form_error" value="{$return_values/@position}" />
								</xsl:when>
								<xsl:when test="$return_values">
									<input type="text" id="position" name="position" value="{$return_values/@position}" />
								</xsl:when>
								<xsl:otherwise>
									<input type="text" id="position" name="position" value="{$client_contact/@position}" />
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="email">Email:</label></th>
						<td>
							<xsl:choose>
								<xsl:when test="$error/@email">
									<span class="error"><xsl:value-of select="$error/@email" /></span><br />
									<input type="text" id="email" name="email" class="form_error" value="{$return_values/@email}" />
								</xsl:when>
								<xsl:when test="$return_values">
									<input type="text" id="email" name="email" value="{$return_values/@email}" />
								</xsl:when>
								<xsl:otherwise>
									<input type="text" id="email" name="email" value="{$client_contact/@email}" />
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="phone">Phone:</label></th>
						<td>
							<xsl:choose>
								<xsl:when test="$error/@phone">
									<span class="error"><xsl:value-of select="$error/@phone" /></span><br />
									<input type="text" id="phone" name="phone" class="form_error" value="{$return_values/@phone}" />
								</xsl:when>
								<xsl:when test="$return_values">
									<input type="text" id="phone" name="phone" value="{$return_values/@phone}" />
								</xsl:when>
								<xsl:otherwise>
									<input type="text" id="phone" name="phone" value="{$client_contact/@phone}" />
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<xsl:if test="/config/user/@client_type_id != '0'">
							<xsl:attribute name="class">hidden-data</xsl:attribute>
						</xsl:if>
						<th scope="col"><label for="is_client_admin">Client Admin:</label></th>
						<td>
							<label>
								<input type="checkbox" id="is_client_admin" name="is_client_admin" value="1">
									<xsl:choose>
										<xsl:when test="$return_values">
										<xsl:if test="$return_values/@is_client_admin = 1">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
										</xsl:when>
										<xsl:otherwise>
											<xsl:if test="$client_contact/@is_client_admin = 1 or not($client_contact)">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					
					<!-- //Added for option to disable automated emails -->
					<tr>
						<xsl:if test="/config/user/@client_type_id != '0'">
							<xsl:attribute name="class">hidden-data</xsl:attribute>
						</xsl:if>
						<th scope="col"><label for="send_auto_emails">Send Auto Emails:</label></th>
						<td>
							<input type="hidden" name="send_auto_emails" value="0" />
							<label>
								<input type="checkbox" id="send_auto_emails" name="send_auto_emails" value="1">
									<xsl:choose>
										<xsl:when test="$return_values">
										<xsl:if test="$return_values/@send_auto_emails = 1">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
										</xsl:when>
										<xsl:otherwise>
											<xsl:if test="$client_contact/@send_auto_emails = 1 or not($client_contact)">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					
					<!-- //Added option for locking of user accounts -->
					<tr>
						<xsl:if test="/config/user/@client_type_id != '0'">
							<xsl:attribute name="class">hidden-data</xsl:attribute>
						</xsl:if>
						<th scope="col"><label for="send_auto_emails">Lock Account:</label></th>
						<td>
							<input type="hidden" name="locked_out" value="0" />
							<label>
								<input type="checkbox" id="locked_out" name="locked_out" value="1">
									<xsl:choose>
										<xsl:when test="$return_values">
										<xsl:if test="$return_values/@locked_out = 1">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
										</xsl:when>
										<xsl:otherwise>
											<xsl:if test="$client_contact/@locked_out = 1">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					
					<!-- //Added option for locking of user accounts -->
					<tr>
						<xsl:if test="/config/user/@client_type_id != '0'">
							<xsl:attribute name="class">hidden-data</xsl:attribute>
						</xsl:if>
						<th scope="col"><label for="send_auto_emails">Locked Out Expiry:<br />e.g; 2014-10-20 08:00:00<br />Set to 0 for infinite lockout</label></th>
						<td>
							<xsl:choose>
								<xsl:when test="$error/@locked_out_expiry">
									<span class="error"><xsl:value-of select="$error/@locked_out_expiry" /></span><br />
									<input type="text" id="locked_out_expiry" name="locked_out_expiry" class="form_error" value="{$return_values/@locked_out_expiry}" />
								</xsl:when>
								<xsl:when test="$return_values">
									<input type="text" id="locked_out_expiry" name="locked_out_expiry" value="{$return_values/@locked_out_expiry}" />
								</xsl:when>
								<xsl:otherwise>
									<input type="text" id="locked_out_expiry" name="locked_out_expiry" value="{$client_contact/@locked_out_expiry}" />
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					
					<!-- //If the client is a business_owner allow photo uploads -->
					<xsl:if test="$client/@client_type_id = '2' or $client/@client_type_id = '16'">
					<tr>
						<th scope="col"><label for="display_contact_photo">Display Contact Photo:</label></th>
						<td>
							<input type="hidden" name="display_contact_photo" value="0" />
							<label>
								<input type="checkbox" id="display_contact_photo" name="display_contact_photo" value="1">
									<xsl:choose>
										<xsl:when test="$return_values">
										<xsl:if test="$return_values/@display_contact_ph0to = 1">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
										</xsl:when>
										<xsl:otherwise>
											<xsl:if test="$client_contact/@display_contact_photo = 1 or not($client_contact)">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<!--//URL for business owners -->
						<th scope="col"><label for="url">Business Owner URL:</label></th>
						<td>
							<xsl:choose>
								<xsl:when test="$error/@url">
									<span class="error"><xsl:value-of select="$error/@url" /></span><br />
									<input type="text" id="url" name="url" class="form_error" value="{$return_values/@url}" />
								</xsl:when>
								<xsl:when test="$return_values">
									<input type="text" id="url" name="url" value="{$return_values/@url}" />
								</xsl:when>
								<xsl:otherwise>
									<input type="text" id="url" name="url" value="{$client_contact/@url}" />
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
						<tr>
							<th scope="col"><label for="photo_upload">Upload Photo<br />Must be 130x180 pixels:</label></th>
							<td>
								<input type="file" id="photo" name="photo" />
								<xsl:if test="$client_contact/@photo = 'yes'">
									<br /><img src="/_images/partners/business_owner_contact_{$client_contact/@client_contact_id}.gif" />
								</xsl:if>
							</td>
						</tr>
                        <tr>
							<th scope="col"><label for="description">Description<br />(XHTML):</label></th>
							<td>
								<textarea rows="10" id="description" name="description">
                                	<xsl:value-of select="$client_contact/@description" />
                                </textarea>
							</td>
						</tr>
					</xsl:if>
				</tbody>
			</table>
		</form>
		
		<!-- //Once the client contact has been created, allow access to other fields -->
		<xsl:if test="$client_contact/@client_contact_id != '0'">
			<xsl:call-template name="clientContactPassword" />
			<xsl:call-template name="clientContactDashboardAccess" />
		</xsl:if>
		
	</xsl:template>

	<xsl:template name="clientContactPassword">
		<xsl:variable name="client" select="client[@client_id = current()/globals/item[@key = 'client_id']/@value]" />
		<xsl:variable name="client_contact" select="client_contact[@client_contact_id = current()/globals/item[@key = 'client_contact_id']/@value]" />
		<xsl:variable name="return_values" select="return_values" />
		<xsl:variable name="password_return_values" select="password_return_values" />
		<xsl:variable name="error" select="error" />

		<h1>Set Client Contact Password</h1>
		<form method="post" action="" enctype="multipart/form-data">
			<input type="hidden" name="action" value="client_contact_set_password" />
			<input type="hidden" name="client_contact_id" value="{$client_contact/@client_contact_id}" />
			<input type="hidden" name="client_id" value="{$client/@client_id}" />
			<table class="editTable">
				<thead>
					<tr>
						<th colspan="2">
						</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Password" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="col"><label for="firstname">Password:</label></th>
						<td>
							<xsl:choose>
								<xsl:when test="$error/@password_0">
									<span class="error"><xsl:value-of select="$error/@password_0" /></span><br />
									<input type="password" id="password_0" name="password_0" class="form_error" value="{$password_return_values/@password_0}" />
								</xsl:when>
								<xsl:when test="$return_values">
									<input type="password" id="password_0" name="password_0" value="{$password_return_values/@password_0}" />
								</xsl:when>
								<xsl:otherwise>
									<input type="password" id="password_0" name="password_0" value="" />
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="lastname">Confirm Password:</label></th>
						<td>
							<xsl:choose>
								<xsl:when test="$error/@password_1">
									<span class="error"><xsl:value-of select="$error/@password_1" /></span><br />
									<input type="password" id="password_1" name="password_1" class="form_error" value="{$password_return_values/@password_1}" />
								</xsl:when>
								<xsl:when test="$return_values">
									<input type="password" id="password_1" name="password_1" value="{$password_return_values/@password_1}" />
								</xsl:when>
								<xsl:otherwise>
									<input type="password" id="password_1" name="password_1" value="" />
								</xsl:otherwise>
							</xsl:choose>
							<br /><p>The password must be between 8 and 60 characters and contain an upper case letter, a number and a non-alphanumeric caracter.</p>
						</td>
					</tr>

				</tbody>
			</table>
		</form>
	</xsl:template>	

	<xsl:template name="clientContactDashboardAccess">
		<xsl:variable name="client" select="client[@client_id = current()/globals/item[@key = 'client_id']/@value]" />
		<xsl:variable name="client_contact" select="client_contact[@client_contact_id = current()/globals/item[@key = 'client_contact_id']/@value]" />
		<xsl:variable name="return_values" select="return_values" />
		<xsl:variable name="password_return_values" select="password_return_values" />
		<xsl:variable name="error" select="error" />

		<h1>Set Client Contact Dashboard</h1>
		<form method="post" action="" enctype="multipart/form-data">
			<input type="hidden" name="action" value="client_contact_save_dashboard" />
			<input type="hidden" name="client_contact_id" value="{$client_contact/@client_contact_id}" />
			<input type="hidden" name="client_id" value="{$client/@client_id}" />
			<table class="editTable">
				<thead>
					<tr>
						<th colspan="2">
						</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="col"><label for="enabled">Dashboard Access:</label></th>
						<td>
							<select id="dashboard-enabled" name="enabled">
								<option value="0">Disabled</option>
								<option value="1">
									<xsl:if test="/config/client_contact_2_dashboard[@client_contact_id = $client_contact/@client_contact_id]">
										<xsl:attribute name="selected" value="selected" />
									</xsl:if>
									Enabled
								</option>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="dashboard-group">Group:</label></th>
						<td>
							<select id="dashboard-group" name="dashboard_group_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="/config/dashboard_group">
									<option value="{@dashboard_group_id}">
										<xsl:if test="/config/client_contact_2_dashboard[@client_contact_id = $client_contact/@client_contact_id]/@dashboard_group_id = current()/@dashboard_group_id">
											<xsl:attribute name="selected" value="selected" />
										</xsl:if>
										<xsl:value-of select="@label" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="dashboard-role">Role:</label></th>
						<td>
							<select id="dashboard-role" name="dashboard_role_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="/config/dashboard_role">
									<option value="{@dashboard_role_id}">
										<xsl:if test="/config/client_contact_2_dashboard[@client_contact_id = $client_contact/@client_contact_id]/@dashboard_role_id = current()/@dashboard_role_id">
											<xsl:attribute name="selected" value="selected" />
										</xsl:if>
										<xsl:value-of select="@name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>	

	
	<xsl:template match="error">
		<span class="error">
			<xsl:value-of select="." />
		</span><br />
	</xsl:template>

</xsl:stylesheet>