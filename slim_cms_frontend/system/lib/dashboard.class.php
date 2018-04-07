<?php

class dashboard {
	private $db;
	private $dbModel;
	
	public function __construct($db) {
		$this->db = $db;
		$this->dbModel = new dbModel($this->db);

		return;
	}

	public function getDashboardUser($client_contact_id) {
		$dashboardUser = array();

		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_contact_2_dashboard`
			WHERE `client_contact_id` = %2$d
			LIMIT 1;
		',
			DB_PREFIX.'dashboard',
			$client_contact_id
		))) {
			while($row = $result->fetch_object()) {
				$dashboardUser = $row;
			}
			$result->close();
		}

		return $dashboardUser;
	}

	//Get all of the filter fields
	public function getFilterFields() {
		$filter_fields = array();
		if($result = $this->db->query(sprintf('
			SELECT
			*
			FROM `%1$s`.`filter_fields`
			ORDER BY `label`
		',
			DB_PREFIX.'dashboard'
		))) {
			while($row = $result->fetch_object()) {
				$filter_fields[] = $row;
			}
			$result->close();
		}
		return $filter_fields;
	}
	
	//Get all of the filter queries
	public function getFilterQueries() {
		$filter_queries = array();
		if($result = $this->db->query(sprintf('
			SELECT
			*
			FROM `%1$s`.`filter_queries`
		',
			DB_PREFIX.'dashboard'
		))) {
			while($row = $result->fetch_object()) {
				$filter_queries[] = $row;
			}
			$result->close();
		}
		return $filter_queries;
	}

	//Get all of the filter field qroups
	public function getFilterFieldGroups() {
		$filter_field_groups = array();
		if($result = $this->db->query(sprintf('
			SELECT
			*
			FROM `%1$s`.`filter_field_group`
			ORDER BY `order`
		',
			DB_PREFIX.'dashboard'
		))) {
			while($row = $result->fetch_object()) {
				$filter_field_groups[] = $row;
			}
			$result->close();
		}
		return $filter_field_groups;
	}

	//Get all of the filter queries
	public function getDashboardRegistration($module_2_token_id) {
		$registration = new stdClass;

		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`dashboard_registration`
			WHERE `module_2_token_id` = %2$d
			LIMIT 1
		',
			DB_PREFIX.'dashboard',
			$module_2_token_id
		))) {
			while($row = $result->fetch_object()) {
				$registration = $row;
			}
			$result->close();
		}
		return $registration;
	}

	//Pass the details of the client contact along with the details to set the user in the dashboard database
	public function setDashboardUser($client_contact_id, $dashboard_group_id, $dashboard_role_id) {
		$this->db->query(sprintf('
			REPLACE INTO `%1$s`.`client_contact_2_dashboard` SET
				`client_contact_id` = %2$d,
				`dashboard_group_id` = %3$d,
				`dashboard_role_id` = %4$d;
		',
			DB_PREFIX.'dashboard',
			$this->db->escape_string($client_contact_id),
			$this->db->escape_string($dashboard_group_id),
			$this->db->escape_string($dashboard_role_id)
		));

		return $this->db->affected_rows > 0 ? true : false;
	}

	public function getDashboardUserGroup($client_contact_id) {
		$contact = clientContact::stGetClientContactById($this->db, $client_contact_id);
		return $this->getDashboardGroups(empty((array)resultFilter::accessible_user_defined_groups($this->db, $contact)) ? "-1" : resultFilter::accessible_user_defined_groups($this->db, $contact));
	}

	public function getDashboardGroups($include = null, $exclude = null) {
		$groups = array();

		$filter = '';
		$filter .= !is_null($include) ? ' AND udg.user_defined_group_id IN(' . (is_array($include) ? implode(',', $include) : $include) . ') ' : null;
		$filter .= !is_null($exclude) ? ' AND udg.user_defined_group_id NOT IN(' . (is_array($exclude) ? implode(',', $exclude) : $exclude) . ') ' : null;

		$query = sprintf('
			SELECT
			udg.*,
			cc.firstname,
			cc.lastname,
			c.company_name
			FROM %1$s.user_defined_group udg
			LEFT JOIN %2$s.client_contact cc ON udg.client_contact_id = cc.client_contact_id
			LEFT JOIN %2$s.client c ON cc.client_id = c.client_id
			WHERE 1
			%3$s
		',
			DB_PREFIX.'dashboard',
			DB_PREFIX.'core',
			$this->db->escape_string($filter)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$groups[] = $row;
			}
			$result->close();
		}

		for($i = 0; $i < count($groups); $i++) {
			$groups[$i]->hierarchy = $this->getDashboardUserDefinedGroupHierarchy($groups, $groups[$i]->user_defined_group_id);
		}

		//Sort the array by heirachy
		usort($groups, function($a, $b) {
    		return strcmp($a->hierarchy, $b->hierarchy);
		});

		return $groups;
	}

	public function getDashboardUserDefinedGroupHierarchy($groups, $id = 0) {
		foreach($groups as $group) {
			if($group->user_defined_group_id === $id) {
				if($group->parent_group_id > 0) {
					return $this->getDashboardUserDefinedGroupHierarchy($groups, $group->parent_group_id) . " / " . $group->name;
				}
				return $group->name;
			}
		}
	}

	public function deleteGroups($groups) {
		foreach($groups as $id) {
			$groups = array_merge($groups, $this->getChildrenGroups($id, $this->getDashboardGroups()));
		}

		$query = sprintf('
			DELETE FROM `%1$s`.`user_defined_group`
			WHERE `user_defined_group`.`user_defined_group_id` IN(%2$s);
			
			OPTIMIZE TABLE `%1$s`.`user_defined_group`;
		',
			DB_PREFIX.'dashboard',
			$this->db->escape_string(implode(',',$groups))
		);

		$this->db->multi_query($query);

		return;
	}

	public function getChildrenGroups($id, $groups, $children = array()) {
		foreach($groups as $group) {
			if($group->parent_group_id === $id) {
				$children[] = $group->user_defined_group_id;
				return $this->getChildrenGroups($group->user_defined_group_id, $groups, $children);
			}
		}
		return $children;
	}

	public function getParentGroups($id = null, $accessible = null) {
		$exclude = $this->getChildrenGroups($id, $this->getDashboardGroups());
		$exclude[] = $id;

		return $this->getDashboardGroups($accessible, $exclude);
	}

	public function setUserDefinedGroup($data) {
		$query = $this->dbModel->prepare_query('dashboard', 'user_defined_group', 'INSERT INTO', $data);
		$this->db->query($query);

		$client_id = $this->db->insert_id;
		
		return $client_id;
	}

	public function updateUserDefinedGroup($data, $where) {
		$query = $this->dbModel->prepare_query('dashboard', 'user_defined_group', 'UPDATE', $data, $where);
		$this->db->query($query);
		
		return $this->db->affected_rows;
	}

	public function getClient2UserDefinedGroup($groups = null, $clients = null) {
		$members = array();

		$filter = '';
		$filter .= !is_null($groups) ? ' AND c2udf.user_defined_group_id IN(' . (is_array($groups) ? implode(',', $groups) : $groups) . ') ' : null;
		$filter .= !is_null($clients) ? ' AND c2udf.client_id IN(' . implode(',', $clients) . ') ' : null;

		$query = sprintf('
			SELECT
				c2udf.client_id,
				c2udf.user_defined_group_id,
				client.company_name
			FROM %1$s.client_2_user_defined_group c2udf
			LEFT JOIN %2$s.client ON c2udf.client_id = client.client_id
			WHERE 1
			%3$s
		',
			DB_PREFIX.'dashboard',
			DB_PREFIX.'core',
			$this->db->escape_string($filter)
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$members[] = $row;
			}
			$result->close();
		}

		return $members;
	}

	public function updateClient2UserDefinedGroup($group_id, $members = null) {
	
		//Delete those not in the array
		$query = sprintf('
			DELETE FROM `%1$s`.`client_2_user_defined_group`
			WHERE `user_defined_group_id` = %2$d;
		',
			DB_PREFIX.'dashboard',
			$group_id,
			$this->db->escape_string(is_array($members) ? implode(',',$members) : $members)
		);

		$this->db->multi_query($query);

		//Insert those who are in the array
		if(!is_null($members)) {
			foreach($members as $key=>$val) {
				$query = sprintf('
					INSERT INTO `%1$s`.`client_2_user_defined_group` SET
					`user_defined_group_id` = %2$d,
					`client_id` = %3$d;
				',
					DB_PREFIX.'dashboard',
					$group_id,
					$val
				);

				$this->db->query($query);	
			}
		}

		return;	
	}

	public function getResultFilter($client_contact_id) {

		$contact = clientContact::stGetClientContactById($this->db, $client_contact_id);
		
		//Store all groups (Filter Fields, Questions, User Defined Groups) in the filterOptions array
		$filterOptions = array();

		//Filter Queries
		$filterOptions["queries"] = $this->getFilterQueries();

		//Entity and Entry Groups
		$filterFieldGroups = $this->getFilterFieldGroups();
		$filterFields = $this->getFilterFields();


		//Filter Groups
		foreach($filterFieldGroups as $group) {
			$groupFields = array();

			//Filter Fields
			foreach($filterFields as $field) {
				if($field->filter_field_group_id === $group->filter_field_group_id) {

					//Set the default field options
					$filterField = new stdClass;
					$filterField->label = $field->label;
					$filterField->id = $field->filter_fields_id;
					$filterField->type = $field->type;

					//Get any options
					$options = array();
					switch($field->field) {

						//User Defined Group
						case 'user_defined_group_id':
							$options = $this->getUserDefinedGroupOptions(resultFilter::accessible_user_defined_groups($this->db, $contact));
							break;

						case 'metric_id':
							$options = $this->getMetricOptions(resultFilter::accessible_checklists($this->db, $contact));
							break;
					}
					$filterField->options = $options;

					$groupFields[] = $filterField;
				}
			}

			$group->fields = $groupFields;
			$filterOptions["groups"][] = $group;
		}

		$pages = $this->getResultFilterEntryPages($contact);
		$questions = $this->getResultFilterEntryQuestions($contact);

		foreach($pages as $page) {
			$group = new stdClass;
			$group->description = $page->page;

			$fields = array();
			foreach($questions as $question) {
				if($question->page_id == $page->page_id) {
					$field = new stdClass;
					$field->label = $question->question;
					$field->id = 'qid-' . $question->question_id;
					$field->type = 'text';
					$field->options = array();
					$fields[] = $field;
				}
			}

			if(!empty($fields)) {
				$group->fields = $fields;
				$filterOptions["groups"][] = $group;
			}
		}

		return $filterOptions;
	}

	private function getResultFilterEntryPages($contact) {
		$pages = array();

		$query = sprintf('
			SELECT
			page.page_id,
			(
				CASE
					WHEN page_section.title IS NOT NULL AND page.title IS NOT NULL AND checklist.name IS NOT NULL THEN CONCAT(checklist.name,\' > \',page_section.title,\' > \',page.title)
					WHEN page_section.title IS NULL AND page.title IS NOT NULL AND checklist.name IS NOT NULL THEN CONCAT(checklist.name,\' > \',page.title)
					ELSE CONCAT(checklist.name,\' > \',page.title)
				END
			) AS page
			FROM greenbiz_checklist.page
			LEFT JOIN greenbiz_checklist.page_section_2_page ON page.page_id = page_section_2_page.page_id
			LEFT JOIN greenbiz_checklist.page_section ON page_section_2_page.page_section_id = page_section.page_section_id
			LEFT JOIN greenbiz_checklist.checklist ON page.checklist_id = checklist.checklist_id
			WHERE page.checklist_id IN(%2$s)
			AND checklist.checklist_id IS NOT NULL
			ORDER BY checklist.name, page.sequence
		',
			DB_PREFIX.'core',
			implode(',',resultFilter::accessible_checklists($this->db, $contact))
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$pages[] = $row;
			}
			$result->close();
		}		

		return $pages;
	}

	private function getResultFilterEntryQuestions($contact) {
		$questions = array();

		$query = sprintf('
			SELECT * FROM (
				SELECT
				page.page_id,
				question.question_id,
				IF(question.export_key != "", question.export_key, question.question) AS question,
				(SELECT COUNT(answer.answer_id) FROM greenbiz_checklist.answer WHERE answer.question_id = question.question_id) AS answers
				FROM greenbiz_checklist.question
				LEFT JOIN greenbiz_checklist.page ON question.page_id = page.page_id
				LEFT JOIN greenbiz_checklist.page_section_2_page ON page.page_id = page_section_2_page.page_id
				LEFT JOIN greenbiz_checklist.page_section ON page_section_2_page.page_section_id = page_section.page_section_id
				LEFT JOIN greenbiz_checklist.checklist ON page.checklist_id = checklist.checklist_id
				WHERE checklist.checklist_id IN(%2$s)
				AND checklist.checklist_id IS NOT NULL
				AND question.show_in_analytics = 1
				ORDER BY checklist.name, page.sequence, question.sequence) questions
			WHERE questions.answers > 0
		',
			DB_PREFIX.'core',
			implode(',',resultFilter::accessible_checklists($this->db, $contact))
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$row->question = strip_tags($row->question);
				$questions[] = $row;
			}
			$result->close();
		}

		return $questions;		
	}

	private function getUserDefinedGroupOptions($accessible_user_defined_groups) {
		$options = array();
		$userDefinedGroups = !empty($accessible_user_defined_groups) ? $this->getDashboardGroups($accessible_user_defined_groups) : array();
		foreach($userDefinedGroups as $userDefinedGroup) {
			$option = new stdClass;
			$option->label = $userDefinedGroup->hierarchy;
			$option->id = $userDefinedGroup->user_defined_group_id;
			$options[] = $option;
		}
		return $options;
	}

	private function getMetricOptions($accessible_checklists) {
		$options = new stdClass;
		$this->db->setDb(DB_PREFIX.'checklist');

		$options = $this->db->where('p.checklist_id', Array(implode(',',$accessible_checklists)), 'IN')
			->join('metric_group mg','m.metric_group_id=mg.metric_group_id','LEFT')
			->join('page p','mg.page_id=p.page_id','LEFT')
			->orderBy('mg.sequence','asc')
			->orderBy('m.sequence','asc')			
			->ObjectBuilder()
			->get('metric m', null, 'm.metric_id AS id, CONCAT(mg.name," > ",m.metric) AS label');

		return $options;
	}

	public function buildUserDefinedGroupHierarchyArray($groupIdentifiers) {
		$groupArray = array();
		$groups = $this->getDashboardGroups();
		$groupIdentifiers = !is_array($groupIdentifiers) ? explode(',',$groupIdentifiers) : $groupIdentifiers;

		foreach($groupIdentifiers as $groupIdentifier) {
			$groupArray = array_merge($groupArray, $this->getChildrenGroups($groupIdentifier, $groups));
			$groupArray[] = $groupIdentifier;
		}
		return $groupArray;
	}

	public function getDashboardRoles() {
		$roles = array();

		$query = sprintf('
			SELECT *
			FROM %1$s.dashboard_role
			ORDER BY dashboard_role_id
		',
			DB_PREFIX.'dashboard'
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$roles[] = $row;
			}
			$result->close();
		}

		return $roles;		
	}

	public function getCompanyNames($client_contact_id) {
		$contact = clientContact::stGetClientContactById($this->db, $client_contact_id);
		$options = array();

		$query = sprintf('
			SELECT
			client.client_id as option_value,
			client.company_name as option_label
			FROM %1$s.client
			WHERE client.client_id IN(%2$s)
			GROUP BY client.client_id
			ORDER BY client.company_name
		',
			DB_PREFIX.'core',
			implode(',',resultFilter::filtered_client_array($this->db, $contact))
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$options[] = $row;
			}
			$result->close();
		}

		return $options;
	}

	public function getUserClientRestriction($client_contact_id) {
		$restriction = array();

		$query = sprintf('
			SELECT *
			FROM `%1$s`.`client_contact_2_client`
			WHERE `client_contact_2_client`.`client_contact_id` = %2$s
			GROUP BY `client_contact_2_client`.`client_id`
		',
			DB_PREFIX.'dashboard',
			$this->db->escape_string($client_contact_id)
		);
		
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$restriction[] = $row;
			}
			$result->close();
		}
	
		return $restriction;
	}

	public function getUserChecklistRestriction($client_contact_id) {
		$restriction = array();

		$query = sprintf('
			SELECT *
			FROM `%1$s`.`client_contact_2_checklist`
			WHERE `client_contact_2_checklist`.`client_contact_id` = %2$s
			GROUP BY `client_contact_2_checklist`.`checklist_id`
		',
			DB_PREFIX.'dashboard',
			$this->db->escape_string($client_contact_id)
		);
		
		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$restriction[] = $row;
			}
			$result->close();
		}
		return $restriction;
	}

	public function setDashboardUserRole($data, $where = null) {
		$response = new stdClass;
		$response->result = true;
		$response->messages = array();

		if(isset($data['client_contact_id']) && isset($data['dashboard_access'])) {
			
			//Set client_contact_2_dashboard
			$delete = $this->deleteClientContact2dashboard($data['client_contact_id']);
			if($data['dashboard_access'] == '1') {
				$response->result = $this->db->query($this->dbModel->prepare_query('dashboard', 'client_contact_2_dashboard', 'REPLACE INTO', $data));
				$response->messages[] = $response->result !== false ? array('type' => 'success', 'key' => 'User', 'message' => USER_DASHBOARD_ACCESS_SUCCESS) : array('type' => 'error', 'key' => 'User', 'message' => USER_DASHBOARD_ACCESS_FAIL);
			}
	
			//Set client_contact_2_client
			$delete = $this->deleteClientContact2Client($data['client_contact_id']);
			if(isset($data['entity_restriction'])) {
				foreach($data['entity_restriction'] as $key=>$val) {
					$data['client_id'] = $val;
					$query = $this->dbModel->prepare_query('dashboard', 'client_contact_2_client', 'INSERT INTO', $data);
					$response->result = $this->db->query($query);
					$response->messages[] = $response->result != false ? array('type' => 'success', 'key' => 'User', 'message' => USER_DASHBOARD_ENTITY_SUCCESS) : array('type' => 'error', 'key' => 'User', 'message' => USER_DASHBOARD_ENTITY_FAIL);
				}
			}

			//set client_contact_2_checklist
			$delete = $this->deleteClientContact2Checklist($data['client_contact_id']);
			if(isset($data['entry_restriction'])) {
				foreach($data['entry_restriction'] as $key=>$val) {
					$data['checklist_id'] = $val;
					$query = $this->dbModel->prepare_query('dashboard', 'client_contact_2_checklist', 'INSERT INTO', $data);
					$response->result = $this->db->query($query);
					$response->messages[] = $response->result != false ? array('type' => 'success', 'key' => 'User', 'message' => USER_DASHBOARD_ENTRY_SUCCESS) : array('type' => 'error', 'key' => 'User', 'message' => USER_DASHBOARD_ENTRY_FAIL);
				}
			}
			
		}

		return $response;
	}

	private function deleteClientContact2Checklist($client_contact_id) {
		$query = sprintf('
			DELETE FROM `%1$s`.`client_contact_2_checklist`
			WHERE `client_contact_id` IN (%2$s);
		',
			DB_PREFIX.'dashboard',
			$this->db->escape_string(is_array($client_contact_id) ? implode(',',$client_contact_id) : $client_contact_id)
		);

		return $this->db->query($query);
	}

	private function deleteClientContact2Client($client_contact_id) {
		$query = sprintf('
			DELETE FROM `%1$s`.`client_contact_2_client`
			WHERE `client_contact_id` IN (%2$s);
		',
			DB_PREFIX.'dashboard',
			$this->db->escape_string(is_array($client_contact_id) ? implode(',',$client_contact_id) : $client_contact_id)
		);

		return $this->db->query($query);
	}

	private function deleteClientContact2dashboard($client_contact_id) {
		$query = sprintf('
			DELETE FROM `%1$s`.`client_contact_2_dashboard`
			WHERE `client_contact_id` IN (%2$s);
		',
			DB_PREFIX.'dashboard',
			$this->db->escape_string(is_array($client_contact_id) ? implode(',',$client_contact_id) : $client_contact_id)
		);

		return $this->db->query($query);
	}
}

?>