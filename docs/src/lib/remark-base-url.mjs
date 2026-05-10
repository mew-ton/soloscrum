// @ts-check
import { visit } from 'unist-util-visit';

/**
 * Remark plugin that rewrites absolute (`/`-leading) Markdown link and image
 * URLs so they resolve correctly under Astro's `base` and Starlight's i18n
 * locale routing.
 *
 * Two rewrites are applied (in order):
 *
 * 1. **Locale prefix** — when the URL points at a content path that does not
 *    already start with a locale segment (`/en/...`, `/ja/...`), the locale
 *    of the *source* Markdown file is prepended. This lets authors write
 *    cross-page links as `[x](/concept/foo/)` and have them resolve to the
 *    matching `/{locale}/concept/foo/` target. Asset paths (`/_astro/...`,
 *    `/favicon.svg`, etc.) are left alone — they are not locale-scoped.
 *
 * 2. **Base prefix** — every absolute URL is then prefixed with the Astro
 *    `base` value (e.g. `/soloscrum/`). Astro/Starlight do not auto-rewrite
 *    `/`-leading hrefs that originate in Markdown content, so without this
 *    step a link emits as `<a href="/concept/foo/">` and on Pages resolves
 *    to `https://mew-ton.github.io/concept/foo/` — the wrong host path.
 *
 * Protocol-relative URLs (`//example.com/...`), already-prefixed URLs, and
 * external URLs (`http://`, `https://`, `mailto:`, etc.) are skipped.
 *
 * @param {{ base: string, locales: string[], contentRoot?: string }} options
 *   - `base`: the Astro `base` value (typically with a trailing slash, e.g.
 *     `/soloscrum/`).
 *   - `locales`: the set of i18n locale codes Starlight emits (e.g.
 *     `['en', 'ja']`). Used both to detect the source file's locale from its
 *     path and to skip URLs that already start with a locale segment.
 *   - `contentRoot`: the directory under which locale-scoped content lives,
 *     relative to the project root. Defaults to `src/content/docs/`. Only
 *     files under this root receive the locale-prefix rewrite; files
 *     elsewhere (rare — e.g. project-root README) get only the base prefix.
 */
export function remarkBaseUrl({ base, locales, contentRoot = 'src/content/docs/' }) {
	// Strip any trailing slash so we can concatenate with `node.url` (which
	// already starts with `/`) without producing a double slash.
	const basePrefix = base.replace(/\/$/, '');
	const basePrefixWithSlash = basePrefix + '/';
	const localeSet = new Set(locales);

	return (
		/** @type {import('mdast').Root} */ tree,
		/** @type {import('vfile').VFile} */ file,
	) => {
		// Detect the source file's locale by looking for the segment that
		// follows `contentRoot` in the file's path. Falls back to `null` for
		// files outside the locale-scoped content root.
		const filePath = file && typeof file.path === 'string' ? file.path : '';
		const idx = filePath.indexOf(contentRoot);
		let sourceLocale = null;
		if (idx !== -1) {
			const after = filePath.slice(idx + contentRoot.length);
			const firstSegment = after.split('/', 1)[0];
			if (firstSegment && localeSet.has(firstSegment)) {
				sourceLocale = firstSegment;
			}
		}

		visit(tree, ['link', 'image'], (/** @type {any} */ node) => {
			const url = node.url;
			if (typeof url !== 'string') return;
			// Only rewrite single-slash absolute paths; skip protocol-relative
			// (`//host/...`) and external URLs.
			if (!url.startsWith('/') || url.startsWith('//')) return;
			// Idempotent: skip URLs that already start with the base prefix.
			if (url === basePrefix || url.startsWith(basePrefixWithSlash)) return;

			// Step 1: locale prefix. Skip when the URL already starts with a
			// known locale segment (`/en/...`, `/ja/...`) or when the URL
			// targets a non-content asset (paths starting with `_` are
			// Astro/Starlight build artefacts; these are not locale-scoped).
			let rewritten = url;
			const firstUrlSegment = url.split('/', 2)[1] ?? '';
			const isLocalePrefixed = localeSet.has(firstUrlSegment);
			const isAsset =
				firstUrlSegment === '' ||
				firstUrlSegment.startsWith('_') ||
				firstUrlSegment.includes('.');
			if (sourceLocale && !isLocalePrefixed && !isAsset) {
				rewritten = '/' + sourceLocale + url;
			}

			// Step 2: base prefix.
			node.url = basePrefix + rewritten;
		});
	};
}
