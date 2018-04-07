<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:func="http://exslt.org/functions"
	xmlns:math="http://exslt.org/math"
	extension-element-prefixes="gbc func math">
		
	<xsl:param name="cart" select="/config/plugin[@plugin = 'pos'][@method = 'getCart']" />
	<xsl:param name="currency" select="/config/plugin[@plugin = 'pos'][@method = 'getCart']/currency[@selected]" />
	
	<func:function name="gbc:formatCurrency">
		<xsl:param name="number" select="0" />
		<xsl:param name="format" select="'###,##0.00'" />
		
		<func:result>
			<xsl:choose>
				<xsl:when test="$currency/@symbol_pos = 'before'">
					<xsl:value-of select="$currency/@symbol" />
					<xsl:value-of select="format-number($number,$format)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="format-number($number,$format)" />
					<xsl:value-of select="$currency/@symbol" />
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>
	<xsl:template match="/config/plugin[@plugin = 'pos'][@method = 'payAccount'][account = false()]">
		<h2>Pay Your Account</h2>
		<p>You have no accounts.</p>
	</xsl:template>
	<xsl:template match="/config/plugin[@plugin = 'pos'][@method = 'payAccount'][account = true()]">
		
		<div class="left-half">
		<h2>Pay Your Account</h2>
		<input type="hidden" name="action" value="payAccount" />
		<table>
			<tr>
				<td><strong>Account Number:</strong></td>
				<td><xsl:value-of select="account/@account_no" /></td>
			</tr>
			<tr>
				<td><strong>Company Name:</strong></td>
				<td><xsl:value-of select="account/@company_name" /></td>
			</tr>
			<xsl:for-each select="ballance">
			<tr>
				<td><strong>Amount due:</strong></td>
				<td>
					<xsl:text>$</xsl:text>
					<xsl:value-of select="format-number(@amount,'#,##0.00')" />
					<xsl:text> </xsl:text>
					<xsl:value-of select="@currency_code" />
				</td>
			</tr>
			</xsl:for-each>
		</table>
		</div>
		<xsl:if test="sum(ballance/@amount) &gt; 0">
			<div class="right-half">
				<h3>Pay Here</h3>
				<form method="post">
					<input type="hidden" name="action" value="payAccount" />
					<p>
						<xsl:choose>
							<xsl:when test="count(ballance[@amount &gt; 0]) &gt; 1">
								<label>
									<xsl:text>Amount: $ </xsl:text>
									<input type="text" name="amount" />
								</label>
								<select name="currency_code">
									<xsl:for-each select="ballance[@amount &gt; 0]">
										<option value="{@currency_code}">
											<xsl:value-of select="@currency_code" />
										</option>
									</xsl:for-each>
								</select>
							</xsl:when>
							<xsl:otherwise>
								<label>
									<strong>Amount:</strong>
									<xsl:text> $ </xsl:text>
									<input type="text" name="amount" value="{format-number(ballance[@amount &gt; 0]/@amount,'0.00')}" />
									<xsl:text> </xsl:text>
									<xsl:value-of select="ballance[@amount &gt; 0]/@currency_code" />
								</label>
								<input type="hidden" name="currency" value="{ballance[@amount &gt; 0]/@currency_code}" />
							</xsl:otherwise>
						</xsl:choose>
						<br /><br /><input type="submit" value="  Pay Now  " />
						<img src="/_images/paypal_accept.gif" style="float: right;" />
					</p>
				</form>
			</div>
		</xsl:if>
		<br class="clear" />
		<hr />
		<h2>Invoices &amp; Previous Payments</h2>
		<xsl:if test="invoice">
			<div class="left-half-divider">
				<h3>Account Invoices</h3>
				<table class="tablesorter">
					<thead>
						<tr>
							<th scope="col"><strong>Date</strong></th>
							<th scope="col"><strong>Amount</strong></th>
							<th scope="col"><strong>Download</strong></th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="invoice">
							<xsl:sort select="@invoice_date" order="ascending" />
							<tr>
								<td><xsl:value-of select="@invoice_date" /></td>
								<td><xsl:value-of select="concat(@currency_code,' ',format-number(@amount,'#,##0.00'))" /></td>
								<td><a href="/pay-your-account/invoice-pdf?account_no={../account/@account_no}&amp;invoice_id={@invoice_id}">PDF</a></td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
		</xsl:if>
		<xsl:if test="transaction">
			<div class="right-half">
				<h3>Previous Payments</h3>
				<table class="tablesorter">
					<thead>
						<tr>
							<th scope="col"><strong>Date / Time</strong></th>
							<th scope="col"><strong>Amount</strong></th>
							<th scope="col"><strong>Method</strong></th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="transaction">
							<xsl:sort select="@timestamp" order="ascending" />
							<tr>
								<td><xsl:value-of select="@timestamp" /></td>
								<td><xsl:value-of select="concat(@currency_code,' ',format-number(@amount,'#,##0.00'))" /></td>
								<td><xsl:value-of select="@method" /></td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
		</xsl:if>
		<br class="clear" />
		
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'pos'][@method = 'payAccount'][account = true()][/config/globals/item[@key = 'action' and @value = 'payAccount']]">
		<h2>Pay Your Account</h2>
		<form method="post" id="paypal" action="{@paypalAddress}" style="text-align: center;">
			<p>You are now being redirected to PayPal's website to complete your transaction.</p>
			<p><img src="/_images/paypal_accept.gif" alt="Paypal" /></p>
			<input type="hidden" name="cmd" value="_s-xclick" />
			<input type="hidden" name="encrypted" value="{paypal}" />
			<p><input type="submit" class="large_button_300" value="Click here if you've been waiting too long." /></p>
