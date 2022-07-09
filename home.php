<?php

// This is a PHP file example.
// Replace it with your application.

$name = $_GET['name'];
$remote = $_SERVER['HTTP_X_FORWARDED_FOR'];
$request = $_SERVER['REQUEST_URI'];

// Below is a welcome page written in HTML.
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Welcome to Serverless PHP</title>
</head>

<body>
    <div>
        <h1 class="text-3xl">Welcome to PHP in lambda</h1>
        <p>This page was rendered using plain php on a lambda handler</p>
        <p>Try <a class="font-medium underline" href="/?name=Jay">requesting</a> this page with a <code>name</code> query parameter</p>
        <p>Hello <?= empty($name) ? "World" : $name ?></p>
        <p>You requested <?= $request ?> from <?= $remote ?></p>
    </div>
</body>

</html>