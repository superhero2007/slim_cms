<?php
namespace GreenBizCheck;

class Questions extends Core {
    /**
     * Get Questions
     *
     * @param Array or String $id Question Id
     * @param int $checklist_id CheckList Id
     * @return void
     */
    public function getQuestions($checklist_id, $id) {
        $id = is_array($id) ? array_values($id) : explode(',', $id);
        $results = $this->db->where('cc.checklist_id', $checklist_id)
            ->where('q.question_id', $id, 'IN')
            ->join(DB_PREFIX.'checklist.client_result cr', 'cr.question_id = q.question_id', 'LEFT')
            ->join(DB_PREFIX.'checklist.client_checklist cc', 'cc.client_checklist_id = cr.client_checklist_id', 'LEFT')
            ->get(DB_PREFIX.'checklist.question q', NULL, 'q.*');

        return $results;
    }

    /**
     * Set Question
     * Creates user defined Question
     *
     * @param array $data
     * @return void
     */
    public function setQuestion($data) {
        $result = $this->db->insert(DB_PREFIX.'checklist.question', $data);
        return $result;
    }

    /**
     * Delete Question
     *
     * @param int $id Question Id
     * @return void
     */
    public function deleteQuestion($id) {
        $result = $this->db->where('question_id', $id)
            ->delete(DB_PREFIX.'checklist.question');

        return $result;
    }
}