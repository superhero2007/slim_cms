<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'product_edit']">
		<xsl:variable name="product" select="product[@product_id = current()/globals/item[@key = 'product_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=products">Product List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=products&amp;mode=product_edit&amp;product_id={$product/@product_id}">
				<xsl:choose>
					<xsl:when test="$product"><xsl:value-of select="$product/@name" /></xsl:when>
					<xsl:otherwise>Add Product</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Product</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="product_save" />
			<input type="hidden" name="product_id" value="{$product/@product_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="3"><input type="submit" value="Save Product" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="name">Name:</label></th>
						<td colspan="2"><input type="text" id="name" name="name" value="{$product/@name}" /></td>
					</tr>
					<xsl:for-each select="currency">
						<xsl:variable name="price" select="../product_price[@product_id = $product/@product_id][@currency_id = current()/@currency_id]/@price" />
						<xsl:variable name="AUD" select="/config/exchange_rate[@code = 'AUD']/@rate" />
						
						<tr>
							<th scope="row">
								<label for="price-{@currency_id}">
									<xsl:value-of select="@code" />
									<xsl:text> Price</xsl:text>
									<xsl:if test="@tax_exempt = '0'">
										<xsl:text> (inc. Tax)</xsl:text>
									</xsl:if>
									<xsl:text>:</xsl:text>
								</label>
							</th>
							<td>
								<input type="text" id="price-{@currency_id}" name="price[{@currency_id}]" value="{$price}" />
							</td>
							<td>
								<xsl:text>AUD </xsl:text>
								<xsl:choose>
									<xsl:when test="@code = 'USD'">
										<xsl:value-of select="format-number($price * $AUD,'#,##0.00')" />
									</xsl:when>
									<xsl:when test="/config/exchange_rate[@code = current()/@code]/@rate &gt;= $AUD">
										<xsl:value-of select="format-number($price * ($AUD div /config/exchange_rate[@code = current()/@code]/@rate),'#,##0.00')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="format-number($price * (/config/exchange_rate[@code = current()/@code]/@rate div $AUD),'#,##0.00')" />
									</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</xsl:for-each>
                    
                    <!-- //Audit the product? //Lets us know if BV gets a share of the sale -->
					<tr>
						<th scope="row"><label for="audit">Audit:</label></th>
						<td colspan="2">
							<label>
	                            <input type="hidden" name="audit" value="0" />
								<input type="checkbox" id="audit" name="audit" value="1">
										<xsl:if test="$product/@audit = 1">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
                    
				</tbody>
			</table>
		</form>
		
		<!-- //Product Description -->
		<h1>Product Description / Items</h1>
		<p>This should list the details of the product, eg; 1 x GreenBizCheck Office Assessment - one per line</p>
			<table>
				<thead>
					<tr>
						<th scope="col">Item</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th><input type="button" value="Add Item" onclick="document.location = '?page=products&amp;mode=product_item_edit&amp;product_id={$product/@product_id}'" /></th>
					</tr>
				</tfoot>
				<tbody>
					<xsl:for-each select="product_item[@product_id = $product/@product_id]">
						<tr>
							<td>
								<xsl:value-of select="@description" /><br />
								<span class="options">
									<a href="?page=products&amp;mode=product_item_edit&amp;product_id={$product/@product_id}&amp;product_description_id={@product_description_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=products&amp;action=product_description_delete&amp;mode=product_edit&amp;product_id={$product/@product_id}&amp;product_description_id={@product_description_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		
		<xsl:if test="$product">
			<h1>Assessments</h1>
			<table>
				<thead>
					<tr>
						<th scope="col">Assessment</th>
						<th scope="col">Variation</th>
						<th scope="col">No of Assessments</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="3"><input type="button" value="Add Assessment" onclick="document.location = '?page=products&amp;mode=checklist_2_product_edit&amp;product_id={$product/@product_id}';" /></th>
					</tr>
				</tfoot>
				<tbody>
					<xsl:for-each select="checklist_2_product[@product_id = $product/@product_id]">
						<tr>
							<td>
								<xsl:value-of select="/config/checklist[@checklist_id = current()/@checklist_id]/@name" /><br />
								<span class="options">
									<a href="?page=products&amp;mode=checklist_2_product_edit&amp;product_id={$product/@product_id}&amp;checklist_2_product_id={@checklist_2_product_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=products&amp;action=checklist_2_product_delete&amp;mode=product_edit&amp;product_id={$product/@product_id}&amp;checklist_2_product_id={@checklist_2_product_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>	
							</td>
							<td><xsl:value-of select="/config/checklist_variation[@checklist_variation_id = current()/@checklist_variation_id]/@name" /></td>
							<td><xsl:value-of select="@checklists" /></td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
			<h1>Suggestions</h1>
			<table>
				<thead>
					<tr>
						<th scope="col">Product</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th><input type="button" value="Add Suggestion" onclick="document.location = '?page=products&amp;mode=suggestion_edit&amp;product_id={$product/@product_id}'" /></th>
					</tr>
				</tfoot>
				<tbody>
					<xsl:for-each select="suggestion[@product_id = $product/@product_id]">
						<tr>
							<td>
								<xsl:value-of select="/config/product[@product_id = current()/@suggested_product_id]/@name" /><br />
								<span class="options">
									<a href="?page=products&amp;mode=suggestion_edit&amp;product_id={$product/@product_id}&amp;suggestion_id={@suggestion_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=products&amp;action=suggestion_delete&amp;mode=product_edit&amp;product_id={$product/@product_id}&amp;suggestion_id={@suggestion_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>