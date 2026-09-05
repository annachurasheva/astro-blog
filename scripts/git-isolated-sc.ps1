# ФАЙЛ: C:\astro-blog\scripts\git-isolated-sc.ps1  (v2, коррекции FIX-1..FIX-8)
# Astro Blog — изолированная среда Git + SSH (GitHub) + зеркало SC + SourceCraft CLI
# v2: блокоустойчивость (GitHub опционален, SC обязателен), remote sc,
#     keyscan, untrack .ssh, идентичность, src опционален, -PushMirror.
# Требования: pwsh 7.x (тестировалось 7.6.5, W10). Окно НЕ закрывается.
# ВАЖНО: .ssh/astro_blog — приватный ключ; не коммитить.
param(
    [switch]$PushMirror   # сознательное зеркалирование в sc (человек решает)
)

$requiredPSVersion = [version]'7.0'
if ($PSVersionTable.PSVersion -lt $requiredPSVersion) {
    Write-Error "Требуется PowerShell $requiredPSVersion+ (у вас $($PSVersionTable.PSVersion))."
    exit 1
}
$ErrorActionPreference = "Stop"

# ============================================================
# 1. Параметры проекта
# ============================================================
$dir          = "C:\astro-blog"
$gitDir       = "$dir\.git"
$sshDir       = "$dir\.ssh"
$key          = "$sshDir\astro_blog"
$pubKey       = "$sshDir\astro_blog.pub"
$knownHosts   = "$sshDir\known_hosts"

$toolsScripts = "C:\Tools\Scripts"
$openSsh      = "C:\Tools\OpenSSH"
$sshWrapper   = "$toolsScripts\ssh.bat"
$sshExe       = "$openSsh\ssh.exe"
$sshKeygen    = "$openSsh\ssh-keygen.exe"
$sshKeyscan   = "$openSsh\ssh-keyscan.exe"

$sourceCraftHome = "$dir\.sourcecraft"
$scSetupMarker   = "$sourceCraftHome\.setup-done"

# [FIX-2] Зеркало: учебный портал SourceCraft (замена/резерв GitHub)
$originUrl = "git@github.com:annachurasheva/astro-blog.git"
$scUrl     = "ssh://ssh.sourcecraft.dev/mem-2026/astro-blog.git"

# ============================================================
# 2. Проверяем проект
# ============================================================
if (-not (Test-Path $dir))  { throw "Папка проекта не найдена: $dir" }
if (-not (Test-Path $gitDir)) { throw "Это не Git-репозиторий: $gitDir" }
Set-Location $dir

# ============================================================
# 3. Изолированный Git
# ============================================================
$env:GIT_DIR = $gitDir
$env:GIT_WORK_TREE = $dir
$env:GIT_CONFIG_NOSYSTEM = "1"
$env:GIT_CONFIG_GLOBAL = "$gitDir\isolated-global-config"

# ============================================================
# 4. Изолированный SourceCraft + папки
# ============================================================
$env:SOURCECRAFT_HOME = $sourceCraftHome
New-Item -ItemType Directory -Force -Path $sshDir | Out-Null
New-Item -ItemType Directory -Force -Path $sourceCraftHome | Out-Null

# ============================================================
# 5. PATH только для этого сеанса
# ============================================================
$env:PATH = "$toolsScripts;$openSsh;$env:PATH"

# ============================================================
# 6. SSH-обёртка и OpenSSH
# ============================================================
if (-not (Test-Path $sshWrapper)) { throw "Не найдена SSH-обёртка: $sshWrapper" }
if (-not (Test-Path $sshExe))     { throw "Не найден OpenSSH: $sshExe" }
if (-not (Test-Path $sshKeygen))  { throw "Не найден ssh-keygen: $sshKeygen" }

# ============================================================
# 7. SSH-ключ (для GitHub и SC по SSH)
# ============================================================
if (-not (Test-Path $key)) {
    Write-Host "SSH-ключ не найден. Создаю ED25519..." -ForegroundColor Yellow
    & $sshKeygen -t ed25519 -f $key -N ""
    if ($LASTEXITCODE -ne 0) { throw "Не удалось создать SSH-ключ." }
    Write-Host "Новый ключ создан: $key" -ForegroundColor Green
} else {
    Write-Host "SSH-ключ найден: $key" -ForegroundColor Green
}

