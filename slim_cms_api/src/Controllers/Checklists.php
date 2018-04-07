<?php
namespace App\Controllers;

Class Checklists
{
    protected $db, $permissions;

    public function __construct($container)
    {
        $this->db = $container['db'];
        $this->permissions = $container['Permissions'];
    }

    /**
     * Get Checklists
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getChecklists($request, $response, $args) {
        $request->getAttribute('token')->role == 1 ?: $this->db->where('c.checklist_id', $this->permissions->getChecklists($request->getAttribute('token')->uid), 'IN');
        isset($args['checklist_id']) ? $this->db->where('c.checklist_id', $args['checklist_id']) : null;
        is_null($request->getQueryParam('sort')) ?: $this->db->orderBy($request->getQueryParam('sort'), 'ASC');

        $data = $this->db->connection('checklist')->get('checklist c', null, ['c.*']);

        return $response->withJson($data, 200);        
    }

    /**
     * Get Client Checklists
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getClientChecklists($request, $response, $args) {
        $this->db->where('cc.checklist_id',$args['checklist_id']);
        is_null($request->getQueryParam('sort')) ?: $this->db->orderBy($request->getQueryParam('sort'), 'ASC');

        $data = $this->db->connection('checklist')->get('client_checklist cc', null, ['cc.*']);

        return $response->withJson($data, 200);    
    }

    /**
     * Get Checklist Results
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getResults($request, $response, $args) {
        $this->db->join('client_checklist cc','cr.client_checklist_id=cc.client_checklist_id','LEFT');
        $this->db->where('cc.checklist_id',$args['checklist_id']);
        is_null($request->getQueryParam('question_id')) ?: $this->db->where('cr.question_id', $request->getQueryParam('question_id'));
        is_null($request->getQueryParam('answer_id')) ?: $this->db->where('cr.answer_id', $request->getQueryParam('answer_id'));
        is_null($request->getQueryParam('value')) ?: $this->db->where('cr.arbitrary_value', $request->getQueryParam('value'));
        is_null($request->getQueryParam('status')) ?: $this->db->where('cc.status', $request->getQueryParam('status'));
        is_null($request->getQueryParam('not_status')) ?: $this->db->where('cc.status', explode(',',$request->getQueryParam('not_status')), 'NOT IN');
        is_null($request->getQueryParam('sort')) ?: $this->db->orderBy($request->getQueryParam('sort'), 'ASC');
        
        $data = $this->db->connection('checklist')->get('client_result cr', null, ['cr.*']);

        return $response->withJson($data, 200);
    }

    /**
     * Get Checklist Question Options
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getQuestions($request, $response, $args) {
        !isset($args['question_id']) ?: $this->db->where('q.question_id', $args['question_id']);

        $data = $this->db->where('q.checklist_id',$args['checklist_id'])
            ->orderBy('q.sequence', 'ASC')
            ->connection('checklist')
            ->get('question q', null, ['q.*']);
        
        return $response->withJson($data, 200);
    }

    /**
     * Get Checklist Question Answer Options
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getAnswers($request, $response, $args) {
        !isset($args['question_id']) ?: $this->db->where('q.question_id', $args['question_id']);
        !isset($args['answer_id']) ?: $this->db->where('a.answer_id', $args['answer_id']);

        $data = $this->db->join('question q','a.question_id=q.question_id','LEFT')
            ->join('answer_string ans','a.answer_string_id=ans.answer_string_id','LEFT')
            ->where('q.checklist_id',$args['checklist_id'])
            ->orderBy('a.sequence', 'ASC')
            ->connection('checklist')
            ->get('answer a', null, ['a.*, ans.string']);
        
        return $response->withJson($data, 200);
    }

    /**
     * Get Import Profiles
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getImportProfiles($request, $response, $args) {
        $this->db->where('ip.checklist_id',$args['checklist_id']);
        isset($args['import_profile_id']) ? $this->db->where('ip.import_profile_id', $args['import_profile_id']) : null;
        is_null($request->getQueryParam('sort')) ?: $this->db->orderBy($request->getQueryParam('sort'), 'ASC');
        
        $data = $this->db->connection('checklist')->get('import_profile ip', null, ['ip.*']);

        return $response->withJson($data, 200);        
    }

    /**
     * Get Import Profile Maps
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getImportProfileMaps($request, $response, $args) {
        $this->db->where('ipm.import_profile_id',$args['import_profile_id']);
        is_null($request->getQueryParam('sort')) ?: $this->db->orderBy($request->getQueryParam('sort'), 'ASC');
        
        $data = $this->db->connection('checklist')->get('import_profile_map ipm', null, ['ipm.*']);

        return $response->withJson($data, 200);        
    }

    /**
     * Delete Client Checklists
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function deleteClientChecklists($request, $response, $args) {
        isset($args['checklist_id']) ? $this->db->where('checklist_id', $args['checklist_id']) : null;

        $data = $this->db->connection('checklist')->delete('client_checklist');

        return $response->withJson($data, $data ? 200 : 404);        
    }

    /**
     * Get Question and Answers
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getQuestionAnswers($request, $response, $args) {
        is_null($request->getQueryParam('question_id')) ?: $this->db->where('q.question_id', $request->getQueryParam('question_id'));
        
        $questions = $this->db->connection('checklist')
            ->where('q.checklist_id',$args['checklist_id'])
            ->orderBy('q.sequence', 'ASC')
            ->get('question q');

        $answers = $this->db->connection('checklist')
            ->join('answer_string ans','a.answer_string_id=ans.answer_string_id','LEFT')
            ->where('a.question_id',empty($questions) ? Array(null) : array_column($questions, 'question_id'), 'IN')
            ->orderBy('a.sequence', 'ASC')
            ->get('answer a', null, ['a.*, ans.string']);


        foreach($questions as $key=>$question) {
            $questions[$key]['answers'] = array();
            foreach($answers as $answer) {
                if($answer['question_id'] == $question['question_id']) {
                    $questions[$key]['answers'][] = $answer;
                }
            }
        }

        return $response->withJson($questions, $questions ? 200 : 404);
    }
}

