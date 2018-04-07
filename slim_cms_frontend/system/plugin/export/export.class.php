<?php

class export extends plugin {
    public $permissions, $export;

    public function __construct() {
        $this->permissions = new \GreenBizCheck\Permissions();
        $this->export = new \GreenBizCheck\Export();
    }

    public function excel() {
        $clients = $this->permissions->getClientPermissions($this->session->get('uid'));
        $checklists = $this->permissions->getChecklistPermissions($this->session->get('uid'));
        return $this->export->excel($clients, $checklists);
    }
}
?>
