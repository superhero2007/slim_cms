<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="/config[@mode = 'invoice_list']">
		<h1>Outstanding Accounts</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">Company Name</th>
					<th scope="col">Amount Due</th>
					<th scope="col">Due Date</th>
					<th scope="col">Days Overdue</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="client">
					<xsl:variable name="client" select="." />
					<xsl:for-each select="../currency">
						<xsl:variable name="invoices" select="../invoice[@client_id = $client/@client_id][@currency_id = current()/@currency_id]" />
						<xsl:variable name="total" select="sum(../product_2_invoice[@invoice_id = $invoices/@invoice_id]/@total)" />
						<xsl:variable name="transactions" select="sum(../transaction[@client_id = $client/@client_id][@currency_id = current()/@currency_id]/@amount)" />
						<xsl:variable name="balance" select="$total - $transactions" />
						<xsl:if test="$balance &gt; 0 and number($invoices[last()]/@days_passed) &gt; 0">
							<tr>
								<td>
									<xsl:value-of select="$client/@company_name" />
									<br />
									<span class="options">
										<a href="?page=clients&amp;mode=client_edit&amp;client_id={$client/@client_id}">edit</a>
									</span>
								</td>
								<td><xsl:value-of select="concat(format-number($balance,'#,##0.00'),' ',@code)" /></td>
								<td><xsl:value-of select="$invoices[last()]/@due_date" /></td>
								<td><xsl:value-of select="$invoices[last()]/@days_passed" /></td>
							</tr>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</tbody>
		</table>
		<h1>Invoice List</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">Invoice No.</th>
					<th scope="col">Client</th>
					<th scope="col">Invoice Amount</th>
					<th scope="col">Client Balance</th>
					<th scope="col">Invoice Due</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="invoice[@client_id = ../client/@client_id]">
					<xsl:sort select="@due_date" order="descending" />
					<xsl:variable name="transactions" select="sum(../transaction[@client_id = current()/@client_id][@currency_id = current()/@currency_id]/@amount)" />
					<xsl:variable name="client_total" select="sum(../product_2_invoice[@invoice_id = ../invoice[@client_id = current()/@client_id][@currency_id = current()/@currency_id]/@invoice_id]/@total)" />
					<xsl:variable name="invoice_total" select="sum(../product_2_invoice[@invoice_id = current()/@invoice_id]/@total)" />
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
						<td>
							<xsl:value-of select="../client[@client_id = current()/@client_id]/@company_name" />
							<br />
							<span class="options">
								<a href="?page=clients&amp;mode=client_edit&amp;client_id={@client_id}">edit</a>
							</span>
						</td>
						<td>
							<xsl:value-of select="format-number($invoice_total,'#,##0.00')" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="../currency[@currency_id = current()/@currency_id]/@code" />
						</td>
						<td>
							<xsl:value-of select="format-number($client_total - $transactions,'#,##0.00')" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="../currency[@currency_id = current()/@currency_id]/@code" />
						</td>
						<td><xsl:value-of select="@due_date" /></td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

</xsl:stylesheet>