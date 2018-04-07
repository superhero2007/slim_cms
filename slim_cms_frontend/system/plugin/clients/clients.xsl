<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">

	<!-- //Include other templates -->
	<xsl:include href="login-form.xsl" />
	<xsl:include href="register-form.xsl" />
	<xsl:include href="legacy-templates.xsl" />
	<xsl:include href="add-client.xsl" />

	<!-- //Check to see the client type, if the client has dashboard access, render the dashboard menu option -->
	<xsl:template match="dashboard-menu" mode="html">
		<xsl:if test="/config/plugin[@plugin = 'clients']/client/dashboard">
			<li class="icon-item dashboard-menu">
			    <a href="/members/dashboard/" class="icon-item-link">
		            <div class="icon-block-item btn-b-white btn-icon">
		                <i class="fa fa-dashboard"></i>
		             </div>
					<span class="icon-title">Dashboard</span>
			    </a>
			</li>
		</xsl:if>
	</xsl:template>

	<!-- //Check to see the client type, if the client has GHG module access, render the dashboard menu option -->
	<xsl:template match="ghg-menu" mode="html">
		<xsl:if test="/config/plugin[@plugin = 'clients']/client/contact[@client_contact_id = ../@client_contact_id]/module[@module = 'ghg']">
			<li class="icon-item dashboard-menu">
			    <a href="/members/ghg-assessment/" class="icon-item-link">
		            <div class="icon-block-item btn-b-white btn-icon">
		                <i class="fa fa-industry"></i>
		             </div>
					<span class="icon-title">GHG</span>
			    </a>
			</li>
		</xsl:if>
	</xsl:template>

	<!-- //Client Name -->
	<xsl:template match="client-name" mode="html">
		<xsl:if test="/config/plugin[@plugin = 'clients']/client/@company_name">
			<xsl:value-of select="/config/plugin[@plugin = 'clients']/client/@company_name" />
		</xsl:if>
	</xsl:template>

	<!-- //Secure Template for Login -->
	<xsl:template match="secure" mode="html">
		<xsl:choose>
			<!-- //Dashboard Login -->
			<xsl:when test="@scope = 'dashboard'">
				<xsl:call-template name="dashboard-secure" />
			</xsl:when>
			<!-- //Standard Login -->
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="/config/plugin[@plugin = 'clients'][@method = 'login']/@type = 'legacy'">
						<xsl:call-template name="secure-legacy" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="secure" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- //Renders Content based on permissions -->
	<xsl:template match="component" mode="html">
		<xsl:choose>
			<xsl:when test="@scope">
				<xsl:choose>
					<xsl:when test="@scope = 'dashboard' and /config/plugin[@plugin = 'clients'][@method = 'login']/client/dashboard">
						<xsl:choose>
							<xsl:when test="@role and @role = /config/plugin[@plugin = 'clients'][@method = 'login']/client/dashboard/@dashboard_role_id">
								<xsl:apply-templates select="*[name() != 'insecure']" mode="html" />
							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[name() != 'insecure']" mode="html" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- //template to check login and access for dashboard users -->
	<xsl:template name="dashboard-secure">
		<xsl:choose>
			<xsl:when test="/config/plugin[@plugin = 'clients'][@method = 'login']/client/dashboard">
				<xsl:apply-templates select="*[name() != 'insecure']" mode="html" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="login-form" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- //template to check login and access for standard users -->
	<xsl:template name="secure">
		<xsl:choose>
			<xsl:when test="/config/plugin[@plugin = 'clients'][@method = 'login']/client">
				<xsl:apply-templates select="*[name() != 'insecure']" mode="html" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="@action = 'no-login'"></xsl:when>
					<xsl:when test="@login = 'false'"></xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="login" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- //Login/Register Template -->
	<xsl:template name="login">
		<div class="row">
			<xsl:choose>
				<!-- //Login and Register -->
				<xsl:when test="/config/plugin[@plugin = 'clients'][@method = 'login']/@register = 'true'">
					<!-- //Errors -->
					<div class="col-md-12">
						<xsl:call-template name="display-errors" />
					</div>
					<div class="col-md-4">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h2>Login</h2>
							</div>
							<div class="panel-body">
								<xsl:call-template name="login-form" />
							</div>
						</div>
					</div>
					<div class="col-md-8">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h2>Register</h2>
							</div>
							<div class="panel-body">
								<xsl:call-template name="register-form" />
							</div>
						</div>
					</div>
				</xsl:when>
				<!-- //Login Only -->
				<xsl:otherwise>
					<div class="col-md-4 col-md-offset-4">
						<xsl:call-template name="display-errors" />
					</div>
					<div class="col-md-4 col-md-offset-4">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h2>Login</h2>
							</div>
							<div class="panel-body">
								<xsl:call-template name="login-form" />
							</div>
						</div>
					</div>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template name="display-errors">
		<xsl:param name="node" select="/config/plugin[@plugin = 'clients'][@method = 'login']" />
		<!-- //Display any logout/lockout messages -->
		<xsl:if test="/config/globals/item[@key = 'logout'] or count($node/error) &gt; 0">
			<div class="login-form-errors">
				<div class="alert alert-danger margin-top-20">

					<!-- //Logout Messages -->
					<xsl:choose>
						<xsl:when test="/config/globals/item[@key = 'logout'][@value = 'session']">
							<p>Your session has been logged out because this account has logged on from another location.</p>
						</xsl:when>
						<xsl:when test="/config/globals/item[@key = 'logout'][@value = 'login-fail']">
							<p>This account has been locked due to multiple failed login attempts. Please try again later.</p>
						</xsl:when>
						<xsl:when test="/config/globals/item[@key = 'logout'][@value = 'locked']">
							<p>This account has been locked. Please try again later.</p>
						</xsl:when>
					</xsl:choose>

					<!-- //Error Messages -->
					<xsl:for-each select="$node/error">
						<p><xsl:value-of select="." /></p>
					</xsl:for-each>

				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="display-email">
		<xsl:param name="email"/>
		<a href="mailto:{$email}"><xsl:value-of select="$email"/></a>
	</xsl:template>
	
	<xsl:template name="display-name">
		<xsl:param name="contact"/>
		<xsl:value-of select="$contact/@firstname"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$contact/@lastname"/>	
	</xsl:template>
	
	<xsl:template name="contact-edit-form">
		<xsl:param name="contact"/>
		<xsl:param name="formAction"/>
		<xsl:param name="client"/>
		
		<xsl:variable name="currentAction" select="/config/globals/item[@key = 'action']/@value"/>
		
		<form action="?" method="POST" class="account-management sky-form" autocomplete="off">
			<input type="hidden" name="action" value="{$formAction}" />
			<xsl:if test="$contact">
				<input type="hidden" name="client_contact_id" value="{$contact/@client_contact_id}" />
				<input type="hidden" name="client_id" value="{$contact/@client_id}" />
			</xsl:if>
			<xsl:if test="$client and not($contact)">
				<input type="hidden" name="client_id" value="{$client/@client_id}" />
			</xsl:if>
            
            <div class="table-responsive">
				<table class="property-form table">
					<col style="width: 25%;" />
					<col style="width: 75%;" />
					<tbody>
						<xsl:if test="$client">
							<tr>
								<th scope="row">Entity:</th>
								<td><xsl:value-of select="$client/@company_name"/></td>
							</tr>
						</xsl:if>
						<tr>
							<th scope="row">First Name:</th>
							<td>
								<xsl:apply-templates select="error[@field = 'firstname']" />
								<input type="text" name="firstname" id="contact_firstname">
									<xsl:attribute name="value">
										<xsl:choose>
											<xsl:when test="$formAction = $currentAction"><xsl:value-of select="/config/globals/item[@key = 'firstname']/@value" /></xsl:when>
											<xsl:when test="$contact and $contact/@firstname"><xsl:value-of select="$contact/@firstname"/></xsl:when>
										</xsl:choose>
									</xsl:attribute>
								</input>
							</td>
						</tr>
						<tr>
							<th scope="row">Last Name:</th>
							<td>
								<xsl:apply-templates select="error[@field = 'lastname']" />
								<input type="text" name="lastname" id="contact_lastname">
									<xsl:attribute name="value">
										<xsl:choose>
											<xsl:when test="$formAction = $currentAction"><xsl:value-of select="/config/globals/item[@key = 'lastname']/@value" /></xsl:when>
											<xsl:when test="$contact and $contact/@lastname"><xsl:value-of select="$contact/@lastname"/></xsl:when>
										</xsl:choose>
									</xsl:attribute>
								</input>
							</td>
						</tr>
						<tr>
							<th scope="row">Position:</th>
							<td>
								<input type="text" name="position" id="contact_position">
									<xsl:attribute name="value">
										<xsl:choose>
											<xsl:when test="$formAction = $currentAction"><xsl:value-of select="/config/globals/item[@key = 'position']/@value" /></xsl:when>
											<xsl:when test="$contact"><xsl:value-of select="$contact/@position"/></xsl:when>
										</xsl:choose>
									</xsl:attribute>
								</input>
							</td>
						</tr>
						<tr>
							<th scope="row">Phone:</th>
							<td>
								<input type="text" name="phone" id="contact_phone">
									<xsl:attribute name="value">
										<xsl:choose>
											<xsl:when test="$formAction = $currentAction"><xsl:value-of select="/config/globals/item[@key = 'phone']/@value" /></xsl:when>
											<xsl:when test="$contact"><xsl:value-of select="$contact/@phone"/></xsl:when>
										</xsl:choose>
									</xsl:attribute>
								</input>
							</td>
						</tr>
						<tr>
							<th scope="row">Email:</th>
							<td>
								<xsl:apply-templates select="error[@field = 'email']" />
								<input type="text" name="email" id="contact_email" autocomplete="off">
									<xsl:attribute name="value">
										<xsl:choose>
											<xsl:when test="$formAction = $currentAction"><xsl:value-of select="/config/globals/item[@key = 'email']/@value" /></xsl:when>
											<xsl:when test="$contact"><xsl:value-of select="$contact/@email"/></xsl:when>
										</xsl:choose>
									</xsl:attribute>
								</input>
							</td>
						</tr>
						
						<!-- //Added password fields -->
						<xsl:if test="$formAction = 'contactCreate'">
							<tr>
								<th scope="row">Password:</th>
								<td>
									<xsl:apply-templates select="error[@field = 'password_0']" />
									<input type="password" name="password_0" id="password_0" maxlengh="60" value="{/config/globals/item[@key = 'password_0']/@value}"  autocomplete="off" />
								</td>
							</tr>
							<tr>
								<th scope="row">Confirm Password:</th>
								<td>
									<input type="password" name="password_1" id="password_1" maxlengh="60" value="{/config/globals/item[@key = 'password_1']/@value}"  autocomplete="off" />
						<br /><br />
						<small><strong>Your password must be between 8 and 60 characters and contain an upper case letter, a number and a non-alphanumeric character.</strong></small>
								</td>
							</tr>
						</xsl:if>
	                    <tr>
	                        <th scope="row"></th>
	                        <td class="edit">
	                            <a href="?" style="text-decoration:none;"><button type="button">Cancel</button></a>
	                            <xsl:text> </xsl:text>	
	                            <input type="submit" value="Save User" />
	                        </td>
	                    </tr>
					</tbody>
				</table>
			</div>
		</form>
		
	</xsl:template>
	
	<xsl:template name="contact-change-password-form">
		<xsl:param name="contact"/>
		
		<form action="" method="POST" class="account-management sky-form" autocomplete="off">
			<input type="hidden" name="action" value="contactChangePassword" />
			<input type="hidden" name="client_id" value="{$contact/@client_id}" />
			<input type="hidden" name="client_contact_id" value="{$contact/@client_contact_id}" />
			<table class="property-form">
				<col style="width: 25%;" />
				<col style="width: 75%;" />
				<tbody>
					<tr>
						<th scope="row">Email:</th>
						<td>
							<xsl:value-of select="$contact/@email"/>
						</td>
					</tr>
					<tr>
						<th scope="row">New Password:</th>
						<td>
							<xsl:apply-templates select="error[@field = 'password_0']" />
							<input type="password" name="password_0" id="password_0" value="{/config/globals/item[@key = 'password_0']/@value}" />
						</td>
					</tr>
					<tr>
						<th scope="row">Confirm New Password:</th>
						<td>
							<xsl:apply-templates select="error[@field = 'password_1']" />
							<input type="password" name="password_1" id="password_1" value="{/config/globals/item[@key = 'password_1']/@value}" />
					<br /><br />
					<small><strong>Your password must be between 8 and 60 characters and contain an upper case letter, a number and a non-alphanumeric character.</strong></small>
						</td>
					</tr>
					<tr>
						<th scope="row"></th>
						<td>
							<input type="submit" value="Change Password" />
							<xsl:text> </xsl:text>
							<a href="?" style="text-decoration:none;"><button type="button">Cancel</button></a>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
		
	</xsl:template>
	
	<!-- New Contact -->
	<xsl:template match="/config/plugin[@plugin = 'clients'][@method = 'updateClient'][/config/globals/item[@key = 'action'][@value = 'contactNew' or @value = 'contactCreate' or @value = 'contactEdit' or @value = 'contactEditSave' or @value = 'contactChangePassword']]">
		<xsl:variable name="client" select="/config/plugin[@plugin = 'clients'][@method = 'login']/client"/>
		<xsl:variable name="currentContact" select="$client/contact[1]"/>
		<xsl:variable name="action" select="/config/globals/item[@key = 'action']/@value"/>
		<xsl:variable name="requestedContact" select="/config/plugin[@plugin = 'clients'][@method = 'updateClient']/requested_client_contact/client_contact[1]"/>
			<div class="with-border" id="contact-display-panel">
				<xsl:choose>
					<xsl:when test="$action = 'contactNew' or $action = 'contactCreate'">
						<h1 class="text-light">New User</h1>
						<xsl:call-template name="contact-edit-form">
							<xsl:with-param name="formAction" select="'contactCreate'"/>
							<xsl:with-param name="client" select="$client"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$action = 'contactChangePassword'">
						<h1 class="text-light">Change Password</h1>
						<xsl:call-template name="contact-change-password-form">
							<xsl:with-param name="contact" select="$requestedContact"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<h1 class="text-light">Edit User</h1>
						<xsl:call-template name="contact-edit-form">
							<xsl:with-param name="formAction" select="'contactEditSave'"/>
							<xsl:with-param name="client" select="$client"/>
							<xsl:with-param name="contact" select="$requestedContact"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</div>

	</xsl:template>
	
	<!-- All Existing Account Management -->
	<xsl:template match="/config/plugin[@plugin = 'clients'][@method = 'updateClient'][not(/config/globals/item[@key = 'action']) or /config/globals/item[@key = 'action'][@value != 'contactNew'][@value != 'contactCreate'][@value != 'contactEdit'][@value != 'contactEditSave'][@value != 'contactChangePassword']]">
		<xsl:variable name="client" select="/config/plugin[@plugin = 'clients'][@method = 'login']/client"/>
		<xsl:variable name="currentContact" select="$client/contact[1]"/>
		<xsl:variable name="allContacts" select="/config/plugin[@plugin = 'clients'][@method = 'updateClient']/all_client_contacts"/>
		<xsl:variable name="action" select="/config/globals/item[@key = 'action']/@value"/>
		
			<div class="with-border" id="client-display-panel">
				<h1 class="text-light">Account Details</h1>
				
                <xsl:variable name="form-state">
                    <xsl:choose>
                        <xsl:when test="$action = 'clientEdit' or $action = 'clientSave'">enabled</xsl:when>
                        <xsl:otherwise>disabled</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                        
                <!-- Editing Client Form -->
                <form action="?" method="POST" class="account-management sky-form" autocomplete="off">
                    <input type="hidden" name="action" value="clientSave" />
                    <input type="hidden" name="client_id" value="{$client/@client_id}" />
                    <div class="table-responsive">
	                    <table class="property-form table">
	                        <col style="width: 25%;" />
	                        <col style="width: 75%" />
	                        <tbody>
	                            <tr>
	                                <th scope="row">Entity Name:</th>
	                                <td class="edit">
	                                    <xsl:apply-templates select="error[@field = 'company_name']" />
	                                    <input type="text" name="company_name" id="client_company_name">
	                                        <xsl:attribute name="value">
	                                            <xsl:choose>
	                                                <xsl:when test="$action = 'clientSave'"><xsl:value-of select="/config/globals/item[@key = 'company_name']/@value" /></xsl:when>
	                                                <xsl:otherwise><xsl:value-of select="$client/@company_name"/></xsl:otherwise>
	                                            </xsl:choose>
	                                        </xsl:attribute>
	                                        <xsl:if test="$form-state = 'disabled'">
	                                            <xsl:attribute name="disabled">disabled</xsl:attribute>
	                                        </xsl:if>
	                                    </input>
	                                </td>
	                            </tr>
	                            <tr>
	                                <th scope="row">Address Line 1:</th>
	                                <td class="edit">
	                                    <input type="text" name="address_line_1" id="client_address_line_1">
	                                        <xsl:attribute name="value">
	                                            <xsl:choose>
	                                                <xsl:when test="$action = 'clientSave'"><xsl:value-of select="/config/globals/item[@key = 'address_line_1']/@value" /></xsl:when>
	                                                <xsl:otherwise><xsl:value-of select="$client/@address_line_1"/></xsl:otherwise>
	                                            </xsl:choose>
	                                        </xsl:attribute>
	                                        <xsl:if test="$form-state = 'disabled'">
	                                            <xsl:attribute name="disabled">disabled</xsl:attribute>
	                                        </xsl:if>
	                                    </input>
	                                </td>
	                            </tr>
	                            <tr>
	                                <th scope="row">Address Line 2:</th>
	                                <td class="edit">
	                                    <input type="text" name="address_line_2" id="client_address_line_2">
	                                        <xsl:attribute name="value">
	                                            <xsl:choose>
	                                                <xsl:when test="$action = 'clientSave'"><xsl:value-of select="/config/globals/item[@key = 'address_line_2']/@value" /></xsl:when>
	                                                <xsl:otherwise><xsl:value-of select="$client/@address_line_2"/></xsl:otherwise>
	                                            </xsl:choose>
	                                        </xsl:attribute>
	                                        <xsl:if test="$form-state = 'disabled'">
	                                            <xsl:attribute name="disabled">disabled</xsl:attribute>
	                                        </xsl:if>
	                                    </input>
	                                </td>
	                            </tr>
	                            <tr>
	                                <th scope="row">City:</th>
	                                <td class="edit">
	                                    <xsl:apply-templates select="error[@field = 'suburb']" />
	                                    <input type="text" name="suburb" id="suburb">
	                                        <xsl:attribute name="value">
	                                            <xsl:choose>
	                                                <xsl:when test="$action = 'clientSave'"><xsl:value-of select="/config/globals/item[@key = 'suburb']/@value" /></xsl:when>
	                                                <xsl:otherwise><xsl:value-of select="$client/@suburb"/></xsl:otherwise>
	                                            </xsl:choose>
	                                        </xsl:attribute>
	                                        <xsl:if test="$form-state = 'disabled'">
	                                            <xsl:attribute name="disabled">disabled</xsl:attribute>
	                                        </xsl:if>
	                                    </input>
	                                </td>
	                            </tr>
	                            <tr>
	                                <th scope="row">State:</th>
	                                <td class="edit">
	                                    <xsl:apply-templates select="error[@field = 'state']" />
	                                    <input type="text" name="state" id="state">
	                                        <xsl:attribute name="value">
	                                            <xsl:choose>
	                                                <xsl:when test="$action = 'clientSave'"><xsl:value-of select="/config/globals/item[@key = 'state']/@value" /></xsl:when>
	                                                <xsl:otherwise><xsl:value-of select="$client/@state"/></xsl:otherwise>
	                                            </xsl:choose>
	                                        </xsl:attribute>
	                                        <xsl:if test="$form-state = 'disabled'">
	                                            <xsl:attribute name="disabled">disabled</xsl:attribute>
	                                        </xsl:if>
	                                    </input>
	                                </td>
	                            </tr>
	                            <tr>
	                                <th scope="row">Post Code:</th>
	                                <td class="edit">
	                                    <xsl:apply-templates select="error[@field = 'postcode']" />
	                                    <input type="text" name="postcode" id="postcode">
	                                        <xsl:attribute name="value">

	                                            <xsl:choose>
	                                                <xsl:when test="$action = 'clientSave'"><xsl:value-of select="/config/globals/item[@key = 'postcode']/@value" /></xsl:when>
	                                                <xsl:otherwise><xsl:value-of select="$client/@postcode"/></xsl:otherwise>
	                                            </xsl:choose>
	                                        </xsl:attribute>
	                                        <xsl:if test="$form-state = 'disabled'">
	                                            <xsl:attribute name="disabled">disabled</xsl:attribute>
	                                        </xsl:if>
	                                     </input>
	                                </td>
	                            </tr>
	                            <tr>
	                                <td colspan="2" class="edit">
	                                    <xsl:choose>
	                                        <xsl:when test="$form-state = 'disabled'">
	                                            <a href="?action=clientEdit" style="text-decoration:none;"><button type="button">Edit Account</button></a>
	                                        </xsl:when>
	                                        <xsl:otherwise>
	                                            <a href="?" style="text-decoration:none;"><button type="button">Cancel</button></a>
	                                            <xsl:text> </xsl:text>	
	                                            <input type="submit" value="Save Account" style="width:120px;" />
	                                        </xsl:otherwise>
	                                    </xsl:choose>
	                                </td>
	                            </tr>
	                        </tbody>
	                    </table>
                	</div>
                </form>
		<!-->				
				<script type="text/javascript" charset="utf-8">
                <xsl:comment>
                //<![CDATA[
                    $().ready(function() {
                        $("#client_industry").autocomplete('/_ajax/naics.php', {
                            autoFill: true
                        });
                    });
                //]]>
                </xsl:comment>
                </script>
				-->
			</div>
   				
		<div id="client-contacts-panel" class="with-border">
			<h1 class="text-light">Users</h1>
			<div class="table-responsive">
				<table class="tablesorter table" id="client-contacts-list">
					<col style="width: 20%;"/>
					<col style="width: 15%;"/>
					<col style="width: 25%;"/>
					<col style="width: 13%;"/>
					<col style="width: 27%;"/>
					<thead>
						<tr>
							<th scope="col">Name</th>
							<th scope="col">Position</th>
							<th scope="col">Email</th>
							<th scope="col">Phone</th>
							<th scope="col"></th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="$allContacts/client_contact">
							<tr>
								<td>
									<xsl:call-template name="display-name">
										<xsl:with-param name="contact" select="current()"/>
									</xsl:call-template>
								</td>
								<td><xsl:value-of select="@position"/></td>
								<td>
									<xsl:call-template name="display-email">
										<xsl:with-param name="email" select="@email"/>
									</xsl:call-template>
								</td>
								<td><xsl:value-of select="@phone"/></td>
								<td>
									<a href="?action=contactEdit&amp;client_contact_id={@client_contact_id}">Edit</a>
									<xsl:text> : </xsl:text>
									<a href="?action=contactChangePassword&amp;client_contact_id={@client_contact_id}">Change Password</a>
	                                <xsl:if test="@client_contact_id != $currentContact/@client_contact_id">
	                                	<xsl:text> : </xsl:text>
										<a href="?action=contactDelete&amp;client_contact_id={@client_contact_id}" onclick="return AccountManagement.confirm('Are you sure you wish to delete this user named {@firstname} {@lastname}?');">Delete</a>
									</xsl:if>

								</td>
							</tr>
						</xsl:for-each>
	                    <tr>
	                        <td class="edit" colspan="5">
	                        	<a href="?action=contactNew" style="text-decoration:none;"><button type="button">Add User</button></a>
	                        </td>
	                    </tr>
					</tbody>
				</table>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'clients'][@method = 'passwordRecovery'][@action = 'email_request']">
		<p>Enter your registered email here and password reset instructions will be sent to your inbox.</p>
		<form method="post" action="" class="enquiry sky-form" autocomplete="off">
			<input type="hidden" name="action" value="recoverPassword" />
			<p>
				<label>
					<xsl:text>Registered email:</xsl:text>
					<span class="required">*</span>
					<xsl:apply-templates select="error[@field = 'email']" /><br />
					<input type="text" name="email">
						<xsl:attribute name="value">
							<xsl:value-of select="/config/globals/item[@key = 'email']/@value" />
						</xsl:attribute>
					</input>
				</label>
			</p>
			
			<!-- //If there is a postback, display a generic message -->
			<xsl:if test="@message">
				<p><xsl:value-of select="@message" /></p>
			</xsl:if>
			
			<p><input class="btn btn-base" type="submit" value="Reset Password" /></p>
		</form>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'clients'][@method = 'passwordRecovery'][@action = 'reset'][@valid = '0']">
		<p>The reset link is no longer valid.</p>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'clients'][@method = 'passwordRecovery'][@action = 'resetCompleted'][@valid = '1']">
		<p>Your password has been reset.</p>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'clients'][@method = 'passwordRecovery'][@action = 'reset'][@valid = '1']">
		<xsl:variable name="requestedContact" select="/config/plugin[@plugin = 'clients'][@method = 'passwordRecovery'][@action = 'reset'][@valid = '1']/requested_client_contact/client_contact[1]"/>
		<p><strong>Change Password</strong></p>
		<xsl:call-template name="contact-change-password-form">
			<xsl:with-param name="contact" select="$requestedContact"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'clients']/error">
		<span class="error">
			<xsl:text> </xsl:text>
			<xsl:value-of select="." />
		</span>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'clients']/client/@*" mode="value">
		<xsl:variable name="name" select="string(name())" />
		<xsl:choose>
			<xsl:when test="/config/globals/item[@key = $name]"><xsl:value-of select="/config/globals/item[@key = $name]/@value" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="current()" /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- New Contact -->
	<xsl:template match="/config/plugin[@plugin = 'clients'][@method = 'clientResources']">
		<xsl:variable name="client" select="/config/plugin[@plugin = 'clients'][@method = 'login']/client"/>
		<xsl:variable name="currentContact" select="$client/contact[1]"/>
		
		<!-- //Display the resources in a table if available -->
		
		<xsl:choose>
			<xsl:when test="count(/config/plugin[@plugin = 'clients'][@method = 'clientResources']/clientResources/resource) > 0">
				<table class="resourcesTable">
					<tr>
						<th>Description</th>
						<th>Link</th>
						<th>Action</th>
					</tr>
					
					<xsl:for-each select="/config/plugin[@plugin = 'clients'][@method = 'clientResources']/clientResources/resource">
						<tr>
							<td>
								<xsl:value-of select="@description" />
							</td>
							<td>
								<a href="/download/{@path}"><xsl:value-of select="@filename" /></a>
							</td>
							<td>
								<a href="/members/resources?action=delete-favourite&amp;file={@file_2_client_favourite_id}">
									<img src="/_images/trashbin.png" title="delete" />
								</a>
							</td>
						</tr>
					</xsl:for-each>
					
				</table>
			</xsl:when>
			<xsl:otherwise>
				<p>You have no resources available at this time.</p>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
	
</xsl:stylesheet>