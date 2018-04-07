<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:exsl="http://exslt.org/common"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-extension-prefixes="exsl">

	<xsl:template name="menu">
		<h1>Scripts</h1>
	</xsl:template>
	
	<xsl:template match="config">
        
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=scripts">Scripts</a>
		</p>

        <xsl:call-template name="script-links" />
		
	</xsl:template>

    <xsl:template name="script-links">
    
        <!-- // List all links to scripts -->
        <h1>Available Admin Scripts</h1>

        <ul>
            <li>
                <a href="?page=scripts&amp;action=encryptAllAdminPasswords">Encrypt All Admin Passwords</a>
            </li>
            <li>
                <a href="?page=scripts&amp;action=encryptAllClientPasswords">Encrypt All Client Passwords</a>
            </li>
            <li>
                <a href="?page=scripts&amp;action=batchUpdateClientCoordinates">Batch Update Client Coordinates</a>
            </li>
            <li>
                <a href="?page=scripts&amp;action=updateChecklistScores&amp;client_checklist_id=0">Update Client Checklist Scores</a>
            </li>
            <li>
                <a href="?page=scripts&amp;action=updateGdacs">Update GDACS Alerts</a>
            </li>
            <li>
                <a href="?page=scripts&amp;action=generateRandomAPIKey">Generate Random API Key</a>
            </li>
            <li>
                <a href="?page=scripts&amp;action=phpInfo">PHP Info</a>
            </li>
            <li>
                <a href="?page=scripts&amp;action=serverVars">Server Variables</a>
            </li>
            <li>
                <a href="?page=scripts&amp;action=processGHGTriggers">Process GHG Triggers</a>
            </li>
        </ul>

    </xsl:template>

</xsl:stylesheet>