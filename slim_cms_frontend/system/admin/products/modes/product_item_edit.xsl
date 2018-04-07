<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'product_item_edit']">
		<xsl:variable name="product" select="product[@product_id = current()/globals/item[@key = 'product_id']/@value]" />
		<xsl:variable name="product_item" select="product_item[@product_description_id = current()/globals/item[@key = 'product_description_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=products">Product List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=products&amp;mode=product_edit&amp;product_id={$product/@product_id}"><xsl:value-of select="$product/@name" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=products&amp;mode=product_item_edit&amp;product_id={$product/@product_id}&amp;product_description_id={$product_item/@product_description_id}">Add / Edit Product Description / Item</a>
		</p>
		<form method="post" action="">
			<input type="hidden" name="action" value="product_item_save" />
			<input type="hidden" name="product_id" value="{$product/@product_id}" />
			<input type="hidden" name="product_item_id" value="{$product_item/@product_description_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Item" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="suggested-product-id">Description / Item:</label></th>
						<td>
							<input type="text" name="description" id="description" value="{$product_item/@description}" />
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
	
</xsl:stylesheet>