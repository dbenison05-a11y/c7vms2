local playerCooldowns = {}
local playerSpawnCounts = {}
local vehicleFleet = {}
local vehicleOwnership = {}

local function getPlayerIdentifiers(src)
    local ids = GetPlayerIdentifiers(src)
    local result = {}

    for _, id in ipairs(ids) do
        table.insert(result, id)
    end

    return result
end

local function getPlayerSteam(src)
    for _, id in ipairs(getPlayerIdentifiers(src)) do
        if id and string.sub(id, 1, 6) == 'steam:' then
            return id
        end
    end
    return 'unknown'
end

local function getPlayerDiscord(src)
    for _, id in ipairs(getPlayerIdentifiers(src)) do
        if id and string.sub(id, 1, 8) == 'discord:' then
            return string.gsub(id, 'discord:', '')
        end
    end
    return nil
end

local function saveVehicleState(plate, data)
    local json = json.encode(data)
    SetResourceKvp('c7vms2:vehicle:' .. plate, json)
end

local function loadVehicleState(plate)
    local data = GetResourceKvpString('c7vms2:vehicle:' .. plate)
    if not data or data == '' then
        return nil
    end
    return json.decode(data)
end

local function deleteVehicleState(plate)
    DeleteResourceKvp('c7vms2:vehicle:' .. plate)
end

local function hasAceAccess(src, ace)
    if not ace then
        return true
    end

    if Config.permissions.enableAce and IsPlayerAceAllowed(src, ace) then
        return true
    end

    return false
end

local function hasDiscordAccess(src, discordRoles)
    if not Config.permissions.enableDiscord then
        return true
    end

    local roleIds = discordRoles or {}
    if not roleIds or #roleIds == 0 then
        return true
    end

    local discordId = getPlayerDiscord(src)
    if not discordId then
        return false
    end

    local userRoles = Config.permissions.discordRoleIds or {}
    for _, allowedRole in ipairs(roleIds) do
        for _, playerRole in ipairs(userRoles) do
            if tostring(allowedRole) == tostring(playerRole) then
                return true
            end
        end
    end

    return false
end

local function hasDepartmentAccess(src, ace, discordRoles)
    if Config.permissions.mode == 'ace' then
        return hasAceAccess(src, ace)
    end

    if Config.permissions.mode == 'discord' then
        return hasDiscordAccess(src, discordRoles)
    end

    if Config.permissions.enableAce and hasAceAccess(src, ace) then
        return true
    end

    if Config.permissions.enableDiscord and hasDiscordAccess(src, discordRoles) then
        return true
    end

    return true
end

local function isAdmin(src)
    return IsPlayerAceAllowed(src, Config.adminPerms.superAdmin) or 
           IsPlayerAceAllowed(src, Config.adminPerms.canDeleteVehicles)
end

local function isSupervisor(src, departmentKey)
    if not departmentKey then
        return false
    end

    local department = Config.departments[departmentKey]
    if not department then
        return false
    end

    return IsPlayerAceAllowed(src, department.supervisorAce or Config.adminPerms.departmentSupervisor)
end

local function getPlayerKey(src)
    return getPlayerSteam(src)
end

local function getSpawnCount(src)
    local key = getPlayerKey(src)
    if not playerSpawnCounts[key] then
        playerSpawnCounts[key] = 0
    end
    return playerSpawnCounts[key]
end

local function addSpawnCount(src)
    local key = getPlayerKey(src)
    if not playerSpawnCounts[key] then
        playerSpawnCounts[key] = 0
    end
    playerSpawnCounts[key] = playerSpawnCounts[key] + 1
end

local function setCooldown(src, ms)
    local key = getPlayerKey(src)
    playerCooldowns[key] = GetGameTimer() + ms
end

local function hasCooldown(src, ms)
    local key = getPlayerKey(src)
    if not playerCooldowns[key] then
        return false
    end
    return GetGameTimer() < playerCooldowns[key]
end

local function generatePlate(src, prefix)
    local steam = getPlayerSteam(src)
    local existing = GetResourceKvpString('c7vms2:plate:' .. steam)
    if existing and existing ~= '' then
        return existing
    end

    local generated = string.upper(prefix .. tostring(math.random(100, 999)) .. tostring(GetPlayerServerId(src) % 1000))
    SetResourceKvp('c7vms2:plate:' .. steam, generated)
    return generated
end

local function applyVehicleExtras(vehicle, extras, extrasOff)
    for _, extraId in ipairs(extras or {}) do
        SetVehicleExtra(vehicle, tonumber(extraId), 0)
    end

    for _, extraId in ipairs(extrasOff or {}) do
        SetVehicleExtra(vehicle, tonumber(extraId), 1)
    end
end

local function applyVehicleModifiers(vehicle, modifiers)
    for _, mod in ipairs(modifiers or {}) do
        if mod.slot ~= nil and mod.value ~= nil then
            SetVehicleMod(vehicle, tonumber(mod.slot), tonumber(mod.value), false)
        end
    end
