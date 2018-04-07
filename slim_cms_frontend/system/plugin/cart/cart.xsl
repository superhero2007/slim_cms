<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">
	
	<xsl:template match="/config/plugin[@plugin = 'cart'][@method = 'getProducts']">
		<h2>Certify Your Business</h2>
		<p>Thankyou for taking the first steps in certifying your business with greenbizcheck. Please complete the information below and we will be on our way.</p>
		<form method="post" action="" class="generic">
			<input type="hidden" name="action" value="certify" />
			<div style="background-color: #EEE; padding: 1em;">
				<p>
					<label>
						<strong>Number of Employees:</strong>
						<input type="text" name="num_employees" value="{/config/globals/item[@key = 'num_employees']/@value}" />
					</label>
					<xsl:apply-templates select="error[@field = 'num_employees']" />
				</p>
				<p>
					<label>
						<input type="checkbox" name="agree" value="1">
							<xsl:if test="/config/globals/item[@key = 'agree']/@value = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
						</input>
						<xsl:text> I / we have read and agree to the </xsl:text>
						<a href="/terms/" target="_blank">Consulting Services Agreement</a>
						<xsl:text>.</xsl:text>
					</label>
					<xsl:if test="error[@field = 'agree']">
						<span class="error">You must agree to the Consulting Service Agreement</span>
					</xsl:if>
				</p>
			</div>
			<p><input type="submit" value="Continue &gt;" /></p>
		</form>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'cart'][@method = 'getProducts'][@mode = 'confirm']">
		<xsl:if test="@num_employees">			
			<h2>Certify Your Business</h2>
			<div class="checkout">
				<table>
					<thead>
						<tr>
							<th scope="col">Description</th>
							<th scope="col" style="text-align: right;">Quantity</th>
							<th scope="col" style="text-align: right;">Amount</th>
						</tr>
					</thead>
					<tfoot>
						<xsl:choose>
							<xsl:when test="/config/plugin[@plugin = 'clients']/client/@country = 'AU'">
								<tr>
									<th scope="row" colspan="2">Sub total:</th>
									<td><xsl:value-of select="format-number(certLevel/@member_fee,'$###,###.00')" /></td>
								</tr>
								<tr>
									<th scope="row" colspan="2">GST:</th>
									<td><xsl:value-of select="format-number(certLevel/@member_fee_gst,'$###,###.00')" /></td>
								</tr>
								<tr>
									<th scope="row" colspan="2">Total:</th>
									<td class="total"><xsl:value-of select="format-number(certLevel/@member_fee + certLevel/@member_fee_gst,'$###,###.00')" /></td>
								</tr>
							</xsl:when>
							<xsl:otherwise>
								<tr>
									<th scope="row" colspan="2">Total:</th>
									<td class="total"><xsl:value-of select="format-number(certLevel/@member_fee,'$###,###.00')" /></td>
								</tr>
							</xsl:otherwise>
						</xsl:choose>
					</tfoot>
					<tbody>
						<tr>
							<th scope="row">greenbizcheck Environmental Certification</th>
							<td>1</td>
							<td><xsl:value-of select="format-number(certLevel/@member_fee,'$###,###.00')" /></td>
						</tr>
					</tbody>
				</table>
			</div>
			<h2>Two ways to pay</h2>
			<form method="post" action="https://www.paypal.com/cgi-bin/webscr" style="background: #EEE; padding: 1em;">
				<p>
					<h2 class="left">1.</h2>
					<input type="image" src="/_images/btn_xpressCheckout.gif" />
				</p>
				<blockquote>
					<p>Pay with PayPal with your credit card or registered PayPal account to gain <strong>instant access</strong> to the certification checklist.</p>
				</blockquote>
				<input type="hidden" name="cmd" value="_s-xclick" />
				<input type="hidden" name="encrypted" value="{paypal}" />
			</form>
			<form method="post" action="" class="checkout" style="padding: 1em;">
				<input type="hidden" name="num_employees" value="{@num_employees}" />
				<input type="hidden" name="agree" value="1" />
				<input type="hidden" name="action" value="invoice" />
				<input tyoe="hidden" name="mode" value="invoice" />
				<p>
					<h2 class="left">2.</h2>
					<input type="submit" value="Pay by cheque / Direct Deposit" />
				</p>
				<blockquote>
					<p>An invoice will be sent to your email address. As soon as we receive your payment we will issue your GreenBizCheck assessment.</p>
				</blockquote>
			</form>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'cart'][@method = 'getProducts'][@mode = 'invoice']">
		<h2>Certify Your Business</h2>
		<p>Thank you, an email has been sent to your email address with your invoice, please arrange payment within 14 days to begin your certification checklist.</p>
	</xsl:template>
	
	<xsl:template match="error">
		<span class="error"><xsl:value-of select="." /></span>
	</xsl:template>
	    
</xsl:stylesheet>