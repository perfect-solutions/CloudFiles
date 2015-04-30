<?php

class CloudFiles {

    private $config;

    public function __construct($config){
        $this->config = $config;
    }

    public function uploadfile($name, $binary, $sizeForCheck){
        foreach ($this->config['backend'] as $backend) {
            if ($backend['write'] == false) {
                $lastMessage = 'backend readonly';
                continue;
            }

            $success = true;
            foreach ($backend['replicas'] as $replicaUrl) {
                list($success, $lastMessage) = $this->uploadstring($replicaUrl, $name, $binary, $sizeForCheck);
                if (!$success) break;
            }
            if (!$success) continue;
            return array(true, $backend['publicUrl'] . $name, "success");
        }
        return array(false, null, $lastMessage);
    }

    public function uploadstring($shard, $name, $binary, $sizeForCheck){
        $url = $shard.'/'.$name;

        $ch = curl_init($url);
        $header = "Content-Type: octet/stream";
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array($header));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $binary);
        $returned = curl_exec($ch);
        $responseInfo = curl_getinfo($ch);
        $httpResponseCode = $responseInfo['http_code'];
        curl_close($ch);
        if ($message = curl_error($ch))
        {
            return array(false, $message . " ($shard)");
        } else if (!preg_match('/^2[\d]{2}$/',$httpResponseCode)) {
            return array(false, "Remote status: " . $httpResponseCode . " ($shard)");
        }
        else
        {
            //check size
            $cch = curl_init();
            curl_setopt ($cch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt ($cch, CURLOPT_URL, $url);
            curl_setopt ($cch, CURLOPT_CONNECTTIMEOUT, 20);
            curl_setopt($cch, CURLOPT_HEADER, true); // header will be at output
            curl_setopt($cch, CURLOPT_CUSTOMREQUEST, 'HEAD'); // HTTP request is 'HEAD'
            curl_setopt($cch, CURLOPT_NOBODY, true);
            curl_setopt($cch, CURLOPT_VERBOSE, 1);
            curl_setopt($cch, CURLOPT_HEADER, 1);
            $response = curl_exec ($cch);

            $header_size = curl_getinfo($cch, CURLINFO_HEADER_SIZE);
            $header = substr($response, 0, $header_size);
            $body = substr($response, $header_size);

            if (preg_match('@Content-Length: (\d+)@', $header, $matches)){
                $size = $matches[1];
                if ($size != $sizeForCheck) {
                    return array(false, "broken upload [size=$size of $sizeForCheck] ($shard)");
                }
            } else {
                return array(false, "Can't check upload ($shard)");
            }

            curl_close ($cch);

            return array(true, null);
        }
    }

    public function deletefile($filename){
	$shard = preg_replace('@^(http://[^/]+/).*$@', '\1', $filename);
	$uri = preg_replace('@^http://[^/]+/(.*)$@', '\1', $filename);
	foreach ($this->config['backend'] as $name => $config) {
	    $shardUrl = $config['publicUrl'];
	    if ($shard === $shardUrl) {
		//it is!
		$r = true;
		foreach ($config['replicas'] as $replica) {
		    $r = $r && @unlink('webdav://'.$replica.$filename);
		}
		return $r;
	    }
	}
	return false;
    }
}
