# force-binoculars

A more advanced binoculars resource for your FiveM server, with multiple vision modes, adjustable zoom and configurable camera behaviour.
[Documentation](https://docs.forcedevelopments.com/)

## Features

- Multiple vision modes (Normal, Night Vision, Thermal Vision)
- Adjustable zoom
- Configurable key bindings
- Framework support (ESX, QBCore, QBX, custom) or standalone via the command
- Item-based usage, with a separate enhanced item for the special modes
- Command-based usage
- Auto-exit on death, entering a vehicle, ragdoll or swimming; ESC also closes them
- Realistic camera positioning and movement
- On-screen controls display
- Ten locales (ar, de, en, es, fr, nl, pl, pt, ru, sv)

### Preview

<div align="center" style="display: flex; flex-wrap: wrap; justify-content: center; gap: 10px;">
<img src="https://i.gyazo.com/36b2623bfa912d4e055bf8864ef45eb6.jpg" alt="Enhanced Binocular" width="49%"/>
<img src="https://i.gyazo.com/b614108b7fc1219aa9a79962ba3b61a9.jpg" alt="Enhanced Binocular" width="49%"/>
<img src="https://i.gyazo.com/3bffa24b6df3ec0c7ec799c305e860ab.jpg" alt="Enhanced Binocular" width="49%"/>
<img src="https://i.gyazo.com/090f27d549aea6c3d6379eaa68c9afde.jpg" alt="Enhanced Binocular" width="49%"/>
</div>

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)

## Installation

1. Install ox_lib
2. Download the latest release and extract it to your resources folder as `force-binoculars`
3. Add `ensure force-binoculars` to your server.cfg, after `ox_lib` (ESX, QBCore or QBX are detected automatically by the server, whatever the start order; without one the resource runs standalone with commands only)
4. Add the items to your inventory if you want item-based usage (see below)
5. Configure the script in `config.lua` (optional)

## Configuration

```lua
Config.Debug = false
Config.Locale = "en" -- ar, de, en, es, fr, nl, pl, pt, ru, sv

Config.Framework = {
  name = "auto",    -- auto, esx, qbcore, qbx, custom
  resource = "auto" -- "auto" = es_extended / qb-core / qbx_core
}

Config.Binoculars = {
  { item = "binoculars",       command = "binoculars", modes = false },
  { item = "binoculars_modes", command = false,        modes = true  },
}
```

`minZoom`/`maxZoom` in `Config.Modes` are magnification factors (FOV = 90 / zoom): higher = more zoomed in, lower = wider view. See the documentation for every option.

## Usage

### Items

- `binoculars` — normal vision with zoom
- `binoculars_modes` — additionally unlocks night vision and thermal vision

### Commands

- `/binoculars` — toggle normal binoculars (enabled by default)
- `/binoculars_modes` — toggle binoculars with modes. Disabled by default because a command is available to everyone and would bypass the item; enable it with `command = "binoculars_modes"`

### Controls

- `MOUSE WHEEL UP/W` - Zoom in
- `MOUSE WHEEL DOWN/S` - Zoom out
- `LEFT ARROW` - Previous mode (modes item only)
- `RIGHT ARROW` - Next mode (modes item only)
- `BACKSPACE` (or ESC) - Exit binoculars

### Item definitions

**ox_inventory** — add to `ox_inventory/data/items.lua`:

```lua
['binoculars'] = {
    label = 'Binoculars',
    weight = 500,
    stack = false,
    close = true,
    description = 'Look at things far away',
},

['binoculars_modes'] = {
    label = 'Tactical Binoculars',
    weight = 750,
    stack = false,
    close = true,
    description = 'Binoculars with night and thermal vision',
},
```

**qb-core** — add to `qb-core/shared/items.lua`:

```lua
binoculars = { name = 'binoculars', label = 'Binoculars', weight = 500, type = 'item', image = 'binoculars.png', unique = true, useable = true, shouldClose = true, description = 'Look at things far away' },
binoculars_modes = { name = 'binoculars_modes', label = 'Tactical Binoculars', weight = 750, type = 'item', image = 'binoculars_modes.png', unique = true, useable = true, shouldClose = true, description = 'Binoculars with night and thermal vision' },
```

Images go in your inventory's image folder (`ox_inventory/web/images/` or `qb-inventory/html/images/`). Usage is registered through the framework (`ESX.RegisterUsableItem`, `QBCore.Functions.CreateUseableItem`, `exports.qbx_core:CreateUseableItem`), so no `client`/`server` export is needed on the item.

If another resource already registers a usable `binoculars` item (for example qb-smallresources), remove that registration or rename the item in `Config.Binoculars`.

## Integration

### Client exports

```lua
-- Toggle, force on or force off
-- state: true = on, false = off, nil = toggle
-- useModes: true allows night/thermal vision (also requires Config.UseModes = true)
--- @return boolean active  -- state after the call
exports["force-binoculars"]:ToggleBinoculars(state, useModes)

-- Turn on (no-op if already active). Returns false if the player cannot use
-- binoculars right now (dead, in a vehicle, ragdolling or swimming)
--- @return boolean success
exports["force-binoculars"]:ActivateBinoculars(useModes)

-- Turn off and clean up
--- @return boolean wasActive  -- false if they were not active
exports["force-binoculars"]:DeactivateBinoculars()

-- Check if binoculars are active
--- @return boolean active
exports["force-binoculars"]:IsBinocularsActive()

-- Current state, returned as three values (not a table)
--- @return boolean active
--- @return integer modeIndex  -- index into Config.Modes (1 = default, 2 = nightvision, 3 = thermalvision)
--- @return number zoom        -- magnification factor, camera FOV = 90 / zoom
local active, modeIndex, zoom = exports["force-binoculars"]:GetBinocularsState()
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions, issues, or feature requests, please open an [issue](https://github.com/Force-Developing/force-binoculars/issues) or reach out on our [Discord](https://discord.gg/927gfpcyDe).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
