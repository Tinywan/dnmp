<?php
phpinfo();

// 测试Redis
function testRedis()
{
    $redis = new \Redis();
    var_dump($redis);
    try {
        $redis->connect('dnmp-redis', 63789);
        var_dump($redis->keys("*"));
        var_dump($redis->get("Name"));
    } catch (\Exception $e) {
        var_dump($e->getMessage());
    }
}


// 测试MySQL
function testMySQL()
{
    $servername = "dnmp-mysql";
    $username = "root";
    $password = "123456";
    $dbname = "mysql";
    $conn = mysqli_connect($servername, $username, $password, $dbname);
    if (!$conn) {
        die("连接失败: " . mysqli_connect_error());
    }

    $sql = "SELECT Host,User FROM user";
    $result = mysqli_query($conn, $sql);

    if (mysqli_num_rows($result) > 0) {
        while ($row = mysqli_fetch_assoc($result)) {
            echo "Host: " . $row["Host"] . " - User: " . $row["User"] . "<br>";
        }
    } else {
        echo "0 结果";
    }
    mysqli_close($conn);
}

// testRedis();
// testMySQL();

