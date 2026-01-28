-- Test helpers for nvim integration tests
-- Provides mocking and assertion utilities

local M = {}

-- Internal registries (cleared by mock functions)
_G._test_confirms = {}
_G._test_notifications = {}

local original_confirm = vim.fn.confirm
local original_notify = vim.notify

--- Mock vim.fn.confirm with expected prompts and responses
--- Errors immediately if an unexpected confirm is called
---@param expectations table[] Array of {message, choices, response}
function M.mockConfirm(expectations)
  _G._test_confirms = {}
  _G._test_confirm_expectations = expectations

  vim.fn.confirm = function(msg, choices, default)
    table.insert(_G._test_confirms, {
      message = msg,
      choices = choices,
      default = default,
    })

    for _, exp in ipairs(_G._test_confirm_expectations) do
      if msg:match(exp.message) and choices == exp.choices then
        return exp.response
      end
    end

    error(
      string.format(
        "Unexpected confirm call:\n  message: %q\n  choices: %q\nNo matching expectation found.",
        msg,
        choices
      )
    )
  end
end

--- Mock vim.notify to record all notifications
function M.mockNotify()
  _G._test_notifications = {}

  vim.notify = function(msg, level, opts)
    table.insert(_G._test_notifications, {
      message = msg,
      level = level,
    })
    original_notify(msg, level, opts)
  end
end

--- Assert that confirm was called with expected messages and choices (in order)
---@param expected table[] Array of {message, choices} where message can contain %s wildcards
function M.assertConfirmed(expected)
  local actual = _G._test_confirms

  if #actual ~= #expected then
    local actual_msgs = {}
    for i, c in ipairs(actual) do
      actual_msgs[i] = string.format("  %d: message=%q choices=%q", i, c.message, c.choices)
    end
    local expected_msgs = {}
    for i, e in ipairs(expected) do
      expected_msgs[i] = string.format("  %d: message=%q choices=%q", i, e.message, e.choices)
    end
    error(
      string.format(
        "Expected %d confirm call(s), got %d.\nExpected:\n%s\nActual:\n%s",
        #expected,
        #actual,
        table.concat(expected_msgs, "\n"),
        table.concat(actual_msgs, "\n")
      )
    )
  end

  for i, exp in ipairs(expected) do
    local act = actual[i]
    if not act.message:match(exp.message) then
      error(
        string.format(
          "Confirm #%d message mismatch:\n\n  expected pattern:\n\n%q\n\n  actual:\n\n%q",
          i,
          exp.message,
          act.message
        )
      )
    end
    if act.choices ~= exp.choices then
      error(string.format("Confirm #%d choices mismatch:\n  expected: %q\n  actual: %q", i, exp.choices, act.choices))
    end
  end
end

--- Assert that no confirm dialogs were shown
function M.assertNotConfirmed()
  local actual = _G._test_confirms
  if #actual > 0 then
    local actual_msgs = {}
    for i, c in ipairs(actual) do
      actual_msgs[i] = string.format("  %d: message=%q choices=%q", i, c.message, c.choices)
    end
    error(string.format("Expected no confirm dialogs, got %d:\n%s", #actual, table.concat(actual_msgs, "\n")))
  end
end

--- Assert that notifications were sent with expected messages and levels (in order)
---@param expected table[] Array of {message, level} where message can contain %s wildcards
function M.assertNotified(expected)
  local actual = _G._test_notifications

  if #actual ~= #expected then
    local actual_msgs = {}
    for i, n in ipairs(actual) do
      actual_msgs[i] = string.format("  %d: %q (level=%s)", i, n.message, tostring(n.level))
    end
    local expected_msgs = {}
    for i, e in ipairs(expected) do
      expected_msgs[i] = string.format("  %d: %q (level=%s)", i, e.message, tostring(e.level))
    end
    error(
      string.format(
        "Expected %d notification(s), got %d.\nExpected:\n%s\n\nActual:\n%s",
        #expected,
        #actual,
        table.concat(expected_msgs, "\n"),
        table.concat(actual_msgs, "\n")
      )
    )
  end

  for i, exp in ipairs(expected) do
    local act = actual[i]
    if not act.message:match(exp.message) then
      error(
        string.format(
          "Notification #%d message mismatch:\n\n  expected pattern: \n\n%q\n\n  actual:\n\n%q",
          i,
          exp.message,
          act.message
        )
      )
    end
    if act.level ~= exp.level then
      error(
        string.format(
          "Notification #%d level mismatch:\n  expected: %s\n  actual: %s",
          i,
          tostring(exp.level),
          tostring(act.level)
        )
      )
    end
  end
end

--- Assert that no notifications were sent
function M.assertNotNotified()
  local actual = _G._test_notifications
  if #actual > 0 then
    local actual_msgs = {}
    for i, n in ipairs(actual) do
      actual_msgs[i] = string.format("  %d: %q (level=%s)", i, n.message, tostring(n.level))
    end
    error(string.format("Expected no notifications, got %d:\n%s", #actual, table.concat(actual_msgs, "\n")))
  end
end

--- Assert that no notifications matching the pattern were sent
---@param pattern string Lua pattern to match against notification messages
function M.assertNotNotifiedMatching(pattern)
  local actual = _G._test_notifications
  local matching = {}
  for i, n in ipairs(actual) do
    if n.message:match(pattern) then
      table.insert(matching, string.format("  %d: %q (level=%s)", i, n.message, tostring(n.level)))
    end
  end
  if #matching > 0 then
    error(
      string.format(
        "Expected no notifications matching %q, got %d:\n%s",
        pattern,
        #matching,
        table.concat(matching, "\n")
      )
    )
  end
end

--- Assert that a file exists and contains the expected content
--- NOTE: Trailing newline is stripped (vim.fn.readfile behavior)
---@param path string Path to the file
---@param expected string Expected file contents
function M.assertFileHasContents(path, expected)
  local stat = vim.uv.fs_lstat(path)
  if not stat then
    error(string.format("File does not exist: %s", path))
  end

  local lines = vim.fn.readfile(path)
  local actual = table.concat(lines, "\n")

  if actual ~= expected then
    error(string.format("File contents mismatch for %s:\n  expected:\n\n%q\n\n  actual:\n\n%q", path, expected, actual))
  end
end

--- Assert that a path is a symlink pointing to the expected target
---@param path string Path to check
---@param expected_target string Expected symlink target
function M.assertIsSymlinkTo(path, expected_target)
  local stat = vim.uv.fs_lstat(path)
  if not stat then
    error(string.format("Path does not exist: %s", path))
  end
  if stat.type ~= "link" then
    error(string.format("Expected symlink at %s, got %s", path, stat.type))
  end
  local actual_target = vim.uv.fs_readlink(path)
  if actual_target ~= expected_target then
    error(
      string.format(
        "Symlink target mismatch for %s:\n  expected: %s\n  actual: %s",
        path,
        expected_target,
        actual_target
      )
    )
  end
end

-- Export as global for easy access in tests
_G.test_helpers = M

return M
