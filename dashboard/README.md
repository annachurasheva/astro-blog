# Дашборд astro-blog

## Соглашения (ревизия f308ee0)

- Развивается **только на npm**: `package-lock.json` — источник истины.
- `pnpm-lock.yaml` здесь **не создаём** (блог живёт на pnpm 10.33.0).
- Node для обеих частей — **24.5.0** (`.nvmrc` в корне репо и здесь).
- `package-lock.json` собран на Node 24.5.0 / npm 11.x.

## Запуск

```pwsh
cd dashboard
npm install        # не pnpm!
npm run dev        # http://localhost:5180
npm run build
```

## Состав бандла (регламент экспорта)

- `src/main.tsx`, `tsconfig.json`, `vite.config.ts` — обязательный минимум
- `package.json` с `"engines": { "node": ">=22" }`
- `index.html`, `src/App.tsx` — заглушка под метрики блога
