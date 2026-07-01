Neovim configuration managed as a Nix flake.

**Quickstart**

- Run the packaged Neovim: `nix run .`
- Enter the dev shell (Lua/Nix tooling + `nvim-dev`): `nix develop`
- Run checks (format/lint/smoke): `nix flake check -L`
- Format Nix (flake `formatter`): `nix fmt`

**What gets checked**

- `stylua --check` on the Lua config
- `luacheck` on the Lua config (see `.luacheckrc`)
- Headless startup smoke test: `${package}/bin/nvim --headless +quitall`
**Dev shell behavior**

- Symlinks a generated `.luarc.json` into the repo root for `lua-language-server`.
- Symlinks the repo `./nvim` into `~/.config/nvim-dev` so you can iterate without rebuilding.

**Outputs**

- `packages.<system>.nvim`: the wrapped Neovim build.
- `devShells.<system>.default`: development environment for this repo.