<script type="text/javascript">
jQuery(document).ready(function() {
	$('#paypal').submit();
});
</script>
		</form>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'pos'][@method = 'getCart']">
		<h2>Your Cart</h2>
		<p>There are no items in your cart.</p>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'pos'][@method = 'getCart'][item]">
		<h2>Your Cart</h2>
		<xsl:apply-templates select="lastItem" />
		<xsl:call-template name="currencySelect" />
		<br />
		<form id="cart" method="post" action="/cart/">
			<input type="hidden" name="action" value="update_cart" />
			<input type="hidden" id="remove_item" name="remove_item" value="" />
			<table class="cart">
				<col />
				<col style="width: 10%;" />
				<col style="width: 20%;" />
				<thead>
					<tr>
						<th scope="col">Item</th>
						<th scope="col" class="money">Price</th>
						<th scope="col">Quantity</th>
						<th scope="col" class="money">Subtotal</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<td colspan="3">Subtotal:</td>
						<td class="money"><xsl:value-of select="gbc:formatCurrency(summary/@subtotal)" disable-output-escaping="yes" /></td>
					</tr>
					<xsl:if test="$currency/@tax_exempt = '0'">
						<tr>
							<td colspan="3">Includes <xsl:value-of select="$currency/@tax_name" /> (<xsl:value-of select="$currency/@tax_rate" />%):</td>
							<td class="money"><xsl:value-of select="gbc:formatCurrency(summary/@tax)" disable-output-escaping="yes" /></td>
						</tr>
					</xsl:if>
					<xsl:if test="summary/@discount &gt; 0">
						<tr>
							<td colspan="3"><xsl:value-of select="concat('Less Discount (',summary/@coupon,'):')" /></td>
							<td class="money"><xsl:value-of select="gbc:formatCurrency(summary/@discount)" disable-output-escaping="yes" /></td>
						</tr>
					</xsl:if>
					<!-- //Coupon code display -->
					<xsl:if test="summary/@coupon_name != ''">
						<tr>
							<td colspan="4">The coupon '<xsl:value-of select="summary/@coupon_name" />' has been applied to this transaction.</td>
						</tr>
					</xsl:if>
					<tr>
						<td colspan="3" class="cart_total"><strong>Grand Total:</strong></td>
						<td class="cart_total"><strong><xsl:value-of select="gbc:formatCurrency(summary/@total)" disable-output-escaping="yes" /></strong></td>
					</tr>
				</tfoot>
				<tbody>
					<xsl:for-each select="item">
						<tr>
							<td>
								<label>
									<!--<input type="checkbox" name="remove_item[]" value="{@item_id}" />
									<xsl:text> </xsl:text>-->
									<xsl:value-of select="../product[@product_id = current()/@product_id]/@name" />
									
										<!-- //Insert any product description/items -->
										<xsl:for-each select="../product/productDescription[@product_id = current()/@product_id]">
											<br /><span class="product_description">- <xsl:value-of select="@description" /></span>
										</xsl:for-each>
									
									<br /><a href="javascript:updateCart({@product_id})" class="remove_item">
									<xsl:text>remove item</xsl:text>
									</a>
								</label>
							</td>
							<td><xsl:value-of select="gbc:formatCurrency(../product[@product_id = current()/@product_id]/@price)" disable-output-escaping="yes" /></td>
							<td><input type="text" name="quantity[{@item_id}]" value="{@quantity}" size="3" /></td>
							<td class="money"><xsl:value-of select="gbc:formatCurrency(@quantity * ../product[@product_id = current()/@product_id]/@price)" disable-output-escaping="yes" /></td>
						</tr>
					</xsl:for-each>
					<tr>
						<!--<td><input type="submit" value="Remove Checked Items" /></td>-->
						<td colspan="2"><xsl:text> </xsl:text></td>
						<td><input type="submit" value="Update Totals" /></td>
						<td><xsl:text> </xsl:text></td>
					</tr>
				</tbody>
			</table>
		</form>
		<script type="text/javascript">
			function updateCart(productId) {
				document.getElementById('cart').elements['remove_item'].value = productId;
				document.getElementById('cart').submit();
			}
		</script>
		<div class="left-half">
			<xsl:if test="suggestion">
				<h3>May we suggest</h3>
				<xsl:for-each select="suggestion">
					<p>
						<xsl:value-of select="../product[@product_id = current()/@product_id]/@name" />
						<xsl:text> - </xsl:text>
						<xsl:value-of select="gbc:formatCurrency(../product[@product_id = current()/@product_id]/@price)" disable-output-escaping="yes" />
						<xsl:text> - </xsl:text>
						
						<form method="post" action="" class="suggest">
							<input type="hidden" name="action" value="add_product_to_cart" />
							<input type="hidden" name="product_id" value="" />
							<input type="hidden" name="quantity" value="1" />
							<input type="image" src="/_images/public-v3/buttons/buy-now.png" alt="Buy Now">
								<xsl:attribute name="onclick">this.form.elements['product_id'].value = <xsl:value-of select="@product_id" />;this.form.submit();</xsl:attribute>
							</input>
						</form>
					</p>
				</xsl:for-each>
			</xsl:if>
		</div>
		<div class="right-half">
			<form method="post" action="/cart/">
				<input type="hidden" name="action" value="claim_coupon" />
				<fieldset>
					<legend>Enter your coupon here</legend>
					<xsl:if test="couponError">
						<p class="error"><xsl:value-of select="couponError" /></p>
					</xsl:if>
					<p>If you have a valid coupon enter it here</p>
					<p>
						<label>
							<strong>Coupon code: </strong>
							<input type="text" name="coupon" />							
						</label>
						<input type="submit" value="Claim Coupon" />
					</p>
				</fieldset>
			</form>
		</div>
		<hr class="clear" />
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'pos'][@method = 'checkout']">
	
	<!-- //New Payment option section -->
	<script type="text/javascript">
	function checkPaymentMethod() {
		var selected = false;
	 	
		for (i=0; i != document.payment_select_form.method.length; i++) {
			if(document.payment_select_form.method[i].checked) {
				selected = true;
			}
		}
		
		if(selected == false) {
			alert('Please select a payment method');	
			return(false);
		}
		
		if(!document.getElementById('serviceAgreementCheckbox').checked) {
			document.getElementById('serviceAgreementCheckbox').parentNode.style.color = "#FF0000";
			alert('Please read and agree to the service agreement');
		
			return(false);
		}
		return(true);
	}
	
	function serviceAgreement() {
		if(!document.getElementById('serviceAgreementCheckbox').checked) {
			document.getElementById('serviceAgreementCheckbox').parentNode.style.color = "#FF0000";
			alert('Please read and agree to the service agreement');
		
			return(false);
		}
		return(true);
	}
	</script>
	<xsl:choose>
		<xsl:when test="$cart/summary/@total &gt; 0">
	<form method="post" name="payment_select_form" action="/cart/" onsubmit="return(checkPaymentMethod());">
	<input type="hidden" name="action" value="checkout" />
	<table class="payment_select">
		<tr>
			<td class="cart_total" colspan="2"><strong>Select Payment Method</strong></td>
		</tr>
		<tr>
			<td colspan="2">
				<input type="radio" name="method" value="paypal" /> 
				Pay Pal/Credit Card - (Instant Payment - Start your assessment now)
			</td>
		</tr>
		<tr>
			<td colspan="2"><input type="radio" name="method" value="sendInvoice" /> Send me an invoice for alternate payment - (Cheque/Bank Transfer/Money Order)</td>
		</tr>
		<tr>
			<td class="submit_payment_option"><input type="checkbox" id="serviceAgreementCheckbox" value="1" /> I have read and agree to the <a href="/service-agreement/">service agreement</a> and the <a href="/privacy/">Privacy Policy</a></td>
			<td class="submit_payment_option"><input type="submit" class="large_button" value=" Checkout &amp; Pay " /></td>
		</tr>
	</table>
	<br />
	<center><img src="/_images/paypal_accept.gif" /></center>
	</form>
	</xsl:when>
	<xsl:otherwise>
		<h2>No Payment Required</h2>
					<p>Your cart has no value so no payment is required, please click on Complete Transaction below and your items will be automatically activated/delivered.</p>
					<form method="post" action="/cart/" onsubmit="return(serviceAgreement());">
						<input type="hidden" name="action" value="checkout" />
						<p><input type="submit" class="large_button" value="Complete Purchase" /></p>
					</form>
				</xsl:otherwise>
			</xsl:choose>
	<!--
