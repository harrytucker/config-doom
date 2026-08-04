;; -*- no-byte-compile: t; -*-
;;; .doom.d/packages.el

;; Testing - BDD support
(package! feature-mode)

;; Python - docstring editing and syntax highlighting
(package! python-docstring)

;; Protobuf/gRPC - .proto file support
(package! protobuf-mode)

;; Caddy - Caddyfile syntax support
(package! caddyfile-mode)

;; Org Mode extensions
(unpin! org-roam)      ; use latest org-roam
(package! org-roam-ui) ; graph visualization web UI
(package! engrave-faces) ; better syntax highlighting in LaTeX exports

;; PostgreSQL - database browser and client library
(package! pg :recipe (:host github :repo "emarsden/pg-el"))
(package! pgmacs :recipe (:host github :repo "emarsden/pgmacs"))

;; Mise - tool version manager integration
(package! mise)

;; Utilities
(package! command-log-mode) ; display keystrokes in a buffer
(package! prism)            ; scope-based syntax highlighting
(package! flyover)          ; modern flycheck display
(package! eat)              ; terminal emulator for eshell
