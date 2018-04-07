<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">
	
	<xsl:template match="/config/plugin[@plugin = 'stamps'][@method = 'renderAllowedStamps']">
		<xsl:param name="node" select="/config/plugin[@plugin = 'stamps'][@method = 'renderAllowedStamps']" />
        	<xsl:for-each select="clientChecklist">
            	<p>
        			<table class="tablesorter" id="renderAllowedStamps">
        				<thead>
        					<tr>
        						<th style="width: 200px;" ><strong><xsl:value-of select="@name" /></strong></th>
            					<th style="width: 200px;" ><strong>Size</strong></th>
            					<th><strong>HTML Code</strong></th>
        					</tr>
            			</thead>
						<tbody>
							<tr>
								<td style="text-align: center;" ><img src="/stamp/?cclid={@client_checklist_id}&amp;w=88" /></td>
								<td>
                                	<strong>88x88 pixels</strong><br />
                                    <a href="/stamp/?cclid={@client_checklist_id}&amp;w=88">Download PNG</a> (Transparent)
                                </td>
								<td>
                                	<textarea rows="5" cols="45" style="width: 100%;" readonly="readonly">&lt;a href="http://www.greenbizcheck.com/"&gt;&lt;img src="http://www.greenbizcheck.com/stamp/?cclid=<xsl:value-of select="@client_checklist_id" />&amp;w=88" alt="GreenBizCheck Certification In Progress" style="border: none;" /&gt;&lt;/a&gt;</textarea>
                                </td>
							</tr>
                            <tr>
								<td style="text-align: center;" ><img src="/stamp/?cclid={@client_checklist_id}&amp;w=125" /></td>
								<td>
                                	<strong>125x125 pixels</strong><br />
                                    <a href="/stamp/?cclid={@client_checklist_id}&amp;w=125">Download PNG</a> (Transparent)
                                </td>
								<td>
                                	<textarea rows="5" cols="45" style="width: 100%;" readonly="readonly">&lt;a href="http://www.greenbizcheck.com/"&gt;&lt;img src="http://www.greenbizcheck.com/stamp/?cclid=<xsl:value-of select="@client_checklist_id" />&amp;w=125" alt="GreenBizCheck Certification In Progress" style="border: none;" /&gt;&lt;/a&gt;</textarea>
                                </td>
							</tr>
                            <tr>
								<td style="text-align: center;" ></td>
								<td>
                                	<strong>400x400 pixels</strong><br />
                                    <a href="/stamp/?cclid={@client_checklist_id}&amp;w=400">Download PNG</a> (Transparent)
                                </td>
								<td>
                                	<textarea rows="5" cols="45" style="width: 100%;" readonly="readonly">&lt;a href="http://www.greenbizcheck.com/"&gt;&lt;img src="http://www.greenbizcheck.com/stamp/?cclid=<xsl:value-of select="@client_checklist_id" />&amp;w=400" alt="GreenBizCheck Certification In Progress" style="border: none;" /&gt;&lt;/a&gt;</textarea>
                                </td>
							</tr>
            		</tbody>
				</table>
        	</p>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>