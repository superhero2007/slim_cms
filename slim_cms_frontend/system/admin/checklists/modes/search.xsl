<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<func:function name="gbc:match">
		<xsl:param name="string1" />
		<xsl:param name="string2" />
		<xsl:choose>
			<xsl:when test="contains(translate($string1,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),translate($string2,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'))">
				<func:result select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<func:result select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</func:function>
	
	<xsl:template match="config[@mode = 'search']">
		<xsl:variable name="in" select="globals/item[@key = 'in']/@value" />
		<xsl:variable name="q" select="globals/item[@key = 'q']/@value" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=checklist_edit&amp;checklist_id={$checklist_id}">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;mode=search&amp;checklist_id={$checklist_id}">Search</a>
		</p>
		<h1>Search</h1>
		<form method="get" action="">
			<input type="hidden" name="page" value="checklists" />
			<input type="hidden" name="mode" value="search" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Search" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="search-q">Query:</label></th>
						<td><input type="text" id="search-q" name="q" value="{/config/globals/item[@key = 'q']/@value}" /></td>
					</tr>
					<tr>
						<th scope="row">In:</th>
						<td>
							<xsl:for-each select="str:tokenize('Pages,Questions,Report Sections,Actions,Primary ID',',')">
								<label>
									<input type="radio" name="in" value="{.}">
										<xsl:if test=". = $in"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
									</input>
									<xsl:value-of select="." />
								</label>
								<br />
							</xsl:for-each>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
		<xsl:if test="$q and $in">
			<h1>Search Results</h1>
			<ol>
				<xsl:choose>
					<xsl:when test="$in = 'Pages'">
						<xsl:for-each select="page[@checklist_id = $checklist_id][gbc:match(@title,$q) or gbc:match(@content,$q)]">
							<xsl:sort select="@sequence" data-type="number" />
							<li>
								<strong>Page: </strong>
								<a href="?page=checklists&amp;mode=page_edit&amp;checklist_id={$checklist_id}&amp;page_id={@page_id}">
									<xsl:value-of select="@title" />
								</a>
							</li>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$in = 'Questions'">
						<xsl:for-each select="question[@checklist_id = $checklist_id][gbc:match(@question,$q)]">
							<xsl:sort select="@sequence" data-type="number" />
							<li>
								<strong>Question: </strong>
								<a href="?page=checklists&amp;mode=question_edit&amp;checklist_id={$checklist_id}&amp;page_id={@page_id}&amp;question_id={@question_id}">
									<xsl:value-of select="@question" disable-output-escaping="yes" />
								</a>
							</li>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$in = 'Report Sections'">
						<xsl:for-each select="report_section[@checklist_id = $checklist_id][gbc:match(@title,$q) or gbc:match(@content,$q)]">
							<xsl:sort select="@sequence" data-type="number" />
							<li>
								<strong>Report Section: </strong>
								<a href="?page=checklists&amp;mode=report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={@report_section_id}">
									<xsl:value-of select="@title" />
								</a>
							</li>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$in = 'Actions'">
						<xsl:for-each select="action[@checklist_id = $checklist_id][gbc:match(@title,$q) or gbc:match(@key_title,$q) or gbc:match(@proposed_measuer,$q) or gbc:match(@comments,$q)]">
							<xsl:sort select="@sequence" data-type="number" />
							<li>
								<strong>Action: </strong>
								<a href="?page=checklists&amp;mode=action_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={@report_section_id}&amp;action_id={@action_id}">
									<xsl:value-of select="@title" />
								</a>
							</li>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$in = 'Primary ID'">
						<xsl:for-each select="*[@*[1] = $q]">
							<xsl:choose>
								<xsl:when test="name(.) = 'page'">
									<li>
										<strong>Page: </strong>
										<a href="?page=checklists&amp;mode=page_edit&amp;checklist_id={$checklist_id}&amp;page_id={@page_id}">
											<xsl:value-of select="@title" />
										</a>
									</li>
								</xsl:when>
								<xsl:when test="name(.) = 'question'">
									<li>
										<strong>Question: </strong>
										<a href="?page=checklists&amp;mode=question_edit&amp;checklist_id={$checklist_id}&amp;page_id={@page_id}&amp;question_id={@question_id}">
											<xsl:value-of select="@question" />
										</a>
									</li>
								</xsl:when>
								<xsl:when test="name(.) = 'answer'">
									<li>
										<strong>Answer: </strong>
										<a href="?page=checklists&amp;mode=answer_edit&amp;checklist_id={$checklist_id}&amp;&amp;page_id={../question[@question_id = current()/@question_id]/@page_id}&amp;question_id={@question_id}&amp;answer_id={@answer_id}">
											<xsl:value-of select="@answer_type" />
										</a>
									</li>
								</xsl:when>
								<xsl:when test="name(.) = 'action'">
									<li>
										<strong>Action: </strong>
										<a href="?page=checklists&amp;mode=action_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={@report_section_id}&amp;action_id={@action_id}">
											<xsl:value-of select="@title" />
										</a>
									</li>
								</xsl:when>
								<xsl:when test="name(.) = 'report_section'">
									<li>
										<strong>Report Section: </strong>
										<a href="?page=checklists&amp;mode=report_section_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={@report_section_id}">
											<xsl:value-of select="@title" />
										</a>
									</li>
								</xsl:when>
								<xsl:when test="name(.) = 'commitment'">
									<li>
										<strong>Commitment Option: </strong>
										<a href="?page=checklists&amp;mode=commitment_edit&amp;checklist_id={$checklist_id}&amp;report_section_id={../action[@action_id = current()/@action_id]/@report_section_id}&amp;action_id={@action_id}&amp;commitment_id={@commitment_id}">
											<xsl:value-of select="@commitment" />
										</a>
									</li>
								</xsl:when>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
			</ol>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>