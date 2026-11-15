# Microchip Lobby Ready Alert

Copy the `Microchip-Lobby-Ready-Alert` folder to your FAF user `mods` directory, enable the mod in FAF, and open a new multiplayer lobby. Use a Windows faf-re build that includes the lobby ready alert hook and `SC_FlashGameWindow` command.

When every seated human player except you is Ready (and there is at least one), and they stay Ready for a second, the game plays an incoming-transmission sound and flashes the Windows title bar and taskbar button. Your own Ready box, empty slots, AI and observers are ignored. The alert fires once each time the others become ready.
