<!-- ФАЙЛ: docs/EXEC-LIST.md -->
# EXEC-LIST v5 — список на исполнение для Кодера
Читать ПОСЛЕ `QWEN.md`. Журнал — `docs/JOURNAL.md`.

Лимит платформы: ~10 минут на ход. Один ход = одна команда или одна правка.
Ответы короткие, правила не пересказывать. Отвал = стоп и ждать.
Команды ДЛЯ СТЕНДА — только PowerShell; в твоём пространстве — его шелл.
Нода у тебя = стенд = `.nvmrc` = 24.5.0 (тарбол в /usr/local).
Документы (`docs/**`, `QWEN.md`, `AGENTS.md`) НЕ изменять.

ИЗВЕСТНАЯ ПРОБЛЕМА (не тратить ресурс): картинки шаблона (sharp,
apply-lqip) обрабатываются ТОЛЬКО на деплой-стороне EdgeOne Pages.
Поэтому `pnpm run build` и `apply-lqip` у себя НЕ запускать никогда.
Контроль у тебя — только `pnpm exec astro check`. Полная сборка и
приёмка — после переноса файлов Заказчиком, на EdgeOne.

## Пункты 1–3 (выполнены). READ, LIST, corepack
## Пункт 4 (ход). Возврат документа
Только: `git restore docs/EXEC-LIST.md`; ответить `git status --short`.
## Пункт 5 (ход, выполнен). NOT TESTED + доказательство (apt-нода, nvm нет)
## Пункт 5.1 (ход). Нода 24.5.0 тарболом в /usr/local + which node; node -v
## Пункт 5.2 (ход). corepack enable && corepack prepare pnpm@10.33.0 --activate && pnpm -v
## Пункт 5.3 (ход). rm -rf node_modules
## Пункт 5.4 (ход). pnpm install --frozen-lockfile
## Пункт 5.5 (ход). node -v; pnpm -v; git status --short; git log -1 --oneline
   (жду v24.5.0 и 10.33.0)

## Пункт 6 (ход). Базовая линия типов
Только: `pnpm exec astro check`. Хвост вывода; статус PASS/FAIL.
При FAIL — стоп, не чинить.

## Пункт 7 (ход). Конфиг: правка без сборки
В `src/config.ts` только перечисленное:
- убрать чужое: `umamiAnalyticsID`, `customUmamiAnalyticsJS` (`views.radishzz.cc`),
  `imageHostURL` (`image.radishzz.cc`);
- позывные донора: author `Anna Churasheva`;
  почты `anna.churasheva@gmail.com`, `79787883649@ya.ru`;
  название «Мемориал Корпечь, Крым»;
- `site.url` — оставить текущий тестовый домен EdgeOne;
- НЕ ТРОГАТЬ: комментарии, языки, остальное, механику файла.
Ответить кратким списком изменённых строк.

## Пункт 8 (ход). package.json
Только строка `repository` → `https://github.com/annachurasheva/astro-blog`.

## Пункт 9 (ход). Контроль типов
Только: `pnpm exec astro check`. Хвост вывода.

## Пункт 10 (ход). Apiflash: Head.astro без сборки
Удалить обе ветки `api.apiflash.com` и ключ; `og:image` всегда
`${base}/og/${postSlug ?? 'index'}.png`. Механику (preload, отложенные
стили, partytown) НЕ трогать.

## Пункт 11 (ход). Apiflash: генератор без сборки
`src/pages/og/[...image].ts`: добавить запись `index`
(title/description из `themeConfig.site`).

## Пункт 12 (ход). Контроль типов
Только: `pnpm exec astro check`. Хвост вывода.

## Пункт 13 (ход). Пакет передачи
Комплект ТОЛЬКО из: `src/config.ts`, `package.json`,
`src/layouts/Head.astro`, `src/pages/og/[...image].ts`.
Отдать кнопкой «Скачать комплект (.zip)». Ничего сверх.

## Пункт 14 (после переноса, делает человек). Приёмка вживую
EdgeOne собирает сам. Проверки: сайт открывается; `/og/index.png`
открывается; в коде страницы Ctrl+F «apiflash» — 0; вердикт по картинке —
Заказчик. Статус в журнал.

## Дальше
Фаза «разместить тексты Заказчика» — задания проектировщика.
Очередь косяков из `docs/elimination-of-deficiencies.md` не трогать.
`update-theme` не запускать.