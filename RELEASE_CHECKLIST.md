# Release Checklist

## 1) Prep
- [ ] Update version in `build.ps1` invocation (e.g., `-Version "1.0.1.0"`).
- [ ] Ensure `src/SHA256-Verify-GUI.ps1` has any visible version string updated if you display it in the GUI/about box.

## 2) Build
```powershell
.\build.ps1 -Version "1.0.1.0"
```
- [ ] Confirm `dist\MizzleVerify.exe` exists.
- [ ] Compute hashes and save as `MizzleVerify_1.0.1.0_SHA256.txt`:
  ```powershell
  Get-FileHash .\dist\MizzleVerify.exe -Algorithm SHA256 | Format-List
  ```

## 3) (Optional) Code Sign
If you have a code signing certificate installed, sign + timestamp:
```powershell
signtool sign ^
  /fd SHA256 ^
  /tr http://timestamp.digicert.com ^
  /td SHA256 ^
  /a ^
  .\dist\MizzleVerify.exe
```
Then verify:
```powershell
signtool verify /pa /v .\dist\MizzleVerify.exe
```

## 4) Sanity Scan
- [ ] Upload the EXE to VirusTotal and confirm "0/xx" detections.

## 5) False‑Positive Channels (if flagged)
- [ ] Submit EXE as false positive to Microsoft Defender.
- [ ] Submit EXE as false positive to Norton.
- [ ] Keep your submission tracking IDs in `releases/<version>/submissions.txt`.

## 6) GitHub Release
- [ ] Create a new Release on GitHub `Twinflame Partners / MizzleVerify`.
- [ ] Attach:
  - `MizzleVerify.exe`
  - `MizzleVerify_1.0.1.0_SHA256.txt`
  - `tools/Add-VerifySHA256.reg`
  - `README.md` (optional duplicate for convenience)
- [ ] Note any changes in the Release notes.
