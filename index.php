<?php

declare(strict_types=1);

require __DIR__ . '/vendor/autoload.php';

// This is a PHP file example.
// Replace it with your application.

$name = $_GET['name'];
$query = $_SERVER['QUERY_STRING'];
$remote = $_SERVER['HTTP_X_FORWARDED_FOR'];
$request = $_SERVER['REQUEST_URI'];

$copied_server = [];

foreach ($_SERVER as $key => $value) {
    if ($key === 'AWS_SESSION_TOKEN') {
        continue;
    }
    $copied_server[$key] = $value;
}

$encoded_server = json_encode($copied_server, JSON_PRETTY_PRINT);
// Below is a welcome page written in HTML.
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Welcome to Serverless PHP</title>
    <link href="https://fonts.googleapis.com/css?family=Dosis:300&display=swap" rel="stylesheet">
    <!-- <script src="https://cdn.tailwindcss.com"></script> -->
</head>

<body>
    <div class="flex container mx-auto justify-center">
        <div class="justify-center">
            <h1 class="text-3xl">Welcome to PHP in lambda</h1>
            <p>This page was rendered using plain php on a lambda handler</p>
            <p>Try <a class="font-medium underline" href="/?name=Jay">requesting</a> this page with a <code>name</code> query parameter</p>
            <p>Hello <?= empty($name) ? "World" : $name ?></p>
            <p>You requested <?= $request ?> from <?= $remote ?></p>
            <pre><?= $encoded_server ?></pre>
        </div>

    </div>
</body>

</html>