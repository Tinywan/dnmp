--[[-----------------------------------------------------------------------      
* |  Copyright (C) Shaobo Wan (Tinywan) 
* |------------------------------------------------------------------------
* |  Author: Tinywan
* |  Date Time : 2019/5/28 16:25
* |  Email: Overcome.wan@Gmail.com
* |------------------------------------------------------------------------
--]]


-- redis config
local redis = require "resty.redis"
local red = redis:new()

-- 容器内部
-- local ok, err = red:connect("172.19.0.2", 6379)
local ok, err = red:connect("dnmp-redis-v2", 6379)

-- 通过宿主机链接
-- local ok, err = red:connect("172.19.0.1", 6379)

-- local ok, err = red:connect("dnmp-redis-v1", 6379)

if not ok then
    ngx.say("failed to connect1: ", err)
    return
end

ok, err = red:set("dog", "an animal1")
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)

local res, err = red:get("dog")
if not res then
    ngx.say("failed to get dog: ", err)
    return
end

if res == ngx.null then
    ngx.say("dog not found.")
    return
end

ngx.say("dog: ", res)



  