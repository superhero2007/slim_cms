<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'suggestion_edit']">
		<xsl:variable name="product" select="product[@product_id = current()/globals/item[@key = 'product_id']/@value]" />
		<xsl:variable name="suggestion" select="suggestion[@suggestion_id = current()/globals/item[@key = 'suggestion_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=products">Product List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=products&amp;mode=product_edit&amp;product_id={$product/@product_id}"><xsl:value-of select="$product/@name" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=products&amp;mode=suggestion_edit&amp;product_id={$product/@product_id}&amp;suggestion_id={$suggestion/@suggestion_id}">Add / Edit Suggestion</a>
		</p>
		<form method="post" action="">
			<input type="hidden" name="action" value="suggestion_save" />
			<input type="hidden" name="product_id" value="{$product/@product_id}" />
			<input type="hidden" name="suggestion_id" value="{$suggestion/@suggestion_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Suggestion" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="suggested-product-id">Suggested Product:</label></th>
						<td>
							<select id="suggested-product-id" name="suggested_product_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="product[@product_id != $product/@product_id]">
									<option value="{@product_id}">
										<xsl:if test="$suggestion/@suggested_product_id = current()/@product_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
	
</xsl:stylesheet>