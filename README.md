# Big Walk Mod Manager

A double-clickable Windows mod installer and uninstaller for **Big Walk**.

Friends only need to download and run this one file:

`BigWalk-Mod-Manager.bat`

They do **not** need to clone or download the whole repository. The BAT file downloads the current PowerShell helper and only the selected action script from this GitHub repository each time it runs. It can:

- Let the user check exactly which mods to install or update
- Let the user check exactly which mods to uninstall
- Start with every mod unchecked so nothing is installed accidentally
- Offer fifteen independently selectable mods
- Create an installed-mod controls note and a Desktop shortcut to open it in Notepad
- Remove all BepInEx mods and BepInEx
- Show the current installation status
- Launch Big Walk

## Included mods

| Key | Mod | Install-menu default | Notes |
| --- | --- | --- | --- |
| 1 | BigYeet | Unchecked | Charged player throws and kicks; installs with the `0.70` throw multiplier |
| 2 | BigDart | Unchecked | Darts, smoke effects, and a temporary speed boost |
| 3 | BigTeleport | Unchecked | Teleport to the map room or completed puzzle gourds |
| 4 | BigFirework | Unchecked | Host-synchronized firework shows; required support mods install automatically |
| 5 | Mady's MiniMap | Unchecked | Full map, minimap, waypoints, and searchable locations |
| 6 | NoClip | Unchecked | Host-only noclip and free flight |
| 7 | Better Trains | Unchecked | Faster trains when the mod user is hosting |
| 8 | QuickBelt | Unchecked | Quickly take and return belt items |
| 9 | Item Debug | Unchecked | Item and colour debug panel |
| A | Big Run | Unchecked | Toggle super speed and high jump |
| B | MapParachute | Unchecked | Use the opened map as a parachute |
| C | TeleportToPlayer | Unchecked | Teleport to a random player and return |
| D | BigBack | Unchecked | Carry large items in inventory slots; required Core support mod installs automatically |
| E | Mady's HideNSeek | Unchecked | Host-controlled hide-and-seek mode |
| F | Big Person View | Unchecked | Third-person, front, free, and locked camera modes |

Every entry is optional. Toggle the checkboxes in the BAT menu before installing.

The selection screen explains that `[X]` means the mod will be installed and `[ ]` means it will be skipped. Press keys `1` through `9` or `A` through `F` to toggle entries, then press `I` to install everything marked `[X]`. The uninstall menu works the same way and uses `U` to remove the checked mods.

## Automatic setup

Every mod installer automatically:

1. Finds Steam through the Windows registry.
2. Reads every configured Steam library.
3. Locates Big Walk, regardless of drive letter.
4. Checks for BepInEx 6 IL2CPP.
5. Installs BepInEx if it is missing or incomplete.
6. Checks Thunderstore for the newest selected mod versions.
7. Downloads, installs, and verifies only the selected mods.
8. Rebuilds `Documents\Big Walk Mod Controls.txt` for the mods actually installed.
9. Creates or updates a `Big Walk Mod Controls` shortcut on the Windows Desktop.

Selecting BigFirework also installs or updates its required ModSettingsMenu and BigWalkLocalizationAPI dependencies. Selecting BigBack installs or updates its required `gugger-Core` support mod. BepInEx is checked and installed automatically for every mod.

Selective uninstall leaves shared support mods in place in case another mod needs them. The **Remove ALL mods and BepInEx** option removes everything. The controls note is regenerated after installs and uninstalls and lists only supported mods still detected in the plugins folder.

No fixed Steam path is required.

## Usage

1. [Download BigWalk-Mod-Manager.bat](https://github.com/DooleyDigital/bwmod/raw/refs/heads/main/BigWalk-Mod-Manager.bat).
2. Double-click the BAT file.
3. Approve the Windows administrator prompt.
4. Choose an option from the menu.

Windows may warn that the BAT file is unsigned. The BAT and every PowerShell script are plain text and can be reviewed in this repository.

## BigYeet throw-strength updater

If BigYeet does not throw far enough, download and double-click [Update-BigYeet-Throw.bat](https://github.com/DooleyDigital/bwmod/raw/refs/heads/main/Update-BigYeet-Throw.bat).

This is also a one-file launcher. It automatically downloads the current updater scripts from this repository, finds Big Walk, confirms BigYeet is installed, and updates only `BepInEx\config\BigYeet.cfg`. Press Enter to use the recommended `0.70` multiplier, which is twice BigYeet's original `0.35` default, or enter another value from `0.05` through `5.0`. Existing configs are backed up before they are changed. The regular BigYeet installer now applies `0.70` automatically too.

## Important multiplayer note

Everyone in a lobby should use the same multiplayer-affecting mods and versions. The installer checks Thunderstore for the newest release of each selected mod when it runs.

## Files

```text
BigWalk-Mod-Manager.bat
Update-BigYeet-Throw.bat
scripts/
  Common.ps1
  Install-BigDart.ps1
  Install-BigYeet.ps1
  Manage-SelectedMods.ps1
  Uninstall-BigDart.ps1
  Uninstall-BigYeet.ps1
  Uninstall-AllModsAndBepInEx.ps1
  Get-ModStatus.ps1
  Update-BigYeet-Throw.ps1
```

`Common.ps1` contains Steam detection, Big Walk detection, downloading, BepInEx setup, installation, removal, and verification. `Manage-SelectedMods.ps1` receives the checkbox selections from the BAT menu and runs only those actions.

## Sources

- [BigDart on Thunderstore](https://thunderstore.io/c/big-walk/p/hsiddaz/BigDart/)
- [BigYeet on Thunderstore](https://thunderstore.io/c/big-walk/p/hsiddaz/BigYeet/)
- [BigTeleport on Thunderstore](https://thunderstore.io/c/big-walk/p/markviews/BigTeleport/)
- [BigFirework on Thunderstore](https://thunderstore.io/c/big-walk/p/Trifocals/BigFirework/)
- [Mady's MiniMap on Thunderstore](https://thunderstore.io/c/big-walk/p/AdamMady/Madys_MiniMap/)
- [NoClip on Thunderstore](https://thunderstore.io/c/big-walk/p/jangles/NoClip/)
- [Better Trains on Thunderstore](https://thunderstore.io/c/big-walk/p/BayTurtleKing/Better_Trains/)
- [QuickBelt on Thunderstore](https://thunderstore.io/c/big-walk/p/hsiddaz/QuickBelt/)
- [Item Debug on Thunderstore](https://thunderstore.io/c/big-walk/p/SixSevenBrigade/Item_Debug/)
- [Big Run on Thunderstore](https://thunderstore.io/c/big-walk/p/BayTurtleKing/Big_Run/)
- [MapParachute on Thunderstore](https://thunderstore.io/c/big-walk/p/gogogadgetjustice/MapParachute/)
- [TeleportToPlayer on Thunderstore](https://thunderstore.io/c/big-walk/p/YonahG0y/TeleportToPlayer/)
- [BigBack on Thunderstore](https://thunderstore.io/c/big-walk/p/gugger/BigBack/)
- [Mady's HideNSeek on Thunderstore](https://thunderstore.io/c/big-walk/p/AdamMady/Madys_HideNSeek/)
- [Big Person View on Thunderstore](https://thunderstore.io/c/big-walk/p/SixSevenBrigade/Big_Person_View/)
- [BepInEx builds](https://builds.bepinex.dev/projects/bepinex_be)

This is an unofficial community utility. Big Walk, BepInEx, Thunderstore, and all listed mods belong to their respective owners.
