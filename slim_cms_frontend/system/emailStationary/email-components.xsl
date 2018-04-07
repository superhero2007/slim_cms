<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- //Generic GBC Email Template Signature -->
	<xsl:template name="gbc-generic-email-signature">

		<p>All the best.</p>
		<p>Your GreenBizCheck team</p>
		<img src="http://www.greenbizcheck.com/_images/email_content/gbc-cloud-logo-and-bv.jpg" />
		<p class="quote">Bureau Veritas verifies and validates GreenBizCheck's environmental assessments</p>
		<p>1300 552 335  |  <a href="mailto:info@greenbizcheck.com">info@greenbizcheck.com</a>  |  <a href="https://www.greenbizcheck.com">www.greenbizcheck.com</a></p>
		<p class="environment-tagline">Please consider the environment before printing this email - every year we are losing 40 million acres of oxygen producing forests through logging and land clearing.</p>

	</xsl:template>

	<!-- //Generic GBC Email Styling -->
	<xsl:template name="gbc-email-styling">
		<!-- In Document CSS -->
		<style type="text/css">
			body {
				font-size:15px;
				color:rgb(51, 51, 51);
				font-family:helvetica;
				background-color: #f2f2f2;
				line-height:1.3em;
				padding:20px;
			}

			.email-container {
				width:600px;
				text-align:left;
				background-color: #ffffff;
				padding:20px;
			}

			.environment-tagline {
				color:rgb(0,153,0);
				font-style:italic;
				font-weight:bold;
				font-size:10px;
				line-height:1.1em;
			}

			.quote {
				font-style:italic;
				font-size:10px;
			}

			p {
				padding:5px;
				margin:0px;
				font-size:15px;
				color:rgb(51, 51, 51);
				font-family:helvetica;
				line-height:1.3em;
			}

			a, a:visited, a:hover {
				color: #3498db;
				font-size:15px;
				font-family:helvetica;
				line-height:1.5em;
			}

			.background-table {
				border:	0px;
				cellpadding: 0px;
				cellspacing: 0px;
				width: 100%;
				height: 100%;
				bgcolor: #f2f2f2;
				background-color: #f2f2f2;
			}

			.background-table-cell {
				bgcolor: #f2f2f2;
				padding:50px;
				background-color: #f2f2f2;
			}

		</style>
	</xsl:template>

</xsl:stylesheet>