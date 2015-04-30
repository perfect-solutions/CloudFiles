<?php

$public_url = require(__DIR__ . "/config.public_url.php");

return array(
    'backend' => array(
        'shard_a' => array(
            'write' => true,
            'replicas' => array(
                'http://sh-1-rpl-0.example.com/',
		'http://sh-1-rpl-1.example.com/'
            ),
            'publicUrl' => $public_url['shard_b'],
        ),
        'shard_b' => array(
            'write' => true,
            'replicas' => array(
                'http://sh-2-rpl-0.example.com/',
		'http://sh-2-rpl-1.example.com/'
            ),
            'publicUrl' => $public_url['shard_b'],
        ),
    ),
);
