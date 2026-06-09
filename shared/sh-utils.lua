function SetStatebag(netId, key, value, replicated)
    if cache.game ~= "fxserver" and replicated then
        return lib.callback.await("filo_muffler:server:SetStatebag", nil, "entity:" .. netId, key, value)
    else
        local packed = msgpack.pack(value)
        SetStateBagValue("entity:" .. netId, key, packed, #packed, replicated)
        return true
    end
end

function GetStatebag(netId, key)
    local value = GetStateBagValue("entity:" .. netId, key)
    return value
end