<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'coupon_list']">
		<h1>Coupon Management</h1>
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=products&amp;mode=coupon_list">Coupon List</a>
		</p>
		<h1>Coupon List</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">Coupon</th>
					<th scope="col">Currency</th>
					<th scope="col">Discount</th>
					<th scope="col">Active</th>
					<th scope="col">Expiry</th>
					<th scope="col">Overall Limit</th>
					<th scope="col">Limit Per Customer</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="7"><input type="button" value="Add New Coupon" onclick="document.location = '?page=products&amp;mode=coupon_edit'" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="coupon">
					<tr>
						<td>
							<xsl:value-of select="@coupon" />
							<br />
							<span class="options">
								<a href="?page=products&amp;mode=coupon_edit&amp;coupon_id={@coupon_id}">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=products&amp;action=coupon_delete&amp;coupon_id={@coupon_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td><xsl:value-of select="../currency[@currency_id = current()/@currency_id]/@code" /></td>
						<td>
							<xsl:choose>
								<xsl:when test="@discount_type = 'percent'"><xsl:value-of select="@discount" />%</xsl:when>
								<xsl:otherwise>$<xsl:value-of select="@discount" /></xsl:otherwise>
							</xsl:choose>
						</td>
						<td><xsl:value-of select="@active_date" /></td>
						<td><xsl:value-of select="@expire_date" /></td>
						<td><xsl:value-of select="@limit" /></td>
						<td><xsl:value-of select="@limit_per_customer" /></td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
</xsl:stylesheet>