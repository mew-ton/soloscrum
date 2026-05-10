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
			// Sidebar sections (Concept / Reference / Commands / Onboarding) will be
			// added in #47 / #48 alongside the actual content. Until then, the site
			// only renders the hand-written stub index page.
			sidebar: [],
		}),
	],
});
