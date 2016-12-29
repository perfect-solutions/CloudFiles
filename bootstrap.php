<?php

set_include_path(get_include_path() . PATH_SEPARATOR . __DIR__ . "/lib/WebDavClient/");

require_once('HTTP/WebDAV/Client.php');
require_once(__DIR__ . '/includes/CloudFiles.php');
$config = require(__DIR__ . '/config/config.php');

$cf = new CloudFiles($config);

if (empty($_GET['action']) || !in_array($_GET['action'], array('upload', 'remove'))) {
    header('HTTP/1.1 400 Action lost');
    $result = json_encode(array(
        'status' => 'fail',
        'message' => 'uri must be have valid ?action= parameter',
    ));
    header('Content-Type: application/json');
    echo $result . "\n";
    exit();
}

$action = $_GET['action'];

require_once(__DIR__.'/includes/actions.php');

echo $action($cf) . "\n";

