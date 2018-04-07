<?php
class core {
	public $nav				= array();
	public $pathSet			= array();
	public $navigationSet	= array();
	public $queryPath 		= array();
	public $template		= false;
	public $domain			= false;
	public $domain_to_duplicate = false;
	public $media_type		= 'text/html';
	public $enable_google_maps = false; //Set in config to enable or disable Google Maps
	public $navMatch 		= array();
	public $plugin;
	public $db;
	public $doc;
	public $session;
	private $xslt;
	public $debug;
	
	public function __construct() {
		$this->doc = new DOMDocument('1.0','UTF-8');
		$this->doc->appendChild($this->doc->createElement('config'));
		$this->db = new db(DB_HOST,DB_USER,DB_PASS);
		$this->debug = new debug($this->doc);
		$this->session = new sessionCookie(SESSION_COOKIE);
		$this->setDomain();
		$this->enforceSecureSsl();
		$this->setGoogleMaps();
		$this->setDateTime();
		$this->setPathSet();
		$breadcrumbNode = $this->doc->lastChild->appendChild($this->doc->createElement('breadcrumb'));
		$this->setContentScope();
		$this->setNavigation();
		$this->setMenuItems();
		$this->matchNav();
		$this->setQueryPath();
		$this->setTemplate();
		$this->setGlobals();
		for($i=0;$i<count($this->navigationSet);$i++) {
			$breadcrumbNode->appendChild($this->doc->createElement('navigation_id',$this->navigationSet[$i]));
		}
		$this->setMessages();
	}

	private function setMessages() {
		$messages = $this->session->getSessionVar('messages');
		if(!is_null($messages)) {
			foreach($messages as $message) {
				$messageNode = $this->doc->lastChild->appendChild($this->doc->createElement('message'));
				foreach($message as $key=>$val) {
					$messageNode->setAttribute($key,$val);
				}
			}
			$this->session->deleteSessionVar('messages');
		}
		return;
	}

	private function setDateTime() {
		$datetimeNode = $this->doc->lastChild->appendChild($this->doc->createElement('datetime'));
		$datetimeNode->setAttribute('year',date('Y'));
		$datetimeNode->setAttribute('month',date('m'));
		$datetimeNode->setAttribute('day',date('d'));
		$datetimeNode->setAttribute('hour',date('h'));
		$datetimeNode->setAttribute('minute',date('i'));
		$datetimeNode->setAttribute('second',date('s'));
		$datetimeNode->setAttribute('hour_extension',date('a'));
		$datetimeNode->setAttribute('long_month',date('F'));
		$datetimeNode->setAttribute('long_day',date('l'));
		$datetimeNode->setAttribute('long_date',date('jS'));
		$datetimeNode->setAttribute('short_day',date('j'));
		$datetimeNode->setAttribute('short_month',date('n'));

		return;
	}

	private function setQueryPath()
 	{
 		$queryPathNode = $this->doc->lastChild->appendChild($this->doc->createElement('queryPath'));
 		if(count($this->pathSet) > count($this->navigationSet)) {
	 		for($i = count($this->navigationSet); $i < count($this->pathSet); $i++) {
	 			$queryPathNode->appendChild($this->doc->createElement('variable',$this->pathSet[$i]));
	 			$this->queryPath[] = $this->pathSet[$i];
	 		}
 		}

 		//Now set the domain base url
 		$queryPathString = count($this->queryPath) > 0 ? implode('/',$this->queryPath) . "/" : '';
 		$this->domain->base_url = substr_replace($this->domain->requested_url_path, '', (strlen($this->domain->requested_url_path) - strlen($queryPathString)));
 		$this->domain->base_url = substr($this->domain->base_url, -1) == '/' ? $this->domain->base_url : $this->domain->base_url . "/";

 		return;
 	}

