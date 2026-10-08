local playerCooldowns = {}
local playerSpawnCounts = {}

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

local function hasAceAccess(src, department)
    if not department or not department.ace then
        return true
    end

    if Config.permissions.enableAce and IsPlayerAceAllowed(src, department.ace) then
        return true
    end

    return false
end

local function hasDiscordAccess(src, department)
    if not Config.permissions.enableDiscord then
        return true
    end

    local roleIds = department.discordRoles or {}
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

local function hasDepartmentAccess(src, departmentKey)
    local department = Config.departments[departmentKey]
    if not department then
        return false
    end

    if Config.permissions.mode == 'ace' then
        return hasAceAccess(src, department)
    end

    if Config.permissions.mode == 'discord' then
        return hasDiscordAccess(src, department)
    end

    -- hybrid mode: allow if either ace or discord passes
    if Config.permissions.enableAce and hasAceAccess(src, department) then
        return true
    end

    if Config.permissions.enableDiscord and hasDiscordAccess(src, department) then
        return true
    end

    return true
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

local function getVehicleList()
    local result = {}

    for deptKey, department in pairs(Config.departments) do
        local currentDept = {
            id = deptKey,
            label = department.label,
            image = department.image,
            vehicles = {}
        }

        for _, vehicle in ipairs(department.vehicles) do
            table.insert(currentDept.vehicles, {
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
                platePrefix = vehicle.platePrefix or 'VMS'
            })
        end

        table.insert(result, currentDept)
    end

    return result
end

local function spawnVehicleForPlayer(src, departmentKey, vehicleId)
    local department = Config.departments[departmentKey]
    if not department then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.invalidDepartment)
        return
    end

    if not hasDepartmentAccess(src, departmentKey) then
        TriggerClientEvent('c7vms2:notify', src, Config.lang.noAccess)
        return
    end

    local selectedVehicle = nil
    for _, vehicle in ipairs(department.vehicles) do
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
    SetVehicleNumberPlateText(vehicle, generatePlate(src, selectedVehicle.platePrefix or 'VMS'))
    SetVehicleEngineOn(vehicle, true, true, true)
    SetVehicleDirtLevel(vehicle, 0.0)

    if selectedVehicle.livery then
        SetVehicleLivery(vehicle, tonumber(selectedVehicle.livery))
    end

    applyVehicleExtras(vehicle, selectedVehicle.extras, selectedVehicle.extrasOff)
    applyVehicleModifiers(vehicle, selectedVehicle.modifiers)

    SetPedIntoVehicle(ped, vehicle, -1)

    addSpawnCount(src)
    setCooldown(src, selectedVehicle.cooldown or 0)

    TriggerClientEvent('c7vms2:notify', src, Config.lang.spawned)
end

RegisterNetEvent('c7vms2:getVehicleData', function()
    TriggerClientEvent('c7vms2:receiveVehicleData', source, getVehicleList())
end)

RegisterNetEvent('c7vms2:requestSpawnVehicle', function(departmentKey, vehicleId)
    spawnVehicleForPlayer(source, departmentKey, vehicleId)
end)

RegisterCommand(Config.command, function(source)
    if source > 0 then
        TriggerClientEvent('c7vms2:receiveVehicleData', source, getVehicleList())
    end
end, false)

print('[C7VMS2] Standalone VMS2 loaded successfully.')
