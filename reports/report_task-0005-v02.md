## Критерий приёмки (для заказчика)
- В коде сайта слово apiflash отсутствует полностью.
- В <head> каждой страницы тег og:image указывает на ваш домен.
- `npm run build` завершается успешно.

```diff
--- a/src/layouts/Head.astro
+++ b/src/layouts/Head.astro
@@ -13,7 +13,6 @@
 // Props and Language
 const { postTitle, postDescription, postSlug } = Astro.props
 const { currentLang } = getPageInfo(Astro.url.pathname)
 const currentUI = ui[currentLang as keyof typeof ui] ?? {}
-const lang = currentLang === defaultLocale ? '' : `${currentLang}/`
 
 // Site Configuration
@@ -20,7 +19,7 @@
 const { title, subtitle, description, i18nTitle, author, favicon } = themeConfig.site
 const { mode: defaultMode, light: { background: lightMode }, dark: { background: darkMode } } = themeConfig.color
 const { katex: katexEnabled, reduceMotion } = themeConfig.global
-const { verification = {}, twitterID = '', googleAnalyticsID = '', umamiAnalyticsID = '', apiflashKey = '' } = themeConfig.seo ?? {}
+const { verification = {}, twitterID = '', googleAnalyticsID = '', umamiAnalyticsID = '' } = themeConfig.seo ?? {}
 const { google = '', bing = '', yandex = '', baidu = '' } = verification
 const { customGoogleAnalyticsJS = '', customUmamiAnalyticsJS = '' } = themeConfig.preload ?? {}
 
@@ -31,10 +30,8 @@
 const siteDescription = i18nTitle ? currentUI.description : description
 
 // Page Metadata
 const pageTitle = postTitle ? `${postTitle} | ${siteTitle}` : `${siteTitle} - ${siteSubtitle}`
 const pageDescription = postDescription || siteDescription
-const pageImage = postSlug
-  ? new URL(`${base}/og/${postSlug}.png`, Astro.url.origin)
-  : apiflashKey
-    ? `https://api.apiflash.com/v1/urltoimage?access_key=${apiflashKey}&url=${Astro.url}&format=png&width=1500&height=788&ttl=259200&wait_until=network_idle&no_tracking=true`
-    : `https://api.apiflash.com/v1/urltoimage?access_key=02a837b6188f4ba0a7fd9fbeff03a83e&url=https://retypeset.radishzz.cc/${lang}&format=png&width=1500&height=788&ttl=604800&wait_until=network_idle&no_tracking=true`
+// TASK-0005: OG-превью генерируются ЛОКАЛЬНЫМ генератором проекта src/pages/og/[...image].ts.
+// Внешний сервис Apiflash и чужой ключ удалены полностью. Для не-постов используется /og/home.png.
+const pageImage = new URL(`${base}/og/${postSlug ?? 'home'}.png`, Astro.url.origin)
 
--- a/src/layouts/Head.astro
+++ b/src/layouts/Head.astro
```
===
```
--- a/src/pages/og/[...image].ts
+++ b/src/pages/og/[...image].ts
@@ -1,7 +1,8 @@
 import type { CollectionEntry } from 'astro:content'
 import { OGImageRoute } from 'astro-og-canvas'
 import { getCollection } from 'astro:content'
+import { themeConfig } from '@/config'
 import { getPostDescription } from '@/utils/description'
 
 // eslint-disable-next-line antfu/no-top-level-await
 const posts = await getCollection('posts')
@@ -9,10 +10,18 @@
 // Create slug-to-metadata lookup object for blog posts
-const pages = Object.fromEntries(
-  posts.map((post: CollectionEntry<'posts'>) => [
-    post.id,
-    {
-      title: post.data.title,
-      description: getPostDescription(post, 'og'),
-    },
-  ]),
-)
+// TASK-0005: добавлена страница 'home', чтобы главная (и любые не-посты) получали
+// превью из локального генератора вместо скриншота внешнего сервиса Apiflash.
+const pages = {
+  home: {
+    title: themeConfig.site.title,
+    description: themeConfig.site.description,
+  },
+  ...Object.fromEntries(
+    posts.map((post: CollectionEntry<'posts'>) => [
+      post.id,
+      {
+        title: post.data.title,
+        description: getPostDescription(post, 'og'),
+      },
+    ]),
+  ),
+}
 
 // Configure Open Graph image generation route
 ```