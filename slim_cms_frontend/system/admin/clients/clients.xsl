<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:exsl="http://exslt.org/common"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-extension-prefixes="exsl">

	<xsl:template name="menu">
		<h1>Account Management</h1>
	</xsl:template>
	
	<xsl:template name="contactName">
		<xsl:param name="checklist"/>
		
		<xsl:value-of select="$checklist/@client_contact_salutation"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$checklist/@client_contact_firstname"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$checklist/@client_contact_lastname"/>
	</xsl:template>

	<xsl:template match="config">
		<xsl:variable name="al" select="'abcdefghijklmnopqrstuvwxyz'" />
		<xsl:variable name="au" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
		<xsl:variable name="q" select="translate(/config/globals/item[@key = 'q']/@value,$au,$al)" />
		<xsl:variable name="in" select="/config/globals/item[@key = 'in']/@value" />
		<xsl:variable name="account_type" select="/config/globals/item[@key = 'account_type']/@value" />
	
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=clients">Account List</a>
		</p>
		<h1>Account List</h1>
	
		<table id="client-account-list-table" class="admin-datatable stripe">
			<thead>
				<tr>
					<th scope="col">Company Name</th>
					<xsl:if test="/config/user/@admin_group_id = '1'">
						<th scope="col">Client Type</th>
					</xsl:if>
					<th scope="col">Location</th>
					<th scope="col">Registered</th>
				</tr>
			</thead>
			<thead>
				<tr class="data-filter">
					<th scope="col">Company Name</th>
					<xsl:if test="/config/user/@admin_group_id = '1'">
						<th scope="col">Client Type</th>
					</xsl:if>
					<th scope="col">Location</th>
					<th scope="col">Registered</th>
				</tr>
			</thead>
			<tbody>
				<xsl:apply-templates select="client" mode="row" />
			</tbody>
		</table>
		
		<div class="admin-datatable-footer-buttons">
			<input type="button" value="Add Account" onclick="document.location = '?page=clients&amp;mode=client_edit';" />
		</div>

	</xsl:template>
	
	<xsl:template match="client" mode="row">
    	<xsl:param name="showProspect">no</xsl:param>
    	
		<xsl:variable name="client_id" select="@client_id" />
		<tr>
			<td>
				<xsl:value-of select="@company_name" />
				<br />
				<span class="options">
					<a href="?page=clients&amp;mode=client_edit&amp;client_id={@client_id}" title="Edit User">edit</a>
					<xsl:text> | </xsl:text>
					<a href="?page=clients&amp;action=client_delete&amp;client_id={@client_id}" title="Delete User" onclick="return(confirm('Are you sure you want to delete {@username}?'));">delete</a>
				</span>
			</td>
			<td>
				<xsl:value-of select="@client_type" />
			</td>
			<td>
				<xsl:value-of select="@suburb" />, <xsl:value-of select="@state" />, <xsl:value-of select="@country" />
			</td>
			<td><xsl:apply-templates select="@registered" /></td>
		</tr>
	</xsl:template>
	
	<!--<xsl:template match="client/@date_registered[. = '0000-00-00'] | client/@last_active[. = '']" /> -->
	
	<xsl:include href="modes/associate_client_list.xsl" />
	<xsl:include href="modes/associate_prospect_list.xsl" />
	<xsl:include href="modes/client_checklist_edit.xsl" />
	<xsl:include href="modes/client_checklist_answer_report.xsl" />
	<xsl:include href="modes/client_contact_edit.xsl" />
	<xsl:include href="modes/client_edit.xsl" />
	<xsl:include href="modes/client_note_edit.xsl" />
	<xsl:include href="modes/invoice_edit.xsl" />
	<xsl:include href="modes/invoice_list.xsl" />
	<xsl:include href="modes/email_compose.xsl" />
	<xsl:include href="modes/email_show.xsl" />
	
</xsl:stylesheet>