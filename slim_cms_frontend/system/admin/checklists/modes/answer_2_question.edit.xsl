<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'answer_2_question_edit']">
		<xsl:variable name="answer_2_question" select="answer_2_question[@answer_2_question_id = current()/globals/item[@key = 'answer_2_question_id']/@value]" />
		<xsl:variable name="question" select="question[@question_id = current()/globals/item[@key = 'question_id']/@value]" />
		<xsl:variable name="answer" select="answer[@answer_id = current()/globals/item[@key = 'answer_id']/@value]" />
		<xsl:variable name="page" select="page[@page_id = $question/@page_id]" />
		<xsl:call-template name="menu" />
		<h1>Add / Edit Answer to Question Link</h1>
		<form method="post" action="">
			<table>
				<tbody>
					<tr>
						<th scope="row"><label for="">
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
	
</xsl:stylesheet>