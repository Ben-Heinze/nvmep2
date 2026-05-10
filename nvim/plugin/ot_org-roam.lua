require('org-roam').setup {
  directory = '/home/jordan/org-roam',
  -- optional
  org_files = {
    '/home/jordan/org-roam',
    -- "~/another_org_dir",
    -- "~/some/folder/*.org",
    -- "~/a/single/org_file.org",
  },
  bindings = {
    find_node = '<Space>orr',
    insert_node = '<Space>ori',
    toggle_roam_buffer_fixed = '<Space>orb',
    capture_date = '<Space>orcD',
    goto_date = '<Space>orgD',
    capture = '<Space>orcc',
    goto_next_node = '<Space>orn',
    goto_prev_node = '<Space>orp',
  },
}
