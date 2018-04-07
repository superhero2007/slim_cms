<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template name="invoice-navigation">
		<p>
			<a href="index.php?page=invoices&amp;mode=outstanding-invoices">Outstanding Invoices</a>
			<xsl:text> | </xsl:text>
			<a href="index.php?page=invoices&amp;mode=all-invoices">All Invoices</a>
		</p>
	</xsl:template>

	<xsl:template match="config[@mode = 'outstanding-invoices']">
		<h1>Outstanding Accounts</h1>
		<xsl:call-template name="invoice-navigation" />
		
		<table id="generic-list-table" class="admin-datatable stripe">
			<col style="width: 10%;" />
			<col style="width: 20%;"  />
			<col style="width: 10%;" />
			<col style="width: 10%;" />
			<col style="width: 10%;" />
			<col style="width: 10%;" />
			<col style="width: 10%;" />
			<col style="width: 20%;" />
			<thead>
				<tr>
					<th scope="col">Invoice</th>
					<th scope="col">Client</th>
					<th scope="col">Invoice Date</th>
					<th scope="col">Due Date</th>
					<th scope="col">Client Balance</th>
					<th scope="col">Invoice Amount</th>
					<th scope="col">Days Overdue</th>
					<th scope="col">Account Owner</th>
				</tr>
			</thead>
			<thead>
				<tr class="data-filter">
					<th scope="col">Invoice</th>
					<th scope="col">Client</th>
					<th scope="col">Invoice Date</th>
					<th scope="col">Due Date</th>
					<th scope="col">Client Balance</th>
					<th scope="col">Invoice Amount</th>
					<th scope="col">Days Overdue</th>
					<th scope="col">Account Owner</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="/config/overdueInvoice">
					<xsl:sort select="@due_date" order="descending" />
					<xsl:variable name="client_balance" select="@client_debits - @client_credits" />
						<tr>
							<td>
								<xsl:value-of select="concat(format-number(@client_id,'0000'),'-',format-number(@invoice_id,'0000'))" />
								<br />
								<span class="options">
									<a href="?page=clients&amp;mode=invoice_edit&amp;client_id={@client_id}&amp;invoice_id={@invoice_id}">edit</a>
									<xsl:text> | </xsl:text>
									<a href="?page=clients&amp;mode=client_edit&amp;action=invoice_delete&amp;client_id={@client_id}&amp;invoice_id={@invoice_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
								</span>
							</td>
							<td><a href="index.php?page=clients&amp;mode=client_edit&amp;client_id={@client_id}"><xsl:value-of select="@company_name" /></a></td>
							<td><xsl:value-of select="@invoice_date" /></td>
							<td><xsl:value-of select="@due_date" /></td>
							<td>
								<xsl:value-of select="format-number($client_balance,'#,##0.00')" />
								<xsl:text> </xsl:text>
								<xsl:value-of select="../currency[@currency_id = current()/@currency_id]/@code" />
							</td>
							<td>
								<xsl:value-of select="format-number(@invoice_amount,'#,##0.00')" />
								<xsl:text> </xsl:text>
								<xsl:value-of select="../currency[@currency_id = current()/@currency_id]/@code" />
							</td>
							<td><xsl:value-of select="@days_passed" /></td>
							<td><a href="index.php?page=clients&amp;mode=client_edit&amp;client_id={@account_owner_id}"><xsl:value-of select="@account_owner" /></a></td>
						</tr>
				</xsl:for-each>
			</tbody>
		</table>
		</xsl:template>
		
		<xsl:template match="config[@mode = 'all-invoices']">
		<h1>All Invoices</h1>
		<xsl:call-template name="invoice-navigation" />	
		
		<table id="generic-list-table" class="admin-datatable stripe">
			<col style="width: 10%;" />
			<col style="width: 20%;"  />
			<col style="width: 10%;" />
			<col style="width: 10%;" />
			<col style="width: 10%;" />
			<col style="width: 10%;" />
			<col style="width: 10%;" />
			<col style="width: 20%;" />
			<thead>
				<tr>
					<th scope="col">Invoice</th>
					<th scope="col">Client</th>
					<th scope="col">Invoice Date</th>
					<th scope="col">Due Date</th>
					<th scope="col">Client Balance</th>
					<th scope="col">Invoice Amount</th>
					<th scope="col">Days Overdue</th>
					<th scope="col">Account Owner</th>
				</tr>
			</thead>
			<thead>
				<tr class="data-filter">
					<th scope="col">Invoice</th>
					<th scope="col">Client</th>
					<th scope="col">Invoice Date</th>
					<th scope="col">Due Date</th>
					<th scope="col">Client Balance</th>
					<th scope="col">Invoice Amount</th>
					<th scope="col">Days Overdue</th>
					<th scope="col">Account Owner</th>
				</tr>
			</thead>
			<tbody>
				<xsl:choose>
					<xsl:when test="/config/globals/item[@key = 'q']">
						<xsl:for-each select="/config/invoice">
							<xsl:sort select="@due_date" order="descending" />
							<xsl:variable name="invoiceNumber" select="concat(format-number(@client_id,'0000'),'-',format-number(@invoice_id,'0000'))" />
							<xsl:variable name="query" select="/config/globals/item[@key = 'q']/@value" />
							<xsl:if test="contains($invoiceNumber,$query)">
								<xsl:variable name="client_balance" select="@client_debits - @client_credits" />
								<!--<xsl:if test="$client_balance = 0">-->
									<tr>
										<td>
											<xsl:value-of select="$invoiceNumber" />
											<br />
											<span class="options">
												<a href="?page=clients&amp;mode=invoice_edit&amp;client_id={@client_id}&amp;invoice_id={@invoice_id}">edit</a>
												<xsl:text> | </xsl:text>
												<a href="?page=clients&amp;mode=client_edit&amp;action=invoice_delete&amp;client_id={@client_id}&amp;invoice_id={@invoice_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
											</span>
										</td>
										<td><a href="index.php?page=clients&amp;mode=client_edit&amp;client_id={@client_id}"><xsl:value-of select="@company_name" /></a></td>
										<td><xsl:value-of select="@invoice_date" /></td>
										<td><xsl:value-of select="@due_date" /></td>
										<td>
											<xsl:value-of select="format-number($client_balance,'#,##0.00')" />
											<xsl:text> </xsl:text>
											<xsl:value-of select="../currency[@currency_id = current()/@currency_id]/@code" />
										</td>
										<td>
											<xsl:value-of select="format-number(@invoice_amount,'#,##0.00')" />
											<xsl:text> </xsl:text>
											<xsl:value-of select="../currency[@currency_id = current()/@currency_id]/@code" />
										</td>
										<td><xsl:value-of select="@days_passed" /></td>
										<td><a href="index.php?page=clients&amp;mode=client_edit&amp;client_id={@account_owner_id}"><xsl:value-of select="@account_owner" /></a></td>
									</tr>
								<!--</xsl:if>-->
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="/config/invoice">
							<xsl:sort select="@due_date" order="descending" />
							<xsl:variable name="client_balance" select="@client_debits - @client_credits" />
							<!--<xsl:if test="$client_balance = 0">-->
								<tr>
									<td>
										<xsl:value-of select="concat(format-number(@client_id,'0000'),'-',format-number(@invoice_id,'0000'))" />
										<br />
										<span class="options">
											<a href="?page=clients&amp;mode=invoice_edit&amp;client_id={@client_id}&amp;invoice_id={@invoice_id}">edit</a>
											<xsl:text> | </xsl:text>
											<a href="?page=clients&amp;mode=client_edit&amp;action=invoice_delete&amp;client_id={@client_id}&amp;invoice_id={@invoice_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
										</span>
									</td>
									<td><a href="index.php?page=clients&amp;mode=client_edit&amp;client_id={@client_id}"><xsl:value-of select="@company_name" /></a></td>
									<td><xsl:value-of select="@invoice_date" /></td>
									<td><xsl:value-of select="@due_date" /></td>
									<td>
										<xsl:value-of select="format-number($client_balance,'#,##0.00')" />
										<xsl:text> </xsl:text>
										<xsl:value-of select="../currency[@currency_id = current()/@currency_id]/@code" />
									</td>
									<td>
										<xsl:value-of select="format-number(@invoice_amount,'#,##0.00')" />
										<xsl:text> </xsl:text>
										<xsl:value-of select="../currency[@currency_id = current()/@currency_id]/@code" />
									</td>
									<td><xsl:value-of select="@days_passed" /></td>
									<td><a href="index.php?page=clients&amp;mode=client_edit&amp;client_id={@account_owner_id}"><xsl:value-of select="@account_owner" /></a></td>
								</tr>
							<!--</xsl:if> -->
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</tbody>
		</table>
		
		</xsl:template>
		
	
	<xsl:template match="config[@mode = 'edit']">
		<xsl:variable name="invoice" select="invoice[@invoice_id = current()/globals/item[@key = 'invoice_id']/@value]" />
		<h1>Add / Edit Invoice</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="save_invoice" />
			<input type="hidden" name="invoice_id" value="{$invoice/@invoice_id}" />
			<fieldset>
				<legend>Details</legend>
				<table class="editTable">
					<tbody>
						<tr>
							<th scope="row"><label for="client-id">Client:</label></th>
							<td>
								<select id="client-id" name="client_id">
									<xsl:for-each select="company">
										<option value="{@client_id}">
											<xsl:if test="@client_id = $invoice/@client_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
											<xsl:value-of select="@company_name" />
										</option>
									</xsl:for-each>
								</select>
							</td>
						</tr>
						<tr>
							<th scope="row"><label for="invoice-date">Invoice Date:</label></th>
							<td><input type="text" id="invoice-date" name="invoice_date" value="{$invoice/@invoice_date}" /></td>
						</tr>
						<tr>
							<th scope="row"><label for="due-date">Due Date:</label></th>
							<td><input type="text" id="due-date" name="due_date" value="{$invoice/@due_date}" /></td>
						</tr>
						<tr>
							<th scope="row"><label for="paid-in-full-date">Paid in Full Date:</label></th>
							<td><input type="text" id="paid-in-full-date" name="paid_in_full_date" value="{$invoice/@paid_in_full_date}" /></td>
						</tr>
					</tbody>
				</table>
				<script type="text/javascript">
				$('#invoice-date').datepicker({ dateFormat: 'yy-mm-dd' });
				$('#due-date').datepicker({ dateFormat: 'yy-mm-dd' });
				$('#paid-in-full-date').datepicker({ dateFormat: 'yy-mm-dd' });
				</script>
			</fieldset>
			<fieldset>
				<legend>Items</legend>
				<table class="editTable">
					<col style="width: 70%;" />
					<col style="width: 10%;" /> 
					<col style="width: 10%;" />
					<col style="width: 10%;" />
					<thead>
						<tr>
							<th scope="col">Description</th>
							<th scope="col">Quantity</th>
							<th scope="col">Price / Item</th>
							<th scope="col">GST / Item</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="$invoice/item">
							<tr>
								<th scope="row"><input type="text" name="item[{(position()-1)}][item]" style="width: 99%;" value="{@item}" /></th>
								<td><input type="text" name="item[{(position()-1)}][quantity]" style="width: 80%; text-align: right" value="{@quantity}" /></td>
								<td>$<input type="text" name="item[{(position()-1)}][amount]" style="width: 80%; text-align: right;" value="{@amount}" /></td>
								<td>$<input type="text" name="item[{(position()-1)}][gst]" style="width: 80%; text-align: right;" value="{@gst}" /></td>
							</tr>
						</xsl:for-each>
						<tr>
							<th scope="row"><input type="text" name="item[{count($invoice/item)}][item]" style="width: 99%;" /></th>
							<td><input type="text" name="item[{count($invoice/item)}][quantity]" style="width: 80%; text-align: right" /></td>
							<td>$<input type="text" name="item[{count($invoice/item)}][amount]" style="width: 80%; text-align: right;" /></td>
							<td>$<input type="text" name="item[{count($invoice/item)}][gst]" style="width: 80%; text-align: right;" /></td>
						</tr>
					</tbody>
				</table>
			</fieldset>
			<fieldset>
				<legend>Transactions</legend>
				<table class="editTable">
					<col style="width: 60%;" />
					<col style="width: 20%;" />
					<col style="width: 20%;" />
					<thead>
						<tr>
							<th scope="row">Date / Time</th>
							<th scope="row">Method</th>
							<th scope="row">Amount</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="$invoice/transaction">
							<tr>
								<th scope="row">
									<input type="text" id="transaction-date-{(position()-1)}" name="transaction[{(position()-1)}][date]" value="{@date}" />
									<script type="text/javascript">
										$('#transaction-date-<xsl:value-of select="(position()-1)" />').datepicker({ dateFormat: 'yy-mm-dd' });
									</script>
								</th>
								<td>
									<select name="transaction[{(position()-1)}][method]">
										<xsl:variable name="method" select="@method" />
										<xsl:for-each select="/config/method">
											<option value="{.}">
												<xsl:if test="$method = ."><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
												<xsl:value-of select="." />
											</option>
										</xsl:for-each>
									</select>
								</td>
								<td>$<input type="text" name="transaction[{(position()-1)}][amount]" value="{@amount}" style="width: 80%; text-align: right;" /></td>
							</tr>
						</xsl:for-each>
						<tr>
							<th scope="row">
								<input type="text" id="transaction-date-{count($invoice/transaction)}" name="transaction[{count($invoice/transaction)}][date]" />
								<script type="text/javascript">
									$('#transaction-date-<xsl:value-of select="count($invoice/transaction)" />').datepicker({ dateFormat: 'yy-mm-dd' });
								</script>
							</th>
							<td>
								<select name="transaction[{count($invoice/transaction)}][method]">
									<xsl:for-each select="/config/method">
										<option value="{.}">
											<xsl:value-of select="." />
										</option>
									</xsl:for-each>
								</select>
							</td>
							<td>$<input type="text" name="transaction[{count($invoice/transaction)}][amount]" style="width: 80%; text-align: right;" /></td>
						</tr>
					</tbody>
				</table>
			</fieldset>
			<p style="text-align: center;"><input type="submit" value="Save Invoice" /></p>
		</form>
	</xsl:template>
	
</xsl:stylesheet>