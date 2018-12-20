<?php
// phpinfo();
$redis = new \Redis();
var_dump($redis);
try {
    $redis->connect('lnmp-redis-v3', 63789);
    var_dump($redis->keys("*"));
} catch (\Exception $e) {
    var_dump($e->getMessage());
}

// $servername = "lnmp-mysql-v3";
// $username = "root";
// $password = "123456";
// $dbname = "docker";
// $conn = mysqli_connect($servername, $username, $password, $dbname);
// if (!$conn) {
//     die("连接失败: " . mysqli_connect_error());
// }

// $sql = "SELECT id,name FROM test";
// $result = mysqli_query($conn, $sql);

// if (mysqli_num_rows($result) > 0) {
//     while ($row = mysqli_fetch_assoc($result)) {
//         echo "id: " . $row["id"] . " - Name: " . $row["name"] . "<br>";
//     }
// } else {
//     echo "0 结果";
// }
// mysqli_close($conn);