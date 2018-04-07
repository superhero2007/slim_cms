<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="/config/plugin[@plugin = 'contacts'][@method = 'contactList']">
	
		<!-- //Get the locator tool -->
		<xsl:call-template name="locator" />
	
		<xsl:for-each select="country">
			<xsl:sort select="@country" data-type="text" />
			<h3><xsl:value-of select="@country" /></h3>
				<xsl:for-each select="region">
				<xsl:sort select="@region" data-type="text" />
				<xsl:if test="@region != ''">
					<h3  style="margin-left: 10px;"><xsl:value-of select="@region" /></h3>
				</xsl:if>
				<xsl:for-each select="city[@city != '']">
					<xsl:sort select="@city" data-type="text" />
						<p style="margin-left: 10px;"><strong><xsl:value-of select="@city" /></strong></p>
							<xsl:for-each select="associate">
								<xsl:sort select="@lastname" data-type="text" />
								<xsl:sort select="@firstname" data-type="text" />
								
								<table class="contact-list">
									<tr>
										<td width="10%" height="34px"><span class="highlight">Name:</span></td>
										<td width="60%"><xsl:value-of select="concat(@firstname,' ',@lastname)" /></td>
										<td width="30%" rowspan="4">
											<xsl:choose>
												<xsl:when test="@photo = 'yes'">
													<img src="/_images/partners/business_owner_contact_{@client_contact_id}.gif" alt="{concat(@firstname,' ',@lastname)} - GreenBizCheck {@city}" width="100" height="138" />
												</xsl:when>
												<xsl:otherwise>
													<img src="/_images/people/no-image.png" alt="{concat(@firstname,' ',@lastname)} - GreenBizCheck {@city}" width="100" height="138" />
												</xsl:otherwise>
											</xsl:choose>
										</td>
									</tr>
									<tr>
										<td height="34px"><span class="highlight">Email:</span></td>
										<td><a href="mailto:{@email}"><xsl:value-of select="@email" /></a></td>
									</tr>
									<tr>
										<td height="34px"><span class="highlight">Phone:</span></td>
										<td><xsl:value-of select="@phone" /></td>
									</tr>
									
									<xsl:if test="@url != ''">
										<tr>
											<td height="34px" colspan="2">
												<a href="{@url}">more...</a>
											</td>
										</tr>
									</xsl:if>
								</table>
							</xsl:for-each>
							<br class="clear" />
							<hr />
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="locator">
		<div class="contactLocator">
			<a name="locator" />
			<h3>Locate your closest GreenBizCheck contact</h3>
			<p>Enter your suburb by name</p>
			<form method="post" action="#locator">
				<input type="text" id="client_location" name="client_location" value="{query/@client_location}" style="width:250px;" />
				<input type="hidden" id="city-id" name="city_id" value="{query/@city_id}" />
				<input type="hidden" id="action" name="action" value="locator" />
				<input type="submit" value="search" />
			</form>
		</div>
		
		<script type="text/javascript">
			$().ready(function() {
				$("#client_location").autocomplete('/_ajax/cities.php', {
					autoFill: true
				}).result(function(event, row) {
				  $("#city-id").attr('value',row[1]);
				});	
			});
		</script>
	</xsl:template>
	
</xsl:stylesheet>