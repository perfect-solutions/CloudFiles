<?php

class CloudFilesClient
{

    const STATUS_OK = 'ok';
    const STATUS_FAIL = 'fail';


    private $cf_server_url;

    public function __construct($cf_server_url)
    {
	assert('!empty($cf_server_url)');
	assert('preg_match("/^http/", $cf_server_url)');
	$this->cf_server_url = $cf_server_url;
    }

    /**
    * $url - Full URL to file for remove (with protocol, domain, uri)
    * 
    * return bool=true or throws \Exception
    **/
    public function remove($url)
    {
	assert('!empty($url)');
	assert('preg_match("/^http/", $url)');
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $this->cf_server_url.'?action=remove&filename='.urlencode($url));
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
	curl_setopt($ch, CURLOPT_POST, true);
	$result = curl_exec($ch);
	if ($result === false) {
	    throw new \Exception(curl_error($ch), 6);
	}

	$response = json_decode($result, true);

	if (!$response) {
	    throw new \Exception('Bad JSON: ' . var_export($response, true), 7);
	}

	if ($response['status'] !== self::STATUS_OK) {
	    throw new \Exception('Service return FAIL: ' . $response['message'], 8);
	}

	return true;
    }

    /**
    * $file - path in your local filesystem to file for upload
    * $uri  - relative (/bla/bla/bla.bmp) filename for uploading file. If file exists, it will be rewrited
    *
    * return bool=true or throws \Exception
    **/
    public function upload($file, $uri)
    {
	assert('!empty($uri)');
	assert('!preg_match("/^http/", $uri)');
	if (!is_file($file)) {
	    throw new \Exception("\$file must be exists file (is_file() checks must be passed)", 5);
	}

	$fileStr = sprintf('@%s', $file);

	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $this->cf_server_url.'?action=upload');
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
	curl_setopt($ch, CURLOPT_POST, true);
	@curl_setopt($ch, CURLOPT_SAFE_UPLOAD, false); //@lynx: for PHP 5.6
	@curl_setopt($ch, CURLOPT_POSTFIELDS, ['upload' => $fileStr]); //@lynx: @todo: uncomment and fix deprecated
	curl_setopt($ch, CURLOPT_HTTPHEADER, array("X-FILENAME: $uri"));

	$result = curl_exec($ch);
	if ($result === false) {
	    throw new \Exception(curl_error($ch), 6);
	}

	$response = json_decode($result, true);

	if (!$response) {
	    throw new \Exception('Bad JSON: ' . var_export($result, true), 7);
	}

	if ($response['status'] !== self::STATUS_OK) {
	    throw new \Exception('Service return FAIL', 8);
	}

	if (empty($response['links']) && !is_array($response['links'])) {
	    throw new \Exception('Service does not return urls', 9);
	}

	return array_shift($response['links']);
    }


}


$cf = new CloudFilesClient('http://upload.example.com/');
$r = rand(111111,9999999);
file_put_contents(__DIR__."/testfile", $r);
$url = ($cf->upload(__DIR__."/testfile", "/testdir/testfile"));
echo "upload passed\n";
if (file_get_contents($url) == $r) {
    echo "download passed\n";
}
if ($cf->remove($url)) {
    echo "remove passed\n";
}
if (@file_get_contents($url) === null) {
    echo "removed ok\n";
}


