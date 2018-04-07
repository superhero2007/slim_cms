<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="config[@mode = 'checklist_dump']">
		<xsl:call-template name="menu" />
		
		<!-- //Add key to top of page to describe the errors -->
		<br />
		<fieldset>
			<p><strong>Error Key</strong></p>
			<table class="editTable">
				<tr>
					<th scope="row">Colour</th>
					<th>Error</th>
				</tr>
				<tr>
					<td><xsl:attribute name="style">background-color: #F00;</xsl:attribute></td>
					<td width="90%">XHTML Encoding Error</td>
				</tr>
				<tr>
					<td><xsl:attribute name="style">background-color: #FFCC00;</xsl:attribute></td>
					<td width="90%">Question does not have any answers</td>
				</tr>
				<tr>
					<td><xsl:attribute name="style">background-color: #f5fe00;</xsl:attribute></td>
					<td width="90%">Sequence Error</td>
				</tr>
			</table>
		</fieldset>
		
		<xsl:for-each select="/config/page[@checklist_id = $checklist_id]">
			<xsl:sort select="@sequence" data-type="number" />
			<xsl:variable name="page_sequence" select="@sequence" />
			
			<table class="editTable">
				<tbody>
					<tr>
						<th scope="row">Page ID:</th>
						<td><xsl:value-of select="@page_id" /></td>
					</tr>
					<tr>
						<th scope="row">Page title:</th>
						<td><a href="?page=checklists&amp;mode=page_edit&amp;checklist_id={$checklist_id}&amp;page_id={@page_id}"><xsl:value-of select="@title" /></a></td>
					</tr>
					<tr>
						<th scope="row">Page content:</th>
						<td><xsl:value-of select="@content" disable-output-escaping="yes" /></td>
					</tr>
					<tr>
						<th scope="row">Skipable:</th>
						<td>
							<xsl:choose>
								<xsl:when test="@enable_skipping = '1'">Yes</xsl:when>
								<xsl:otherwise>No</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<xsl:if test="/config/question[@page_id = current()/@page_id]">
						<tr>
							<th scope="row">Questions:</th>
							<td>
								<table>
									<thead>
										<tr>
											<th scope="col" style="width: 1em;">Question ID</th>
											<th scope="col">Question</th>
										</tr>
									</thead>
									<tbody>
										<xsl:for-each select="/config/question[@page_id = current()/@page_id]">
											<xsl:sort select="@sequence" data-type="number" />
											<xsl:variable name="answers" select="/config/answer[@question_id = current()/@question_id]" />	
																					
											<tr>
												<td>
													<xsl:if test="count(/config/answer[@question_id = current()/@question_id]) = 0 and @content_block = '0'">
														<xsl:attribute name="style">background-color: #FFCC00;</xsl:attribute>
													</xsl:if>
													<xsl:value-of select="@question_id" />
												</td>
												<td>
													<xsl:if test="count(/config/answer[@question_id = current()/@question_id]) = 0 and @content_block = '0'">
														<xsl:attribute name="style">background-color: #FFCC00;</xsl:attribute>
													</xsl:if>
													<a href="?page=checklists&amp;mode=question_edit&amp;checklist_id={$checklist_id}&amp;page_id={@page_id}&amp;question_id={@question_id}"><xsl:value-of select="@question" disable-output-escaping="yes" /></a>
													<xsl:if test="/config/answer_2_question[@question_id = current()/@question_id]">
														<br />
														<strong>Contingent Questions:</strong>
														<ul>
															<xsl:for-each select="/config/answer_2_question[@question_id = current()/@question_id]">
																<xsl:variable name="contingent_answer" select="/config/answer[@answer_id = current()/@answer_id]" />
																<xsl:variable name="contingent_question" select="/config/question[@question_id = $contingent_answer/@question_id]" />
																<xsl:variable name="contingent_page" select="/config/page[@page_id = $contingent_question/@page_id]" />
																<li>
																	<xsl:if test="$page_sequence &lt; $contingent_page/@sequence">
																		<xsl:attribute name="style">color: #f5fe00;</xsl:attribute>
																	</xsl:if>
																	<xsl:value-of select="concat($contingent_page/@sequence,' - ',$contingent_page/@title)" />
																	<xsl:text> &gt; </xsl:text>
																	<xsl:value-of select="$contingent_question/@question" disable-output-escaping="yes" />
																	<xsl:text> &gt; </xsl:text>
																	<xsl:value-of select="/config/answer_string[@answer_string_id = $contingent_answer/@answer_string_id]/@string" />
																</li>
															</xsl:for-each>
														</ul>
													</xsl:if>
													<xsl:if test="/config/answer_2_question[@answer_id = $answers/@answer_id]">
														<br />
														<strong>Dependant Questions:</strong>
														<ul>
															<xsl:for-each select="/config/answer_2_question[@answer_id = $answers/@answer_id]">
																<xsl:variable name="dependant_answer" select="/config/answer[@answer_id = current()/@answer_id]" />
																<xsl:variable name="dependant_question" select="/config/question[@question_id = current()/@question_id]" />
																<xsl:variable name="dependant_page" select="/config/page[@page_id = $dependant_question/@page_id]" />
																<li>
																	<xsl:if test="$page_sequence &gt; $dependant_page/@sequence">
																		<xsl:attribute name="style">color: #f5fe00;</xsl:attribute>
																	</xsl:if>
																	<xsl:value-of select="/config/answer_string[@answer_string_id = $dependant_answer/@answer_string_id]/@string" />
																	<xsl:text> &gt; </xsl:text>
																	<xsl:value-of select="concat($dependant_page/@sequence,' - ',$dependant_page/@title)" />
																	<xsl:text> &gt; </xsl:text>
																	<xsl:value-of select="$dependant_question/@question" disable-output-escaping="yes" />
																	<xsl:if test="$dependant_question = false()">
																		<xsl:text>You should delete answer_2_question_id </xsl:text> 
																		<xsl:value-of select="@answer_2_question_id" />
																	</xsl:if>
																</li>
															</xsl:for-each>
														</ul>
													</xsl:if>
												</td>
											</tr>
										</xsl:for-each>
									</tbody>
								</table>
							</td>
						</tr>
					</xsl:if>
				</tbody>
			</table>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="config[@mode = 'report_dump']">
		<xsl:call-template name="menu" />
		
		<!-- //Add key to top of page to describe the errors -->
		<br />
		<fieldset>
			<p><strong>Error Key</strong></p>
			<table class="editTable">
				<tr>
					<th scope="row">Colour</th>
					<th>Error</th>
				</tr>
				<tr>
					<td><xsl:attribute name="style">background-color: #F00;</xsl:attribute></td>
					<td width="90%">XHTML Encoding Error</td>
				</tr>
				<tr>
					<td><xsl:attribute name="style">background-color: #FFCC00;</xsl:attribute></td>
					<td width="90%">Too many/little commitment (merits) for the action (demerits)</td>
				</tr>
				<tr>
					<td><xsl:attribute name="style">background-color: #f5fe00;</xsl:attribute></td>
					<td width="90%">Zero points (demerits) for the action</td>
				</tr>
			</table>
		</fieldset>
		
		<xsl:for-each select="/config/report_section[@checklist_id = $checklist_id]">
			<xsl:sort select="@sequence" data-type="number" />
			<table class="editTable">
				<tbody>
					<tr>
						<th scope="row">Report Section ID:</th>
						<td><xsl:value-of select="@report_section_id" /></td>
					</tr>
					<tr>
						<th scope="row">Title:</th>
						<td><a href="?page=checklists&amp;mode=report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={@report_section_id}"><xsl:value-of select="@title" /></a></td>
					</tr>
					<tr>
						<th scope="row">Content:</th>
						<td><xsl:value-of select="@content" disable-output-escaping="yes" /></td>
					</tr>
					<xsl:if test="/config/confirmation[@report_section_id = current()/@report_section_id]">
						<tr>
							<th scope="row">Confirmations:</th>
							<td>
								<xsl:for-each select="/config/confirmation[@report_section_id = current()/@report_section_id]">
									<table class="editTable">
										<tbody>
											<tr>
												<th scope="row">Confirmation ID:</th>
												<td><xsl:value-of select="@confirmation_id" /></td>
											</tr>
											<tr>
												<th scope="row">Confirmation:</th>
												<td><xsl:value-of select="@confirmation" /></td>
											</tr>
										</tbody>
									</table>
								</xsl:for-each>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="/config/action[@report_section_id = current()/@report_section_id]">
						<tr>
							<th scope="row">Actions:</th>
							<td>
								<xsl:for-each select="/config/action[@report_section_id = current()/@report_section_id]">
									<xsl:sort select="@sequence" data-type="number" />
									<table class="editTable">
										<tbody>
											<tr>
												<th scope="row">Action ID:</th>
												<td>
													<xsl:if test="../problem_action/@action_id = current()/@action_id and ../problem_action[@action_id = current()/@action_id]/@demerits != 0">
														<xsl:attribute name="style">background-color: #FFCC00;</xsl:attribute>
													</xsl:if>
													<xsl:value-of select="@action_id" />
												</td>
											</tr>
											<tr>
												<th scope="row">Summary:</th>
												<td><a href="?page=checklists&amp;mode=action_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={@report_section_id}&amp;action_id={@action_id}"><xsl:value-of select="@summary" disable-output-escaping="yes" /></a></td>
											</tr>
											<tr>
												<th scope="row">Proposed Measure:</th>
												<td>
													<xsl:if test="@proposed_measure_wellformed = '0'"><xsl:attribute name="style">background-color: #F00;</xsl:attribute></xsl:if>
													<xsl:value-of select="@proposed_measure" disable-output-escaping="yes" />
												</td>
											</tr>
											<tr>
												<th scope="row">Comments:</th>
												<td>
													<xsl:if test="@comments_wellformed = '0'"><xsl:attribute name="style">background-color: #F00;</xsl:attribute></xsl:if>
													<xsl:value-of select="@comments" disable-output-escaping="yes" />
												</td>
											</tr>
											<tr>
												<th scope="row">Demerits:</th>
												<td>
													<xsl:if test="../problem_action/@action_id = current()/@action_id and ../problem_action[@action_id = current()/@action_id]/@demerits = 0">
														<xsl:attribute name="style">background-color: #f5fe00;</xsl:attribute>
													</xsl:if>
													<xsl:value-of select="@demerits" /> demerits
												</td>
											</tr>
											<tr>
												<th scope="row">Commitments:</th>
												<td>
													<ul>
														<xsl:for-each select="/config/commitment[@action_id = current()/@action_id]">
															<xsl:sort select="@sequence" data-type="number" />
															<li><xsl:value-of select="concat(@commitment,' (',@merits,' merits)')" /></li>
														</xsl:for-each>
													</ul>
												</td>
											</tr>
										</tbody>
									</table>
								</xsl:for-each>
							</td>
						</tr>
					</xsl:if>
				</tbody>
			</table>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>