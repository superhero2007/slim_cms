<?php
namespace GreenBizCheck;

class Clients extends Core {

    /**
     * Get Clients
     *
     * @param int $id
     * @return void
     */
    public function getClients($id) {
        $id = is_array($id) ? array_values($id) : explode(',', $id);
        $id = empty($id) ? Array('') : $id;
        
        $clients = $this->db->where('c.client_id', $id, 'IN')
            ->get(DB_PREFIX.'core.client c');

        return $clients;
    }
}
?>