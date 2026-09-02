Ошибка создания файла тестирования run-edge-vk-test_v03.ps1
файл удален. 



- проект использует pnpm 

```
=== Тестирование развёртывания на EdgeOne ===
Версия скрипта: 0.3
Дата: 2026-09-02 09:28:24

Проверка окружения...
✓ Node.js: v24.5.0
npm warn Unknown project config "ignore-unused-patches". This will stop working in the next major version of npm.
npm warn Unknown project config "shamefully-hoist". This will stop working in the next major version of npm.
✓ npm: 11.5.1
✓ package.json найден

Установка зависимостей...
npm warn Unknown project config "ignore-unused-patches". This will stop working in the next major version of npm.
npm warn Unknown project config "shamefully-hoist". This will stop working in the next major version of npm.
npm error Cannot read properties of null (reading 'edgesOut')
npm error A complete log of this run can be found in: C:\Users\An\AppData\Local\npm-cache\_logs\2026-09-02T06_28_26_236Z-debug-0.log
✗ Ошибка установки зависимостей
```

Прошу проверить на ошибвки в коде мой существующий файл run-edge-develop-test-v03.ps1