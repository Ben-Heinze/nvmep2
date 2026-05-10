local function get_jdtls_path()
  local path = os.getenv('JDTLS_PATH')
  if not path or path == '' then
    error('JDTLS_PATH is not set')
  end
  return path
end

local function get_java_path()
  local path = os.getenv('JAVA_HOME')
  if not path or path == '' then
    error('JAVA_HOME is not set')
  end
  return path
end

local jdtls_path = get_jdtls_path()
local java_path = get_java_path()

-- local on_attach = function(client, bufnr)
--   require("plugins.configs.lspconfig").on_attach(client, bufnr)
-- end

-- local capabilities = require("plugins.configs.lspconfig").capabilities
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

-- Get the jdtls path and calculate the install path
-- local jdtls_path = get_jdtls_path()
-- local java_path = get_java_path()
local install_path = vim.fn.fnamemodify(jdtls_path, ':h:h') -- Two directories back

-- local jar_path = "/home/jordan/Downloads/plugins/org.eclipse.equinox.launcher_1.7.0.v20250519-0528.jar"
-- local jar_path = jdtls_path .. '/share/java/jdtls/plugins/org.eclipse.equinox.launcher_1.7.0.v20250519-0528.jar'

local plugins_dir = jdtls_path .. '/share/java/jdtls/plugins'
local prefix = 'org.eclipse.equinox.launcher_'
local handle = io.popen('find "' .. plugins_dir .. '" -maxdepth 1 -type f -name "' .. prefix .. '*.jar" | head -n 1')
local jar_path = handle:read('*l')
handle:close()

local configuration_path = jdtls_path .. '/share/java/jdtls/config_linux/'
local workspace_dir = vim.fn.stdpath('data') .. '/site/java/workspace-root/' .. project_name

-- local workspace_dir = "/home/jordan/.local/share/nvim" .. "/site/java/workspace-root/" .. project_name

-- Get the debug adapter install path (you can keep using mason for this if preferred)
-- local debug_install_path = require("mason-registry").get_package("java-debug-adapter"):get_install_path()

-- local bundles = {
--   vim.fn.glob(debug_install_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
-- }

-- "--jvm-arg=-javaagent:" .. install_path .. "/lombok.jar",

-- local config = {
--   -- The command that starts the language server
--   -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
--   cmd = {
--
--     -- 💀
--     java_path, -- or '/path/to/java21_or_newer/bin/java'
--     -- depends on if `java` is in your $PATH env variable and if it points to the right version.
--
--     '-Declipse.application=org.eclipse.jdt.ls.core.id1',
--     '-Dosgi.bundles.defaultStartLevel=4',
--     '-Declipse.product=org.eclipse.jdt.ls.core.product',
--     '-Dlog.protocol=true',
--     '-Dlog.level=ALL',
--     '-Xmx1g',
--     '--add-modules=ALL-SYSTEM',
--     '--add-opens',
--     'java.base/java.util=ALL-UNNAMED',
--     '--add-opens',
--     'java.base/java.lang=ALL-UNNAMED',
--
--     -- 💀
--     '-jar',
--     jar_path,
--     -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
--     -- Must point to the                                                     Change this to
--     -- eclipse.jdt.ls installation                                           the actual version
--
--     -- 💀
--     '-configuration',
--     configuration_path,
--     -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
--     -- Must point to the                      Change to one of `linux`, `win` or `mac`
--     -- eclipse.jdt.ls installation            Depending on your system.
--
--     -- 💀
--     -- See `data directory configuration` section in the README
--     '-data',
--     workspace_dir,
--   },
--
--   -- 💀
--   -- This is the default if not provided, you can remove it. Or adjust as needed.
--   -- One dedicated LSP server & client will be started per unique root_dir
--   --
--   -- vim.fs.root requires Neovim 0.10.
--   -- If you're using an earlier version, use: require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
--   root_dir = vim.fs.root(0, { '.git', 'mvnw', 'gradlew' }),
--
--   -- Here you can configure eclipse.jdt.ls specific settings
--   -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
--   -- for a list of options
--   settings = {
--     java = {},
--   },
--
--   -- Language server `initializationOptions`
--   -- You need to extend the `bundles` with paths to jar files
--   -- if you want to use additional eclipse.jdt.ls plugins.
--   --
--   -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
--   --
--   -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
--   init_options = {
--     bundles = {},
--   },
-- }

vim.lsp.start {
  name = 'jdtls',
  -- filetypes = { 'java' },
  cmd = { 'jdtls' },
  -- root_dir = vim.fs.root(0, { '.git', 'mvnw', 'gradlew' }),
  root_dir = '/home/jordan/projects/charm/',
  root_markers = { '.git', 'mvnw', 'gradlew' },
}

-- local config = {
--   cmd = 'jdtls',
--   root_dir = vim.fs.dirname(
--     vim.fs.find({ '.gradlew', '.git', 'mvnw', 'pom.xml', 'build.gradle' }, { upward = true })[1]
--   ),
-- }
-- -- This starts a new client & server,
-- -- or attaches to an existing client & server depending on the `root_dir`.
-- require('jdtls').start_or_attach(config)

-- -- See `:help vim.lsp.start` for an overview of the supported `config` options.
-- local config = {
--   name = 'jdtls',
--
--   -- `cmd` defines the executable to launch eclipse.jdt.ls.
--   -- `jdtls` must be available in $PATH and you must have Python3.9 for this to work.
--   --
--   -- As alternative you could also avoid the `jdtls` wrapper and launch
--   -- eclipse.jdt.ls via the `java` executable
--   -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
--   cmd = { 'jdtls' },
--
--   -- `root_dir` must point to the root of your project.
--   -- See `:help vim.fs.root`
--   root_dir = vim.fs.root(0, { 'gradlew', '.git', 'mvnw' }),
--
--   -- Here you can configure eclipse.jdt.ls specific settings
--   -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
--   -- for a list of options
--   settings = {
--     java = {},
--   },
--
--   -- This sets the `initializationOptions` sent to the language server
--   -- If you plan on using additional eclipse.jdt.ls plugins like java-debug
--   -- you'll need to set the `bundles`
--   --
--   -- See https://codeberg.org/mfussenegger/nvim-jdtls#java-debug-installation
--   --
--   -- If you don't plan on any eclipse.jdt.ls plugins you can remove this
--   init_options = {
--     bundles = {},
--   },
-- }
-- require('jdtls').start_or_attach(config)

-- {{{ old config

-- local config = {
--   cmd = {
--     jdtls_path,
--     "-Declipse.application=org.eclipse.jdt.ls.core.id1",
--     "-Dosgi.bundles.defaultStartLevel=4",
--     "-Declipse.product=org.eclipse.jdt.ls.core.product",
--     "-Dlog.protocol=true",
--     "-Dlog.level=ALL",
--     "-Xms1g",
--     "--add-modules=ALL-SYSTEM",
--     "--add-opens",
--     "java.base/java.util=ALL-UNNAMED",
--     "--add-opens",
--     "java.base/java.lang=ALL-UNNAMED",
--     "-data",
--     workspace_dir,
--   },
--   on_attach = on_attach,
--   -- capabilities = capabilities,
--   root_dir = vim.fs.dirname(
--     vim.fs.find({ ".gradlew", ".git", "mvnw", "pom.xml", "build.gradle" }, { upward = true })[1]
--   ),
--   settings = {
--     java = {
--       signatureHelp = { enabled = true },
--     },
--   },
--   -- init_options = {
--   --   bundles = bundles,
--   -- },
-- }
--
-- require('jdtls').start_or_attach(config)

-- }}} old config
