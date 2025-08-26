# MizzleVerify

Lightweight Windows GUI to verify a file's SHA‑256. Integrates with the right‑click context menu.

## Install (recommended: prebuilt EXE)

1. Copy `dist/MizzleVerify.exe` to `C:\_Local_Dev_Ops\Tools\MizzleVerify.exe` (or your preferred tools folder).
2. Import the context‑menu entry: double‑click `tools\Add-VerifySHA256.reg` and accept.
3. Right‑click any file → **Verify SHA‑256…**.

> **No PowerShell console appears.** The taskbar icon is the Mizzle icon embedded in the EXE.

## Install (script-only)

If you don’t want an EXE, run `src\SHA256-Verify-GUI.ps1` from PowerShell. A launcher `.js` is provided in `tools\Launch-MizzleVerify.js` for Windows Script Host users, but it isn’t required when using the EXE.

## Build from source

Open a PowerShell prompt at the repo root and run:

```powershell
.uild.ps1 -Version "1.0.0.0"
```

Artifacts land in `dist\`. You can change the icon/version via parameters.

## Uninstall

- Remove the context menu: `reg delete "HKCU\Software\Classes\*\shell\VerifySHA256" /f`
- Delete `C:\_Local_Dev_Ops\Tools\MizzleVerify.exe`

## Repository layout

```
MizzleVerify_repo_starter_20250826_194107/
├─ src/                       # PowerShell source
│  └─ SHA256-Verify-GUI.ps1
├─ tools/                     # Icons, .reg, optional JS launcher
│  ├─ Add-VerifySHA256.reg
│  ├─ Add-VerifySHA256.orig.reg   (original you uploaded, for reference)
│  ├─ Launch-MizzleVerify.js
│  ├─ mizzle-logo.ico
│  └─ mizzle-logo.png
├─ dist/                      # Build outputs (.exe lives here)
│  └─ .gitkeep
├─ build.ps1
├─ RELEASE_CHECKLIST.md
└─ .gitignore
```

## Credits

© Twinflame Partners. MizzleVerify logo by Twinflame Partners.
