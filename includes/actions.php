<?php

function upload(CloudFiles $cf)
{
    if (!empty($_SERVER['HTTP_X_FILENAME'])) {
        $name = $_SERVER['HTTP_X_FILENAME'];
    } else {
        $name = $_FILES['upload']['name'];
    }
    $name = preg_replace('@/+@','/', $name);
    if (!preg_match('@^/@', $name)) {
	return json_encode([
	    'status' => 'fail',
	    'message' => 'uri must be starts with /',
	]);
    }

    if (!empty($_FILES['upload'])){
	$tmpFile = $_FILES['upload']['tmp_name'];
	$size = filesize($tmpFile);

	list($status, $url, $message) = $cf->uploadfile($name, file_get_contents($tmpFile), $size);
	if ($status) {
	    $result = json_encode(array(
		'status' => 'ok',
		'links' => array($url),
	    ));
	} else {
	    header('HTTP/1.1 503 Service Down');
	    $result = json_encode(array(
		'status' => 'fail',
	        'message' => $message,
	    ));
	}
    } else {
	header('HTTP/1.1 503 Service Down');
	$result = json_encode(array(
	    'status' => 'fail',
	    'message' => 'PHP UPLOAD: can\'t upload or file missed',
	));
    }
    return $result;
}

function remove(CloudFiles $cf)
{
    if (empty($_GET['filename'])) {
	header('HTTP/1.1 400 filename missed');
	$result = json_encode(array(
	    'status' => 'fail',
	    'message' => 'uri must be have the filename parameter: /?action=remove&filename=... ',
	));
	return $result;
    }
    $filename = $_GET['filename'];

    if (!preg_match('@(https?://[^/]+/)(.+)@', $filename, $matches)) {
	header('HTTP/1.1 400 invalid url');
	$result = json_encode(array(
	    'status' => 'fail',
	    'message' => 'filename parameter must be a valid url stored in CloudFiles',
	));
	return $result;
    }

    $result = $cf->deletefile($filename);
    if ($result) {
	$result = json_encode(array(
	    'status' => 'ok',
        ));
    } else {
	$result = json_encode(array(
	    'status' => 'fail',
	    'message' => 'not found',
        ));

    }
    return $result;
}
