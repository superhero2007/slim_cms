<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'coupon_2_product_edit']">
		<xsl:variable name="coupon" select="coupon[@coupon_id = current()/globals/item[@key = 'coupon_id']/@value]" />
		<xsl:variable name="coupon_2_product" select="coupon_2_product[@coupon_2_product_id = current()/globals/item[@key = 'coupon_2_product_id']/@value]" />
		<h1>Coupon Management</h1>
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=products&amp;mode=coupon_list">Coupon List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=products&amp;mode=coupon_edit&amp;coupon_id={$coupon/@coupon_id}"><xsl:value-of select="$coupon/@coupon" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=products&amp;mode=coupon_2_product_edit&amp;coupon_id={$coupon/@coupon_id}&amp;coupon_2_product_id={$coupon_2_product/@coupon_2_product_id}">
				<xsl:choose>
					<xsl:when test="$coupon_2_product"><xsl:value-of select="product[@product_id = $coupon_2_product/@product_id]/@name" /></xsl:when>
					<xsl:otherwise>Add Product</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Product to Coupon</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="coupon_2_product_save" />
			<input type="hidden" name="coupon_id" value="{$coupon/@coupon_id}" />
			<input type="hidden" name="coupon_2_product_id" value="{$coupon_2_product/@coupon_2_product_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Product to Coupon" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="product-id">Product:</label></th>
						<td>
							<select id="product-id" name="product_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="product">
									<option value="{@product_id}">
										<xsl:if test="$coupon_2_product/@product_id = current()/@product_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="limit-per-transaction">Limit Per Transaction:</label></th>
						<td><input type="text" id="limit-per-transaction" name="limit_per_transaction" value="{$coupon_2_product/@limit_per_transaction}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
	
</xsl:stylesheet>