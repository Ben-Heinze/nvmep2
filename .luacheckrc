std = "luajit"

globals = {
  "vim",
}

-- Neovim configs commonly contain long plugin option tables and command strings.
max_line_length = 200

-- These are intentionally used throughout config (Neovim provides them).
read_globals = {
  "jit",
  "vim",
}

ignore = {
  "122", -- assigning to read-only fields (common in Neovim config)
}

exclude_files = {
  ".direnv/**",
  "build/**",
}

files["nvim/plugin/heirline.lua"] = {
  ignore = {
    "111", -- setting non-standard global variable
    "113", -- accessing undefined variable
    "211", -- unused variable
    "212", -- unused argument
    "213", -- unused loop variable
    "231", -- unused function
    "511", -- loop is executed at most once
    "512", -- loop is executed at most once (alt)
    "411", -- redefined local
  },
}

files["nvim/plugin/luasnip.lua"] = {
  ignore = {
    "211",
    "212",
    "213",
    "231",
    "311", -- value assigned is unused
    "411", -- redefined local
    "241", -- redefined local
    "541", -- shadowing upvalue
    "542", -- shadowing upvalue
    "631", -- line is too long
  },
}
