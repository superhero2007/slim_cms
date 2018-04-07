<?php

class clientRole extends dbModel {

    public static function toXml($client_role, $doc) {
        $clientRoleNode = self::createElementWithAttributes($doc, 'client_role', $client_role);
        return($clientRoleNode);
    }

    public function setClientToClientRole($data) {
        $query = parent::prepare_query('core', 'client_2_client_role', 'INSERT INTO', $data);
        $this->db->query($query);
        $client_id = $this->db->insert_id;
        return $client_id;
    }
}

?>