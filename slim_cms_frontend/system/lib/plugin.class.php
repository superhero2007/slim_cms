<?php
class plugin {
	public $node;
	public $core;
	public $details;
	public $param;
	public $db;
	public $doc;
	public $session;

	public function __construct() {
		$this->db = $GLOBALS['core']->db;
		$this->doc = $GLOBALS['core']->doc;
		$this->session = $GLOBALS['core']->session;
	}

	public function setParams() {
		$this->param = new stdClass;
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`plugin_method_call_param`
			WHERE `plugin_method_call_id` = %2$d;
		',
			DB_PREFIX.'core',
			$this->details->plugin_method_call_id
		))) {
			while($row = $result->fetch_object()) {
				$this->node->appendChild($GLOBALS['core']->doc->createElement('param'));
				$this->node->lastChild->setAttribute('name',$row->param);
				$this->node->lastChild->setAttribute('value',$row->value);

				$this->param->{$row->param} = $row->value;
			}
			$result->close();
		}

		return $this->param;
	}

	/*
	*	$url [string, default=null] = The data source URL (API or other)
	*	$params [string, default=null] = Any additional parameters
	*	$internal [bool, default=true] = Specify if this is an internal API request or external
	*/

	public function setDataSource($url = null, $params = null, $internal = true) {
		$dataNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('data'));

		//Set mandatory params
		$dataNode->setAttribute('url',$url);
		$dataNode->setAttribute('params',is_null($params) ? '' : json_encode($params));

		//Set only for internal request
		if($internal) {
			$timestamp = time();
			$dataNode->setAttribute('key', GBC_API_PUB_KEY);
			$dataNode->setAttribute('hash',hash_hmac('sha256', (GBC_API_PUB_KEY . $timestamp), GBC_API_PRV_KEY));
			$dataNode->setAttribute('timestamp',$timestamp);
		}

		return;
	}

	public function setJsonTableData($id = null, $data = null) {
		//Add Json encoded data
		$tableData = $this->node->appendChild($GLOBALS['core']->doc->createElement('query-data'));
		$timestamp = time();
		$tableData->setAttribute('key', GBC_API_PUB_KEY);
		$tableData->setAttribute('hash',hash_hmac('sha256', (GBC_API_PUB_KEY . $timestamp), GBC_API_PRV_KEY));
		$tableData->setAttribute('timestamp',$timestamp);
		$tableData->setAttribute('query',$id);
		$tableData->setAttribute('post-data',json_encode($data));

		return;
	}
	
	final public function navBase() {
		$base = array();
		foreach($GLOBALS['core']->navigationSet as $navigation_id) {
			$base[] = $GLOBALS['core']->nav[$navigation_id]->path;
		}
		return(implode('/',$base));
	}
	
	final public function getNavPos() {
		return(array_search($this->details->navigation_id,$GLOBALS['core']->navigationSet));
	}
	
	final public function createHTMLNode($html,$name) {
		$doc = new DOMDocument('1.0','UTF-8');
		$doc->preserveWhiteSpace = false;
		if(@$doc->loadXML('<'.$name.'>'.$html.'</'.$name.'>') == false) {
			$cdata = $GLOBALS['core']->doc->createElement($name);
			$cdata->appendChild($GLOBALS['core']->doc->createCDATASection($html));
			$cdata->setAttribute('parsable','0');
			$cdata->setAttribute('length',strlen($html));
			return($cdata);
		}
		$doc->firstChild->setAttribute('parsable','1');
		$doc->firstChild->setAttribute('length',strlen($html));
		return($GLOBALS['core']->doc->importNode($doc->firstChild,true));
	}

	protected function pluginLoadTime($start, $finish) {
		$this->node->setAttribute('loadTime',($finish - $start) . ' seconds');
		return;
	}
	
	// Create a node named $elementName with attributes matching the $attributesArray 
	// properties of $record. $specialAttributes are a key/value hash where key is the
	// attribute name and value is the value to add.
	// Additional check to make sure the attributes are not objects or values (eg; string, int etc)
	protected function createNodeFromRecord($elementName, $record, $attributesArray, $specialAttributes = array()) {
		$node = $this->doc->createElement($elementName);
		foreach ($attributesArray as $attribute) {
			(!is_array($record->$attribute) && !is_object($record->$attribute)) ? $node->setAttribute($attribute, $GLOBALS['core']->xssafe($record->$attribute)) : null;
		}
		foreach ($specialAttributes as $attribute => $value) {
			(!is_array($value) && !is_object($value)) ? $node->setAttribute($attribute, $GLOBALS['core']->xssafe($value)) : null;
		}
		return $node;
	}

	protected function createNodeFromArray($name, $array, $keys) {
		$node = $this->doc->createElement($name);
		foreach ($keys as $key) {
			$node->setAttribute($key, $array[$key]);
		}

		return $node;
	}
	
	// Add attributes to $node matching the $attributesArray to
	// properties of $record. $specialAttributes are a key/value hash where key is the
	// attribute name and value is the value to add.
	protected function addAttributesToNodeFromRecord($node, $record, $attributesArray, $specialAttributes = array()) {
		foreach ($attributesArray as $attribute) {
			$node->setAttribute($attribute, $GLOBALS['core']->xssafe($record->$attribute));
		}
		foreach ($specialAttributes as $attribute => $value) {
			$node->setAttribute($attribute, $GLOBALS['core']->xssafe($value));
		}
		return $node;		
	}

	/**
	 * Get Path Params
	 * 
	 * Return any paths in the URL which are not matched to the navigation
	 *
	 * @return void
	 */
	public function getPathParams() {
		$params = str_replace($GLOBALS['core']->domain->base_url, '', $GLOBALS['core']->domain->requested_url_path);
		return explode('/', $params);
	}

	/**
	 * Get the base URL
	 *
	 * @return void
	 */
	public function getBaseUrl() {
		return $GLOBALS['core']->domain->base_url;
	}
}
?>