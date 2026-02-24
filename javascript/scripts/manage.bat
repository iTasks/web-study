@echo off
:: manage.bat — Full-stack project management (Windows Batch)
::
:: Usage:
::   scripts\manage.bat <command> [options]
::
:: Commands:
::   setup              Install all dependencies
::   dev [all|frontend|backend]  Start dev servers
::   build              Build frontend for production
::   test               Run all test suites
::   lint               Lint and type-check code
::   deploy [env]       Deploy with Docker Compose
::   docker <action>    Docker Compose: up|down|ps|logs|pull|build
::   clean              Remove build artefacts
::   status             Show running service status
::   logs [service]     Tail Docker Compose service logs
::   help               Show this message

setlocal EnableDelayedExpansion

:: ─── Paths ───────────────────────────────────────────────────────────────────
set "SCRIPT_DIR=%~dp0"
set "ROOT=%SCRIPT_DIR%.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"
set "FRONTEND_DIR=%ROOT%\roadmap"
set "BACKEND_DIR=%ROOT%\..\python\samples"
set "COMPOSE_FILE=%ROOT%\docker-compose.yml"

:: ─── Dispatch ─────────────────────────────────────────────────────────────────
set "CMD=%~1"
if "%CMD%"=="" set "CMD=help"
shift

if /i "%CMD%"=="setup"   goto cmd_setup
if /i "%CMD%"=="dev"     goto cmd_dev
if /i "%CMD%"=="build"   goto cmd_build
if /i "%CMD%"=="test"    goto cmd_test
if /i "%CMD%"=="lint"    goto cmd_lint
if /i "%CMD%"=="deploy"  goto cmd_deploy
if /i "%CMD%"=="docker"  goto cmd_docker
if /i "%CMD%"=="clean"   goto cmd_clean
if /i "%CMD%"=="status"  goto cmd_status
if /i "%CMD%"=="logs"    goto cmd_logs
if /i "%CMD%"=="help"    goto cmd_help
if /i "%CMD%"=="-h"      goto cmd_help
if /i "%CMD%"=="--help"  goto cmd_help

echo [ERROR] Unknown command: %CMD%
goto cmd_help

:: ─── setup ────────────────────────────────────────────────────────────────────
:cmd_setup
echo.
echo ============================================================
echo   Setup -- Installing Dependencies
echo ============================================================

if exist "%FRONTEND_DIR%" (
    echo.
    echo  Frontend -- npm install
    npm --prefix "%FRONTEND_DIR%" install
    if errorlevel 1 ( echo [ERROR] npm install failed ) else ( echo [OK] Frontend deps installed )
) else (
    echo [WARN] Frontend dir not found: %FRONTEND_DIR%
)

if exist "%BACKEND_DIR%" (
    for /r "%BACKEND_DIR%" %%R in (requirements*.txt) do (
        echo.
        echo  Backend -- pip install -r %%~nxR
        python -m pip install -r "%%R"
        if errorlevel 1 ( echo [ERROR] pip install failed for %%~nxR ) else ( echo [OK] Installed %%~nxR )
    )
) else (
    echo [WARN] Backend dir not found: %BACKEND_DIR%
)
goto end

:: ─── dev ──────────────────────────────────────────────────────────────────────
:cmd_dev
set "SVC=%~1"
if "%SVC%"=="" set "SVC=all"
echo.
echo ============================================================
echo   Dev Servers -- %SVC%
echo ============================================================

if /i not "%SVC%"=="backend" (
    if exist "%FRONTEND_DIR%" (
        echo   Starting frontend on port 5173 ...
        start "Frontend Dev" cmd /k "npm --prefix ""%FRONTEND_DIR%"" run dev"
    ) else (
        echo [WARN] Frontend dir not found: %FRONTEND_DIR%
    )
)

if /i not "%SVC%"=="frontend" (
    if exist "%BACKEND_DIR%" (
        echo   Starting backend on port 8000 ...
        start "Backend Dev" cmd /k "cd /d ""%BACKEND_DIR%"" && python -m uvicorn app.main:app --reload --port 8000"
    ) else (
        echo [WARN] Backend dir not found: %BACKEND_DIR%
    )
)

echo.
echo   Servers launched in separate windows. Close them to stop.
goto end

:: ─── build ────────────────────────────────────────────────────────────────────
:cmd_build
echo.
echo ============================================================
echo   Build -- Frontend Production Build
echo ============================================================
if not exist "%FRONTEND_DIR%" (
    echo [ERROR] Frontend dir not found: %FRONTEND_DIR%
    exit /b 1
)
npm --prefix "%FRONTEND_DIR%" run build
if errorlevel 1 ( echo [ERROR] Build failed ) else ( echo [OK] Build complete -- dist/ )
goto end

:: ─── test ─────────────────────────────────────────────────────────────────────
:cmd_test
echo.
echo ============================================================
echo   Test Suites
echo ============================================================
set "ERRS=0"

if exist "%FRONTEND_DIR%" (
    echo  Frontend -- npm test
    npm --prefix "%FRONTEND_DIR%" test -- --run
    if errorlevel 1 ( echo [ERROR] Frontend tests failed & set /a ERRS+=1 ) else ( echo [OK] Frontend tests passed )
)

if exist "%BACKEND_DIR%" (
    echo  Backend -- pytest
    python -m pytest -v "%BACKEND_DIR%"
    if errorlevel 1 ( echo [ERROR] Backend tests failed & set /a ERRS+=1 ) else ( echo [OK] Backend tests passed )
)

