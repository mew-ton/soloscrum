// @ts-check
import { visit } from 'unist-util-visit';

/**
 * Remark plugin that prefixes absolute (`/`-leading) Markdown link and image
 * URLs with Astro's `base` value (e.g. `/soloscrum/`).
 *
 * Why this is needed: Astro and Starlight do **not** auto-rewrite `/`-leading
 * hrefs that originate inside Markdown content. Starlight's own link helper
 * (`createPathFormatter` → `pathWithBase`) is used by the sidebar, header, and
 * other framework chrome — but body content goes through standard
 * remark/rehype, which emits `<a href="/concept/foo/">` verbatim. On a site
 * served from a subpath (`base: '/soloscrum/'`) this resolves to the wrong
 * host path (`https://host/concept/foo/` instead of
 * `https://host/soloscrum/concept/foo/`).
 *
 * Locale prefixing is **not** handled here. Under Starlight's canonical "root
 * locale" form (English at the content root, other locales at `/{lang}/`),
 * authors write the locale segment directly: English content uses
 * `[x](/concept/foo/)`; Japanese content uses `[x](/ja/concept/foo/)`. The
 * plugin only prepends `base`.
 *
 * Protocol-relative URLs (`//example.com/...`), already-prefixed URLs, and
 * external URLs (`http://`, `https://`, `mailto:`, etc.) are skipped.
 *
 * @param {{ base: string }} options
 *   - `base`: the Astro `base` value (typically with a trailing slash, e.g.
 *     `/soloscrum/`).
 */
export function remarkBaseUrl({ base }) {
	// Strip any trailing slash so we can concatenate with `node.url` (which
	// already starts with `/`) without producing a double slash.
	const basePrefix = base.replace(/\/$/, '');
	const basePrefixWithSlash = basePrefix + '/';

	return (/** @type {import('mdast').Root} */ tree) => {
		visit(tree, ['link', 'image'], (/** @type {any} */ node) => {
			const url = node.url;
			if (typeof url !== 'string') return;
			// Only rewrite single-slash absolute paths; skip protocol-relative
			// (`//host/...`) and external URLs.
			if (!url.startsWith('/') || url.startsWith('//')) return;
			// Idempotent: skip URLs that already start with the base prefix.
			if (url === basePrefix || url.startsWith(basePrefixWithSlash)) return;

			node.url = basePrefix + url;
		});
	};
}
