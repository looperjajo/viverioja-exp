@echo off
cd /d "%~dp0"
echo.
echo =========================================
echo   ViveRioja Experience — Guardar cambios
echo =========================================
echo.

git add -A

set /p msg="Descripcion del cambio (Enter = automatico): "
if "%msg%"=="" set msg=Actualizacion automatica

git commit -m "%msg%"

if %errorlevel%==0 (
    echo.
    echo Subiendo a GitHub...
    git push origin master
    echo.
    echo =========================================
    echo   LISTO. Cambios subidos correctamente.
    echo.
    echo   La pagina se actualiza sola en ~2 min:
    echo   https://looperjajo.github.io/viverioja-exp
    echo.
    echo   Ver estado del despliegue:
    echo   https://github.com/looperjajo/viverioja-exp/actions
    echo =========================================
) else (
    echo.
    echo   No habia cambios nuevos que guardar.
)

echo.
pause
