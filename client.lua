local isMenuOpen = false

RegisterNetEvent('c7vms2:receiveVehicleData', function(data)
    SendNUIMessage({
        action = 'openMenu',
        data = data or {}
    })

    SetNuiFocus(true, true)
    isMenuOpen = true
end)

RegisterNetEvent('c7vms2:notify', function(msg)
    if msg then
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandThefeedPostTicker(false, true)
    end
end)

RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    if not data or not data.department or not data.vehicle then
        cb('ok')
        return
    end

    TriggerServerEvent('c7vms2:requestSpawnVehicle', data.department, data.vehicle)
    SetNuiFocus(false, false)
    isMenuOpen = false
    cb('ok')
end)

RegisterCommand(Config.command, function()
    TriggerServerEvent('c7vms2:getVehicleData')
end, false)

RegisterKeyMapping(Config.command, 'Open C7 Vehicle Management System', 'keyboard', Config.keybind)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if isMenuOpen and IsControlJustPressed(0, 200) then
            SetNuiFocus(false, false)
            isMenuOpen = false
            SendNUIMessage({ action = 'closeMenu' })
        end
    end
end)
