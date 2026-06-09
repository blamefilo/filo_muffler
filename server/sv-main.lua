RegisterNetEvent('filo_muffler:server:checkVehicle', function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or not DoesEntityExist(vehicle) then return end

    local plate = GetVehicleNumberPlateText(vehicle)
    local vehicleData = GetVehicleData(plate) or {}

    if vehicleData.mufflerSound then
        SetStatebag(netId, 'mufflerSound', vehicleData.mufflerSound, true)
    else
        SetStatebag(netId, 'mufflerSound', 'default', true)
    end
end)

lib.callback.register('filo_muffler:server:setMufflerSound', function(source, netId, sound)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or not DoesEntityExist(vehicle) then return false end

    local plate = GetVehicleNumberPlateText(vehicle)
    local vehicleData = GetVehicleData(plate) or {}

    vehicleData.mufflerSound = sound
    SetVehicleData(plate, vehicleData)
    SetStatebag(netId, 'mufflerSound', sound, true)

    return true
end)

lib.callback.register('filo_muffler:server:resetMufflerSound', function(source, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or not DoesEntityExist(vehicle) then return false end

    local plate = GetVehicleNumberPlateText(vehicle)
    local vehicleData = GetVehicleData(plate) or {}

    vehicleData.mufflerSound = nil
    SetVehicleData(plate, vehicleData)
    SetStatebag(netId, 'mufflerSound', 'default', true)

    return true
end)

lib.addCommand(Config.Command, {
    help = 'Change engine sound',
    restricted = Config.CommandPermissions
}, function(source, args, raw)
    TriggerClientEvent('filo_muffler:client:openMenu', source, true)
end)