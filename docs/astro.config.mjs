// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'soloscrum docs',
			social: [
				{
					icon: 'github',
					label: 'GitHub',
					href: 'https://github.com/mew-ton/soloscrum',
				},
			],
			// i18n was enabled in #47 (English default + Japanese). Each locale
			// has its own subtree under `src/content/docs/{en,ja}/`; Starlight
			// resolves the autogenerate `directory` per locale, so the sidebar
			// definition below stays unified across languages.
			defaultLocale: 'en',
			locales: {
				en: { label: 'English', lang: 'en' },
				ja: { label: '日本語', lang: 'ja' },
			},
			// Concept and Reference sections were added in #47. Commands and
			// Onboarding sections will be added in #48. Both existing sections
			// rely on Starlight's `autogenerate` so adding a new page only
			// requires dropping a Markdown file with `sidebar.order` frontmatter
			// in the matching directory of each locale.
			sidebar: [
				{
					label: 'Concept',
					items: [{ autogenerate: { directory: 'concept' } }],
				},
				{
					label: 'Reference',
					items: [{ autogenerate: { directory: 'reference' } }],
				},
			],
		}),
	],
});
