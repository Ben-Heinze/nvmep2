# Custom snippets

All custom LuaSnip snippets are defined in `luasnip.lua`. This is a manually
maintained reference — update it whenever a snippet is added, removed, or
its trigger/condition changes.

External community snippets (`friendly-snippets`) are also loaded for every
filetype except `tex`, via `from_vscode`/`from_snipmate` `lazy_load()` at the
bottom of `luasnip.lua`. They aren't listed here since they aren't custom.
`tex` is excluded from that blanket load because friendly-snippets' tex
autosnippets expand unconditionally (e.g. `.` -> `\dots`, even outside math
mode) — our own gated replacements are below instead.

## all (every filetype)

| Trigger | Type | Expansion |
| --- | --- | --- |
| `envrc` | snippet | direnv boilerplate for a Nix flake-backed `.envrc` |

## lua

| Trigger | Type | Expansion |
| --- | --- | --- |
| `new-module` | snippet | `local M = {} ... return M` module skeleton |
| `lowercase-global` | snippet | `---@diagnostic disable-next-line: lowercase-global` |
| `unused-local` | snippet | `---@diagnostic disable-next-line: unused-local` |

## java

| Trigger | Type | Expansion |
| --- | --- | --- |
| `fn` | snippet | Full method skeleton (visibility/type/name/params/throws choices) with an auto-generated Javadoc block above it |

## tex

| Trigger | Type | Condition | Expansion |
| --- | --- | --- | --- |
| `ls` | snippet | — | `\begin{itemize} \item ...` with recursive `\item` expansion (Tab through as many items as needed) |
| `.` | autosnippet | `in_mathzone()` — cursor must be inside a `texMathZone*` syntax region | `\dots` |

`in_mathzone()` (defined just above the `tex` snippets in `luasnip.lua`)
checks the buffer's tex syntax stack at the cursor. Gate any future
math-only autosnippet the same way; ungated autosnippets fire everywhere,
which is what caused the original `.` -> `\dots` annoyance.

## tex — TikZ graphs (`snippets_tikz.lua`)

Registered for `tex`, so via `filetype_extend('org', { 'tex' })` they also
expand in `.org` buffers (org exports the `\begin{tikzpicture}` block verbatim).
These are **regular** snippets (Tab / `<C-n>`), not `in_mathzone`-gated
autosnippets. Layout is automatic via the pgf `graphdrawing` engine, which is
why the org exporter runs LuaLaTeX (see `scripts/org-pdf-export.el`).

| Trigger | Type | Expansion |
| --- | --- | --- |
| `graph` | snippet | Full `tikzpicture` + `\graph{…}` scaffold, two stacked `name / value` nodes; first field is a layout choice node (`spring` / `layered` / `tree layout`) |
| `gex` | snippet | Ready-made worked example: a 3-node weighted directed graph, fully filled in so it renders as-is (edit afterwards) |
| `gnode` | snippet | One node for inside a `\graph{…}`: `id [as={name \\ value}]` |
| `gedge` | snippet | Edge `a <dir> b;` — direction choice node (`--` / `->` / `<->`) |
| `gwedge` | snippet | Weighted/labelled edge `a <dir>["w"] b;` (via the `quotes` library) |

## org — math openers (`snippets_org.lua`)

Regular snippets (Tab / `<C-n>`), org-only. Deliberately **not** autosnippets, so
typing the words "equation"/"eqref" in prose never expands them.

| Trigger | Type | Expansion |
| --- | --- | --- |
| `mm` | snippet | Inline `$…$` |
| `dm` | snippet | `\(…\)` opener on its own line (renders in-editor; exports inline/uncentered) |
| `cm` | snippet | `\[…\]` opener on its own line (renders in-editor; exports centered display) |
| `eqn` | snippet | `\begin{equation}\label{eq:…} … \end{equation}` — a **numbered** display equation with a label to cite |
| `eqref` | snippet | `\(\eqref{eq:…}\)` — reference an `eqn` label, renders as linked "(1)" |

Cross-references resolve in the **PDF** out of the box (amsmath `\eqref`; `\label`
numbers the line). On the **HTML site** they resolve only when
`org-html-mathjax-options` sets `tags: ams` in `yappopotamus/publish.el` (default is
`none` = unnumbered). `eqref` is wrapped in `\(…\)` on purpose: MathJax only
processes math inside its delimiters, so a bare `\eqref` in prose would print
literally. Org internal links `[[eq:name]]` do **not** work — org cannot resolve a
link to a raw `\label`.

## cpp

| Trigger | Type | Expansion |
| --- | --- | --- |
| `ponce` | snippet | `#pragma once` |
| `javatocpp` | snippet | Prompt template: "convert the java code above to C++..." |
| `charmassumptions` | snippet | Prompt template: charm project coding assumptions/requirements |
| `charmentity` | snippet | `#include <charm/aiestate/cem/entity/entity.hpp>` |
| `charmxml` | snippet | `#include <charm/xml/xml.hpp>` |
| `iostream` | snippet | `#include <iostream>` |
| `memory` | snippet | `#include <memory>` |
| `helloworld` | snippet | Full hello-world `main()` |

## nix

| Trigger | Type | Expansion |
| --- | --- | --- |
| `module` | snippet | NixOS module skeleton (`imports`/`options`/`config`) |
| `basic-shell` | snippet | Minimal `mkShell` derivation |
| `basic-flake` | snippet | Minimal flake with `flake-utils.eachDefaultSystem` devShell |
