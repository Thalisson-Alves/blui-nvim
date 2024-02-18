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

---Apply user command
---@param cmd string | function
---@param args any
function M.apply_command(cmd, args)
  if type(cmd) == "function" then
    cmd(args)
  elseif type(cmd) == "string" then
    vim.api.nvim_command(string.format(cmd, args))
  end
end

return M
