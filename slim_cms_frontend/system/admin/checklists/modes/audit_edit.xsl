<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="config[@mode = 'audit_edit']">
		<xsl:variable name="audit" select="audit[@audit_id = current()/globals/item[@key = 'audit_id']/@value]" />
		<xsl:variable name="question_id">
			<xsl:choose>
				<xsl:when test="$audit">
                	<xsl:value-of select="answer[@answer_id = $audit/@answer_id]/@question_id" />
				</xsl:when>
				<xsl:otherwise>
                	<xsl:value-of select="question[@question_id = current()/globals/item[@key = 'question_id']/@value]/@question_id" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
        
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=audit_list&amp;checklist_id={$checklist_id}">Audit List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=audit_edit&amp;checklist_id={$checklist_id}&amp;audit_id={$audit/@audit_id}">
				<xsl:choose>
					<xsl:when test="$audit"><xsl:value-of select="question[@question_id = $question_id]/@question" disable-output-escaping="yes" /></xsl:when>
					<xsl:otherwise>Create Audit</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Audit Item</h1>
        
        <!-- Show the question select option -->
        
        <form method="post" action="">
			<input type="hidden" name="action" value="fetch_question_answers" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Fetch Answers" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="question-id">Question:</label></th>
						<td>
							<select id="question-id" name="question_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="page[@checklist_id = $checklist_id]">
									<xsl:sort select="@sequence" data-type="number" />
									<optgroup label="{@title}">
										<xsl:for-each select="../question[@page_id = current()/@page_id]">
											<xsl:sort select="@sequence"  data-type="number" />
											<option value="{@question_id}">
												<xsl:if test="@question_id = $question_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
												<xsl:value-of select="concat(@question_id,' - ',substring(@question,1,50),'...')" disable-output-escaping="yes" />
											</option>
										</xsl:for-each>
									</optgroup>
								</xsl:for-each>
							</select>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
        
     	<!-- Show main part of the audit form -->

		<xsl:if test="$question_id != ''">   
        <xsl:variable name="current_answer" select="answer[@question_id =  current()/globals/item[@key = 'question_id']/@value]" />
		<form method="post" action="">
        	<input type="hidden" name="action" value="audit_save" />
            <input type="hidden" name="checklist_id" value="{$checklist_id}" />
            <input type="hidden" name="audit_id" value="{$audit/@audit_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Audit Item" /></th>
					</tr>
				</tfoot>
				<tbody>
                	<tr>
                		<th scope="row"><label for="answer-id">Answer:</label></th>
						<td>
                            	<xsl:choose>
                                <xsl:when test="$current_answer/@answer_type != 'percent'">
								<select id="answer-id" name="answer-id">
									<option value="0">-- Select --</option>
									<xsl:for-each select="answer[@question_id = $question_id]">
										<option value="{@answer_id}">
											<xsl:if test="@answer_id = $audit/@answer_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
                                            <xsl:value-of select="../answer_string[@answer_string_id = current()/@answer_string_id]/@string" disable-output-escaping="yes" />
										</option>
									</xsl:for-each>
								</select>
                                </xsl:when>
                                <xsl:otherwise>
                                <xsl:text>Range (Input Arbitrary Value)</xsl:text>
                                <input type="hidden" id="answer-id" name="answer-id" value="{$current_answer/@answer_id}" />
                                </xsl:otherwise>
                                </xsl:choose>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="title">Arbitrary Value:(Optional)</label></th>
						<td><input type="text" id="arbitrary-value" name="arbitrary-value" value="{$audit/@arbitrary_value}" /></td>
					</tr>
                	<tr>
						<th scope="row"><label for="confirmation">Audit Type:</label></th>
                       	<td>
                       		<select type="select" id="audit_type" name="audit_type">
                       			<option value="Documentary Evidence">Documentary Evidence</option>
                       			<option value="Physical Audit">Physical Audit</option>
                       			<option value="Physical Audit / Documentary Evidence">Physical Audit / Documentary Evidence</option>
                       		</select>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
        </xsl:if>
	</xsl:template>
</xsl:stylesheet>