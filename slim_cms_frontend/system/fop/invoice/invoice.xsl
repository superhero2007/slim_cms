<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:xf="http://www.ecrion.com/xf/1.0" 
	xmlns:xc="http://www.ecrion.com/xc" 
	xmlns:xfd="http://www.ecrion.com/xfd/1.0" 
	xmlns:svg="http://www.w3.org/2000/svg" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:date="http://exslt.org/dates-and-times" 
	xmlns:str="http://exslt.org/strings" 			
	xmlns:exsl="http://exslt.org/common"
 	version="1.0" 
	exclude-element-prefix="date str exsl"
	extension-element-prefixes="date str exsl">
	<xsl:output indent="yes"/>

	<!-- //Call the default template -->
	<xsl:include href="../greenbizcheck-invoice/greenbizcheck-invoice.xsl" />

</xsl:stylesheet>
