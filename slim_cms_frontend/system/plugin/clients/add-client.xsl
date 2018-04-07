<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">

	<xsl:template match="/config/plugin[@plugin = 'clients'][@method = 'addClient']">

        <xsl:choose>
            <xsl:when test="success">
                <div class="col-md-12">
                    <div class="alert alert-success">
                        <p><strong>Success</strong></p>
                        <ul>
                            <xsl:for-each select="success/item">
                                <li>
                                    <xsl:value-of select="@message" disable-output-escaping="yes" />
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </div>
                <div class="col-md-12">
                    <a href="/members/add/" class="btn btn-base btn-icon btn-icon-right fa-plus">
                        <span>
                            <xsl:choose>    
                                <xsl:when test="@record_type">
                                    Add New <xsl:value-of select="@record_type" />
                                </xsl:when>
                                <xsl:otherwise>
                                    Add New Company
                                </xsl:otherwise>
                            </xsl:choose>                       
                        </span>
                    </a>                
                </div>
            </xsl:when>
            <xsl:when test="error">
                <div class="col-md-12">
                    <div class="alert alert-danger">
                        <p><strong>Error</strong></p>
                        <ul>
                            <xsl:for-each select="error/item">
                                <li>
                                    <xsl:value-of select="@message" />
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </div>
                <xsl:call-template name="add-client-form" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="add-client-form" />
            </xsl:otherwise>
        </xsl:choose>

	</xsl:template>

    <xsl:template name="add-client-form">
		<div class="col-md-12">
			<form method="post" action="" class="enquiry sky-form" autocomplete="off" data-parsley-validate="data-parsley-validate">
                <input type="hidden" name="action" value="addClient" />
				<input type="hidden" name="client_type_id" value="{/config/plugin[@plugin = 'clients'][@method = 'login']/@client_type_id}" />

				<div class="entry page row">

                    <div class="col-md-12">
                        <h4 class="form-section">
                            <xsl:choose>    
                                <xsl:when test="@record_type">
                                    <xsl:value-of select="@record_type" /> Details
                                </xsl:when>
                                <xsl:otherwise>
                                    Company Details
                                </xsl:otherwise>
                            </xsl:choose>   
                        </h4>
                    </div>

					<!-- //Row - Client Name -->
					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">
                                        <xsl:choose>    
                                            <xsl:when test="@record_type">
                                                <xsl:value-of select="@record_type" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                Company
                                            </xsl:otherwise>
                                        </xsl:choose>   
										<span class="entry question icon required fa fa-asterisk" />
									</label>
									<input type="text" name="company_name" data-parsley-required="required" class="form-control" value="{/config/globals/item[@key = 'company_name']/@value}" />
								</div>
							</div>
						</fieldset>
					</div>

					<xsl:if test="@clientRole = 'true' and count(client_roles/client_role) &gt; 0">
						<xsl:call-template name="clientRole" />
					</xsl:if>

					<xsl:if test="@address = 'true'">
						<xsl:call-template name="clientAddress" />			
					</xsl:if>              

                    <div class="col-md-12">
                        <h4 class="form-section">Contact Details</h4>
                    </div>

					<!-- //Row - Client Contact -->
					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-4">
									<label class="entry question-content">
										First Name
										<span class="entry question icon required fa fa-asterisk" />
									</label>
									<input type="text" name="firstname" data-parsley-required="required" class="form-control" value="{/config/globals/item[@key = 'firstname']/@value}" />
								</div>
								<div class="col-md-4">
									<label class="entry question-content">
										Last Name
										<span class="entry question icon required fa fa-asterisk" />
									</label>
									<input type="text" name="lastname" data-parsley-required="required" class="form-control" value="{/config/globals/item[@key = 'lastname']/@value}" />
								</div>
								<div class="col-md-4">
									<label class="entry question-content">
										Email
										<span class="entry question icon required fa fa-asterisk" />
									</label>
									<input type="email" name="email" data-parsley-required="required" class="form-control" value="{/config/globals/item[@key = 'email']/@value}" />
								</div>
							</div>
						</fieldset>
					</div>

					<!-- //Submit -->
					<div class="col-md-12">
						<div class="row">
							<div class="col-md-3">
								<a class="btn btn-base btn-icon btn-icon-right fa-plus btn-block submit-form-button" data-action="submit">
									<span>
                                        <xsl:choose>    
                                            <xsl:when test="@record_type">
                                                Save New <xsl:value-of select="@record_type" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                Save New Company
                                            </xsl:otherwise>
                                        </xsl:choose>   
                                    </span>
								</a>  
							</div>
						</div>
					</div>

                </div>
			</form>
		</div>        

    </xsl:template>

	<!-- //Row - Client Role -->
	<xsl:template name="clientRole">
		<div class="col-md-12">
			<h4 class="form-section">Role</h4>
		</div>

		<div class="col-md-12 question">
			<fieldset class="entry question">
				<div class="row">
					<div class="col-md-12">
						<label class="entry question-content">
							Role
							<span class="entry question icon required fa fa-asterisk" />
						</label>
						<select id="clientrole" name="clientrole">
							<option value="">-- Select --</option>
							<xsl:for-each select="client_roles/client_role">
								<xsl:sort select="@client_role" />
								<xsl:if test="@client_type_id=/config/plugin[@plugin = 'clients'][@method = 'addClient']/@client_type_id">
									<option value="{@client_role_id}">
										<xsl:value-of select="@client_role" />
									</option>
								</xsl:if>
							</xsl:for-each>
						</select>
					</div>
				</div>
			</fieldset>
		</div>
	</xsl:template>

	<!-- //Row - Client Address -->
	<xsl:template name="clientAddress">
		<div class="col-md-12 question">
			<fieldset class="entry question">
				<div class="row">
					<div class="col-md-6">
						<label class="entry question-content">
							Street Address
							<span class="entry question" />
						</label>
						<input type="text" name="address_line_1" class="form-control" value="{/config/globals/item[@key = 'address_line_1']/@value}" />
					</div>
					<div class="col-md-6">
						<label class="entry question-content">
							City
							<span class="entry question" />
						</label>
						<input type="text" name="suburb" class="form-control" value="{/config/globals/item[@key = 'suburb']/@value}"/>
					</div>
				</div>
			</fieldset>
		</div>
		<!-- //Row - Client Address 2 -->
		<div class="col-md-12 question">
			<fieldset class="entry question">
				<div class="row">
					<div class="col-md-4">
						<label class="entry question-content">
							State
							<span class="entry question" />
						</label>
						<input type="text" name="state" class="form-control" value="{/config/globals/item[@key = 'state']/@value}" />
					</div>
					<div class="col-md-4">
						<label class="entry question-content">
							Zip/Post Code
							<span class="entry question" />
						</label>
						<input type="text" name="postcode" class="form-control" value="{/config/globals/item[@key = 'postcode']/@value}" />
					</div>
					<div class="col-md-4">
						<label class="entry question-content">
							Country
							<span class="entry question" />
						</label>
						<div class="select drop-down-list">
							<select class="form-control chosen-select" name="country">
								<option value="">-- select --</option>
								<xsl:for-each select="countries/country">
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
	</xsl:template>

</xsl:stylesheet>