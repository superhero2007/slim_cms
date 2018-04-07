<?php

use \GreenBizCheck\{Groups,
                    Permissions,
                    Submissions};

class dashboards extends plugin {

	/**
	 * David Jones Dashboard
	 */
	public function davidJones() {
        //Check for the user
		if(!$GLOBALS['core']->session->get('uid')) return;

		//Set the params
		$params = $this->getPathParams();
		$this->node->setAttribute('mode', isset($params[0]) ? $params[0] : 'index');
		
        if(!empty($params)) {
            switch($params[0]) {
                case 'report':
                    $this->davidJonesReport();
                    break;

				case 'index':
				default:
					$this->davidJonesDashboard();
					break;
            }
        }

		return;
	}

	private function davidJonesDashboard() {
		$groups = new Groups();
		$permissions = new Permissions();
		$submissions = new Submissions();
		$groupMemberships = $groups->getGroupMembership($GLOBALS['core']->session->get('cid'));

		foreach($groupMemberships as $groupMembership) {

			//Set the dashboard node
			$dashboardNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('dashboard'));
			$dashboardNode->setAttribute('group', $groupMembership['slug']);
			
			switch($groupMembership['slug']) {
				case 'ethical-sourcing':

					$this->completedSuppliersProfile($dashboardNode, 35);
					$this->setAnswerStats($dashboardNode, 'totalNumberOfSuppliers', 15702, 35);
					$this->setAnswerStats($dashboardNode, 'supplierCodeOfConduct', 15714, 35);
					$this->setAnswerStats($dashboardNode, 'supplierApprovalStatus', 15907, 35);
					$this->setSustainabilityAttributesProfile($dashboardNode, 'sustainabilityAttributes', 15947, 35);
					$this->setFoodProgramStats($dashboardNode);
					
					break;

					case 'buyer':
					$this->completedSuppliersProfile($dashboardNode, 35);
					$this->setAnswerStats($dashboardNode, 'totalNumberOfSuppliers', 15702, 35);
					$this->setAnswerStats($dashboardNode, 'myFactoriesApprovalStatus', 15907, 35);
					$this->setSustainabilityAttributesProfile($dashboardNode, 'sustainabilityAttributes', 15947, 35);
					
					break;

					case 'private-label':
					$clientChecklists = $submissions->getSubmissions($permissions->getClientChecklistPermissions($GLOBALS['core']->session->get('uid'), [144]));
					$clientChecklist = isset($clientChecklists[0]) ? $clientChecklists[0] : [];
					$dashboardNode->appendChild($this->createNodeFromArray('clientChecklist', $clientChecklist, array_keys($clientChecklist)));
					
					if(!empty($clientChecklist)) {
						$this->setAnswerStats($dashboardNode, 'myFactoriesApprovalStatus', 15907, 35, $clientChecklist['client_checklist_id']);
						$this->setSustainabilityAttributesProfile($dashboardNode, 'sustainabilityAttributes', 15947, 35);
					}
					break;

					case 'rbma':
					case 'branded':
					$clientChecklist = isset($clientChecklists[0]) ? $clientChecklists[0] : [];
					$dashboardNode->appendChild($this->createNodeFromArray('clientChecklist', $clientChecklist, array_keys($clientChecklist)));
					break;

					case 'distributor':
					$clientChecklist = isset($clientChecklists[0]) ? $clientChecklists[0] : [];
					$dashboardNode->appendChild($this->createNodeFromArray('clientChecklist', $clientChecklist, array_keys($clientChecklist)));
					break;

					case 'general-manager':
					$this->setAnswerStats($dashboardNode, 'totalNumberOfSuppliers', 15702, 35);
					$this->setSustainabilityAttributesProfile($dashboardNode, 'sustainabilityAttributes', 15947, 35);
					$this->setAnswerStats($dashboardNode, 'supplierApprovalStatus', 15907, 35);
					break;
			}
		}

		//Footer Menu
		$this->setFooterMenu();

