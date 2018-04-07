<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:gbc="http://www.greenbizcheck.com/xsl"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:func="http://exslt.org/functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="func"
	exclude-result-prefixes="gbc">
	
	<xsl:template match="config[@mode = 'metric_edit']">
		<xsl:variable name="page" select="page[@page_id = current()/globals/item[@key = 'page_id']/@value]" />
		<xsl:variable name="metric_group" select="metric_group[@metric_group_id = current()/globals/item[@key = 'metric_group_id']/@value]" />
		<xsl:variable name="metric" select="metric[@metric_id = current()/globals/item[@key = 'metric_id']/@value]" />
		<xsl:call-template name="menu" />
		<p id="breadcrumb">
			<xsl:text>You are here: </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=checklist_edit">Checklist Details</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_list">Page List</a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=page_edit&amp;page_id={$page/@page_id}"><xsl:value-of select="$page/@title" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=metric_group_edit&amp;page_id={$page/@page_id}&amp;metric_group_id={$metric_group/@metric_group_id}">Edit Metric Group: <xsl:value-of select="$metric_group/@name" /></a>
			<xsl:text> &gt; </xsl:text>
			<a href="?page=checklists&amp;checklist_id={$checklist_id}&amp;mode=metric_edit&amp;page_id={$page/@page_id}&amp;metric_group_id={$metric_group/@metric_group_id}&amp;metric_id={$metric/@metric_id}">
				<xsl:choose>
					<xsl:when test="$metric">Edit Metric: <xsl:value-of select="$metric/@metric" /></xsl:when>
					<xsl:otherwise>Add Metric</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<h1>Add / Edit Metric</h1>
		<form method="post" action="">
			<input type="hidden" name="action" value="metric_save" />
			<input type="hidden" name="checklist_id" value="{$checklist_id}" />
			<input type="hidden" name="page_id" value="{$page/@page_id}" />
			<input type="hidden" name="metric_group_id" value="{$metric_group/@metric_group_id}" />
			<input type="hidden" name="metric_id" value="{$metric/@metric_id}" />
			<input type="hidden" name="sequence" value="{$metric/@sequence}" />
			<table class="editTable">
				<tfoot>
					<tr>
						<th colspan="2"><input type="submit" value="Save Metric" /></th>
					</tr>
				</tfoot>
				<tbody>
					<tr>
						<th scope="row"><label for="metric">Metric:</label></th>
						<td><input type="text" id="metric" name="metric" value="{$metric/@metric}" /></td>
					</tr>
					<tr>
						<th scope="row">Unit Types:</th>
						<td>
							<table>
								<tr>
									<td scope="col">ID</td>
									<td scope="col">Unit</td>
									<td scope="col">Description</td>
									<td scope="col">Default</td>
									<td scope="col">Conversion (to default)</td>
								</tr>

								<xsl:for-each select="metric_unit_type">
									<xsl:variable name="conversion">
										<xsl:choose>
											<xsl:when test="../metric_unit_type_2_metric[@metric_id = $metric/@metric_id][@metric_unit_type_id = current()/@metric_unit_type_id]/@conversion &gt; 0">
												<xsl:value-of select="../metric_unit_type_2_metric[@metric_id = $metric/@metric_id][@metric_unit_type_id = current()/@metric_unit_type_id]/@conversion" />
											</xsl:when>
											<xsl:otherwise>0</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>

									<tr>
										<td>
											<label>								
												<xsl:value-of select="@metric_unit_type_id" />
											</label>
										</td>
										<td>
											<label>								
												<input type="checkbox" name="metric_unit_type[]" value="{@metric_unit_type_id}">
													<xsl:if test="../metric_unit_type_2_metric[@metric_id = $metric/@metric_id][@metric_unit_type_id = current()/@metric_unit_type_id]">
														<xsl:attribute name="checked">checked</xsl:attribute>
													</xsl:if>
												</input>
												<xsl:value-of select="@metric_unit_type" disable-output-escaping="yes" />
											</label>
										</td>
										<td>
											<label>								
												<xsl:value-of select="@description" />
											</label>
										</td>
										<td>
											<label>								
												<input type="radio" name="default_metric_unit_type" value="{@metric_unit_type_id}">
													<xsl:if test="../metric_unit_type_2_metric[@metric_id = $metric/@metric_id][@metric_unit_type_id = current()/@metric_unit_type_id]/@default = '1'">
														<xsl:attribute name="checked">checked</xsl:attribute>
													</xsl:if>
												</input>
											</label>
										</td>
										<td>
											<label>
												<input type="number" step="any" name="metric_unit_conversion[{@metric_unit_type_id}]" value="{$conversion}" />
											</label>
										</td>
									</tr>
								</xsl:for-each>								
							</table>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="help">Help Content:</label></th>
						<td>
							<textarea id="help" name="help" rows="5">
								<xsl:value-of select="$metric/@help" />
							</textarea>
						</td>
					</tr>
					<tr>
						<th scope="row">Required:</th>
						<td>
							<input type="hidden" name="required" value="0" />
							<label>
								<input type="checkbox" id="required" name="required" value="1">
									<xsl:if test="$metric/@required = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
								</input>
								<xsl:text> Yes</xsl:text>
							</label>
						</td>
					</tr>
       				<tr>
						<th scope="row">Maximum Duration (Months):</th>
						<td>							
                            <select name="max_duration">
                                <option value="12">
                                    <xsl:choose>
                                        <xsl:when test="$metric">
                                            <xsl:if test="$metric/@max_duration = 12">
                                                <xsl:attribute name="SELECTED">SELECTED</xsl:attribute>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="SELECTED">SELECTED</xsl:attribute>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text>12 Months</xsl:text>
                                </option>
                                <option value="3">
                                    <xsl:if test="$metric/@max_duration = 3">
                                        <xsl:attribute name="SELECTED">SELECTED</xsl:attribute>
                                    </xsl:if>
                                    <xsl:text>3 Months</xsl:text>
                                </option>
                                <option value="1">
                                    <xsl:if test="$metric/@max_duration = 1">
                                        <xsl:attribute name="SELECTED">SELECTED</xsl:attribute>
                                    </xsl:if>
                                    <xsl:text>1 Month</xsl:text>
                                </option>
                            </select>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="max-variation">Maximum Variation (%):</label></th>
						<td>
							<input name="max_variation" type="number" step="any" value="{$metric/@max_variation}" />
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</xsl:template>
</xsl:stylesheet>