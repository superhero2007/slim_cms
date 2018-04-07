<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
			xmlns:fo="http://www.w3.org/1999/XSL/Format" 
			xmlns:svg="http://www.w3.org/2000/svg" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:date="http://exslt.org/dates-and-times" 
			xmlns:str="http://exslt.org/strings" 
			extension-element-prefixes="date str">

	<xsl:template name="stampImage">
		<xsl:param name="prefix"/>
		<xsl:param name="certifiedLevel"/>
		<xsl:param name="generator" select="'greenbizcheck'"/>
		<xsl:param name="imageWidth" select="'400'"/>
		<xsl:param name="client_checklist_id" />
        <xsl:param name="stamp_name" />
		
		<xsl:variable name="imageSrc">
			<xsl:choose>
            	<!-- //When the stamp name is passed render it first! -->
                <xsl:when test="$stamp_name != ''">
					<xsl:text>url(https://www.</xsl:text>
					<xsl:value-of select="$generator" />
					<xsl:text>.com/stamp/?s=</xsl:text>
					<xsl:value-of select="$stamp_name" />
					<xsl:text>&amp;w=</xsl:text>
					<xsl:value-of select="$imageWidth" />
					<xsl:text>)</xsl:text>
				</xsl:when>
            
				<xsl:when test="$client_checklist_id != ''">
					<xsl:text>url(https://www.</xsl:text>
					<xsl:value-of select="$generator" />
					<xsl:text>.com/stamp/?cclid=</xsl:text>
					<xsl:value-of select="$client_checklist_id"/>
					<xsl:text>&amp;w=</xsl:text>
					<xsl:value-of select="$imageWidth"/>
					<xsl:text>)</xsl:text>
				</xsl:when>
				<xsl:when test="$certifiedLevel != ''">
					<xsl:text>url(https://www.</xsl:text>
					<xsl:value-of select="$generator" />
					<xsl:text>.com/stamp/?s=</xsl:text>
					<xsl:value-of select="$prefix"/>
					<xsl:text>_</xsl:text>
					<xsl:value-of select="$certifiedLevel"/>
					<xsl:text>&amp;w=</xsl:text>
					<xsl:value-of select="$imageWidth"/>
					<xsl:text>)</xsl:text>
				</xsl:when>
				
				<!-- //When null is passed allow the stamp renderer to choose any image -->
				<xsl:when test="$certifiedLevel = 'null'">
					<xsl:text>url(https://www.</xsl:text>
					<xsl:value-of select="$generator" />
					<xsl:text>.com/stamp/?s=</xsl:text>
					<xsl:value-of select="$prefix"/>
					<xsl:text>&amp;w=</xsl:text>
					<xsl:value-of select="$imageWidth"/>
					<xsl:text>)</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>url(https://www.</xsl:text>
					<xsl:value-of select="$generator" />
					<xsl:text>.com/stamp/?s=</xsl:text>
					<xsl:value-of select="$generator" />
					<xsl:text>_inprogress</xsl:text>
					<xsl:text>&amp;w=</xsl:text>
					<xsl:value-of select="$imageWidth"/>
					<xsl:text>)</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<fo:external-graphic src="{$imageSrc}" content-width="24%">
		</fo:external-graphic>
	</xsl:template>
	
</xsl:stylesheet>