<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:param name="domain_id" select="/config/globals/item[@key = 'domain_id']/@value" />

	<xsl:template name="menu">
		<h1>Content Management</h1>
	</xsl:template>

	<xsl:template match="config">
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=navigation&amp;domain_id={$domain_id}">Navigation List</a>
		</p>
		<form method="get" action="">
			<p>
				<label>
					<xsl:text>Edit navigation for domain: </xsl:text>
					<select name="domain_id" onchange="document.location = '?page=navigation&amp;domain_id='+this.options[this.selectedIndex].value;">
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
		<h1>Navigation List</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">Path</th>
					<th scope="col">Title</th>
					<th scope="col">Template</th>
					<th scope="col">Scope</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="4"><input type="button" value="Add Navigation" onclick="document.location = '?page=navigation&amp;mode=navigation_edit&amp;domain_id={$domain_id}'" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:apply-templates select="navigation[@domain_id = /config/globals/item[@key = 'domain_id']/@value][@parent_id = '']" />

				<!-- //Spares -->
				<xsl:for-each select="/config/navigation[@domain_id = /config/globals/item[@key = 'domain_id']/@value][@parent_id != '']">
					<xsl:if test="count(/config/navigation[@navigation_id = current()/@parent_id]) = 0">
						<xsl:apply-templates select="/config/navigation[@navigation_id = current()/@navigation_id]">
							<xsl:with-param name="missing-parent" select="'true'" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
		
	<xsl:template match="navigation">
		<xsl:param name="parent" />
		<xsl:param name="missing-parent" />
		<xsl:variable name="path" select="concat(@path,'/')" />
		<tr>
			<td>
				<xsl:value-of select="concat($parent,$path)" />
				<br />
				<span class="options">
					<a href="?page=navigation&amp;mode=navigation_edit&amp;domain_id={@domain_id}&amp;navigation_id={@navigation_id}">edit</a>
					<xsl:text> | </xsl:text>
					<a href="?page=navigation&amp;action=navigation_delete&amp;domain_id={@domain_id}&amp;navigation_id={@navigation_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
				</span>
			</td>
			<td>
				<xsl:if test="/config/content[@navigation_id = current()/@navigation_id]/@content_wellformed = '0'">
					<xsl:attribute name="style">background-color: #F00;</xsl:attribute>
				</xsl:if>
				<xsl:if test="$missing-parent = 'true'">
					<xsl:attribute name="style">background-color: #FFA500;</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="@title" />
			</td>
			<td><xsl:value-of select="../template[@template_id = current()/@template_id]/@template" /></td>
			<td><xsl:value-of select="../scope[@scope_id = current()/@scope_id]/@description" /></td>
		</tr>
		<xsl:apply-templates select="../navigation[@parent_id = current()/@navigation_id]">
			<xsl:with-param name="parent" select="concat($parent,$path)" />
		</xsl:apply-templates>

	</xsl:template>
	
	<xsl:include href="modes/content_edit.xsl" />
	<xsl:include href="modes/menu_item_edit.xsl" />
	<xsl:include href="modes/menu_item_list.xsl" />
	<xsl:include href="modes/navigation_edit.xsl" />
	<xsl:include href="modes/plugin_method_call_edit.xsl" />

</xsl:stylesheet>