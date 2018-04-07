<?php
class resultFilter {
	private $db;
	private $user;
	private $super_admin_role_id = 1;
	private $super_admin_group_id = 1;
	
	//SQL Filters
	private static $conditional_client_type_filter = null;
	private static $conditional_checklist_filter = null;
	private static $conditional_client_checklist_filter = null;
	private static $conditional_client_filter = null;

	public static function conditional_client_type_filter($db, $contact) {
		if(is_null(self::$conditional_client_type_filter)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$conditional_client_type_filter;
	}

	public static function conditional_checklist_filter($db, $contact) {
		if(is_null(self::$conditional_checklist_filter)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$conditional_checklist_filter;
	}

	public static function conditional_client_checklist_filter($db, $contact) {
		if(is_null(self::$conditional_client_checklist_filter)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$conditional_client_checklist_filter;
	}

	public static function conditional_client_filter($db, $contact) {
		if(is_null(self::$conditional_client_filter)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$conditional_client_filter;
	}

	//Filter Settings
	private static $filterSettings = null;
	private static $filterSettingsPermalink = null;

	public static function filterSettings($db, $contact) {
		if(is_null(self::$filterSettings)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return is_null(self::$filterSettings) ? array() : self::$filterSettings;
	}

	public static function filterSettingsPermalink($db, $contact) {
		if(is_null(self::$filterSettingsPermalink)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$filterSettingsPermalink;
	}

	//User Based Restriction
	private static $restricted_clients = null;
	private static $restricted_checklists = null;

	public static function restricted_clients($db, $contact) {
		if(is_null(self::$restricted_clients)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$restricted_clients;
	}

	public static function restricted_checklists($db, $contact) {
		if(is_null(self::$restricted_checklists)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$restricted_checklists;
	}

	//Group Accessible Array less User Based Restriction	
	private static $accessible_clients = null;
	private static $accessible_client_types = null;
	private static $accessible_checklists = null;
	private static $accessible_client_checklists = null;
	private static $accessible_user_defined_groups = null;

	public static function accessible_clients($db, $contact) {
		if(is_null(self::$accessible_clients)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$accessible_clients;
	}

	public static function accessible_client_types($db, $contact) {
		if(is_null(self::$accessible_client_types)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$accessible_client_types;
	}

	public static function accessible_checklists($db, $contact) {
		if(is_null(self::$accessible_checklists)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$accessible_checklists;
	}

	public static function accessible_client_checklists($db, $contact) {
		if(is_null(self::$accessible_client_checklists)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$accessible_client_checklists;
	}

	public static function accessible_user_defined_groups($db, $contact) {
		if(is_null(self::$accessible_user_defined_groups)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$accessible_user_defined_groups;
	}

	//Accessible Array less Filtered Array	
	private static $filtered_client_array = null;
	private static $filtered_client_checklist_array = null;

	public static function filtered_client_array($db, $contact) {
		if(is_null(self::$filtered_client_array)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$filtered_client_array;
	}

	public static function filtered_client_checklist_array($db, $contact) {
		if(is_null(self::$filtered_client_checklist_array)) {
			$resultFilter = new resultFilter($db, $contact);
		}
		return self::$filtered_client_checklist_array;
	}
	
	public function __construct($db, $user) {
		$this->db = $db;
		$this->user = $user;

		//Get the User Details
		if(!isset($user->client_contact_id)) return;

		//Get any user based restrictions
		$this->getUserClientRestriction();
		$this->getUserChecklistRestriction();
		
		//Get Accessible Array
		$this->getUserAccessibleClientType();
		$this->getUserAccessibleChecklist();
		$this->getUserAccessibleClient();
		$this->getUserAccessibleClientChecklist();

		//Get Accessible User Defined Groups
		$this->getDashboardAccessibleUserDefinedGroups();

		$this->getPostFilterSettings();
		$this->getFilterPermalink();
		$this->getClientChecklistResults();

		return;
	}
	
	private function getUserClientRestriction() {
		$query = sprintf('
			SELECT
			`client_contact_2_client`.`client_id`
			FROM `%1$s`.`client_contact_2_client`
			WHERE `client_contact_2_client`.`client_contact_id` = %2$s
			GROUP BY `client_contact_2_client`.`client_id`
		',
			DB_PREFIX.'dashboard',
			$this->db->escape_string($this->user->client_contact_id)
		);
		
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				self::$restricted_clients[$row->client_id] = $row->client_id;
			}
			$result->close();
		}
	
		return;
	}

	private function getUserChecklistRestriction() {
		$query = sprintf('
			SELECT
			`client_contact_2_checklist`.`checklist_id`
			FROM `%1$s`.`client_contact_2_checklist`
			WHERE `client_contact_2_checklist`.`client_contact_id` = %2$s
			GROUP BY `client_contact_2_checklist`.`checklist_id`
		',
			DB_PREFIX.'dashboard',
			$this->db->escape_string($this->user->client_contact_id)
		);
		
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				self::$restricted_checklists[$row->checklist_id] = $row->checklist_id;
			}
			$result->close();
		}
		return;
	}

	private function getUserAccessibleClientType() {
		self::$accessible_client_types = array();

		$filter = '';
		if($this->user->dashboard_group_id != $this->super_admin_group_id) {
			$filter .= sprintf('
				AND client_type_id IN(
					SELECT client_type_id 
					FROM %1$s.dashboard_2_client_type 
					WHERE dashboard_group_id = %2$s
				)', 
			DB_PREFIX.'dashboard', 
			$this->user->dashboard_group_id);
		}

		$query = sprintf('
			SELECT
			`client_type`.`client_type_id`
			FROM `%1$s`.`client_type`
			WHERE 1
			' . $filter . '
			GROUP BY `client_type`.`client_type_id`;
		',
			DB_PREFIX.'core'
		);
		
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				self::$accessible_client_types[$row->client_type_id] = $row->client_type_id;
			}
			$result->close();
		}

		self::$conditional_client_type_filter = "AND `client`.`client_type_id` IN(" .  implode(',',self::$accessible_client_types) . ")";
	
		return;
	}

	private function getUserAccessibleChecklist() {
		self::$accessible_checklists = array();

		$filter = "";
		if($this->user->dashboard_group_id != $this->super_admin_group_id) {
			$filter .= sprintf('
				AND checklist_id IN(
					SELECT checklist_id 
					FROM %1$s.dashboard_2_checklist 
					WHERE dashboard_group_id = %2$s
				) ', 
			DB_PREFIX.'dashboard', 
			$this->user->dashboard_group_id);
		}

		$filter .= count(self::$restricted_checklists) > 0 ? ' AND checklist_id IN(' . implode(',',self::$restricted_checklists) . ')' : null;

		$query = sprintf('
			SELECT
			`checklist`.`checklist_id`
			FROM `%1$s`.`checklist`
			WHERE 1
			' . $filter . '
			GROUP BY `checklist`.`checklist_id`;
		',
			DB_PREFIX.'checklist'
		);
		
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				self::$accessible_checklists[$row->checklist_id] = $row->checklist_id;
			}
			$result->close();
		}

		//Set the SQL filter
		self::$conditional_checklist_filter = "AND `checklist`.`checklit_id` IN(" . implode(',',self::$accessible_checklists) . ")";
	
		return;
	}

	private function getUserAccessibleClient() {
		self::$accessible_clients = array();

		$filter = "";
		$filter .= ' AND client_type_id IN(' . implode(',',self::$accessible_client_types) . ') ';
		$filter .= count(self::$restricted_clients) > 0 ? ' AND client_id IN(' . implode(',',self::$restricted_clients) . ',' . $this->user->client_id . ') ' : null;

		$query = sprintf('
			SELECT
			`client`.`client_id`
			FROM `%1$s`.`client`
			WHERE 1
			' . $filter . '
			AND `client`.`status` != 3
			GROUP BY `client`.`client_id`;
		',
			DB_PREFIX.'core'
		);
		
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				self::$accessible_clients[$row->client_id] = $row->client_id;
			}
			$result->close();
		}

		//Set the SQL filter
		self::$conditional_client_filter = "AND `client`.`client_id` IN(" . implode(',',self::$accessible_clients) . ")";
	
		return;
	}

	private function getUserAccessibleClientChecklist() {
		self::$accessible_client_checklists = array();

		$filter = "";
		$filter .= ' AND checklist_id IN(' . implode(',',self::$accessible_checklists) . ') ';
		$filter .= ' AND client_id IN(' . implode(',',self::$accessible_clients) . ') ';

		$query = sprintf('
			SELECT
			`client_checklist`.`client_checklist_id`
			FROM `%1$s`.`client_checklist`
			WHERE 1
			' . $filter . '
			AND `client_checklist`.`status` != 4
			GROUP BY `client_checklist`.`client_checklist_id`;
		',
			DB_PREFIX.'checklist'
		);
		
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				self::$accessible_client_checklists[$row->client_checklist_id] = $row->client_checklist_id;
			}
			$result->close();
		}

		//Set the SQL filter
		self::$conditional_client_checklist_filter = "AND `client_checklist`.`client_checklist_id` IN(" . implode(',',self::$accessible_client_checklists) . ")";
	
		return;
	}

	//Get any post variables that are filter based and created the nodes
	private function getPostFilterSettings() {
		$filterSettings = array();

		if(isset($_REQUEST['action']) && $_REQUEST['action'] === 'filter-results') {

			//Now get each of the filter fields and add them to the XML for postback
			$filterCount = 0;
			if(isset($_REQUEST['filter-field'])) {
				foreach($_REQUEST['filter-field'] as $filterField) {
			
					$filterSetting = new stdClass;
					$filterSetting->{'filter-field'} = $_REQUEST['filter-field'][$filterCount];
					$filterSetting->{'filter-type'} = $_REQUEST['filter-type'][$filterCount];
					$filterSetting->{'filter-value'} = $_REQUEST['filter-value'][$filterCount];

					$filterSettings[] = $filterSetting;
					$filterCount++;
				}
			}
		}

		self::$filterSettings = $filterSettings;

		return;
	}

	private function getFilterPermalink() {
		$permalink = new stdClass;
		$permalink->link = 'http'.(empty($_SERVER['HTTPS'])?'':'s').'://'.$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
		$permalink->link = rtrim(str_replace($_SERVER['QUERY_STRING'], '', $permalink->link), '?');

		$filterCount = 0;
		if(isset($_REQUEST['action']) && $_REQUEST['action'] == "filter-results" && isset($_REQUEST['filter-field'])) {
			$permalink->link .= '?action=filter-results';
			foreach($_REQUEST['filter-field'] as $filterField) {		
				$permalink->link .= '&filter-field[]=' . $_REQUEST['filter-field'][$filterCount];
				$permalink->link .= '&filter-type[]=' . $_REQUEST['filter-type'][$filterCount];
				$permalink->link .= '&filter-value[]=' . (is_array($_REQUEST['filter-value'][$filterCount]) ? implode(',',$_REQUEST['filter-value'][$filterCount]) : $_REQUEST['filter-value'][$filterCount]);
				$filterCount++;
			}
		}

		self::$filterSettingsPermalink = $permalink;

		return;
	}
	
	private function getClientChecklistResults() {
		//Set the filtered_client_array and filtered_client_checklist_array to the accessible as a default
		self::$filtered_client_array = self::$accessible_clients;
		self::$filtered_client_checklist_array = self::$accessible_client_checklists;

		$queryBuilder = new queryBuilder($this->db);
		$queryFilters = $queryBuilder->buildQueryFilter();

		//Foreach query filter, run the selected query to continualy refine the result
		foreach($queryFilters as $queryFilter) {

			$query = sprintf('
				SELECT
				client_checklist.client_id,
				client_checklist.client_checklist_id
				FROM %1$s.client_checklist
				LEFT JOIN %1$s.checklist ON client_checklist.checklist_id = checklist.checklist_id
				LEFT JOIN %2$s.client ON client_checklist.client_id = client.client_id
				LEFT JOIN %1$s.client_result ON client_checklist.client_checklist_id = client_result.client_checklist_id
				LEFT JOIN %1$s.client_metric ON client_checklist.client_checklist_id = client_metric.client_checklist_id
				LEFT JOIN %1$s.answer ON client_result.answer_id = answer.answer_id
	            LEFT JOIN %1$s.answer_string ON answer.answer_string_id = answer_string.answer_string_id
				LEFT JOIN %1$s.checklist_2_client_type ON client_checklist.checklist_id = checklist_2_client_type.checklist_id
				LEFT JOIN %3$s.client_2_user_defined_group ON client.client_id = client_2_user_defined_group.client_id
				LEFT JOIN %3$s.user_defined_group ON client_2_user_defined_group.user_defined_group_id = user_defined_group.user_defined_group_id
				WHERE 1
				AND client_checklist.client_id IN(%4$s)
				AND client_checklist.client_checklist_id IN(%5$s)
				' . $queryFilter . '
				GROUP BY client_checklist.client_checklist_id
				ORDER BY client_checklist.client_checklist_id;
			',
				DB_PREFIX.'checklist',
				DB_PREFIX.'core',
				DB_PREFIX.'dashboard',
				implode(',', self::$filtered_client_array),
				implode(',', self::$filtered_client_checklist_array)
			);

			//Reset the filtered_client_array and the filtered_client_checklist_array
			self::$filtered_client_array = array();
			self::$filtered_client_checklist_array = array();

			if($result = $this->db->query($query)) {
				while($row = $result->fetch_object()) {
					self::$filtered_client_array[$row->client_id] = $row->client_id;
					self::$filtered_client_checklist_array[$row->client_checklist_id] = $row->client_checklist_id;
				}
				$result->close();
			}

		}
			
		return;
	}

	private function getDashboardAccessibleUserDefinedGroups() {
		$query = sprintf('
			SELECT
			`user_defined_group_id`
			FROM `%1$s`.`user_defined_group`
			WHERE `dashboard_group_id` = %2$d
		',
			DB_PREFIX.'dashboard',
			$this->db->escape_string($this->user->dashboard_group_id)
		);
		
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				self::$accessible_user_defined_groups[] = $row->user_defined_group_id;
			}
			$result->close();
		}
	
		return;		
	}

}
?>