	//Get the content scope
	private function setContentScope() {
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`scope`;
		',
			DB_PREFIX.'core'
		))) {
			$contentScopes = $this->doc->lastChild->appendChild($this->doc->createElement('contentScopes'));
			while($row = $result->fetch_object()) {
				$scopeNode = $contentScopes->appendChild($this->doc->createElement('scope'));
				$scopeNode->setAttribute('scope_id',$row->scope_id);
				$scopeNode->setAttribute('description',$row->description);
			}
			$result->close();
		}
		return;
	}
	
	private function setDomain() {
		$fallback_domain_id = 1;
		$query = sprintf('
			SELECT *
			FROM `%1$s`.`domain`
			WHERE `domain`.`%2$s` LIKE "%%%3$s";
		',
			DB_PREFIX.'core',
			SERVER_ENV,
			$this->db->escape_string(HOST)
		);

		if($result = $this->db->query($query)) {
			if($row = $result->fetch_object()) {
				$this->domain = $row;
				if(!is_null($row->redirect_to_domain_id)) {
					$fallback_domain_id = $row->redirect_to_domain_id;
				} else {
					$fallback_domain_id = false;
				}
			}
			$result->close();
		}
		if($fallback_domain_id !== false) {
			$query = sprintf('
				SELECT *
				FROM `%1$s`.`domain`
				WHERE `domain`.`domain_id` = %2$d;
			',
				DB_PREFIX.'core',
				$fallback_domain_id
			);

			if($result = $this->db->query($query)) {
				if($row = $result->fetch_object()) {
					$this->domain = $row;
				}
				$result->close();
			}
		}

		#SERVER_ENV
		#set the domain name
		$this->domain->name = $this->domain->{SERVER_ENV};

		if($this->domain->name != HOST) {
			header('Location: http://'.$this->domain->name.$_SERVER['REQUEST_URI'],301);
			die();
		} else {
			$domainNode = $this->doc->firstChild->appendChild($this->doc->createElement('domain'));
			$domainNode->setAttribute('domain_id',$this->domain->domain_id);
			$domainNode->setAttribute('name',$this->domain->name);
			$domainNode->setAttribute('server_env',SERVER_ENV);
			$domainNode->setAttribute('generator',GENERATOR);
			
			//If this domain is set to render content from another domain (duplicate) add the domain id to the node
			if(!is_null($this->domain->domain_to_duplicate)) {
				$domainNode->setAttribute('domain_to_duplicate',$this->domain->domain_to_duplicate);
			}

			//Set the domain paths
			$this->domain->requested_url = 'http' . (isset($_SERVER['HTTPS']) ? 's' : '') . '://' .$this->domain->name.$_SERVER['REQUEST_URI'];
			$this->domain->requested_url_path = 'http' . (isset($_SERVER['HTTPS']) ? 's' : '') . '://' .$this->domain->name.strtok($_SERVER['REQUEST_URI'],'?');
			$this->domain->requested_query_string = "?".$_SERVER['QUERY_STRING'];
			$this->domain->site_url = 'http' . (isset($_SERVER['HTTPS']) ? 's' : '') . '://' .$this->domain->name;
			$domainNode->setAttribute('requested_url',$this->domain->requested_url);
			$domainNode->setAttribute('requested_url_path',$this->domain->requested_url_path);
			$domainNode->setAttribute('requested_query_string',$this->domain->requested_query_string);
			$domainNode->setAttribute('ssl',$this->domain->ssl);
			$domainNode->setAttribute('site_url',$this->domain->site_url);

			//Set the site customisation settings
			$domainNode->setAttribute('css_override',$this->domain->css_override);
			$domainNode->setAttribute('site_image',$this->domain->site_image);
			$domainNode->setAttribute('site_image_alt',$this->domain->site_image_alt);
			$domainNode->setAttribute('favicon',$this->domain->favicon);
			$domainNode->setAttribute('icon',$this->domain->icon);
			$domainNode->setAttribute('site_name',$this->domain->site_name);
			$domainNode->setAttribute('default_color',$this->domain->default_color);
			$domainNode->setAttribute('gbc_api', GBCAPI);
			
			//Set the footer content
			$domainNode->appendChild($this->createHTMLNode($this->domain->footer_content,'footer_content'));
			$domainNode->appendChild($this->createHTMLNode($this->domain->footer_scripts,'footer_scripts'));
		}
		return;
	}
	
	private function enforceSecureSsl() {
		if(SERVER_ENV == 'remote' && $this->domain->ssl == '1') {
			//If the request was for a secure page without ssl, force redirect
			if(!isset($_SERVER['HTTPS']) || $_SERVER['HTTPS'] == ""){
				$redirect = "https://".HOST.$_SERVER['REQUEST_URI'];
				header("Location: $redirect");
				die();
			}
		}		
	
		return;
	}
	
	//Function Sets the xsl variables for google maps api
	private function setGoogleMaps() {
		$googleMapsNode = $this->doc->firstChild->appendChild($this->doc->createElement('googleMaps'));
		$googleMapsNode->setAttribute('enabled',GOOGLE_MAPS_ENABLED);
		$googleMapsNode->setAttribute('use_api_key',GOOGLE_MAPS_USE_KEY);
		$googleMapsNode->setAttribute('api_key',GOOGLE_MAPS_API_KEY);
		$googleMapsNode->setAttribute('sensor',GOOGLE_MAPS_SENSOR);
		$googleMapsNode->setAttribute('url',GOOGLE_MAPS_URL);
	}
	
	private function setTemplate() {
		$this->xslt = new DOMDocument();
		$this->xslt->load(PATH_TEMPLATE.'/'.$this->template.'/'.$this->template.'.xsl');
		$this->setPlugins();
	}
	
	public function render() {
		if((isset($_REQUEST['debug'])) && (isset($_REQUEST['pass']))) {
			 return $this->debug();
		}

		header("Status: 200");
		header("Content-type: ".$this->media_type);
		
		//Added Cache Control Headers
		header("Cache-Control: no-store, no-cache");
		header("Pragma: no-cache");
		header("Expires: 0");
		
		$this->session->save();
		$xsl = new XSLTProcessor();
		$xsl->registerPHPFunctions();
		$xsl->importStyleSheet($this->xslt);
		$html = $xsl->transformToXML($this->doc);
		print $html;
		return;
	}
	
	//Only allow debug feed in the local development environment
	public function debug() {
		$this->debug->renderXML();
	}
	
	private function setNavigation() {
	 
	 	//If this domain has an ID to duplicate it's content from query content from both domain_id and domain_to_duplicate id  
	 	if(!is_null($this->domain->domain_to_duplicate)){
			if($result = $this->db->query(sprintf('
				SELECT
					`navigation`.`navigation_id`,
					IF(`navigation`.`parent_id` IS NULL,0,`navigation`.`parent_id`) AS `parent_id`,
					`template`.`template`,
					`template`.`media_type`,
					`navigation`.`sequence`,
					`navigation`.`path`,
					`navigation`.`label`,
					`navigation`.`title`,
					`navigation`.`secure`,
					`navigation`.`sitemap_priority`,
					`navigation`.`sitemap_lastmod`,
					`navigation`.`sitemap_changefreq`,
					`navigation`.`meta-title`,
					`navigation`.`meta-description`,
					`navigation`.`meta-keywords`,
					`navigation`.`scope_id`
				FROM `%1$s`.`navigation`
				LEFT JOIN `%1$s`.`template` USING (`template_id`)
				WHERE `navigation`.`domain_id` = %2$d
				ORDER BY `navigation`.`sequence` ASC;
			',
				DB_PREFIX.'core',
				$this->domain->domain_to_duplicate
			))) {
				$this->nav[0] = new StdClass();
				$this->nav[0]->node = $this->doc->lastChild->appendChild($this->doc->createElement('navigation'));
				while($row = $result->fetch_object()) {
					//Check to see if the domain has content for the current navigation - if so we can inject this content here
					if($replace_result_query = $this->db->query(sprintf('
						SELECT
							`navigation`.`navigation_id`,
							IF(`navigation`.`parent_id` IS NULL,0,`navigation`.`parent_id`) AS `parent_id`,
							`template`.`template`,
							`navigation`.`label`,
							`navigation`.`title`,
							`navigation`.`navigation_id`
						FROM `%1$s`.`navigation`
						LEFT JOIN `%1$s`.`template` USING (`template_id`)
						WHERE `navigation`.`domain_id` = %2$d
						AND `navigation`.`path` = "%3$s"
						LIMIT 1;
					',
					DB_PREFIX.'core',
					$this->domain->domain_id,
					$row->path
					))) {
					 while($replace_result = $replace_result_query->fetch_object()) {
					
						//Now check to see if the values are set
						if(!is_null($replace_result->template)) {
							$row->template = $replace_result->template;
						}
						if(!is_null($replace_result->label)) {
							$row->label = $replace_result->label;
						}
						if(!is_null($replace_result->title)) {
							$row->title = $replace_result->title;
						}
					
						$row->duplicate_navigation_id = $replace_result->navigation_id;

						}
					}
			 
					$this->nav[$row->navigation_id] = $row;
					$this->nav[$row->navigation_id]->node = $this->prepareNavItem($row);
				}
				$result->close();
				foreach($this->nav as $navigation_id => $item) {
					if($navigation_id == 0) continue;
					$this->nav[$item->parent_id]->node->appendChild($item->node);
				}
			}
			return;
		}
		else {
	 
			if($result = $this->db->query(sprintf('
				SELECT
					`navigation`.`navigation_id`,
					IF(`navigation`.`parent_id` IS NULL,0,`navigation`.`parent_id`) AS `parent_id`,
					`template`.`template`,
					`template`.`media_type`,
					`navigation`.`sequence`,
					`navigation`.`path`,
					`navigation`.`label`,
					`navigation`.`title`,
					`navigation`.`secure`,
					`navigation`.`sitemap_priority`,
					`navigation`.`sitemap_lastmod`,
					`navigation`.`sitemap_changefreq`,
					`navigation`.`meta-title`,
					`navigation`.`meta-description`,
					`navigation`.`meta-keywords`,
					`navigation`.`scope_id`
				FROM `%1$s`.`navigation`
				LEFT JOIN `%1$s`.`template` USING (`template_id`)
				WHERE `navigation`.`domain_id` = %2$d
				ORDER BY `navigation`.`sequence` ASC;
			',
				DB_PREFIX.'core',
				$this->domain->domain_id
			))) {
				$this->nav[0] = new StdClass();
				$this->nav[0]->node = $this->doc->lastChild->appendChild($this->doc->createElement('navigation'));
				while($row = $result->fetch_object()) {
					$this->nav[$row->navigation_id] = $row;
					$this->nav[$row->navigation_id]->node = $this->prepareNavItem($row);
				}
				$result->close();
				foreach($this->nav as $navigation_id => $item) {
					if($navigation_id == 0) continue;
					if(isset($this->nav[$item->parent_id])) {
						$this->nav[$item->parent_id]->node->appendChild($item->node);
					}
				}
			}
			return;
		}
	}
	
	private function setMenuItems() {
	 
	 //IF the domain_to_duplicate element is present get content from the main domain id and the domain_to_duplicate ID
	 if(!is_null($this->domain->domain_to_duplicate)) {
	  
	  	$menuItems = array();
		$menuItems[0] = $this->doc->lastChild->appendChild($this->doc->createElement('menuItems'));
		if($result = $this->db->query(sprintf('
			SELECT
				`menu_item`.`menu_item_id`,
				IF(`menu_item`.`parent_id` IS NULL,0,`menu_item`.`parent_id`) AS `parent_id`,
				`menu_item`.`label`,
				`menu_item`.`href`,
				`menu_item`.`sequence`,
				`menu_item`.`scope_id`,
				`menu_item`.`icon`
			FROM `%1$s`.`menu_item`
			WHERE `menu_item`.`domain_id` = %2$d
			ORDER BY `menu_item`.`sequence` ASC;
		',
			DB_PREFIX.'core',
			$this->domain->domain_to_duplicate
		))) {
			while($row = $result->fetch_object()) {
				$menuItems[$row->menu_item_id] = $this->doc->createElement('menuItem');
				$menuItems[$row->menu_item_id]->setAttribute('menu_item_id',$row->menu_item_id);
				$menuItems[$row->menu_item_id]->setAttribute('parent_id',$row->parent_id);
				$menuItems[$row->menu_item_id]->setAttribute('label',$row->label);
				$menuItems[$row->menu_item_id]->setAttribute('href',$row->href);
				$menuItems[$row->menu_item_id]->setAttribute('sequence',$row->sequence);
				$menuItems[$row->menu_item_id]->setAttribute('scope_id',$row->scope_id);
				$menuItems[$row->menu_item_id]->setAttribute('icon',$row->icon);
			}
			$result->close();
		}
		foreach($menuItems as $menu_item_id => $menuItem) {
			if($menu_item_id == 0) continue;
			$menuItems[$menuItem->getAttribute('parent_id')]->appendChild($menuItem);
		}
		return;
	 }
	else {
		$menuItems = array();
		$menuItems[0] = $this->doc->lastChild->appendChild($this->doc->createElement('menuItems'));
		if($result = $this->db->query(sprintf('
			SELECT
				`menu_item`.`menu_item_id`,
				IF(`menu_item`.`parent_id` IS NULL,0,`menu_item`.`parent_id`) AS `parent_id`,
				`menu_item`.`label`,
				`menu_item`.`href`,
				`menu_item`.`sequence`,
				`menu_item`.`scope_id`,
				`menu_item`.`icon`
			FROM `%1$s`.`menu_item`
			WHERE `menu_item`.`domain_id` = %2$d
			ORDER BY `menu_item`.`sequence` ASC;
		',
			DB_PREFIX.'core',
			$this->domain->domain_id
		))) {
			while($row = $result->fetch_object()) {
				$menuItems[$row->menu_item_id] = $this->doc->createElement('menuItem');
				$menuItems[$row->menu_item_id]->setAttribute('menu_item_id',$row->menu_item_id);
				$menuItems[$row->menu_item_id]->setAttribute('parent_id',$row->parent_id);
				$menuItems[$row->menu_item_id]->setAttribute('label',$row->label);
				$menuItems[$row->menu_item_id]->setAttribute('href',$row->href);
				$menuItems[$row->menu_item_id]->setAttribute('sequence',$row->sequence);
				$menuItems[$row->menu_item_id]->setAttribute('scope_id',$row->scope_id);
				$menuItems[$row->menu_item_id]->setAttribute('icon',$row->icon);
			}
			$result->close();
		}
		foreach($menuItems as $menu_item_id => $menuItem) {
			if($menu_item_id == 0) continue;
			$menuItems[$menuItem->getAttribute('parent_id')]->appendChild($menuItem);
		}
		return;
		}
	}
	
	private function matchNav($parent_id=0,$level=0) {
		if(count($this->pathSet) <= $level) return;
		$match = false;

		foreach($this->nav as $navigation_id => $item) {
			if($navigation_id == 0) continue;
			if($parent_id == $item->parent_id && $this->pathSet[$level] == $item->path) {
				$match = true;
				$this->navigationSet[] = $navigation_id;
				$this->matchNav($navigation_id,$level+1);
				if(!is_null($item->template) && !$this->template) {
					$this->template = $item->template;
					$this->media_type = $item->media_type;
				}
			}
		}

		$this->matchNav[] = $match;

		return;
	}
	
	public function prepareNavItem($item) {
		$node = $this->doc->createElement('item');
		foreach($item as $key => $val) {
			$node->setAttribute($key,$val);
		}
		return($node);
	}
	
	private function setPathSet() {
		$path = parse_url('http://'.$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'],PHP_URL_PATH);
		$this->pathSet = preg_split('/\//',$path,-1,PREG_SPLIT_NO_EMPTY);
		$pathSetNode = $this->doc->lastChild->appendChild($this->doc->createElement('pathSet'));
		for($i=0;$i<count($this->pathSet);$i++) {
			$pathSetNode->appendChild($this->doc->createElement('path',$this->pathSet[$i]));
		}
		array_unshift($this->pathSet,'');
		return;
	}
	
	private function setGlobals() {
		$node = $this->doc->lastChild->appendChild($this->doc->createElement('globals'));
		$this->setGlobalVar(array(
			'HTTP_USER_AGENT'=>@$_SERVER['HTTP_USER_AGENT'],
			'REMOTE_ADDR'=>@$_SERVER['REMOTE_ADDR'],
			'SERVER_ADDR'=>@$_SERVER['SERVER_ADDR']
			),'server',$node);
		$this->setGlobalVar($_POST,'post',$node);
		$this->setGlobalVar($_GET,'get',$node);
		$this->setGlobalVar($_COOKIE,'cookie',$node);
		$this->setGlobalVar(array(
			'code'=>in_array(false, $this->matchNav) ? 404 : 200
			),'response',$node);
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
				$itemNode->setAttribute('value',$this->xssafe(utf8_encode($val)));
			}
		}
		return;
	}
	
	private function setPlugins() {
		$this->plugin = new stdClass();
		$GLOBALS['core'] = &$this;
		$plugins = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`plugin`.`plugin_id`,
				`plugin`.`plugin`,
				`plugin_method`.`plugin_method_id`,
				`plugin_method`.`method`,
				`plugin_method_call`.`plugin_method_call_id`,
				`plugin_method_call`.`navigation_id`,
				`plugin_method_call`.`inherit`,
				`plugin_method_call`.`sequence`,
				`plugin_method_call`.`position`
			FROM `%1$s`.`plugin_method_call`
			LEFT JOIN `%1$s`.`plugin_method` USING (`plugin_method_id`)
			LEFT JOIN `%1$s`.`plugin` USING (`plugin_id`)
			WHERE 1
				AND `plugin_method_call`.`navigation_id` = %2$d
				OR (`plugin_method_call`.`navigation_id` IN (%3$s)
				AND `plugin_method_call`.`inherit` = 1)
			ORDER BY `plugin_method_call`.`sequence`, `plugin_method_call`.`position` ASC;
		',
			DB_PREFIX.'core',
			end($this->navigationSet),
			implode(',',$this->navigationSet)
		))) {
			while($row = $result->fetch_object()) {
				$plugins[$row->navigation_id][] = $row;
			}
			$result->close();
		}
		foreach($this->navigationSet as $navigation_id) {
			if(!isset($plugins[$navigation_id])) continue;
			foreach($plugins[$navigation_id] as $plugin) {
				$plugin = $this->setPluginParams($plugin);
				$node = $this->doc->lastChild->appendChild($this->doc->createElement('plugin'));
				foreach($plugin as $key => $val) {
					$node->setAttribute($key,$val);
				}
				if(!isset($this->plugin->{$plugin->plugin})) {
					$xslt = PATH_PLUGIN.'/'.$plugin->plugin.'/'.$plugin->plugin.'.xsl';
					if(is_file($xslt)) {
						$xslInclude = $this->xslt->firstChild->appendChild($this->xslt->createElementNS('http://www.w3.org/1999/XSL/Transform','xsl:include'));
						$xslInclude->setAttribute('href',$xslt);
					}
					
					$this->plugin->{$plugin->plugin} = new $plugin->plugin();
					
				}
				$this->plugin->{$plugin->plugin}->node = $node;
				$this->plugin->{$plugin->plugin}->details = $plugin;
				$this->plugin->{$plugin->plugin}->db = $this->db;
				$this->plugin->{$plugin->plugin}->doc = $this->doc;
				$this->plugin->{$plugin->plugin}->session = $this->session;
				$this->plugin->{$plugin->plugin}->{$plugin->method}();
			}
		}
		return;
	}

	public function setPluginParams($plugin) {
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`plugin_method_call_param`
			WHERE `plugin_method_call_id` = %2$d;
		',
			DB_PREFIX.'core',
			$plugin->plugin_method_call_id
		))) {
			while($row = $result->fetch_object()) {
				$plugin->{$row->param} = $row->value;
			}
			$result->close();
		}

		return $plugin;
	}
	
	//xss mitigation functions
	public function xssafe($data,$encoding='UTF-8')
	{
		return $data;
	}
	
	public function xecho($data)
	{
	   echo $this->xssafe($data);
	}
	
	private function createHTMLNode($html,$name) {
		$doc = new DOMDocument('1.0','UTF-8');
		$doc->preserveWhiteSpace = false;
		if(@$doc->loadXML('<'.$name.'>'.$html.'</'.$name.'>') == false) {
			$cdata = $this->doc->createElement($name);
			$cdata->appendChild($this->doc->createCDATASection($html));
			$cdata->setAttribute('parsable','0');
			return($cdata);
		}
		$doc->firstChild->setAttribute('parsable','1');
		return($this->doc->importNode($doc->firstChild,true));
	}
}

?>