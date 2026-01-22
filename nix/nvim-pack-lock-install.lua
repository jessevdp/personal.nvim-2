-- Ensure the vim.pack lockfile exists at the location Neovim expects.
--
-- Problem:
--   vim.pack requires its lockfile at: stdpath('config') .. '/nvim-pack-lock.json'
--   This path is NOT configurable (see: https://github.com/neovim/neovim/issues/27539)
--
--   For Nix-wrapped Neovim, the config comes from the Nix store, but stdpath('config')
--   points to a user-writable location (e.g., ~/.config/<NVIM_APPNAME>/).
--
--   We bridge that gap by copying or symlinking the lockfile from the Nix-
--   provided source to Neovim's expected location on startup.
--
-- Environment variable overrides
--   NVIM_PACK_LOCK_INSTALL_SOURCE_PATH  Override source lockfile path
--   NVIM_PACK_LOCK_INSTALL_SYMLINK      If "1", create symlink instead of copy

--------------------------------------------------------------------------------
-- Installer
--------------------------------------------------------------------------------

---@class Installer
---@field source_path string
---@field target_path string
---@field wants_symlink boolean
local Installer = {}
Installer.__index = Installer

---@param opts { source_path: string, wants_symlink: boolean }
---@return Installer
function Installer.new(opts)
  local self = setmetatable({}, Installer)
  self.source_path = opts.source_path or ""
  self.target_path = vim.fn.stdpath("config") .. "/nvim-pack-lock.json"
  self.wants_symlink = opts.wants_symlink or false
  return self
end

function Installer:run()
  local ok, err = pcall(function()
    if not self:source_exists() then
      error("Source lockfile not found: " .. self.source_path, 0)
    end

    if self:source_is_target() then
      return
    end

    if not self:target_exists() then
      self:install()
      return
    end

    if self:target_matches() then
      return
    end

    if not self:confirm_replace() then
      return
    end

    self:backup_target()
    self:install()
  end)

  if not ok then
    Installer.log(err, vim.log.levels.ERROR)
  end
end

--------------------------------------------------------------------------------
-- Branching (queries)
--------------------------------------------------------------------------------

function Installer:source_exists()
  return vim.fn.filereadable(self.source_path) == 1
end

function Installer:source_is_target()
  return self.source_path == self.target_path
end

function Installer:target_exists()
  local stat = vim.uv.fs_lstat(self.target_path)
  return stat ~= nil
end

function Installer:target_matches()
  if self.wants_symlink then
    return self:target_is_symlink_to_source()
  else
    return self:target_contents_match()
  end
end

function Installer:target_is_symlink_to_source()
  local stat = vim.uv.fs_lstat(self.target_path)
  if not stat or stat.type ~= "link" then
    return false
  end
  local link_target = vim.uv.fs_readlink(self.target_path)
  return link_target == self.source_path
end

function Installer:target_contents_match()
  local stat = vim.uv.fs_lstat(self.target_path)
  if not stat or stat.type == "link" then
    return false
  end
  local source_lines = vim.fn.readfile(self.source_path)
  local target_lines = vim.fn.readfile(self.target_path)
  if #source_lines ~= #target_lines then
    return false
  end
  for i, line in ipairs(source_lines) do
    if line ~= target_lines[i] then
      return false
    end
  end
  return true
end

function Installer:confirm_replace()
  return Installer.confirm(
    "Lockfile at "
      .. self.target_path
      .. " differs from source. Replace it? (backup will be created)"
  )
end

--------------------------------------------------------------------------------
-- Actions (doing)
--------------------------------------------------------------------------------

function Installer:install()
  self:ensure_target_parent_dir()

  if self.wants_symlink then
    self:install_symlink()
  else
    self:install_copy()
  end
end

function Installer:install_symlink()
  local ok, err = vim.uv.fs_symlink(self.source_path, self.target_path)
  if not ok then
    error("Failed to create symlink: " .. (err or "unknown error"), 0)
  end
  Installer.log("Created symlink at " .. self.target_path)
end

function Installer:install_copy()
  local content = vim.fn.readfile(self.source_path, "b")
  if vim.fn.writefile(content, self.target_path, "b") ~= 0 then
    error("Failed to copy lockfile to " .. self.target_path, 0)
  end
  Installer.log("Copied lockfile to " .. self.target_path)
end

function Installer:ensure_target_parent_dir()
  local parent = vim.fn.fnamemodify(self.target_path, ":h")
  vim.fn.mkdir(parent, "p")
end

function Installer:backup_target()
  local timestamp = os.date("%Y-%m-%d-%H%M%S")
  local backup_path = self.target_path .. ".backup." .. timestamp
  local ok, err = vim.uv.fs_rename(self.target_path, backup_path)
  if not ok then
    error("Failed to backup to " .. backup_path .. ": " .. (err or "unknown error"), 0)
  end
  Installer.log("Backed up to " .. backup_path)
end

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local LOG_TAG = "[nvim-pack-install]"

---@param msg string
---@param level? integer
function Installer.log(msg, level)
  vim.schedule(function()
    vim.notify(LOG_TAG .. " " .. msg, level or vim.log.levels.INFO)
  end)
end

---@param msg string
---@return boolean
function Installer.confirm(msg)
  local choice = vim.fn.confirm(LOG_TAG .. " " .. msg, "&Yes\n&No", 2)
  return choice == 1
end

--------------------------------------------------------------------------------
-- Entry point
--------------------------------------------------------------------------------

---@class RunOpts
---@field source_path string Path to source lockfile
---@field wants_symlink? boolean Create symlink instead of copy (default: false)

---@param opts RunOpts
---@return nil
local function run(opts)
  local source_path = vim.env.NVIM_PACK_LOCK_INSTALL_SOURCE_PATH
  if not source_path or source_path == "" then
    source_path = opts.source_path
  end

  local wants_symlink = vim.env.NVIM_PACK_LOCK_INSTALL_SYMLINK == "1"
  if vim.env.NVIM_PACK_LOCK_INSTALL_SYMLINK == nil then
    wants_symlink = opts.wants_symlink or false
  end

  if not source_path or source_path == "" then
    Installer.log("source_path not provided and NVIM_PACK_LOCK_INSTALL_SOURCE_PATH not set", vim.log.levels.ERROR)
    return
  end

  local installer = Installer.new({
    source_path = source_path,
    wants_symlink = wants_symlink,
  })

  installer:run()
end

return { run = run }
