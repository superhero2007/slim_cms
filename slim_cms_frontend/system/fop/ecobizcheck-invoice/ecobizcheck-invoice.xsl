<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:xf="http://www.ecrion.com/xf/1.0" 
	xmlns:xc="http://www.ecrion.com/xc" 
	xmlns:xfd="http://www.ecrion.com/xfd/1.0" 
	xmlns:svg="http://www.w3.org/2000/svg" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:date="http://exslt.org/dates-and-times" 
	xmlns:str="http://exslt.org/strings" 			
	xmlns:exsl="http://exslt.org/common"
 	version="1.0" 
	exclude-element-prefix="date str exsl"
	extension-element-prefixes="date str exsl">
	<xsl:output indent="yes"/>

	<xsl:variable name="invoice" select="/config/fop/invoice"/>
	
	<xsl:variable name="head-list">
		<item>
			<caption>Website</caption>
			<value><fo:basic-link external-destination="url('http://www.ecobizcheck.com')" text-decoration="underline" color="rgb(0,0,255)">www.ecobizcheck.com</fo:basic-link></value>
		</item>
		<item>
			<caption>E-mail</caption>
			<value><fo:basic-link external-destination="url('mailto:info@ecobizcheck.com')" text-decoration="underline" color="rgb(0,0,255)">info@ecobizcheck.com</fo:basic-link></value>
		</item>
		<item>
			<caption>Phone</caption>
			<value>
				<fo:block>(702) 932-7979</fo:block>
			</value>
		</item>
		<item>
			<caption>Address</caption>
			<value>
				<fo:block>3651 Lindell Rd. Suite D#250</fo:block>
				<fo:block>Las Vegas, NV. 89103</fo:block>
				<fo:block>USA</fo:block>
			</value>
		</item>
		<item>
			<caption>Account Number</caption>
			<value><xsl:value-of select="$invoice/client/@account_no"/></value>
		</item>
		<item>
			<caption>Invoice Number</caption>
			<value><xsl:value-of select="$invoice/@invoice_no_display"/></value>
		</item>
		<item>
			<caption>Date</caption>
			<value><xsl:value-of select="$invoice/@invoice_date_long"/></value>
		</item>
		<xsl:if test="$invoice/@discount &gt; 0">
			<item>
				<caption>Discount Included</caption>
				<value><fo:inline font-weight="bold"><xsl:value-of select="format-number($invoice/@discount, '$###,##0.00')"/></fo:inline></value>
			</item>
		</xsl:if>
		<item>
			<caption>Due Date</caption>
			<value><fo:block color="rgb(255,0,0)" font-weight="bold"><xsl:value-of select="$invoice/@due_date_long"/></fo:block></value>
		</item>
		<item>
			<caption>Amount Due</caption>
			<value><fo:block color="rgb(255,0,0)" padding-bottom="6pt" font-weight="bold"><xsl:value-of select="format-number($invoice/@amount_due, '$###,##0.00')"/></fo:block></value>
		</item>
	</xsl:variable>
	
	<xsl:variable name="bank-details">
		<item>
			<caption>Bank</caption>
			<value>Citibank</value>
		</item>
		<item>
			<caption>Account Name</caption>
			<value>EcoBizCheck Operations Inc.</value>
		</item>
		<item>
			<caption>Account Number</caption>
			<value>500373832</value>
		</item>
		<item>
			<caption>Routing Number</caption>
			<value>122401710</value>
		</item>
	</xsl:variable>
	
	<xsl:template name="display-field-table">
		<xsl:param name="list"/>
		<xsl:param name="col1-width" select="'3.3cm'"/>
		<xsl:param name="col2-width" select="'4.4cm'"/>
	
		<fo:table>
			<fo:table-column column-width="{$col1-width}"/>
			<fo:table-column column-width="{$col2-width}"/>
			<fo:table-body>
				<xsl:for-each select="$list/item">
					<fo:table-row>
						<fo:table-cell padding-bottom="5pt"><fo:block font-weight="bold">
							<xsl:value-of select="caption"/>
							<xsl:text>:</xsl:text>
						</fo:block></fo:table-cell>
						<fo:table-cell padding-bottom="5pt"><fo:block>
							<xsl:copy-of select="value/node()"/>
						</fo:block></fo:table-cell>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>	
	</xsl:template>
		
	<!-- ========================= ROOT TEMPLATE =========================== -->
	<xsl:template match="/">
		<fo:root>
			<fo:layout-master-set>
				<fo:simple-page-master master-name="all-pages" page-width="21cm" page-height="29.7cm">
					<fo:region-body padding="0%" margin="1cm" margin-top="2cm" region-name="xsl-region-body" column-gap="0.25in"/>
					<fo:region-before padding="0%" region-name="xsl-region-before" display-align="after" extent="0mm"/>
					<fo:region-after padding="0%" region-name="xsl-region-after" display-align="before" extent="0mm"/>
					<fo:region-start region-name="xsl-region-start" extent="1cm"/>
					<fo:region-end region-name="xsl-region-end" extent="1cm"/>
				</fo:simple-page-master>
			</fo:layout-master-set>
			<fo:page-sequence master-reference="all-pages">
				<fo:static-content flow-name="xsl-region-before" font-size="12pt" font-family="Helvetica">
					<fo:block> </fo:block>
				</fo:static-content>
				<fo:static-content flow-name="xsl-region-after" font-size="12pt" font-family="Helvetica">
					<fo:block> </fo:block>
				</fo:static-content>
				<fo:static-content flow-name="xsl-region-start" font-size="12pt" font-family="Helvetica">
					<fo:block> </fo:block>
				</fo:static-content>
				<fo:static-content flow-name="xsl-region-end" font-size="12pt" font-family="Helvetica">
					<fo:block> </fo:block>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body" font-size="12pt" font-family="Helvetica">
					<!-- Logo -->
					<fo:block-container position="absolute" left="0cm" top="0cm" width="8.5cm" height="5cm" text-align="center">
						<fo:block><fo:external-graphic src="url(ecobizcheck-cloud-logo.png)" content-width="8cm" /></fo:block>
						<fo:block font-size="8pt" width="5.5cm">
							<fo:block>EcoBizCheck Operations Inc.</fo:block>
						</fo:block>
					</fo:block-container>
					
					<!-- Address Block -->
					<fo:block-container position="absolute" left="0cm" top="3.6cm" width="8.5cm" height="2.5cm">
						<fo:block background-color="rgb(235,235,235)">
							<fo:block font-size="10pt" margin="6pt">
								<fo:block font-weight="bold"><xsl:value-of select="$invoice/client/@company_name"/></fo:block>
								<fo:block><xsl:value-of select="$invoice/client/@address_line_1"/></fo:block>
								<xsl:if test="$invoice/client/@address_line_2 != ''">
									<fo:block><xsl:value-of select="$invoice/client/@address_line_2"/></fo:block>
								</xsl:if>
								<fo:block><xsl:value-of select="$invoice/client/@suburb"/></fo:block>
								<fo:block><xsl:value-of select="concat($invoice/client/@state,' ',$invoice/client/@postcode)"/></fo:block>
							</fo:block>
						</fo:block>
					</fo:block-container>
					
					<!-- Top-right Data Block -->
					<fo:block-container position="absolute" left="11.5cm" top="0cm" width="9cm" height="7cm">
						<fo:block font-size="10pt">
							<xsl:call-template name="display-field-table">
								<xsl:with-param name="list" select="exsl:node-set($head-list)"/>
							</xsl:call-template>							
						</fo:block>
					</fo:block-container>
					
					<!-- Main Invoice Content -->
					<fo:block-container position="absolute" left="0cm" top="6.5cm" width="19cm" border-style="sold">
						<fo:block font-size="20pt" font-weight="bold">Tax Invoice/Receipt</fo:block>
						<fo:block font-size="10pt" margin-top="0.5cm">
							<fo:table>
								<fo:table-column column-width="12.5cm"/>
								<fo:table-column column-width="3.2cm"/>
								<fo:table-column column-width="3.3cm"/>
								<fo:table-header>
									<fo:table-row background-color="rgb(235,235,235)">
										<fo:table-cell padding-top="3pt" padding-bottom="3pt" padding-left="3pt" border-style="solid" border-width="0.5pt" border-color="rgb(0,0,0)">
											<fo:block text-align="left" font-weight="bold">Description</fo:block>
										</fo:table-cell>
										<fo:table-cell padding-top="3pt" padding-bottom="3pt" border-style="solid" border-width="0.5pt" border-color="rgb(0,0,0)">
											<fo:block text-align="center" font-weight="bold">Quantity</fo:block>
										</fo:table-cell>
										<fo:table-cell padding-top="3pt" padding-bottom="3pt" padding-right="3pt" border-style="solid" border-width="0.5pt" border-color="rgb(0,0,0)">
											<fo:block text-align="right" font-weight="bold">Amount</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-header>
								<fo:table-body>
									<xsl:for-each select="$invoice/items/item">
										<fo:table-row>
											<fo:table-cell padding-top="5pt" padding-bottom="5pt" padding-left="3pt" border-style="solid" border-width="0.5pt" border-color="rgb(0,0,0)">
												<fo:block text-align="left" font-weight="bold">
													<xsl:value-of select="@name"/>
												</fo:block>
												
												<!-- //Insert the product descriptions -->
												<xsl:for-each select="/config/plugin[@plugin = 'pos']/product[@product_id = current()/@product_id]/productDescription">
													<fo:block text-align="left" margin-left="10pt" font-size="6pt">
														<xsl:value-of select="@description" disable-output-escaping="no" />
													
													</fo:block>
												</xsl:for-each>												
												<!-- //End insert of the product descriptions -->
												
											</fo:table-cell>
											<fo:table-cell padding-top="5pt" padding-bottom="5pt" border-style="solid" border-width="0.5pt" border-color="rgb(0,0,0)">
												<fo:block text-align="center"><xsl:value-of select="format-number(@quantity, '#,##0.##')"/></fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="5pt" padding-bottom="5pt" padding-right="3pt" border-style="solid" border-width="0.5pt" border-color="rgb(0,0,0)">
												<fo:block text-align="right"><xsl:value-of select="format-number(@quantity * @price_per_item, '$#,##0.00')"/></fo:block>
											</fo:table-cell>
										</fo:table-row>
									</xsl:for-each>

									<xsl:if test="$invoice/@coupon_id > 0">
										<fo:table-row>
											<fo:table-cell padding-top="0.9cm" padding-left="3pt" text-align="left">
											<!-- //If a coupon has been used show it here -->											
												<fo:block font-size="6pt">The coupon '<xsl:value-of select="$invoice/coupon[@coupon_id = $invoice/@coupon_id]/@coupon" />' has been applied to this transaction.</fo:block>				
											<!--//End of coupon being used -->
											</fo:table-cell>
										</fo:table-row>
									</xsl:if>
									<!-- Total Lines -->
			
									<fo:table-row>
										<fo:table-cell padding-left="3pt" text-align="left" padding-top="10pt">
											<fo:block font-weight="bold">All prices are in <xsl:value-of select="$invoice/currency/@description"/> (<xsl:value-of select="$invoice/currency/@code"/>).</fo:block>
											
										</fo:table-cell>
										
										<fo:table-cell padding-top="0.9cm" padding-right="0.7cm" text-align="right">
											<fo:block font-weight="bold">Subtotal:</fo:block>
										</fo:table-cell>
										<fo:table-cell padding-top="0.9cm" padding-right="3pt" text-align="right">
											<fo:block>
												<xsl:choose>
													<xsl:when test="$invoice/currency/@tax_exempt = '0'">
														<xsl:value-of select="format-number($invoice/@total - ($invoice/@total - ($invoice/@total div (1 + ($invoice/currency/@tax_rate * 0.01)))), '$#,##0.00')"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="format-number($invoice/@total, '$#,##0.00')"/>
													</xsl:otherwise>
												</xsl:choose>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
									
									<xsl:if test="$invoice/currency/@tax_exempt = '0'">
									<fo:table-row>
										<fo:table-cell padding-top="5pt" padding-left="3pt" text-align="left">
											<fo:block></fo:block>
										</fo:table-cell>
										<fo:table-cell padding-top="5pt" padding-right="0.7cm" text-align="right">
											<fo:block font-weight="bold"><xsl:value-of select="$invoice/currency/@tax_name" /> @ <xsl:value-of select="$invoice/currency/@tax_rate" />%:</fo:block>
										</fo:table-cell>
										<fo:table-cell padding-top="5pt" padding-right="3pt" text-align="right">
											<fo:block>
												<xsl:value-of select="format-number(($invoice/@total - ($invoice/@total div (1 + ($invoice/currency/@tax_rate * 0.01)))), '$#,##0.00')"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
									</xsl:if>

									<!-- //Dummy row for total spacing -->
									<fo:table-row>
										<fo:table-cell padding-top="5pt" padding-left="3pt" text-align="left">
											<fo:block></fo:block>
										</fo:table-cell>
										<fo:table-cell padding-top="5pt" padding-right="0.7cm" text-align="right">
											<fo:block></fo:block>
										</fo:table-cell>
										<fo:table-cell padding-top="5pt" padding-right="3pt" text-align="right">
											<fo:block></fo:block>
										</fo:table-cell>
									</fo:table-row>

									<fo:table-row>
										<fo:table-cell padding-top="5pt" padding-left="3pt" text-align="left">
											<fo:block></fo:block>
										</fo:table-cell>
										<fo:table-cell padding-top="5pt" padding-right="0.7cm" text-align="right" border-top-style="solid" border-top-width="1.5pt" border-top-color="rgb(0,0,0)">
											<fo:block font-weight="bold">Total:</fo:block>
										</fo:table-cell>
										<fo:table-cell padding-top="5pt" padding-right="3pt" text-align="right" border-top-style="solid" border-top-width="1.5pt" border-top-color="rgb(0,0,0)">
											<fo:block font-weight="bold">
												<xsl:value-of select="format-number($invoice/@total, '$#,##0.00')"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
									
								</fo:table-body>
							</fo:table>
							
							<!-- //Insert the notes for the invoice where applicable -->
							<xsl:if test="$invoice/@notes != ''">
								<fo:block font-weight="bold">Notes:</fo:block>
								<fo:block><xsl:value-of select="$invoice/@notes" /></fo:block>
							</xsl:if>
						</fo:block>
						
						<!-- Payment Options -->
						<fo:block line-height="12pt" font-size="10pt">
							<fo:block font-size="20pt" font-weight="bold" margin-top="0.5cm">Payment Options</fo:block>
							
							<fo:block font-size="12pt" font-weight="bold" margin-top="20pt">1. Online</fo:block>
							<fo:block>
								Payments can be made online with most major credit cards 
								<fo:basic-link external-destination="url('http://www.ecobizcheck.com/pay-your-account/?account_no={$invoice/client/@account_no}')" text-decoration="underline" color="rgb(0,0,255)">by clicking here</fo:basic-link>
								or visit 
							</fo:block>
							<fo:block>
								<fo:basic-link external-destination="url('http://www.ecobizcheck.com/pay-your-account/')" text-decoration="underline" color="rgb(0,0,255)">www.ecobizcheck.com/pay-your-account/</fo:basic-link>
								and enter your account number:
								<fo:inline font-weight="bold"><xsl:value-of select="$invoice/client/@account_no"/></fo:inline>
								in the field provided.
							</fo:block>
							
							<fo:block font-size="12pt" font-weight="bold" margin-top="12pt">2. Direct Deposit</fo:block>
							<fo:block>
								Payments can be made via internet banking or direct deposit using the following account details:
							</fo:block>
							
							<fo:block margin-top="10pt" margin-left="1cm">
								<xsl:call-template name="display-field-table">
									<xsl:with-param name="list" select="exsl:node-set($bank-details)"/>
									<xsl:with-param name="col1-width" select="'4cm'"/>
									<xsl:with-param name="col2-width" select="'10cm'"/>
								</xsl:call-template>
							</fo:block>
							
							<fo:block margin-top="6pt">
								Please use your EcoBizCheck account number <fo:inline font-weight="bold"><xsl:value-of select="$invoice/client/@account_no"/></fo:inline> as reference.
							</fo:block>
							<fo:block margin-top="6pt">
								<fo:inline font-weight="bold">Disclaimer: </fo:inline>Please note by payment of this invoice you access EcoBizCheck's terms and conditions and agree not to hold EcoBizCheck or any of its related parties liable for any errors, omissions or any actions taken as a result of any services, reports or advice given.
							</fo:block>
							<fo:block margin-top="6pt">
								Payment or Registration constitutes acceptance of our 
								<fo:basic-link external-destination="url('http://www.ecobizcheck.com/service-agreement/')" text-decoration="underline" color="rgb(0,0,255)">service agreement</fo:basic-link>.
							</fo:block>
							
						</fo:block>
			
					</fo:block-container>
					
				</fo:flow>
			</fo:page-sequence>
		</fo:root>
	</xsl:template>
	
