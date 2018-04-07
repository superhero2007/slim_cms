<?php
/**
 * Dependency Injection
 */
$container = $app->getContainer();

/**
 * View Renderer
 */
$container['renderer'] = function ($c) {
    $settings = $c->get('settings')['renderer'];
    return new Slim\Views\PhpRenderer($settings['template_path']);
};

/**
 * Monolog
 */
$container['logger'] = function ($c) {
    $settings = $c->get('settings')['logger'];
    $logger = new Monolog\Logger($settings['name']);
    $logger->pushProcessor(new Monolog\Processor\UidProcessor());
    $logger->pushHandler(new Monolog\Handler\StreamHandler($settings['path'], $settings['level']));
    return $logger;
};

/**
 * Database
 */
$container['db'] = function ($c) {
    $settings = $c->get('settings')['db'];

    //Default Database
    $db = new MysqliDb(Array('host' => $settings['host'], 'username' => $settings['username'], 'password' => $settings['password'],'db' => $settings['dbprefix'] . $settings['db']));
    
    //Other Connections
    foreach ($settings['connections'] as $key=>$connection) {
        $db->addConnection($connection, Array('host' => $settings['host'], 'username' => $settings['username'], 'password' => $settings['password'],'db' => $settings['dbprefix'] . $connection));
    }
    
    return $db;
};

/**
 * JWT
 */
$container['jwt'] = function ($c) {
    return $c->get('settings')['jwt'];
};

/**
 * Controllers
 */
 $container['Clients'] = function($container) {
     return new \App\Controllers\Clients($container);
 };

$container['ClientRoles'] = function($container) {
    return new \App\Controllers\ClientRoles($container);
};

 $container['ClientContacts'] = function($container) {
    return new \App\Controllers\ClientContacts($container);
};

$container['ClientChecklists'] = function($container) {
    return new \App\Controllers\ClientChecklists($container);
};

$container['Checklists'] = function($container) {
    return new \App\Controllers\Checklists($container);
};

$container['Auth'] = function($container) {
    return new \App\Controllers\Auth($container);
};

$container['Permissions'] = function($container) {
    return new \App\Controllers\Permissions($container);
};
