-- Luacheck configuration for Neovim configs.
-- Keep this minimal: prefer catching real issues over silencing everything.

std = "luajit"

-- Neovim runtime globals.
read_globals = { "vim" }
globals = { "vim" }

-- Neovim config style tends to intentionally:
-- - set globals (W111/W113)
-- - assign to vim.* option tables (W122)
-- - define helper functions that are referenced via commands/autocmds (W211)
ignore = { "111", "113", "122", "211" }

-- Don't lint vendored/generated files (none currently), but keep playground permissive.
exclude_files = {
  ".direnv/**",
  "build/**",
}

-- Allow long lines in plugin configs (often tables/keys).
max_line_length = false
