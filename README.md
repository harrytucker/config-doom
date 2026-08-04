# Harry's Doom Emacs Config

A literate [Doom Emacs](https://github.com/doomemacs/doomemacs) configuration.
The full config, including commentary, lives in [`config.org`](config.org),
which tangles into `init.el`/`config.el`/`packages.el` and loads a set of
modular literate files. It's also published as a browsable site at
[harrytucker.github.io/config-doom](https://harrytucker.github.io/config-doom/),
built by `.github/workflows/gh-pages.yml` on every push to `main`.

| Module                              | Purpose                                         |
|--------------------------------------|-------------------------------------------------|
| [`modules/ui.org`](modules/ui.org)             | Theme, fonts, modeline, and visual settings     |
| [`modules/editor.org`](modules/editor.org)         | Evil mode, projectile, and completion settings  |
| [`modules/shell.org`](modules/shell.org)          | Eshell and terminal emulator configuration      |
| [`modules/programming.org`](modules/programming.org)    | Language-specific settings (Go, Rust, Python)   |
| [`modules/writing.org`](modules/writing.org)        | Org mode, Org Roam, Markdown, and LaTeX export  |
| [`modules/tools.org`](modules/tools.org)          | Diff mode, mise, and other tooling integrations |
| [`modules/workarounds.org`](modules/workarounds.org)    | MacOS-specific fixes and quirks                 |

See [`config.org`](config.org) for the full write-up.
