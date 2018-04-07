<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:str="http://exslt.org/strings"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config">
		<h1>Followup Trigger List</h1>
		<p>The triggers are run every 10 minutes via a cron job. You can run the followup process manually using this <a href="?page=triggers&amp;action=manual_process">link</a>.</p>
		<table>
			<thead>
				<tr>
					<th scope="col">Name</th>
					<th scope="col">Active From</th>
					<th scope="col">Action</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="3"><input type="button" value="Add Trigger" onclick="document.location = '?page=triggers&amp;mode=followup_trigger_edit';" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="followup_trigger">
					<tr>
						<td>
							<xsl:value-of select="@name" />
							<br />
							<span class="options">
								<a href="?page=triggers&amp;mode=followup_trigger_edit&amp;followup_trigger_id={@followup_trigger_id}">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=triggers&amp;action=followup_trigger_delete&amp;followup_trigger_id={@followup_trigger_id}" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td><xsl:value-of select="@active" /></td>
						<td><xsl:value-of select="@action" /></td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="config[@mode = 'followup_trigger_edit']">
		<xsl:variable name="followup_trigger" select="followup_trigger[@followup_trigger_id = current()/globals/item[@key = 'followup_trigger_id']/@value]" />
		<h1>Add / Edit Followup Trigger</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="followup_trigger_save" />
			<input type="hidden" name="followup_trigger_id" value="{$followup_trigger/@followup_trigger_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Trigger" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row">Trigger ID:</th>
						<td><xsl:value-of select="$followup_trigger/@followup_trigger_id" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="name">Name:</label></th>
						<td><input type="text" id="name" name="name" value="{$followup_trigger/@name}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="active">Active From:</label></th>
						<td><input type="text" id="active" name="active" value="{$followup_trigger/@active}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="trigger-action">Action:</label></th>
						<td>
							<select id="trigger-action" name="trigger_action">
								<xsl:for-each select="str:tokenize('email,call,head office,head office + associate,delete,issue assessment + email client,function',',')">
									<option value="{.}">
										<xsl:if test=". = $followup_trigger/@action"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="." />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="function_arguments">Function Arguments:</label></th>
						<td><input type="text" id="function_arguments" name="function_arguments" value="{$followup_trigger/@function_arguments}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="sql">SQL:</label></th>
						<td><textarea id="sql" name="sql" rows="30" cols="45"><xsl:value-of select="$followup_trigger/@sql" /></textarea></td>
					</tr>
					<tr>
						<th scope="row"><label for="email-stationary">Email Stationary:</label></th>
						<td><input type="text" id="email-stationary" name="email_stationary" value="{$followup_trigger/@email_stationary}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="email-subject">Email Subject:</label></th>
						<td><input type="text" id="email-subject" name="email_subject" value="{$followup_trigger/@email_subject}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
		<h1>Trigger SQL Result</h1>
		<p><xsl:value-of select="trigger_error" /></p>
		<table>
			<thead>
				<tr>
					<xsl:for-each select="trigger_result[1]/@*">
						<th scope="col"><xsl:value-of select="name(.)" /></th>
					</xsl:for-each>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="trigger_result">
					<tr>
						<xsl:for-each select="./@*">
							<td><xsl:value-of select="." /></td>
						</xsl:for-each>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

</xsl:stylesheet>