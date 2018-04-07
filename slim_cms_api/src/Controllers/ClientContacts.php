<?php
namespace App\Controllers;

Class ClientContacts
{
    protected $db;

    public function __construct($container)
    {
        $this->db = $container['db'];
    }

    /**
     * Get Client Contacts
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function getClientContacts($request, $response, $args) {
        $this->db->where('cc.client_id',$args['client_id']);
        isset($args['client_contact_id']) ? $this->db->where('cc.client_contact_id', $args['client_contact_id']) : null;

        $data = $this->db->get('client_contact cc', null, ['cc.*']);

        return $response->withJson($data, 200);        
    }

    /**
     * Set Client Contact
     *
     * @param [type] $request
     * @param [type] $response
     * @param [type] $args
     * @return void
     */
    public function setClientContact($request, $response, $args) {
        $input = $request->getParsedBody();
        !isset($args['client_id']) ?: $input['client_id'] = $args['client_id'];

        $data = $this->db->insert('client_contact', $input);

        return $response->withJson($data, $data ? 201 : 404);        
    }
}

