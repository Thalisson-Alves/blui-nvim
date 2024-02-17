local M = {}

---Check if a window is open
---@param win_id number | nil
---@return boolean
function M.is_window_open(win_id)
  return win_id ~= nil and vim.api.nvim_win_is_valid(win_id)
end

---Check if a string is whitespace
---@param str string
---@return boolean
function M.is_whitespace(str)
  return str:match("^%s*$") ~= nil
end

return M
