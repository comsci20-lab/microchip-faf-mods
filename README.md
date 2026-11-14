# Microchip FAF Mods

Standalone UI mods for Forged Alliance Forever, by Microchip.

**[Download releases](https://github.com/comsci20-lab/microchip-faf-mods/releases)**

| Mod | Folder | Requirements / purpose |
|---|---|---|
| Chat Mention | `Microchip-Chat-Mention` | Chat mention popups; UI Mod Tools for options |
| Client Test Recorder | `Microchip-Client-Test` | Passive local diagnostics; extra metrics need the updated engine |
| Eco Sharing | `Microchip-Eco-Sharing` | Share selected surplus with empty allies |
| Lobby Ready Alert | `Microchip-Lobby-Ready-Alert` | Alert when all lobby players are ready |
| Logo Stamps | `Microchip-Evil-Stamp` | Ctrl+Shift+L: MC Chip or Drunk Husky; painting enabled |
| F11 Connectivity | `Microchip-F11-Lag-Connectivity-Screen` | Sorted by total wait; optional "who is lagging?" chat bot (UI Mod Tools); wait metrics require the updated engine |
| Icon Mod | `Microchip-Icon-Mod` | Live icon scaling requires the updated engine and UI Mod Tools |
| Offline Chat | `Microchip-Offline-Chat` | Compatible engine plus separately installed translator and language packs |
| Team Colour Bands | `Microchip-Team-Colour-Bands` | Display-only team colours |

## Install or update

1. Close the game and download the ZIP for the mod you want from Releases.
2. Extract into `Documents/My Games/Gas Powered Games/Supreme Commander Forged Alliance/mods`.
3. Preserve the installation folder name exactly. Do not append a version or leave an extra wrapper folder.
4. Replace the previous copy when updating, avoiding duplicate mod UIDs. Enable the mod in FAF's UI Mod Manager.

Each release includes its requirements, installation notes and SHA-256 checksum.
Game executables and offline translation models are not bundled.

## Engine source

Engine updates remain separate in
[the Microchip x64 engine branch](https://github.com/comsci20-lab/faf-re/tree/codex/microchip-x64-engine).
Installing a UI mod alone does not add engine APIs. See each mod's README/mod_info.lua for details.

## Releases and testing

[Release instructions](tools/mod-release/README.md): update a mod's own version,
then push its matching tag. GitHub publishes only that mod. Branch pushes check
packaging without creating releases. Existing published versions are not overwritten.

```sh
python -m unittest discover -s tools/mod-release -p 'test_*.py' -v
python tools/mod-release/package.py --all --output out/mod-release-check
```

Lua unit checks under `tests/mods` require Python's `lupa` package. Native engine
integration tests remain in the engine repository. Original icon credits include
Caliber, BlackYps and Balthazar; preserve the attribution in the Icon Mod.

Initial source snapshot: `comsci20-lab/faf-re` mods branch at
`f3266c91bc7f36f8f02cee420f4983847724c640`. Mod releases are now published here; engine work remains in the faf-re fork.