if "%ERRS%"=="0" ( echo [OK] All tests passed ) else ( echo [ERROR] %ERRS% suite(s) failed )
goto end

:: ─── lint ─────────────────────────────────────────────────────────────────────
:cmd_lint
echo.
echo ============================================================
echo   Lint and Type-check
echo ============================================================
set "ERRS=0"

if exist "%FRONTEND_DIR%" (
    npm --prefix "%FRONTEND_DIR%" run lint        & if errorlevel 1 set /a ERRS+=1
    npm --prefix "%FRONTEND_DIR%" run type-check  & if errorlevel 1 set /a ERRS+=1
)

if exist "%BACKEND_DIR%" (
    where ruff >nul 2>&1 && (
        cd /d "%BACKEND_DIR%" && ruff check . & if errorlevel 1 set /a ERRS+=1
    ) || echo [WARN] ruff not found -- skipping

    where mypy >nul 2>&1 && (
        cd /d "%BACKEND_DIR%" && mypy . & if errorlevel 1 set /a ERRS+=1
    ) || echo [WARN] mypy not found -- skipping
)

if "%ERRS%"=="0" ( echo [OK] All lint checks passed ) else ( echo [ERROR] %ERRS% check(s) failed )
goto end

:: ─── deploy ───────────────────────────────────────────────────────────────────
:cmd_deploy
set "ENV=%~1"
if "%ENV%"=="" set "ENV=production"
echo.
echo ============================================================
echo   Deploy -- %ENV%
echo ============================================================
call :docker_run pull
call :docker_run up -d --build --remove-orphans
echo [OK] Deployment complete
goto end

:: ─── docker ───────────────────────────────────────────────────────────────────
:cmd_docker
set "ACT=%~1"
if "%ACT%"=="" set "ACT=ps"
echo.
echo ============================================================
echo   Docker -- %ACT%
echo ============================================================

if /i "%ACT%"=="up"    ( call :docker_run up -d & goto end )
if /i "%ACT%"=="down"  ( call :docker_run down & goto end )
if /i "%ACT%"=="ps"    ( call :docker_run ps & goto end )
if /i "%ACT%"=="logs"  ( call :docker_run logs --tail=50 -f & goto end )
if /i "%ACT%"=="pull"  ( call :docker_run pull & goto end )
if /i "%ACT%"=="build" ( call :docker_run build & goto end )

echo [ERROR] Unknown docker action: %ACT%. Choose: up, down, ps, logs, pull, build
exit /b 1

:docker_run
if exist "%COMPOSE_FILE%" (
    docker compose -f "%COMPOSE_FILE%" %*
) else (
    docker compose %*
)
goto :eof

:: ─── clean ────────────────────────────────────────────────────────────────────
:cmd_clean
echo.
echo ============================================================
echo   Clean -- Removing Build Artefacts
echo ============================================================
for %%D in (
    "%FRONTEND_DIR%\dist"
    "%FRONTEND_DIR%\.vite"
    "%FRONTEND_DIR%\coverage"
    "%BACKEND_DIR%\.pytest_cache"
    "%BACKEND_DIR%\.mypy_cache"
    "%BACKEND_DIR%\.ruff_cache"
) do (
    if exist %%D (
        rmdir /s /q %%D
        echo   Removed: %%D
    )
)
for /d /r "%BACKEND_DIR%" %%C in (__pycache__) do (
    if exist "%%C" ( rmdir /s /q "%%C" & echo   Removed: %%C )
)
echo [OK] Clean complete
goto end

:: ─── status ───────────────────────────────────────────────────────────────────
:cmd_status
echo.
echo ============================================================
echo   Service Status
echo ============================================================
echo.
echo Docker Compose services:
call :docker_run ps 2>nul || echo [WARN] Docker not available

echo.
echo Local ports:
netstat -ano -p TCP 2>nul | findstr /r ":5173 .*LISTENING" >nul 2>&1 && (
    echo   frontend  port 5173  RUNNING
) || echo   frontend  port 5173  STOPPED

netstat -ano -p TCP 2>nul | findstr /r ":8000 .*LISTENING" >nul 2>&1 && (
    echo   backend   port 8000  RUNNING
) || echo   backend   port 8000  STOPPED
goto end

:: ─── logs ─────────────────────────────────────────────────────────────────────
:cmd_logs
set "SVC=%~1"
echo.
echo ============================================================
echo   Logs -- %SVC%
echo ============================================================
if "%SVC%"=="" (
    call :docker_run logs --tail=100 -f
) else (
    call :docker_run logs --tail=100 -f %SVC%
)
goto end

:: ─── help ─────────────────────────────────────────────────────────────────────
:cmd_help
echo.
echo  manage.bat -- Full-stack project management (Windows Batch)
echo.
echo  Usage:  scripts\manage.bat ^<command^> [options]
echo.
echo  Commands:
echo    setup              Install all dependencies
echo    dev [all^|frontend^|backend]  Start dev servers (default: all)
echo    build              Build frontend for production
echo    test               Run all test suites
echo    lint               Lint and type-check code
echo    deploy [env]       Deploy with Docker Compose (default: production)
echo    docker ^<action^>    Docker Compose: up^|down^|ps^|logs^|pull^|build
echo    clean              Remove build artefacts
echo    status             Show running service status
echo    logs [service]     Tail Docker Compose service logs
echo    help               Show this message
echo.
goto end

:end
endlocal
