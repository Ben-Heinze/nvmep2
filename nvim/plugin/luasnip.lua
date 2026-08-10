local ls = require('luasnip')
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local types = require('luasnip.util.types')

-- {{{ setup opts
ls.setup {
  keep_roots = true,
  link_roots = true,
  link_children = true,

  -- Update more often, :h events for more info.
  update_events = 'TextChanged,TextChangedI',
  -- Snippets aren't automatically removed if their text is deleted.
  -- `delete_check_events` determines on which events (:h events) a check for
  -- deleted snippets is performed.
  -- This can be especially useful when `history` is enabled.
  delete_check_events = 'TextChanged',
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { 'choiceNode', 'Comment' } },
      },
    },
  },
  -- treesitter-hl has 100, use something higher (default is 200).
  ext_base_prio = 300,
  -- minimal increase in priority.
  ext_prio_increase = 1,
  enable_autosnippets = true,
  -- mapping for cutting selected text so it's usable as SELECT_DEDENT,
  -- SELECT_RAW or TM_SELECTED_TEXT (mapped via xmap).
  store_selection_keys = '<Tab>',
  -- luasnip uses this function to get the currently active filetype. This
  -- is the (rather uninteresting) default, but it's possible to use
  -- eg. treesitter for getting the current filetype by setting ft_func to
  -- require("luasnip.extras.filetype_functions").from_cursor (requires
  -- `nvim-treesitter/nvim-treesitter`). This allows correctly resolving
  -- the current filetype in eg. a markdown-code block or `vim.cmd()`.
  ft_func = function()
    return vim.split(vim.bo.filetype, '.', { plain = true })
  end,
}
-- }}} setup opts

-- {{{ Helper methods

-- 'recursive' dynamic snippet. Expands to some text followed by itself.
local rec_ls
rec_ls = function()
  return sn(
    nil,
    c(1, {
      -- Order is important, sn(...) first would cause infinite loop of expansion.
      t(''),
      sn(nil, { t { '', '\t\\item ' }, i(1), d(2, rec_ls, {}) }),
    })
  )
end

-- complicated function for dynamicnode.
local function jdocsnip(args, _, old_state)
  -- !!! old_state is used to preserve user-input here. don't do it that way!
  -- using a restorenode instead is much easier.
  -- view this only as an example on how old_state functions.
  local nodes = {
    t { '/**', ' * ' },
    i(1, 'a short description'),
    t { '', '' },
  }

  -- these will be merged with the snippet; that way, should the snippet be updated,
  -- some user input eg. text can be referred to in the new snippet.
  local param_nodes = {}

  if old_state then
    nodes[2] = i(1, old_state.descr:get_text())
  end
  param_nodes.descr = nodes[2]

  -- at least one param.
  if string.find(args[2][1], ', ') then
    vim.list_extend(nodes, { t { ' * ', '' } })
  end

  local insert = 2
  ---@diagnostic disable-next-line: unused-local
  for indx, arg in ipairs(vim.split(args[2][1], ', ', { plain = true })) do
    -- get actual name parameter.
    arg = vim.split(arg, ' ', { plain = true })[2]
    if arg then
      local inode
      -- if there was some text in this parameter, use it as static_text for this new snippet.
      if old_state and old_state[arg] then
        inode = i(insert, old_state['arg' .. arg]:get_text())
      else
        inode = i(insert)
      end
      vim.list_extend(nodes, { t { ' * @param ' .. arg .. ' ' }, inode, t { '', '' } })
      param_nodes['arg' .. arg] = inode

      insert = insert + 1
    end
  end

  if args[1][1] ~= 'void' then
    local inode
    if old_state and old_state.ret then
      inode = i(insert, old_state.ret:get_text())
    else
      inode = i(insert)
    end

    vim.list_extend(nodes, { t { ' * ', ' * @return ' }, inode, t { '', '' } })
    param_nodes.ret = inode
    insert = insert + 1
  end

  if vim.tbl_count(args[3]) ~= 1 then
    local exc = string.gsub(args[3][2], ' throws ', '')
    local ins
    if old_state and old_state.ex then
      ins = i(insert, old_state.ex:get_text())
    else
      ins = i(insert)
    end
    vim.list_extend(nodes, { t { ' * ', ' * @throws ' .. exc .. ' ' }, ins, t { '', '' } })
    param_nodes.ex = ins
    insert = insert + 1
  end

  vim.list_extend(nodes, { t { ' */' } })

  local snip = sn(nil, nodes)
  -- error on attempting overwrite.
  snip.old_state = param_nodes
  return snip
end

-- }}} Helper methods

