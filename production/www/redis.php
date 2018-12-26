<?php
$redis = new \Redis();
try {
    $redis->connect('lnmp-redis', 63789);
    var_dump($redis->keys("*"));
} catch (\Exception $e) {
    var_dump($e->getMessage());
}