<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'international_report_section_edit']">
		<xsl:variable name="report_section" select="report_section[@report_section_id = current()/globals/item[@key = 'report_section_id']/@value]" />
		<xsl:variable name="international_report_section" select="international_report_section[@international_report_section_id = current()/globals/item[@key = 'international_report_section_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_list&amp;checklist_id={$checklist_id}">Report Section List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}"><xsl:value-of select="$report_section/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=international_report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;action_id={$international_report_section/@international_report_section_id}">
				<xsl:choose>
					<xsl:when test="$international_report_section"><xsl:value-of select="country[@country_id = $international_report_section/@country_id]/@country" /></xsl:when>
					<xsl:otherwise>Create International Report Section</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit International Report Section</h1>
		<p>Here you can edit this international report section content selecting the country and entering your content. The "Content" must be well formed XHTML.</p>
		<form method="post" action="">
			<input type="hidden" name="action" value="international_report_section_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="international_report_section_id" value="{$international_report_section/@international_report_section_id}" />
			<input type="hidden" name="report_section_id" value="{$report_section/@report_section_id}" />

			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save International Report Section" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="report-section-id">Country:</label></th>
						<td>
							<select id="country_id" name="country_id">
								<xsl:for-each select="/config/country">
									<xsl:sort select="@country" data-type="text" />
									<option value="{@country_id}">
										<xsl:if test="@country_id = $international_report_section/@country_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@country" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="content">International Report Section Content:<br />(XHTML)</label></th>
						<td><textarea cols="45" rows="8" id="content" name="content"><xsl:value-of select="$international_report_section/@content" /></textarea></td>
											
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