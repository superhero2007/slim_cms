<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:param name="domain_id" select="/config/globals/item[@key = 'domain_id']/@value" />

	<xsl:template match="config[@mode = 'menu_item_list']">
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=navigation&amp;mode=menu_item_list&amp;domain_id={$domain_id}">Menu Item List</a>
		</p>
		<form method="get" action="">
			<p>
				<label>
					<xsl:text>Edit menu items for domain: </xsl:text>
					<select name="domain_id" onchange="document.location = '?page=navigation&amp;mode=menu_item_list&amp;domain_id='+this.options[this.selectedIndex].value;">
						<xsl:for-each select="domain[@redirect_to_domain_id = '']">
							<option value="{@domain_id}">
								<xsl:if test="@domain_id = $domain_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
								<xsl:value-of select="@remote" />
							</option>
						</xsl:for-each>
					</select>
				</label>
			</p>
		</form>
		<h1>Menu Item List</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">Label</th>
					<th scope="col">HREF</th>
					<th scope="col">Scope</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="3"><input type="button" value="Add Menu Item" onclick="document.location = '?page=navigation&amp;mode=menu_item_edit&amp;domain_id={$domain_id}'" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:apply-templates select="menu_item[@domain_id = $domain_id][@parent_id = '']" />
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="menu_item">
		<xsl:param name="chevrons" />
		<tr>
			<td>
				<xsl:value-of select="concat($chevrons,@label)" disable-output-escaping="yes" />
				<br />
				<span class="options">
					<a href="?page=navigation&amp;mode=menu_item_edit&amp;domain_id={@domain_id}&amp;menu_item_id={@menu_item_id}">edit</a>
					<xsl:text> | </xsl:text>
					<a href="?page=navigation&amp;mode=menu_item_list&amp;action=menu_item_delete&amp;domain_id={@domain_id}&amp;menu_item_id={@menu_item_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
				</span>
			</td>
			<td><xsl:value-of select="@href" /></td>
			<td><xsl:value-of select="../scope[@scope_id = current()/@scope_id]/@description" /></td>
		</tr>
		<xsl:apply-templates select="../menu_item[@parent_id = current()/@menu_item_id]">
			<xsl:with-param name="chevrons" select="concat($chevrons,'&gt; ')" />
		</xsl:apply-templates>
	</xsl:template>

</xsl:stylesheet>