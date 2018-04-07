<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="config[@mode = 'client_checklist_answer_report']">
		<xsl:variable name="client" select="client[@client_id = current()/globals/item[@key = 'client_id']/@value]" />
		<xsl:variable name="client_checklist" select="client_checklist[@client_checklist_id = current()/globals/item[@key = 'client_checklist_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=clients">Account List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_edit&amp;client_id={$client/@client_id}"><xsl:value-of select="$client/@company_name" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=clients&amp;mode=client_checklist_answer_report&amp;client_id={$client/@client_id}&amp;client_checklist_id={$client_checklist/@client_checklist_id}">
				<xsl:value-of select="$client_checklist/@name" />
			</a>
		</p>
		<h1>Question &amp; Answers Report</h1>

		<xsl:for-each select="/config/checklistPage">
			<xsl:if test="count(/config/client_result[@page_id = current()/@page_id]) &gt; 0">
				<table class="edit_table">
					<tbody>
						<tr>
							<th scope="col" colspan="2">Page</th>
						</tr>
						<tr>
							<td colspan="2"><xsl:value-of select="@title" /></td>
						</tr>
						<tr>
							<th scope="col">Question</th>
							<th scope="col">Your Answer</th>
						</tr>
						<xsl:for-each select="/config/question[@page_id = current()/@page_id]">
							<xsl:sort select="@sequence" data-type="number" />
							
							<xsl:if test="count(/config/client_result[@page_id = current()/@page_id]) &gt; 0">
								<!-- //Check to see if the answer_type is a text area, if so break over 2 rows -->
								<xsl:choose>
									<xsl:when test="/config/client_result[@question_id = current()/@question_id]/@answer_type = 'textarea'">
										<tr>
											<td colspan="2" class="question">
												<xsl:value-of select="@question" disable-output-escaping="yes" />
											</td>
										</tr>
										<tr>
											<td colspan="2" class="answer">
												<xsl:for-each select="/config/client_result[@question_id = current()/@question_id]">
													<xsl:choose>
														<xsl:when test="@answer_type = 'checkbox' or @answer_type= 'drop-down-list'"><xsl:value-of select="/config/answer[@answer_id = current()/@answer_id]/@string" disable-output-escaping="yes" /></xsl:when>
														<xsl:when test="@answer_type = 'percent'"><xsl:value-of select="@arbitrary_value" />%</xsl:when>
														<xsl:when test="@answer_type = 'text' or @answer_type = 'textarea'">
															<xsl:if test="../answer[@answer_id = current()/@answer_id]/@string!= ''">
																<xsl:value-of select="concat(../answer[@answer_id = current()/@answer_id]/@string, ': ')" />
															</xsl:if>
															<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
														</xsl:when>
														<xsl:when test="@answer_type = 'checkbox-other'">Other: <xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:when>
														<xsl:when test="@answer_type = 'date-quarter'">Quarter ending <xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:when>
														<xsl:when test="@answer_type = 'float'">
															<xsl:if test="../answer[@answer_id = current()/@answer_id]/@string != ''">
																<xsl:value-of select="concat(../answer[@answer_id = current()/@answer_id]/@string, ': ')" />
															</xsl:if>
															<xsl:choose>
																<xsl:when test="string(number(myNode)) != 'NaN'">
																	<xsl:value-of select='format-number(@arbitrary_value, "###,###,###.00")' />
																</xsl:when>
																<xsl:otherwise>
																	<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
																</xsl:otherwise>
															</xsl:choose>
														</xsl:when>
														<xsl:when test="@answer_type = 'file-upload'">
															Downloadable File: <a href="/download/?hash={@arbitrary_value}"><xsl:value-of select="@arbitrary_value" /></a>
														</xsl:when>
														<xsl:otherwise><xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:otherwise>
													</xsl:choose>
													<br /><br /></xsl:for-each>
											</td>
										</tr>
									</xsl:when>
									<xsl:otherwise>
										<tr>
											<td class="question">
												<xsl:value-of select="@question" disable-output-escaping="yes" />
											</td>
											<td class="answer">
												<xsl:for-each select="/config/client_result[@question_id = current()/@question_id]">
													<xsl:choose>
														<xsl:when test="@answer_type = 'checkbox' or @answer_type = 'drop-down-list'"><xsl:value-of select="/config/answer[@answer_id = current()/@answer_id]/@string" disable-output-escaping="yes" /></xsl:when>
														<xsl:when test="@answer_type = 'percent'"><xsl:value-of select="@arbitrary_value" />%</xsl:when>
														<xsl:when test="@answer_type = 'text' or @answer_type = 'textarea'">
															<xsl:if test="../answer[@answer_id = current()/@answer_id]/@string!= ''">
																<xsl:value-of select="concat(../answer[@answer_id = current()/@answer_id]/@string, ': ')" />
															</xsl:if>
															<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
														</xsl:when>
														<xsl:when test="@answer_type = 'checkbox-other'">Other: <xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:when>
														<xsl:when test="@answer_type = 'date-quarter'">Quarter ending <xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:when>
														<xsl:when test="@answer_type = 'float'">
															<xsl:if test="../answer[@answer_id = current()/@answer_id]/@string != ''">
																<xsl:value-of select="concat(../answer[@answer_id = current()/@answer_id]/@string, ': ')" />
															</xsl:if>
															<xsl:choose>
																<xsl:when test="string(number(myNode)) != 'NaN'">
																	<xsl:value-of select='format-number(@arbitrary_value, "###,###,###.00")' />
																</xsl:when>
																<xsl:otherwise>
																	<xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" />
																</xsl:otherwise>
															</xsl:choose>
														</xsl:when>
														<xsl:when test="@answer_type = 'file-upload'">
															Downloadable File: <a href="/download?hash={@arbitrary_value}"><xsl:value-of select="@arbitrary_value" /></a>
														</xsl:when>
														<xsl:otherwise><xsl:value-of select="@arbitrary_value" disable-output-escaping="yes" /></xsl:otherwise>
													</xsl:choose>
													<br />
												</xsl:for-each>
											</td>
										</tr>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
		</xsl:for-each>
		
	</xsl:template>

</xsl:stylesheet>