-- snippets are added via ls.add_snippets(filetype, snippets[, opts]), where
-- opts may specify the `type` of the snippets ("snippets" or "autosnippets",
-- for snippets that should expand directly after the trigger is typed).
--
-- opts can also specify a key. by passing an unique key to each add_snippets, it's possible to reload snippets by
-- re-`:luafile`ing the file in which they are defined (eg. this one).

-- {{{ All snippets

ls.add_snippets('all', {
  s('envrc', {
    t {

      '# shellcheck shell=bash',
      'if ! has nix_direnv_version || ! nix_direnv_version 3.1.0; then',
      "  source_url 'https://raw.githubusercontent.com/nix-community/nix-direnv/3.1.0/direnvrc' 'sha256-yMJ2OVMzrFaDPn7q8nCBZFRYpL/f0RcHzhmw/i6btJM='",
      'fi',
      'watch_file flake.nix',
      'use flake',
    },
  }),
}, {
  key = 'all',
})

-- }}} All snippets

-- {{{ lua snippets
ls.add_snippets('lua', {
  -- Very long example for a java class.
  s('new-module', {
    t { 'local M = {}', '', '' },
    i(1),
    t { '', '', 'return M' },
  }),

  s('lowercase-global', {
    t { '---@diagnostic disable-next-line: lowercase-global' },
  }),

  s('unused-local', {
    t { '---@diagnostic disable-next-line: unused-local' },
  }),
}, {
  key = 'lua',
})
-- }}} lua snippets

-- {{{ Java snippets
ls.add_snippets('java', {
  -- Very long example for a java class.
  s('fn', {
    d(6, jdocsnip, { 2, 4, 5 }),
    t { '', '' },
    c(1, {
      t('public '),
      t('private '),
    }),
    c(2, {
      t('void'),
      t('String'),
      t('char'),
      t('int'),
      t('double'),
      t('boolean'),
      i(nil, ''),
    }),
    t(' '),
    i(3, 'myFunc'),
    t('('),
    i(4),
    t(')'),
    c(5, {
      t(''),
      sn(nil, {
        t { '', ' throws ' },
        i(1),
      }),
    }),
    t { ' {', '\t' },
    i(0),
    t { '', '}' },
  }),
}, {
  key = 'java',
})
-- }}} Java snippets

-- {{{ tex snippets

-- True when the cursor sits inside a math region, per the buffer's tex
-- syntax highlighting (texMathZone*, defined by $VIMRUNTIME/syntax/tex.vim).
-- Used to gate autosnippets that should only fire in math mode, e.g. '.'.
local function in_mathzone()
  local stack = vim.fn.synstack(vim.fn.line('.'), vim.fn.col('.') - 1)
  for _, id in ipairs(stack) do
    if vim.fn.synIDattr(id, 'name'):find('texMathZone') then
      return true
    end
  end
  return false
end

ls.add_snippets('tex', {
  -- rec_ls is self-referencing. That makes this snippet 'infinite' eg. have as many
  -- \item as necessary by utilizing a choiceNode.
  s('ls', {
    t { '\\begin{itemize}', '\t\\item ' },
    i(1),
    d(2, rec_ls, {}),
    t { '', '\\end{itemize}' },
  }),
}, {
  key = 'tex',
})

ls.add_snippets('tex', {
  s('.', { t('\\dots') }, { condition = in_mathzone }),
}, {
  type = 'autosnippets',
  key = 'tex_auto',
})

-- }}} tex snippets

-- {{{ CPP snippets
ls.add_snippets('cpp', {

  s('ponce', {
    t { '#pragma once' },
  }),

  s('javatocpp', {
    t {
      'Consider the code java code above.',
      'Can you help me write it to its equivalent c++ code?',
      'Can you separate it into a header file and a source file?',
      'Also, can you provide a full working example?',
      'Also, can you write unit tests using doctest for the public api?',
    },
  }),

  s('charmassumptions', {
    t {
      'You can assume the following assumptions and additional requirements:',
      '',
      'Assumptions:',
      ' - for xml api things, you can assume I have an api that closely follows, except prefixes with Xml (i.e. xml api known from java: XmlDocument, XmlNode, XmlElement, XmlAttribute, XmlText, XmlComment, ...)',
      ' - assume objects with types unknown to you are defined somewhere else just place an include placeholder (commented)',
      '',
      'Requirements',
      ' - use #pragma once instead of include guards',
      ' - use shared_ptr to wrap any output and input for unknown (to you) types',
      ' - wrap source and header in the charm namespace ',
    },
  }),

  s('charmentity', {
    t {
      '#include <charm/aiestate/cem/entity/entity.hpp>',
    },
  }),

  s('charmxml', {
    t {
      '#include <charm/xml/xml.hpp>',
    },
  }),

  s('iostream', {
    t { '#include <iostream>' },
  }),

  s('memory', {
    t { '#include <memory>' },
  }),

  s('helloworld', {
    t {
      '#include <iostream>',
      '',
      'int main(void) {',
      '  std::cout << "Hello World!" << std::endl;',
      '  return 0;',
      '}',
    },
  }),
}, {
  key = 'cpp',
})
-- }}} Cpp snippets

