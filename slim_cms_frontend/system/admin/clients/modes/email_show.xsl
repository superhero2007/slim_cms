<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:php="http://php.net/xsl"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">

	<xsl:template match="config[@mode = 'email_show']">
		<xsl:variable name="client" select="client[@client_id = current()/globals/item[@key = 'client_id']/@value]"/>
		<xsl:variable name="clientEmail" select="client_email[@client_email_id = current()/globals/item[@key='client_email_id']/@value]"/>
		<xsl:variable name="clientContact" select="/config/client_contact[@client_contact_id=$clientEmail/@client_contact_id]"/>
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=clients">Account List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_edit&amp;client_id={$client/@client_id}">
					<xsl:value-of select="$client/@company_name" />
			</a>
			<xsl:text> &gt; </xsl:text>
			Display Email
		</p>
		<h1>Display Email</h1>
		<table class="editTable">
			<tbody>
				<tr>
					<th scope="row"><label>Sent On:</label></th>
					<td><xsl:value-of select="$clientEmail/@sent_date_au"/></td>
				</tr>
				<tr>
					<th scope="row"><label>Contact:</label></th>
					<td>
						<xsl:value-of select="$clientContact/@salutation"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$clientContact/@firstname"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$clientContact/@lastname"/>
					</td>
				</tr>
				<tr>
					<th scope="row"><label>Subject:</label></th>
					<td><xsl:value-of select="$clientEmail/@email_subject"/></td>
				</tr>
				<tr>
					<th scope="row"><label>Stationery Template:</label></th>
					<td><xsl:value-of select="stationery_template[@filename=$clientEmail/@email_stationery]/@name"/></td>
				</tr>
				<tr>
					<th scope="row"><label>Email Message:</label></th>
					<td><xsl:value-of select="$clientEmail/@email_body" disable-output-escaping="yes"/></td>
				</tr>
			</tbody>
		</table>
	</xsl:template>
</xsl:stylesheet>