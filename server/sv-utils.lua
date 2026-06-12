local vehicles = {}

local function cleanTable(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do
        res[cleanTable(k)] = cleanTable(v)
    end
    return res
end

local function loadBIN(file)
    local binaryData = LoadResourceFile(cache.resource, file, -1)
    if not binaryData or binaryData == "" then return {} end

    local success, myData = pcall(msgpack.unpack, binaryData)
    if not success then
        print("^1[Error]^7 " .. file .. " was corrupted or incomplete. Starting with fresh table.")
        return {}
    end
    return myData or {}
end

local function saveBIN(file, data)
    local tbl = cleanTable(data)
    local binaryBytes = msgpack.pack(tbl)
    SaveResourceFile(cache.resource, file, binaryBytes, #binaryBytes)
end

function SetVehicleData(plate, data)
    vehicles[plate] = data
end

function GetVehicleData(plate)
    return vehicles[plate] or {}
end

lib.callback.register('filo_muffler:server:SetStatebag', function(playerId, bag, key, value)
    local targetType, target = string.strsplit(':', bag, 2)
    local targetId = tonumber(target)

    if targetType ~= 'player' and targetType ~= 'entity' then return false end
    if targetType == 'player' and targetId ~= playerId then return false end

    SetStatebag(target, key, value, true)
    return true
end)

vehicles = loadBIN('data/vehicles.bin')
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= cache.resource then return end

    saveBIN('data/vehicles.bin', vehicles)
end)