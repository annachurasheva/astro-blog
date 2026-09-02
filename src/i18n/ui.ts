import type { Language } from '@/i18n/config'

interface Translation {
  title: string
  subtitle: string
  description: string
  posts: string
  tags: string
  about: string
  toc: string
}

export const ui: Record<Language, Translation> = {
  'ru': {
    title: 'Мемориал Корпечь, Крым',
    subtitle: 'Восстановление связей: боец → документ → потомок',
    description: 'Мемориал Корпечь — восстановление связей: боец → документ → потомок. Цифровая память о погибших воинах.',
    posts: 'Посты',
    tags: 'Теги',
    about: 'О проекте',
    toc: 'Оглавление',
  },
}
