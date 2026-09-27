local M = {}

local SDKMAN_CURRENT_LINK = "current"
local MIN_RUNTIME_MAJOR = 8
-- jdtls 1.54.0 runs on Java 21 to 25 and knows execution environments up to JavaSE-25
local MIN_JDTLS_MAJOR = 21
local MAX_JDTLS_MAJOR = 25

local function sdkman_java_dir()
  local sdkman_dir = vim.env.SDKMAN_DIR or (vim.env.HOME .. "/.sdkman")
  return sdkman_dir .. "/candidates/java"
end

local function read_major_version(java_home)
  local release_file = java_home .. "/release"
  if vim.fn.filereadable(release_file) == 0 then
    return nil
  end

  for _, line in ipairs(vim.fn.readfile(release_file)) do
    local version = line:match('^JAVA_VERSION="([^"]+)"')
    if version then
      -- Java 8 and older use the "1.x" version format
      return tonumber(version:match("^1%.(%d+)") or version:match("^(%d+)"))
    end
  end
  return nil
end

local function runtime_name(major)
  if major <= 8 then
    return "JavaSE-1." .. major
  end
  return "JavaSE-" .. major
end

---Finds the SDKMAN JDKs that jdtls supports, one for each major version.
---@return { major: integer, home: string }[] # sorted by major version
function M.find_sdkman_jdks()
  local homes_by_major = {}
  for _, home in ipairs(vim.fn.glob(sdkman_java_dir() .. "/*", false, true)) do
    local major = not home:match("/" .. SDKMAN_CURRENT_LINK .. "$") and read_major_version(home)
    if major and major >= MIN_RUNTIME_MAJOR and major <= MAX_JDTLS_MAJOR and not homes_by_major[major] then
      homes_by_major[major] = home
    end
  end

  local jdks = {}
  for major, home in pairs(homes_by_major) do
    table.insert(jdks, { major = major, home = home })
  end
  table.sort(jdks, function(a, b)
    return a.major < b.major
  end)
  return jdks
end

---@param jdks { major: integer, home: string }[]
---@return { name: string, path: string }[] # value for `java.configuration.runtimes`
function M.to_runtimes(jdks)
  local runtimes = {}
  for _, jdk in ipairs(jdks) do
    table.insert(runtimes, { name = runtime_name(jdk.major), path = jdk.home })
  end
  return runtimes
end

---@param jdks { major: integer, home: string }[] # sorted by major version
---@return string|nil # home of the newest JDK that can run jdtls
function M.find_jdtls_home(jdks)
  for i = #jdks, 1, -1 do
    if jdks[i].major >= MIN_JDTLS_MAJOR then
      return jdks[i].home
    end
  end
  return nil
end

return M
