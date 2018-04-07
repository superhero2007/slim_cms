<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:php="http://php.net/xsl"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">

	<xsl:template match="config[@mode = 'client_edit']">
		
		<script type="text/javascript" charset="utf-8">
		<xsl:comment><![CDATA[
			function submitComposeEmail(stationeryList, clientId, clientContactId) {
				var stationeryFile = $('#' + stationeryList).val();
				if (stationeryFile == "") {
					alert("Please select a stationery template before continuing.");
				}
				else {
					var url = '?page=clients&mode=email_compose&client_id=' + encodeURIComponent(clientId) + '&stationery_template=' + encodeURIComponent(stationeryFile);
					if (clientContactId) {
						url += '&client_contact_id=' + encodeURIComponent(clientContactId);
					}
					window.location = url;
				}
			}
		]]></xsl:comment>
		</script>
		
		<xsl:variable name="client" select="client[@client_id = current()/globals/item[@key = 'client_id']/@value]" />
		<xsl:variable name="clientTypeAssociate" select="'2'" />
		
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=clients">Account List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_edit&amp;client_id={$client/@client_id}">
				<xsl:choose>
					<xsl:when test="$client"><xsl:value-of select="$client/@company_name" /></xsl:when>
					<xsl:otherwise>Add Account</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Account</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="client_save" />
			<input type="hidden" name="client_id" value="{$client/@client_id}" />
			<input type="hidden" name="associate_id" value="{$client/@associate_id}" />
			<input type="hidden" name="associate_account_id" value="{$client/@associate_account_id}" />
			<input type="hidden" name="affiliate_id" value="{$client/@affiliate_id}" />
			<input type="hidden" name="registered" value="{$client/@registered}" />
			<input type="hidden" name="source" value="{$client/@source}" />
			<input type="hidden" name="username" value="{$client/@username}" />
			<input type="hidden" name="password" value="{$client/@password}" />
			<table class="editTable">
				<thead>
					<tr>
						<th colspan="4"></th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="4"><input type="submit" value="Save Account" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<xsl:if test="/config/user/@admin_group_id!= '1'">
							<xsl:attribute name="class">hidden-data</xsl:attribute>
						</xsl:if>
						<th scope="row"><label for="client-type-id">Account Type:</label></th>
						<td>
							<select id="client-type-id" name="client_type_id">
								<xsl:for-each select="client_type">
									<option value="{@client_type_id}">
										<xsl:if test="@client_type_id = $client/@client_type_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@client_type" />
									</option>
								</xsl:for-each>
							</select>
						<xsl:if test="/config/user/@admin_group_id!= '1'">
							<input type="hidden" name="client_type_id" value="{/config/user/@client_type_id}" />
						</xsl:if>
						</td>
						<th scope="row"><label for="parent-id">Account Owner:</label></th>
						<td>
							<select id="parent-id" name="parent_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="client[@client_type_id = '2' or @client_type_id = '5']">
									<xsl:sort select="@company_name" />
									<option value="{@client_id}">
										<xsl:if test="$client/@parent_id = @client_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@company_name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="company-name">Company Name:</label></th>
						<td>
							<xsl:if test="/config/user/@admin_group_id!= '1'">
								<xsl:attribute name="colspan">3</xsl:attribute>
							</xsl:if>						
							<input type="text" id="company-name" name="company_name" value="{$client/@company_name}" />
						</td>
						<th scope="row">
							<xsl:if test="/config/user/@admin_group_id!= '1'">
								<xsl:attribute name="class">hidden-data</xsl:attribute>
							</xsl:if>
						<label for="distributor-id">Distributor:</label></th>
						<td>
							<xsl:if test="/config/user/@admin_group_id!= '1'">
								<xsl:attribute name="class">hidden-data</xsl:attribute>
							</xsl:if>
							<select id="distributor-id" name="distributor_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="client[@client_type_id = '16']">
									<xsl:sort select="@company_name" />
									<option value="{@client_id}">
										<xsl:if test="$client/@distributor_id = @client_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@company_name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="col"><label for="address-line-1">Address Line 1:</label></th>
						<td><input type="text" id="address-line-1" name="address_line_1" value="{$client/@address_line_1}" /></td>
						<th scope="col"><label for="address-line-2">Address Line 2:</label></th>
						<td><input type="text" id="address-line-2" name="address_line_2" value="{$client/@address_line_2}" /></td>
					</tr>
					<tr>
						<th scope="col"><label for="suburb">City/Suburb:</label></th>
						<td><input type="text" id="suburb" name="suburb" value="{$client/@suburb}" /></td>
						<th scope="col"><label for="state">State:</label></th>
						<td><input type="text" id="state" name="state" value="{$client/@state}" /></td>
					</tr>
					<tr>
						<th scope="col"><label for="postcode">Postcode:</label></th>
						<td><input type="text" id="postcode" name="postcode" value="{$client/@postcode}" /></td>
						<th scope="col"><label for="postcode">Country:</label></th>
						<td>
							<select id="country" name="country">
								<xsl:for-each select="country">
									<xsl:sort select="@country" />
									<option value="{@country}">
										<xsl:choose>
											<xsl:when test="$client/@country != ''">
												<xsl:if test="$client/@country = @country"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
											</xsl:when>
											<xsl:otherwise>
												<xsl:if test="@country = 'Australia'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:value-of select="@country" />
									</option>
								</xsl:for-each>
							</select>
						
							<!--<input type="text" id="location" name="location" value="{$client/@location}" />
							<input type="hidden" id="city-id" name="city_id" value="{$client/@city_id}" />-->
						</td>
					</tr>
					<tr>
						<xsl:if test="/config/user/@admin_group_id!= '1'">
							<xsl:attribute name="class">hidden-data</xsl:attribute>
						</xsl:if>
						<th scope="col"><label for="refered_from">Referred From:</label></th>
						<td><input type="text" id="refered_from" name="refered_from" value="{$client/@refered_from}" /></td>
						<th scope="col">JV Partner:</th>
						<td>
							<select id="jv-partner-id" name="jv_partner_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="client[@client_type_id = '9']">
									<xsl:sort select="@company_name" />
									<option value="{@client_id}">
										<xsl:if test="/config/partner_2_client[@client_id = $client/@client_id]/@partner_id = @client_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@company_name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="col">
							<xsl:if test="/config/user/@admin_group_id!= '1'">
								<xsl:attribute name="class">hidden-data</xsl:attribute>
							</xsl:if>
						<label for="parent-company-id">Parent Company:</label></th>
						<td>
							<xsl:if test="/config/user/@admin_group_id!= '1'">
								<xsl:attribute name="class">hidden-data</xsl:attribute>
							</xsl:if>
							<select id="parent-company-id" name="parent_company_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="client[@client_id != $client/@client_id]">
									<xsl:sort select="@company_name" />
									<option value="{@client_id}">
										<xsl:if test="$client/@parent_company_id = @client_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@company_name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
                        <th scope="col"><label for="industry">Industry:</label></th>
						<td>
							<xsl:if test="/config/user/@admin_group_id!= '1'">
								<xsl:attribute name="colspan">3</xsl:attribute>
							</xsl:if>
							<select id="industry" name="industry">
                            	<option>-- Select --</option>
								<xsl:for-each select="industry">
									<option value="{@anzsic_id}">
										<xsl:choose>
											<xsl:when test="$client/@anzsic_id != ''">
												<xsl:if test="$client/@anzsic_id = @anzsic_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
											</xsl:when>
										</xsl:choose>
										<xsl:value-of select="@description" />
									</option>
								</xsl:for-each>
							</select>
						</td>
                    </tr>
					<tr>
						<xsl:if test="/config/user/@admin_group_id!= '1'">
							<xsl:attribute name="class">hidden-data</xsl:attribute>
						</xsl:if>
						<th scope="col"><label for="parent-id">Location (For Contact Us Section):</label></th>
						<td>
							<input type="text" id="location" name="location" value="{$client/@location}" />
							<input type="hidden" id="city-id" name="city_id" value="{$client/@city_id}" />
						</td>
						<th scope="col"><label for="parent-id">Old Business Owner:</label></th>
						<td>
							<select id="existing_business_owner_id" name="existing_business_owner_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="existing_business_owner">
									<xsl:sort select="@name" />
									<option value="{@existing_business_owner_id}">
										<xsl:if test="$client/@existing_business_owner_id = @existing_business_owner_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<xsl:if test="/config/user/@admin_group_id!= '1'">
							<xsl:attribute name="class">hidden-data</xsl:attribute>
						</xsl:if>
						<th scope="col"><label for="source">Source:</label></th>
						<td><input type="text" id="source" name="source" value="{$client/@source}" /></td>
						<th scope="col" colspan="2"></th>
					</tr>
				</tbody>
			</table>
		</form>
		<script type="text/javascript">
		$().ready(function() {
			$("#location").autocomplete('/_ajax/cities.php', {
				autoFill: true
			}).result(function(event, row) {
			  $("#city-id").attr('value',row[1]);
			});	
		});
		</script>

		<xsl:if test="$client">
			
			<h1>Account Contacts</h1>
			<table id="table-client-contact-list" class="admin-datatable stripe">
				<thead>
					<tr>
						<th scope="col">Name</th>
						<xsl:if test="$client/@client_type_id = '2' or $client/@client_type_id = '16'">
							<th scope="row">Business Owner Photo</th>
						</xsl:if>
						<th scope="col">Title / Position</th>
						<th scope="col">Email</th>
						<th scope="col">Phone</th>
						<xsl:if test="/config/user/@client_type_id = '0'">
							<th scope="col">Admin?</th>
							<th scope="col">Auto Emails?</th>
						</xsl:if>
						<th scope="col">Login</th>
					</tr>
				</thead>
				<thead>
					<tr class="data-filter">
						<th scope="col">Name</th>
						<xsl:if test="$client/@client_type_id = '2' or $client/@client_type_id = '16'">
							<th scope="row">Business Owner Photo</th>
						</xsl:if>
						<th scope="col">Title / Position</th>
						<th scope="col">Email</th>
						<th scope="col">Phone</th>
						<xsl:if test="/config/user/@client_type_id = '0'">
							<th scope="col">Admin?</th>
							<th scope="col">Auto Emails?</th>
						</xsl:if>
						<th scope="col">Login</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="client_contact[@client_id = $client/@client_id]">
						<xsl:sort select="@sequence" data-type="number" />
						<tr id="id-{@client_contact_id}">
							<td>
								<xsl:value-of select="concat(@salutation,' ',@firstname,' ',@lastname)" />
								<br />
								<span class="options">
									<a href="?page=clients&amp;mode=client_contact_edit&amp;client_id={$client/@client_id}&amp;client_contact_id={@client_contact_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=clients&amp;mode=client_edit&amp;action=client_contact_delete&amp;client_id={$client/@client_id}&amp;client_contact_id={@client_contact_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
							
							<!-- //If the client is a business owner -->
							<xsl:if test="$client/@client_type_id = '2' or $client/@client_type_id = '16'">
								<td>
									<xsl:if test="@photo = 'yes'">
										<img src="/_images/partners/business_owner_contact_{@client_contact_id}.gif" />
									</xsl:if>
								</td>
							</xsl:if>
							
							<td><xsl:value-of select="@position" /></td>
							<td>
								<xsl:choose>
									<xsl:when test="/config/user/@client_type_id = '0'">
										<xsl:value-of select="@email" />
										<div style="margin-top: 0.5em;">
											<select id="send-email-stationery-contact-{@client_contact_id}" name="send-email-stationery">
												<option value="">-- Select --</option>
												<xsl:for-each select="/config/stationery_template">
													<xsl:sort select="@name" />
													<option value="{@filename}">
														<xsl:value-of select="@name" />
													</option>
												</xsl:for-each>
											</select>
											<xsl:text> </xsl:text>
											<button onClick="submitComposeEmail('send-email-stationery-contact-{@client_contact_id}', {@client_id}, {@client_contact_id}); return false;">Compose Email</button>
										</div>
									</xsl:when>
									<xsl:otherwise>
										<a href="mailto:{@email}">
											<xsl:value-of select="@email" />
										</a>
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<td><xsl:value-of select="@phone" /></td>
							
							<xsl:if test="/config/user/@client_type_id = '0'">
								<td>
									<xsl:choose>
										<xsl:when test="@is_client_admin = 1">Yes</xsl:when>
										<xsl:otherwise>No</xsl:otherwise>
									</xsl:choose>
								</td>
								<td>
									<xsl:choose>
										<xsl:when test="@send_auto_emails = 1">Yes</xsl:when>
										<xsl:otherwise>No</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:if>
							<td style="text-align: center;">
								<form method="post" action="/members/" target="_blank">
									<input type="hidden" name="action" value="login" />
									<input type="hidden" name="username" value="{@email}" />
									<input type="hidden" name="password" value="{@password}" />
									<input type="submit" value="Login" />
								</form>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
			<div class="admin-datatable-footer-buttons">
				<input type="button" value="Add Contact" onclick="document.location = '?page=clients&amp;mode=client_contact_edit&amp;client_id={$client/@client_id}';" />
			</div>


			<h1>Account Checklists</h1>
			<table id="table-client-account-checklist" class="admin-datatable stripe">
				<thead>
					<tr>
						<th scope="col">Name</th>
						<th scope="col">Checklist</th>
						<th scope="col">Responsible Contacts</th>
						<th scope="col">Created</th>
						<th scope="col">Completed</th>
						<th scope="col">Score</th>
						<th scope="col">Status</th>
					</tr>
				</thead>
				<thead>
					<tr class="data-filter">
						<th scope="col">Name</th>
						<th scope="col">Checklist</th>
						<th scope="col">Responsible Contacts</th>
						<th scope="col">Created</th>
						<th scope="col">Completed</th>
						<th scope="col">Score</th>
						<th scope="col">Status</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="client_checklist">
						<tr>
							<td>
								<xsl:value-of select="@name" />
								<br />
								<span class="options">
									<a href="?page=clients&amp;mode=client_checklist_edit&amp;client_id={$client/@client_id}&amp;client_checklist_id={@client_checklist_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=clients&amp;mode=client_checklist_answer_report&amp;client_id={$client/@client_id}&amp;client_checklist_id={@client_checklist_id}">answer report</a>
									<xsl:text> | </xsl:text>
									<a href="?page=clients&amp;mode=client_checklist_edit&amp;action=export_client_results&amp;client_id={$client/@client_id}&amp;client_checklist_id={@client_checklist_id}">export answers</a>
									<xsl:text> | </xsl:text>
									<xsl:if test="@completed != ''">
										<a href="?page=clients&amp;mode=client_edit&amp;action=client_checklist_reopen&amp;client_id={$client/@client_id}&amp;client_checklist_id={@client_checklist_id}" onclick="return(confirm('Did you really mean to click re-open?'))">re-open</a>
										<xsl:text> | </xsl:text>
									</xsl:if>
									<a href="?page=clients&amp;mode=client_edit&amp;action=client_checklist_delete&amp;client_id={$client/@client_id}&amp;client_checklist_id={@client_checklist_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
							<td><xsl:value-of select="@checklist" /></td>
							<td>
								<xsl:if test="/config/client_checklist_permission[@client_checklist_id = current()/@client_checklist_id]">
									<ul class="responsible-contacts">
										<xsl:for-each select="/config/client_checklist_permission[@client_checklist_id = current()/@client_checklist_id]">
											<xsl:variable name="responsibleContact" select="/config/client_contact[@client_contact_id = current()/@client_contact_id]"/>
											<li>
												<xsl:value-of select="$responsibleContact/@salutation"/>
												<xsl:text> </xsl:text>
												<xsl:value-of select="$responsibleContact/@firstname"/>
												<xsl:text> </xsl:text>
												<xsl:value-of select="$responsibleContact/@lastname"/>
											</li>
										</xsl:for-each>
									</ul>
								</xsl:if>
							</td>
							<td><xsl:value-of select="@created" /></td>
							<td><xsl:value-of select="@completed" /></td>
							<td><xsl:value-of select="format-number(@current_score, '###%')" /></td>
							<td>
								<xsl:choose>
									<xsl:when test="@status = 'report'">Complete</xsl:when>
									<xsl:when test="@status = 'incomplete'">Incomplete</xsl:when>
									<xsl:otherwise><xsl:value-of select="@status" /></xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
			<div class="admin-datatable-footer-buttons">
				<input type="button" value="Add Checklist" onclick="document.location = '?page=clients&amp;mode=client_checklist_edit&amp;client_id={$client/@client_id}';" />
			</div>

			<h1>Client Notes</h1>
			<table id="table-client-account-notes" class="admin-datatable stripe">
				<col style="width: 10em;" />
				<thead>
					<tr>
						<th scope="col">Date/Time</th>
						<th scope="col">Note</th>
					</tr>
				</thead>
				<thead>
					<tr class="data-filter">
						<th scope="col">Date/Time</th>
						<th scope="col">Note</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="client_note[@client_id = $client/@client_id]">
						<tr>
							<td>
								<xsl:value-of select="@timestamp" />
								<br />
								<span class="options">
									<a href="?page=clients&amp;mode=client_note_edit&amp;client_id={@client_id}&amp;client_note_id={@client_note_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=clients&amp;mode=client_edit&amp;action=client_note_delete&amp;client_id={@client_id}&amp;client_note_id={@client_note_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
							<td><xsl:value-of select="php:function('nl2br',string(@note))" disable-output-escaping="yes" /></td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
			
			<div class="admin-datatable-footer-buttons">
				<input type="button" value="Add Note" onclick="document.location = '?page=clients&amp;mode=client_note_edit&amp;client_id={$client/@client_id}';" />
			</div>
			
			<xsl:if test="/config/user/@admin_group_id = '1'">
				<h1><a name="email_list" />Emails Sent</h1>
				<table id="table-client-account-emails" class="admin-datatable stripe">
					<thead>
						<tr>
							<th scope="col">Sent On</th>
							<th scope="col">Contact</th>
							<th scope="col">Subject</th>
						</tr>
					</thead>
					<thead>
						<tr class="data-filter">
							<th scope="col">Sent On</th>
							<th scope="col">Contact</th>
							<th scope="col">Subject</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="client_email">
							<xsl:sort select="@sent_date" order="descending" />
							<xsl:variable name="clientContactId" select="@client_contact_id"/>
							<xsl:variable name="clientContact" select="/config/client_contact[@client_contact_id=$clientContactId]"/>
							<tr>
								<td>
									<xsl:value-of select="@sent_date_au"/>
									<br />
									<span class="options">
										<a href="?page=clients&amp;mode=email_show&amp;client_id={$clientContact/@client_id}&amp;client_email_id={@client_email_id}">show email</a>
									</span>
								</td>
								<td>
									<xsl:value-of select="$clientContact/@salutation"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select="$clientContact/@firstname"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select="$clientContact/@lastname"/>
								</td>
								<td><xsl:value-of select="@email_subject"/></td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>

			<div class="admin-datatable-footer-buttons">
				Stationery Template:
				<xsl:text> </xsl:text>
				<select id="send-email-stationery" name="send-email-stationery">
					<option value="">-- Select --</option>
					<xsl:for-each select="stationery_template">
						<xsl:sort select="@name" />
						<option value="{@filename}">
							<xsl:value-of select="@name" />
						</option>
					</xsl:for-each>
				</select>
				<xsl:text> </xsl:text>
				<button onClick="submitComposeEmail('send-email-stationery', {$client/@client_id}, null); return false;">Compose Email</button>
			</div>
						
				<h1>Account Invoices</h1>
				<xsl:for-each select="currency">
					<xsl:variable name="invoices" select="../invoice[@client_id = $client/@client_id][@currency_id = current()/@currency_id]" />
					<xsl:variable name="transactions" select="../transaction[@client_id = $client/@client_id][@currency_id = current()/@currency_id]" />
					<xsl:variable name="balance" select="sum(../product_2_invoice[@invoice_id = $invoices/@invoice_id]/@total) - sum($transactions/@amount)" />
					<xsl:if test="$balance &gt; 0">
						<p style="text-align: center;">
							<strong>Outstanding balance: </strong>
							<xsl:value-of select="format-number($balance,'#,##0.00')" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="@code" />
						</p>
					</xsl:if>
				</xsl:for-each>
				
				<table id="table-client-account-invoices" class="admin-datatable stripe">
					<thead>
						<tr>
							<th scope="col">Invoice No.</th>
							<th scope="col">Invoice Date</th>
							<th scope="col">Total</th>
						</tr>
					</thead>
					<thead>
						<tr class="data-filter">
							<th scope="col">Invoice No.</th>
							<th scope="col">Invoice Date</th>
							<th scope="col">Total</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="invoice[@client_id = $client/@client_id]">
							<tr>
								<td>
									<xsl:value-of select="concat(format-number(@client_id,'0000'),'-',format-number(@invoice_id,'0000'))" />
									<br />
									<span class="options">
										<a href="?page=clients&amp;mode=invoice_edit&amp;client_id={$client/@client_id}&amp;invoice_id={@invoice_id}">edit</a>
										<xsl:text> | </xsl:text>
										<a href="?page=clients&amp;mode=client_edit&amp;action=invoice_delete&amp;client_id={$client/@client_id}&amp;invoice_id={@invoice_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
										<xsl:text> | </xsl:text>
										<a href="/pay-your-account/invoice-pdf?account_no={$client/@account_no}&amp;invoice_id={@invoice_id}">download pdf</a>
									</span>
								</td>
								<td><xsl:value-of select="@invoice_date" /></td>
								<td>
									<xsl:value-of select="format-number(sum(../product_2_invoice[@invoice_id = current()/@invoice_id]/@total),'###,##0.00')" />
									<xsl:text> </xsl:text>
									<xsl:value-of select="../currency[@currency_id = current()/@currency_id]/@code" />
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				
				<div class="admin-datatable-footer-buttons">
					<input type="button" value="Add Invoice" onclick="document.location = '?page=clients&amp;mode=invoice_edit&amp;client_id={$client/@client_id}';" />
				</div>
				
				
				<h1>Transactions</h1>
				<table id="table-client-account-transactions" class="admin-datatable stripe">
					<thead>
						<tr>
							<th scope="col">Date</th>
							<th scope="col">Amount</th>
							<th scope="col">Method</th>
						</tr>
					</thead>
					<thead>
						<tr class="data-filter">
							<th scope="col">Date</th>
							<th scope="col">Amount</th>
							<th scope="col">Method</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="transaction[@client_id = $client/@client_id]">
							<tr>
								<td>
									<xsl:value-of select="@timestamp" />
									<br />
									<span class="options">
										<a href="?page=clients&amp;mode=client_edit&amp;action=transaction_delete&amp;client_id={$client/@client_id}&amp;transaction_id={@transaction_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
									</span>
								</td>
								<td>
									<xsl:value-of select="format-number(@amount,'###,##0.00')" />
									<xsl:text> </xsl:text>
									<xsl:value-of select="../currency[@currency_id = current()/@currency_id]/@code" />
								</td>
								<td><xsl:value-of select="@method" /></td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				
				
				<h1>Add a Transaction</h1>
				<form method="post" action="">
					<input type="hidden" name="action" value="transaction_save" />
					<input type="hidden" name="client_id" value="{$client/@client_id}" />
					<table class="editTable">
						<thead>
							<tr>
								<th colspan="2"></th>
							</tr>
						</thead>
						<tfoot>
							<tr>
								<th colspan="2"><input type="submit" value="Save Transaction" /></th>
							</tr>
						</tfoot>
						<tbody>
							<tr>
								<th scope="row"><label for="transaction-timestamp">Date / Time:</label></th>
								<td><input type="text" id="transaction-timestamp" name="timestamp" /></td>
							</tr>
							<tr>
								<th scope="row"><label for="transaction-currency">Currency:</label></th>
								<td>
									<select id="transaction-currency" name="currency_id">
										<xsl:for-each select="currency">
											<option value="{@currency_id}"><xsl:value-of select="@code" /></option>
										</xsl:for-each>
									</select>
								</td>
							</tr>
							<tr>
								<th scope="row"><label for="transaction-amount">Amount:</label></th>
								<td><input type="text" id="transaction-amount" name="amount" /></td>
							</tr>
							<tr>
								<th scope="row"><label for="transaction-method">Method:</label></th>
									<td>
									<select id="transaction-method" name="method">
										<xsl:for-each select="str:tokenize('Direct Credit,Cheque,Cash',',')">
											<option value="{.}"><xsl:value-of select="." /></option>
										</xsl:for-each>
									</select>
								</td>
							</tr>
						</tbody>
					</table>
				</form>
			</xsl:if>
			
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>