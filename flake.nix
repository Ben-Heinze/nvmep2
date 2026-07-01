{
  description = "Neovim derivation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Separate nixpkgs pin for a small set of bleeding-edge plugins.
    nixpkgs-unstable-plugins.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";

    # Add bleeding-edge plugins here.
    # They can be updated with `nix flake update` (make sure to commit the generated flake.lock)
    # wf-nvim = {
    #   url = "github:Cassin01/wf.nvim";
    #   flake = false;
    # };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      systems = flake-utils.lib.defaultSystems;

      # This is where the Neovim derivation is built.
      neovim-overlay = import ./nix/neovim-overlay.nix { inherit inputs; };
    in
    flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
          overlays = [
            # Import the overlay, so that the final Neovim derivation(s) can be accessed via pkgs.<nvim-pkg>
            neovim-overlay
            # This adds a function can be used to generate a .luarc.json
            # containing the Neovim API all plugins in the workspace directory.
            # The generated file can be symlinked in the devShell's shellHook.
            inputs.gen-luarc.overlays.default
          ];
        };
        shell = pkgs.mkShell {
          name = "nvim-devShell";
          buildInputs = with pkgs; [
            # Tools for Lua and Nix development, useful for editing files in this repo

            bash-language-server
            lua-language-server
            nil
            stylua
            luajitPackages.luacheck
            nvim-dev
            cmake
            jq
            clang

            markdownlint-cli2

            # jdk

            # TODO: maybe add these as a def
            # python312
            # python312Packages.pytest
            # python312Packages.numpy
            (python3.withPackages (
              python-pkgs: with python-pkgs; [
                pytest
                numpy
              ]
            ))

            # python312Packages.pynvim
            # python312Packages.python-lsp-server
            # python312Packages.pylsp-mypy
          ];
          shellHook = ''
            # symlink the .luarc.json generated in the overlay
            ln -fs ${pkgs.nvim-luarc-json} .luarc.json
            # allow quick iteration of lua configs
            mkdir -p ~/.config
            ln -Tfns $PWD/nvim ~/.config/nvim-dev
          '';
        };
      in
      {
        packages = rec {
          default = nvim;
          nvim = pkgs.nvim-pkg;
        };
        checks = {
          stylua =
            pkgs.runCommand "stylua-check" { nativeBuildInputs = [ pkgs.stylua ]; src = ./.; }
              ''
                cd "$src"
                stylua --check nvim playground/lua *.lua
                touch "$out"
              '';

          luacheck =
            pkgs.runCommand "luacheck" { nativeBuildInputs = [ pkgs.luajitPackages.luacheck ]; src = ./.; }
              ''
                cd "$src"
                export HOME="$TMPDIR/home"
                export XDG_CACHE_HOME="$TMPDIR/cache"
                mkdir -p "$HOME" "$XDG_CACHE_HOME"
                luacheck --config "$src/.luacheckrc" --no-unused --no-unused-args nvim playground/lua *.lua
                touch "$out"
              '';

          nvim-starts =
            pkgs.runCommand "nvim-starts" { nativeBuildInputs = [ pkgs.nvim-pkg ]; }
              ''
                export HOME="$TMPDIR/home"
                export XDG_CACHE_HOME="$TMPDIR/cache"
                export XDG_DATA_HOME="$TMPDIR/data"
                export XDG_STATE_HOME="$TMPDIR/state"
                mkdir -p "$HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"
                ${pkgs.nvim-pkg}/bin/nvim --headless "+quitall"
                touch "$out"
              '';
          nvim-unit-tests = pkgs.runCommand "nvim-unit-tests" {
            nativeBuildInputs = [
              pkgs.neovim-unwrapped
            ];
            NVIM_TEST_PLENARY = "${pkgs.vimPlugins.plenary-nvim}";
            NVIM_TEST_RTP = "${self}/nvim";
            NVIM_TEST_DIR = "${self}/tests";
            NVIM_TEST_MINIMAL_INIT = "${self}/tests/minimal_init.lua";
          } ''
            export HOME="$TMPDIR/home"
            mkdir -p "$HOME"

            nvim --headless -u "$NVIM_TEST_MINIMAL_INIT" \
              -c "lua require('plenary.test_harness').test_directory(vim.env.NVIM_TEST_DIR, { minimal_init = vim.env.NVIM_TEST_MINIMAL_INIT, sequential = true })" \
              -c "qa"

            touch "$out"
          '';
        };
        devShells = {
          default = shell;
        };
        formatter = pkgs.alejandra;
      }
    )
    // {
      # You can add this overlay to your NixOS configuration
      overlays.default = neovim-overlay;
    };
}
