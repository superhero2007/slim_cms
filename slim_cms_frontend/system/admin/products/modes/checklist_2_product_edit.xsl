<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'checklist_2_product_edit']">
		<xsl:variable name="product" select="product[@product_id = current()/globals/item[@key = 'product_id']/@value]" />
		<xsl:variable name="checklist_2_product" select="checklist_2_product[@checklist_2_product_id = current()/globals/item[@key = 'checklist_2_product_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=products">Product List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=products&amp;mode=product_edit&amp;product_id={$product/@product_id}"><xsl:value-of select="$product/@name" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=products&amp;mode=checklist_2_product_edit&amp;product_id={$product/@product_id}&amp;checklist_2_product_id={$checklist_2_product/@checklist_2_product}">Add / Edit Assessment</a>
		</p>
		<h1>Add / Edit Assessment</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="checklist_2_product_save" />
			<input type="hidden" name="product_id" value="{$product/@product_id}" />
			<input type="hidden" name="checklist_2_product_id" value="{$checklist_2_product/@checklist_2_product_id}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Assessment" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="checklist-id">Assessment:</label></th>
						<td>
							<select id="checklist-id" name="checklist_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="checklist">
									<option value="{@checklist_id}">
										<xsl:if test="@checklist_id = $checklist_2_product/@checklist_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="checklist-variation-id">Variation:</label></th>
						<td>
							<select id="checklist-variation-id" name="checklist_variation_id">
								<option value="0">-- Select --</option>
								<xsl:for-each select="checklist_variation">
									<option value="{@checklist_variation_id}">
										<xsl:if test="@checklist_variation_id = $checklist_2_product/@checklist_variation_id"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<xsl:value-of select="@name" />
									</option>
								</xsl:for-each>
							</select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="checklists">No. of Assessments:</label></th>
						<td><input type="text" id="checklists" name="checklists" value="{$checklist_2_product/@checklists}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
	
</xsl:stylesheet>