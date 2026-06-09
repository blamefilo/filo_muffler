# Filo Muffler

A FiveM resource that allows players to change vehicle muffler/engine sounds with customizable restrictions and persistence.

## Features

- **Custom Muffler Sounds**: Install custom muffler sounds on any vehicle
- **Job Restrictions**: Limit access to specific jobs (e.g., mechanics)
- **Item Requirements**: Require specific items to install/remove mufflers
- **Persistent Storage**: Muffler sounds are saved per vehicle plate
- **Automatic Restoration**: Sounds are automatically restored when players are nearby
- **Admin Command**: Bypass restrictions with a configurable command
- **Progress Animations**: Realistic installation/removal animations
- **ox_target Integration**: Easy vehicle interaction via target system

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)
- [community_bridge](https://github.com/TheOrderFivem/community_bridge)
- [ox_target](https://github.com/overextended/ox_target)

## Installation

1. Download the resource and place it in your server's `resources` directory
2. Add `ensure filo_muffler` to your `server.cfg`
3. Configure the settings in `shared/sh-config.lua`
4. Restart your server

## Configuration

Edit `shared/sh-config.lua` to customize the resource:

```lua
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
```

## Usage

### For Players

1. Ensure you have the required item (if configured) and the correct job (if configured)
2. Approach a vehicle (within the configured distance)
3. Use the ox_target option "Manage Muffler"
4. Select "Change Vehicle Muffler" and enter the sound name
5. Wait for the installation progress bar to complete
6. To remove, select "Remove Vehicle Muffler" from the menu

### For Admins

Use the configured command (default: `/esound`) to open the muffler menu without job or item restrictions.

## How It Works

1. **Installation**: Players interact with vehicles via ox_target, enter a sound name, and go through a progress animation
2. **Storage**: Muffler sound data is stored per vehicle plate in `data/vehicles.bin` using msgpack serialization
3. **Synchronization**: Statebags are used to sync muffler sounds across all clients
4. **Restoration**: A background thread scans for nearby vehicles and restores their muffler sounds automatically
5. **Persistence**: Data is saved to disk when the resource stops and loaded on startup

## Sound Names

The sound names you can use depend on your server's vehicle audio configuration. Common GTA V sound names include:

- `default` - Original vehicle sound
- `banshee` - Banshee engine sound
- `cheetah` - Cheetah engine sound
- `infernus` - Infernus engine sound
- `turismo` - Turismo engine sound
- And many more vehicle-specific sounds

Check your server's vehicle audio files or sound banks for available options.

## Troubleshooting

- **Sounds not applying**: Ensure the sound name is valid and exists in your server's audio files
- **Menu not appearing**: Check that you have the required item and job permissions
- **Sounds not persisting**: Verify that `data/vehicles.bin` has write permissions
- **Performance issues**: Adjust `Config.RestoreScanInterval` and `Config.RestoreScanDistance` if needed

## Support

- **Discord**: [Join our Discord](https://discord.gg/bErPEKvRXg)
- **Repository**: [GitHub](https://github.com/blamefilo/filo_muffler)
- **Author**: filo studios.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.
