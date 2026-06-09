local appliedSounds = {}

RegisterNetEvent('filo_muffler:client:openMenu', function(isCommand)
    if not isCommand then
        local jobName, jobGrade = Framework.GetPlayerJobData()
        if Config.AllowedJobs and (not Config.AllowedJobs[jobName] or Config.AllowedJobs[jobName] < jobGrade) then
            Notify.SendNotification('Error', 'You don\'t have permission to do that.', 'error')
            return
        end

        if Config.RequiredItem and not Inventory.HasItem(Config.RequiredItem) then
            Notify.SendNotification('Error', 'You don\'t have the required item.', 'error')
            return
        end
    end

    if cache.vehicle then
        Notify.SendNotification('Error', 'You can\'t change engine while in vehicle.', 'error')
        return
    end

    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords, Config.MaxDistance or 2.5, false)
    if not vehicle or vehicle == 0 then
        Notify.SendNotification('Error', 'No vehicle found nearby.', 'error')
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local options = {}
    table.insert(options, {
        title = 'Change Vehicle Muffler',
        description = 'Change vehicle\'s muffler sound.',
        onSelect = function()
            local input = lib.inputDialog('Muffler Sound', {
                {type = 'input', label = 'Muffler Sound', description = 'Enter the muffler sound name', required = true}
            })
            if not input then return end

            TaskTurnPedToFaceEntity(cache.ped, vehicle, -1)
            Wait(1000)
            local prog = lib.progressBar({
                duration = math.random(Config.ChangeDurationMin, Config.ChangeDurationMax),
                label = 'Installing muffler...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                },
                anim = {
                    dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                    clip = "machinic_loop_mechandplayer",
                    flag = 1,
                },
            })

            ClearPedTasks(cache.ped)
            if not prog then return end

            if not lib.callback.await('filo_muffler:server:setMufflerSound', nil, netId, input[1]) then
                Notify.SendNotification('Error', 'Failed to set muffler sound.', 'error')
            else
                Notify.SendNotification('Success', 'Muffler sound set successfully.', 'success')
            end
        end
    })

    if GetStatebag(netId, 'mufflerSound') then
        table.insert(options, {
            title = 'Remove Vehicle Muffler',
            description = 'Remove vehicle\'s muffler sound.',
            onSelect = function()
                TaskTurnPedToFaceEntity(cache.ped, vehicle, -1)
                Wait(1000)
                local prog = lib.progressBar({
                    duration = math.random(Config.ChangeDurationMin, Config.ChangeDurationMax),
                    label = 'Removing muffler...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                    },
                    anim = {
                        dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                        clip = "machinic_loop_mechandplayer",
                        flag = 1,
                    },
                })

                ClearPedTasks(cache.ped)
                if not prog then return end

                if not lib.callback.await('filo_muffler:server:resetMufflerSound', nil, netId) then
                    Notify.SendNotification('Error', 'Failed to remove muffler sound.', 'error')
                else
                    Notify.SendNotification('Success', 'Muffler sound removed successfully.', 'success')
                end
            end
        })
    end

    lib.registerContext({
        id = 'muffler_menu',
        title = 'Muffler Menu',
        options = options
    })
    lib.showContext('muffler_menu')
end)

local function registerVehicleTargets()
    local jobData = Framework.GetPlayerJobData()
    if Config.AllowedJobs and (not Config.AllowedJobs[jobData.jobName] or Config.AllowedJobs[jobData.jobName] < jobData.gradeRank) then
        return
    end

    exports.ox_target:addGlobalVehicle({
        {
            name = 'filo_muffler',
            icon = 'fa-solid fa-wrench',
            label = 'Manage Muffler',
            distance = Config.MaxDistance or 2.0,
            canInteract = function()
                local jobData = Framework.GetPlayerJobData()
                if Config.RequiredItem and not Inventory.HasItem(Config.RequiredItem) then
                    return false
                end

                if Config.AllowedJobs and not (Config.AllowedJobs[jobData.jobName] and Config.AllowedJobs[jobData.jobName] >= jobData.gradeRank) then
                    return false
                end

                return true
            end,
            event = 'filo_muffler:client:openMenu'
        }
    })
end

local function removeVehicleTargets()
    exports.ox_target:removeGlobalVehicle({
        'filo_muffler'
    })
end

RegisterNetEvent('community_bridge:Client:OnPlayerLoaded', function()
    removeVehicleTargets()
    registerVehicleTargets()
end)

RegisterNetEvent('community_bridge:Client:OnPlayerUnload', removeVehicleTargets)
RegisterNetEvent('community_bridge:Client:OnJobUpdate', function(jobData)
    removeVehicleTargets()
    registerVehicleTargets()
end)

CreateThread(function()
    while true do
        Wait(Config.RestoreScanInterval or 5000)
        if not Framework.GetIsPlayerLoaded() then
            goto continue
        end

        local coords = GetEntityCoords(cache.ped)
        local vehicles = lib.getNearbyVehicles(coords, Config.RestoreScanDistance or 35.0, true)
        local seenVehicles = {}

        for _, data in pairs(vehicles) do
            local vehicle = data.vehicle
            if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                local plate = GetVehicleNumberPlateText(vehicle)
                local netId = NetworkGetNetworkIdFromEntity(vehicle)
                local mufflerSound = GetStatebag(netId, 'mufflerSound')
                seenVehicles[plate] = true

                if mufflerSound and appliedSounds[plate] ~= mufflerSound then
                    appliedSounds[plate] = mufflerSound
                    ForceUseAudioGameObject(vehicle, mufflerSound)
                elseif not mufflerSound and appliedSounds[plate] ~= 'default' then
                    appliedSounds[plate] = 'default'
                    ForceUseAudioGameObject(vehicle, 'default')
                end
            end
        end

        for plate in pairs(appliedSounds) do
            if not seenVehicles[plate] then
                appliedSounds[plate] = nil
            end
        end

        ::continue::
    end
end)

lib.onCache('vehicle', function(vehicle)
    if not vehicle then return end
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if GetStatebag(netId, 'mufflerSound') then return end
    TriggerServerEvent('filo_muffler:server:checkVehicle', netId)
end)

AddStateBagChangeHandler("mufflerSound", nil, function(bagName, key, value, reserved, replicated)
    if not value then return end
    local entity = GetEntityFromStateBagName(bagName)
    if not entity or entity == 0 then return end

    ForceUseAudioGameObject(entity, value)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= cache.resource then return end
    if not Framework.GetIsPlayerLoaded() then return end

    registerVehicleTargets()
end)