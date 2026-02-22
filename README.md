# Glass Cutter

A Project Zomboid mod that adds a **Glass Cutter** tool for safely removing glass panes from windows without smashing them. No more broken glass, cuts, and noise—just a clean removal.

## Requirements

- **Project Zomboid** Build 42
- **Maintenance 1** to perform the action

## Optional

- **ZItemTiers** — If installed, higher-tier cutters reduce break chance further.

## Installation

1. Subscribe on Steam Workshop, or
2. Download and extract to `%UserProfile%\Zomboid\Mods\ZGlassCutter\`
3. Enable **Glass Cutter** in the game’s Mods menu.

Safe to add or remove from existing games.

## Usage

1. Obtain a Glass Cutter (see [Obtaining](#obtaining)).
2. Right-click a window (not barricaded, not smashed, glass still present).
3. Choose **Window** → **Cut out glass**.
4. If successful, you receive a **Glass Panel**. If not, the window may smash and you risk cuts—wear gloves.

### Break Chance

The chance of breaking the window instead of cleanly cutting depends on:

| Factor            | Effect                                      |
|-------------------|---------------------------------------------|
| Maintenance       | −5% per level                               |
| Glassmaking       | −5% per level                               |
| Science           | −5% per level                               |
| Aiming            | −5% per level                               |
| Woodwork          | −5% per level                               |
| Agility           | −5% per level                               |
| Engineer profession | 50% reduction                           |
| All Thumbs trait  | +40% chance                                 |
| Awkward gloves    | +40% chance                                 |
| Too dark to read  | +20% chance                                 |
| ZItemTiers (tier) | −10% per tier above Common                  |

The context menu tooltip shows the exact break chance before you act.

## Obtaining

The Glass Cutter can be **found with other tools** (world loot) or **crafted**—but to craft it, you must find the recipe magazine first.

### Magazine

- **Magazine: Cutting Glass for Fun and Profit** — Teaches the recipe. Spawns in the same loot as GlassmakingMag1 (e.g. bookstores, libraries). Required for crafting.

### Crafting

- **Make Glass Cutter** (Assembly; requires the magazine to learn, Maintenance 1)

### World Loot

- The Glass Cutter appears in the same loot tables as Calipers (tool stores, garages, etc.).

## Items

| Item        | Description                                      |
|------------|---------------------------------------------------|
| Glass Cutter | Tool to cut glass from windows. Can be used as a makeshift weapon. |
| Magazine: Cutting Glass for Fun and Profit | Teaches the Make Glass Cutter recipe. |

## Compatibility

- Standalone: no dependencies.
- **ZItemTiers**: optional; improves break chance for higher-tier cutters.
- Tested on 42.13.1, 42.13.12, and 42.14 (unstable).

## Links

- [GitHub](https://github.com/zed-0xff/ZGlassCutter)
- [Support on Ko-fi](https://ko-fi.com/zed_0xff)

## License

See the repository for license details.
