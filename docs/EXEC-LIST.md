<!-- ФАЙЛ: docs/EXEC-LIST.md -->
# EXEC-LIST v2 — список на исполнение для Кодера
Читать ПОСЛЕ `AGENTS.md`. Журнал — `docs/JOURNAL.md`.
Один пункт = один ответ с артефактом. Не забегать вперёд.

## Пункт 1. Среда и стенд
- Если платформа умеет devcontainer: открыть проект через
  `.devcontainer/devcontainer.json` (среда уже зафиксирована рецептом автора;
  `postCreateCommand` там совпадает с нашей командой среды).
- Если не умеет: `corepack enable && corepack prepare pnpm@10.33.0 --activate && pnpm install --frozen-lockfile`
- Фиксация стенда (3A, С2-СТЕНД): `node -v`; `pnpm -v`; `git status --short`; `git log -1 --oneline`.
- Отдать: отчёт, блок ENV с реальными выводами. Код НЕ трогать.

## Пункт 2. Базовая линия
- `pnpm run build` БЕЗ правок кода.
- Отдать: хвост вывода; статус PASS/FAIL. При FAIL — остановиться, код не чинить.

## Пункт 3. Конфиг и идентичность (только перечисленное!)
В `src/config.ts`:
- убрать чужое: `umamiAnalyticsID`, `customUmamiAnalyticsJS` (`views.radishzz.cc`),
  `imageHostURL` (`image.radishzz.cc`); проверить, что локальные картинки
  собираются;
- поставить позывные донора: author `Anna Churasheva`;
  почты `anna.churasheva@gmail.com`, `79787883649@ya.ru`;
  название сайта «Мемориал Корпечь, Крым»;
- `site.url` — оставить текущий тестовый домен EdgeOne;
- НЕ ТРОГАТЬ: комментарии, языки, остальное.
В `package.json`:
- `repository` — `https://github.com/annachurasheva/astro-blog`.
- Отдать: полный `src/config.ts` и полный `package.json` + хвост сборки.

## Пункт 4. Apiflash: убрать, не сломав
- `src/layouts/Head.astro`: удалить обе ветки `api.apiflash.com` и ключ;
  `og:image` всегда из локального генератора: `${base}/og/${postSlug ?? 'index'}.png`.
  МЕХАНИКУ Head.astro (preload, отложенные стили, partytown) НЕ трогать —
  это заплатка под 100 баллов.
- `src/pages/og/[...image].ts`: добавить запись `index`
  (title/description из `themeConfig.site`).
- Сборка; убедиться, что `dist/og/index.png` создан.
- Отдать: оба файла целиком + хвост сборки.
- Если за один шаг не выходит — BLOCKED; чужой ключ НЕ возвращать.

## Пункт 5. Пакет передачи
- Отдать по одному файлу на блок, ничего сверх:
  `src/config.ts`, `package.json`, `src/layouts/Head.astro`,
  `src/pages/og/[...image].ts`.

## Дальше (после приёмки 1–5)
Фаза «разместить тексты Заказчика» — задания проектировщика, один текст
за цикл. Очередь косяков из `docs/elimination-of-deficiencies.md`
до конца фазы НЕ трогать. `update-theme` НЕ запускать никогда без задачи.