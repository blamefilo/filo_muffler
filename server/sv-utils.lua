local vehicles = {}
local TABLE_NAME = 'filo_muffler'
local tableReady = false
local tableError = nil

local function IsEmptyTable(data)
    return type(data) ~= 'table' or next(data) == nil
end

local function EncodeVehicleData(data)
    local success, encoded = pcall(json.encode, data or {})
    if not success then
        print('^1[Error]^7 filo_muffler data was corrupted or incomplete. Starting with fresh table.')
        return json.encode({})
    end

    return encoded
end

local function DecodeVehicleData(result)
    if not result then return nil end

    local success, data = pcall(json.decode, result)
    if not success or type(data) ~= 'table' then
        print('^1[Error]^7 filo_muffler data was corrupted or incomplete. Starting with fresh table.')
        return nil
    end

    return data
end

local function EnsureTable()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `filo_muffler` (
            `plate`        VARCHAR(15)  NOT NULL,
            `data`         LONGTEXT     NOT NULL,
            `updated_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
                                          ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`plate`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end

local function LoadVehicleData(plate)
    local result = MySQL.scalar.await(
        ('SELECT data FROM `%s` WHERE plate = ?'):format(TABLE_NAME),
        { plate }
    )

    return DecodeVehicleData(result)
end

local function SaveVehicleData(plate, data)
    MySQL.query.await(
        ('INSERT INTO `%s` (plate, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE data = VALUES(data)'):format(TABLE_NAME),
        { plate, EncodeVehicleData(data) }
    )
end

local function DeleteVehicleData(plate)
    MySQL.query.await(
        ('DELETE FROM `%s` WHERE plate = ?'):format(TABLE_NAME),
        { plate }
    )
end

local function IsPlayerOwnedVehicle(plate)
    local result

    if Framework.GetResourceName() == 'es_extended' then
        result = MySQL.scalar.await(
            "SELECT COUNT(*) FROM `owned_vehicles` WHERE plate = ?",
            { plate }
        )
    else
        result = MySQL.scalar.await(
            "SELECT COUNT(*) FROM `player_vehicles` WHERE plate = ?",
            { plate }
        )
    end

    return result and result > 0
end

function SetVehicleData(plate, data)
    if not plate or plate == '' then return end
    while not tableReady and not tableError do Wait(0) end

    if not IsPlayerOwnedVehicle(plate) then return end
    if tableError then return end

    data = data or {}

    if IsEmptyTable(data) then
        vehicles[plate] = nil
        DeleteVehicleData(plate)
        return
    end

    vehicles[plate] = data
    SaveVehicleData(plate, data)
end

function GetVehicleData(plate)
    if not plate or plate == '' then return {} end
    while not tableReady and not tableError do Wait(0) end
    
    if not IsPlayerOwnedVehicle(plate) then return {} end
    if tableError then return {} end
    if vehicles[plate] ~= nil then return vehicles[plate] end

    local data = LoadVehicleData(plate)
    vehicles[plate] = data or {}

    return vehicles[plate]
end

CreateThread(function()
    while not MySQL do Wait(0) end

    local success, err = pcall(EnsureTable)
    if not success then
        tableError = err
        print('^1[Error]^7 filo_muffler could not create SQL table: ' .. tostring(err))
        return
    end

    tableReady = true
end)

lib.callback.register('filo_muffler:server:SetStatebag', function(playerId, bag, key, value)
    local targetType, target = string.strsplit(':', bag, 2)
    local targetId = tonumber(target)

    if targetType ~= 'player' and targetType ~= 'entity' then return false end
    if targetType == 'player' and targetId ~= playerId then return false end

    SetStatebag(target, key, value, true)
    return true
end)
