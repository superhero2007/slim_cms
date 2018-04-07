<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">
	
	<xsl:template match="/config/plugin[@plugin = 'form'][@method = 'contactForm']">
		<form method="post" action="" class="enquiry">
			<input type="hidden" name="action" value="enquire" />	
			<div class="col-md-6 col-sm-6">
				<table width="100%">
					<tr>
						<td>
							<label>
								<xsl:text>Name:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'name']" /></span>
								<input type="text" id="contact-name" name="name" value="{/config/globals/item[@key = 'name']/@value}" tabindex="1" />
							</label>
						</td>
					</tr>
					<tr>
						<td>
							<label>
								<xsl:text>Email:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'email']" /></span><br />
								<input type="text" id="contact-email" name="email" value="{/config/globals/item[@key = 'email']/@value}" tabindex="2" />
							</label>
						</td>
					</tr>
					<tr>
						<td>
							<label>
								<xsl:text>Phone:</xsl:text><xsl:apply-templates select="error[@field = 'phone']" /><br />
								<input type="text" id="contact-phone" name="phone" value="{/config/globals/item[@key = 'phone']/@value}" tabindex="3" />
							</label>
						</td>
					</tr>
					<tr>
						<td>
							<label>
								<xsl:text>Location:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'location']" /></span><br />
								<input type="text" id="location" name="location" value="{/config/globals/item[@key = 'location']/@value}" tabindex="4" />
							</label>
						</td>
					</tr>
					<tr>
						<td>
							<label>
								<xsl:text>Company:</xsl:text><xsl:apply-templates select="error[@field = 'company']" /><br />
								<input type="text" id="contact-company" name="company" value="{/config/globals/item[@key = 'company']/@value}" tabindex="5" />
							</label>
						</td>
					</tr>
				</table>
			</div>
			<div class="col-md-6 col-sm-6">
				<table width="100%">
					<tr>
						<td>
							<label>
								<xsl:text>Message:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'message']" /></span><br />
								<textarea id="contact-message" name="message" rows="7" cols="30" style="width:100%" tabindex="6"><xsl:value-of select="/config/globals/item[@key = 'message']/@value" /></textarea>
							</label>

							<!-- //Add Image verification for the web form -->
							<br />
							<label>
								<xsl:text>Please enter the verification image:</xsl:text>
								<span class="required">*<xsl:apply-templates select="error[@field = 'verificationCode']" /></span><br />
								<input type="text" name="verificationCode" id="verificationCode" style="width:25%;" />
								<xsl:text> </xsl:text><img src="/_images/imageVerification/getimage.php" height="26px" style="padding:0px; vertical-align:top;" />
								<input type="submit" value="Send Enquiry" style="float:right; margin-top:5px;" tabindex="7"/>
							</label>
						</td>
					</tr>
				</table>
			</div>
		</form>
		<br class="clear" />
	</xsl:template>
	
	<!-- //NRA Contact Form -->
	<xsl:template match="/config/plugin[@plugin = 'form'][@method = 'nraContactForm']">
		<form method="post" action="" class="enquiry">
			<input type="hidden" name="action" value="enquire" />	
			<table width="100%">
				<tr>
					<td>
						<label>
							<xsl:text>Name:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'name']" /></span>
							<input type="text" id="contact-name" name="name" value="{/config/globals/item[@key = 'name']/@value}" tabindex="1" />
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<label>
							<xsl:text>Email:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'email']" /></span><br />
							<input type="text" id="contact-email" name="email" value="{/config/globals/item[@key = 'email']/@value}" tabindex="2" />
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<label>
							<xsl:text>Phone:</xsl:text><xsl:apply-templates select="error[@field = 'phone']" /><br />
							<input type="text" id="contact-phone" name="phone" value="{/config/globals/item[@key = 'phone']/@value}" tabindex="3" />
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<label>
							<xsl:text>Location:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'location']" /></span><br />
							<input type="text" id="location" name="location" value="{/config/globals/item[@key = 'location']/@value}" tabindex="4" />
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<label>
							<xsl:text>Company:</xsl:text><xsl:apply-templates select="error[@field = 'company']" /><br />
							<input type="text" id="contact-company" name="company" value="{/config/globals/item[@key = 'company']/@value}" tabindex="5" />
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<label>
							<xsl:text>Message:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'message']" /></span><br />
							<textarea id="contact-message" name="message" rows="7" cols="30" style="width:100%" tabindex="6"><xsl:value-of select="/config/globals/item[@key = 'message']/@value" /></textarea>
						</label>

						<!-- //Add Image verification for the web form -->
						<br />
						<label>
							<xsl:text>Please enter the verification image:</xsl:text>
							<span class="required">*<xsl:apply-templates select="error[@field = 'verificationCode']" /></span><br />
							<input type="text" name="verificationCode" id="verificationCode" style="width:25%;" />
							<xsl:text> </xsl:text><img src="/_images/imageVerification/getimage.php" height="26px" style="padding:0px; vertical-align:top;" />
							<input type="submit" value="Send Enquiry" style="float:right; margin-top:5px;" tabindex="7"/>
						</label>
					</td>
				</tr>
			</table>
		</form>
	</xsl:template>
	
	<!--//Franchise Info Form -->
	<xsl:template match="/config/plugin[@plugin = 'form'][@method = 'franchiseForm']">
		<form method="post" action="" class="enquiry">
			<input type="hidden" name="action" value="franchiseInfo" />	
			<table width="100%" class="franchise-enquiry">
				<tr>
					<td>
						<label>
							<xsl:text>First Name:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'first-name']" /></span>
							<input type="text" id="contact-first-name" name="first-name" value="{/config/globals/item[@key = 'first-name']/@value}" tabindex="1" />
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<label>
							<xsl:text>Last Name:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'last-name']" /></span>
							<input type="text" id="contact-last-name" name="last-name" value="{/config/globals/item[@key = 'last-name']/@value}" tabindex="2" />
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<label>
							<xsl:text>Location:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'location']" /></span><br />
							<input type="text" id="location" name="location" value="{/config/globals/item[@key = 'location']/@value}" tabindex="3" />
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<label>
							<xsl:text>Email:</xsl:text><span class="required">* <xsl:apply-templates select="error[@field = 'email']" /></span><br />
							<input type="text" id="contact-email" name="email" value="{/config/globals/item[@key = 'email']/@value}" tabindex="4" />
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<label>
							<xsl:text>Phone:</xsl:text><xsl:apply-templates select="error[@field = 'phone']" /><br />
							<input type="text" id="contact-phone" name="phone" value="{/config/globals/item[@key = 'phone']/@value}" tabindex="5" />
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<label>
							<xsl:text>Prefered Method of Contact:</xsl:text><xsl:apply-templates select="error[@field = 'preferred-contact']" /><br />
							<select name="preferred-contact" id="preferred-contact" tabindex="6">
								<option value="Phone">
									<xsl:if test="/config/globals/item[@key = 'phone']/@value = 'Phone'">
										<xsl:attribute name="SELECTED">SELECTED</xsl:attribute>
									</xsl:if>
									<xsl:text>Phone</xsl:text>
								</option>
								<option value="Email">
									<xsl:if test="/config/globals/item[@key = 'email']/@value = 'Email'">
										<xsl:attribute name="SELECTED">SELECTED</xsl:attribute>
									</xsl:if>
									<xsl:text>Email</xsl:text>
								</option>
							</select>
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<label>
							<xsl:text>Preferred Time of Contact:</xsl:text><xsl:apply-templates select="error[@field = 'preferred-time']" /><br />
							<input type="text" id="contact-preferred-time" name="preferred-time" value="{/config/globals/item[@key = 'preferred-time']/@value}" tabindex="7" />
						</label>
					</td>
				</tr>
				<tr>
					<td>
						<!-- //Add Image verification for the web form -->
						<label>
							<xsl:text>Please enter the verification image:</xsl:text>
							<span class="required">*<xsl:apply-templates select="error[@field = 'verificationCode']" /></span><br />
							<input type="text" name="verificationCode" id="verificationCode" style="width:25%;" tabindex="8" />
							<xsl:text> </xsl:text><img src="/_images/imageVerification/getimage.php" height="26px" style="padding:0px; vertical-align:top;" />
							<input type="submit" value="Send Enquiry" style="float:right; margin-top:5px;" tabindex="9"/>
						</label>
					</td>
				</tr>
			</table>
		</form>
	</xsl:template>
	
	<xsl:template match="/config/plugin[@plugin = 'form']/error">
		<span class="error">
			<xsl:text> </xsl:text>
			<xsl:value-of select="." />
		</span>
	</xsl:template>
	
</xsl:stylesheet>