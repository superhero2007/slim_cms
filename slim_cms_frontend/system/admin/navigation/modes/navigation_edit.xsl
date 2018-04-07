<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="config[@mode = 'navigation_edit']">
		<xsl:variable name="navigation" select="navigation[@navigation_id = current()/globals/item[@key = 'navigation_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=navigation&amp;domain_id={$domain_id}">Navigation List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=navigation&amp;mode=navigation_edit&amp;domain_id={$domain_id}&amp;navigation_id={$navigation/@navigation_id}">
				<xsl:choose>
					<xsl:when test="$navigation"><xsl:value-of select="$navigation/@title" /></xsl:when>
					<xsl:otherwise>Add Navigation</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Navigation</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="navigation_save" />
			<input type="hidden" name="navigation_id" value="{$navigation/@navigation_id}" />
			<input type="hidden" name="sequence" value="{$navigation/@sequence}" />
			<input type="hidden" name="secure" value="{$navigation/@secure}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Navigation" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="domain-id">Domain:</label></th>
						<td>
							<select id="domain-id" name="domain_id">
								<xsl:for-each select="domain">
									<option value="{@domain_id}">
										<xsl:if test="@domain_id = $domain_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@remote" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="parent-id">Parent:</label></th>
						<td>
							<select id="parent-id" name="parent_id">
								<option value="0">-- Root Level --</option>
								<xsl:apply-templates select="navigation[@domain_id = $domain_id][@parent_id = '']" mode="select">
									<xsl:with-param name="selected" select="$navigation/@parent_id" />
								</xsl:apply-templates>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="template-id">Template:</label></th>
						<td>
							<select id="template-id" name="template_id">
								<option value="0">-- Inherit --</option>
								<xsl:for-each select="template">
									<option value="{@template_id}">
										<xsl:if test="$navigation/@template_id = current()/@template_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@template" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="scope-id">Scope:</label></th>
						<td>
							<select id="scope-id" name="scope_id">
								<xsl:for-each select="scope">
									<option value="{@scope_id}">
										<xsl:if test="@scope_id = $navigation/@scope_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@description" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="page-heading">Page Heading:</label></th>
						<td><input type="text" id="title" name="title" value="{$navigation/@title}" onkeyup="setPath(this.value,'path');" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="label">Label:<br /></label></th>
						<td><input type="text" id="label" name="label" value="{$navigation/@label}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="path">Path:</label></th>
						<td><input type="text" id="path" name="path" value="{$navigation/@path}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="sitemap-priority">Sitemap Priority:</label></th>
						<td><input type="text" id="sitemap-priority" name="sitemap_priority" value="{$navigation/@sitemap_priority}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="sitemap-lastmod">Sitemap Lastmod:</label></th>
						<td><input type="text" id="sitemap-lastmod" name="sitemap_lastmod" value="{$navigation/@sitemap_lastmod}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="sitemap-changefreq">Sitemap Changefreq:</label></th>
						<td><input type="text" id="sitemap-changefreq" name="sitemap_changefreq" value="{$navigation/@sitemap_changefreq}" /></td>
					</tr>
					
					<!-- //SEO Meta Tags -->
					<tr>
						<th scope="row" colspan="2"><label for="seo-meta-tags"><center>Meta Tags for SEO:</center></label></th>
					</tr>
					<tr>
						<th scope="row"><label for="meta-title">Title:</label></th>
						<td><input type="text" id="meta-title" name="meta-title" value="{$navigation/@meta-title}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="meta-description">Description:</label></th>
						<td><input type="text" id="meta-description" name="meta-description" value="{$navigation/@meta-description}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="meta-keywords">Keywords:</label></th>
						<td><input type="text" id="meta-keywords" name="meta-keywords" value="{$navigation/@meta-keywords}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
		<h1>Content List</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">XHTML</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th><input type="button" value="Add Content" onclick="document.location = '?page=navigation&amp;mode=content_edit&amp;domain_id={$domain_id}&amp;navigation_id={$navigation/@navigation_id}'" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="content[@navigation_id = $navigation/@navigation_id]">
					<xsl:sort select="@sequence" data-type="number" />
					<tr>
						<td>
							<code><xsl:value-of select="@content" disable-output-escaping="no" /></code>
							<br />
							<span class="options">
								<a href="?page=navigation&amp;mode=content_edit&amp;domain_id={$domain_id}&amp;navigation_id={$navigation/@navigation_id}&amp;content_id={@content_id}">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=navigation&amp;mode=navigation_edit&amp;domain_id={$domain_id}&amp;action=content_delete&amp;navigation_id={$navigation/@navigation_id}&amp;content_id={@content_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		<h1>Plugin Call List</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">Plugin</th>
					<th scope="col">Method</th>
					<th scope="col">Inherit</th>
					<th scope="col">Sequence</th>
					<th scope="col">Position</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="5"><input type="button" value="Add Plugin Call" onclick="document.location = '?page=navigation&amp;mode=plugin_method_call_edit&amp;domain_id={$domain_id}&amp;navigation_id={$navigation/@navigation_id}'" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="plugin_method_call[@navigation_id = $navigation/@navigation_id]">
					<xsl:sort select="@sequence" data-type="number" />
					<tr>
						<td>
							<xsl:value-of select="../plugin[@plugin_id = ../plugin_method[@plugin_method_id = current()/@plugin_method_id]/@plugin_id]/@plugin" />
							<br />
							<span class="options">
								<a href="?page=navigation&amp;mode=plugin_method_call_edit&amp;domain_id={$domain_id}&amp;navigation_id={$navigation/@navigation_id}&amp;plugin_method_call_id={@plugin_method_call_id}">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=navigation&amp;mode=navigation_edit&amp;action=plugin_method_call_delete&amp;domain_id={$domain_id}&amp;navigation_id={$navigation/@navigation_id}&amp;plugin_method_call_id={@plugin_method_call_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td><xsl:value-of select="../plugin_method[@plugin_method_id = current()/@plugin_method_id]/@method" /></td>
						<td>
							<xsl:choose>
								<xsl:when test="@inherit = '1'">Yes</xsl:when>
								<xsl:otherwise>No</xsl:otherwise>
							</xsl:choose>
						</td>
						<td><xsl:value-of select="@sequence" /></td>
						<td><xsl:value-of select="@position" /></td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="navigation" mode="select">
		<xsl:param name="selected" />
		<xsl:param name="parent" />
		<xsl:variable name="path" select="concat(@path,'/')" />
		<option value="{@navigation_id}">
			<xsl:if test="@navigation_id = $selected"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
			<xsl:value-of select="concat($parent,$path)" />
		</option>
		<xsl:apply-templates select="../navigation[@parent_id = current()/@navigation_id]" mode="select">
			<xsl:with-param name="selected" select="$selected" />
			<xsl:with-param name="parent" select="concat($parent,$path)" />
		</xsl:apply-templates>
	</xsl:template>
	
</xsl:stylesheet>