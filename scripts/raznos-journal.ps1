# ФАЙЛ: C:\astro-blog\scripts\raznos-journal.ps1
# Разнос каркаса журнала-пособия в memorial-korpech-crimea + git-публикация.
# Никогда не перезаписывает существующее. Журнал действий: reports\raznos-journal.log
#Requires -Version 7
$ErrorActionPreference = 'Stop'

$Head    = 'C:\astro-blog'
$SrcDash = 'C:\Projects\git-isolated-fixed\git-projects\context-vkru\dashboard'
$Dst     = Join-Path $Head 'memorial-korpech-crimea'
$logDir  = Join-Path $Head 'reports'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir 'raznos-journal.log'

function Log([string]$m) {
  $line = '[{0}] {1}' -f (Get-Date -Format 'HH:mm:ss'), $m
  Add-Content -LiteralPath $log -Value $line -Encoding utf8
  Write-Host $line
}
function Copy-IfAbsent([string]$from, [string]$to) {
  if (Test-Path -LiteralPath $to) { Log "пропуск (уже есть): $to"; return }
  New-Item -ItemType Directory -Force -Path (Split-Path $to) | Out-Null
  Copy-Item -LiteralPath $from -Destination $to
  Log "копия: $from -> $to"
}
function Write-IfAbsent([string]$path, [string]$text) {
  if (Test-Path -LiteralPath $path) { Log "пропуск (уже есть): $path"; return }
  New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
  Set-Content -LiteralPath $path -Value $text -Encoding utf8
  Log "создан: $path"
}
function Invoke-Git([string[]]$a) {
  & git -C $Dst @a
  if ($LASTEXITCODE -ne 0) { Log "ОШИБКА git: $($a -join ' ')"; exit 1 }
  Log "git: $($a -join ' ')"
}

# ---------- предварительные проверки ----------
if (-not (Test-Path -LiteralPath $SrcDash)) {
  Log "НЕТ источника: $SrcDash — останов"; exit 1
}
New-Item -ItemType Directory -Force -Path $Dst | Out-Null
Log "=== фаза А: разнос файлов ==="

# ---------- каркас дашборда (без node_modules и dist) ----------
$dstSrc = Join-Path $Dst 'src'
if (Test-Path -LiteralPath $dstSrc) { Log "пропуск (уже есть): src" }
else {
  Copy-Item -LiteralPath (Join-Path $SrcDash 'src') -Destination $dstSrc -Recurse
  Log "копия папки src"
}
foreach ($f in @('index.html','package.json','package-lock.json','tsconfig.json')) {
  Copy-IfAbsent (Join-Path $SrcDash $f) (Join-Path $Dst $f)
}

# ---------- vite.config.js с base './' (Pages по любому пути) ----------
Write-IfAbsent (Join-Path $Dst 'vite.config.js') @'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  base: './',
  plugins: [react(), tailwindcss()],
})
'@

Write-IfAbsent (Join-Path $Dst '.gitignore') @'
node_modules/
dist/
'@

# ---------- GitHub Actions: сборка и публикация Pages ----------
Write-IfAbsent (Join-Path $Dst '.github\workflows\deploy-pages.yml') @'
name: deploy-pages
on:
  push:
    branches: [main]
  workflow_dispatch:
permissions:
  contents: read
  pages: write
  id-token: write
concurrency:
  group: pages
  cancel-in-progress: true
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run build
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with:
          path: dist
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
'@

