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
	
		<fo:table>
			<fo:table-column column-width="125mm"/>
			<fo:table-column column-width="65mm"/>
				
			<!-- //Render the header row -->
			<fo:table-header>
				<fo:table-row>
					<fo:table-cell background-color="#EEE"
						border-top-width="0.5mm" border-top-color="#000000" border-top-style="solid"
						border-right-width="0.5mm" border-right-color="#000000" border-right-style="solid"
						border-bottom-width="0.5mm" border-bottom-color="#000000" border-bottom-style="solid"
						border-left-width="0.5mm" border-left-color="#000000" border-left-style="solid"
						padding-top="1mm" padding-bottom="1mm">
						<fo:block font-weight="bold">Question</fo:block>
					</fo:table-cell>
					<fo:table-cell background-color="#EEE"
						border-top-width="0.5mm" border-top-color="#000000" border-top-style="solid"
						border-right-width="0.5mm" border-right-color="#000000" border-right-style="solid"
						border-bottom-width="0.5mm" border-bottom-color="#000000" border-bottom-style="solid"
						border-left-width="0.5mm" border-left-color="#000000" border-left-style="solid"
						padding-top="1mm" padding-bottom="1mm">
						<fo:block font-weight="bold">Answers</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
		
			<xsl:for-each select="/config/plugin[@plugin='checklist']/report/questionAnswer">
			
				<!-- //Render the Question -->
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell
							border-top-width="0.5mm" border-top-color="#000000" border-top-style="solid"
							border-right-width="0.5mm" border-right-color="#000000" border-right-style="solid"
							border-bottom-width="0.5mm" border-bottom-color="#000000" border-bottom-style="solid"
							border-left-width="0.5mm" border-left-color="#000000" border-left-style="solid"
							padding-top="1mm" padding-bottom="1mm">
							<fo:block>
								<xsl:value-of select="@question" />
							</fo:block>
						</fo:table-cell>
					
						<!-- //Render the answers -->
						<fo:table-cell
							border-top-width="0.5mm" border-top-color="#000000" border-top-style="solid"
							border-right-width="0.5mm" border-right-color="#000000" border-right-style="solid"
							border-bottom-width="0.5mm" border-bottom-color="#000000" border-bottom-style="solid"
							border-left-width="0.5mm" border-left-color="#000000" border-left-style="solid"
							padding-top="1mm" padding-bottom="1mm">
							<xsl:for-each select="answer">
								<fo:block>
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
											<fo:basic-link color="blue" external-destination="https://www.greenbizcheck.com/download/?hash={@arbitrary_value}"><xsl:value-of select="@arbitrary_value" /></fo:basic-link>
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