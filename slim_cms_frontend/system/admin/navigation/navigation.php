<?php
if(isset($_REQUEST['action'])) {
	switch($_REQUEST['action']) {
		case 'navigation_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`navigation` SET
					`navigation_id` = %2$d,
					`parent_id` = IF(%3$d != "",%3$d,NULL),
					`domain_id` = %4$d,
					`template_id` = IF(%5$d != "",%5$d,NULL),
					`sequence` = %6$d,
					`secure` = IF(%7$d != "",%7$d,0),
					`path` = "%8$s",
					`label` = "%9$s",
					`title` = "%10$s",
					`sitemap_priority` = "%11$s",
					`sitemap_lastmod` = "%12$s",
					`sitemap_changefreq` = "%13$s",
					`meta-title` = "%14$s",
					`meta-description` = "%15$s",
					`meta-keywords` = "%16$s",
					`scope_id` = %17$d
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_POST['navigation_id']),
				$this->db->escape_string($_POST['parent_id']),
				$this->db->escape_string($_POST['domain_id']),
				$this->db->escape_string($_POST['template_id']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['secure']),
				$this->db->escape_string($_POST['path']),
				$this->db->escape_string($_POST['label']),
				$this->db->escape_string($_POST['title']),
				$this->db->escape_string($_POST['sitemap_priority']),
				$this->db->escape_string($_POST['sitemap_lastmod']),
				$this->db->escape_string($_POST['sitemap_changefreq']),
				$this->db->escape_string($_POST['meta-title']),
				$this->db->escape_string($_POST['meta-description']),
				$this->db->escape_string($_POST['meta-keywords']),
				$this->db->escape_string($_POST['scope_id'])
			));
			header('location: ?page=navigation&mode=navigation_edit&domain_id='.$_POST['domain_id'].'&navigation_id='.$this->db->insert_id);
			die();
		}
		case 'navigation_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`navigation`
				WHERE `navigation_id` = %2$d;
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_REQUEST['navigation_id'])
			));
			header('location: ?page=navigation&domain_id='.$_REQUEST['domain_id']);
			die();
		}
		case 'plugin_method_call_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`plugin_method_call` SET
					`plugin_method_call_id` = %2$d,
					`plugin_method_id` = %3$d,
					`navigation_id` = %4$d,
					`inherit` = %5$d,
					`sequence` = %6$d,
					`position` = %7$d;
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_POST['plugin_method_call_id']),
				$this->db->escape_string($_POST['plugin_method_id']),
				$this->db->escape_string($_POST['navigation_id']),
				$this->db->escape_string($_POST['inherit']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['position'])
			));
			header('location: ?page=navigation&mode=plugin_method_call_edit&domain_id='.$_POST['domain_id'].'&navigation_id='.$_POST['navigation_id'].'&plugin_method_call_id='.$this->db->insert_id);
			die();
		}
		case 'plugin_method_call_param_save': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`plugin_method_call_param`
				WHERE `plugin_method_call_id` = %2$d;
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_REQUEST['plugin_method_call_id'])
			));

			if(isset($_POST['param']) && isset($_POST['value'])) {
				for($i = 0; $i < count($_POST['param']); $i++) {
					$this->db->query(sprintf('
						INSERT INTO `%1$s`.`plugin_method_call_param` SET
							`plugin_method_call_id` = %2$d,
							`param` = "%3$s",
							`value` = "%4$s"
					',
						DB_PREFIX.'core',
						$this->db->escape_string($_POST['plugin_method_call_id']),
						$this->db->escape_string($_POST['param'][$i]),
						$this->db->escape_string($_POST['value'][$i])
					));
				}
			}
			header('location: ?page=navigation&mode=plugin_method_call_edit&domain_id='.$_POST['domain_id'].'&navigation_id='.$_POST['navigation_id'].'&plugin_method_call_id='.$_REQUEST['plugin_method_call_id']);
			die();
		}
		case 'plugin_method_call_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`plugin_method_call`
				WHERE `plugin_method_call_id` = %2$d;
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_REQUEST['plugin_method_call_id'])
			));
			header('location: ?page=navigation&mode=navigation_edit&domain_id='.$_REQUEST['domain_id'].'&navigation_id='.$_REQUEST['navigation_id']);
			die();
		}
		case 'content_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`content` SET
					`content_id` = %2$d,
					`navigation_id` = %3$d,
					`content` = "%4$s";
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_POST['content_id']),
				$this->db->escape_string($_POST['navigation_id']),
				$this->db->escape_string($_POST['content'])
			));
			header('location: ?page=navigation&mode=content_edit&domain_id='.$_POST['domain_id'].'&navigation_id='.$_POST['navigation_id'].'&content_id='.$this->db->insert_id);
			die();
		}
		case 'content_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`content`
				WHERE `content_id` = %2$d;
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_REQUEST['content_id'])
			));
			header('location: ?page=navigation&mode=navigation_edit&domain_id='.$_REQUEST['domain_id'].'&navigation_id='.$_REQUEST['navigation_id']);
			die();
		}
		case 'menu_item_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`menu_item` SET
					`menu_item_id` = %2$d,
					`parent_id` = IF(%3$d != "",%3$d,NULL),
					`domain_id` = %4$d,
					`label` = "%5$s",
					`href` = "%6$s",
					`sequence` = %7$d,
					`scope_id` = %8$d,
					`icon` = IF("%9$s" != "","%9$s",NULL);
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_POST['menu_item_id']),
				$this->db->escape_string($_POST['parent_id']),
				$this->db->escape_string($_POST['domain_id']),
				$this->db->escape_string($_POST['label']),
				$this->db->escape_string($_POST['href']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['scope_id']),
				$this->db->escape_string($_POST['icon'])
			));
			header('location: ?page=navigation&mode=menu_item_list&domain_id='.$_POST['domain_id']);
			die();
		}
		case 'menu_item_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`menu_item`
				WHERE `menu_item_id` = %2$d;
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_REQUEST['menu_item_id'])
			));
			header('location: ?page=navigation&mode=menu_itel_list&domain_id='.$_POST['domain_id']);
			die();
		}
	}
}
$tmpDoc = new DOMDocument('1.0','UTF-8');
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`domain`
	ORDER BY `domain_id` ASC;
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'domain');
	}
	$result->close();
}

if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`navigation`
	ORDER BY `path` ASC;
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'navigation');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`template`
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'template');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`plugin`
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'plugin');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`plugin_method`
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'plugin_method');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`plugin_method_call`
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'plugin_method_call');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`plugin_method_call_param`
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'plugin_method_call_param');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`content`
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$row->content_wellformed = @$tmpDoc->loadXML('<body>'.$row->content.'</body>') ? '1': '0';
		$this->row2config($row,'content');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`menu_item`
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'menu_item');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`scope`
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'scope');
	}
	$result->close();
}
?>