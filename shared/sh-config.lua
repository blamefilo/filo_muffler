Config = {}

-- Enable debug mode for console output and troubleshooting
Config.Debug = true

-- Item required to install/remove the muffler (set to nil to disable item requirement)
Config.RequiredItem = 'muffler_kit'

-- Jobs allowed to use the muffler system with minimum grade (set to nil to allow all jobs)
Config.AllowedJobs = {
    ['mechanic'] = 0,
}

-- Command name to toggle the muffler sound effect
Config.Command = 'esound'

-- Permission groups allowed to use the command (set to empty table to allow everyone)
Config.CommandPermissions = {
    'group.admin'
}

-- Maximum distance (in meters) a player can be from the vehicle to interact with the muffler
Config.MaxDistance = 2.5

-- Distance (in meters) to scan for vehicles to restore muffler sounds when players are nearby
Config.RestoreScanDistance = 35.0

-- Interval (in milliseconds) between restore scans for vehicle muffler sounds
Config.RestoreScanInterval = 5000

-- Minimum duration (in milliseconds) for the muffler sound change animation/effect
Config.ChangeDurationMin = 15000

-- Maximum duration (in milliseconds) for the muffler sound change animation/effect
Config.ChangeDurationMax = 30000