Neovim configuration managed as a Nix flake.

**Quickstart**

- Run the packaged Neovim: `nix run .`
- Enter the devshell (Lua/Nix tooling + `nvim-dev`): `nix develop`
- Run checks (format/lint/smoke): `nix flake check -L`
- Format Nix (flake `formatter`): `nix fmt`

**What gets checked**

- `stylua --check` on the Lua config
- `luacheck` on the Lua config (see `.luacheckrc`)
- Headless startup smoke test: `${package}/bin/nvim --headless +quitall`


