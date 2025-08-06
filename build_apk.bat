@echo off
echo.
echo ===============================================
echo    GENERANDO APK - APLICACION MIGRACION RD
echo ===============================================
echo.

echo [1/4] Limpiando proyecto...
call flutter clean

echo.
echo [2/4] Obteniendo dependencias...
call flutter pub get

echo.
echo [3/4] Analizando codigo...
call flutter analyze

echo.
echo [4/4] Generando APK de release...
call flutter build apk --release

echo.
echo ===============================================
echo           CONSTRUCCION COMPLETADA
echo ===============================================
echo.
echo El APK se encuentra en:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo Tamaño del archivo:
for %%I in (build\app\outputs\flutter-apk\app-release.apk) do echo %%~zI bytes
echo.
echo Presiona cualquier tecla para continuar...
pause >nul
