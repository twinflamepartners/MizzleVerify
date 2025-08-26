// Launch-MizzleVerify.js — minimal, no logging, no probe.js
// Purpose: start the GUI PS1 via 64-bit PowerShell with no console window
// Usage (context menu): wscript.exe //nologo "C:\\_Local_Dev_Ops\\Tools\\Launch-MizzleVerify.js" "%1"

var fso = new ActiveXObject("Scripting.FileSystemObject");
var sh  = new ActiveXObject("WScript.Shell");

function q(a){
  if (a.indexOf('"') >= 0) a = a.replace(/"/g, '\\"');
  if (/\s/.test(a)) a = '"' + a + '"';
  return a;
}

// Forward all args (e.g., the clicked file path)
var args = "";
for (var i = 0; i < WScript.Arguments.Length; i++) args += " " + q(WScript.Arguments(i));

function fileExists(p){ try { return fso.FileExists(p); } catch(e){ return false; } }

// Resolve 64-bit PowerShell even when invoked from a 32-bit host
var sysNativePS = sh.ExpandEnvironmentStrings("%SystemRoot%\\SysNative\\WindowsPowerShell\\v1.0\\powershell.exe");
var sys32PS     = sh.ExpandEnvironmentStrings("%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe");
var psExe = fileExists(sysNativePS) ? sysNativePS : sys32PS;

var ps1   = "C:\\_Local_Dev_Ops\\Tools\\SHA256-Verify-GUI.ps1";
var parms = '-NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -STA -File "' + ps1 + '"' + args;

// Launch hidden via ShellExecute; fallback to WScript.Shell.Run
try {
  var shellApp = new ActiveXObject("Shell.Application");
  shellApp.ShellExecute(psExe, parms, "", "open", 0); // 0 = hidden
} catch (e) {
  try {
    sh.Run('"' + psExe + '" ' + parms, 0, false); // 0 = hidden, async
  } catch (ee) {
    try { WScript.Echo("Launcher error: " + ee.message); } catch (eee) {}
  }
}
