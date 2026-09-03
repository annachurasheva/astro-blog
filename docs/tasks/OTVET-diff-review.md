<!-- ФАЙЛ: tasks/OTVET-diff-review.md -->
# Сверка диффов: принято с двумя поправками

## Что хорошо
- В конце вывода `git status --short` ровно четыре строки `M`:
  src/config.ts, package.json, src/layouts/Head.astro,
  src/pages/og/[...image].ts — состав совпадает с согласованным.
- Apiflash удалён полностью: и ключ, и обе ветки url; превью идёт
  на локальный генератор с ключом `index` — как задумано.
- Запись `index` в генераторе берёт title/description из themeConfig.site —
  верно.
- То, что на скрине слева опять файлы из node_modules (+819 и т.п.) —
  тот же шум установки, правило Ш1: игнорировать. Критерий — четыре `M`,
  они в порядке.

## Две поправки (моя вина в спецификации — исправляю)
1. `og:image` обязан быть АБСОЛЮТНЫМ адресом, иначе соцсети не подтянут
   превью. Строка `${base}/og/...png` даёт относительный путь.
   Вернуть обёртку new URL(..., Astro.url.origin), как было у постов.
2. В `[...image].ts` Кодер снёс комментарий
   `// eslint-disable-next-line antfu/no-top-level-await` над строкой
   `const posts = await getCollection('posts')` — вернуть на место,
   иначе линт будет ругать верхнеуровневый await.

## Ваши фразы Кодеру (по одной)
И1: Поправка в src/layouts/Head.astro: замени строку pageImage на
    const pageImage = new URL(`${base}/og/${postSlug ?? 'index'}.png`, Astro.url.origin)
    Больше ничего не трогать. Ответь одной строкой OK.

И2: Поправка в src/pages/og/[...image].ts: верни комментарий
    // eslint-disable-next-line antfu/no-top-level-await
    непосредственно над строкой const posts = await getCollection('posts')
    Больше ничего не трогать. Ответь одной строкой OK.

И3: Выполни ТОЛЬКО: pnpm exec astro check — хвост. Затем покажи ПОЛНОСТЬЮ:
    git diff -- src/config.ts package.json src/layouts/Head.astro "src/pages/og/[...image].ts"
    (жду все четыре диффа, включая конфиг и package.json — их я ещё не видел).

## После И3 — цепочка до СТОПа (без изменений)
1–4. Четыре правки в GitHub карандашом, по файлу за цикл.
Д0–Д4. clean-posts.ps1: ls-files → сохранить как → выполнить (жду 0) →
commit+push.
5. Моя raw-сверка по хэшу.
6. EdgeOne деплоит; приёмка вживую: сайт; /og/index.png; Ctrl+F «apiflash» = 0;
   шаблонных постов нет; вердикт по картинке — ваш. → ТОЧКА СТОП донора.