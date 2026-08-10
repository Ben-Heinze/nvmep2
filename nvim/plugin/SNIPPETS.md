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
