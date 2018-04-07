<?php
namespace GreenBizCheck;

class Messages extends Core {

    /**
     * Get Messages
     */
    public function getMessages() {
        $messages = $this->db->join(DB_PREFIX.'core.message_type', 'message_type.message_type_id=message.message_type_id', 'LEFT')
            ->orderBy('message_id','asc')
            ->get(DB_PREFIX.'core.message');

        return $messages;
    }

    /**
     * Add Message
     */
	public function setMessage($data) {
        $result = $this->db->insert(DB_PREFIX.'core.message', $data);
        return $result;
	}

    /**
     * Update Message
     */
    public function updateMessage($message_id, $data) {
        $result = $this->db->where('message_id', $message_id)
            ->update(DB_PREFIX.'core.message' , $data);
        return $result;
    }

    /**
     * Get Clients From Message
     */
    public function getMessageClientEmails($message_id) {
        $result = $this->db->where('message_2_client_contact.message_id', $message_id)
            ->join(DB_PREFIX.'core.client_contact', 'message_2_client_contact.client_contact_id=client_contact.client_contact_id', 'LEFT')
            ->get(DB_PREFIX.'core.message_2_client_contact', NULL, 'client_contact.*');
        return $result;
    }

    public function setMessageToClientContact($data) {
        $result = $this->db->insertMulti(DB_PREFIX . 'core.message_2_client_contact', $data);
        return $result;
    }

    public function deleteMessageToClientContact($message_id) {
        $this->db->where('message_id', $message_id)
            ->delete(DB_PREFIX.'core.message_2_client_contact');
        return;
    }
}

?>
