# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{ inputs }:
final: prev:
with final.pkgs.lib;
let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin =
    src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  neovimVersion = "v0.11.4";
  neovimSrc = pkgs.fetchFromGithub {
    owner = "neovim";
    repo = "neovim";
    rev = neovimVersion;
    sha256 = ""; # NOTE: why is this not needed!?
  };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-locked = inputs.nixpkgs.legacyPackages.${pkgs.system};

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix {
    inherit (pkgs-locked) wrapNeovimUnstable neovimUtils;
    src = neovimSrc; # NOTE: why does this actually work?
  };

  # A plugin can either be a package or an attrset, such as
  # { plugin = <plugin>; # the package, e.g. pkgs.vimPlugins.nvim-cmp
  #   config = <config>; # String; a config that will be loaded with the plugin
  #   # Boolean; Whether to automatically load the plugin as a 'start' plugin,
  #   # or as an 'opt' plugin, that can be loaded with `:packadd!`
  #   optional = <true|false>; # Default: false
  #   ...
  # }
  all-plugins =
    let

      Nuake = pkgs.vimUtils.buildVimPlugin {
        name = "nuake";
        src = pkgs.fetchFromGitHub {
          owner = "lenowski";
          repo = "nuake";
          rev = "9cfa226";
          hash = "sha256-cmVTjs552eXPMDh95Tgx9wDxwKL+dV+Z9lGlKfG5Osw=";
        };
      };

      TelescopeLuasnip = pkgs.vimUtils.buildVimPlugin {
        name = "telescope-luasnip-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "benfowler";
          repo = "telescope-luasnip.nvim";
          rev = "07a2a2936a7557404c782dba021ac0a03165b343";
          hash = "sha256-9XsV2hPjt05q+y5FiSbKYYXnznDKYOsDwsVmfskYd3M=";
        };
      };

      EasyGrep = pkgs.vimUtils.buildVimPlugin {
        name = "vim-easygrep";
        src = pkgs.fetchFromGitHub {
          owner = "dkprice";
          repo = "vim-easygrep";
          rev = "d0c36a77cc63c22648e792796b1815b44164653a";
          hash = "sha256-bL33/S+caNmEYGcMLNCanFZyEYUOUmSsedCVBn4tV3g=";
        };
      };

      # https://github.com/NotAShelf/direnv.nvim
      DirenvNvim = pkgs.vimUtils.buildVimPlugin {
        name = "direnv";
        src = pkgs.fetchFromGitHub {
          owner = "NotAShelf";
          repo = "direnv.nvim";
          rev = "4dfc8758a1deab45e37b7f3661e0fd3759d85788";
          hash = "sha256-KqO8uDbVy4sVVZ6mHikuO+SWCzWr97ZuFRC8npOPJIE=";
        };
      };
      LivePreviewNvim = pkgs.vimUtils.buildVimPlugin {
        name = "live-preview-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "brianhuster";
          repo = "live-preview.nvim";
          rev = "598672eaf91b38946626677f8e80426e6e7ceccc";
          hash = "sha256-wtEG5GoXWEIVXOtC7Jp/euDQR7NmttbdI8MbmgIc74Q=";
        };
        doCheck = false;
      };

      # # https://github.com/chrisgrieser/nvim-justice
      # Justice = pkgs.vimUtils.buildVimPlugin {
      #   name = "jsfunc-nvim";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "chrisgrieser";
      #     repo = "nvim-justice";
      #     rev = "1335a7eacc7766fc933e5e3ea2f37d324d478431";
      #     hash = "sha256-bfHZl0n8ig0PL4TW9AcAur4BH/iO6h8nELZRztNVxLU=";
      #   };
      # };

      # JsFunc = pkgs.vimUtils.buildVimPlugin {
      #   name = "jsfunc-nvim";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "nxuv";
      #     repo = "jsfunc.nvim";
      #     rev = "ed968840ade89f1d0c95513852a145dca1fe7916";
      #     hash = "sha256-qQAGTI0BieXI6F/qWNmiQVVVxmTwHQ9vlMendflkAxs=";
      #   };
      # };

      Telescope = pkgs.vimUtils.buildVimPlugin {
        name = "telescope";
        src = pkgs.fetchFromGitHub {
          owner = "nvim-telescope";
          repo = "telescope.nvim";
          rev = "b4da76be54691e854d3e0e02c36b0245f945c2c7";
          hash = "sha256-JpW0ehsX81yVbKNzrYOe1hdgVMs6oaaxMLH6lECnOJg=";
        };
        dependencies = [
          pkgs.vimPlugins.plenary-nvim
        ];
      };

      # JustNvim = pkgs.vimUtils.buildVimPlugin {
      #   name = "just-nvim";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "nxuv";
      #     repo = "just.nvim";
      #     rev = "daf68f3babfef658d7adb18b41efbfec63927feb";
      #     hash = "sha256-o7mZnHS03qyclkR2/wy2mTz5P+1R995ja6D1gBpdWjM=";
      #   };
      #   dontBuild = true;
      #   dontCheck = true;
      #   dependencies = [
      #     JsFunc
      #     pkgs.vimPlugins.plenary-nvim
      #     pkgs.vimPlugins.telescope-nvim
      #     pkgs.vimPlugins.fidget-nvim
      #     pkgs.vimPlugins.nvim-notify
      #   ];
      # };

      nvim-tree-preview = pkgs.vimUtils.buildVimPlugin {
        name = "nvim-tree-preview";
        src = pkgs.fetchFromGitHub {
          owner = "b0o";
          repo = "nvim-tree-preview.lua";
          rev = "e763de51dca15d65ce4a0b9eca716136ac51b55c";
          hash = "sha256-7XPYnset01YEtwPUEcS+cXZQwf8h9cARKlgwwCUT3YY=";
        };
      };

      # https://github.com/R-nvim/R.nvim
      R-nvim = pkgs.vimUtils.buildVimPlugin {
        name = "r";
        src = pkgs.fetchFromGitHub {
          owner = "R-nvim";
          repo = "R.nvim";
          rev = "fef990378e4b5157f23314dca4136bc0079cc2c4";
          hash = "sha256-KgvK2tR6C97Z1WEUbVNHzAe6QKUg0T5FLB9HwO3eay4=";
        };
      };

    in
    with pkgs.vimPlugins;
    [
      # plugins from nixpkgs go in here.
      # https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=vimPlugins

      Nuake
      R-nvim
      DirenvNvim
      Telescope
      TelescopeLuasnip
      LivePreviewNvim

      # Justice
      # JsFunc
      # JustNvim
      EasyGrep
      # nvim-tree-preview
      # nvim-luadev
      # telescope-ultisnips-nvim
      # orgmode
      # jupytext-nvim

      nvim-coverage
      neotest # https://github.com/nvim-neotest/neotest
      neotest-testthat
      neotest-jest
      neotest-java
      neotest-python
      neotest-gtest
      neotest-bash
      otter-nvim # https://github.com/jmbuhr/otter.nvim
      dashboard-nvim # https://github.com/nvimdev/dashboard-nvim/
      text-case-nvim # https://github.com/johmsalas/text-case.nvim
      friendly-snippets # https://github.com/rafamadriz/friendly-snippets
      asyncrun-vim # https://github.com/skywind3000/asyncrun.vim
      blink-cmp # https://github.com/Saghen/blink.cmp
      # refactoring-nvim # https://github.com/ThePrimeagen/refactoring.nvim
      nvim-treesitter-refactor # https://github.com/nvim-treesitter/nvim-treesitter-refactor
      flash-nvim # https://github.com/folke/flash.nvim
      focus-nvim # https://github.com/nvim-focus/focus.nvim
      kanagawa-nvim # https://github.com/rebelot/kanagawa.nvim
      markdown-preview-nvim # https://github.com/iamcco/markdown-preview.nvim
      melange-nvim # https://github.com/savq/melange-nvim
      nerdtree # https://github.com/preservim/nerdtree
      nvim-bqf # https://github.com/kevinhwang91/nvim-bqf
      nvim-dap # https://github.com/mfussenegger/nvim-dap
      nvim-dap-ui # https://github.com/rcarriga/nvim-dap-ui
      nvim-highlight-colors # https://github.com/brenoprata10/nvim-highlight-colors
      oil-nvim # https://github.com/stevearc/oil.nvim
      other-nvim # https://github.com/rgroli/other.nvim
      overseer-nvim # https://github.com/stevearc/overseer.nvim?tab=readme-ov-file
      render-markdown-nvim # https://github.com/MeanderingProgrammer/render-markdown.nvim
      todo-comments-nvim # https://github.com/folke/todo-comments.nvim
      tokyonight-nvim # https://github.com/folke/tokyonight.nvim
      ultisnips # https://github.com/SirVer/ultisnips
      url-open # https://github.com/sontungexpt/url-open
      none-ls-nvim # https://github.com/nvimtools/none-ls.nvim
      conform-nvim # https://github.com/stevearc/conform.nvim
      zen-mode-nvim # https://github.com/folke/zen-mode.nvim

      leetcode-nvim # https://github.com/kawre/leetcode.nvim

      aerial-nvim # https://github.com/stevearc/aerial.nvim
      cmp-buffer # https://github.com/hrsh7th/cmp-buffer/
      cmp-cmdline # https://github.com/hrsh7th/cmp-cmdline
      cmp-cmdline-history
      cmp-nvim-lsp # https://github.com/hrsh7th/cmp-nvim-lsp/
      cmp-nvim-lsp-signature-help # https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/
      cmp-nvim-lua # https://github.com/hrsh7th/cmp-nvim-lua/
      hover-nvim # https://github.com/lewis6991/hover.nvim
      cmp-path # https://github.com/hrsh7th/cmp-path/
      cmp_luasnip # https://github.com/saadparwaiz1/cmp_luasnip/
      codecompanion-nvim # https://github.com/olimorris/codecompanion.nvim
      copilot-vim # https://github.com/github/copilot.vim/
      diffview-nvim # https://github.com/sindrets/diffview.nvim/
      eyeliner-nvim # https://github.com/jinh0/eyeliner.nvim
      gitsigns-nvim # https://github.com/lewis6991/gitsigns.nvim/
      heirline-nvim # https://github.com/rebelot/heirline.nvim/
      lsp-progress-nvim # https://github.com/linrongbin16/lsp-progress.nvim
      lspkind-nvim # https://github.com/onsails/lspkind.nvim/
      luasnip # https://github.com/l3mon4d3/luasnip/
      neogit # https://github.com/TimUntersberger/neogit/
      nvim-cmp # https://github.com/hrsh7th/nvim-cmp
      nvim-jdtls # https://github.com/mfussenegger/nvim-jdtls
      nvim-navic # https://github.com/SmiteshP/nvim-navic
      nvim-surround # https://github.com/kylechui/nvim-surround/
      nvim-tree-lua # https://github.com/nvim-tree/nvim-tree.lua
      nvim-tree-lua # https://github.com/nvim-tree/nvim-tree.lua
      nvim-treesitter-context # nvim-treesitter-context
      nvim-treesitter-textobjects # https://github.com/nvim-treesitter/nvim-treesitter-textobjects/
      nvim-treesitter.withAllGrammars
      nvim-treesitter-parsers.r
      nvim-ts-context-commentstring # https://github.com/joosepalviste/nvim-ts-context-commentstring/
      nvim-unception # nvim-unception
      nvim-web-devicons # https://github.com/nvim-tree/nvim-web-devicons
      plenary-nvim # https://github.com/nvim-lua/plenary.nvim
      smart-splits-nvim # https://github.com/mrjones2014/smart-splits.nvim
      sqlite-lua # https://github.com/kkharji/sqlite.lua
      statuscol-nvim # https://github.com/luukvbaal/statuscol.nvim/
      telescope-fzy-native-nvim # https://github.com/nvim-telescope/telescope-fzy-native.nvim
      # telescope-nvim # https://github.com/nvim-telescope/telescope.nvim/
      telescope-project-nvim # https://github.com/nvim-telescope/telescope-project.nvim
      vim-fugitive # https://github.com/tpope/vim-fugitive/
      vim-repeat # https://github.com/tpope/vim-repeat
      vim-slime # https://github.com/jpalardy/vim-slime
      vim-unimpaired # https://github.com/tpope/vim-unimpaired/
      which-key-nvim # https://github.com/folke/which-key.nvim

      # image-nvim # https://github.com/3rd/image.nvim
    ];

  extraPackages = with pkgs; [
    luajit
    direnv

    # # language servers, etc.
    # lua-language-server
    # nil # nix LSP

    # # cpp
    # gcc
    # gdb
    # libclang
    # llvm # ??? rudundant?
    # cppcheck

    # # markdown
    # markdownlint-cli2

    # # python
    # mypy
    # pylint
    # isort
    # black
    # python312
    # (python312.withPackages (python-pkgs: [
    #   python-pkgs.numpy
    #   python-pkgs.python-lsp-server
    #   python-pkgs.debugpy
    # ]))

    # # cmake
    # cmake
    # cmake-lint

    # # HTML
    # html-tidy

    # # javascript
    # nodejs_23
    # prettierd

    # # css
    # stylelint
    # stylelint-lsp

    # # lua
    # selene
    # lua-language-server

    # # fortran
    # gfortran

    # # nix
    # nil # nix LSP
    # alejandra
    # statix

    # # shell
    # bash-language-server
    # beautysh

    # # Java
    # jdk
    # jdt-language-server

    # # latex
    # texliveFull
    # # textidote

    # # typescript
    # typescript-language-server

    # # R
    # # R
    # # rPackages.testthat
    # # rPackages.languageserver
    # # rPackages.languageserversetup
  ];
in
{
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
  };

  # This is meant to be used within a devshell.
  # Instead of loading the lua Neovim configuration from
  # the Nix store, it is loaded from $XDG_CONFIG_HOME/nvim-dev
  nvim-dev = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
    appName = "nvim-dev";
    wrapRc = false;
  };

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json {
    plugins = all-plugins;
  };

  # You can add as many derivations as you like.
  # Use `ignoreConfigRegexes` to filter out config
  # files you would not like to include.
  #
  # For example:
  #
  # nvim-pkg-no-telescope = mkNeovim {
  #   plugins = [];
  #   ignoreConfigRegexes = [
  #     "^plugin/telescope.lua"
  #     "^ftplugin/.*.lua"
  #   ];
  #   inherit extraPackages;
  # };
}
