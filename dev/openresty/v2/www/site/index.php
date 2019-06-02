<?php
function testRedis()
{
    $redis = new \Redis();
    var_dump($redis);
    try {
        $redis->connect('dnmp-redis-v2', 6379);
        var_dump($redis->keys("*"));
        // $redis->set('Name',"Tinywan");
        var_dump($redis->get("Name"));
    } catch (\Exception $e) {
        var_dump($e->getMessage());
    }
}
testRedis();
// phpinfo();
