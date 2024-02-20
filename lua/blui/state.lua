local config = require("blui.config")
local utils = require("blui.utils")

local M = {}

---@alias State table<string, number>

local function format_state(items)
  local lines = {}
  for path, _ in pairs(items) do
    table.insert(lines, path)
  end
  table.sort(lines, function(a, b)
    return items[a] < items[b]
  end)
  return lines
end

---Save the state to the persist file
---@param items State
function M.save(items)
  local persist_path = config.get_config().persist_path
  local content = vim.fn.json_decode(utils.read_file(persist_path))
  content[vim.fn.getcwd()] = format_state(items)
  utils.write_file(persist_path, vim.fn.json_encode(content))
end

---Load the state from the persist file
---@return State
function M.load()
  local content = vim.fn.json_decode(utils.read_file(config.get_config().persist_path))
  if not content then
    return {}
  end
  local lines = content[vim.fn.getcwd()]
  if not lines then
    return {}
  end
  local items = {}
  for i, path in ipairs(lines) do
    items[path] = i
  end
  return items
end

return M
