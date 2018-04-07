<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">
	
	<xsl:template name="question-result">
		<xsl:param name="question"/>
		
		<xsl:for-each select="$question/result">
			<xsl:variable name="answer" select="$question/answer[@answer_id = current()/@answer_id]"/>
			<!-- Answer string -->
			<xsl:if test="$answer/@string != ''">
				<xsl:value-of select="$answer/@string"/>
			</xsl:if>
			
			<!-- Separator if answer string and result value -->
			<xsl:if test="$answer/@string != '' and @value != ''">
				<xsl:text>: </xsl:text>
			</xsl:if>
			
			<!-- Result value -->
			<xsl:choose>
				<xsl:when test="$answer/@type = 'percent'">
					<xsl:value-of select="@value"/><xsl:text>%</xsl:text>
				</xsl:when>
				<xsl:when test="$answer/@type = 'range'">
					<xsl:value-of select="@value"/><xsl:text> </xsl:text><xsl:value-of select="@unit" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="not($answer/@string) and @value = ''">
							<em>Left Blank</em>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@value"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		
	</xsl:template>
	
	<xsl:template match="h3" mode="html">
		<xsl:param name="pageNumber" />
		<h3>
			<xsl:if test="$pageNumber">
				<xsl:value-of select="$pageNumber"/>
				<xsl:text>. </xsl:text>
			</xsl:if>
			<xsl:value-of select="."/>
		</h3>
	</xsl:template>

	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'assessmentAnswers']">

		<h2><xsl:value-of select="clientChecklist/@checklist" /> Answers</h2>
		<xsl:if test="@own_checklist = 'no'">
			<h3>For: <a href="/members/associate/edit-client/?client_id={clientChecklist/@client_id}"><xsl:value-of select="clientChecklist/@company_name"/></a></h3>
		</xsl:if>
		<xsl:if test="clientChecklist/@status = 'incomplete'">
			<div class="checklist-complete-message">Checklist Incomplete</div>
		</xsl:if>
		
		<div class="checklist-answers">
			
		<xsl:for-each select="clientChecklist/page">
			<xsl:if test="question and question/result">
				<div class="page">
					<xsl:variable name="page" select="."/>
					<div class="page-head">
						<xsl:apply-templates select="content/*" mode="html"><xsl:with-param name="pageNumber" select="position()"/></xsl:apply-templates>
					</div>
			
					<h4>Questions</h4>
					<ol class="questions">
						<xsl:for-each select="question[result]">
							<xsl:variable name="question" select="."/>
								<li>
									<label>
										<xsl:value-of select="@question" disable-output-escaping="yes" />
										<xsl:text> </xsl:text>
									</label>
									<span>
										<xsl:call-template name="question-result"><xsl:with-param name="question" select="."/></xsl:call-template>
									</span>
								</li>
						</xsl:for-each>
					</ol>
					
					<xsl:if test="@note and @note != ''">
						<div class="notes">
							<h4>Page Note/Comment</h4>
							<blockquote>
								<xsl:value-of select="@note" disable-output-escaping="yes" />
							</blockquote>
						</div>
					</xsl:if>
				</div>
			</xsl:if>
		</xsl:for-each>
		
		</div>

	</xsl:template>
</xsl:stylesheet>