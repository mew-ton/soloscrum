// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import { remarkBaseUrl } from './src/lib/remark-base-url.mjs';

const BASE = '/soloscrum/';

// https://astro.build/config
export default defineConfig({
	// Public canonical URL for the deployed site. The docs are published to
	// GitHub Pages at https://mew-ton.github.io/soloscrum/ via the
	// `.github/workflows/docs.yml` workflow. `site` is required for sitemap
	// generation (without it Astro emits a build warning) and `base` makes
	// internal links resolve correctly when served from the `/soloscrum/`
	// subpath.
	site: 'https://mew-ton.github.io/soloscrum/',
	base: BASE,
	markdown: {
		// Astro and Starlight do not auto-prefix `/`-leading hrefs that
		// originate inside Markdown body content with the configured `base`
		// value. Starlight's `createPathFormatter` covers framework chrome
		// (sidebar, header, breadcrumbs) but body content emits as authored.
		// Without this plugin a link `[x](/concept/foo/)` resolves on Pages
		// to `https://host/concept/foo/` instead of
		// `https://host/soloscrum/concept/foo/`.
		//
		// Locale prefixing is author-managed under the canonical root-locale
		// form: English content uses absolute slugs without a locale segment
		// (`/concept/foo/`); Japanese content uses absolute slugs with the
		// `/ja/` segment already in place (`/ja/concept/foo/`). The plugin
		// only prepends `base`.
		remarkPlugins: [[remarkBaseUrl, { base: BASE }]],
	},
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
			// i18n uses Starlight's canonical "root locale" form: English
			// content lives at the content root (no `/en/` prefix in URLs) and
			// Japanese content lives under `/ja/`. With this layout, English
			// absolute slugs (`/concept/foo/`) resolve directly under `base`,
			// and Japanese absolute slugs are authored with the `/ja/` prefix
			// already (`/ja/concept/foo/`). This matches Starlight's own docs
			// site convention.
			locales: {
				root: { label: 'English', lang: 'en' },
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
