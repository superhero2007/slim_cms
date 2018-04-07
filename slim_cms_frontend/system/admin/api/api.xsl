<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:exsl="http://exslt.org/common"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-extension-prefixes="exsl">

	<xsl:template name="menu">
		<h1>API</h1>
	</xsl:template>
	
	<xsl:template match="config">
        
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=api">API</a>
		</p>

		<xsl:call-template name="api-import" />
	
	</xsl:template>

	<xsl:template name="api-import">
		<h2>Import data via the API</h2>

		<form name="api-import-form" class="api-import-form" method="post" action="#">
			<label>Private Key: </label><input type="text" name="prv_key" class="prv_key" value="{/config/api/@prv}" style="width:100%"/><label>Public Key: </label><input type="text" name="pub_key" class="pub_key" value="{/config/api/@pub}" style="width:100%;" /><br /><br />
			<input type="file" class="file-upload-input" data-results="api-import-results" />
			<input type="submit" value="import" />
		</form>

		<div class="api-import-results" />
	</xsl:template>

</xsl:stylesheet>