<?php
class auditContent extends audit {
	private $xslt;
	private $doc;
	
	public function __construct($associate=false) {
		parent::__construct($associate);
		$this->doc = new DOMDocument('1.0','UTF-8');
		$this->doc->appendChild($this->doc->createElement('config'));
		$this->setGlobals();
		$userNode = $this->doc->lastChild->appendChild($this->doc->createElement('user'));
		
		//If there is no user set, log out
		if(is_null($this->user)) {
			$this->logout();
		}
		
		foreach($this->user as $key => $val) {
			$userNode->setAttribute($key,$val);
		}
	}
	
	public function __destruct() {
		$this->db->close();
		return;
	}
	
	public function loadXSL($xslFile) {
		$this->xslt = new DOMDocument('1.0','UTF-8');
		$this->xslt->load($xslFile);
	}
	
	public function render() {
		$xsl = new XSLTProcessor();
		$xsl->registerPHPFunctions();
		$xsl->importStyleSheet($this->xslt);
		print $xsl->transformToXML($this->doc);
		return;
	}
	
	public function debug() {
		if(($_REQUEST['debug'] == 'now') && (SERVER_ENV == 'local')) {
			$this->doc->formatOutput = true;
			header("Content-type: text/xml");
			print $this->doc->saveXML();
			return;
		}
		else {
			return;
		}
	}
	
	public function loadContent($contentDir,$default='home') {
		if(isset($this->user->admin_id)) {
			$this->db->query(sprintf('
				INSERT DELAYED INTO `%1$s`.`audit_log` SET
					`auditor_id` = %2$d,
					`timestamp` = NOW(),
					`request` = "%3$s";
			',
				DB_PREFIX.'audit',
				$this->user->audit_id,
				$this->db->escape_string($_SERVER['REQUEST_URI'])
			));
		}
		$page = (isset($_REQUEST['page']) ? $_REQUEST['page'] : $default);
		if(($phpFile = $contentDir.'/'.$page.'/'.$page.'.php') && is_file($phpFile)) {
			include($phpFile);
		}
		if(($xslFile = $contentDir.'/'.$page.'/'.$page.'.xsl') && is_file($xslFile)) {
			$xslInclude = $this->xslt->firstChild->appendChild($this->xslt->createElementNS('http://www.w3.org/1999/XSL/Transform','xsl:include'));
			$xslInclude->setAttribute('href',$xslFile);
		}
		return;
	}
	
	public function row2config($row,$name) {
		$node = $this->appendChild($this->doc->createElement($name));
		foreach($row as $key => $val) {
			$node->setAttribute($key,utf8_encode($val));
		}
		return($node);
	}
	
	public function appendChild($node) {
		return $this->doc->lastChild->appendChild($node);
	}
	
	private function setGlobals() {
		if(isset($_REQUEST['page'])) { $this->doc->lastChild->setAttribute('page',$_REQUEST['page']); }
		if(isset($_REQUEST['mode'])) { $this->doc->lastChild->setAttribute('mode',$_REQUEST['mode']); }
		if(isset($_REQUEST['step'])) { $this->doc->lastChild->setAttribute('step',$_REQUEST['step']); }
		$node = $this->doc->lastChild->appendChild($this->doc->createElement('globals'));
		$this->setGlobalVar(array(
			'HTTP_USER_AGENT'=>$_SERVER['HTTP_USER_AGENT'],
			'REMOTE_ADDR'=>$_SERVER['REMOTE_ADDR']
			),'server',$node);
		$this->setGlobalVar($_POST,'post',$node);
		$this->setGlobalVar($_GET,'get',$node);
		$this->setGlobalVar($_COOKIE,'cookie',$node);
		return;
	}
	
	private function setGlobalVar($array,$type,$parentNode) {
		if(!is_array($array)) return;
		foreach($array as $key => $val) {
			$itemNode = $parentNode->appendChild($this->doc->createElement('item'));
			$itemNode->setAttribute('key',$key);
			$itemNode->setAttribute('type',$type);
			if(is_array($val)) {
				$this->setGlobalVar($val,$type,$itemNode);
			} else {
				$itemNode->setAttribute('value',$val);
			}
		}
		return;
	}
}
?>