<?php
namespace GreenBizCheck;

class Auth extends Core {

    public function setPassword($client_contact_id, $password) {
        $data = Array(
            'password' => $this->db->escape_string(password_hash($password, PASSWORD_DEFAULT)),
            'encrypted' => '1'
        );
        $result = $this->db->where('cc.client_contact_id', $client_contact_id)
            ->update(DB_PREFIX.'core.client_contact cc', $data);
        return $result;
    }

    public function checkPassword($client_contact_id, $password) {
        $result = $this->db->where('cc.client_contact_id', $client_contact_id)
            ->getOne(DB_PREFIX.'core.client_contact cc');
        return password_verify($password, $result['password']);
    }

    public function resetPassword($email, $password) {
        return false;
    }

    public function validatePassword($client_contact_id, $password) {
        return true;
    }
}