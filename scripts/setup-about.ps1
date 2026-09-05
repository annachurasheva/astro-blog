# Скрипт для обновления about-страницы
# Использование: .\scripts\setup-about.ps1

$ErrorActionPreference = "Stop"

Write-Host "=== Обновление about-страницы ===" -ForegroundColor Cyan

# Путь к директории about
$AboutDir = "src\content\about"

# Создаём директорию если не существует
if (-not (Test-Path $AboutDir)) {
    Write-Host "Создание директории $AboutDir..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force $AboutDir | Out-Null
    Write-Host "✓ Директория создана" -ForegroundColor Green
}

# Удаляем все существующие файлы about
Write-Host "Удаление старых файлов about..." -ForegroundColor Yellow
Get-ChildItem -Path $AboutDir -Filter "about-*.md" | Remove-Item -Force
Write-Host "✓ Старые файлы удалены" -ForegroundColor Green

# Создаём новый файл about-ru.md
$aboutContent = @'
---
lang: ru
---

## Мемориал Корпечь, Крым (Korpech Memorial, Crimea)

### 1. Понимание проекта (с нуля, факты)

**mem-2026** — восстановление связей: боец → документ → потомок.

**Цифры:**
- 3310 в учёте захоронения
- 600+ с документальным подтверждением на «Корпечь»
- 59 известных = офицеры
- По сектору фронта — 229 000+ погибших

**Источники:**
- obd-memorial/ЦАМО (приказ №181)
- Фотосканы рукописных журналов безвозвратных потерь («умер 19-3-1942, высота 28.3, яма, перезахоронение»)
- Журналы отправки похоронок (несистемные, в основном офицерская картотека)
- Адреса «кого известить», записанные со слов, с ошибками

**Треки:**
- **А «плиты»** (documented → approved → engraved)
- **Б «поиск»** (волонтёры/джуниоры, потомки)
- **С «передача»** (музей, кадетский класс — определиться)

**Представительство:**
- Сайт на Astro (этот репо)
- Образец формы — n52a.de/memorial/niesky/list (триада разделов, строгая таблица, доверие = данные + согласование с Минобороны)

**Расширение Context VK.RU** (репо alex-6675/context-vkru) — удочка контакта через соцсети; приоритет: mem-2026 первый.
'@

Write-Host "Создание about-ru.md..." -ForegroundColor Yellow
$aboutContent | Out-File -FilePath "$AboutDir\about-ru.md" -Encoding UTF8
Write-Host "✓ about-ru.md создан" -ForegroundColor Green

Write-Host "`n=== Результат ===" -ForegroundColor Cyan
Write-Host "Файл about-ru.md обновлён с информацией о проекте Мемориал Корпечь" -ForegroundColor White
Write-Host "`nГотово!" -ForegroundColor Green
