# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a literate [Doom Emacs](https://github.com/doomemacs/doomemacs) configuration. Nearly all configuration is written as Org-mode prose with embedded `elisp` source blocks, not as raw `.el` files. `init.el`, `config.el`, and `packages.el` are (mostly) Doom-required entry points that exist only to bootstrap loading of the literate `.org` files — do not add configuration directly to them except where noted below.

## Architecture

- `config.org` is the root: sets `user-full-name`/`user-mail-address`, then calls `org-babel-load-file` on each file in `modules/*.org` in a fixed order, then tangles `packages.el` from its own `:tangle packages.el` source block.
- `modules/*.org` — one file per concern (`ui`, `editor`, `shell`, `programming`, `writing`, `tools`, `workarounds`). Each file's elisp blocks are loaded directly via `org-babel-load-file` at startup — there are **no** committed `.el` counterparts for these; do not create `modules/*.el` files.
- `packages.el` is tangled from the `#+begin_src elisp :tangle packages.el` block near the end of `config.org` — edit that block in `config.org`, not `packages.el` directly (it gets regenerated).
- `init.el` holds Doom's `doom!` module-selection block (which Doom modules/languages are enabled) and is edited directly (it is not tangled from org).
- `config.el` is a legacy/duplicate entry point mirroring the module-loading calls in `config.org`; check both if changing how modules load.
- `html/` holds assets for the Org HTML export theme (`org-export.css`), referenced from `modules/writing.org` via `doom-user-dir` — mirrors how `latex/` holds `mimore.cls` for LaTeX export.
- `modules/workarounds.org` isolates MacOS-only fixes, guarded with `(featurep :system 'macos)` — keep platform-specific hacks there rather than scattering `when`/`featurep` checks across other modules.

## Editing workflow

Since the source of truth is Org prose + embedded code blocks, not `.el` files:

- Edit the relevant `#+begin_src elisp` block inside the appropriate `modules/*.org` file (or `config.org` for the packages block).
- Prose above each block should stay in sync with what the code does — these files are meant to read as documentation, so update the surrounding explanation when behavior changes.
- To tangle a single module to a real `.el` file for inspection/syntax-checking (does not happen automatically outside Emacs loading it):
  ```
  emacs --batch -l org --eval '(org-babel-tangle-file "modules/<name>.org" "modules/<name>.el" "elisp")'
  ```
- There is no separate build/lint/test command outside of Emacs itself; validate changes by loading the config in Doom Emacs (`doom sync` after changing `init.el`/`packages.el`, then restart Emacs or `M-x doom/reload`).
- After changing `init.el` (the `doom!` block) or `packages.el`, run `doom sync` to install/remove packages and modules.

## Style conventions in this repo

- Module `.org` files start with `#+title: <Name> Configuration` followed by `*`-level sections, each with a short prose explanation before its `elisp` source block.
- Keep unrelated concerns in their designated module file rather than adding ad-hoc top-level sections to `config.org`.