		return;		
	}

	private function setFooterMenu() {
		$componentNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('component'));
		$componentNode->setAttribute('name', 'footerMenu');
	}

	private function davidJonesReport() {
        $params = $this->getPathParams();
        $submissions = new Submissions;
		$records = [];
		$columns = [];
		$questions = [];
		$clientChecklists = [];
		$clientChecklistResults = [];
		$sustainabilityAttributes = [];
		
        if(!empty($params)) {
            switch($params[1]) {
				case 'completed-suppliers-profile':

					$columns = ['vendor_number' => 'Vendor #', 'vendor_name' => 'Vendor Name', 'supplier_type' => 'Supplier Type', 'group' => 'Group', 'buyer' => 'Buyer', 'complete' => '% Complete', 'saved' => 'Last Saved'];
					$questions = ['vendor_name' => 15697, 'supplier_type' => 15702, 'group' => 15710, 'buyer' => 15713];
					$records = $this->getMasterRecordType();
					$clientChecklists = $submissions->getSubmissions(array_column($records, 'client_checklist_id'));
					$clientChecklistResults = $submissions->getAnswers(array_column($records, 'client_checklist_id'), array_values($questions));
					$this->node->setAttribute('reportType', $params[1]);
					$this->node->setAttribute('reportName', 'Completed Suppliers Profile');

					break;
					
				case 'total-number-of-suppliers':

					$columns = ['vendor_number' => 'Vendor #', 'vendor_name' => 'Vendor Name', 'supplier_type' => 'Supplier Type', 'group' => 'Group', 'buyer' => 'Buyer'];
					$questions = ['vendor_name' => 15697, 'supplier_type' => 15702, 'group' => 15710, 'buyer' => 15713];
					$records = $this->getMasterRecordType();
					$clientChecklistResults = $submissions->getAnswers(array_column($records, 'client_checklist_id'), array_values($questions));
					$this->node->setAttribute('reportType', $params[1]);
					$this->node->setAttribute('reportName', 'Total # of Suppliers');				

					break;
					
				case 'supplier-code-of-conduct':

					$columns = ['vendor_number' => 'Vendor #', 'vendor_name' => 'Vendor Name', 'supplier_type' => 'Supplier Type', 'group' => 'Group', 'buyer' => 'Buyer', 'code_status' => 'Code Status'];
					$questions = ['vendor_name' => 15697, 'supplier_type' => 15702, 'group' => 15710, 'buyer' => 15713, 'code_status' => 15714];
					$records = $this->getMasterRecordType();
					$clientChecklistResults = $submissions->getAnswers(array_column($records, 'client_checklist_id'), array_values($questions));
					$this->node->setAttribute('reportType', $params[1]);
					$this->node->setAttribute('reportName', 'Supplier Code of Conduct');		

					break;
					
				case 'sustainability-attributes':

					$columns = ['vendor_number' => 'Vendor #', 'vendor_name' => 'Vendor Name', 'supplier_type' => 'Supplier Type', 'group' => 'Group', 'buyer' => 'Buyer', 'sustainability_attributes' => 'Sustainability Attributes'];
					$questions = ['vendor_name' => 15697, 'supplier_type' => 15702, 'group' => 15710, 'buyer' => 15713, 'sustainability_attributes' => 15947];
					$records = $this->getMasterRecordType();
					$clientChecklistResults = $submissions->getAnswers(array_column($records, 'client_checklist_id'), array_values($questions));
					$this->setSustanabilityAttributeGroups($clientChecklistResults);
					$this->node->setAttribute('reportType', $params[1]);
					$this->node->setAttribute('reportName', 'Sustainability Attributes');

					break;
					
				//For each factory?
				case 'approved-factory-program':

					$columns = ['vendor_name' => 'Vendor Name', 'group' => 'Group', 'buyer' => 'Buyer', 'factory_id' => 'Factory ID', 'facility_name' => 'Facility Name', 'approval_status' => 'Approval Status', 'approval_status_reason' => 'Approval Status Reason', 'approval_status_last_update' => 'Approval Status Last Update'];
					$questions = ['vendor_name' => 15697, 'group' => 15710, 'buyer' => 15713, 'factory_id' => 15747, 'facility_name' => 15751, 'approval_status' => 15907, 'approval_status_reason' => 15836, 'approval_status_last_update' => 15745];
					$records = $this->getMasterRecordType(array_column($this->getApprovedFactoryProgram(), 'client_checklist_id'));
					$clientChecklistResults = $submissions->getAnswers(array_column($records, 'client_checklist_id'), array_values($questions));
					$this->node->setAttribute('reportType', $params[1]);
					$this->node->setAttribute('reportName', 'Approved Factory Program (Merch)');

					break;
					
				//For each factory?
				case 'food-program':

					$columns = ['vendor_number' => 'Vendor #', 'vendor_name' => 'Vendor Name', 'buyer' => 'Buyer', 'factory_info_provided' => 'Factory Info Provided', 'site_code' => 'Site Code', 'saq_completion' => 'SAQ Completion'];
					$questions = ['vendor_name' => 15697, 'buyer' => 15713, 'factory_info_provided' => 15742, 'site_code' => 15781, 'saq_completion' => 15923];
					$records = $this->getMasterRecordType(array_column($this->getFoodProgram(), 'client_checklist_id'));
					$clientChecklistResults = $submissions->getAnswers(array_column($records, 'client_checklist_id'), array_values($questions));
					$this->node->setAttribute('reportType', $params[1]);
					$this->node->setAttribute('reportName', 'Approved Facility Program (Food)');

                    break;
            }
        }

		//Create Rows
		$rows = array();
		foreach($records as $record) {

			//Set clientChecklists
			foreach($clientChecklists as $clientChecklist) {
				if($clientChecklist['client_checklist_id'] == $record['client_checklist_id']) {
					$record['complete'] = is_null($clientChecklist['completed']) ? $clientChecklist['progress'] : 100;
					$saved = new DateTime($clientChecklist['saved']);
					$record['saved'] = $saved->format("Y-m-j");
				}
			}

			//Set Results
			foreach($questions as $key=>$val) {
				foreach($clientChecklistResults as $result) {
					if($result['client_checklist_id'] == $record['client_checklist_id'] && $result['question_id'] == $val) {
						$response = is_null($result['string']) ? $result['arbitrary_value'] : $result['string'];
						$record[$key] = isset($record[$key]) ? $record[$key] . ', '  . $response : $response;
					}
				}
			}
			$rows[] = $record;
		}
		
		//Set Columns
        $columnsNode = $this->node->appendChild($this->doc->createElement('columns'));
        foreach($columns as $key=>$val) {
			$columnNode = $columnsNode->appendChild($this->doc->createElement('column'));
			$columnNode->setAttribute('column', $key);
			$columnNode->setAttribute('label', $val);
        }

		//Set Rows
        $resultsNode = $this->node->appendChild($this->doc->createElement('results'));
        foreach($rows as $row) {
			$resultNode = $resultsNode->appendChild($this->createNodeFromArray('result', $row, array_keys($row)));
		}

		return;
	}

	/**
	 * Get David Jones Master Record Type
	 *
	 * @return void
	 */
	private function getMasterRecordType($filter = null) {
        $permissions = new Permissions;
		$clientChecklists = $permissions->getClientChecklistPermissions($GLOBALS['core']->session->get('uid'));
		$masterVendorAnswerId = 40231;
		$vendorNumberAnswerId = 38495;

		!is_array($filter) ?: $this->db->where('cc.client_checklist_id', empty($filter) ? [null] : $filter, 'IN');

		$results = $this->db
			->where('cc.client_checklist_id', empty($clientChecklists) ? [null] : $clientChecklists, 'IN')
			->where('vt.answer_id', $masterVendorAnswerId)
			->where('vn.answer_id', $vendorNumberAnswerId)
			->where('vn.index', 'vt.index')
			->join(DB_PREFIX.'checklist.client_result vn', 'vn.client_checklist_id=vt.client_checklist_id', 'LEFT')
			->join(DB_PREFIX.'checklist.client_checklist cc', 'vt.client_checklist_id=cc.client_checklist_id', 'LEFT')
			->get(DB_PREFIX.'checklist.client_result vt', NULL, 'vt.client_checklist_id, cc.client_id, vt.arbitrary_value AS vendor_type, vn.arbitrary_value AS vendor_number');

		return $results;	
	}

	private function setSustanabilityAttributeGroups($clientChecklistResults) {
		$clientChecklists = array_unique(array_column($clientChecklistResults, 'client_checklist_id'));
		$question_id = 15947;
		
		foreach($clientChecklists as $clientChecklist) {
			$attributes = [];
			foreach($clientChecklistResults as $key=>$clientChecklistResult) {
				if($clientChecklistResult['client_checklist_id'] == $clientChecklist && $clientChecklistResult['question_id'] == $question_id) {
					$attribute = $this->getSustainabilityAttribute($clientChecklistResult['answer_id']);
					$attributes[$attribute['category']] = $attribute['category'];
					unset($clientChecklistResults[$key]);
				}
			}

			if(!empty($attributes)) {
				sort($attributes);
				$clientChecklistResults[] = [
					'client_checklist_id' => $clientChecklist,
					'question_id' => $question_id,
					'string' => implode(', ', $attributes)
				];
			}
		}

		return $clientChecklistResults;
	}

	private function getSustainabilityAttribute($answer_id) {
		$sustainabilityAttributes = $this->sustainabilityAttributes();
		foreach($sustainabilityAttributes as $category) {
			foreach($category['attributes'] as $attribute)
				if($attribute['answer_id'] == $answer_id)
					return $category;
		} 
		return null;
	}

	private function sustainabilityAttributes() {
		return [
			[
				'category' => 'Sustainable fibres',
				'attributes' => [
					['answer_id' => '44142','string' => 'Organic Cotton (accredited) >50%'],
					['answer_id' => '44143','string' => 'Organic Cotton (not-accredited) >50%'],
					['answer_id' => '44144','string' => 'Organic Cotton (not-accredited) 100%'],
					['answer_id' => '44145','string' => 'Recycled Poly, Nylon, Cotton or Wool >50%'],
					['answer_id' => '44146','string' => 'Linen or Hemp 100%'],
					['answer_id' => '44147','string' => 'Lyocell, Monocel, Tencel >50% '],
					['answer_id' => '44148','string' => 'Recycled or Organic material >50%'],
					['answer_id' => '44149','string' => 'Better Cotton Initiative Cotton >50%']
				],
				'icon' => 'https://files.greenbizcheck.com/images/davidjones/gbj_sustainable_fibres.png'
			],
			[
				'category' => 'Environmental Sustainability',
				'attributes' => [
					['answer_id' => '44150','string' => 'Renewable energy 100% used in production'],
					['answer_id' => '44151','string' => 'Carbon Neutral (accredited) '],
					['answer_id' => '44152','string' => 'Rainforest Alliance certified  '],
					['answer_id' => '44153','string' => 'Palm Oil - RSPO mass balance'],
					['answer_id' => '44154','string' => 'Palm Oil - RSPO segregated '],
					['answer_id' => '44155','string' => 'FSC/PEFC certified stationery/wood >50%'],
					['answer_id' => '44156','string' => 'Leather Working Group certified '],
					['answer_id' => '44157','string' => 'Vegetable Tanned Leather 100% '],
					['answer_id' => '44158','string' => 'Recycled/Organic products (non-apparel)'],
					['answer_id' => '44159','string' => 'UTZ accredited products '],
					['answer_id' => '44160','string' => 'Soya - Certified responsible soya'],
					['answer_id' => '44161','string' => 'Sugar - Certified Bonsucro']
				],
				'icon' => 'https://files.greenbizcheck.com/images/davidjones/gbj_environmental_sustainability.png'
			],
			[
				'category' => 'Social sustainability - Product',
				'attributes' => [
					['answer_id' => '44162','string' => 'Ethical Clothing Australia accredited'],
					['answer_id' => '44163','string' => 'Fair-trade certified product >50%']
				],
				'icon' => 'https://files.greenbizcheck.com/images/davidjones/gbj_social_sustainability.png'
			],
			[
				'category' => 'Social sustainability - Vendor',
				'attributes' => [
					['answer_id' => '44164','string' => 'Good Weave certification '],
					['answer_id' => '44165','string' => 'Member - multi-stakeholder initiative'],
					['answer_id' => '44166','string' => 'Social enterprise ']
				],
				'icon' => 'https://files.greenbizcheck.com/images/davidjones/gbj_social_sustainability.png'
			],
			[
				'category' => 'Sustainable packaging',
				'attributes' => [
					['answer_id' => '44167','string' => 'Certified sustainable packaging >50%'],
					['answer_id' => '44168','string' => 'Recycled content in packaging >50%'],
					['answer_id' => '44169','string' => 'Compostable packaging ']
				],
				'icon' => 'https://files.greenbizcheck.com/images/davidjones/gbj_sustainable_packaging.png'
			],
			[
				'category' => 'No hazardous substances',
				'attributes' => [
					['answer_id' => '44170','string' => 'Oeko-Tex accredited ']
				],
				'icon' => 'https://files.greenbizcheck.com/images/davidjones/gbj_no_hazardous_substances.png'
			],
			[
				'category' => 'Animal Friendly',
				'attributes' => [
					['answer_id' => '44171','string' => 'Hormone-free animal products/inputs'],
					['answer_id' => '44172','string' => 'Animal testing free (not-certified) '],
					['answer_id' => '44173','string' => 'Animal testing  free (certified) '],
					['answer_id' => '44174','string' => 'Higher welfare - eggs, meat, poultry'],
					['answer_id' => '44175','string' => 'Free range - FREPA or RSPCA certified '],
					['answer_id' => '44176','string' => 'Wool - RWS certified '],
					['answer_id' => '44177','string' => 'Down - RDS certified '],
					['answer_id' => '44178','string' => 'Vegan Cosmetics (certified) '],
					['answer_id' => '44179','string' => 'Seafood - certified MSC/ASC ']
				],
				'icon' => 'https://files.greenbizcheck.com/images/davidjones/gbj_animal_friendly.png'
			],
			[
				'category' => 'Community Investment - Product',
				'attributes' => [
					['answer_id' => '44180','string' => 'Donate 100% profit from item to charity']
				],
				'icon' => 'https://files.greenbizcheck.com/images/davidjones/gbc_community_investment.png'
			],
			[
				'category' => 'Community Investment - Vendor',
				'attributes' => [
					['answer_id' => '44181','string' => 'Support charitable cause (>1% sales)  ']
				],
				'icon' => 'https://files.greenbizcheck.com/images/davidjones/gbc_community_investment.png'
			]
		];
	}


	private function completedSuppliersProfile($node, $client_type_id) {
		$permissions = new Permissions();
		$submissions = new Submissions();
		$progressGroup = array();
		
		$clientChecklists = $submissions->getSubmissions($permissions->getClientChecklistPermissions($GLOBALS['core']->session->get('uid')));
		foreach($clientChecklists as $clientChecklist) {

			if($clientChecklist['progress'] >= 90) {
				$progressGroup['90% - 100%'] = isset($progressGroup['90% - 100%']) ? $progressGroup['90% - 100%'] + 1 : 1;
			} elseif($clientChecklist['progress'] >= 70) {
				$progressGroup['70% - 90%'] = isset($progressGroup['70% - 90%']) ? $progressGroup['70% - 90%'] + 1 : 1;
			} elseif($clientChecklist['progress'] >= 50) {
				$progressGroup['50% - 70%'] = isset($progressGroup['50% - 70%']) ? $progressGroup['50% - 70%'] + 1 : 1;
			} else {
				$progressGroup['0% - 50%'] = isset($progressGroup['0% - 50%']) ? $progressGroup['0% - 50%'] + 1 : 1;
			}
		}

		$componentNode = $node->appendChild($GLOBALS['core']->doc->createElement('component'));
		$componentNode->setAttribute('name', 'completedSuppliersProfile');
		$componentNode->setAttribute('type', 'answerStats');
		foreach($progressGroup as $key=>$val) {
			$resultNode = $componentNode->appendChild($GLOBALS['core']->doc->createElement('result'));
			$resultNode->setAttribute('string', $key);
			$resultNode->setAttribute('count', $val);
		}

		return;
	}

    /**
     * setAnswerStates
     *
     * @param xsl $node Node to append
     * @param string $name Name of the stat
     * @param int $questionId Question identifier
     * @param int $clientTypeId Client type identifier
     * @param int $clientChecklistId Client checklist identifier
     * @return void
     */    
	private function setAnswerStats($node, $name, $questionId, $clientTypeId, $clientChecklistId = null) {
        $permissions = new Permissions();
        $clientChecklists = $permissions->getClientChecklistPermissions($GLOBALS['core']->session->get('uid'));

        $this->db
			->join(DB_PREFIX.'checklist.answer a', 'cr.answer_id=a.answer_id', 'LEFT')
			->join(DB_PREFIX.'checklist.answer_string str', 'a.answer_string_id=str.answer_string_id', 'LEFT')
			->join(DB_PREFIX.'checklist.client_checklist cc', 'cr.client_checklist_id=cc.client_checklist_id', 'LEFT')
			->join(DB_PREFIX.'core.client c', 'cc.client_id=c.client_id', 'LEFT')
			->where('cr.question_id', $questionId)
			->where('c.client_type_id', $clientTypeId)
			->where('cc.client_checklist_id', empty($clientChecklists) ? [null]: $clientChecklists, 'IN')
			->groupBy('cr.answer_id');

			is_null($clientChecklistId) ?: $this->db->where('cc.client_checklist_id', $clientChecklistId);
			$results = $this->db->get(DB_PREFIX.'checklist.client_result cr', NULL, 'str.string, COUNT(*) AS count');

			$componentNode = $node->appendChild($GLOBALS['core']->doc->createElement('component'));
			$componentNode->setAttribute('name', $name);
			$componentNode->setAttribute('type', 'answerStats');
			foreach($results as $result) {
				$resultNode = $componentNode->appendChild($GLOBALS['core']->doc->createElement('result'));
				$resultNode->setAttribute('string', $result['string']);
				$resultNode->setAttribute('count', $result['count']);
			}

		return;
	}

	private function setSustainabilityAttributesProfile($node, $name, $questionId, $clientTypeId, $clientChecklistId = null) {
		$permissions = new Permissions();
        $clientChecklists = $permissions->getClientChecklistPermissions($GLOBALS['core']->session->get('uid'));

        $this->db
			->join(DB_PREFIX.'checklist.answer a', 'cr.answer_id=a.answer_id', 'LEFT')
			->join(DB_PREFIX.'checklist.answer_string str', 'a.answer_string_id=str.answer_string_id', 'LEFT')
			->join(DB_PREFIX.'checklist.client_checklist cc', 'cr.client_checklist_id=cc.client_checklist_id', 'LEFT')
			->join(DB_PREFIX.'core.client c', 'cc.client_id=c.client_id', 'LEFT')
			->where('cr.question_id', $questionId)
			->where('c.client_type_id', $clientTypeId)
			->where('cc.client_checklist_id', empty($clientChecklists) ? [null]: $clientChecklists, 'IN')
			->groupBy('cr.answer_id');

			is_null($clientChecklistId) ?: $this->db->where('cc.client_checklist_id', $clientChecklistId);
			$results = $this->db->get(DB_PREFIX.'checklist.client_result cr', NULL, 'str.string, cr.answer_id');

			$attributes = [];
			foreach($results as $result) {
				$attribute = $this->getSustainabilityAttribute($result['answer_id']);
				isset($attributes[$attribute['category']]) ? $attributes[$attribute['category']]['count'] + 1 : $attributes[$attribute['category']] = ['count' => 1, 'icon' => $attribute['icon']];
			}

			$componentNode = $node->appendChild($GLOBALS['core']->doc->createElement('component'));
			$componentNode->setAttribute('name', 'sustainabilityAttributes');
			$componentNode->setAttribute('type', 'answerStats');
			foreach($attributes as $key=>$val) {
				$resultNode = $componentNode->appendChild($GLOBALS['core']->doc->createElement('result'));
				$resultNode->setAttribute('string', $key);
				$resultNode->setAttribute('count', $val['count']);
			}

		return;
	}

	private function setFoodProgramStats($node) {
        $permissions = new Permissions();
		$clientChecklists = array_column($this->getFoodProgram(), 'client_checklist_id');
		$questions = [38456 => 'Provided Factory Info', 38521 => 'Provided Site Code', 40369 => 'Provided SAQ Completion'];

		$this->db->setTrace(true);
        $results = $this->db
			->join(DB_PREFIX.'checklist.client_result cr', 'cr.answer_id=a.answer_id', 'LEFT')
			->join(DB_PREFIX.'checklist.answer_string ans', 'a.answer_string_id=ans.answer_string_id', 'LEFT')
			->join(DB_PREFIX.'checklist.question q', 'cr.question_id=q.question_id', 'LEFT')
			->where('cr.answer_id', array_keys($questions), 'IN')
			->where('cr.client_checklist_id', empty($clientChecklists) ? [null] : $clientChecklists, 'IN')
			->groupBy('cr.answer_id')
			->get(DB_PREFIX.'checklist.answer a', NULL, 'a.answer_id, COUNT(a.answer_id) AS count');

			$componentNode = $node->appendChild($GLOBALS['core']->doc->createElement('component'));
			$componentNode->setAttribute('name', 'foodProgram');
			$componentNode->setAttribute('type', 'answerStats');
			$componentNode->setAttribute('legend', '0');
			foreach($questions as $key=>$question) {
				$resultNode = $componentNode->appendChild($GLOBALS['core']->doc->createElement('result'));
				$resultNode->setAttribute('string', $question);
				$count = 0;

				foreach($results as $result) {
					if($result['answer_id'] == $key)
						$count = $result['count'];
				}

				$resultNode->setAttribute('count', $count);
			}

		return;
	}

	private function percentCompleteProfile($node, $client_id, $checklist_id) {
		$permissions = new Permissions();
		$submissions = new Submissions();
		$clientChecklists = $submissions->getSubmissions($permissions->getClientChecklistPermissions($GLOBALS['core']->session->get('uid'), [144]));
		$componentNode = $node->appendChild($GLOBALS['core']->doc->createElement('component'));
		$componentNode->setAttribute('name', 'percentCompletedProfile');
		$componentNode->setAttribute('type', 'percentDial');
		foreach($clientChecklists as $clientChecklist) {
			$resultNode = $componentNode->appendChild($GLOBALS['core']->doc->createElement('result'));
			$resultNode->setAttribute('client_checklist_id', $clientChecklist['client_checklist_id']);
			$resultNode->setAttribute('progress', $clientChecklist['progress']);
		}
	}

	private function getApprovedFactoryProgram() {
		$permissions = new Permissions();
		$clientChecklists = $permissions->getClientChecklistPermissions($GLOBALS['core']->session->get('uid'));

		$results = $this->db
			->join(DB_PREFIX.'checklist.client_result cr1', 'cc.client_checklist_id=cr1.client_checklist_id', 'LEFT')
			->join(DB_PREFIX.'checklist.client_result cr2', 'cc.client_checklist_id=cr2.client_checklist_id', 'LEFT')
			->where('cc.client_checklist_id', empty($clientChecklists) ? [null] : $clientChecklists, 'IN')
			->where('cr1.answer_id', 38839)
			->where('cr2.answer_id', 38474)
			->groupBy('cc.client_checklist_id')
			->get(DB_PREFIX.'checklist.client_checklist cc', NULL, 'cc.client_checklist_id');

		return $results;
	}

	private function getFoodProgram() {
		$permissions = new Permissions();
		$clientChecklists = $permissions->getClientChecklistPermissions($GLOBALS['core']->session->get('uid'));

		$this->db->setTrace(true);
		$results = $this->db
			->join(DB_PREFIX.'checklist.client_result cr1', 'cc.client_checklist_id=cr1.client_checklist_id', 'LEFT')
			->join(DB_PREFIX.'checklist.client_result cr2', 'cc.client_checklist_id=cr2.client_checklist_id', 'LEFT')
			->where('cc.client_checklist_id', empty($clientChecklists) ? [null] : $clientChecklists, 'IN')
			->where('cr1.answer_id', 38839)
			->where('cr2.answer_id', 38506)
			->groupBy('cc.client_checklist_id')
			->get(DB_PREFIX.'checklist.client_checklist cc', NULL, 'cc.client_checklist_id');

		return $results;
	}

}
?>