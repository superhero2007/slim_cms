<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template name="menu">
		<h1>Product Management</h1>
	</xsl:template>
	
	<xsl:template match="config">
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=products">Product List</a>
		</p>
		<h1>Product List</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">Name</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th><input type="button" value="Add Product" onclick="document.location = '?page=products&amp;mode=product_edit';" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="product">
					<tr>
						<td>
							<xsl:value-of select="@name" /><br />
							<span class="options">
								<a href="?page=products&amp;mode=product_edit&amp;product_id={@product_id}">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=products&amp;action=product_delete&amp;product_id={@product_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:include href="modes/checklist_2_product_edit.xsl" />
	<xsl:include href="modes/coupon_2_product_edit.xsl" />
	<xsl:include href="modes/coupon_edit.xsl" />
	<xsl:include href="modes/coupon_list.xsl" />
	<xsl:include href="modes/product_edit.xsl" />
	<xsl:include href="modes/suggestion_edit.xsl" />
	<xsl:include href="modes/product_item_edit.xsl" />
	
</xsl:stylesheet>