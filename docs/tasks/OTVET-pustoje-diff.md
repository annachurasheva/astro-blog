<!-- ФАЙЛ: tasks/OTVET-pustoje-diff.md -->
# Ответ: пустой дифф и «много строк node_modules»

## Проверил репо сам — оно чистое
- `.gitignore` НА МЕСТЕ (содержит `node_modules/`).
- Файлов node_modules в репозитории НЕТ (404).
Значит «много строк» — это платформа Кодера показывает НЕОТСЛЕЖИВАЕМЫЕ
файлы его же рабочей установки. Это шум по правилу Ш1: игнорировать.
Критерий статуса: в `git status --short` нас интересуют только строки `M`
по нашим файлам; строки про node_modules — вне критерия;
`pnpm-lock.yaml` появиться НЕ должен.

## Почему дифф пуст
Новое окно Кодера = свежая чистая копия ветки. Правки прошлого окна
остались в том окне и пропали, потому что переносит только человек,
а мы перенести ещё не успели. Это цена правила 0 — и она нормальная:
теперь сразу после правок забираем диффы и переносим в тот же день.
Кодеру разрешаем продолжать, но микро-ходами и с пункта 7
(пункты 10–11 он вспомнил, а конфиг и package.json тоже пусты).

## Ваши фразы (по одной; отвал — стоп и мне)
В0: Ответь ТОЛЬКО одной строкой: node -v
    (если ответ не v24.5.0 — подаёте В1–В2c; если v24.5.0 — сразу В3)

В1: Поставь node ровно 24.5.0 тарболом:
    curl -fsSL https://nodejs.org/dist/v24.5.0/node-v64.5.0-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1
    (опечатка исправлена ниже, копировать эту строку:)
    curl -fsSL https://nodejs.org/dist/v24.5.0/node-v24.5.0-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1
    Затем ТОЛЬКО: which node; node -v

В2: Выполни ТОЛЬКО: corepack enable && corepack prepare pnpm@10.33.0 --activate && pnpm -v

В2b: Выполни ТОЛЬКО: rm -rf node_modules — ответь OK.

В2c: Выполни ТОЛЬКО: pnpm install --frozen-lockfile — ответь хвостом.

В3: Пункт 7: правка src/config.ts (без сборки): убрать чужое
    umamiAnalyticsID, customUmamiAnalyticsJS, imageHostURL; поставить
    author Anna Churasheva, почты anna.churasheva@gmail.com и
    79787883649@ya.ru, название «Мемориал Корпечь, Крым»;
    site.url и остальное НЕ трогать. Ответь списком изменённых строк.

В4: Пункт 8: в package.json ТОЛЬКО строка repository →
    https://github.com/annachurasheva/astro-blog

В5: Пункт 10: src/layouts/Head.astro — удалить обе ветки api.apiflash.com
    и ключ; og:image всегда `${base}/og/${postSlug ?? 'index'}.png`;
    механику (preload, отложенные стили, partytown) НЕ трогать.

В6: Пункт 11: src/pages/og/[...image].ts — добавить запись index
    (title/description из themeConfig.site).

В7: Выполни ТОЛЬКО: pnpm exec astro check — ответь хвостом.

В8: Диффы: git diff -- src/config.ts package.json src/layouts/Head.astro
    "src/pages/og/[...image].ts" — показать ПОЛНОСТЬЮ.
    Плюс git status --short: жду только M по этим четырём файлам;
    pnpm-lock.yaml — отсутствует; node_modules-строки — шум, вне критерия.

После В8 — перенос четырёх правок в GitHub (карандаш, по файлу за цикл),
моя raw-сверка, живой деплой, приёмка → ТОЧКА СТОП донора.