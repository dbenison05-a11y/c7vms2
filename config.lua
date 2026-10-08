Config = {}

-- Core Settings
Config.command = 'vms2'
Config.keybind = 'F7'
Config.adminCommand = 'vms2admin'

-- Permission Modes: 'ace' | 'discord' | 'hybrid'
Config.permissions = {
    mode = 'hybrid',
    enableAce = true,
    enableDiscord = false,
    acePrefix = 'c7vms2.department.',
    discordGuildId = nil,
    discordRoleIds = {}
}

-- Admin ACE Permissions
Config.adminPerms = {
    superAdmin = 'c7vms2.admin.super',
    departmentSupervisor = 'c7vms2.supervisor',
    canDeleteVehicles = 'c7vms2.admin.delete',
    canManageFleet = 'c7vms2.admin.fleet'
}

-- Out of Service Reasons for Fleet Management
Config.fleetOutOfServiceReasons = {
    'Totaled',
    'Out for Repairs',
    'Investigation',
    'Mechanical Failure',
    'Collision Damage',
    'Safety Inspection',
    'Preventive Maintenance',
    'Equipment Installation',
    'Evidence Hold',
    'Administrative Hold',
    'Cleaning / Decontamination',
    'Other'
}

-- Vehicle Status Types
Config.vehicleStatus = {
    available = 'available',
    outOfService = 'outOfService',
    inUse = 'inUse',
    maintenance = 'maintenance'
}

