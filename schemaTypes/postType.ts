import {defineField, defineType} from 'sanity'

export const postType = defineType({
  name: 'post',
  title: 'Post',
  type: 'document',
  fields: [
    defineField({
      name: 'title',
      type: 'string',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'slug',
      type: 'slug',
      options: {source: 'title'},
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'category',
      title: 'Categoría',
      type: 'string',
      options: {
        list: [
          { title: 'IA aplicada', value: 'ia-aplicada' },
          { title: 'Casos de negocio', value: 'casos-de-negocio' },
          { title: 'Tendencias', value: 'tendencias' },
          { title: 'Human + Machine', value: 'human-machine' },
          { title: 'News', value: 'news' },
          { title: 'Opinion', value: 'opinion' }
        ]
      },
      validation: (rule) => rule.required()
    }),
    defineField({
      name: 'publishedAt',
      type: 'datetime',
      initialValue: () => new Date().toISOString(),
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'image',
      type: 'image',
    }),
    defineField({
      name: 'body',
      type: 'array',
      of: [{type: 'block'}],
      
    }),
  ],
})