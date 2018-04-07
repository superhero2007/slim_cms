<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			extension-element-prefixes="date str">

	<!-- //Template for rendering questionAnswers -->
    <xsl:template match="questionAnswers" mode="xhtml">
	
		<fo:table margin="4px" margin-bottom="20px">
			<fo:table-column column-width="70%" />
			<fo:table-column column-width="30%" />
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Question</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block font-weight="bold" padding="8px" background-color="#f3f3f3">Answer</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
		
			<xsl:for-each select="/config/plugin[@plugin='checklist']/report/questionAnswer">
			
				<!-- //Render the Question -->
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block padding="8px" border-top="1px solid #ddd">
								<xsl:value-of select="@question" />
							</fo:block>
						</fo:table-cell>
					
						<!-- //Render the answers -->
						<fo:table-cell>
							<xsl:for-each select="answer">
								<fo:block padding="8px" border-top="1px solid #ddd">
									<xsl:choose>
										<xsl:when test="@answer_type = 'checkbox'"><xsl:value-of select="@answer_string" disable-output-escaping="yes" /></xsl:when>
										<xsl:when test="@answer_type = 'percent'"><xsl:value-of select="@arbitrary_value" />%</xsl:when>
										<xsl:when test="@answer_type = 'text' or @answer_type = 'textarea'">
											<xsl:if test="@answer_string != ''">
												<xsl:value-of select="concat(@answer_string, ': ')" />
											</xsl:if>
											<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
										</xsl:when>
										<xsl:when test="@answer_type = 'checkbox-other'">Other: <xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:when>
										<xsl:when test="@answer_type = 'date-quarter'">Quarter ending <xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:when>
										<xsl:when test="@answer_type = 'float'">
											<xsl:if test="@answer_string != ''">
												<xsl:value-of select="concat(@answer_string, ': ')" />
											</xsl:if>
											<xsl:value-of select='format-number(@arbitrary_value, "###,###,##0.00")' />
										</xsl:when>
										<xsl:when test="@answer_type = 'file-upload'">
											<fo:basic-link color="blue" external-destination="http://www.greenbizcheck.com/download?action=download-file&amp;file-type=answer_document&amp;file-name={@arbitrary_value}"><xsl:value-of select="@arbitrary_value" /></fo:basic-link>
										</xsl:when>
										<xsl:otherwise><xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:otherwise>
									</xsl:choose>
								</fo:block>
							</xsl:for-each>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</xsl:for-each>
		</fo:table>
	</xsl:template>
  
</xsl:stylesheet>