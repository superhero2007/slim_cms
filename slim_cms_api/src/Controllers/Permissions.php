<?php
namespace App\Controllers;

Class Permissions
{
    protected $db;

    public function __construct($container)
    {
        $this->db = $container['db'];
    }

    /**
     * Get User
     *
     * @param [type] $uid
     * @return void
     */
    public function getDashboardUser($uid) {
        return $this->db->connection('dashboard')
            ->where('cc2d.client_contact_id', $uid)
            ->getOne('client_contact_2_dashboard cc2d');
    }

    /**
     * Get Checklist Permissions
     *
     * @param [type] $uid
     * @return void
     */
    public function getChecklists($uid) {
        $checklists = $this->db->connection('dashboard')
            ->join('client_contact_2_dashboard cc2d', 'cc2d.dashboard_group_id=d2c.dashboard_group_id', 'LEFT')
            ->where('cc2d.client_contact_id',$uid)
            ->get('dashboard_2_checklist d2c', NULL, ['d2c.checklist_id']);

        return array_column($checklists, 'checklist_id');
    }

    /**
     * Get Client Type Permissions
     *
     * @param [type] $uid
     * @return void
     */
    public function getClientTypes($uid) {
        $clientTypes = $this->db->connection('dashboard')
            ->join('client_contact_2_dashboard cc2d', 'cc2d.dashboard_group_id=d2ct.dashboard_group_id', 'LEFT')
            ->where('cc2d.client_contact_id',$uid)
            ->get('dashboard_2_client_type d2ct', NULL, ['d2ct.client_type_id']);

        return array_column($clientTypes, 'client_type_id');
    }

    /**
     * Get Client Permissions 
     *
     * @param [type] $uid
     * @return void
     */
    public function getClients($uid) {
        $clients = $this->db->where('c.client_type_id', $this->getClientTypes($uid), 'IN')
            ->get('client c', NULL, ['c.client_id']);

        return array_column($clients, 'client_id');
    }

}

