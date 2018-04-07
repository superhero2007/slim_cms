<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config[@mode = 'client_note_edit']">
		<xsl:variable name="client" select="client[@client_id = current()/globals/item[@key = 'client_id']/@value]" />
		<xsl:variable name="client_note" select="client_note[@client_note_id = current()/globals/item[@key = 'client_note_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=clients">Client List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_edit&amp;client_id={$client/@client_id}"><xsl:value-of select="$client/@company_name" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_note_edit&amp;client_id={$client/@client_id}&amp;client_note_id={$client_note/@client_note_id}">Add / Edit Note</a>
		</p>
		<h1>Add / Edit Note</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="client_note_save" />
			<input type="hidden" name="client_note_id" value="{$client_note/@client_note_id}" />
			<input type="hidden" name="client_id" value="{$client/@client_id}" />
			<input type="hidden" name="timestamp" value="{$client_note/@timestamp}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Note" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="note">Note:</label></th>
						<td><textarea id="note" name="note" rows="8" cols="45"><xsl:value-of select="$client_note/@note" /></textarea></td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
</xsl:stylesheet>