<?php
return [
    'settings' => [
        'displayErrorDetails' => true, // set to false in production
        'addContentLengthHeader' => false, // Allow the web server to send the content-length header

        // JWT Settings
        'jwt' => [
            'secret' => 'Uz77HPQftuKZ4TeYT3g8OXl7AzIoWK4Ay021aErE',
            'https' => false,
            'expiry' => '+7 days',
            'algorithm' => 'HS256'
        ],

        // Renderer settings
        'renderer' => [
            'template_path' => __DIR__ . '/../templates/',
        ],

        // Monolog settings
        'logger' => [
            'name' => 'api.greenbizcheck.com',
            'path' => isset($_ENV['docker']) ? 'php://stdout' : __DIR__ . '/../logs/app.log',
            'level' => \Monolog\Logger::DEBUG,
        ],

        // Database connection settings
        'db' => [
            'host' => 'localhost',
            'username' => '', //Your Username
            'password' => '', //Your Password
            'db' => 'core',
            'dbprefix' => 'greenbiz_',
            'connections' => [
                'checklist' => 'checklist',
                'ghg' => 'ghg',
                'dashboard' => 'dashboard'
            ]
        ]
    ],
];
