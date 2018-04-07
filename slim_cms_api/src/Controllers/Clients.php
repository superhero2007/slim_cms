<?php
namespace App\Controllers;

Class Clients
{
    protected $db, $permissions;

    public function __construct($container)
    {
        $this->db = $container['db'];
        $this->permissions = $container['Permissions'];
    }

    /**
     * Routes
     */

    /**
     * Get Clients
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getClients($request, $response, $args) {
        $clients = $this->permissions->getClients($request->getAttribute('token')->uid);
        $request->getAttribute('token')->role == 1 ?: $this->db->where('c.client_id', empty($clients) ? Array(null) : $clients, 'IN');
        
        !isset($args['client_id']) ?: $this->db->where('c.client_id', $args['client_id']);

        is_null($request->getQueryParam('client_type_id')) ?: $this->db->where('c.client_type_id', $request->getQueryParam('client_type_id'));
        is_null($request->getQueryParam('company_name')) ?: $this->db->where('c.company_name', $request->getQueryParam('company_name'));
        is_null($request->getQueryParam('status')) ?: $this->db->where('c.status', $request->getQueryParam('status'));
        is_null($request->getQueryParam('not_status')) ?: $this->db->where('c.status', explode(',',$request->getQueryParam('not_status')), 'NOT IN');

        $data = $this->db->get('client c', null, ['c.*']);

        return $response->withJson($data, 200);        
    }

    /**
     * Get Client Types
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getClientTypes($request, $response, $args) {
        $request->getAttribute('token')->role == 1 ?: $this->db->where('ct.client_type_id', $this->permissions->getClientTypes($request->getAttribute('token')->uid), 'IN');

        !isset($args['client_type_id']) ?: $this->db->where('ct.client_type_id', $args['client_type_id']);
        is_null($request->getQueryParam('sort')) ?: $this->db->orderBy($request->getQueryParam('sort'), 'ASC');

        $data = $this->db->get('client_type ct', null, ['ct.*']);

        return $response->withJson($data, 200);        
    }


    /**
     * Set Client
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function setClient($request, $response, $args) {
        $input = $request->getParsedBody();
        $client_id = $this->db->insert('client', $input);

        $data = $this->db->where('client_id', $client_id)->get('client');

        return $response->withJson($data, $client_id ? 201 : 404);        
    }

    /**
     * Delete Client
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function deleteClient($request, $response, $args) {
        $this->db->where('client_id', $args['client_id'])->delete('client_contact');
        $this->db->where('client_id', $args['client_id'])->delete('client_contact_log');
        $this->db->where('client_id', $args['client_id'])->delete('client_address');
        $this->db->where('client_id', $args['client_id'])->delete('client_coordinates');
        $this->db->where('client_id', $args['client_id'])->delete('client_coordinates_error');
        $this->db->where('client_id', $args['client_id'])->delete('client_log');
        $this->db->where('client_id', $args['client_id'])->delete('client_note');

        $data = $this->db->where('client_id', $args['client_id'])->delete('client');
        
        return $response->withJson($data, $data ? 200 : 404);
    }
}

