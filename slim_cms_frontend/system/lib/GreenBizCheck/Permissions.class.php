<?php
namespace GreenBizCheck;

class Permissions extends Core {

    /**
     * Get Client Permissions
     *
     * @param int $id client_contact_id
     * @return void
     */
    public function getClientPermissions($id) {
        static $permissions = null;
        if(!is_null($permissions)) {
            return $permissions;
        }

        $results = $this->db
            ->where('cc2d.client_contact_id', $id)
            ->join(DB_PREFIX.'dashboard.dashboard_2_client_type d2ct', 'cc2d.dashboard_group_id=d2ct.dashboard_group_id')
            ->join(DB_PREFIX.'core.client c', 'd2ct.client_type_id=c.client_type_id')
            ->get(DB_PREFIX.'dashboard.client_contact_2_dashboard cc2d', NULL, 'c.client_id');

        $permissions = array_column($results, 'client_id');

        return $permissions;
    }

    /**
     * Set Client Permissions
     *
     * @param array $data
     * @param int $id client_contact_id
     * @return void
     */
    public function setClientPermissions($data, $id) {
        return $permissions;       
    }

    /**
     * Get Checklist Permissions
     *
     * @param int $id
     * @return void
     */
    public function getChecklistPermissions($id) {
        static $permissions = null;
        if(!is_null($permissions)) {
            return $permissions;
        }

        $results = $this->db
            ->where('cc2d.client_contact_id', $id)
            ->join(DB_PREFIX.'dashboard.dashboard_2_checklist d2c', 'cc2d.dashboard_group_id=d2c.dashboard_group_id')
            ->get(DB_PREFIX.'dashboard.client_contact_2_dashboard cc2d', NULL, 'd2c.checklist_id');

        $permissions = array_column($results, 'checklist_id');

        return $permissions;  
    }

    /**
     * Set Checklist Permissions
     *
     * @param array $data
     * @param int $id client_contact_id
     * @return void
     */
    public function setChecklistPermissions($data, $id) {
        return $permissions;       
    }

    /**
     * Get Group Permissions
     *
     * @param int $id
     * @return void
     */
    public function getGroupPermissions($id) {
        static $permissions = null;
        if(!is_null($permissions)) {
            return $permissions;
        }

        $results = $this->db
            ->where('cc2d.client_contact_id', $id)
            ->join(DB_PREFIX.'dashboard.user_defined_group udg', 'cc2d.dashboard_group_id=udg.dashboard_group_id')
            ->get(DB_PREFIX.'dashboard.client_contact_2_dashboard cc2d', NULL, 'udg.user_defined_group_id');

        $permissions = array_column($results, 'user_defined_group_id');

        return $permissions;  
    }

    /**
     * Get Client Checklist Permissions
     *
     * @param int $id client conact id
     * @return void
     */
    public function getClientChecklistPermissions($id) {
        static $permissions = null;
        if(!is_null($permissions)) {
            return $permissions;
        }

        $clients = $this->getClientPermissions($id);
        $checklists = $this->getChecklistPermissions($id);

        $results = $this->db->where('cc.client_id', empty($clients) ? [null] : $clients, 'IN' )
            ->where('cc.checklist_id', empty($checklists) ? [null] : $checklists, 'IN')
            ->get(DB_PREFIX.'checklist.client_checklist cc', NULL, 'cc.client_checklist_id');
        
        $permissions = array_column($results, 'client_checklist_id');

        return $permissions;
    }
}
?>