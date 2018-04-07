<?php
namespace GreenBizCheck;

class Submissions extends Core {

    /**
     * Submission = clientChecklist
     */

    /**
     * Get submissions
     *
     * @param Array $clientChecklists An array of clientChecklist identifiers
     * @param array (optional) $checklists An array of checklist identifiers
     * @return void
     */
    public function getSubmissions($clientChecklists, $checklists = null) {
        !is_array($checklists) ?: $this->db->where('cc.checklist_id', $checklists, 'IN');

        $results = $this->db->where('cc.client_checklist_id', empty($clientChecklists) ? [null] : $clientChecklists, 'IN')
            ->join(DB_PREFIX.'checklist.client_result cr', 'cc.client_checklist_id=cr.client_checklist_id', 'LEFT')
            ->groupBy('cc.client_checklist_id')
            ->get(DB_PREFIX.'checklist.client_checklist cc', NULL, 'cc.*, MAX(cr.timestamp) AS saved');

        return $results;
    }

    /**
     * Get submission results
     *
     * @param array $clientChecklists An array of clientChecklist identifiers
     * @param array (optional) $questions An array of question identifiers
     * @return void
     */

    public function getAnswers($clientChecklists, $questions = []) {
        empty($questions) ?: $this->db->where('cr.question_id', $questions, 'IN');

        $results = $this->db->where('cr.client_checklist_id', empty($clientChecklists) ? [null] : $clientChecklists, 'IN')
            ->join(DB_PREFIX.'checklist.answer a', 'cr.answer_id=a.answer_id', 'LEFT')
            ->join(DB_PREFIX.'checklist.answer_string ans', 'a.answer_string_id=ans.answer_string_id', 'LEFT')
            ->orderBy('cr.client_checklist_id', 'ASC')
            ->orderBy('cr.index', 'ASC')
            ->get(DB_PREFIX.'checklist.client_result cr', NULL, 'cr.*, ans.string');

        return $results;
    }

    /**
     * Set submission
     * Creates user defined submission
     *
     * @param array $data
     * @return void
     */
    public function setSubmission($data) {
        $result = $this->db->insert(DB_PREFIX.'checklist.client_checklist', $data);
        return $result;
    }

    /**
     * Delete submission
     *
     * @param int $id submission Id
     * @return void
     */
    public function deleteForm($id) {
        $result = $this->db->where('client_checklist_id', $id)
            ->delete(DB_PREFIX.'checklist.client_checklist');

        return $result;
    }

}