<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:str="http://exslt.org/strings"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config[@mode = 'invoice_edit']">
		<xsl:variable name="client" select="client[@client_id = current()/globals/item[@key = 'client_id']/@value]" />
		<xsl:variable name="invoice" select="invoice[@invoice_id = current()/globals/item[@key = 'invoice_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=clients">Client List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_edit&amp;client_id={$client/@client_id}"><xsl:value-of select="$client/@company_name" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=invoice_edit&amp;client_id={$client/@client_id}&amp;invoice_id={$invoice/@invoice_id}">
				<xsl:choose>
					<xsl:when test="$invoice">Invoice No. <xsl:value-of select="$invoice/@invoice_id" /></xsl:when>
					<xsl:otherwise>Add Invoice</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Invoice</h1>
		<p>NOTE: If a coupon is set it will overide any value set in the discount field.</p>
		<form method="post" action="">
			<input type="hidden" name="action" value="invoice_save" />
			<input type="hidden" name="client_id" value="{$client/@client_id}" />
			<input type="hidden" name="invoice_id" value="{$invoice/@invoice_id}" />
			<input type="hidden" name="timestamp" value="{$invoice/@timestamp}" />
			<table class="editTable">
				<thead>
					<tr>
						<th colspan="2"></th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Invoice" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="invoice-date">Invoice Date:<br />(YYYY-MM-DD)</label></th>
						<td><input type="text" id="invoice-date" name="invoice_date" value="{$invoice/@invoice_date}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="terms">Terms:</label></th>
						<td><input type="text" id="terms" name="terms" value="{$invoice/@terms}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="currency-id">Currency:</label></th>
						<td>
							<select id="currency-id" name="currency_id">
								<xsl:for-each select="currency">
									<option value="{@currency_id}">
										<xsl:if test="$invoice/@currency_id = current()/@currency_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@code" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="discount">Discount:</label></th>
						<td><input type="text" id="discount" name="discount" value="{$invoice/@discount}" /></td>
					</tr>
					
					<!-- //Allow the ability to set the coupon code in the admin system when raising an invoice -->
					<tr>
						<th scope="row"><label for="coupon">Apply Coupon:</label></th>
						<td>
							<select id="coupon_id" name="coupon_id">
								<option value="0">None</option>
								<xsl:for-each select="coupon">
									<option value="{@coupon_id}">
										<xsl:if test="$invoice/@coupon_id = current()/@coupon_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="concat(@coupon, ' - [', @discount, ' ', @discount_type, ']')" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					
					<!-- //Add a section to provide client notes or instructions -->
					<tr>
						<th scope="row"><label for="notes">Client notes/instructions:</label></th>
						<td>
							<textarea name="notes" id="notes" rows="5">
								<xsl:value-of select="$invoice/@notes" />
							</textarea>
						</td>
					</tr>
					
					<!-- //Archive Invoice -->
					<tr>
						<th scope="row"><label for="archive">Archive:</label></th>
						<td>
							<label>
	                            <input type="hidden" name="archive" value="0" />
								<input type="checkbox" id="archive" name="archive" value="1">
										<xsl:if test="$invoice/@archive = 1">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
                    <tr>
						<th scope="row"><label for="paid-date">Paid Date:<br />(YYYY-MM-DD)</label></th>
						<td><input type="text" id="paid-date" name="paid_date" value="{$invoice/@paid_date}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
		<xsl:if test="$invoice">
			<xsl:if test="product_2_invoice[@invoice_id = $invoice/@invoice_id]">
				<h1>Products</h1>
				
					<!-- //Get the currently redeemed coupon -->
					<xsl:variable name="redeemed_coupon" select="coupon[@coupon_id = $invoice/@coupon_id]" />
					
					<!--//Get the new invoice total based on the discount applied -->
					<xsl:variable name="discounted_amount">
						<xsl:choose>
							<xsl:when test="$redeemed_coupon/@discount_type = 'percent'">
								<xsl:value-of select="sum(product_2_invoice[@invoice_id = $invoice/@invoice_id]/@total) * ($redeemed_coupon/@discount * 0.01)" />	
							</xsl:when>
							<!--//Otherwise it is a dollar discount -->
							<xsl:when test="$redeemed_coupon/@discount_type = 'dollar'">
								<xsl:value-of select="$redeemed_coupon/@discount" />	
							</xsl:when>
							<!-- //Otherwise there is no coupon set and we should default back to the invoice dollar discount -->
							<xsl:otherwise>
								<xsl:value-of select="$invoice/@discount" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<!-- //Get the total minus any discount -->
					<xsl:variable name="invoice_total">
							<xsl:value-of select="sum(product_2_invoice[@invoice_id = $invoice/@invoice_id]/@total)" />
					</xsl:variable>
				
				<table class="editTable">
					<tfoot>
						<tr>
						    <th>
								<!-- //Display the discount if there is one to be applied -->
								<xsl:if test="$discounted_amount > 0">
									<span class="notice">
										<xsl:choose>
											<xsl:when test="$invoice/@coupon_id > 0">
												<xsl:value-of select="concat('The coupon ',$redeemed_coupon/@coupon, ' has been applied to this invoice [', $redeemed_coupon/@discount, ' ', $redeemed_coupon/@discount_type,']')" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat('This invoice has had an $',format-number($invoice/@discount,'#,##0.00'),' discount applied')" />
											</xsl:otherwise>
										</xsl:choose>
									</span>
								</xsl:if>
						    </th>
							<th style="text-align: right;">Total:</th>
							<th style="text-align: right;"><xsl:value-of select="sum(product_2_invoice[@invoice_id = $invoice/@invoice_id]/@quantity)" /></th>
							<th style="text-align: right;"><xsl:value-of select="concat(currency[@currency_id = $invoice/@currency_id]/@code,' ',format-number($invoice_total,'#,##0.00'))" /></th>
						</tr>
					</tfoot>
					<thead>
						<tr>
							<th scope="col">Product</th>
							<th scope="col" style="text-align: right;">Price Per Item</th>
							<th scope="col" style="text-align: right;">Quantity</th>
							<th scope="col" style="text-align: right;">Total</th>
						</tr>
					</thead>
					<thead>
						<tr>
							<th colspan="4"></th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="product_2_invoice[@invoice_id = $invoice/@invoice_id]">
							<tr>
								<td>
									<xsl:value-of select="../product[@product_id = current()/@product_id]/@name" />
									<xsl:if test="@received = '1'"><xsl:text> - </xsl:text><em>(already received)</em></xsl:if>
									<br />
									<span class="options">
										<a href="?page=clients&amp;action=product_2_invoice_delete&amp;client_id={$client/@client_id}&amp;invoice_id={$invoice/@invoice_id}&amp;product_2_invoice_id={@product_2_invoice_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
									</span>
								</td>
								<td style="text-align: right;"><xsl:value-of select="concat(../currency[@currency_id = $invoice/@currency_id]/@code,' ',format-number(@price_per_item,'#,##0.00'))" /></td>
								<td style="text-align: right;"><xsl:value-of select="@quantity" /></td>
								<td style="text-align: right;"><xsl:value-of select="concat(../currency[@currency_id = $invoice/@currency_id]/@code,' ',format-number(@total,'#,##0.00'))" /></td>
							</tr>
						</xsl:for-each>
						
					</tbody>
				</table>
			</xsl:if>
			<h1>Add Product</h1>
			<form method="post" action="">
				<input type="hidden" name="action" value="product_2_invoice_save" />
				<input type="hidden" name="client_id" value="{$client/@client_id}" />
				<input type="hidden" name="invoice_id" value="{$invoice/@invoice_id}" />
				<table class="editTable">
					<thead>
						<tr>
							<th colspan="3"></th>
						</tr>
					</thead>
					<tfoot>
						<tr>
							<th colspan="3"><input type="submit" value="Add Product" /></th>
						</tr>
					</tfoot>
					<tbody>
						<tr>
							<th scope="row"><label for="product-id">Product:</label></th>
							<td colspan="2">
								<select id="product-id" name="product_id">
									<xsl:for-each select="product">
										<option value="{@product_id}">
											<xsl:value-of select="concat(@name,' (',../currency[@currency_id = $invoice/@currency_id]/@code,' ',format-number(../product_price[@product_id = current()/@product_id][@currency_id = $invoice/@currency_id]/@price,'#,##0.00'),')')" />
										</option>
									</xsl:for-each>
								</select>
							</td>
						</tr>
						<tr>
							<th scope="row"><label for="quantity">Quantity:</label></th>
							<td><input type="text" id="quantity" name="quantity" value="1" /></td>
						</tr>
					<!--	<tr>
							<th scope="row">
								<label for="price-per-item">
									<xsl:text>Price Per Item:</xsl:text>
									<xsl:if test="currency[@currency_id = $invoice/@currency_id]/@tax_exempt = '0'"> (inc. GST)</xsl:if>
								</label>
							</th>
							<td><input type="text" id="price-per-item" name="price_per_item" /></td>
						</tr>-->
						<tr>
							<th scope="row"><label for="received">Item(s) received:</label></th>
							<td>
								<input type="hidden" name="received" value="0" />
								<label><input type="checkbox" id="received" name="received" value="1" /> Yes</label>
							</td>
						</tr>
					</tbody>
				</table>
			</form>
			
			<xsl:if test="$invoice">

				<h1>Download Invoice</h1>
				<a href="/pay-your-account/invoice-pdf?account_no={$client/@account_no}&amp;invoice_id={$invoice/@invoice_id}">download pdf invoice</a>
			</xsl:if>
			<!--<form method="post" action="">
				<input type="hidden" name="action" value="send_invoice" />
				<input type="hidden" name="client_id" value="{$client/@client_id}" />
				<input type="hidden" name="invoice_id" value="{$invoice/@invoice_id}" />
				<center><input type="submit" value="Generate Invoice" /></center>
			</form>-->
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>