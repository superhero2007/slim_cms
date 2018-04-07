<?php

class permissions extends plugin {
    public $groups, $contact, $permissions;

    public function __construct() {
        $this->clients = new \GreenBizCheck\Clients();
        $this->groups = new \GreenBizCheck\Groups();
        $this->permissions = new \GreenBizCheck\Permissions();
    }
    
    /**
     * Groups Method
     *
     * @return void
     */
    public function groups() {
        $params = $this->getPathParams();
        $this->node->setAttribute('mode', isset($params[0]) ? $params[0] : 'index');
        $this->node->setAttribute('url', $this->getBaseUrl());

        $this->contact = clientContact::stGetClientContactById($this->db, $this->session->get('uid'));
        $groups = $this->groups->getGroups($this->permissions->getGroupPermissions($this->contact->client_contact_id));

        if(!empty($params)) {
            switch($params[0]) {
                case 'add':
                    $this->addGroup();
                    break;
                case 'edit':
                    $this->editGroup($params[count($params)-1]);
                    break;
                case 'delete':
                    $this->deleteGroup($params[count($params)-1]);
                    break;
            }
        }

        //List Groups
        $groupsNode = $this->node->appendChild($this->doc->createElement('groups'));
        foreach($groups as $group) {
            $groupNode = $groupsNode->appendChild($this->createNodeFromArray('group', $group, array_keys($group)));
        }

        return;
    }

    /**
     * Add Group
     *
     * @return void
     */
    private function addGroup() {
        $this->node->setAttribute('group_id', null);
        if(isset($_POST['mode']) && $_POST['mode'] === 'group-add') {
            $input = array();
            !isset($_POST['parent_group_id']) ?: $input['parent_group_id'] = $_POST['parent_group_id'];
            !isset($_POST['name']) ?: $input['name'] = $_POST['name'];
            !isset($_POST['slug']) ?: $input['slug'] = $_POST['slug'];
            !isset($_POST['description']) ?: $input['description'] = $_POST['description'];
            !isset($this->contact->client_contact_id) ?: $input['client_contact_id'] = $this->contact->client_contact_id;
            !isset($this->contact->dashboard_group_id) ?: $input['dashboard_group_id'] = $this->contact->dashboard_group_id;
            
            $result = $this->groups->setGroup($input);
            if($result) {
                if(isset($_POST['group_members'])) {
                    $input = array();
                    foreach($_POST['group_members'] as $key=>$val) {
                        $input[] = ['client_id' => $val, 'user_defined_group_id' => $result];
                    }
                    $this->groups->setGroupMembers($input);
                }
                header("Location: " . $this->getBaseUrl() . "edit/" . $result);
                die();
            }
        }

        //List Clients
        $clients = $this->clients->getClients($this->permissions->getClientPermissions($this->contact->client_contact_id));
        $clientsNode = $this->node->appendChild($this->doc->createElement('clients'));
        foreach($clients as $client) {
            $clientsNode->appendChild($this->createNodeFromArray('client', $client, Array('client_id', 'company_name')));
        }

        return;
    }

    /**
     * Edit Group
     *
     * @param int $id
     * @return void
     */
    private function editGroup($id) {
        $this->node->setAttribute('group_id', $id);
        if(isset($_POST['mode']) && $_POST['mode'] === 'group-edit') {
            $input = array();
            !isset($_POST['parent_group_id']) ?: $input['parent_group_id'] = $_POST['parent_group_id'];
            !isset($_POST['name']) ?: $input['name'] = $_POST['name'];
            !isset($_POST['slug']) ?: $input['slug'] = $_POST['slug'];
            !isset($_POST['description']) ?: $input['description'] = $_POST['description'];
            !isset($this->contact->client_contact_id) ?: $input['client_contact_id'] = $this->contact->client_contact_id;
            !isset($this->contact->dashboard_group_id) ?: $input['dashboard_group_id'] = $this->contact->dashboard_group_id;
            
            $result = $this->groups->updateGroup($input, $id);
            if($result) {
                $this->groups->deleteGroupMembers($id);
                if(isset($_POST['group_members'])) {
                    $input = array();
                    foreach($_POST['group_members'] as $key=>$val) {
                        $input[] = ['client_id' => $val, 'user_defined_group_id' => $id];
                    }
                    $this->groups->setGroupMembers($input, $id);
                }
                header("Location: " . $this->getBaseUrl() . "edit/" . $id);
                die();
            } else {
                $this->node->appendChild($this->createNodeFromArray('input', $_POST, array_keys($_POST)));
            }
        }

        $groupMembers = $this->groups->getGroupMembers($id);
        $members = $this->clients->getClients(array_column($groupMembers, 'client_id'));
        $membersNode = $this->node->appendChild($this->doc->createElement('members'));
        foreach($members as $member) {
            $membersNode->appendChild($this->createNodeFromArray('member', $member, Array('client_id', 'company_name')));
        }

        //List Clients
        $clients = $this->clients->getClients($this->permissions->getClientPermissions($this->contact->client_contact_id));
        $clientsNode = $this->node->appendChild($this->doc->createElement('clients'));
        foreach($clients as $client) {
            $clientsNode->appendChild($this->createNodeFromArray('client', $client, Array('client_id', 'company_name')));
        }

        return;
    }

    /**
     * Delete Group
     *
     * @param int $id
     * @return void
     */
    private function deleteGroup($id) {
        $this->node->setAttribute('group_id', $id);
        $result = $this->groups->deleteGroup($id);
        if($result) {
            header("Location: " . $this->getBaseUrl());
            die();
        }
        return $result;
    }
}
?>