-- Departments with Sub-departments
Config.departments = {
    police = {
        label = 'Police Department',
        image = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
        ace = 'c7vms2.department.police',
        supervisorAce = 'c7vms2.supervisor.police',
        discordRoles = {},
        spawn = vector4(435.1, -978.6, 30.1, 270.0),
        subDepartments = {
            patrol = {
                label = 'Patrol Division',
                image = 'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=800&q=80',
                ace = 'c7vms2.department.police.patrol',
                vehicles = {
                    {
                        id = 'police_cruiser_patrol',
                        label = 'Police Cruiser',
                        model = 'police',
                        image = 'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=800&q=80',
                        spawnLimit = 3,
                        cooldown = 30000,
                        livery = 0,
                        extras = { 1, 2 },
                        extrasOff = { 3, 4 },
                        modifiers = {
                            { slot = 48, value = 1 }
                        },
                        platePrefix = 'PD',
                        maxInventorySlots = 6
                    },
                    {
                        id = 'police_bike_patrol',
                        label = 'Police Bike',
                        model = 'policeb',
                        image = 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?auto=format&fit=crop&w=800&q=80',
                        spawnLimit = 2,
                        cooldown = 40000,
                        livery = 0,
                        extras = {},
                        extrasOff = {},
                        modifiers = {},
                        platePrefix = 'PD',
                        maxInventorySlots = 3
                    }
                }
            },
            swat = {
                label = 'SWAT Team',
                image = 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?auto=format&fit=crop&w=800&q=80',
                ace = 'c7vms2.department.police.swat',
                vehicles = {
                    {
                        id = 'swat_interceptor',
                        label = 'SWAT Interceptor',
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
                        platePrefix = 'SWAT',
                        maxInventorySlots = 8
                    },
                    {
                        id = 'swat_van',
                        label = 'SWAT Van',
                        model = 'riot',
                        image = 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=800&q=80',
                        spawnLimit = 1,
                        cooldown = 60000,
                        livery = 0,
                        extras = {},
                        extrasOff = {},
                        modifiers = {},
                        platePrefix = 'SWAT',
                        maxInventorySlots = 10
                    }
                }
            },
            traffic = {
                label = 'Traffic Control',
                image = 'https://images.unsplash.com/photo-1497436212556-cf7271cbe7fc?auto=format&fit=crop&w=800&q=80',
                ace = 'c7vms2.department.police.traffic',
                vehicles = {
                    {
                        id = 'traffic_cruiser',
                        label = 'Traffic Cruiser',
                        model = 'police',
                        image = 'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=800&q=80',
                        spawnLimit = 2,
                        cooldown = 35000,
                        livery = 2,
                        extras = {},
                        extrasOff = {},
                        modifiers = {},
                        platePrefix = 'TRAFFIC',
                        maxInventorySlots = 4
                    }
                }
            }
        }
    },

    ambulance = {
        label = 'EMS Department',
        image = 'https://images.unsplash.com/photo-1538108149393-fbbd81895973?auto=format&fit=crop&w=800&q=80',
        ace = 'c7vms2.department.ambulance',
        supervisorAce = 'c7vms2.supervisor.ambulance',
        discordRoles = {},
        spawn = vector4(340.4, -570.2, 28.9, 160.0),
        subDepartments = {
            rescue = {
                label = 'Rescue Division',
                image = 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80',
                ace = 'c7vms2.department.ambulance.rescue',
                vehicles = {
                    {
                        id = 'ambulance_rescue',
                        label = 'Rescue Ambulance',
                        model = 'ambulance',
                        image = 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80',
                        spawnLimit = 2,
                        cooldown = 60000,
                        livery = 0,
                        extras = {},
                        extrasOff = {},
                        modifiers = {},
                        platePrefix = 'EMS',
                        maxInventorySlots = 12
                    }
                }
            },
            supervisor = {
                label = 'Supervisor Unit',
                image = 'https://images.unsplash.com/photo-1538108149393-fbbd81895973?auto=format&fit=crop&w=800&q=80',
                ace = 'c7vms2.department.ambulance.supervisor',
                vehicles = {
                    {
                        id = 'ems_supervisor',
                        label = 'Supervisor Vehicle',
                        model = 'police',
                        image = 'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=800&q=80',
                        spawnLimit = 1,
                        cooldown = 45000,
                        livery = 0,
                        extras = {},
                        extrasOff = {},
                        modifiers = {},
                        platePrefix = 'EMS',
                        maxInventorySlots = 8
                    }
                }
            }
        }
    },

    sheriff = {
        label = 'Sheriff Department',
        image = 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=800&q=80',
        ace = 'c7vms2.department.sheriff',
        supervisorAce = 'c7vms2.supervisor.sheriff',
        discordRoles = {},
        spawn = vector4(389.2, -1609.2, 29.3, 90.0),
        subDepartments = {
            patrol = {
                label = 'Sheriff Patrol',
                image = 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?auto=format&fit=crop&w=800&q=80',
                ace = 'c7vms2.department.sheriff.patrol',
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
                        platePrefix = 'SHF',
                        maxInventorySlots = 6
                    }
                }
            }
        }
    }
}

-- Language Strings
Config.lang = {
    menuTitle = 'C7 Vehicle Management System',
    noAccess = 'You do not have access to this department.',
    invalidDepartment = 'Invalid department selected.',
    invalidVehicle = 'Invalid vehicle selected.',
    spawned = 'Vehicle spawned successfully.',
    cooldown = 'Vehicle is on cooldown. Please wait.',
    limitReached = 'Spawn limit reached for this vehicle.',
    available = 'Available',
    outOfService = 'Out of Service',
    inUse = 'In Use',
    maintenance = 'Maintenance',
    status = 'Status',
    reason = 'Reason',
    adminMenu = 'Fleet Management',
    deleteVehicle = 'Delete Vehicle',
    vehicleDeleted = 'Vehicle deleted successfully.',
    markOutOfService = 'Mark Out of Service',
    markAvailable = 'Mark Available',
    manageFleet = 'Manage Fleet',
    outOfServiceReason = 'Out of Service Reason',
    noVehicles = 'No vehicles available for this department.',
    noDiscord = 'Discord role validation failed.',
    error = 'An error occurred.',
    vehicleNotFound = 'Vehicle not found.',
    notAdmin = 'You do not have permission to use this command.',
    success = 'Action completed successfully.',
    reasonUpdated = 'Out of service reason updated.'
}
