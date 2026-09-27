local repo_root = arg[0]:match("^(.*)/tests/[^/]+$") or "."
local jdk_path = repo_root .. "/nvim/lua/config/jdk.lua"
local plugin_path = repo_root .. "/nvim/lua/plugins/jdtls.lua"

local sdkman_java = "/sdkman/candidates/java"

local function release_file(java_version)
  return { 'IMPLEMENTOR="Eclipse Adoptium"', 'JAVA_VERSION="' .. java_version .. '"' }
end

local function stub_vim(files)
  local homes = {}
  for path in pairs(files) do
    table.insert(homes, (path:gsub("/release$", "")))
  end
  table.sort(homes)

  _G.vim = {
    env = { SDKMAN_DIR = "/sdkman", PATH = "/usr/bin" },
    log = { levels = { WARN = 3 } },
    fn = {
      glob = function(pattern)
        assert(pattern == sdkman_java .. "/*")
        return homes
      end,
      filereadable = function(path)
        return files[path] and 1 or 0
      end,
      readfile = function(path)
        return assert(files[path])
      end,
    },
  }
end

-- find_sdkman_jdks keeps one JDK for each major version from 8 to 25
stub_vim({
  [sdkman_java .. "/7.0.352-zulu/release"] = release_file("1.7.0_352"),
  [sdkman_java .. "/8.0.422-tem/release"] = release_file("1.8.0_422"),
  [sdkman_java .. "/17.0.12-tem/release"] = release_file("17.0.12"),
  [sdkman_java .. "/17.0.9-zulu/release"] = release_file("17.0.9"),
  [sdkman_java .. "/21.0.4-tem/release"] = release_file("21.0.4"),
  [sdkman_java .. "/25-tem/release"] = release_file("25"),
  [sdkman_java .. "/26.ea.3-open/release"] = release_file("26-ea"),
  [sdkman_java .. "/current/release"] = release_file("21.0.4"),
})
local jdk = dofile(jdk_path)
local jdks = jdk.find_sdkman_jdks()
assert(#jdks == 4)
assert(jdks[1].major == 8 and jdks[1].home == sdkman_java .. "/8.0.422-tem")
assert(jdks[2].major == 17 and jdks[2].home == sdkman_java .. "/17.0.12-tem")
assert(jdks[3].major == 21 and jdks[3].home == sdkman_java .. "/21.0.4-tem")
assert(jdks[4].major == 25 and jdks[4].home == sdkman_java .. "/25-tem")

-- to_runtimes uses the execution environment names of jdtls
local runtimes = jdk.to_runtimes(jdks)
assert(runtimes[1].name == "JavaSE-1.8" and runtimes[1].path == jdks[1].home)
assert(runtimes[2].name == "JavaSE-17")
assert(runtimes[4].name == "JavaSE-25")

-- find_jdtls_home picks the newest JDK from 21 to 25, or nil
assert(jdk.find_jdtls_home(jdks) == sdkman_java .. "/25-tem")
assert(jdk.find_jdtls_home({ jdks[1], jdks[2] }) == nil)

local function load_plugin(files)
  stub_vim(files)
  local calls = {}
  local spring_boot_config = {}
  package.loaded["config.jdk"] = dofile(jdk_path)
  package.loaded["spring_boot.config"] = spring_boot_config
  package.loaded["cmp_nvim_lsp"] = {
    default_capabilities = function()
      return {}
    end,
  }
  package.loaded["java"] = {
    setup = function(options)
      calls.java_setup = options
    end,
  }
  vim.notify = function(message)
    calls.notify = message
  end
  vim.lsp = {
    config = function(name, config)
      assert(name == "jdtls")
      calls.lsp_config = config
    end,
    enable = function(name)
      calls.enabled = name
    end,
  }

  dofile(plugin_path).config()
  return calls, spring_boot_config
end

-- Without a JDK 21 to 25, the plugin warns and does not start nvim-java, so no JDK download starts
local calls = load_plugin({ [sdkman_java .. "/17.0.12-tem/release"] = release_file("17.0.12") })
assert(calls.notify)
assert(calls.java_setup == nil)
assert(calls.enabled == nil)

-- With a JDK 21 to 25, jdtls and the Spring Boot LS run on it and all JDKs are runtimes
local jdk21 = sdkman_java .. "/21.0.4-tem"
local spring_boot_config
calls, spring_boot_config = load_plugin({
  [sdkman_java .. "/8.0.422-tem/release"] = release_file("1.8.0_422"),
  [jdk21 .. "/release"] = release_file("21.0.4"),
})
assert(calls.java_setup.jdk.auto_install == false)
assert(spring_boot_config.java_cmd == jdk21 .. "/bin/java")
assert(calls.lsp_config.cmd_env.JAVA_HOME == jdk21)
assert(calls.lsp_config.cmd_env.PATH == jdk21 .. "/bin:/usr/bin")
local configured = calls.lsp_config.settings.java.configuration.runtimes
assert(#configured == 2)
assert(configured[1].name == "JavaSE-1.8")
assert(configured[2].name == "JavaSE-21")
assert(calls.enabled == "jdtls")