<script type="text/javascript">
function serviceAgreement() {
	if(!document.getElementById('serviceAgreementCheckbox').checked) {
		document.getElementById('serviceAgreementCheckbox').parentNode.style.color = "#FF0000";
		alert('Please read and agree to the service agreement');
		
		return(false);
	}
	return(true);
}
</script>
		<div class="left-half">
			<h2>Service Agreement</h2>
			<p><label><input type="checkbox" id="serviceAgreementCheckbox" value="1" /> I have read and agree to the <a href="/service-agreement/">service agreement</a> and the <a href="/privacy/">Privacy Policy</a>.</label></p>
		</div>
		<div class="right-half">
			<xsl:choose>
				<xsl:when test="$cart/summary/@total &gt; 0">
					<a href="javascript:;" onclick="window.open('https://www.paypal.com/au/verified/pal=info%40greenbizcheck%2ecom','paypalverfified','location=1,scrollbars=1,width=850,height=400');" style="float: right;"><img src="/_images/paypal_verification_seal.gif" alt="Official PayPal Seal" /></a>
					<h2>Pay with Credit Card or Pay Pal</h2>
					<p>PayPal is the safer, easier way to make an online payment. Pay with your credit card or registered PayPal account.</p>
					<form method="post" action="/cart/" onsubmit="return(serviceAgreement());">
						<input type="hidden" name="action" value="checkout" />
						<p><input type="image" src="/_images/paypal_accept.gif" /></p>
					</form>
					<hr />
					<h2>Send me an Invoice</h2>
					<p>Do you want an invoice for the contents of this cart? The items selected will not become available to your account until payment for this invoice has been received. If you would like to start using these items immediately, please use the Paypal option above.</p>
					<form method="post" action="/cart/" onsubmit="return(serviceAgreement());">
						<input type="hidden" name="action" value="checkout" />
						<input type="hidden" name="method" value="sendInvoice" />
						<button class="large green awesome">Send me an Invoice</button>
					</form>
				</xsl:when>
				<xsl:otherwise>
					<h2>No Payment Required</h2>
					<p>Your cart has no value so no payment is required, please click on Complete Transaction below and your items will be automatically activated/delivered.</p>
					<form method="post" action="/cart/" onsubmit="return(serviceAgreement());">
						<input type="hidden" name="action" value="checkout" />
						<p><input type="submit" value="Complete Purchase" /></p>
					</form>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		-->
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'pos'][@method = 'getCart'][/config/globals/item[@key = 'action' and @value = 'checkout']]" />
	
	<xsl:template match="/config/plugin[@plugin = 'pos'][@method = 'checkout'][/config/globals/item[@key = 'action' and @value = 'checkout']]">
		<form method="post" id="paypal" action="{@paypalAddress}" style="text-align: center;">
			<h2>Checkout</h2>
			<p>You are now being redirected to PayPal's website to complete your transaction.</p>
			<p><img src="/_images/paypal_accept.gif" alt="Paypal" /></p>
			<input type="hidden" name="cmd" value="_s-xclick" />
			<input type="hidden" name="encrypted" value="{paypal}" />
			<p><input type="submit" class="large_button_300" value="Click here if you've been waiting too long." /></p>