<!-- ========================= NUMBER FORMATS ========================= -->
<!-- ========================= EXSLT TEMPLATES [str.padding.template.xsl] ========================= -->
	<xsl:template name="str:padding">
		<xsl:param name="length" select="0"/>
		<xsl:param name="chars" select="' '"/>
		<xsl:choose>
			<xsl:when test="not($length) or not($chars)"/>
			<xsl:otherwise>
				<xsl:variable name="string" select="concat($chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars)"/>
				<xsl:choose>
					<xsl:when test="string-length($string) &gt;= $length">
						<xsl:value-of select="substring($string, 1, $length)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="str:padding">
							<xsl:with-param name="length" select="$length"/>
							<xsl:with-param name="chars" select="$string"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
<!-- ========================= EXSLT TEMPLATES [date.format-date.template.xsl] ========================= -->
	<date:months>
		<date:month length="31" abbr="Jan">January</date:month>
		<date:month length="28" abbr="Feb">February</date:month>
		<date:month length="31" abbr="Mar">March</date:month>
		<date:month length="30" abbr="Apr">April</date:month>
		<date:month length="31" abbr="May">May</date:month>
		<date:month length="30" abbr="Jun">June</date:month>
		<date:month length="31" abbr="Jul">July</date:month>
		<date:month length="31" abbr="Aug">August</date:month>
		<date:month length="30" abbr="Sep">September</date:month>
		<date:month length="31" abbr="Oct">October</date:month>
		<date:month length="30" abbr="Nov">November</date:month>
		<date:month length="31" abbr="Dec">December</date:month>
	</date:months>
	<date:days>
		<date:day abbr="Sun">Sunday</date:day>
		<date:day abbr="Mon">Monday</date:day>
		<date:day abbr="Tue">Tuesday</date:day>
		<date:day abbr="Wed">Wednesday</date:day>
		<date:day abbr="Thu">Thursday</date:day>
		<date:day abbr="Fri">Friday</date:day>
		<date:day abbr="Sat">Saturday</date:day>
	</date:days>
	<xsl:template name="date:format-date">
		<xsl:param name="date-time"/>
		<xsl:param name="pattern"/>
		<xsl:variable name="formatted">
			<xsl:choose>
				<xsl:when test="starts-with($date-time, '---')">
					<xsl:call-template name="date:_format-date">
						<xsl:with-param name="year" select="'NaN'"/>
						<xsl:with-param name="month" select="'NaN'"/>
						<xsl:with-param name="day" select="number(substring($date-time, 4, 2))"/>
						<xsl:with-param name="pattern" select="$pattern"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="starts-with($date-time, '--')">
					<xsl:call-template name="date:_format-date">
						<xsl:with-param name="year" select="'NaN'"/>
						<xsl:with-param name="month" select="number(substring($date-time, 3, 2))"/>
						<xsl:with-param name="day" select="number(substring($date-time, 6, 2))"/>
						<xsl:with-param name="pattern" select="$pattern"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="neg" select="starts-with($date-time, '-')"/>
					<xsl:variable name="no-neg">
						<xsl:choose>
							<xsl:when test="$neg or starts-with($date-time, '+')">
								<xsl:value-of select="substring($date-time, 2)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$date-time"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="no-neg-length" select="string-length($no-neg)"/>
					<xsl:variable name="timezone">
						<xsl:choose>
							<xsl:when test="substring($no-neg, $no-neg-length) = 'Z'">Z</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="tz" select="substring($no-neg, $no-neg-length - 5)"/>
								<xsl:if test="(substring($tz, 1, 1) = '-' or                                      substring($tz, 1, 1) = '+') and                                    substring($tz, 4, 1) = ':'">
									<xsl:value-of select="$tz"/>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:if test="not(string($timezone)) or                           $timezone = 'Z' or                            (substring($timezone, 2, 2) &lt;= 23 and                            substring($timezone, 5, 2) &lt;= 59)">
						<xsl:variable name="dt" select="substring($no-neg, 1, $no-neg-length - string-length($timezone))"/>
						<xsl:variable name="dt-length" select="string-length($dt)"/>
						<xsl:choose>
							<xsl:when test="substring($dt, 3, 1) = ':' and                                   substring($dt, 6, 1) = ':'">
								<xsl:variable name="hour" select="substring($dt, 1, 2)"/>
								<xsl:variable name="min" select="substring($dt, 4, 2)"/>
								<xsl:variable name="sec" select="substring($dt, 7)"/>
								<xsl:if test="$hour &lt;= 23 and                                    $min &lt;= 59 and                                    $sec &lt;= 60">
									<xsl:call-template name="date:_format-date">
										<xsl:with-param name="year" select="'NaN'"/>
										<xsl:with-param name="month" select="'NaN'"/>
										<xsl:with-param name="day" select="'NaN'"/>
										<xsl:with-param name="hour" select="$hour"/>
										<xsl:with-param name="minute" select="$min"/>
										<xsl:with-param name="second" select="$sec"/>
										<xsl:with-param name="timezone" select="$timezone"/>
										<xsl:with-param name="pattern" select="$pattern"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="year" select="substring($dt, 1, 4) * (($neg * -2) + 1)"/>
								<xsl:choose>
									<xsl:when test="not(number($year))"/>
									<xsl:when test="$dt-length = 4">
										<xsl:call-template name="date:_format-date">
											<xsl:with-param name="year" select="$year"/>
											<xsl:with-param name="timezone" select="$timezone"/>
											<xsl:with-param name="pattern" select="$pattern"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="substring($dt, 5, 1) = '-'">
										<xsl:variable name="month" select="substring($dt, 6, 2)"/>
										<xsl:choose>
											<xsl:when test="not($month &lt;= 12)"/>
											<xsl:when test="$dt-length = 7">
												<xsl:call-template name="date:_format-date">
													<xsl:with-param name="year" select="$year"/>
													<xsl:with-param name="month" select="$month"/>
													<xsl:with-param name="timezone" select="$timezone"/>
													<xsl:with-param name="pattern" select="$pattern"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:when test="substring($dt, 8, 1) = '-'">
												<xsl:variable name="day" select="substring($dt, 9, 2)"/>
												<xsl:if test="$day &lt;= 31">
													<xsl:choose>
														<xsl:when test="$dt-length = 10">
															<xsl:call-template name="date:_format-date">
																<xsl:with-param name="year" select="$year"/>
																<xsl:with-param name="month" select="$month"/>
																<xsl:with-param name="day" select="$day"/>
																<xsl:with-param name="timezone" select="$timezone"/>
																<xsl:with-param name="pattern" select="$pattern"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:when test="substring($dt, 11, 1) = 'T' and                                                        substring($dt, 14, 1) = ':' and                                                        substring($dt, 17, 1) = ':'">
															<xsl:variable name="hour" select="substring($dt, 12, 2)"/>
															<xsl:variable name="min" select="substring($dt, 15, 2)"/>
															<xsl:variable name="sec" select="substring($dt, 18)"/>
															<xsl:if test="$hour &lt;= 23 and                                                         $min &lt;= 59 and                                                         $sec &lt;= 60">
																<xsl:call-template name="date:_format-date">
																	<xsl:with-param name="year" select="$year"/>
																	<xsl:with-param name="month" select="$month"/>
																	<xsl:with-param name="day" select="$day"/>
																	<xsl:with-param name="hour" select="$hour"/>
																	<xsl:with-param name="minute" select="$min"/>
																	<xsl:with-param name="second" select="$sec"/>
																	<xsl:with-param name="timezone" select="$timezone"/>
																	<xsl:with-param name="pattern" select="$pattern"/>
																</xsl:call-template>
															</xsl:if>
														</xsl:when>
													</xsl:choose>
												</xsl:if>
											</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="string(number(substring($dt,5,1)))!='NaN'">
										<xsl:variable name="month" select="substring($dt, 5, 2)"/>
										<xsl:choose>
											<xsl:when test="not($month &lt;= 12)"/>
											<xsl:when test="$dt-length = 6">
												<xsl:call-template name="date:_format-date">
													<xsl:with-param name="year" select="$year"/>
													<xsl:with-param name="month" select="$month"/>
													<xsl:with-param name="timezone" select="$timezone"/>
													<xsl:with-param name="pattern" select="$pattern"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:variable name="day" select="substring($dt, 7, 2)"/>
												<xsl:if test="$day &lt;= 31">
													<xsl:choose>
														<xsl:when test="$dt-length = 8">
															<xsl:call-template name="date:_format-date">
																<xsl:with-param name="year" select="$year"/>
																<xsl:with-param name="month" select="$month"/>
																<xsl:with-param name="day" select="$day"/>
																<xsl:with-param name="timezone" select="$timezone"/>
																<xsl:with-param name="pattern" select="$pattern"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:when test="substring($dt, 9, 1) = 'T' and  substring($dt, 12, 1) = ':' and  substring($dt, 15, 1) = ':'">
															<xsl:variable name="hour" select="substring($dt, 10, 2)"/>
															<xsl:variable name="min" select="substring($dt, 13, 2)"/>
															<xsl:variable name="sec" select="substring($dt, 16)"/>
															<xsl:if test="$hour &lt;= 23 and                                                         $min &lt;= 59 and                                                         $sec &lt;= 60">
																<xsl:call-template name="date:_format-date">
																	<xsl:with-param name="year" select="$year"/>
																	<xsl:with-param name="month" select="$month"/>
																	<xsl:with-param name="day" select="$day"/>
																	<xsl:with-param name="hour" select="$hour"/>
																	<xsl:with-param name="minute" select="$min"/>
																	<xsl:with-param name="second" select="$sec"/>
																	<xsl:with-param name="timezone" select="$timezone"/>
																	<xsl:with-param name="pattern" select="$pattern"/>
																</xsl:call-template>
															</xsl:if>
														</xsl:when>
													</xsl:choose>
												</xsl:if>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$formatted"/>
	</xsl:template>
	<xsl:template name="date:_format-date">
		<xsl:param name="year"/>
		<xsl:param name="month" select="1"/>
		<xsl:param name="day" select="1"/>
		<xsl:param name="hour" select="0"/>
		<xsl:param name="minute" select="0"/>
		<xsl:param name="second" select="0"/>
		<xsl:param name="timezone" select="'Z'"/>
		<xsl:param name="pattern" select="''"/>
		<xsl:variable name="char" select="substring($pattern, 1, 1)"/>
		<xsl:choose>
			<xsl:when test="not($pattern)"/>
			<xsl:when test="$char = &quot;'&quot;">
				<xsl:choose>
					<xsl:when test="substring($pattern, 2, 1) = &quot;'&quot;">
						<xsl:text>'</xsl:text>
						<xsl:call-template name="date:_format-date">
							<xsl:with-param name="year" select="$year"/>
							<xsl:with-param name="month" select="$month"/>
							<xsl:with-param name="day" select="$day"/>
							<xsl:with-param name="hour" select="$hour"/>
							<xsl:with-param name="minute" select="$minute"/>
							<xsl:with-param name="second" select="$second"/>
							<xsl:with-param name="timezone" select="$timezone"/>
							<xsl:with-param name="pattern" select="substring($pattern, 3)"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="literal-value" select="substring-before(substring($pattern, 2), &quot;'&quot;)"/>
						<xsl:value-of select="$literal-value"/>
						<xsl:call-template name="date:_format-date">
							<xsl:with-param name="year" select="$year"/>
							<xsl:with-param name="month" select="$month"/>
							<xsl:with-param name="day" select="$day"/>
							<xsl:with-param name="hour" select="$hour"/>
							<xsl:with-param name="minute" select="$minute"/>
							<xsl:with-param name="second" select="$second"/>
							<xsl:with-param name="timezone" select="$timezone"/>
							<xsl:with-param name="pattern" select="substring($pattern, string-length($literal-value) + 2)"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="not(contains('abcdefghjiklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', $char))">
				<xsl:value-of select="$char"/>
				<xsl:call-template name="date:_format-date">
					<xsl:with-param name="year" select="$year"/>
					<xsl:with-param name="month" select="$month"/>
					<xsl:with-param name="day" select="$day"/>
					<xsl:with-param name="hour" select="$hour"/>
					<xsl:with-param name="minute" select="$minute"/>
					<xsl:with-param name="second" select="$second"/>
					<xsl:with-param name="timezone" select="$timezone"/>
					<xsl:with-param name="pattern" select="substring($pattern, 2)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not(contains('GyMdhHmsSEDFwWakKz', $char))">
				<xsl:message>
              Invalid token in format string: <xsl:value-of select="$char"/></xsl:message>
				<xsl:call-template name="date:_format-date">
					<xsl:with-param name="year" select="$year"/>
					<xsl:with-param name="month" select="$month"/>
					<xsl:with-param name="day" select="$day"/>
					<xsl:with-param name="hour" select="$hour"/>
					<xsl:with-param name="minute" select="$minute"/>
					<xsl:with-param name="second" select="$second"/>
					<xsl:with-param name="timezone" select="$timezone"/>
					<xsl:with-param name="pattern" select="substring($pattern, 2)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="next-different-char" select="substring(translate($pattern, $char, ''), 1, 1)"/>
				<xsl:variable name="pattern-length">
					<xsl:choose>
						<xsl:when test="$next-different-char">
							<xsl:value-of select="string-length(substring-before($pattern, $next-different-char))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="string-length($pattern)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$char = 'G'">
						<xsl:choose>
							<xsl:when test="string($year) = 'NaN'"/>
							<xsl:when test="$year &gt; 0">AD</xsl:when>
							<xsl:otherwise>BC</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$char = 'M'">
						<xsl:choose>
							<xsl:when test="string($month) = 'NaN'"/>
							<xsl:when test="$pattern-length &gt;= 3">
								<xsl:variable name="month-node" select="document('')/*/date:months/date:month[number($month)]"/>
								<xsl:choose>
									<xsl:when test="$pattern-length &gt;= 4">
										<xsl:value-of select="$month-node"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$month-node/@abbr"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$pattern-length = 2">
								<xsl:value-of select="format-number($month, '00')"/>
							</xsl:when>
							<xsl:when test="$pattern-length = 1">
								<xsl:value-of select="format-number($month, '0')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$month"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$char = 'E'">
						<xsl:choose>
							<xsl:when test="string($year) = 'NaN' or string($month) = 'NaN' or string($day) = 'NaN'"/>
							<xsl:otherwise>
								<xsl:variable name="month-days" select="sum(document('')/*/date:months/date:month[position() &lt; $month]/@length)"/>
								<xsl:variable name="days" select="$month-days + $day + boolean(((not($year mod 4) and $year mod 100) or not($year mod 400)) and $month &gt; 2)"/>
								<xsl:variable name="y-1" select="$year - 1"/>
								<xsl:variable name="dow" select="(($y-1 + floor($y-1 div 4) -                                              floor($y-1 div 100) + floor($y-1 div 400) +                                              $days)                                              mod 7) + 1"/>
								<xsl:variable name="day-node" select="document('')/*/date:days/date:day[number($dow)]"/>
								<xsl:choose>
									<xsl:when test="$pattern-length &gt;= 4">
										<xsl:value-of select="$day-node"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$day-node/@abbr"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$char = 'a'">
						<xsl:choose>
							<xsl:when test="string($hour) = 'NaN'"/>
							<xsl:when test="$hour &gt;= 12">PM</xsl:when>
							<xsl:otherwise>AM</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$char = 'z'">
						<xsl:choose>
							<xsl:when test="$timezone = 'Z'">UTC</xsl:when>
							<xsl:otherwise>
                    UTC<xsl:value-of select="$timezone"/></xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="padding">
							<xsl:choose>
								<xsl:when test="$pattern-length &gt; 10">
									<xsl:call-template name="str:padding">
										<xsl:with-param name="length" select="$pattern-length"/>
										<xsl:with-param name="chars" select="'0'"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring('0000000000', 1, $pattern-length)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$char = 'y'">
								<xsl:choose>
									<xsl:when test="string($year) = 'NaN'"/>
									<xsl:when test="$pattern-length &gt; 2">
										<xsl:value-of select="format-number($year, $padding)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="format-number(substring($year, string-length($year) - 1), $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'd'">
								<xsl:choose>
									<xsl:when test="string($day) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number($day, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'h'">
								<xsl:variable name="h" select="$hour mod 12"/>
								<xsl:choose>
									<xsl:when test="string($hour) = 'NaN'"/>
									<xsl:when test="$h">
										<xsl:value-of select="format-number($h, $padding)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="format-number(12, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'H'">
								<xsl:choose>
									<xsl:when test="string($hour) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number($hour, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'k'">
								<xsl:choose>
									<xsl:when test="string($hour) = 'NaN'"/>
									<xsl:when test="$hour">
										<xsl:value-of select="format-number($hour, $padding)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="format-number(24, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'K'">
								<xsl:choose>
									<xsl:when test="string($hour) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number($hour mod 12, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'm'">
								<xsl:choose>
									<xsl:when test="string($minute) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number($minute, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 's'">
								<xsl:choose>
									<xsl:when test="string($second) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number($second, $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'S'">
								<xsl:choose>
									<xsl:when test="string($second) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="format-number(substring-after($second, '.'), $padding)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$char = 'F'">
								<xsl:choose>
									<xsl:when test="string($day) = 'NaN'"/>
									<xsl:otherwise>
										<xsl:value-of select="floor($day div 7) + 1"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="string($year) = 'NaN' or string($month) = 'NaN' or string($day) = 'NaN'"/>
							<xsl:otherwise>
								<xsl:variable name="month-days" select="sum(document('')/*/date:months/date:month[position() &lt; $month]/@length)"/>
								<xsl:variable name="days" select="$month-days + $day + boolean(((not($year mod 4) and $year mod 100) or not($year mod 400)) and $month &gt; 2)"/>
								<xsl:choose>
									<xsl:when test="$char = 'D'">
										<xsl:value-of select="format-number($days, $padding)"/>
									</xsl:when>
									<xsl:when test="$char = 'w'">
										<xsl:call-template name="date:_week-in-year">
											<xsl:with-param name="days" select="$days"/>
											<xsl:with-param name="year" select="$year"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="$char = 'W'">
										<xsl:variable name="y-1" select="$year - 1"/>
										<xsl:variable name="day-of-week" select="(($y-1 + floor($y-1 div 4) -                                                   floor($y-1 div 100) + floor($y-1 div 400) +                                                   $days)                                                    mod 7) + 1"/>
										<xsl:choose>
											<xsl:when test="($day - $day-of-week) mod 7">
												<xsl:value-of select="floor(($day - $day-of-week) div 7) + 2"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="floor(($day - $day-of-week) div 7) + 1"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="date:_format-date">
					<xsl:with-param name="year" select="$year"/>
					<xsl:with-param name="month" select="$month"/>
					<xsl:with-param name="day" select="$day"/>
					<xsl:with-param name="hour" select="$hour"/>
					<xsl:with-param name="minute" select="$minute"/>
					<xsl:with-param name="second" select="$second"/>
					<xsl:with-param name="timezone" select="$timezone"/>
					<xsl:with-param name="pattern" select="substring($pattern, $pattern-length + 1)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="date:_week-in-year">
		<xsl:param name="days"/>
		<xsl:param name="year"/>
		<xsl:variable name="y-1" select="$year - 1"/>
		<xsl:variable name="day-of-week" select="($y-1 + floor($y-1 div 4) -                           floor($y-1 div 100) + floor($y-1 div 400) +                           $days)                           mod 7"/>
		<xsl:variable name="dow">
			<xsl:choose>
				<xsl:when test="$day-of-week">
					<xsl:value-of select="$day-of-week"/>
				</xsl:when>
				<xsl:otherwise>7</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="start-day" select="($days - $dow + 7) mod 7"/>
		<xsl:variable name="week-number" select="floor(($days - $dow + 7) div 7)"/>
		<xsl:choose>
			<xsl:when test="$start-day &gt;= 4">
				<xsl:value-of select="$week-number + 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="not($week-number)">
						<xsl:call-template name="date:_week-in-year">
							<xsl:with-param name="days" select="365 + ((not($y-1 mod 4) and $y-1 mod 100) or not($y-1 mod 400))"/>
							<xsl:with-param name="year" select="$y-1"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$week-number"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
<!-- ========================= END OF STYLESHEET ========================= -->
</xsl:stylesheet>
