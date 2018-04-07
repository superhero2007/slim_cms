<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'variation_list']">
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;mode=variation_list">Variation List</a>
		</p>
		<h1>Variation List</h1>
		<table>
			<thead>
				<tr>
					<th scope="col">Name</th>
					<th scope="col">No. of Client Assessments</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="2"><input type="button" value="Create New Variation" onclick="document.location = '?page=checklists&amp;mode=variation_edit';" /></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:for-each select="checklist_variation">
					<tr>
						<td>
							<xsl:value-of select="@name" />
							<br />
							<span class="options">
								<a href="?page=checklists&amp;mode=variation_edit&amp;checklist_variation_id={@checklist_variation_id}">edit</a>
								<xsl:text> | </xsl:text>
								<a href="?page=checklists&amp;action=checklist_variation_delete&amp;checklist_variation_id={@checklist_variation_id}" onclick="return(confirm('Do you really want to delete the \'{@name}\' variation?'))">delete</a>
							</span>
						</td>
						<td><xsl:value-of select="@num_clients" /></td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
</xsl:stylesheet>