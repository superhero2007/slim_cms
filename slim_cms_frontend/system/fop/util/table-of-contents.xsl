<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:svg="http://www.w3.org/2000/svg" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:date="http://exslt.org/dates-and-times" 
	xmlns:str="http://exslt.org/strings" 
	extension-element-prefixes="date str">

	<xsl:template match="tableOfContents" mode="xhtml">
		<!-- //Table of contents -->
		<fo:table border-collapse="collapse" margin-bottom="20mm">
			<fo:table-column column-width="60%" column-number="1"/>
			<fo:table-column column-width="40%" column-number="2" text-align="right" />
			<fo:table-body>
				<xsl:for-each select="/config/plugin[@plugin='checklist']/report/reportSection[@display_in_pdf = '1']">
					<fo:table-row>
						<fo:table-cell padding-bottom="2pt">
							<xsl:if test="@subsection_of_id &lt;= 0">
								<xsl:attribute name="padding-top">10pt</xsl:attribute>
							</xsl:if>
							<fo:block>
								<xsl:choose>
									<xsl:when test="@subsection_of_id &gt; 0">
										<xsl:attribute name="margin-left">6mm</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="font-weight">Bold</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:value-of select="@title"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell padding-bottom="2pt" text-align="right">
							<xsl:if test="@subsection_of_id &lt;= 0">
								<xsl:attribute name="padding-top">10pt</xsl:attribute>
							</xsl:if>
							<fo:block>
								<xsl:if test="@subsection_of_id &lt;= 0">
									<xsl:attribute name="font-weight">Bold</xsl:attribute>
								</xsl:if>
								<fo:page-number-citation ref-id="report-section-{@report_section_id}"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>
	</xsl:template>

</xsl:stylesheet>