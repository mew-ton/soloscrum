// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	// Public canonical URL for the deployed site. The docs are published to
	// GitHub Pages at https://mew-ton.github.io/soloscrum/ via the
	// `.github/workflows/docs.yml` workflow. `site` is required for sitemap
	// generation (without it Astro emits a build warning) and `base` makes
	// internal links resolve correctly when served from the `/soloscrum/`
	// subpath.
	site: 'https://mew-ton.github.io/soloscrum/',
	base: '/soloscrum/',
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
					label: 'Policies',
					items: [{ autogenerate: { directory: 'policies' } }],
				},
			],
		}),
	],
});
