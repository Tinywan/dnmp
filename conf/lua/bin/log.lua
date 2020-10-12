local ctx = ngx.ctx
local lim = ctx.limit_conn
if lim then
    -- if you are using an upstream module in the content phase,
    -- then you probably want to use $upstream_response_time
    -- instead of $request_time below.
    local latency = tonumber(ngx.var.request_time)
    local key = ctx.limit_conn_key
    assert(key)
    local conn, err = lim:leaving(key, latency)
    if not conn then
        ngx.log(ngx.ERR,
                "failed to record the connection leaving ",
                "request: ", err)
        return
    end
end