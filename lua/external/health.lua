-- This file gets ran on :checkhealth

--[[

Summary:
--------
health checker for Neovim config dependencies

* Makes sure Neovim version is good and external CLI tools are installed
 If any tools are not installed yet, you need to run ./bootstrap.sh


Functionality:
--------------
- `check_version()`:
    Checks that Neovim is up-to-date.
    Displays `vim.health.ok` or `vim.health.error` messages accordingly.

- `check_external_reqs()`:
    Iterates through the required executables listed in `lua/external/reqs.lua`.
    For each, shows a success or warning if not found via `vim.fn.executable()`.

- `check()` (main entrypoint):
    Called when `:checkhealth` is run.
    Starts health group, displays system info, and runs the above two checks.

Helpful Commands:
-----------------
- `:checkhealth`       → Runs this script and displays plugin + system status.
- `:lua require('external.health').check()` → Manually run health checks.

References:
-----------
- `:help vim.health`
- `:help vim.fn.executable`
- `:help lua-guide`
]]

local check_version = function()
  local verstr = tostring(vim.version())
  if not vim.version.ge then
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
    return
  end

  if vim.version.ge(vim.version(), '0.10-dev') then
    vim.health.ok(string.format("Neovim version is: '%s'", verstr))
  else
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
  end
end

local external_reqs = require 'external.reqs'

local check_external_reqs = function()
  for _, exe in ipairs(external_reqs) do
    local is_executable = vim.fn.executable(exe) == 1
    if is_executable then
      vim.health.ok(string.format("Found executable: '%s'", exe))
    else
      vim.health.warn(string.format("Could not find executable: '%s'", exe))
    end
  end

  return true
end

return {
  check = function()
    vim.health.start 'kickstart.nvim'

    vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

    local uv = vim.uv or vim.loop
    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_version()
    check_external_reqs()
  end,
}