-- {{{ nix snippets
ls.add_snippets('nix', {

  -- {{{ Module
  s('module', {
    t {
      '# https://nix.dev/tutorials/module-system/index.html',
      '{lib, ...}:',
      '{',
      '  imports = [',
      '    # Paths to other modules.',
      '    # Compose this module out of smaller ones.',
      '  ];',
      '',
      '  options = {',
      '    # Option declarations.',
      '    # Declare what settings a user of this module can set.',
      '    # Usually this includes a global "enable" option which defaults to false.',
      '  };',
      '',
      '  config = {',
      '    # Option definitions.',
      '    # Define what other settings, services and resources should be active.',
      '    # Usually these depend on whether a user of this module chose to "enable" it',
      '    # using the "option" above.',
      '    # Options for modules imported in "imports" can be set here.',
      '  };',
      '}',
    },
  }),
  -- }}} Module

  -- {{{ basic-shell
  s('basic-shell', {
    t {
      '# my-env shell',
      'with import <nixpkgs> { };',
      '',
      'mkShell {',
      '  name = "my-env";',
      '  packages = [',
      '    hello',
      '  ];',
      '}',
    },
  }),
  -- }}} basic-shell

  -- {{{ basic flake
  s('basic-flake', {
    t {
      '{',
      '  description = "A basic flake";',
      '  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";',
      '  inputs.systems.url = "github:nix-systems/default";',
      '  inputs.flake-utils = {',
      '    url = "github:numtide/flake-utils";',
      '    inputs.systems.follows = "systems";',
      '  };',
      '',
      '  outputs =',
      '    { nixpkgs, flake-utils, ... }:',
      '    flake-utils.lib.eachDefaultSystem (',
      '      system:',
      '      let',
      '        pkgs = nixpkgs.legacyPackages.${system};',
      '      in',
      '      {',
      '        devShells.default = pkgs.mkShell { ',
      '          packages = [',
      '            pkgs.hello',
      '          ]; ',
      '        };',
      '      }',
      '    );',
      '}',
    },
  }),

  -- }}} basic flake
}, {
  key = 'nix',
})
-- }}} Cpp snippets

-- {{{ load snippets
-- in a lua file: search lua-, then c-, then all-snippets.
ls.filetype_extend('lua', { 'c' })
-- in a cpp file: search c-snippets, then all-snippets only (no cpp-snippets!!).
ls.filetype_set('cpp', { 'c', 'cpp' })
require('luasnip.loaders.from_vscode').load { include = { 'python' } } -- Load only python snippets
require('luasnip.loaders.from_vscode').load { paths = { './my-snippets' } } -- Load snippets from my-snippets folder
-- tex is excluded: friendly-snippets' tex bundle autoexpands unconditionally
-- (e.g. '.' -> '\dots' outside math mode); we maintain our own tex snippets
-- above instead, gated by in_mathzone() where appropriate.
require('luasnip.loaders.from_vscode').lazy_load { exclude = { 'tex' } }
ls.filetype_extend('all', { '_' })
require('luasnip.loaders.from_snipmate').load { include = { 'c' } } -- Load only snippets for c.
require('luasnip.loaders.from_snipmate').load { path = { './my-snippets' } }
require('luasnip.loaders.from_snipmate').lazy_load { exclude = { 'tex' } } -- Lazy loading
require('luasnip.loaders.from_lua').load { include = { 'c' } }
require('luasnip.loaders.from_lua').lazy_load { include = { 'all', 'cpp' } }
-- }}} load snippets from other sources

-- {{{ note-taking snippets
-- LaTeX math autosnippets (registered for `tex`) and Org structure snippets.
require('user.snippets_math')
require('user.snippets_org')
-- In an org buffer, also search tex snippets so the full math library is
-- available inside `$...$` / math environments.
ls.filetype_extend('org', { 'tex' })
-- }}} note-taking snippets
