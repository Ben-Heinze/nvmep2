local status_ok, overseer = pcall(require, 'overseer')

if not status_ok then
  return
end

overseer.setup {
  templates = { 'user.cpp_build' }, -- "builtin",  -- NOTE: I don't think i want builtin templates (crowds out when too many and bad ui (needs telescope))
}
