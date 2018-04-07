<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="config[@mode = 'menu_item_edit']">
		<xsl:variable name="menu_item" select="menu_item[@menu_item_id = current()/globals/item[@key = 'menu_item_id']/@value]" />
		
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=navigation&amp;mode=menu_item_list&amp;domain_id={$domain_id}">Menu Item List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=navigation&amp;mode=menu_item_edit&amp;domain_id={$domain_id}&amp;menu_item_id={$menu_item/@menu_item_id}">
				<xsl:choose>
					<xsl:when test="$menu_item"><xsl:value-of select="$menu_item/@label" disable-output-escaping="yes" /></xsl:when>
					<xsl:otherwise>Add Menu Item</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Menu Item</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="menu_item_save" />
			<input type="hidden" name="menu_item_id" value="{$menu_item/@menu_item_id}" />
			<input type="hidden" name="domain_id" value="{$domain_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Menu Item" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="parent-id">Parent:</label></th>
						<td>
							<select id="parent-id" name="parent_id">
								<option value="0">-- Root Level --</option>
								<xsl:apply-templates select="menu_item[@domain_id = $domain_id][@parent_id = '']" mode="select">
									<xsl:with-param name="selected" select="$menu_item/@parent_id" />
								</xsl:apply-templates>
							</select>
						</td>
					</tr>
					
					<tr>
						<th scope="row"><label for="scope-id">Scope:</label></th>
						<td>
							<select id="scope-id" name="scope_id">
								<xsl:for-each select="scope">
									<option value="{@scope_id}">
										<xsl:if test="$menu_item/@scope_id = current()/@scope_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@description" disable-output-escaping="yes" />
									</option>
								</xsl:for-each>	
							</select>
						</td>
					</tr>

					<tr>
						<th scope="row"><label for="label">Label:</label></th>
						<td><input type="text" id="label" name="label" value="{$menu_item/@label}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="href">HREF:</label></th>
						<td><input type="text" id="href" name="href" value="{$menu_item/@href}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="sequence">Sequence:</label></th>
						<td><input type="text" id="sequence" name="sequence" value="{$menu_item/@sequence}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="icon">Icon:</label></th>
						<td><input type="text" id="icon" name="icon" value="{$menu_item/@icon}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
	
	<xsl:template match="menu_item" mode="select">
		<xsl:param name="selected" />
		<xsl:param name="chevrons" />
		<option value="{@menu_item_id}">
			<xsl:if test="@menu_item_id = $selected"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
			<xsl:value-of select="concat($chevrons,@sequence,' - ',@label)" disable-output-escaping="yes" />
		</option>
		<xsl:apply-templates select="../menu_item[@parent_id = current()/@menu_item_id]" mode="select">
			<xsl:with-param name="selected" select="$selected" />
			<xsl:with-param name="chevrons" select="concat($chevrons,'&gt; ')" />
		</xsl:apply-templates>
	</xsl:template>
	
</xsl:stylesheet>