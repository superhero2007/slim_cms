<?php
namespace App\Controllers;

Class ClientChecklists
{
    protected $db;

    public function __construct($container)
    {
        $this->db = $container['db'];
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
        !isset($args['client_id']) ?: $this->db->where('cc.client_id', $args['client_id']);
        !isset($args['client_checklist_id']) ?: $this->db->where('cc.client_checklist_id', $args['client_checklist_id']);
        is_null($request->getQueryParam('sort')) ?: $this->db->orderBy($request->getQueryParam('sort'), 'ASC');

        $data = $this->db->connection('checklist')->get('client_checklist cc', null, ['cc.*']);

        return $response->withJson($data, 200);    
    }

    /**
     * Get Client Checklist Results
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getClientChecklistResults($request, $response, $args) {
        $this->db->join('client_checklist cc','cr.client_checklist_id=cc.client_checklist_id','LEFT');
        $this->db->where('cc.client_checklist_id',$args['client_checklist_id']);
        is_null($request->getQueryParam('question_id')) ?: $this->db->where('cr.question_id', $request->getQueryParam('question_id'));
        is_null($request->getQueryParam('answer_id')) ?: $this->db->where('cr.answer_id', $request->getQueryParam('answer_id'));
        is_null($request->getQueryParam('value')) ?: $this->db->where('cr.arbitrary_value', $request->getQueryParam('value'));
        is_null($request->getQueryParam('index')) ?: $this->db->where('cr.index', $request->getQueryParam('index'));
        is_null($request->getQueryParam('sort')) ?: $this->db->orderBy($request->getQueryParam('sort'), 'ASC');
        
        $data = $this->db->connection('checklist')->get('client_result cr', null, ['cr.*']);

        return $response->withJson($data, 200);
    }

    /**
     * Set Client Checklist
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function setClientChecklist($request, $response, $args) {
        $input = $request->getParsedBody();
        !isset($args['client_id']) ?: $input['client_id'] = $args['client_id'];

        $client_checklist_id = $this->db->connection('checklist')->insert('client_checklist', $input);
        
        $data = $this->db->connection('checklist')->where('client_checklist_id', $client_checklist_id)->get('client_checklist');

        return $response->withJson($data, $client_checklist_id ? 201 : 404);        
    }

    /**
     * Set Client Checklist Result
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function setClientChecklistResult($request, $response, $args) {
        $input = $request->getParsedBody();
        !isset($args['client_checklist_id']) ?: $input['client_checklist_id'] = $args['client_checklist_id'];
        $this->db->connection('checklist');
        $client_result_id = $this->db->connection('checklist')->insert('client_result', $input);

        $data = $this->db->connection('checklist')->where('client_result_id', $client_result_id)->get('client_result');

        return $response->withJson($data, $client_result_id ? 201 : 404);        
    }

    /**
     * Delete Client Checklist Results
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function deleteClientChecklistResults($request, $response, $args) {

        //Query Path
        !isset($args['client_checklist_id']) ?: $this->db->where('client_checklist_id', $args['client_checklist_id']);

        //Query String
        is_null($request->getQueryParam('client_result_id')) ?: $this->db->where('client_result_id', $request->getQueryParam('client_result_id'));
        is_null($request->getQueryParam('question_id')) ?: $this->db->where('question_id', $request->getQueryParam('question_id'));
        is_null($request->getQueryParam('answer_id')) ?: $this->db->where('answer_id', $request->getQueryParam('answer_id'));
        is_null($request->getQueryParam('index')) ?: $this->db->where('`index`', $request->getQueryParam('index'));

        $data = $this->db->connection('checklist')->delete('client_result');

        return $response->withJson($data, $data ? 200 : 404);        
    }
}

