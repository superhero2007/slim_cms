<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:php="http://php.net/xsl"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">

	<xsl:template match="config[@mode = 'email_compose']">
		<xsl:variable name="stationery_filename" select="/config/globals/item[@key='stationery_template']/@value"/>
		<xsl:variable name="client" select="client[@client_id = current()/globals/item[@key = 'client_id']/@value]"/>
		<xsl:variable name="clientContact" select="client_contact[@client_contact_id = current()/globals/item[@key='client_contact_id']/@value]"/>
		<xsl:variable name="clientContactName" select="concat($clientContact/@salutation, ' ', $clientContact/@firstname, ' ', $clientContact/@lastname)"/>
		<xsl:variable name="user" select="user/@value" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=clients">Account List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_edit&amp;client_id={$client/@client_id}">
					<xsl:value-of select="$client/@company_name" />
			</a>
			<xsl:text> &gt; </xsl:text>
			Compose Email <xsl:if test="$clientContact">(<xsl:value-of select="$clientContactName"/>)</xsl:if>
		</p>
		<h1>Compose Email <xsl:if test="$clientContact">(<xsl:value-of select="$clientContactName"/>)</xsl:if></h1>
		<form id="email-message" action="?page=clients&amp;mode=email_compose" method="POST">
			<table class="editTable">
				<tbody>
					<tr>
						<th scope="row">Subject:</th>
						<td>
						<xsl:choose>
							<xsl:when test="stationery_template[@filename=$stationery_filename]/@subject != ''">
								<input type="text" name="email_subject" value="{stationery_template[@filename=$stationery_filename]/@subject}" />
							</xsl:when>
							<xsl:otherwise>
								<input type="text" name="email_subject" value="{stationery_template[@filename=$stationery_filename]/@name}" />
							</xsl:otherwise>
						</xsl:choose>
						</td>
					</tr>
					<tr>
						<th scope="row">CC:</th>
						<td><input type="text" name="email_cc" value="" /></td>
					</tr>
				</tbody>
			</table>
			<div>
				<input type="hidden" name="action" value="email_send" />
				<input type="hidden" name="client_id" value="{$client/@client_id}" />
				<xsl:if test="$clientContact">
					<input type="hidden" name="client_contact_id" value="{$clientContact/@client_contact_id}"/>
				</xsl:if>
				<input type="hidden" name="stationery_template" value="{$stationery_filename}" />
				<textarea id="email-body" name="email_body" rows="20" cols="40">
					<xsl:value-of select="stationery_body/text()"/>
				</textarea>
				<script type="text/javascript">
				<xsl:comment><![CDATA[
			
					function sendEmail() {
						$("#email-message").submit();
					}
			
					CKEDITOR.plugins.add('sendemail', {
						init: function (editor) {
							editor.addCommand('send_email', {
								exec: function (editor) {
									sendEmail();
								}
							});
							editor.ui.addButton('SendEmail', {
								label: 'Send Email',
								command: 'send_email',
								icon: '/_images/email_go.png'
							});
						}
					});
			
					var editorConfig = {
						toolbar: [
						    ['SendEmail'], ['Source'],
						    ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Print', 'SpellChecker', 'Scayt'],
						    ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
						    ['Link','Unlink','Anchor'],
						    ['Image','Table','HorizontalRule','SpecialChar'],
						    '/',
						    ['Format','Font','FontSize','Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
						    ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
						    ['JustifyLeft','JustifyCenter','JustifyRight'],
						    ['TextColor','BGColor'],
						    ['Maximize', 'ShowBlocks']
						],
						height: '25em',
						extraPlugins: 'sendemail'
					};

					// This call can be placed at any point after the
					// <textarea>, or inside a <head><script> in a
					// window.onload event handler.

					// Replace the <textarea id="editor"> with an CKEditor
					// instance, using default configurations.
					var emailEditor = CKEDITOR.replace('email-body', editorConfig);
			
			

				]]></xsl:comment>
				</script>
			</div>
		</form>
	</xsl:template>
	
</xsl:stylesheet>