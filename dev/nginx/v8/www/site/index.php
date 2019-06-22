<?php
phpinfo();

function testRedis()
{
    $redis = new \Redis();
    var_dump($redis);
    try {
        $redis->connect('lnmp-redis-v8', 6379);
        var_dump($redis->keys("*"));
        var_dump($redis->get("Name"));
    } catch (\Exception $e) {
        var_dump($e->getMessage());
    }
}

testRedis();