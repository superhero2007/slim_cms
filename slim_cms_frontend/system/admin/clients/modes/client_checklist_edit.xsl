<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config[@mode = 'client_checklist_edit']">
		<xsl:variable name="client" select="client[@client_id = current()/globals/item[@key = 'client_id']/@value]" />
		<xsl:variable name="client_checklist" select="client_checklist[@client_checklist_id = current()/globals/item[@key = 'client_checklist_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=clients">Account List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_edit&amp;client_id={$client/@client_id}"><xsl:value-of select="$client/@company_name" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_checklist_edit&amp;client_id={$client/@client_id}&amp;client_checklist_id={$client_checklist/@client_checklist_id}">
				<xsl:choose>
					<xsl:when test="$client_checklist"><xsl:value-of select="$client_checklist/@name" /></xsl:when>
					<xsl:otherwise>Add Client Checklist</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Client Checklist</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="client_checklist_save" />
			<input type="hidden" name="client_checklist_id" value="{$client_checklist/@client_checklist_id}" />
			<input type="hidden" name="client_id" value="{$client/@client_id}" />
			<table class="editTable">
				<thead>
					<tr>
						<th colspan="2" scope="col"></th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Client Checklist" /></th>
					</tr>
				</tfoot>
				<tbody>
					<xsl:choose>
						<xsl:when test="$client_checklist">
							<tr>
								<th scope="row">Checklist</th>
								<td>
									<input type="hidden" name="checklist_id" value="{$client_checklist/@checklist_id}" />
									<xsl:value-of select="checklist[@checklist_id = $client_checklist/@checklist_id]/@name" />
								</td>
							</tr>
						</xsl:when>
						<xsl:otherwise>
							<tr>
								<th scope="row"><label for="checklist-id">Checklist:</label></th>
								<td>
									<select id="checklist-id" name="checklist_id" onchange="document.getElementById('name').value = this.options[this.selectedIndex].text">
										<option value="0">-- Select --</option>
										<xsl:for-each select="checklist">
											<option value="{@checklist_id}">
												<xsl:value-of select="@name" />
											</option>
										</xsl:for-each>
									</select>
								</td>
							</tr>
						</xsl:otherwise>
					</xsl:choose>
					<tr>
						<xsl:if test="/config/user/@client_type_id != '0'">
							<xsl:attribute name="class">hidden-data</xsl:attribute>
						</xsl:if>
						<th scope="row"><label for="checklist-variation-id">Variation:</label></th>
						<td>
							<select id="checklist-variation-id" name="checklist_variation_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="checklist_variation">
									<option value="{@checklist_variation_id}">
										<xsl:if test="$client_checklist/@checklist_variation_id = current()/@checklist_variation_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="name">Name:</label></th>
						<td><input type="text" id="name" name="name" value="{$client_checklist/@name}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="name">Responsible Contacts:</label></th>
						<td>
							<xsl:for-each select="client_contact[@client_id = $client/@client_id]">
								<xsl:sort select="concat(@firstname, ' ', @lastname)"/>
								<input type="hidden" name="client_checklist_permission[{@client_contact_id}]" value="0" />
								<label>
									<input type="checkbox" id="client_checklist_permission_{@client_contact_id}" name="client_checklist_permission[{@client_contact_id}]" value="1">
										<xsl:if test="../client_checklist_permission[@client_contact_id = current()/@client_contact_id][@client_checklist_id = $client_checklist/@client_checklist_id]">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
									</input>
									<xsl:text> </xsl:text>
									<xsl:value-of select="@salutation" />
									<xsl:text> </xsl:text>
									<xsl:value-of select="@firstname" />
									<xsl:text> </xsl:text>
									<xsl:value-of select="@lastname" />
									<br />
								</label>
							</xsl:for-each>
						</td>
					</tr>
                    <tr>
                    	<xsl:if test="/config/user/@client_type_id != '0'">
							<xsl:attribute name="class">hidden-data</xsl:attribute>
						</xsl:if>
						<th scope="row"><label for="name">Audit:</label></th>
						<td>
							<input type="hidden" name="audit" value="0" />
                            <!-- //Default to no audit -->
                            <label>
                                <input type="checkbox" id="audit" name="audit" value="1">
                                    <xsl:if test="$client_checklist/@audit_required = '1'">
                                        <xsl:attribute name="checked">checked</xsl:attribute>
                                    </xsl:if>
                                </input>
                                <xsl:text>Yes</xsl:text>
                            </label>
						</td>
					</tr>
                    <xsl:if test="count(client_checklist_audit[@client_checklist_id = $client_checklist/@client_checklist_id]) &gt; 0">
                        <tr>
                            <xsl:if test="/config/user/@client_type_id != '0'">
                                <xsl:attribute name="class">hidden-data</xsl:attribute>
                            </xsl:if>
                            <th scope="row"><label for="audit_cost">Audit Cost:</label></th>
                            <td><input type="text" id="audit_cost" name="audit_cost" value="{client_checklist_audit[@client_checklist_id = $client_checklist/@client_checklist_id]/@audit_cost}" /></td>
                        </tr>
                    </xsl:if>
					<tr>
						<th scope="row"></th>
						<td>
							If no responsible contact is chosen, only client admins can access this checklist.
						</td>
					</tr>
				</tbody>
			</table>
			<xsl:if test="/config/user/@admin_group_id = '1'">
				<a href="?page=clients&amp;mode=client_checklist_edit&amp;client_id={$client/@client_id}&amp;client_checklist_id={$client_checklist/@client_checklist_id}&amp;action=duplicate_client_checklist">Duplicate client checklist including answers</a>
				<xsl:if test="/config/globals/item[@key = 'query_result']">
					<p>
						<xsl:choose>
							<xsl:when test="/config/globals/item[@key = 'query_result']/@value = 'failed'">
								<span color="red">failed!</span>
							</xsl:when>
							<xsl:when test="/config/globals/item[@key = 'query_result']/@value = 'success'">
								<span color="green">success!</span>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="/config/globals/item[@key = 'query_result']/@value" />
							</xsl:otherwise>
						</xsl:choose>
					</p>
				</xsl:if>
			</xsl:if>
		</form>
	</xsl:template>

</xsl:stylesheet>
