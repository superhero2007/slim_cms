<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="config[@mode = 'question_import']">
		<xsl:variable name="page" select="page[@page_id = current()/globals/item[@key = 'page_id']/@value]" />
		
		<!-- //Current Checklist -->
		<xsl:variable name="checklist" select="checklist[@checklist_id = current()/globals/item[@key = 'checklist_id']/@value]" />
		
		<!-- //Import Checklist -->
		<xsl:variable name="import_checklist" select="checklist[@checklist_id = current()/globals/item[@key = 'import_checklist_id']/@value]" />
        
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=checklist_edit">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_list">Page List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_edit&amp;page_id={$page/@page_id}">
				<xsl:value-of select="$page/@title" />
			</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=question_import&amp;page_id={$page/@page_id}">Import Questions</a>
		</p>
		
		<h1>Import Questions</h1>
        
        <!-- Show the checklist select option -->
        
        <form method="post" action="">
			<input type="hidden" name="action" value="fetch_checklist_questions" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Fetch Questions" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="import-checklsit-id">Checklist:</label></th>
						<td>
							<select id="import-checklist-id" name="import_checklist_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="checklist">
									<xsl:sort select="@name" />
									<option value="{@checklist_id}">
										<xsl:if test="@checklist_id = $import_checklist/@checklist_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@name" disable-output-escaping="yes" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
        
     	<!-- Show main part of the audit form -->

		<xsl:if test="$import_checklist/@checklist_id != ''">   
			<form method="post" action="">
				<input type="hidden" name="action" value="question_copy" />
				<input type="hidden" name="checklist_id" value="{$checklist/@checklist_id}" />
				<input type="hidden" name="import_checklist_id" value="{$import_checklist/@checklist_id}" />
				<input type="hidden" name="page_id" value="{$page/@page_id}" />
				<table class="editTable">
					<tfoot>
						<tr>
							<th colspan="3"><input type="submit" value="Import Questions" /></th>
						</tr>
					</tfoot>
					<tbody>
						<xsl:for-each select="import_checklist_page">
							<xsl:sort select="@sequence" data-type="number" />
							<tr>
								<th colspan="3">
									<xsl:value-of select="@title" />
								</th>
							</tr>
							<tr>
								<th width="75px">Select</th>
								<th>Question</th>
								<th>Sequence</th>
							</tr>
							<xsl:for-each select="../import_checklist_question[@page_id = current()/@page_id]">
								<tr>
									<td width="75px">
										<input type="checkbox" name="import_question[{@question_id}]" />
									</td>
									<td>
										<xsl:value-of select="@question" />
									</td>
									<td>
										<xsl:value-of select="@sequence" />
									</td>
								</tr>
							</xsl:for-each>
						</xsl:for-each>
					</tbody>
				</table>
			</form>
        </xsl:if>
	</xsl:template>
</xsl:stylesheet>