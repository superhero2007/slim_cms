<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'coupon_edit']">
		<xsl:variable name="coupon" select="coupon[@coupon_id = current()/globals/item[@key = 'coupon_id']/@value]" />
		<h1>Coupon Management</h1>
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=products&amp;mode=coupon_list">Coupon List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=products&amp;mode=coupon_edit&amp;coupon_id={$coupon/@coupon_id}">
				<xsl:choose>
					<xsl:when test="$coupon"><xsl:value-of select="$coupon/@coupon" /></xsl:when>
					<xsl:otherwise>Add Coupon</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Coupon</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="coupon_save" />
			<input type="hidden" name="coupon_id" value="{$coupon/@coupon_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Coupon" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="coupon">Coupon:</label></th>
						<td><input type="text" id="coupon" name="coupon" value="{$coupon/@coupon}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="currency-id">Currency:</label></th>
						<td>
							<select id="currency-id" name="currency_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="currency">
									<option value="{@currency_id}">
										<xsl:if test="$coupon/@currency_id = current()/@currency_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@code" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="active-date">Active Date:</label></th>
						<td><input type="text" id="active-date" name="active_date" value="{$coupon/@active_date}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="expire-date">Expiry Date:</label></th>
						<td><input type="text" id="expire-date" name="expire_date" value="{$coupon/@expire_date}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="limit">Overall Limit:</label></th>
						<td><input type="text" id="limit" name="limit" value="{$coupon/@limit}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="dollar_limit">Overall Dollar Limit:</label></th>
						<td><input type="text" id="dollar_limit" name="dollar_limit" value="{$coupon/@dollar_limit}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="limit-per-customer">Limit Per Customer:</label></th>
						<td><input type="text" id="limit-per-customer" name="limit_per_customer" value="{$coupon/@limit_per_customer}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="discount">Discount:</label></th>
						<td><input type="text" id="discount" name="discount" value="{$coupon/@discount}" /></td>
					</tr>
					<tr>
						<th scope="row">Discount Type:</th>
						<td>
							<label>
								<input type="radio" name="discount_type" value="percent">
									<xsl:if test="$coupon/@discount_type = 'percent' or not($coupon)"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Percent</xsl:text>
							</label>
							<xsl:text> </xsl:text>
							<label>
								<input type="radio" name="discount_type" value="dollar">
									<xsl:if test="$coupon/@discount_type = 'dollar'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Dollar</xsl:text>
							</label>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
		<xsl:if test="$coupon">
			<h1>Coupon Products</h1>
			<p>To limt coupons to a certain product or products add them here. Otherwise to leave the coupon applicable to all products leave this clear.</p>
			<table>
				<thead>
					<tr>
						<th scope="col">Product</th>
						<th scope="col">Transaction Limit</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="2"><input type="button" value="Add Product" onclick="document.location = '?page=products&amp;mode=coupon_2_product_edit&amp;coupon_id={$coupon/@coupon_id}';" /></th>
					</tr>
				</tfoot>
				<tbody>
					<xsl:for-each select="coupon_2_product[@coupon_id = $coupon/@coupon_id]">
						<tr>
							<td>
								<xsl:value-of select="../product[@product_id = current()/@product_id]/@name" />
								<br />
								<span class="options">
									<a href="?page=products&amp;mode=coupon_2_product_edit&amp;coupon_id={@coupon_id}&amp;coupon_2_product_id={@coupon_2_product_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=products&amp;action=coupon_2_product_delete&amp;coupon_id={@coupon_id}&amp;coupon_2_product_id={@coupon_2_product_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
							<td><xsl:value-of select="@limit_per_transaction" /></td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>