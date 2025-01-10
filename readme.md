# force-binoculars

A more advanced binoculars resource then normal for you're FiveM server. It Contains multiple vision modes and configuration options.
[Documentation](https://force-developing.gitbook.io/docs/free-resources/force-binoculars)

## Features

- Multiple vision modes (Normal, Night Vision, Thermal Vision)
- Adjustable zoom
- Configurable key bindings
- Framework support (ESX, QBCore, QBX)
- Item-based usage support
- Command-based usage support
- Realistic camera positioning and movement
- On-screen controls display
- Customizable camera settings

### Preview

<img src="https://i.gyazo.com/36b2623bfa912d4e055bf8864ef45eb6.jpg" alt="Enhanced Binocular" width="49%"/>
<img src="https://i.gyazo.com/b614108b7fc1219aa9a79962ba3b61a9.jpg" alt="Enhanced Binocular" width="49%"/>
<img src="https://i.gyazo.com/3bffa24b6df3ec0c7ec799c305e860ab.jpg" alt="Enhanced Binocular" width="49%"/>
<img src="https://i.gyazo.com/090f27d549aea6c3d6379eaa68c9afde.jpg" alt="Enhanced Binocular" width="49%"/>

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)

## Installation

1. Download the latest release
2. Extract to your resources folder
3. Add `ensure force-binoculars` to your server.cfg
4. Configure the script in `config.lua` (optional)

## Configuration

```lua
Config = {
    Debug = false,                            -- Enable/disable debug mode
    Locale = "en",                           -- Language setting (ar, de, en, es, fr, nl, pl, pt, ru, se)
    Framework = "auto",                      -- Framework detection (auto, esx, qbcore, qbx, custom)
    Item = "binoculars",                    -- Regular binoculars item name
    EnhancedItem = "binoculars_modes",      -- Enhanced binoculars item name (with special modes)
    Command = "binoculars",                 -- Command to use binoculars

    ...more settings..
}
```

## Usage

### Items

- Use the `binoculars` item for basic functionality
- Use the `binoculars_modes` item for enhanced functionality (night vision, thermal)

### Commands

- `/binoculars` - Toggle binoculars (if enabled in config)

### Controls

- `MOUSE WHEEL UP/W` - Zoom in
- `MOUSE WHEEL DOWN/S` - Zoom out
- `LEFT ARROW` - Previous mode
- `RIGHT ARROW` - Next mode
- `BACKSPACE` - Exit binoculars

## Modes

1. **Default** - Standard vision mode
2. **Night Vision** - Enhanced visibility in dark areas
3. **Thermal Vision** - Heat signature detection

## Integration

### Client Exports

```lua
-- Check if binoculars are active
exports["force-binoculars"]:IsBinocularsActive()

-- Get the current binoculars state
--- @return table { active, mode, zoom }
exports["force-binoculars"]:GetBinocularsState()

-- Toggle binoculars
exports["force-binoculars"]:ToggleBinoculars()

-- Activate binoculars
exports["force-binoculars"]:ActivateBinoculars()

-- Deactivate binoculars
exports["force-binoculars"]:DeactivateBinoculars()
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions, issues, or feature requests, please open an [issue](https://github.com/Force-Developing/force-binoculars/issues) or reach out on our [Discord](https://discord.gg/927gfpcyDe).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

```

```
