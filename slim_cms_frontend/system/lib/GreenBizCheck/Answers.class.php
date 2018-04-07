<?php
namespace GreenBizCheck;

class Answers extends Core {
    /**
     * Get Answers
     *
     * @param Array or String $id Answer Id
     * @param int $checklist_id CheckList Id
     * @param int $question_id Question Id
     * @return void
     */
    public function getAnswers($checklist_id, $question_id, $id) {
        $id = is_array($id) ? array_values($id) : explode(',', $id);
        $results = $this->db->where('cc.checklist_id', $checklist_id)
            ->where('cr.question_id', $question_id)
            ->where('a.answer_id', $id, 'IN')
            ->join(DB_PREFIX.'checklist.client_result cr', 'cr.answer_id = a.answer_id', 'LEFT')
            ->join(DB_PREFIX.'checklist.client_checklist cc', 'cc.client_checklist_id = cr.client_checklist_id', 'LEFT')
            ->get(DB_PREFIX.'checklist.answer a', NULL, 'a.*');

        return $results;
    }

    /**
     * Set Answer
     * Creates user defined Answer
     *
     * @param array $data
     * @return void
     */
    public function setAnswer($data) {
        $result = $this->db->insert(DB_PREFIX.'checklist.answer', $data);
        return $result;
    }

    /**
     * Delete Answer
     *
     * @param int $id Answer Id
     * @return void
     */
    public function deleteAnswer($id) {
        $result = $this->db->where('answer_id', $id)
            ->delete(DB_PREFIX.'checklist.answer');

        return $result;
    }
}