# ---------- источники урока и документы ----------
Copy-IfAbsent (Join-Path $Head 'docs\elimination-of-deficiencies.md') `
              (Join-Path $Dst 'docs\revision-1.md')

Write-IfAbsent (Join-Path $Dst 'docs\revision-2.md') @'
# Ревизия 2 - EdgeOne AI, follow-up от 04.09.2026 (конспект)
## Подтверждено исправленным
Umami удалён; Apiflash удалён (локальный /og + запись index);
imageHostURL удалён; twitterID свой; верификации очищены;
комментарии отключены; пост-пустышка добавлена.
## Остатки
01 Critical: PAT ghu_ в .git/config - отозвать, SSH.
02 High: пять языков без контента - пустые страницы и переключатель.
03 Medium: site.url = временный домен.
04 Medium: OG-шрифт Noto Sans SC без кириллицы.
05 Medium: словари i18n - демо «Переверстка».
06 Low: инертные ссылки комментов (waline, jsDelivr).
07 Low: mailto: в футере ломает regex компонента.
08 Low: английские строки (updated, min, 404).
09 Low: robots.txt теряет base.
10 Low: .ssh отслеживается.
11 Low: контент - пустышка.
'@

Write-IfAbsent (Join-Path $Dst 'docs\ITERATIONS.md') @'
# ИТЕРАЦИИ - интерактивный журнал исполнения шагов
Итерация = 1-3 ответа Кодера; конец = статус done + артефакт + галочка.
I-1 Скелет и публикация: Vite+React+TS+Tailwind; Actions->Pages.
I-2 Данные и список с галочками: src/data/steps.ts {id,title,status,details}.
I-3 Раскрывающиеся блоки и прогресс-бар.
I-4 Мини-анимации; уважать prefers-reduced-motion.
I-5 Урок «работа над ошибками EdgeOne AI» (astro-blog - пример):
    три этапа из revision-1/2.
I-6 Слои: «руководитель (не-ИТ)» / «juniors».
I-7 Лимиты: репо < 2МБ, data < 200КБ; архив в docs/archive.
'@

Write-IfAbsent (Join-Path $Dst 'QWEN.md') @'
# QWEN.md - полигон «Интерактивные уроки»
Предмет: интерактивный журнал шагов (прогресс, галочки, аккордеон,
мини-анимации). Стек: Vite + React + TypeScript + Tailwind.
Это ПЕСОЧНИЦА: dev/build/эксперименты разрешены.
Запреты: чужие репо; контекст > 3МБ; бинарники; «дашборд в дашборде».
astro-blog - ТОЛЬКО пример (docs/revision-1.md, revision-2.md).
Публикация: GitHub Actions при пуше; вручную НЕ публиковать.
Сессия <= 6 ответов; после 5-го - handover.md (последний шаг,
следующий шаг, последние id). Данные отдельно: src/data/*.ts.
Один ответ = один артефакт. Лимит: репо < 2МБ, data < 200КБ.
'@

Write-IfAbsent (Join-Path $Dst 'docs\REGULAMENT-MUSEUM.md') @'
# РЕГЛАМЕНТ (одна страница, для руководителя, не-ИТ)
1. Главный по смыслу - владелец мемориала; по технике - куратор.
2. Сайт обновляется сам; руками ничего нажимать не нужно.
3. НЕ трогать: репозиторий, пароли, ключи - они у владельца.
4. Добавить текст: передать файл куратору или владельцу;
   срок появления на сайте - до 7 дней.
5. Ошибка на сайте: написать куратору; резервная копия хранится
   в репозитории, история изменений - в журнале (аудит).
6. Контакты: владелец ____, куратор ____.
'@

# ---------- HEAD: скрыть вложенный репо из статуса astro-blog ----------
$headIgnore = Join-Path $Head '.gitignore'
if (-not (Select-String -LiteralPath $headIgnore -Pattern '^memorial-korpech-crimea/' -Quiet)) {
  Add-Content -LiteralPath $headIgnore -Value 'memorial-korpech-crimea/' -Encoding utf8
  Log "HEAD: в .gitignore добавлена строка memorial-korpech-crimea/"
}

# ---------- фаза Б: git-публикация (только после создания репо на GitHub) ----------
Log "=== фаза Б: публикация ==="
$ans = Read-Host 'Пустой репо memorial-korpech-crimea создан на GitHub? (да/нет)'
if ($ans -eq 'да') {
  Invoke-Git @('init','-b','main')
  Invoke-Git @('add','-A')
  Invoke-Git @('commit','-m','journal: skeleton, lessons data, actions')
  $rem = & git -C $Dst remote get-url origin 2>$null
  if (-not $rem) { Invoke-Git @('remote','add','origin','git@github.com:annachurasheva/memorial-korpech-crimea.git') }
  Invoke-Git @('push','-u','origin','main')
  Log 'ГОТОВО: далее Settings -> Pages -> Source: GitHub Actions'
} else {
  Log 'фаза Б пропущена: создайте репо на GitHub и запустите скрипт ещё раз'
}
Log "=== конец; лог: $log ==="