# ============================================================
# 8. Защищаем приватное от Git + [FIX-4] untrack .ssh (пункт К1)
# ============================================================
$gitignore = "$dir\.gitignore"
if (-not (Test-Path $gitignore)) { New-Item -ItemType File -Path $gitignore | Out-Null }
$ignoreLines = @(Get-Content $gitignore -ErrorAction SilentlyContinue)
foreach ($entry in @(".ssh/", ".sourcecraft/")) {
    if ($ignoreLines -notcontains $entry) {
        Add-Content -Path $gitignore -Value $entry
        Write-Host "Добавлено в .gitignore: $entry" -ForegroundColor Green
    }
}
# [FIX-4] .ssh мог остаться в индексе со старых времён — снять, не удаляя с диска.
$trackedSsh = git ls-files .ssh 2>$null
if ($trackedSsh) {
    git rm -r --cached .ssh | Out-Null
    Write-Host "[FIX-4] .ssh снят с отслеживания. Сделайте коммит вручную: git commit -m 'chore: untrack .ssh'" -ForegroundColor Yellow
}

# ============================================================
# 8.5 [FIX-5] Идентичность в изолированном конфиге (кастрированная W10)
# ============================================================
$isoCfg = $env:GIT_CONFIG_GLOBAL
if (-not (git config --file $isoCfg user.email 2>$null)) {
    git config --file $isoCfg user.name  "Anna Churasheva"
    git config --file $isoCfg user.email "anna.churasheva@gmail.com"
    Write-Host "[FIX-5] Идентичность записана в изолированный конфиг." -ForegroundColor Green
}

# ============================================================
# 9. Git SSH command (проектный ключ, проектный known_hosts)
# ============================================================
$sshCommand = "C:/Tools/Scripts/ssh.bat -i C:/astro-blog/.ssh/astro_blog -o UserKnownHostsFile=C:/astro-blog/.ssh/known_hosts"
git config --local core.sshCommand $sshCommand

# ============================================================
# 10. Remotes: origin (GitHub) + sc (зеркало) [FIX-2]
# ============================================================
$originExists = git remote get-url origin 2>$null
if (-not $originExists) { git remote add origin $originUrl }
elseif ($originExists -ne $originUrl) { git remote set-url origin $originUrl }

if (git remote | Select-String -SimpleMatch "origin2") {
    git remote remove origin2
    Write-Host "Удалён временный remote: origin2" -ForegroundColor Yellow
}

$scExists = git remote get-url sc 2>$null
if (-not $scExists) { git remote add sc $scUrl; Write-Host "[FIX-2] Добавлен remote sc: $scUrl" -ForegroundColor Green }
elseif ($scExists -ne $scUrl) { git remote set-url sc $scUrl }

# ============================================================
# 10.5 [FIX-3] known_hosts: ключи хостов заранее
# ============================================================
foreach ($h in @("github.com", "ssh.sourcecraft.dev")) {
    $present = Select-String -Path $knownHosts -Pattern ([regex]::Escape($h)) -Quiet -ErrorAction SilentlyContinue
    if (-not $present) {
        try {
            if (Test-Path $sshKeyscan) {
                & $sshKeyscan $h 2>$null | Add-Content $knownHosts
                Write-Host "[FIX-3] known_hosts += $h" -ForegroundColor Green
            }
        } catch { Write-Host "[FIX-3] keyscan $h не удался — пропуск." -ForegroundColor Yellow }
    }
}

# ============================================================
# 11. [FIX-1] Проверки доступности: SC обязателен, GitHub опционален
# ============================================================
Write-Host "" ; Write-Host "Проверяю SSH-доступ к SC (зеркало, обязательно)..." -ForegroundColor Cyan
git ls-remote sc HEAD | Out-Null
if ($LASTEXITCODE -ne 0) { throw "SC недоступен по SSH — зеркало невозможно. Останов." }
Write-Host "SC: OK" -ForegroundColor Green

