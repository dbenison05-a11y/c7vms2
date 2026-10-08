Config = {}

Config.command = 'vms2'
Config.keybind = 'F7'

Config.permissions = {
    mode = 'hybrid', -- 'ace', 'discord', 'hybrid'
    enableAce = true,
    enableDiscord = false,
    acePrefix = 'c7vms2.department.',
    discordGuildId = nil,
    discordRoleIds = {
        -- example: '123456789012345678'
    }
}

Config.departments = {
    police = {
        label = 'Police Department',
        image = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
        ace = 'c7vms2.department.police',
        discordRoles = {},
        spawn = vector4(435.1, -978.6, 30.1, 270.0),
        vehicles = {
            {
                id = 'police_cruiser',
                label = 'Police Cruiser',
                model = 'police',
                image = 'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=800&q=80',
                spawnLimit = 2,
                cooldown = 30000,
                livery = 0,
                extras = { 1, 2 },
                extrasOff = { 3, 4 },
                modifiers = {
                    { slot = 48, value = 1 }
                },
                platePrefix = 'PD'
            },
            {
                id = 'police_interceptor',
                label = 'Interceptor',
                model = 'police2',
                image = 'https://images.unsplash.com/photo-1553440569-bcc63803a83d?auto=format&fit=crop&w=800&q=80',
                spawnLimit = 1,
                cooldown = 45000,
                livery = 1,
                extras = {},
                extrasOff = {},
                modifiers = {
                    { slot = 48, value = 1 }
                },
                platePrefix = 'PD'
            }
        }
    },

    ambulance = {
        label = 'EMS Department',
        image = 'https://images.unsplash.com/photo-1538108149393-fbbd81895973?auto=format&fit=crop&w=800&q=80',
        ace = 'c7vms2.department.ambulance',
        discordRoles = {},
        spawn = vector4(340.4, -570.2, 28.9, 160.0),
        vehicles = {
            {
                id = 'ambulance',
                label = 'Ambulance',
                model = 'ambulance',
                image = 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80',
                spawnLimit = 1,
                cooldown = 60000,
                livery = 0,
                extras = {},
                extrasOff = {},
                modifiers = {},
                platePrefix = 'EMS'
            }
        }
    },

    sheriff = {
        label = 'Sheriff Department',
        image = 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=800&q=80',
        ace = 'c7vms2.department.sheriff',
        discordRoles = {},
        spawn = vector4(389.2, -1609.2, 29.3, 90.0),
        vehicles = {
            {
                id = 'sheriff_cruiser',
                label = 'Sheriff Cruiser',
                model = 'sheriff',
                image = 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?auto=format&fit=crop&w=800&q=80',
                spawnLimit = 2,
                cooldown = 50000,
                livery = 0,
                extras = {},
                extrasOff = {},
                modifiers = {},
                platePrefix = 'SHF'
            }
        }
    }
}

Config.lang = {
    noAccess = 'You do not have access to this department.',
    invalidDepartment = 'Invalid department selected.',
    invalidVehicle = 'Invalid vehicle selected.',
    cooldown = 'This vehicle is still on cooldown.',
    limitReached = 'Spawn limit reached for this vehicle.',
    spawned = 'Vehicle spawned successfully.',
    noDiscord = 'Discord role validation failed.',
    noVehicle = 'No vehicles available in this department.'
}
