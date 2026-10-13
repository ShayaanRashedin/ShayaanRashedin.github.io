# Portfolio redesign — review and recovery

This redesign is isolated on `codex/portfolio-redesign`. The original GitHub Pages site on `main` has not been replaced.

## Original version

- Backup branch: `backup/portfolio-before-redesign-2026-10-13`
- Original commit: `ed908a3a598588e70701e3947743344e10d419a4`

Before merging, rejecting the redesign simply means closing its pull request. Nothing needs to be restored on the live site. If the redesign is merged later, revert its merge or squash commit with a new pull request; this preserves history and subsequent changes. The backup branch retains the exact original website.

## Preview

Open `index.html` from a downloaded and extracted copy. The site uses relative links and requires no build or package installation. The PDF resume remains available as a direct download if the browser does not support inline PDF display.

For a local HTTP preview, serve this directory with any static web server. No server-side application is required.

## Content and visual provenance

- Architecture illustrations are based on the SyncWire, NetWatch, and EEBOT repository READMEs reviewed on October 13, 2026.
- EEBOT is explicitly credited as a shared course project. The navigation explainer is conceptual, not a simulation or recorded hardware demonstration.
- `assets/demos/netwatch/` is an adapted static copy of the actual NetWatch dashboard HTML/CSS. It has no live API, synthetic telemetry, polling, or inactive dashboard controls. A visible banner labels its status.
- Existing lab evidence, image assets, and resume PDF are retained.

## Validation

All 10 HTML pages and 153 local references were checked for missing files and anchor targets; duplicate IDs were checked. Both JavaScript files passed syntax validation. Browser visual and interaction QA could not be completed because the local preview connections were blocked by this execution environment. Desktop, mobile, theme, and keyboard behaviour should be checked in a normal browser before merging.
