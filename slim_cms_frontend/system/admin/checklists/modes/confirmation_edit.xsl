<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="config[@mode = 'confirmation_edit']">
		<xsl:variable name="report_section" select="report_section[@report_section_id = current()/globals/item[@key = 'report_section_id']/@value]" />
		<xsl:variable name="confirmation" select="confirmation[@confirmation_id = current()/globals/item[@key = 'confirmation_id']/@value]" />
		
        <xsl:variable name="question_id">			
			<xsl:choose>
            	<xsl:when test="current()/globals/item[@key = 'question_id']">
                	<xsl:value-of select="question[@question_id = current()/globals/item[@key = 'question_id']/@value]/@question_id" />
                </xsl:when>
				<xsl:otherwise>
                	<xsl:value-of select="answer[@answer_id = $confirmation/@answer_id]/@question_id" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
        
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
            
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_list&amp;checklist_id={$checklist_id}">Report Section List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}"><xsl:value-of select="$report_section/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=confirmation_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;confirmation_id={$confirmation/@confirmation_id}">
				<xsl:choose>
					<xsl:when test="$confirmation"><xsl:value-of select="$confirmation/@confirmation" /></xsl:when>
					<xsl:otherwise>Create Confirmation</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Confirmation</h1>
        
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
        
     	<!-- Show main part of the confirmation form -->

		<xsl:if test="$question_id != ''">   
        <xsl:variable name="current_answer" select="answer[@question_id =  $question_id]" />
		<form method="post" action="">
        	<input type="hidden" name="action" value="confirmation_save" />
            <input type="hidden" name="checklist_id" value="{$checklist_id}" />
            <input type="hidden" name="confirmation_id" value="{$confirmation/@confirmation_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Confirmation" /></th>
					</tr>
				</tfoot>
				<tbody>
				<!-- //Add section to choose the report_section_id -->
					<tr>
						<th scope="row"><label for="report-section-id">Report Section:</label></th>
						<td>
							<select id="report-section-id" name="report_section_id">
								<xsl:for-each select="report_section[@checklist_id = $checklist_id]">
									<xsl:sort select="@sequence" data-type="number" />
									<option value="{@report_section_id}">
										<xsl:if test="@report_section_id = $report_section/@report_section_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="concat(position(),' - ',@title)" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
                	<tr>
                		<th scope="row"><label for="answer-id">Answer:</label></th>
						<td>
                            	<xsl:choose>
                                <xsl:when test="$current_answer/@answer_type != 'percent'">
								<select id="answer-id" name="answer-id">
									<option value="0">-- Select --</option>
									<xsl:for-each select="answer[@question_id = $question_id]">
										<option value="{@answer_id}">
											<xsl:if test="@answer_id = $confirmation/@answer_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
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
						<td><input type="text" id="arbitrary-value" name="arbitrary-value" value="{$confirmation/@arbitrary_value}" /></td>
					</tr>
                	<tr>
						<th scope="row"><label for="confirmation">Confirmation:</label></th>
                       	<td><textarea cols="45" rows="8" id="confirmation" name="confirmation"><xsl:value-of select="$confirmation/@confirmation" /></textarea></td>
					</tr>
				</tbody>
			</table>
		</form>
		
				<!-- //International Action list -->
		<h1>International Confirmation List</h1>	
		<p>Below is the list of international confirmation custom content. click 'add' at the bottom to create a new international confirmation content listing. Click edit to modify an existing listing. Click delete to remove an existing listing.</p>
		<table id="table-action-list">
			<thead>
				<tr>
					<th scope="col">Country</th>
					<th scope="col">Confirmation</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="2"><input type="button" value="Add International Confirmation Content" onclick="document.location = '?page=checklists&amp;mode=international_confirmation_edit&amp;checklist_id={$checklist_id}&amp;confirmation_id={$confirmation/@confirmation_id}&amp;report_section_id={$report_section/@report_section_id}'" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="international_confirmation[@report_section_id = $report_section/@report_section_id and @confirmation_id = $confirmation/@confirmation_id]">
					<tr id="id-{@international_confirmation_id}">
						<td>
							<xsl:value-of select="../country[@country_id = current()/@country_id]/@country" disable-output-escaping="yes" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=international_confirmation_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;confirmation_id={$confirmation/@confirmation_id}&amp;international_confirmation_id={@international_confirmation_id}" title="Edit Content">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;mode=international_confirmation_delete&amp;action=international_confirmation_delete&amp;checklist_id={$checklist_id}&amp;report_section_id={$report_section/@report_section_id}&amp;confirmation_id={$confirmation/@confirmation_id}&amp;international_confirmation_id={@international_confirmation_id}" title="Delete Content" onclick="return(confirm('Did you really mean to click delete?'))">delete</a>
							</span>
						</td>
						<td>
							<xsl:value-of select="@confirmation" disable-output-escaping="yes" />
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		
        </xsl:if>
	</xsl:template>
</xsl:stylesheet>