<?php
/**
 * App Middleware
 */
use Slim\Middleware\JwtAuthentication;
use Tuupola\Middleware\Cors;

$container = $app->getContainer();

$container["JwtAuthentication"] = function ($container) {
    return new JwtAuthentication([
        'secure' => $container->get('settings')['jwt']['https'],
        'secret' => $container->get('settings')['jwt']['secret'],
        'path' => ['/'],
        'passthrough' => ['/v2/auth']
    ]);
};

$container["Cors"] = function ($container) {
    return new Cors([
        "logger" => $container["logger"],
        "origin" => ["*"],
        "methods" => ["GET", "POST", "PUT", "PATCH", "DELETE"],
        "headers.allow" => ["Authorization", "If-Match", "If-Unmodified-Since"],
        "headers.expose" => ["Authorization", "Etag"],
        "credentials" => true,
        "cache" => 0
    ]);
};

$app->add("JwtAuthentication");
$app->add("Cors");