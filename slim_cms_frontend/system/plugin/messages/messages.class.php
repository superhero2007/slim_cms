<?php

class messages extends plugin {
    public $messages;

    public function __construct() {
        $this->messages = new \GreenBizCheck\Messages();
    }

    /**
     * Messages Method
     *
     * @return void
     */
    public function index() {
        $params = $this->getPathParams();
        $this->node->setAttribute('mode', isset($params[0]) ? $params[0] : 'index');
        $this->node->setAttribute('url', $this->getBaseUrl());

        $messages = $this->messages->getMessages();

        if(!empty($params)) {
            switch($params[0]) {
                case 'add':
                    $this->add();
                    break;
                case 'edit':
                    $this->edit($params[count($params)-1]);
                    break;
            }
        }

        //List Messages
        $messagesNode = $this->node->appendChild($this->doc->createElement('messages'));
        foreach($messages as $message) {
            $messagesNode->appendChild($this->createNodeFromArray('message', $message, array_keys($message)));
        }
        return;
    }

    /**
     * Edit Message
     *
     * @param int $id
     * @return void
     */
    public function edit($message_id) {
        $this->node->setAttribute('message_id', $message_id);

        $clientEmails = $this->messages->getMessageClientEmails($message_id);
        $membersNode = $this->node->appendChild($this->doc->createElement('selected_client_emails'));
        foreach($clientEmails as $member) {
            $membersNode->appendChild($this->createNodeFromArray('selected_client_email', $member, Array('client_contact_id', 'email')));
        }

        $this->form("message-edit", $message_id);
    }

    /**
     * Add Message
     *
     * @return void
     */
	public function add() {
        $this->form("message-add");
    }

    private function setMesssageType()
    {
        //Set Message Type
        $message_types = $this->node->appendChild($this->doc->createElement('message_types'));

        $types = $GLOBALS['core']->db->get(DB_PREFIX.'core.message_type');
        foreach($types as $type) {
            $message_types->appendChild($this->createNodeFromArray('message_type', $type, array_keys($type)));
        }
    }

    private function setRecipients()
    {
        //Set Recipients
        $client_emails = $this->node->appendChild($this->doc->createElement('client_emails'));

        $clients = $GLOBALS['core']->db->where('client_contact.email', NULL, 'IS NOT')
            ->where('client_contact.email', '', '<>')
            ->join(DB_PREFIX.'core.client', 'client.client_id=client_contact.client_id', 'LEFT')
            ->orderby('client_contact.client_contact_id')
            ->get(DB_PREFIX.'core.client_contact');
        foreach($clients as $client) {
            $client_emails->appendChild($this->createNodeFromArray('client_email', $client, array_keys($client)));
        }
    }

    private function form($option, $default_message_id = -1) {
        $errors = array();
        $successes = array();
        $requiredFields = ['message_subject' => 'Subject', 'message_content' => 'Message', 'message_type' => 'Message Type', 'client_email' => 'Recipients'];

        $this->setMesssageType();
        $this->setRecipients();

        if(isset($_POST['mode']) && $_POST['mode'] == $option) {
            !isset($_POST['message_active']) ?  $_POST['message_active'] = "0" : $_POST['message_active'] = "1";

            //Validate Data
            foreach($requiredFields as $key=>$field) {
                if(!isset($_POST[$key]) || (isset($_POST[$key]) && empty($_POST[$key]))) {
                    $errors[] = array('message' => $field . ' is a required field.');
                }
            }

            if(isset($_POST['message_type']) && $_POST['message_type'] != 1 && (!isset($_POST['message_sql_query']) || (isset($_POST['message_sql_query']) && empty($_POST['message_sql_query'])))) {
                $errors[] = array('message' => 'Message Trigger (SQL) is a required field.');
            }

            if(empty($errors)) {
                $input = array();
                !isset($_POST['message_subject']) ?: $input['message_subject'] = $_POST['message_subject'];
                !isset($_POST['message_content']) ?: $input['message_content'] = $_POST['message_content'];
                !isset($_POST['message_sql_query']) ?: $input['message_sql_query'] = $_POST['message_sql_query'];
                !isset($_POST['message_active']) ?: $input['message_active'] = $_POST['message_active'];
                !isset($_POST['message_type']) ?: $input['message_type_id'] = $_POST['message_type'];

                if ($option == 'message-add') {
                    //Add Message
                    $message_id = $this->messages->setMessage($input);

                    if($message_id) {
                        $successes[] = array('message' => 'Message successfully added.');

                         //Add Message to Client
                        if(isset($_POST['client_email'])) {
                            $input = array();
                            foreach($_POST['client_email'] as $key=>$val) {
                                $input[] = ['message_id' => $message_id, 'client_contact_id' => $val, 'delivered' => 0];
                            }
                            $message_2_client_contact_id = $this->messages->setMessageToClientContact($input);
                            $message_2_client_contact_id ? $successes[] = array('message' => 'Message is successfully matched to Recipient.') : $errors[] = array('message' => 'Message could not be matched to Recipients.');
                        }

                        header("Location: " . $this->getBaseUrl() . "edit/" . $message_id);
                        die();
                    } else {
                        $errors[] = array('message' => 'Message could not be added.');
                    }
                } else if ($option == 'message-edit') {
                    $message_id = $default_message_id;

                    //Update Message
                    $result = $this->messages->updateMessage(
                        $message_id,
                        $input
                    );

                    if ($result) {
                        $successes[] = array('message' => 'Message is successfully updated.');

                        //Add Message to Client
                        if (isset($_POST['client_email'])) {
                            $this->messages->deleteMessageToClientContact($message_id);
                            $input = array();
                            foreach($_POST['client_email'] as $key=>$val) {
                                $input[] = ['client_contact_id' => $val, 'message_id' => $message_id, 'delivered' => 0];
                            }
                            $message_2_client_contact_id = $this->messages->setMessageToClientContact($input);
                            $message_2_client_contact_id ? $successes[] = array('message' => 'Message is successfully matched to Recipient.') : $errors[] = array('message' => 'Message could not be matched to Recipients.');
                        }
                        header("Location: " . $this->getBaseUrl() . "edit/" . $message_id);
                        die();
                    } else {
                        $errors[] = array('message' => 'Message could not be updated.');
                    }
                }
            }

            //Report Success
            if(!empty($successes)) {
                $successNode = $this->node->appendChild($this->doc->createElement('success'));
                foreach($successes as $success) {
                    $successNode->appendChild($this->createNodeFromRecord('item', (object)$success, array_keys($success)));
                }
                return;
            }

            //Report Errors
            if(!empty($errors)) {
                $this->node->appendChild($this->createNodeFromArray('input', $_POST, Array('message_subject', 'message_content', 'message_sql_query', 'message_active')));

                $errorNode = $this->node->appendChild($this->doc->createElement('error'));
                foreach($errors as $error) {
                    $errorNode->appendChild($this->createNodeFromRecord('item', (object)$error, array_keys($error)));
                }
                return;
            }
        }
    }
}
?>
