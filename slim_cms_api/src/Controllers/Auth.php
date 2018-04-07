<?php
namespace App\Controllers;

use \Firebase\JWT\JWT;
use \Tuupola\Base62;
use \DateTime;

Class Auth
{
    protected $db, $jwt, $permissions;

    public function __construct($container)
    {
        $this->db = $container['db'];
        $this->jwt = $container['jwt'];
        $this->permissions = $container['Permissions'];
    }

    public function login($request, $response, $args) {
        $input = $request->getParsedBody();
        $user = $this->authenticateUser(isset($input['email']) ? $input['email'] : null, isset($input['password']) ? $input['password'] : null);
        $user = empty($user) ? [] : array_merge($user, $this->permissions->getDashboardUser($user['client_contact_id']));
        $data = empty($user) ? [] : $this->encodeJWT(['uid' => $user['client_contact_id'], 'email' => $user['email'], 'role' => isset($user['dashboard_role_id']) ? $user['dashboard_role_id'] : null]);

        return $response->withJson($data, empty($user) ? 401 : 201);   
    }

    private function authenticateUser($username, $password) {
        $user = $this->db->where('cc.email', $username)->getOne('client_contact cc');

        if(!empty($user)) {
            $user = password_verify($password, isset($user['password']) ? $user['password'] : null) ? $user : null;
        }        

        return $user;
    }

    private function encodeJWT($data = null) {
        $now = new DateTime();
        $future = new DateTime($this->jwt['expiry']);
        $jti = (new Base62)->encode(random_bytes(16));

        $payload = [
            'iat' => $now->getTimeStamp(),
            'exp' => $future->getTimeStamp(),
            'jti' => $jti
        ];
       
        foreach($data as $key=>$val) {
            $payload[$key] = $val;
        }

        $token = JWT::encode($payload, $this->jwt['secret'], $this->jwt['algorithm']);
        $jwt['token'] = $token;
        $jwt['expires'] = $future->getTimeStamp();

        return $jwt;
    }    
}

