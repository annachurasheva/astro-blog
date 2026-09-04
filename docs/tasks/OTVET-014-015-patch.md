<!-- ФАЙЛ: tasks/OTVET-014-015-patch.md -->
# 014–015 · Да, заплатка одна и та же — теперь точно

## 014 · Что это за файл (одной человеческой строкой)
`patches/@qwik.dev__partytown@0.11.2.patch` — это и есть заплатка под
100 баллов: она учит partytown не трогать новые оконные API браузера
(sharedStorage, AttributionReporting и compagnia) — иначе в консоли
ошибки, а Lighthouse снимает баллы; заодно чинит имена переменных в
сниппете. Применяется автоматически через `pnpm.patchedDependencies`
в package.json при каждой установке.
Моя прежняя формулировка «механика Head.astro» — вторая половина той же
заплатки (preload/отложенные стили). Обе половины остаются, курс не меняем.

## 015 · Новые запреты (входят в И4 и в журнал)
- Папку `patches/` НЕ трогать никогда.
- В package.json секция `pnpm` (patchedDependencies + onlyBuiltDependencies)
  НЕПРИКОСНОВЕННА: И4 меняет ТОЛЬКО version и repository.
- Проверил текущий package.json в ветке: repository всё ещё чужой
  (radishzzz/astro-theme-retypeset) — И4 действительно нужен.

Уточнённая фраза И4 (подайте её первой по возвращении):
> И4: Правки без сборки: в src/config.ts значения googleAnalyticsID: ''
> и twitterID: ''; в package.json version вернуть на 1.0.0 и repository
> поставить "repository": "https://github.com/annachurasheva/astro-blog".
> Секцию "pnpm" и папку patches/ НЕ трогать. Больше ничего не трогать.
> Ответь OK.

Дальше по карте возврата (ответ 013): И5 → процедура 010 → raw → деплой →
приёмка → ТОЧКА СТОП. Хорошей паузы. Журнал держу.
```