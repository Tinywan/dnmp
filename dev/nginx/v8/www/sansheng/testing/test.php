<?php
mkdir("testing");
$data = "在PHP中文网学好PHP，妹子票子不再话下！";

$numbytes = file_put_contents('binggege.txt', $data); //如果文件不存在创建文件，并写入内容

if($numbytes){

    echo '写入成功，我们读取看看结果试试：';

    echo file_get_contents('binggege.txt');

}else{
    echo '写入失败或者没有权限，注意检查';
}