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
function M.run_command(cmd, args)
  if type(cmd) == "function" then
    cmd(args)
  elseif type(cmd) == "string" then
    vim.api.nvim_command(string.format(cmd, args))
  end
end

---Write content to a file
---@param path string
---@param content string
function M.write_file(path, content)
  local file = io.open(path, "w")
  if not file then
    return
  end
  file:write(content)
  file:close()
end

---Read content from a file
---@param path string
---@return string
function M.read_file(path)
  local file = io.open(path, "r")
  if not file then
    return "{}"
  end
  local content = file:read("*a")
  file:close()
  return content
end

---Open a buffer if it's not already open
---@param path string
---@return number
function M.open_buffer(path)
  local bufnr = vim.fn.bufadd(path)
  vim.api.nvim_buf_set_option(bufnr, "buflisted", true)
  return bufnr
end

return M
