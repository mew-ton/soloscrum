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
			// Concept and Policies sections were added in #47. Commands and
			// Onboarding sections were added in #48. Every section relies on
			// Starlight's `autogenerate` so adding a new page only requires
			// dropping a Markdown file with `sidebar.order` frontmatter in the
			// matching directory of each locale. Order: Onboarding (newcomer
			// entry) → Concept (the why) → Policies (rules) → Commands (how-to).
			sidebar: [
				{
					label: 'Onboarding',
					items: [{ autogenerate: { directory: 'onboarding' } }],
				},
				{
					label: 'Concept',
					items: [{ autogenerate: { directory: 'concept' } }],
				},
				{
					label: 'Policies',
					items: [{ autogenerate: { directory: 'policies' } }],
				},
				{
					label: 'Commands',
					items: [{ autogenerate: { directory: 'commands' } }],
				},
			],
		}),
	],
});
