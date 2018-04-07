<?php
class stamps extends plugin {
	
	public function renderAllowedStamps() {
		
		$this->clientChecklist = new clientChecklist($this->db);
		$clientChecklists = $this->clientChecklist->getChecklists($this->session->get('cid'));
		
		$accessibleChecklists = $this->accessibleClientChecklists($clientChecklists);
		foreach ($accessibleChecklists as $checklist) {			
			
			$checklistNode = $this->node->appendChild(
				$this->createNodeFromRecord('clientChecklist', $checklist,
					array(	'client_checklist_id', 'checklist_id', 'checklist', 'name', 'report_type', 'progress', 'initial_score',
							'current_score', 'created', 'completed', 'expires', 'company_name', 'department', 
							'status', 'hash', 'client_checklist_id_md5')
				)
			);			
		}
		
		
		return;
	}
	
		// Return permissions this user has for the passed in $clientChecklistId.
	// Return: clientChecklist if user can access checklist (inserts attribute into plugin
	// node too if admin).
	// NOTE: Loads and returns checklist.
	private function accessibleClientChecklistId($clientChecklistId) {
		$session = $this->session;
		$db = $this->db;
		$this->clientChecklist = new clientChecklist($db);
		$contactModel = new clientContact($db);
		$clientModel = new client($db);
		
		$contact = $contactModel->getClientContactById($session->get('uid'));
		$client = $clientModel->getClientById($session->get('cid'));
		$checklist = $this->clientChecklist->getChecklistByClientChecklistId($clientChecklistId);
		
		if ($contact) {
			$clientChecklistPermissions = dao::model('ChecklistClientChecklistPermission')->findAsChecklistHashByClientContactId($contact->client_contact_id);

			$permissions = $this->canAccessClientChecklist($checklist, $client, $contact, $clientChecklistPermissions);
			$canAccess = $permissions[0];
			$isChecklistAdmin = $permissions[1];

			if (isset($checklist) && isset($clientChecklistPermissions) && isset($clientChecklistPermissions[$checklist->client_checklist_id])) {
				$clientChecklistPermissions[$checklist->client_checklist_id]->xmlRenderer()->injectAttributesInNode($this->node);
			}
				
			if ($client && $contact && $checklist) {
				$this->node->setAttribute('own_checklist', $client->client_id == $checklist->client_id ? 'yes' : 'no');
			}
		
			$this->node->setAttribute('can_access',	$canAccess ? 'yes' : 'no');
			$this->node->setAttribute('is_checklist_admin', $isChecklistAdmin ? 'yes' : 'no');
		
			return $canAccess ? $checklist : NULL;
		}
		else {
			return NULL;
		}
	}
	
	// From the passed in $clientChecklists, return only those that the current user
	// can access.
	// NOTE: Doesn't load checklists.
	private function accessibleClientChecklists($clientChecklists) {
		$session = $this->session;
		$db = $this->db;
		$this->clientChecklist = new clientChecklist($db);
		$contactModel = new clientContact($db);
		$clientModel = new client($db);

		$contact = $contactModel->getClientContactById($session->get('uid'));
		$client = $clientModel->getClientById($session->get('cid'));
		$accessibleChecklists = array();
		if ($contact) {
			$clientChecklistPermissions = dao::model('ChecklistClientChecklistPermission')->findAsChecklistHashByClientContactId($contact->client_contact_id);		
		
			foreach ($clientChecklists as $checklist) {
				$permissions = $this->canAccessClientChecklist($checklist, $client, $contact, $clientChecklistPermissions);
				if ($permissions[0] && $checklist->logo != "") { // canAccess == true and logo exists
					$accessibleChecklists[] = $checklist;
				}
			}
		}
		
		return $accessibleChecklists;
	}
	
		
	// Generic permissions function that returns an array containing [$canAccess, $isChecklistAdmin].
	private function canAccessClientChecklist($checklist, $client, $contact, $contactChecklistPermissions) {
		$clientModel = new client($this->db);
		
		$canAccess = false;
		$isChecklistAdmin = false;
		
		if ($client && $contact && $checklist) {
			// Contact-specific checklist.
			if (isset($contactChecklistPermissions[$contact->client_contact_id])) {
				$permissions = $contactChecklistPermissions[$contact->client_contact_id];
				
				if ($permissions->can_read_checklist || $permissions->can_read_report) {
					$canAccess = true;
				}
			}
			
			// Client's checklist (only if client is admin for client).
			elseif ($checklist->client_id == $client->client_id && $contact->is_client_admin) {
				$canAccess = true;
			}		
		
			// Admin/Associates' client's checklist.
			elseif ($client->client_type == "Admin" || $client->client_type == "Associate") {
				if ($checklist->client_parent_id == $client->client_id) {
					$canAccess = true;
					$isChecklistAdmin = true;
				}
			}
			
			$this->node->setAttribute('own_checklist', $client->client_id == $checklist->client_id ? 'yes' : 'no');
		}
		elseif ($client && $checklist) {
			// No contact means legacy username/password and therefore client should be considered an admin client.
			$canAccess = true;
		}
		
		return array($canAccess, $isChecklistAdmin);
	}
}
?>
