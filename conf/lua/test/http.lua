--[[-----------------------------------------------------------------------      
* |  Copyright (C) Shaobo Wan (Tinywan) 
* |------------------------------------------------------------------------
* |  Author: Tinywan
* |  Date Time : 2019/5/28 16:25
* |  Email: Overcome.wan@Gmail.com
* |------------------------------------------------------------------------
--]]

local url = require "net.url"
local u = url.parse("https://www.tinywan.com/p/124.html")
ngx.say("scheme: ",u.scheme)
ngx.say("host: ",u.host)
ngx.say("path: ",u.path)