end

local function getVehicleListForPlayer(src)
    local result = {}

    for deptKey, department in pairs(Config.departments) do
        local hasDeptAccess = hasDepartmentAccess(src, department.ace, department.discordRoles)

        if hasDeptAccess then
            local currentDept = {
                id = deptKey,
                label = department.label,
                image = department.image,
                subDepartments = {}
            }

            if department.subDepartments then
                for subDeptKey, subDept in pairs(department.subDepartments) do
                    local hasSubAccess = hasDepartmentAccess(src, subDept.ace, subDept.discordRoles or {})

                    if hasSubAccess then
                        local subDeptEntry = {
                            id = subDeptKey,
                            label = subDept.label,
                            image = subDept.image,
                            vehicles = {}
                        }

                        for _, vehicle in ipairs(subDept.vehicles or {}) do
                            table.insert(subDeptEntry.vehicles, {
                                id = vehicle.id,
                                label = vehicle.label,
                                model = vehicle.model,
                                image = vehicle.image,
                                spawnLimit = vehicle.spawnLimit or 0,
                                cooldown = vehicle.cooldown or 0,
                                livery = vehicle.livery or 0,
                                extras = vehicle.extras or {},
                                extrasOff = vehicle.extrasOff or {},
                                modifiers = vehicle.modifiers or {},
                                platePrefix = vehicle.platePrefix or 'VMS',
                                maxInventorySlots = vehicle.maxInventorySlots or 4
                            })
                        end

                        table.insert(currentDept.subDepartments, subDeptEntry)
                    end
                end
            else
                for _, vehicle in ipairs(department.vehicles or {}) do
                    local vehicleEntry = {
                        id = vehicle.id,
                        label = vehicle.label,
                        model = vehicle.model,
                        image = vehicle.image,
                        spawnLimit = vehicle.spawnLimit or 0,
                        cooldown = vehicle.cooldown or 0,
                        livery = vehicle.livery or 0,
                        extras = vehicle.extras or {},
                        extrasOff = vehicle.extrasOff or {},
                        modifiers = vehicle.modifiers or {},
                        platePrefix = vehicle.platePrefix or 'VMS',
                        maxInventorySlots = vehicle.maxInventorySlots or 4
                    }

                    table.insert(currentDept.subDepartments, {
                        id = 'default',
                        label = 'Vehicles',
                        image = department.image,
                        vehicles = { vehicleEntry }
                    })
                end
            end

            if #currentDept.subDepartments > 0 then
                table.insert(result, currentDept)
            end
        end
    end

    return result
end

local function spawnVehicleForPlayer(src, departmentKey, subDeptKey, vehicleId)
    local department = Config.departments[departmentKey]
    if not department then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.invalidDepartment)
        return
    end

    if not hasDepartmentAccess(src, department.ace, department.discordRoles) then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.noAccess)
        return
    end

    local subDept = department.subDepartments and department.subDepartments[subDeptKey]
    if not subDept then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.invalidDepartment)
        return
    end

    if not hasDepartmentAccess(src, subDept.ace, subDept.discordRoles or {}) then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.noAccess)
        return
    end

    local selectedVehicle = nil
    for _, vehicle in ipairs(subDept.vehicles or {}) do
        if vehicle.id == vehicleId then
            selectedVehicle = vehicle
            break
        end
    end

    if not selectedVehicle then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.invalidVehicle)
        return
    end

    if selectedVehicle.spawnLimit and selectedVehicle.spawnLimit > 0 and getSpawnCount(src) >= selectedVehicle.spawnLimit then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.limitReached)
        return
    end

    if selectedVehicle.cooldown and selectedVehicle.cooldown > 0 and hasCooldown(src, selectedVehicle.cooldown) then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.cooldown)
        return
    end

    local model = selectedVehicle.model
    if not IsModelInCdimage(model) or not IsModelValid(model) then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.invalidVehicle)
        return
    end

    RequestModel(model)
    local attempts = 0
    while not HasModelLoaded(model) and attempts < 100 do
        Wait(0)
        attempts = attempts + 1
    end

    if not HasModelLoaded(model) then
        TriggerClientEvent('c7vms2:notify', src, 'Vehicle model failed to load.')
        return
    end

    local ped = GetPlayerPed(src)
    local coords = department.spawn or GetEntityCoords(ped)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w or 0.0, true, false)

    if not vehicle or vehicle == 0 then
        TriggerClientEvent('c7vms2:notify', src, 'Unable to create the vehicle.')
        return
    end

    SetEntityHeading(vehicle, coords.w or 0.0)
    SetVehicleOnGroundProperly(vehicle)

    local plate = generatePlate(src, selectedVehicle.platePrefix or 'VMS')
    SetVehicleNumberPlateText(vehicle, plate)
    SetVehicleEngineOn(vehicle, true, true, true)
    SetVehicleDirtLevel(vehicle, 0.0)

    if selectedVehicle.livery then
        SetVehicleLivery(vehicle, tonumber(selectedVehicle.livery))
    end

    applyVehicleExtras(vehicle, selectedVehicle.extras, selectedVehicle.extrasOff)
    applyVehicleModifiers(vehicle, selectedVehicle.modifiers)

    SetPedIntoVehicle(ped, vehicle, -1)

    local vehicleData = {
        plate = plate,
        status = Config.vehicleStatus.available,
        reason = nil,
        department = departmentKey,
        subDepartment = subDeptKey,
        assignedTo = getPlayerSteam(src),
        spawnedAt = os.time(),
        model = model,
        label = selectedVehicle.label
    }

    vehicleFleet[plate] = vehicleData
    vehicleOwnership[vehicle] = plate
    saveVehicleState(plate, vehicleData)

    addSpawnCount(src)
    setCooldown(src, selectedVehicle.cooldown or 0)

    TriggerClientEvent('c7vms2:notify', src, Config.lang.spawned)