$ghOk = $false
Write-Host "Проверяю SSH-доступ к GitHub (опционально)..." -ForegroundColor Cyan
git ls-remote origin HEAD | Out-Null
$ghOk = ($LASTEXITCODE -eq 0)
if ($ghOk) { Write-Host "GitHub: OK" -ForegroundColor Green }
else { Write-Host "[FIX-1] GitHub недоступен — работаем через SC. Это резервный маршрут, ничего не сломано." -ForegroundColor Yellow }

# ============================================================
# 12. SourceCraft CLI — опциональный слой [FIX-6]
# ============================================================
if (-not (Get-Command src -ErrorAction SilentlyContinue)) {
    Write-Host "SourceCraft CLI не обнаружен. Пробую установить (опционально)..." -ForegroundColor Yellow
    try {
        $installer = 'https://s3.yandexcloud.net/sourcecraft-cli/install.ps1'
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString($installer)
        Write-Host "SourceCraft установлен. Перезапускаю скрипт для PATH..." -ForegroundColor Yellow
        Start-Process pwsh -ArgumentList "-NoExit", "-File", ".\git-isolated-sc.ps1"
        exit
    } catch {
        Write-Host "[FIX-6] SourceCraft CLI не установлен — НЕ страшно: зеркало и git работают через SSH без src." -ForegroundColor Yellow
    }
} else {
    Write-Host "SourceCraft CLI: $(src --version 2>$null)" -ForegroundColor Green
}

# ============================================================
# 13. SourceCraft init/auth (идемпотентно, только если src есть)
# ============================================================
if (Get-Command src -ErrorAction SilentlyContinue) {
    if (-not (Test-Path $scSetupMarker)) {
        Write-Host "Первичная настройка SourceCraft (один раз)..." -ForegroundColor Cyan
        src init
        src auth login
        src auth setup-git
        src opencode install
        New-Item -ItemType File -Force -Path $scSetupMarker | Out-Null
        Write-Host "Первичная настройка SourceCraft завершена." -ForegroundColor Green
    } else {
        src auth status
        if ($LASTEXITCODE -ne 0) { Write-Host "Нет аутентификации — вход..." -ForegroundColor Yellow; src auth login }
        else { Write-Host "Аутентификация SourceCraft: OK" -ForegroundColor Green }
    }
}

# ============================================================
# 14. [FIX-7] fetch: sc всегда, origin только если жив
# ============================================================
Write-Host "" ; Write-Host "Обновляю remote branches..." -ForegroundColor Cyan
git fetch sc --prune
if ($LASTEXITCODE -ne 0) { throw "fetch sc не удался." }
if ($ghOk) { git fetch origin --prune } else { Write-Host "fetch origin пропущен (GitHub недоступен)." -ForegroundColor Yellow }

# ============================================================
# 15. Информация + [FIX-8] зеркало
# ============================================================
Write-Host "" ; Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Astro Blog — окружение готово (v2)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Project:    $dir"
Write-Host "Origin:     $originUrl  (доступен: $ghOk)"
Write-Host "SC mirror:  $scUrl  (доступен: True)"
Write-Host "SSH key:    $key"
Write-Host "SourceCraft:$sourceCraftHome"
Write-Host "" ; Write-Host "Remote:" ; git remote -v
Write-Host "" ; Write-Host "Branches:" ; git branch -a
Write-Host "" ; Write-Host "Git status:" ; git status --short --branch

if ($PushMirror) {
    Write-Host "[FIX-8] Зеркалирую в sc..." -ForegroundColor Cyan
    git push sc main main-qwen3-coder-plus-v01
    git push sc --tags 2>$null
    Write-Host "Зеркало обновлено." -ForegroundColor Green
} else {
    Write-Host "" ; Write-Host "Команды зеркала (когда решите):" -ForegroundColor Cyan
    Write-Host "  git push sc main main-qwen3-coder-plus-v01"
    Write-Host "  git push sc --tags"
    Write-Host "  или запуск с ключом: .\git-isolated-sc.ps1 -PushMirror"
}
Write-Host "" ; Write-Host "Основные команды:" -ForegroundColor Cyan
Write-Host "  git pull origin main   (если GitHub жив)"
Write-Host "  git add . ; git commit -m 'описание' ; git push origin main"
Write-Host "  pnpm dev"
Write-Host "" ; Write-Host " Готово. Окно остаётся открытым." -ForegroundColor Green