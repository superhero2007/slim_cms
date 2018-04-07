<?php
namespace GreenBizCheck;

class Forms extends Core {
    /**
     * Get Forms
     *
     * @param Array or String $id CheckList Id
     * @return void
     */
    public function getForms($id) {
        $id = is_array($id) ? array_values($id) : explode(',', $id);
        $results = $this->db->where('checklist.checklist_id', $id, 'IN')
            ->get(DB_PREFIX.'checklist.checklist ch', NULL, 'ch.*');

        return $results;
    }

    /**
     * Set Form
     * Creates user defined form
     *
     * @param array $data
     * @return void
     */
    public function setForm($data) {
        $result = $this->db->insert(DB_PREFIX.'checklist.checklist', $data);
        return $result;
    }

    /**
     * Delete Form
     *
     * @param int $id Form Id
     * @return void
     */
    public function deleteForm($id) {
        $result = $this->db->where('checklist_id', $id)
            ->delete(DB_PREFIX.'checklist.checklist');

        return $result;
    }
}