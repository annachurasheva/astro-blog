PS C:\astro-blog> git branch
  main
* main-qwen3-coder-plus-v01
PS C:\astro-blog> corepack enable && corepack prepare pnpm@10.33.0 --activate && pnpm install --frozen-lockfile
Preparing pnpm@10.33.0 for immediate activation...
Lockfile is up to date, resolution step is skipped
Packages: +896
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   ╭───────────────────────────────────────────────╮
   │                                               │
   │     Update available! 10.33.0 → 11.25.0.      │
   │     Changelog: https://pnpm.io/v/11.25.0      │
   │   To update, run: corepack use pnpm@11.25.0   │
   │                                               │
   ╰───────────────────────────────────────────────╯

Progress: resolved 896, reused 896, downloaded 0, added 896, done

dependencies:
+ @astrojs/mdx 5.0.3
+ @astrojs/partytown 2.1.6
+ @astrojs/sitemap 3.7.2
+ @waline/client 3.13.0
+ astro 6.1.5
+ astro-compress 2.4.1
+ astro-og-canvas 0.11.0
+ canvaskit-wasm 0.41.1
+ feed 5.2.0
+ katex 0.16.45
+ lite-youtube-embed 0.3.4
+ markdown-it 14.1.1
+ mdast-util-to-string 4.0.0
+ mermaid 11.14.0
+ node-html-parser 7.1.0
+ reading-time 1.5.0
+ rehype-katex 7.0.1
+ rehype-mermaid 3.0.0
+ rehype-slug 6.0.0
+ remark-directive 4.0.0
+ remark-math 6.0.0
+ sanitize-html 2.17.2
+ sharp 0.34.5
+ twikoo 1.7.7
+ unist-util-visit 5.1.0

devDependencies:
+ @antfu/eslint-config 8.1.1
+ @astrojs/check 0.9.8
+ @types/markdown-it 14.1.2
+ @types/node 25.6.0
+ @types/sanitize-html 2.16.1
+ @unocss/astro 66.6.8
+ @unocss/eslint-plugin 66.6.8
+ @unocss/preset-attributify 66.6.8
+ @unocss/reset 66.6.8
+ astro-eslint-parser 1.4.0
+ autocorrect-node 2.14.0
+ eslint 10.2.0
+ eslint-plugin-astro 1.7.0
+ fast-glob 3.3.3
+ lint-staged 16.4.0
+ playwright 1.59.1
+ simple-git-hooks 2.13.1
+ tsx 4.21.0
+ typescript 6.0.2
+ unocss 66.6.8
+ unocss-preset-theme 0.14.1

Done in 29.8s using pnpm v10.33.0
PS C:\astro-blog> pnpm dev

> astro-theme-retypeset@1.0.0 dev C:\astro-blog
> astro check && astro dev

23:47:30 [content] Syncing content
23:47:38 [content] Synced content
23:47:38 [types] Generated 10.71s
23:47:38 [check] Getting diagnostics for Astro files in C:\astro-blog...
Result (59 files):
- 0 errors
- 0 warnings
- 0 hints

[vite] connected.
23:48:10 [types] Generated 2ms
(node:1752) MaxListenersExceededWarning: Possible EventEmitter memory leak detected. 11 change listeners added to [FSWatcher]. MaxListeners is 10. Use emitter.setMaxListeners() to increase limit
(Use `node --trace-warnings ...` to show where the warning was created)
[vite] connected.
23:48:11 [content] Syncing content

 update  ▶ New version of Astro available: 7.3.1
  Run pnpm dlx @astrojs/upgrade to update

23:48:19 [content] Synced content
23:48:20 [vite] Re-optimizing dependencies because vite config has changed
 astro  v6.1.5 ready in 15630 ms
┃ Local    http://localhost:4321/
┃ Network  use --host to expose
23:48:20 watching for file changes...
