local null_ls = require('null-ls')
null_ls.setup {
  sources = {

    -- null_ls.builtins.diagnostics.eslint,
    -- null_ls.builtins.completion.spell,
    -- null_ls.builtins.completion.spell,

    -- null_ls.builtins.diagnostics.textidote,

    -- {{{ css

    -- null_ls.builtins.formatting.stylelint,

    -- }}} css

    -- {{{ cmake

    -- null_ls.builtins.diagnostics.cmake_lint,

    -- }}} cmake

    -- {{{ cpp

    -- null_ls.builtins.diagnostics.cppcheck,
    -- null_ls.builtins.formatting.clang_format,

    -- }}} cpp

    -- {{{ html/xml

    -- null_ls.builtins.formatting.tidy,

    -- }}} html/xml

    -- {{{ javascript

    -- null_ls.builtins.formatting.prettierd,
    -- null_ls.builtins.formatting.prettierd.with({
    --     filetypes = { "javascript", "typescript", "html", "css", "json" },
    -- }),

    -- }}} javascript

    -- {{{ just

    -- null_ls.builtins.formatting.just,

    -- }}} just

    -- {{{ lua

    -- null_ls.builtins.formatting.stylua,
    -- null_ls.builtins.diagnostics.selene, -- needs configuration w/ vim (workspaces?)

    -- }}} lua

    -- {{{ nix

    -- null_ls.builtins.diagnostics.statix,

    -- }}} nix

    -- {{{ matlab

    -- null_ls.builtins.formatting.mlint,

    -- }}} matlab

    -- {{{ markdown

    -- null_ls.builtins.diagnostics.markdownlint_cli2,

    -- }}} markdown

    -- {{{ python

    null_ls.builtins.diagnostics.pylint.with {
      diagnostics_postprocess = function(diagnostic)
        diagnostic.code = diagnostic.message_id
      end,
    },
    -- null_ls.builtins.formatting.isort,
    null_ls.builtins.formatting.black,
    null_ls.builtins.diagnostics.mypy,

    -- }}} python
  },
}
