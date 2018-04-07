<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">

	<!-- //Register Form -->
	<xsl:template name="register-form">
		<xsl:variable name="client_type_id" select="/config/plugin[@plugin = 'clients'][@method = 'login']/@client_type_id" />
		<xsl:variable name="product_id" select="/config/plugin[@plugin = 'clients'][@method = 'login']/@product_id" />

		<div class="col-md-12">

			<form method="post" action="" class="enquiry sky-form" autocomplete="off" data-parsley-validate="data-parsley-validate">

				<!-- //Hidden Fields -->
				<!-- //Action -->
				<input type="hidden" name="action" value="register" />

				<!-- //Product ID -->
				<xsl:if test="$product_id != ''">
					<input type="hidden" name="product_id" value="{$product_id}" />
				</xsl:if>

				<!-- //Client Type ID -->
				<xsl:if test="$client_type_id != ''">
					<input type="hidden" name="client_type_id" value="{$client_type_id}" />
				</xsl:if>

				<div class="entry page row">

					<!-- //Row -->
					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-6">
									<label class="entry question-content">
										First Name
										<span class="entry question icon required fa fa-asterisk" />
									</label>
									<input type="text" name="firstname" data-parsley-required="required" class="form-control" value="{/config/globals/item[@key = 'firstname']/@value}" />
								</div>
								<div class="col-md-6">
									<label class="entry question-content">
										Last Name
										<span class="entry question icon required fa fa-asterisk" />
									</label>
									<input type="text" name="lastname" data-parsley-required="required" class="form-control" value="{/config/globals/item[@key = 'lastname']/@value}" />
								</div>
							</div>
						</fieldset>
					</div>
					<!-- //Row -->
					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-6">
									<label class="entry question-content">
										Email
										<span class="entry question icon required fa fa-asterisk" />
									</label>
									<input type="email" name="email" data-parsley-required="required" class="form-control" value="{/config/globals/item[@key = 'email']/@value}" />
								</div>
								<div class="col-md-6">
									<label class="entry question-content">
										Company
										<span class="entry question icon required fa fa-asterisk" />
									</label>
									<input type="text" name="company_name" data-parsley-required="required" class="form-control" value="{/config/globals/item[@key = 'company_name']/@value}" />
								</div>
							</div>
						</fieldset>
					</div>
					<!-- //Row -->
					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-6">
									<label class="entry question-content">
										Password
										<span class="entry question icon required fa fa-asterisk" />
										<span class="entry question icon information fa fa-info-circle" title="Information" data-container="body" data-toggle="popover" data-trigger="hover" data-placement="auto top" data-content="Password must be between 8 and 60 characters and contain an upper case letter, a number and a non-alphanumeric character."/>
									</label>
									<input type="password" name="password" id="password" data-parsley-required="required" class="form-control" />
								</div>
								<div class="col-md-6">
									<label class="entry question-content">
										Confirm Password
										<span class="entry question icon required fa fa-asterisk" />
										<span class="entry question icon information fa fa-info-circle" title="Information" data-container="body" data-toggle="popover" data-trigger="hover" data-placement="auto top" data-content="Password must be between 8 and 60 characters and contain an upper case letter, a number and a non-alphanumeric character."/>
									</label>
									<input type="password" name="password_confirm" id="password_confirm" data-parsley-required="required" data-parsley-equalto="#password" class="form-control" />
								</div>
							</div>
						</fieldset>
					</div>
					<!-- //Row -->
					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-6">
									<input type="text" name="address_line_1" class="form-control" placeholder="Street Address" value="{/config/globals/item[@key = 'address_line_1']/@value}" />
								</div>
								<div class="col-md-6">
									<input type="text" name="suburb" class="form-control" placeholder="City" value="{/config/globals/item[@key = 'suburb']/@value}"/>
								</div>
							</div>
						</fieldset>
					</div>
					<!-- //Row -->
					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-4">
									<input type="text" name="state" class="form-control" placeholder="State" value="{/config/globals/item[@key = 'state']/@value}" />
								</div>
								<div class="col-md-4">
									<input type="text" name="postcode" class="form-control" placeholder="Zip/Post Code" value="{/config/globals/item[@key = 'postcode']/@value}" />
								</div>
								<div class="col-md-4">
									<xsl:variable name="countries" select="/config/plugin[@plugin = 'clients']/countries" />
									<div class="select drop-down-list">
										<select class="form-control" name="country">
											<option value="" disabled="disabled" selected="selected">Country</option>
											<xsl:for-each select="$countries/country">
												<xsl:sort select="@name" />
												<option value="{@name}">
													<xsl:if test="/config/globals/item[@key = 'country']/@value = @name">
														<xsl:attribute name="selected">selected</xsl:attribute>
													</xsl:if>
													<xsl:value-of select="@name" />
												</option>
											</xsl:for-each>
										</select>
										<i></i>
									</div>
								</div>
							</div>
						</fieldset>
					</div>

					<!-- //Row -->
					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<div class="g-recaptcha" data-sitekey="6Lc9iSITAAAAAL1_EFqrlSVQxu6_3cUtMW3pPG9u"></div>
								</div>
							</div>
						</fieldset>
					</div>
					
					<!-- //Row -->
					<div class="col-md-12 question">
						<div class="row">
							<div class="col-sm-12">
								<!--<button type="submit" class="g-recaptcha btn btn-base btn-icon btn-icon-right fa-paper-plane submit-form-button" data-sitekey="6LfMAxkUAAAAAHxTpQGKFvOjzbGLMWbmOpohdztk" data-callback="">-->
									<button type="submit" class="btn btn-base btn-icon btn-icon-right fa-paper-plane submit-form-button">
									<span>Register</span>
								</button>                            
							</div>
						</div>
					</div>
				</div>
			</form>
		</div>

	</xsl:template>

</xsl:stylesheet>