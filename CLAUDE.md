# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a literate [Doom Emacs](https://github.com/doomemacs/doomemacs) configuration. Nearly all configuration is written as Org-mode prose with embedded `elisp` source blocks, not as raw `.el` files. `init.el`, `config.el`, and `packages.el` are (mostly) Doom-required entry points that exist only to bootstrap loading of the literate `.org` files — do not add configuration directly to them except where noted below.

## Architecture

- `config.org` is the root: sets `user-full-name`/`user-mail-address`, then calls `org-babel-load-file` on each file in `modules/*.org` in a fixed order, then tangles `packages.el` from its own `:tangle packages.el` source block.
- `modules/*.org` — one file per concern (`ui`, `editor`, `shell`, `programming`, `writing`, `tools`, `workarounds`). Each file's elisp blocks are loaded directly via `org-babel-load-file` at startup, which tangles a matching `modules/<name>.el` as a side effect. These tangled `.el` files are deliberately committed (see "Editing workflow" below) — the `.org` file is still the source of truth, so never hand-edit the `.el` file directly.
- `packages.el` is tangled from the `#+begin_src elisp :tangle packages.el` block near the end of `config.org` — edit that block in `config.org`, not `packages.el` directly (it gets regenerated).
- `init.el` holds Doom's `doom!` module-selection block (which Doom modules/languages are enabled) and is edited directly (it is not tangled from org).
- `config.el` is a legacy/duplicate entry point mirroring the module-loading calls in `config.org`; check both if changing how modules load.
- `html/` holds assets for the Org HTML export theme: `org-export.css`/`org-export.js` (the visual theme, inlined into exported pages) and `export-settings.el` (the `org-html-*` variable configuration itself). `export-settings.el` is plain elisp (`with-eval-after-load`, not Doom's `after!`) so it loads both from `modules/writing.org` inside Doom and from `.github/scripts/publish.el` in a bare `emacs --batch` CI run — mirrors how `latex/` holds `mimore.cls` for LaTeX export.
- `modules/workarounds.org` isolates MacOS-only fixes, guarded with `(featurep :system 'macos)` — keep platform-specific hacks there rather than scattering `when`/`featurep` checks across other modules.
- `index.org` is the GitHub Pages site landing page (not part of the Doom config load path) — link to any new module or top-level `.org` page from here and from `config.org`'s module table to keep the published site navigable.
- `.github/workflows/gh-pages.yml` + `.github/scripts/publish.el` build and deploy the published site (`config.org`, `index.org`, `modules/*.org`) to GitHub Pages on every push to `main` via `org-publish-project-alist`. This is a separate concern from the Doom config itself — it doesn't affect how Emacs loads, only how the `.org` files get exported to a static site.

## Editing workflow

Since the source of truth is Org prose + embedded code blocks, not `.el` files:

- Edit the relevant `#+begin_src elisp` block inside the appropriate `modules/*.org` file (or `config.org` for the packages block).
- Prose above each block should stay in sync with what the code does — these files are meant to read as documentation, so update the surrounding explanation when behavior changes.
- Also update `config.org`'s module summary table when a module's scope changes (e.g. sections added/removed) — it's easy to let it drift.
- After editing a module's `.org` file, regenerate its committed `modules/<name>.el` so the tracked tangle output stays in sync. Run this from inside `modules/` (the tangle target is resolved relative to the current directory, so running it from the repo root produces `modules/modules/<name>.el` and fails):
  ```
  cd modules && emacs --batch -l org --eval '(org-babel-tangle-file "<name>.org" "<name>.el" "elisp")'
  ```
- There is no separate build/lint/test command outside of Emacs itself; validate changes by loading the config in Doom Emacs (`doom sync` after changing `init.el`/`packages.el`, then restart Emacs or `M-x doom/reload`).
- After changing `init.el` (the `doom!` block) or `packages.el`, run `doom sync` to install/remove packages and modules.

## Style conventions in this repo

- Module `.org` files start with `#+title: <Name> Configuration` followed by `*`-level sections, each with a short prose explanation before its `elisp` source block.
- Keep unrelated concerns in their designated module file rather than adding ad-hoc top-level sections to `config.org`.
