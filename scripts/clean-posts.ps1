# Скрипт для удаления шаблонных постов из проекта astro-b-v2
# Использование: .\scripts\clean-posts.ps1

$ErrorActionPreference = "Stop"

# Путь к директории с постами
$PostsDir = "src\content\posts"

Write-Host "=== Очистка шаблонных постов ===" -ForegroundColor Cyan

# Удаляем папки examples и guides
if (Test-Path "$PostsDir\examples") {
    Write-Host "Удаление папки examples..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "$PostsDir\examples"
    Write-Host "✓ Папка examples удалена" -ForegroundColor Green
} else {
    Write-Host "ℹ Папка examples не найдена" -ForegroundColor Gray
}

if (Test-Path "$PostsDir\guides") {
    Write-Host "Удаление папки guides..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "$PostsDir\guides"
    Write-Host "✓ Папка guides удалена" -ForegroundColor Green
} else {
    Write-Host "ℹ Папка guides не найдена" -ForegroundColor Gray
}

# Удаляем файл Universal Post.md
$universalPost = "$PostsDir\Universal Post.md"
if (Test-Path $universalPost) {
    Write-Host "Удаление Universal Post.md..." -ForegroundColor Yellow
    Remove-Item -Force $universalPost
    Write-Host "✓ Universal Post.md удалён" -ForegroundColor Green
} else {
    Write-Host "ℹ Universal Post.md не найден" -ForegroundColor Gray
}

# Подсчёт оставшихся постов
$remainingPosts = Get-ChildItem -Path $PostsDir -Filter "*.md" -Recurse | Measure-Object | Select-Object -ExpandProperty Count
Write-Host "`n=== Результат ===" -ForegroundColor Cyan
Write-Host "Осталось постов: $remainingPosts" -ForegroundColor White

if ($remainingPosts -eq 0) {
    Write-Host "✓ Все шаблонные посты успешно удалены" -ForegroundColor Green
    Write-Host "Теперь вы можете добавить свои собственные посты в папку $PostsDir" -ForegroundColor Cyan
}

Write-Host "`nГотово!" -ForegroundColor Green
