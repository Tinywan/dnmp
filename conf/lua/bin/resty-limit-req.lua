--[[-----------------------------------------------------------------------      
* |  Copyright (C) Shaobo Wan (Tinywan) 
* |------------------------------------------------------------------------
* |  Author: Tinywan
* |  Date Time : 2019/5/28 16:25
* |  Email: Overcome.wan@Gmail.com
* |  Desc: 网关接口限流
* |     1. Redis 白名单过滤
* |     2. limit 限流
* |------------------------------------------------------------------------
--]]

local redis = require "resty.redis"
local limit_req = require "resty.limit.req"
local var = ngx.var

local rate = 1 --固定平均速率2r/s
local burst = 3 --桶容量
local error_status = 503
local nodelay = false --是否需要不延迟处理

-- redis config
local redis_host = "172.19.0.1"
local redis_port = 6379
local redis_timeout = 1000
local red = redis:new()
red:set_timeout(redis_timeout)
local ok, err = red:connect(redis_host, redis_port)
if not ok then
    ngx.log(ngx.ERR, "connect to redis error : ", err)
end

-- filter ip
local ip = ngx.var.remote_addr
ngx.log(ngx.ERR, "remote_addr: "..ip)
--ngx.log(ngx.ERR, "referrer: "..var.referrer)
local black_key = "IP:BLACK:LIST"
local is_ok = red:SISMEMBER(black_key,ip)
if (tonumber(is_ok) == 1) then
    --ngx.exit(ngx.HTTP_FORBIDDEN)
    ngx.redirect("https://github.com/Tinywan", 302)
end

-- limit rate
local lim, err = limit_req.new("my_req_store", rate, burst)
if not lim then --没定义共享字典
    ngx.exit(error_status)
end

local key = ngx.var.binary_remote_addr --IP维度限流
--请求流入，如果你的请求需要被延迟则返回delay>0
local delay, err = lim:incoming(key, true)

if not delay then
    if err == "rejected" then
        -- add ip to black_list
        -- red:add(black_key,ip)
        ngx.log(ngx.ERR, "ip : ", ip)
        ngx.log(ngx.ERR, "redis: add ", red:sadd(black_key,ip))
        ngx.log(ngx.ERR, "error: 503 ", err)
        return ngx.exit(503)
    end
    ngx.log(ngx.ERR, "failed to limit traffic: ", err)
    return ngx.exit(500)
end

if delay > 0 then --根据需要决定延迟或者不延迟处理
    if nodelay then
        --直接突发处理
        ngx.log(ngx.ERR,"直接突发处理")
    else
        ngx.log(ngx.ERR,"延迟处理")
        ngx.sleep(delay) --延迟处理
    end
end