<script type="text/javascript">
jQuery(document).ready(function() {
	$('#paypal').submit();
});
</script>
		</form>
	</xsl:template>
	
	<xsl:template match="lastItem">
		<p><xsl:value-of select="@name" /> has been added to your cart.</p>
	</xsl:template>
	
	<xsl:template match="multiProducts" mode="html">
		<!--<xsl:call-template name="currencySelect" />-->
		<xsl:variable name="products" select="/config/plugin[@plugin = 'pos'][@method = 'getCart']/product" />
		<form method="post" action="" class="multi-products">
			<input type="hidden" name="action" value="add_product_to_cart" />
			<input type="hidden" name="product_id" value="" />
			<input type="hidden" name="quantity" value="1" />
			<table id="certify" class="product-list">
				<tbody>
					<tr>
						<xsl:for-each select="product">
							<td>
								<p class="product-tile">
									<xsl:value-of select="@product_name" />
								</p>
								<p class="product-price">
									<xsl:value-of select="gbc:formatCurrency($products[@product_id = current()/@product_id]/@price,'###,###')" disable-output-escaping="yes" />
								</p>
								<p class="product-name"><xsl:value-of select="@product_size" /></p>
								<p>No. Staff: <strong><xsl:value-of select="@num_of_staff" /></strong><br />(Full Time Equivalent)</p>
								<p>Annual Price Inc. GST</p>
								<input type="image" src="/_images/public-v3/buttons/buy-now.png" alt="Buy Now">
									<xsl:attribute name="onclick">this.form.elements['product_id'].value = <xsl:value-of select="@product_id" />;this.form.submit();</xsl:attribute>
								</input>
							</td>
						</xsl:for-each>
					</tr>				
				</tbody>
			</table>
		</form>
		
		<!-- //Small note for NSWBC clients -->
		<xsl:if test="(/config/domain[@name = 'nswbc.greenbizcheck.local']) or (/config/domain[@name = 'nswbc.greenbizcheck.com'])">
			<center><p><strong>Note that member discount of 10% will apply at check out</strong></p></center>
		</xsl:if>
	</xsl:template>
	
	<!-- //A smaller version of the multiproducts template -->
		<xsl:template match="multiProductsSmall" mode="html">
		<!--<xsl:call-template name="currencySelect" />-->
		<xsl:variable name="products" select="/config/plugin[@plugin = 'pos'][@method = 'getCart']/product" />
		<form method="post" action="" class="multi-products-small">
			<input type="hidden" name="action" value="add_product_to_cart" />
			<input type="hidden" name="product_id" value="" />
			<input type="hidden" name="quantity" value="1" />
			<table id="certify" class="multi-products-small">
				<tbody>
					<tr>
						<xsl:for-each select="product">
							<td>
								<p class="product-tile">
									<xsl:value-of select="$products[@product_id = current()/@product_id]/@name" />
								</p>
								<p class="product-price">
									<xsl:value-of select="gbc:formatCurrency($products[@product_id = current()/@product_id]/@price,'###,###')" disable-output-escaping="yes" />
								</p>
								<xsl:for-each select="info[@type = 'body']">
									<xsl:variable name="ref" select="@ref" />
										<xsl:for-each select="../product">
											<p><xsl:value-of select="@*[name() = $ref]" /></p>
										</xsl:for-each>
								</xsl:for-each>
								<input type="image" src="/_images/public-v3/buttons/buy-now.png" alt="Buy Now">
									<xsl:attribute name="onclick">this.form.elements['product_id'].value = <xsl:value-of select="@product_id" />;this.form.submit();</xsl:attribute>
								</input>
							</td>
						</xsl:for-each>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
	<!-- // End the smaller multiproducts template -->
	
	<xsl:template match="productList" mode="html">
		<xsl:variable name="products" select="/config/plugin[@plugin = 'pos'][@method = 'getCart']/product[@product_id &lt;= 5]" />
		<!--<xsl:call-template name="currencySelect" />-->
		<form method="post" action="" class="product-list">
			<input type="hidden" name="action" value="add_product_to_cart" />
			<input type="hidden" name="product_id" value="" />
			<input type="hidden" name="quantity" value="1" />
			<table id="certify" class="product-list">
				<tbody>
					<tr>
						<td>
							<p class="product-tile">Certification</p>
							<p class="product-price">$699</p>
							<p class="product-name">Entry</p>
							<p>No. Staff: <strong>1 - 10</strong><br />(Full Time Equivalent)</p>
							<p>Annual Price Inc.</p>
							<input type="image" src="/_images/public-v3/buttons/buy-now.png" alt="Buy Now" onclick="this.form.elements['product_id'].value = 1;this.form.submit();" class="product-button" />
						</td>
						<td>
							<p class="product-tile">Certification</p>
							<p class="product-price">$1,250</p>
							<p class="product-name">Small</p>
							<p>No. Staff: <strong>11 - 20</strong><br />(Full Time Equivalent)</p>
							<p>Annual Price Inc.</p>
							<input type="image" src="/_images/public-v3/buttons/buy-now.png" alt="Buy Now" onclick="this.form.elements['product_id'].value = 2;this.form.submit();" class="product-button" />
						</td>
						<td>
							<p class="product-tile">Certification</p>
							<p class="product-price">$2,250</p>
							<p class="product-name">Medium</p>
							<p>No. Staff: <strong>21 - 50</strong><br />(Full Time Equivalent)</p>
							<p>Annual Price Inc.</p>
							<input type="image" src="/_images/public-v3/buttons/buy-now.png" alt="Buy Now" onclick="this.form.elements['product_id'].value = 3;this.form.submit();" class="product-button" />
						</td>
						<td>
							<p class="product-tile">Certification</p>
							<p class="product-price">$4,500</p>
							<p class="product-name">Large</p>
							<p>No. Staff: <strong>51 - 100</strong><br />(Full Time Equivalent)</p>
							<p>Annual Price Inc.</p>
							<input type="image" src="/_images/public-v3/buttons/buy-now.png" alt="Buy Now" onclick="this.form.elements['product_id'].value = 4;this.form.submit();" class="product-button" />
						</td>
						<td>
							<p class="product-tile">Certification</p>
							<p class="product-price">$8,900</p>
							<p class="product-name">Enterprise</p>
							<p>No. Staff: <strong>101 - 500</strong><br />(Full Time Equivalent)</p>
							<p>Annual Price Inc.</p>
							<input type="image" src="/_images/public-v3/buttons/buy-now.png" alt="Buy Now" onclick="this.form.elements['product_id'].value = 5;this.form.submit();" class="product-button" />
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
	
	<xsl:template name="currencySelect">
		<xsl:variable name="currencies" select="/config/plugin[@plugin = 'pos'][@method = 'getCart']/currency" />
<!--		<xsl:choose>
			<xsl:when test="/config/plugin[@plugin = 'clients']/client/@currency_id != ''">
				<div style="text-align: right;">Currency displayed in <xsl:value-of select="concat($currencies[@selected]/@description,' (',$currencies[@selected]/@code,')')" />.</div>
			</xsl:when>
			<xsl:otherwise>-->
				<form method="post" action="" style="text-align: right;">
					<input type="hidden" name="action" value="change_currency" />
					<label>
						<xsl:text>Select your currency: </xsl:text>
						<select name="currency_id" onChange="this.form.submit();">
							<xsl:for-each select="$currencies">
								<option value="{@currency_id}">
									<xsl:if test="@selected"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
									<xsl:value-of select="concat(@description,' (',@code,')')" />
								</option>
							</xsl:for-each>
						</select>
					</label>
				</form>
		<!--	</xsl:otherwise>
		</xsl:choose> -->
	</xsl:template>
	
</xsl:stylesheet>