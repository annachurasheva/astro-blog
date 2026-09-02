# ============================================================================
# run-edge-develop-test-v03.ps1
# Запуск Microsoft Edge с чистым профилем для тестирования
# Окружение: PowerShell 7.6.5, Windows 10
# v3: ключи чистки браузерной памяти + автозагрузка расширения из dist
# ============================================================================

$requiredPSVersion = [version]'7.6.5'
if ($PSVersionTable.PSVersion -lt $requiredPSVersion) {
    Write-Error "Требуется PowerShell версии $requiredPSVersion или выше"
    exit 1
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$EdgePath   = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$ProfileDir = 'C:\Users\An\serv6675\Edge_test_context\'
$DistDir    = 'C:\astro-b-v2\test\dist'

if (-not (Test-Path $EdgePath)) {
    Write-Error "Не найден файл Edge: $EdgePath"
    exit 1
}

if (-not (Test-Path $ProfileDir)) {
    Write-Host "Создаю директорию профиля: $ProfileDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ProfileDir -Force
}

# ----------------------------------------------------------------------------
# ЧИСТКА ПАМЯТИ (БЕЗОПАСНО): только кэши.
# НЕ ТРОГАТЬ: Local Extension Settings (БАЗА КАРТОЧЕК!), Local Storage,
# IndexedDB, Preferences — там живёт ctxdb.
# ----------------------------------------------------------------------------
$cachePaths = @(
    "$ProfileDir\Default\Cache",
    "$ProfileDir\Default\Code Cache",
    "$ProfileDir\Default\GPUCache",
    "$ProfileDir\Default\ShaderCache",
    "$ProfileDir\Default\Service Worker\CacheStorage"
)
foreach ($p in $cachePaths) {
    if (Test-Path $p) {
        Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Вычищено: $p" -ForegroundColor DarkGray
    }
}

# ----------------------------------------------------------------------------
# Ключи запуска
# ----------------------------------------------------------------------------
$edgeArgs = @(
    "--user-data-dir=$ProfileDir",
    '--no-first-run',
    '--no-default-browser-check',
    '--disable-component-update',
    '--start-maximized',
    # --- чистота теста:
    '--disk-cache-size=1',                  # дисковый кэш фактически выключен
    '--media-cache-size=1',                 # медиа-кэш выключен
    '--aggressive-cache-discard',           # агрессивный сброс кэша
    '--disable-features=BackForwardCache',  # НЕТ «замороженных» страниц со старым контент-скриптом
    '--disable-session-crashed-bubble',     # нет пузыря «восстановить вкладки?»
    # --- автозагрузка расширения из dist (неудобно — уберите две строки):
    "--disable-extensions-except=$DistDir",
    "--load-extension=$DistDir"
)

Write-Host "Путь к Edge:      $EdgePath" -ForegroundColor Cyan
Write-Host "Директория профиля: $ProfileDir" -ForegroundColor Cyan
Write-Host "Расширение (dist): $DistDir" -ForegroundColor Cyan

Start-Process -FilePath $EdgePath -ArgumentList $edgeArgs

Write-Host ''
Write-Host 'Edge запущен: кэш чист, BackForwardCache выключен, расширение из dist.' -ForegroundColor Green
Write-Host 'ВАЖНО: после Reload расширения обновляйте вкладки VK (F5) —' -ForegroundColor Yellow
Write-Host 'контент-скрипт инжектится только при загрузке страницы.' -ForegroundColor Yellow