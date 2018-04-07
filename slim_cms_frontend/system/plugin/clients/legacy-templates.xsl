<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">

	<xsl:template name="secure-legacy">
		<xsl:choose>
			<xsl:when test="/config/plugin[@plugin = 'clients'][@method = 'login']/client">
				<xsl:apply-templates select="*[name() != 'insecure']" mode="html" />
			</xsl:when>
			<xsl:otherwise>
				<!-- //Content for NRA -->
				<xsl:if test="/config/domain/@domain_id = '63'">
				
					<!-- //Custom Style for Home Page -->
					<style>
					#body {
							background-color: #427bb1;
					}

					#content {
						   padding-top:0px;
					}

					.body-background-image {
						   display:block;
					}
					</style>

					<div class="banner-container">
						<img src="/_images/nra/keyboard-hero.png" class="hero-image" style="right:-15%;"/>
						<h2>Login or Register</h2>
						<br /><br />
						<div class="question-panel">
							<p class="strong-blue">Are you concerned about your rising electricity costs?</p>
							<p class="strong-blue">Are you unsure of what you could be doing in your business to be more energy efficient?</p>
							<p class="strong-blue">Do you want access to information and workshops on energy efficiency in retail?</p>
						</div>
					</div>
					
					<div class="blue-highlight-panel">
						<p><img src="/_images/nra/register-now-button.png" class="register-now-button" />The NRA Retail Buys the Future web portal gives you access to assessment tools, a GHG Calculator and a variety of information resources relevant to your retail business.</p>
					</div>
					<br /><br />
				</xsl:if>
				<!-- // End NRA content -->
				<xsl:apply-templates select="insecure/*" mode="html" />
				
				<!-- //Display any logout/lockout messages -->
				<xsl:if test="/config/globals/item[@key = 'logout']">
					<div class="logout-message content-alert">
						<xsl:choose>
							<xsl:when test="/config/globals/item[@key = 'logout'][@value = 'session']">
								<p>Your session has been logged out because this account has logged on from another location.</p>
							</xsl:when>
							<xsl:when test="/config/globals/item[@key = 'logout'][@value = 'login-fail']">
								<p>This account has been locked due to multiple failed login attempts. Please try again later.</p>
							</xsl:when>
							<xsl:when test="/config/globals/item[@key = 'logout'][@value = 'locked']">
								<p>This account has been locked. Please try again later.</p>
							</xsl:when>
						</xsl:choose>
					</div>
				</xsl:if>
				
				<div class="left-half login-container">
					<h2>Login</h2>
					<xsl:call-template name="login-legacy" />
					
					<!-- //Content for BSA -->
					<xsl:if test="/config/domain/@domain_id = '82'">
						<br />
						<span class="red-alert">Please note: Your HealthCheck account is separate to your membership account, please register to use this service.</span>
					</xsl:if>
				</div>
				<div class="right-half register-container">
				
					<!-- //Display a different title for NSWBC -->
					<h2>Register</h2>
					<xsl:call-template name="register-legacy">
						<xsl:with-param name="client_type_id" select="@client_type_id" />
						<xsl:with-param name="product_id" select="@product_id" />
					</xsl:call-template>
				</div>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="login-legacy">
		<xsl:param name="node" select="/config/plugin[@plugin = 'clients'][@method = 'login'][@mode = 'login']" />
		
		<form method="post" action="" class="enquiry sky-form" autocomplete="off">
			<input type="hidden" name="action" value="login" />
			<fieldset>
				<xsl:choose>
					<xsl:when test="/config/domain/@domain_id = '82'">
						<legend>Service Login</legend>
					</xsl:when>
				</xsl:choose>
				<p>
					<label>
						<xsl:text>Email:</xsl:text>
						<span class="required">*</span>
						<xsl:apply-templates select="$node/error[@field = 'username']" /><br />
						<input type="text" name="username">
							<xsl:if test="$node">
								<xsl:attribute name="value">
									<xsl:choose>
										<xsl:when test="$node/alternativeAuthContact/@email"><xsl:value-of select="$node/alternativeAuthContact/@email"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="/config/globals/item[@key = 'username']/@value" /></xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</xsl:if>
						</input>
					</label>
				</p>
				<p>
					<label>
						<xsl:text>Password:</xsl:text>
						<span class="required">*</span>
						<xsl:apply-templates select="$node/error[@field = 'password']" /><br />
						<input type="password" name="password">
							<xsl:if test="$node">
								<xsl:attribute name="value">
									<xsl:value-of select="/config/globals/item[@key = 'password']/@value" />
								</xsl:attribute>
							</xsl:if>
						</input>
					</label>
				</p>
				<div style="line-height: 2em;">
					<input type="submit" value="Login" class="btn btn-primary" />	
				</div> 
				<p><a href="/password-recovery/">Forgotten your password?</a></p>
			</fieldset>
		</form>
	</xsl:template>

	
	<xsl:template name="register-legacy">
		<xsl:param name="client_type_id" />
		<xsl:param name="product_id" />
		<xsl:param name="node" select="/config/plugin[@plugin = 'clients'][@method = 'login'][@mode = 'register']" />
		
		<form method="post" action="" class="enquiry sky-form" autocomplete="off">
			<input type="hidden" name="action" value="register" />
			<input type="hidden" name="legacy" value="1" />

			<!-- //########################################################################################## -->
			<!-- //TODO: Remove hard coded domain names and use attribute based client_type_id and product_id -->
			<xsl:choose>
				<xsl:when test="/config/domain/@name = 'nra.retailbuysthefuture.com' or /config/domain/@name = 'nra.retailbuysthefuture.local'">
					<input type="hidden" name="client_type_id" value="13" />
					<input type="hidden" name="product_id" value="95" />
				</xsl:when>
				<xsl:when test="/config/domain/@name = 'socialenterpriseawards.greenbizcheck.com' or /config/domain/@name = 'socialenterpriseawards.greenbizcheck.local'">
					<input type="hidden" name="client_type_id" value="14" />
				</xsl:when>
				<xsl:when test="/config/domain/@name = 'mta.greenbizcheck.com' or /config/domain/@name = 'mta.greenbizcheck.local'">
					<input type="hidden" name="client_type_id" value="17" />
					<input type="hidden" name="product_id" value="102" />
				</xsl:when>
				<xsl:when test="/config/domain/@name = 'www.thesupplychaintracker.com' or /config/domain/@name = 'www.thesupplychaintracker.local'">
					<input type="hidden" name="client_type_id" value="18" />
				</xsl:when>
				<xsl:when test="/config/domain/@name = 'healthchecks.business-sa.com' or /config/domain/@name = 'business-sa.ipbiz.local'">
					<input type="hidden" name="client_type_id" value="25" />
					<input type="hidden" name="product_id" value="108" />
				</xsl:when>
				<xsl:when test="$client_type_id != ''">
					<input type="hidden" name="client_type_id" value="{$client_type_id}" />
				</xsl:when>
				<xsl:otherwise>
					<input type="hidden" name="client_type_id" value="1" />
				</xsl:otherwise>
			</xsl:choose>

			<!-- //Check the param and see if there is a valid product_id -->
			<xsl:choose>
				<xsl:when test="$product_id != ''">
					<input type="hidden" name="product_id" value="{$product_id}" />
				</xsl:when>
			</xsl:choose>	
			
			<fieldset>
				<legend>Login Details</legend>
				<p>
					<label>
						<xsl:text>Email:</xsl:text>
						<span class="required">*</span>
						<xsl:apply-templates select="$node/error[@field = 'email']" /><br />
						<input type="text" name="email">
							<xsl:if test="$node">
								<xsl:attribute name="value">
									<xsl:value-of select="/config/globals/item[@key = 'email']/@value" />
								</xsl:attribute>
							</xsl:if>
						</input>
					</label>
				</p>
				<p>
					<label>
						<xsl:text>Password:</xsl:text>
						<span class="required">*</span>
						<xsl:apply-templates select="$node/error[@field = 'password']" /><br />
						<input type="password" name="password" maxlengh="60">
							<xsl:if test="$node">
								<xsl:attribute name="value">
									<xsl:value-of select="/config/globals/item[@key = 'password']/@value" />
								</xsl:attribute>
							</xsl:if>
						</input>
					</label>
				</p>
				<p>
					<label>
						<xsl:text>Confirm password:</xsl:text>
						<span class="required">*</span>
						<xsl:apply-templates select="$node/error[@field = 'password_confirm']" /><br />
						<input type="password" name="password_confirm" maxlengh="60">
							<xsl:if test="$node">
								<xsl:attribute name="value">
									<xsl:value-of select="/config/globals/item[@key = 'password_confirm']/@value" />
								</xsl:attribute>
							</xsl:if>
						</input>
					</label>
					<br /><br />
					<small><strong>Your password must be between 8 and 60 characters and contain an upper case letter, a number and a non-alphanumeric character.</strong></small>
					
					<!-- //Content for BSA -->
					<xsl:if test="/config/domain/@domain_id = '82'">
						<br />
						<small><strong><a href="/help/#password-requirements">View example passwords</a></strong></small>
					</xsl:if>
				
				</p>
			</fieldset>
			<fieldset>
				<legend>Contact Details</legend>
				<p>
					<label>
						<xsl:text>First name:</xsl:text>
						<span class="required">*</span>
						<xsl:apply-templates select="$node/error[@field = 'firstname']" /><br />
						<input type="text" name="firstname">
							<xsl:if test="$node">
								<xsl:attribute name="value">
									<xsl:value-of select="/config/globals/item[@key = 'firstname']/@value" />
								</xsl:attribute>
							</xsl:if>
						</input>
					</label>
				</p>
				<p>
					<label>
						<xsl:text>Last name:</xsl:text>
						<span class="required">*</span>
						<xsl:apply-templates select="$node/error[@field = 'lastname']" /><br />
						<input type="text" name="lastname">
							<xsl:if test="$node">
								<xsl:attribute name="value">
									<xsl:value-of select="/config/globals/item[@key = 'lastname']/@value" />
								</xsl:attribute>
							</xsl:if>
						</input>
					</label>
				</p>
			</fieldset>
			<fieldset>
				<legend>Organisation Details</legend>
				<p>
					<label>
						<xsl:text>Organisation name:</xsl:text>
						<span class="required">*</span>
						<xsl:apply-templates select="$node/error[@field = 'company_name']" /><br />
						<input type="text" name="company_name">
							<xsl:if test="$node">
								<xsl:attribute name="value">
									<xsl:value-of select="/config/globals/item[@key = 'company_name']/@value" />
								</xsl:attribute>
							</xsl:if>
						</input>
					</label>
				</p>
				
				<!--// Added in street address lines -->
				<xsl:choose>
					<xsl:when test="(/config/domain[@name = 'business-sa.ipbiz.local']) or (/config/domain[@name = 'healthchecks.business-sa.net'])">
						<input type="hidden" name="address_line_1" value="" />
						<input type="hidden" name="address_line_2" value="" />
						<input type="hidden" name="suburb" value="" />
						<input type="hidden" name="state" value="" />
						<input type="hidden" name="postcode" value="" />
						<input type="hidden" name="country" value="Australia" />
					</xsl:when>
					<xsl:otherwise>
				
						<p>
							<label>
								<xsl:text>Address Line 1:</xsl:text>
								<span class="required">*</span>
								<xsl:apply-templates select="$node/error[@field = 'address_line_1']" /><br />
								<input type="text" name="address_line_1">
									<xsl:if test="$node">
										<xsl:attribute name="value">
											<xsl:value-of select="/config/globals/item[@key = 'address_line_1']/@value" />
										</xsl:attribute>
									</xsl:if>
								</input>
							</label>
						</p>
						<p>
							<label>
								<xsl:text>Address Line 2:</xsl:text><br />
								<input type="text" name="address_line_2">
									<xsl:if test="$node">
										<xsl:attribute name="value">
											<xsl:value-of select="/config/globals/item[@key = 'address_line_2']/@value" />
										</xsl:attribute>
									</xsl:if>
								</input>
							</label>
						</p>
				
						<p>
							<label>
								<xsl:text>City/Suburb:</xsl:text>
								<span class="required">*</span>
								<xsl:apply-templates select="$node/error[@field = 'suburb']" /><br />
								<input type="text" name="suburb">
									<xsl:if test="$node">
										<xsl:attribute name="value">
											<xsl:value-of select="/config/globals/item[@key = 'suburb']/@value" />
										</xsl:attribute>
									</xsl:if>
								</input>
							</label>
						</p>
						<p>
							<label>
								<xsl:text>State:</xsl:text>
								<span class="required">*</span>
								<xsl:apply-templates select="$node/error[@field = 'state']" /><br />
								<input type="text" name="state">
									<xsl:if test="$node">
										<xsl:attribute name="value">
											<xsl:value-of select="/config/globals/item[@key = 'state']/@value" />
										</xsl:attribute>
									</xsl:if>
								</input>
							</label>
						</p>
						<p>
							<label>
								<xsl:text>Post Code:</xsl:text>
								<span class="required">*</span>
								<xsl:apply-templates select="$node/error[@field = 'postcode']" /><br />
								<input type="text" name="postcode">
									<xsl:if test="$node">
										<xsl:attribute name="value">
											<xsl:value-of select="/config/globals/item[@key = 'postcode']/@value" />
										</xsl:attribute>
									</xsl:if>
								</input>
							</label>
						</p>
						<!-- //countries drop down box -->
						<xsl:variable name="countries" select="/config/plugin[@plugin = 'clients']/countries" />
						<p>
							<label>
								<xsl:text>Country:</xsl:text>
								<span class="required">*</span>
								<xsl:apply-templates select="$node/error[@field = 'country']" /><br />
								<label class="select">
									<select name="country" style="width: 97%;">
										<xsl:for-each select="$countries/country">
											<xsl:sort select="@name" />
											<option value="{@name}">
											<xsl:choose>
												<xsl:when test="$node">
													<xsl:if test="/config/globals/item[@key = 'country']/@value = @name">
														<xsl:attribute name="selected">selected</xsl:attribute>
													</xsl:if>
												</xsl:when>
												<xsl:otherwise>
													<xsl:if test="@name = 'Australia'">
														<xsl:attribute name="selected">selected</xsl:attribute>
													</xsl:if>
												</xsl:otherwise>
											</xsl:choose>
												<xsl:value-of select="@name" />
											</option>
										</xsl:for-each>
									</select>
									<i></i>
								</label>
							</label>
						</p>
					
					</xsl:otherwise>
				</xsl:choose>
				
				<!-- //Display a different title for BSA -->
				<xsl:if test="/config/domain/@domain_id = '82'">
					<p>
						<label>
							<xsl:text>Membership number:</xsl:text>
							<input type="text" name="membership_number">
								<xsl:if test="$node">
									<xsl:attribute name="value">
										<xsl:value-of select="/config/globals/item[@key = 'membership_number']/@value" />
									</xsl:attribute>
								</xsl:if>
							</input>
						</label>
					</p>
					
					<!-- //Hidden Field for client value -->
					<input type="hidden" name="client" value="bsa" />
				</xsl:if>
                
                <!-- //Agree to the service agreement -->
                <p>
                <label>
                	<xsl:if test="$node/error[@field = 'service_agreement']">
                    	<xsl:apply-templates select="$node/error[@field = 'service_agreement']" />
                    </xsl:if>
					
					<!-- //Some clients want to use 'terms' rather than service agreement -->
					<xsl:choose>
						<xsl:when test="/config/domain/@domain_id = '64'">
							<xsl:text>I have read, and agree to the </xsl:text><a href="/terms/" target="_blank">terms &amp; conditions</a><xsl:text>:</xsl:text>
							<span class="required">*</span>
                    		<input type="checkbox" name="service_agreement" value="1" style="width:25px" />
						</xsl:when>
						<xsl:when test="/config/domain/@domain_id = '63'">
							<a href="/privacy-statement/" target="_blank">privacy statement</a><xsl:text>:</xsl:text>
							<span class="required">*</span>
                    		<input type="checkbox" name="service_agreement" value="1" style="width:25px" />
						</xsl:when>
						<xsl:when test="/config/domain/@domain_id = '1'">
							<!-- //GreenBizCheck and EcoBizCheck domains -->
							<xsl:text>I have read, and agree to the </xsl:text><a href="/service-agreement/" target="_blank">service agreement</a><xsl:text>:</xsl:text>
							<span class="required">*</span>
                    		<input type="checkbox" name="service_agreement" value="1" style="width:25px" />
						</xsl:when>
						<xsl:otherwise>
							<input type="hidden" name="service_agreement" value="1" />
						</xsl:otherwise>
					</xsl:choose>
                </label>
                </p>
				
				<!-- //Add Image verification for the client login -->
				<p>
					<label>
						<xsl:text>Please enter the verification image:</xsl:text><span class="required">*</span>
						<xsl:apply-templates select="$node/error[@field = 'verificationCode']" /><br />
						<input type="text" name="verificationCode" id="verificationCode" style="width:25%;" />
						<xsl:text> </xsl:text><img src="/_images/imageVerification/getimage.php" height="26px" style="padding:0px; vertical-align:top;" />
					</label>
				</p>
				<p><input type="submit" value="Register" class="btn btn-primary" /></p>
			</fieldset>
		</form>
	</xsl:template>

</xsl:stylesheet>