end

local function deleteNearestVehicle(src)
    if not isAdmin(src) then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.notAdmin)
        return
    end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local closestVehicle = nil
    local closestDistance = 10.0

    for vehicle, plate in pairs(vehicleOwnership) do
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(coords - vehicleCoords)

            if distance < closestDistance then
                closestDistance = distance
                closestVehicle = vehicle
            end
        end
    end

    if closestVehicle then
        local plate = vehicleOwnership[closestVehicle]
        deleteVehicleState(plate)
        vehicleFleet[plate] = nil
        vehicleOwnership[closestVehicle] = nil
        DeleteEntity(closestVehicle)
        TriggerClientEvent('c7vms2:notify', src, Config.lang.vehicleDeleted)
    else
        TriggerClientEvent('c7vms2:notify', src, 'No vehicle found nearby.')
    end
end

local function setVehicleStatus(src, plate, status, reason)
    local currentVehicle = vehicleFleet[plate]

    if not currentVehicle then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.vehicleNotFound)
        return
    end

    if not (isAdmin(src) or isSupervisor(src, currentVehicle.department)) then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.notAdmin)
        return
    end

    currentVehicle.status = status
    currentVehicle.reason = reason
    currentVehicle.updatedBy = getPlayerSteam(src)
    currentVehicle.updatedAt = os.time()

    saveVehicleState(plate, currentVehicle)
    TriggerClientEvent('c7vms2:notify', src, Config.lang.reasonUpdated)
end

local function getFleetStatus()
    local fleetData = {}

    for plate, data in pairs(vehicleFleet) do
        table.insert(fleetData, {
            plate = plate,
            status = data.status,
            reason = data.reason,
            department = data.department,
            subDepartment = data.subDepartment,
            label = data.label,
            model = data.model,
            assignedTo = data.assignedTo,
            spawnedAt = data.spawnedAt
        })
    end

    return fleetData
end

RegisterNetEvent('c7vms2:getVehicleData', function()
    local vehicleData = getVehicleListForPlayer(source)
    TriggerClientEvent('c7vms2:receiveVehicleData', source, vehicleData)
end)

RegisterNetEvent('c7vms2:requestSpawnVehicle', function(departmentKey, subDeptKey, vehicleId)
    spawnVehicleForPlayer(source, departmentKey, subDeptKey, vehicleId)
end)

RegisterNetEvent('c7vms2:setVehicleStatus', function(plate, status, reason)
    setVehicleStatus(source, plate, status, reason)
end)

RegisterNetEvent('c7vms2:getFleetStatus', function()
    local fleetData = getFleetStatus()
    TriggerClientEvent('c7vms2:receiveFleetStatus', source, fleetData)
end)

RegisterCommand(Config.command, function(source)
    if source > 0 then
        local vehicleData = getVehicleListForPlayer(source)
        TriggerClientEvent('c7vms2:receiveVehicleData', source, vehicleData)
    end
end, false)

RegisterCommand(Config.adminCommand, function(source)
    if source > 0 and isAdmin(source) then
        local fleetData = getFleetStatus()
        TriggerClientEvent('c7vms2:openAdminMenu', source, fleetData)
    else
        TriggerClientEvent('c7vms2:notify', source, Config.lang.notAdmin)
    end
end, false)

RegisterCommand('vms2delete', function(source)
    if source > 0 then
        deleteNearestVehicle(source)
    end
end, false)

AddEventHandler('playerDropped', function(reason)
    local key = getPlayerKey(source)
    if key then
        playerCooldowns[key] = nil
        playerSpawnCounts[key] = nil
    end
end)

print('^2[C7VMS2 Premium]^7 Server loaded with fleet management and sub-departments.')
