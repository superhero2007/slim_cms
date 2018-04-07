<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config[@mode = 'plugin_method_call_edit']">
		<xsl:variable name="navigation" select="navigation[@navigation_id = current()/globals/item[@key = 'navigation_id']/@value]" />
		<xsl:variable name="plugin_method_call" select="plugin_method_call[@plugin_method_call_id = current()/globals/item[@key = 'plugin_method_call_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=navigation&amp;domain_id={$domain_id}">Navigation List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=navigation&amp;mode=navigation_edit&amp;domain_id={$domain_id}&amp;navigation_id={$navigation/@navigation_id}"><xsl:value-of select="$navigation/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=navigation&amp;mode=plugin_method_call_edit&amp;domain_id={$domain_id}&amp;navigation_id={$navigation/@navigation_id}&amp;plugin_method_call_id={$plugin_method_call/@plugin_method_call_id}">
				<xsl:choose>
					<xsl:when test="$plugin_method_call">Edit Plugin Call</xsl:when>
					<xsl:otherwise>Add Plugin Call</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Plugin Call</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="plugin_method_call_save" />
			<input type="hidden" name="domain_id" value="{$domain_id}" />
			<input type="hidden" name="plugin_method_call_id" value="{$plugin_method_call/@plugin_method_call_id}" />
			<input type="hidden" name="navigation_id" value="{$navigation/@navigation_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Plugin Call" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="plugin-method-id">Plugin:</label></th>
						<td>
							<select id="plugin-method-id" name="plugin_method_id">
								<xsl:for-each select="plugin">
									<xsl:sort select="@plugin" data-type="text" />
									<optgroup label="{@plugin}">
										<xsl:for-each select="../plugin_method[@plugin_id = current()/@plugin_id]">
											<option value="{@plugin_method_id}">
												<xsl:if test="@plugin_method_id = $plugin_method_call/@plugin_method_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
												<xsl:value-of select="@method" />
											</option>
										</xsl:for-each>
									</optgroup>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="inherit">Inherit:</label></th>
						<td>
							<input type="hidden" name="inherit" value="0" />
							<label>
								<input type="checkbox" name="inherit" value="1">
									<xsl:if test="$plugin_method_call/@inherit = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="position">Position:</label></th>
						<td><input type="text" id="position" name="position" value="{$plugin_method_call/@position}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="sequence">Sequence:</label></th>
						<td><input type="text" id="sequence" name="sequence" value="{$plugin_method_call/@sequence}" /></td>
					</tr>
				</tbody>
			</table>
		</form>

		<!-- //If the plugin_method call is set, allow access to the plugin param form -->
		<xsl:if test="$plugin_method_call/@plugin_method_call_id &gt; 0">
			<xsl:call-template name="plugin-param" />
		</xsl:if>

	</xsl:template>

	<xsl:template name="plugin-param">
		<xsl:variable name="navigation" select="navigation[@navigation_id = current()/globals/item[@key = 'navigation_id']/@value]" />
		<xsl:variable name="plugin_method_call" select="plugin_method_call[@plugin_method_call_id = current()/globals/item[@key = 'plugin_method_call_id']/@value]" />
		<h1>Add / Edit Plugin Parameters</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="plugin_method_call_param_save" />
			<input type="hidden" name="domain_id" value="{$domain_id}" />
			<input type="hidden" name="plugin_method_call_id" value="{$plugin_method_call/@plugin_method_call_id}" />
			<input type="hidden" name="navigation_id" value="{$navigation/@navigation_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="3">
							<input type="button" class="admin template-add plugin add-plugin-param" value="Add" data-target=".admin.plugin.add-plugin-param.target" data-template=".admin.plugin.plugin-param.template" />
							<input type="submit" value="Save" />
						</th>
					</tr>
				</tfoot>
				<tbody class="admin plugin add-plugin-param target">

					<!-- //Title Row -->
					<tr>
						<th scope="col"><label for="parameter">Parameter</label></th>
						<th scope="col"><label for="value">Value</label></th>
						<th scope="col"><label for="action">Action</label></th>
					</tr>

					<!-- //Each Existing Row -->
					<xsl:for-each select="/config/plugin_method_call_param[@plugin_method_call_id = $plugin_method_call/@plugin_method_call_id]">
						<tr class="admin plugin plugin-param">
							<td>
								<input type="text" name="param[]" value="{@param}" />
							</td>
							<td>
								<input type="text" name="value[]" value="{@value}" />
							</td>
							<td>
								<input type="button" class="admin template-delete plugin delete-plugin-param" value="Delete" data-target=".admin.plugin.plugin-param" />
							</td>
						</tr>
					</xsl:for-each>		

					<!-- //Template Row -->
					<tr class="admin plugin plugin-param template">
						<td>
							<input type="text" name="param[]" disabled="disabled" />
						</td>
						<td>
							<input type="text" name="value[]" disabled="disabled" />
						</td>
						<td>
							<input type="button" class="admin template-delete plugin delete-plugin-param" value="Delete" data-target=".admin.plugin.plugin-param"/>
						</td>
					</tr>

				</tbody>
			</table>
		</form>
	</xsl:template>

</xsl:stylesheet>