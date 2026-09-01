# Big Walk Mod Manager

A double-clickable Windows mod installer and uninstaller for **Big Walk**.

Friends only need to download and run this one file:

`BigWalk-Mod-Manager.bat`

They do **not** need to clone or download the whole repository. The BAT file downloads the current PowerShell helper and only the selected action script from this GitHub repository each time it runs. It can:

- Install or update BigDart
- Install or update BigYeet
- Install both mods
- Uninstall either mod separately
- Remove all BepInEx mods and BepInEx
- Show the current installation status
- Launch Big Walk

## Automatic setup

Every mod installer automatically:

1. Finds Steam through the Windows registry.
2. Reads every configured Steam library.
3. Locates Big Walk, regardless of drive letter.
4. Checks for BepInEx 6 IL2CPP.
5. Installs BepInEx if it is missing or incomplete.
6. Checks Thunderstore for the newest mod version.
7. Downloads, installs, and verifies the selected mod.

No fixed Steam path is required.

## Usage

1. [Download BigWalk-Mod-Manager.bat](https://github.com/DooleyDigital/bwmod/raw/refs/heads/main/BigWalk-Mod-Manager.bat).
2. Double-click the BAT file.
3. Approve the Windows administrator prompt.
4. Choose an option from the menu.

Windows may warn that the BAT file is unsigned. The BAT and every PowerShell script are plain text and can be reviewed in this repository.

## Important multiplayer note

Everyone in a lobby should use the same multiplayer-affecting mods and versions. The installer checks Thunderstore for the latest BigDart and BigYeet releases when it runs.

## Files

```text
BigWalk-Mod-Manager.bat
scripts/
  Common.ps1
  Install-BigDart.ps1
  Install-BigYeet.ps1
  Uninstall-BigDart.ps1
  Uninstall-BigYeet.ps1
  Uninstall-AllModsAndBepInEx.ps1
  Get-ModStatus.ps1
```

`Common.ps1` contains Steam detection, Big Walk detection, downloading, BepInEx setup, installation, removal, and verification. The individual action scripts stay separate so the BAT file only runs the action selected by the user.

## Sources

- [BigDart on Thunderstore](https://thunderstore.io/c/big-walk/p/hsiddaz/BigDart/)
- [BigYeet on Thunderstore](https://thunderstore.io/c/big-walk/p/hsiddaz/BigYeet/)
- [BepInEx builds](https://builds.bepinex.dev/projects/bepinex_be)

This is an unofficial community utility. Big Walk, BepInEx, Thunderstore, BigDart, and BigYeet belong to their respective owners.
