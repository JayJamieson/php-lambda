<?php

declare(strict_types=1);

require __DIR__ . '/vendor/autoload.php';

/**
 * Display home page
 */
get("/", "home.php");

/**
 * Show debug information about the current request excluden sensitive information like AWS_SESSION_TOKEN
 */
get("/api/debug", function () {
    header('Content-Type: application/json');

    $copied_server = [];

    foreach ($_SERVER as $key => $value) {
        if ($key === 'AWS_SESSION_TOKEN') {
            continue;
        }
        $copied_server[$key] = $value;
    }

    echo json_encode($copied_server, JSON_PRETTY_PRINT);
});

any('/404', 'home.php');
