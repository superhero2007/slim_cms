<?php
namespace App\Controllers;

Class ClientRoles
{
    protected $db;

    public function __construct($container)
    {
        $this->db = $container['db'];
    }

    /**
     * Get Client Roles
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getClientRoles($request, $response, $args) {
        // $request->getAttribute('token')->role == 1 ?: $this->db->where('ct.client_type_id', $this->permissions->getClientTypes($request->getAttribute('token')->uid), 'IN');

        !isset($args['client_type_id']) ?: $this->db->where('ct.client_type_id', $args['client_type_id']);
        is_null($request->getQueryParam('sort')) ?: $this->db->orderBy($request->getQueryParam('sort'), 'ASC');

        $data = $this->db->get('client_role ct', null, ['ct.*']);

        return $response->withJson($data, 200);
    }

    /**
     * Set Client Roles
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function setClientRole($request, $response, $args) {
        $input = $request->getParsedBody();
        $client_role_id = $this->db->insert('client_role', $input);

        $data = $this->db->where('client_role_id', $client_role_id)->get('client_role');

        return $response->withJson($data, $client_role_id ? 201 : 404);
    }

    /**
     * Get Client Role Members
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getClientToRoles($request, $response, $args) {
        !isset($args['client_role_id']) ?: $this->db->where('ct.client_role_id', $args['client_role_id']);
        !isset($args['client_id']) ?: $this->db->where('ct.client_id', $args['client_id']);
        is_null($request->getQueryParam('sort')) ?: $this->db->orderBy($request->getQueryParam('sort'), 'ASC');

        $data = $this->db->get('client_2_client_role ct', null, ['ct.*']);

        return $response->withJson($data, 200);
    }

    /**
     * Set Client Role Members
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function setClientToRole($request, $response, $args) {
        $input = $request->getParsedBody();
        $client_role_id = $this->db->insert('client_2_client_role', $input);

        $data = $this->db->where('client_role_id', $client_role_id)->get('client_2_client_role');

        return $response->withJson($data, $client_role_id ? 201 : 404);
    }
}

