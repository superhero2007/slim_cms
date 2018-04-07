<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'form_group_edit']">
		<xsl:variable name="page" select="page[@page_id = current()/globals/item[@key = 'page_id']/@value]" />
		<xsl:variable name="form_group" select="form_group[@form_group_id = current()/globals/item[@key = 'form_group_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=checklist_edit">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_list">Page List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_edit&amp;page_id={$page/@page_id}"><xsl:value-of select="$page/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=form_group_edit&amp;page_id={$page/@page_id}&amp;form_group_id={$form_group/@form_group_id}">
				<xsl:choose>
					<xsl:when test="$form_group">Edit Form Group: <xsl:value-of select="$form_group/@name" /></xsl:when>
					<xsl:otherwise>Add Form Group</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Form Group</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="form_group_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="page_id" value="{$page/@page_id}" />
			<input type="hidden" name="form_group_id" value="{$form_group/@form_group_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Form Group" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="name">Name:</label></th>
						<td><input type="text" id="name" name="name" value="{$form_group/@name}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="name">Description:</label></th>
						<td>
                            <textarea name="description"><xsl:value-of select="$form_group/@description" /></textarea>
                        </td>
					</tr>
                    <tr>
                        <th scope="row"><label for="repeatable">Repeatable:</label></th>
                        <td>
                            <input type="hidden" name="repeatable" value="0" /> 
                            <input type="checkbox" name="repeatable" value="1">
                                <xsl:if test="$form_group/@repeatable = '1'">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input>
                            <xsl:text>Yes</xsl:text>
                        </td>
                    </tr>
                    <tr>
                        <th scope="row"><label for="sortable">Sortable:</label></th>
                        <td>
                            <input type="hidden" name="sortable" value="0" /> 
                            <input type="checkbox" name="sortable" value="1">
                                <xsl:if test="$form_group/@sortable = '1'">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input>
                            <xsl:text>Yes</xsl:text>
                        </td>
                    </tr>
                    <tr>
                        <th scope="row"><label for="show_order">Show Sort Order:</label></th>
                        <td>
                            <input type="hidden" name="show_order" value="0" /> 
                            <input type="checkbox" name="show_order" value="1">
                                <xsl:if test="$form_group/@show_order = '1'">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input>
                            <xsl:text>Yes</xsl:text>
                        </td>
                    </tr>
					<tr>
						<th scope="row"><label for="name">Minimum Rows:</label></th>
						<td><input type="number" step="1" id="min_rows" name="min_rows" value="{$form_group/@min_rows}" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="name">Maximum Rows:</label></th>
						<td><input type="number" step="1" id="max_rows" name="max_rows" value="{$form_group/@max_rows}" /></td>
					</tr>
                    <tr>
                        <th scope="row"><label for="repeat_question">Repeat Question:</label></th>
                        <td>
                            <input type="hidden" name="repeat_question" value="0" /> 
                            <input type="checkbox" name="repeat_question" value="1">
                                <xsl:if test="$form_group/@repeat_question = '1'">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input>
                            <xsl:text>Yes</xsl:text>
                        </td>
                    </tr>
					<tr>
						<th scope="row"><label for="css_class">CSS Class:</label></th>
						<td><input type="text" id="css_class" name="css_class" value="{$form_group/@css_class}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
		<h1>Questions</h1>
		<table id="table-question-list">
			<thead>
				<tr>
					<th scope="col">Question</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="question[@form_group_id = $form_group/@form_group_id]">
				<xsl:sort select="@sequence" data-type="number" />
					<tr>
						<td>
							<xsl:value-of select="@question" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=question_edit&amp;checklist_id={$checklist_id}&amp;page_id={$page/@page_id}&amp;question_id={@question_id}" title="Edit Question">edit</a>
							</span>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		
	</xsl:template>
</xsl:stylesheet>