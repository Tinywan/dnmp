<?php
/**.-------------------------------------------------------------------------------------------------------------------
 * |  Author: Tinywan(ShaoBo Wan)
 * |  DateTime: 2018/12/4 14:20
 * |  Mail: 756684177@qq.com
 * |  Desc: 支付Demo
 * '------------------------------------------------------------------------------------------------------------------*/


class PayDemo
{
    /**
     * Api公共请求
     * @param $api_name string 接口方法名
     * @param $data array 请求业务参数
     * @return mixed
     */
    public function request($method, $data)
    {
        $gate_way_url = 'https://pay.sunspay.com/api/gateway'; //网关
        $mch_id = '12001';
        $data = [
            'mch_id' => $mch_id,
            'method' => $method,
            'version' => '1.0',
            'timestamp' => time(),
            'content' => json_encode($data)
        ];
        $sign = $this->sign($data);
        if (!$sign) {
            exit('签名失败');
        }
        $data['sign'] = $sign;
        //将所有参数urlencode编码，防止中文乱码
        foreach ($data as &$item) {
            $item = urlencode($item);
        }
        unset($item);
        $result = $this->curl_post($gate_way_url, $data); //post请求
        return json_decode($result, true); // json 格式转换为数组格式
    }

    /**
     * 签名
     * @param $data array 签名数据
     * @return string
     */
    private function sign($data)
    {
        // 解码
        foreach ($data as $key => &$value) {
            $value = urldecode($value);
        }
        unset($value);

        // 如果有sign，去除sign
        if (isset($data['sign'])) {
            unset($data['sign']);
        }
        $key = '121111as2d12a2s1da1das';  //商户秘钥
        ksort($data);  //数组正序排序
        $params_str = urldecode(http_build_query($data));    //拼接
        $params_str = $params_str . '&key=' . $key;  //拼接商户秘钥在最后面
        return md5($params_str);  //返回md5结果
    }

    /**
     * Curl post请求
     * @param $url string 请求网关地址
     * @param array $data 请求数据报文
     * @return mixed
     */
    private function curl_post($url, $data = [])
    {
        $curl = curl_init();
        curl_setopt($curl, CURLOPT_URL, $url);
        curl_setopt($curl, CURLOPT_HEADER, 0);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($curl, CURLOPT_POST, 1);
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
        $result = curl_exec($curl);
        curl_close($curl);
        return $result;
    }
}

// 接口方法名
$method = "shop.payment.aliH5";

// 业务参数
$content = [
    'total_fee' => 10,
    'goods' => '支付宝H5测试',
    'client' => 'wap',
    'client_ip' => '127.0.0.1',
    'order_sn' => time(),
    'notify_url' => 'https://www.baidu.com/notify_url',
    'return_url' => 'https://www.baidu.com/return_url'
];

$pay = new PayDemo();
$res = $pay->request($method, $content);
// 打印接口返回数据
var_dump($res);