<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:exsl="http://exslt.org/common"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-extension-prefixes="exsl">

	<xsl:template name="menu">
		<h1>Audit List</h1>
	</xsl:template>
	
	<xsl:template name="contactName">
		<xsl:param name="checklist"/>
		
		<xsl:value-of select="$checklist/@client_contact_salutation"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$checklist/@client_contact_firstname"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$checklist/@client_contact_lastname"/>
	</xsl:template>

	<xsl:template match="config">
		<xsl:variable name="al" select="'abcdefghijklmnopqrstuvwxyz'" />
		<xsl:variable name="au" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
		<xsl:variable name="q" select="translate(/config/globals/item[@key = 'q']/@value,$au,$al)" />
		<xsl:variable name="in" select="/config/globals/item[@key = 'in']/@value" />
		<xsl:variable name="account_type" select="/config/globals/item[@key = 'account_type']/@value" />
	
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=audit">Audit List</a>
		</p>
		<form method="get" action="">
			<input type="hidden" name="action" value="search" />
			<input type="hidden" name="page" value="audit" />
			<fieldset>
				<legend>Search Audit List</legend>
				<p>
					<label>
						<xsl:text>Search: </xsl:text>
						<input type="text" name="q" value="{$q}" />
					</label>
					<label>
						<xsl:text> in: </xsl:text>
						<select name="in">
							<xsl:variable name="options">
								<option value="company_name" desc="Company Name" />
							</xsl:variable>
							<xsl:for-each select="exsl:node-set($options)/option">
								<option value="{@value}">
									<xsl:if test="$in = @value"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
									<xsl:value-of select="@desc" />
								</option>
							</xsl:for-each>
						</select>
					</label>
					<input type="submit" value="Search" />
				</p>
			</fieldset>
		</form>
		<h1>Account List</h1>
		
		<table id="accountlist">
			<thead>
				<tr>
					<th scope="col">Company Name</th>
					<th scope="col">Checklist</th>
					<th scope="col">Audit Score</th>
					<th scope="col">Audit Level</th>
					<th scope="col">Audited</th>
					<th scope="col">Certified</th>
					<th scope="col">Audit Start Date</th>
					<th scope="col">Audit Complete Date</th>
					<th scope="col">Audit Status</th>
                    <th scope="col">Audit Cost</th>
				</tr>
			</thead>
			<tbody>
				<xsl:choose>
					<xsl:when test="$q and $in = 'company_name'">
						<xsl:apply-templates select="audit[contains(translate(@company_name,$au,$al),$q)]" mode="row" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="audit" mode="row" />
					</xsl:otherwise>
				</xsl:choose>
			</tbody>
		</table>
<script type="text/javascript">
$("#accountlist").tablesorter({
	cancelSelection: true
});
</script>
	</xsl:template>
	
	<xsl:template match="audit" mode="row">
    	<xsl:param name="showProspect">no</xsl:param>
    	
		<xsl:variable name="client_id" select="@client_id" />
		
		<xsl:variable name="showRow">
			<xsl:choose>
				<xsl:when test="/config/globals/item[@key = 'mode']/@value = 'incomplete'">
					<xsl:if test="@status != '3' and @status != '4'">1</xsl:if>
				</xsl:when>
				<xsl:when test="/config/globals/item[@key = 'mode']/@value = 'complete'">
					<xsl:if test="@status = '3' or @status = '4'">1</xsl:if>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$showRow = '1'">
		<tr>
			<xsl:choose>
				<xsl:when test="position() mod 2 = 0">
					<xsl:attribute name="class">even</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">odd</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<td>
				<xsl:value-of select="@company_name" />
				<br />
				<span class="options">
					<a href="?page=audit&amp;mode=audit_edit&amp;audit_id={@audit_id}" title="Audit Assessment">audit</a>
				</span>
			</td>
			<td>
				<xsl:value-of select="@name" />
			</td>
			<td>
				<xsl:value-of select="format-number(@audit_score, '###%')" />
			</td>
			<td>
				<!--//Get the current certification level for the checklist id -->
				<xsl:variable name="certification_level">
					<xsl:choose>
						<xsl:when test="@audit_score &gt; '0.80000' or @audit_score = '0.80000'">Gold</xsl:when>
						<xsl:when test="@audit_score &gt; '0.70000' or @audit_score = '0.70000'">Silver</xsl:when>
						<xsl:when test="@audit_score &gt; '0.60000' or @audit_score = '0.60000'">Bronze</xsl:when>
						<xsl:otherwise>invalid</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$certification_level" />
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="@audited = '0'">
						<xsl:text>No</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Yes</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="@certified = '0'">
						<xsl:text>No</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Yes</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td><xsl:apply-templates select="@audit_start_date" /></td>
			<td>
				<xsl:if test="@audited = '1' and @certified = '1'">
					<xsl:apply-templates select="@audit_finish_date" />
				</xsl:if>
			</td>
			<td>
				<xsl:value-of select="/config/audit_status[@status_id = current()/@status]/@status" />
			</td>
			<td style="text-align:right;">
				<xsl:value-of select="concat('$',format-number(@audit_cost,'0.00'))" />
			</td>
		</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="audit/@audit_start_date[. = '0000-00-00'] | audit/@audit_finish_date[. = '']" />
	
	<xsl:include href="modes/audit_edit.xsl" />
</xsl:stylesheet>