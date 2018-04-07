<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">

	<!-- //Login Form -->
	<xsl:template name="login-form">
		<xsl:param name="node" select="/config/plugin[@plugin = 'clients'][@method = 'login'][@mode = 'login']" />

		<div class="col-md-12">
			<form method="post" action="" class="enquiry sky-form" autocomplete="off" data-parsley-validate="data-parsley-validate">
				<input type="hidden" name="action" value="login" />
				<div class="entry page row">
					<!-- //Row -->
					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">
										Email
										<span class="entry question icon required fa fa-asterisk" />
									</label>
									<input type="email" name="username" data-parsley-required="required" class="form-control" autocomplete="off" />
								</div>
							</div>
						</fieldset>
					</div>
					<!-- //Row -->
					<div class="col-md-12 question">
						<fieldset class="entry question">
							<div class="row">
								<div class="col-md-12">
									<label class="entry question-content">
										Password
										<span class="entry question icon required fa fa-asterisk" />
									</label>
									<input type="password" name="password" data-parsley-required="required" class="form-control" autocomplete="off" />
								</div>
							</div>
						</fieldset>
					</div>
					<!-- //Row -->
					<div class="col-md-12 question">
						<div class="row">
							<div class="col-md-12">
								<button type="submit" class="btn btn-primary btn-base btn-icon btn-icon-right fa-unlock submit-form-button">
									<span>Login</span>
								</button>                            
							</div>
						</div>
					</div>
					<!-- //Row -->
					<div class="col-md-12 question">
						<div class="row margin-top-10">
							<div class="col-md-12 password-recovery">
								<a href="/password-recovery/">Forgot your password?</a>
							</div>
						</div>
					</div>
				</div>
			</form>
		</div>
	</xsl:template>

</xsl:stylesheet>