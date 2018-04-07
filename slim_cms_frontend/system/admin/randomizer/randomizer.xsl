<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:exsl="http://exslt.org/common"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-extension-prefixes="exsl">

	<xsl:template match="config">
		<xsl:variable name="al" select="'abcdefghijklmnopqrstuvwxyz'" />
		<xsl:variable name="au" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
		<xsl:variable name="q" select="translate(/config/globals/item[@key = 'q']/@value,$au,$al)" />
		<xsl:variable name="in" select="/config/globals/item[@key = 'in']/@value" />
	
		<h1>Randomizer</h1>
		<p>Creates random clients, client_checklists and other items for testing</p>
		<xsl:call-template name="progress-bars" />
		<xsl:call-template name="form" />
		
	</xsl:template>
	
	<xsl:template name="progress-bars">
		<xsl:if test="/config/globals/item[@key = 'action']/@value = 'generate'">
			<div id="clientProgressBar"></div>
		</xsl:if>
	</xsl:template>
	
	<!-- //Get the dashboard content -->
	
	<xsl:template name="form">
		<form name="randomizer" method="post" action="">
			<input type="hidden" value="generate" name="action" />
			
			<!-- //Call the client Generator -->
			<xsl:call-template name="clientGenerator" />
			
			<!-- //Call the checklist generator -->
			<xsl:call-template name="clientChecklistGenerator" />
			
			<br /><br />
			<input type="submit" value="submit" />
		</form>
	</xsl:template>
	
	<xsl:template name="clientGenerator">
		<h1>Client Generator</h1>
		
		<!-- //Hiden Values -->
		<input type="hidden" name="source" value="randomizer" />
		
		<table class="editTable">
			<tr>
				<th scope="col">Number to generate</th>
				<td>
					<input type="number" name="client_number" min="1" step="1" />
				</td>
			</tr>
			<tr>
				<th scope="col">Client Type</th>
				<td>
					<select name="client_type">
						<option value="0">Random</option>
						<xsl:for-each select="/config/client_type">
							<option value="{@client_type_id}">
								<xsl:value-of select="@client_type" />
							</option>
						</xsl:for-each>
					</select>
				</td>
			</tr>
			<tr>
				<th scope="col">Industry</th>
				<td>
					<select name="industry">
						<option value="0">Random</option>
						<xsl:for-each select="/config/anzsic_insdustry">
							<option value="{@anzsic_id}">
								<xsl:value-of select="@description" />
							</option>
						</xsl:for-each>
					</select>
				</td>
			</tr>
			<tr>
				<th scope="col">Country</th>
				<td>
					<select name="country">
						<option value="Australia">Australia</option>
						<option value="United States">USA</option>
						<option value="0">Worldwide</option>
					</select>
				</td>
			</tr>
		</table>
	</xsl:template>
	
	<xsl:template name="clientChecklistGenerator">
		<h1>Client Checklist Generator</h1>
		
		<table class="editTable">
			<tr>
				<th scope="col">Number to generate</th>
				<td>
					<input type="number" name="checklist_number" min="0" step="1" />
				</td>
			</tr>
			<tr>
				<th scope="col">Checklist Type</th>
				<td>
					<select name="checklist_id">
						<xsl:for-each select="/config/checklist">
							<option value="{@checklist_id}">
								<xsl:value-of select="@name" />
							</option>
						</xsl:for-each>
					</select>
				</td>
			</tr>
			<tr>
				<th scope="col">Auto Complete</th>
				<td>
					<select name="auto_complete_checklist">
						<option value="yes">Yes</option>
						<option value="no">No</option>
					</select>
				</td>
			</tr>
			<tr>
				<th scope="col">Seed Year</th>
				<td>
					<select name="seed-year">
						<xsl:for-each select="/config/year">
							<option value="{@year}">
								<xsl:value-of select="@year" />
							</option>
						</xsl:for-each>
					</select>
				</td>
			</tr>
			<tr>
				<th scope="col">Skew Results</th>
				<td>
					<select name="skew">
						<option value="center">Center (Default. Results not skewed.)</option>
						<option value="left">Left (weighted left to right)</option>
						<option value="right">Right (weighted right to left)</option>
					</select>
				</td>
			</tr>
			<tr>
				<th scope="col">Skew Multiplier</th>
				<td>
					<input type="number" name="skew_multiplier" min="1" step="1" />
				</td>
			</tr>
		</table>

		<p>
			<strong>Notes:</strong>
		</p>
		<p>
			<ul>
				<li>To generate checklists (entries) with the new account, enter a number of '1' or higher.</li>
				<li>Skew results either from the left, right or center (default). Answers are skewed by their sequence from left to right.</li>
			</ul>
		</p>
	</xsl:template>
	
</xsl:stylesheet>