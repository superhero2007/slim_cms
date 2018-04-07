<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config[@mode = 'content_edit']">
		<xsl:variable name="navigation" select="navigation[@navigation_id = current()/globals/item[@key = 'navigation_id']/@value]" />
		<xsl:variable name="content" select="content[@content_id = current()/globals/item[@key = 'content_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=navigation&amp;domain_id={$domain_id}">Navigation List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=navigation&amp;mode=navigation_edit&amp;domain_id={$domain_id}&amp;navigation_id={$navigation/@navigation_id}"><xsl:value-of select="$navigation/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=navigation&amp;mode=content_edit&amp;domain_id={$domain_id}&amp;navigation_id={$navigation/@navigation_id}&amp;content_id={$content/@content_id}">
				<xsl:choose>
					<xsl:when test="$content">Edit Content</xsl:when>
					<xsl:otherwise>Add Content</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Content</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="content_save" />
			<input type="hidden" name="domain_id" value="{$domain_id}" />
			<input type="hidden" name="content_id" value="{$content/@content_id}" />
			<input type="hidden" name="navigation_id" value="{$navigation/@navigation_id}" />
			<input type="hidden" name="sequence" value="{$content/@sequence}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Content" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="col">Edit Mode:</th>
						<td>
							<label><input type="radio" name="editmode" value="xhtml" checked="checked" onchange="toggleEditMode(this.form);" />XHTML</label>
							<label><input type="radio" name="editmode" value="wysiwyg" onchange="toggleEditMode(this.form);" />WYSIWYG</label>
						</td>
					</tr>
					<tr id="xhtml_mode">
						<th scope="col"><label for="content">Content<br />(XHTML)</label></th>
						<td><textarea id="content" name="content" rows="30" cols="45"><xsl:value-of select="$content/@content" /></textarea></td>
											
					<!-- //Insert the CKEditor 
					<script type="text/javascript">
					<xsl:comment><![CDATA[
						CKEDITOR.replace( 'content',
						{
							contentsCss : 'assets/output_xhtml.css'
						});

					]]></xsl:comment>
					</script>
					 //End of CKEditor -->

					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>

</xsl:stylesheet>