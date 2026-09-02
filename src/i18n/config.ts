// Global Language Map
export const langMap = {
  'ru': ['ru-RU'],
} as const

// Supported Languages
export type Language = keyof typeof langMap

// Giscus Language Map
// https://giscus.app/
export const giscusLocaleMap: Record<Language, string> = {
  'ru': 'ru',
}

// Twikoo Language Map
// https://github.com/twikoojs/twikoo/blob/main/src/client/utils/i18n/index.js
export const twikooLocaleMap: Record<Language, string> = {
  'ru': 'en', // fallback to English
}

// Waline Language Map
// https://waline.js.org/en/guide/features/i18n.html
export const walineLocaleMap: Record<Language, string> = {
  'ru': 'ru-RU',
}
