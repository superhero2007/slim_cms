<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="/config[@mode = 'associate_prospect_list']">
		<xsl:variable name="client" select="client[@client_id = current()/globals/item[@key = 'client_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=clients">Acount List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_edit&amp;client_id={$client/@client_id}"><xsl:value-of select="$client/@company_name" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=associate_prospect_list&amp;client_id={$client/@client_id}">Associate Prospect List</a>
		</p>
		<h1>Associate Prospects</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">Company Name</th>
					<th scope="col">Type</th>
					<th scope="col">Location</th>
					<th scope="col">Account Owner</th>
					<th scope="col">Balance</th>
					<th scope="col">Registered</th>
					<th scope="col">Last Active</th>
				</tr>
			</thead>
			<tbody>
                <xsl:apply-templates select="client[@client_type_id = 3][@parent_id = $client/@client_id]" mode="row">
                	<xsl:with-param name="showProspect">yes</xsl:with-param>
                </xsl:apply-templates>
			</tbody>
		</table>
	</xsl:template>
    

	
</xsl:stylesheet>