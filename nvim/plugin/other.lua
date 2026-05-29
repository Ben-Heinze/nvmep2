-- default settings
local modified_defaults = {

  -- by default there are no mappings enabled
  mappings = {

    -- {{{ from include

    { pattern = '/include/(.*)/(.*).hpp', target = '/source/%1/%2.cpp', context = 'source' },

    { pattern = '/include/(.*)/(.*).hpp', target = '/tests/source/%1/%2_tests.cpp', context = 'test' },

    { pattern = '/include/(.*)/(.*).hpp', target = '/examples/source/%1/%2_ex.cpp', context = 'example' },

    { pattern = '/include/(.*)/(.*).hpp', target = '/include/%1/%2_impl.hpp', context = 'impl' },

    -- }}} from include

    -- {{{ from source

    { pattern = '/source/(.*)/(.*).cpp', target = '/include/%1/%2.cpp', context = 'include' },

    { pattern = '/source/(.*)/(.*).cpp', target = '/tests/source/%1/%2_tests.cpp', context = 'test' },

    { pattern = '/source/(.*)/(.*).cpp', target = '/examples/source/%1/%2_ex.cpp', context = 'example' },

    { pattern = '/source/(.*)/(.*).cpp', target = '/include/%1/%2_impl.hpp', context = 'impl' },

    -- }}} from source

    -- {{{ from tests

    {
      pattern = '/tests/(.*)/(.*)_tests.cpp',
      target = '/include/%1/%2.cpp',
      context = 'include',
    },

    {
      pattern = '/tests/(.*)/(.*)_tests.cpp',
      target = '/source/%1/%2.cpp',
      context = 'source',
    },

    {
      pattern = '/tests/(.*)/(.*)_tests.cpp',
      target = '/examples/source/%1/%2_ex.cpp',
      context = 'example',
    },

    {
      pattern = '/tests/(.*)/(.*)_tests.cpp',
      target = '/include/%1/%2_impl.hpp',
      context = 'impl',
    },

    -- }}} from tests

    -- {{{ from impl

    {
      pattern = '/include/(.*)/(.*)_impl.hpp',
      target = '/source/%1/%2.cpp',
      context = 'source',
    },

    {
      pattern = '/include/(.*)/(.*)_impl.hpp',
      target = '/tests/source/%1/%2_tests.cpp',
      context = 'test',
    },

    {
      pattern = '/include/(.*)/(.*)_impl.hpp',
      target = '/examples/source/%1/%2_ex.cpp',
      context = 'example',
    },

    {
      pattern = '/include/(.*)/(.*)_impl.hpp',
      target = '/include/%1/%2.hpp',
      context = 'include',
    },

    -- }}} from tests
  },

  -- -- default transformers
  -- transformers = {
  --   camelToKebap = transformers.camelToKebap,
  --   kebapToCamel = transformers.kebapToCamel,
  --   pluralize = transformers.pluralize,
  --   singularize = transformers.singularize,
  -- },

  -- Should the window show files which do not exist yet based on
  -- pattern matching. Selecting the files will create the file.
  showMissingFiles = true,

  -- When a mapping requires an initial selection of the other file, this setting controls,
  -- wether the selection should be remembered for the current user session.
  -- When this option is set to false reference between the two buffers are never saved.
  -- Existing references can be removed on the buffer with :OtherClear
  rememberBuffers = true,

  keybindings = {
    ['<cr>'] = 'open_file_by_command()',
    ['<esc>'] = 'close_window()',
    t = 'open_file_tabnew()',
    o = 'open_file()',
    q = 'close_window()',
    v = 'open_file_vs()',
    s = 'open_file_sp()',
  },

  hooks = {
    -- This hook which is executed when the file-picker is shown.
    -- It could be used to filter or reorder the files in the filepicker.
    -- The function must return a lua table with the same structure as the input parameter.
    --
    -- The input parameter "files" is a lua table with each entry containing:
    -- @param table (filename (string), context (string), exists (boolean))
    -- @return table | boolean When an empty table or false is returned the filepicker is not openend.
    filePickerBeforeShow = function(files)
      return files
    end,

    -- This hook is called whenever a file is about to be opened.
    -- One example how this can be used: a non existing file needs to be opened by another plugin, which provides a template.
    --
    -- @param filename (string) the full-path of the file
    -- @param exists (boolean) doess the file already exist
    -- @return (boolean) When true (default) the plugin takes care of opening the file, when the function returns false this indicated that opening of the file is done in the hook.
    onOpenFile = function(_, _)
      return true
    end,

    -- This hook is called whenever the plugin tries to find other files.
    -- It returns the matches found by the plugin. It can be used to filter or reorder the files or use the matches with another plugin.
    --
    -- @param matches (table) lua table with each entry containing: (filename (string), context (string), exists (boolean))
    -- @return (matches) Make sure to return the matches, otherwise the plugin will not work as expected.
    onFindOtherFiles = function(matches)
      return matches
    end,
  },

  style = {
    -- How the plugin paints its window borders
    -- Allowed values are none, single, double, rounded, solid and shadow
    border = 'solid',

    -- Column seperator for the window
    seperator = '|',

    -- Indicator showing that the file does not yet exist
    newFileIndicator = '(* new *)',

    -- width of the window in percent. e.g. 0.5 is 50%, 1 is 100%
    width = 0.7,

    -- min height in rows.
    -- when more columns are needed this value is extended automatically
    minHeight = 2,
  },
}

require('other-nvim').setup(modified_defaults)
