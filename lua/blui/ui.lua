local bufferline = require("bufferline")
local popup = require("plenary.popup")
local config = require("blui.config")
local utils = require("blui.utils")
local state = require("blui.state")

local M = {}

WIN_ID = nil
BUF_ID = nil

local function create_window()
  local width = 60
  local height = 10
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local bufnr = vim.api.nvim_create_buf(false, false)

  local win_id, win = popup.create(bufnr, {
    title = "Buffers",
    highlight = "BluiWindow",
    line = math.floor(((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    minwidth = width,
    minheight = height,
    borderchars = borderchars,
  })

  vim.api.nvim_win_set_option(win.border.win_id, "winhl", "Normal:BluiWindowBorder")

  return {
    bufnr = bufnr,
    win_id = win_id,
  }
end

local function close_window()
  if utils.is_window_open(WIN_ID) then
    if config.get_config().save_on_close then
      M.on_save()
    end

    vim.api.nvim_win_close(WIN_ID, true)
  end

  WIN_ID = nil
  BUF_ID = nil
end

---Get the items from the buffer
---@return State
local function get_items()
  local lines = vim.api.nvim_buf_get_lines(BUF_ID, 0, -1, true)
  local result = {}
  for i, line in ipairs(lines) do
    if not utils.is_whitespace(line) then
      local path = vim.fn.fnamemodify(line, ":p")
      result[path] = i
    end
  end

  return result
end

---@class UpdateStateOpts
---@field skip_close boolean | nil
---@field skip_open boolean | nil

---Update the bufferline
---@param items State
---@param opts UpdateStateOpts | nil
function M.update_state(items, opts)
  opts = opts or {}
  local buffers = bufferline.get_elements().elements
  local seen = {}
  for _, buf in ipairs(buffers) do
    if not items[buf.path] then
      if opts.skip_close ~= true then
        utils.run_command(config.get_config().close_command, buf.id)
      end
    else
      seen[buf.path] = true
    end
  end

  for path, _ in pairs(items) do
    if not seen[path] and opts.skip_open ~= false then
      utils.open_buffer(path)
    end
  end
end

function M.on_save()
  local items = get_items()
  M.update_state(items)

  vim.schedule(function()
    bufferline.sort_by(function(a, b)
      if not items[a.path] then
        return false
      end
      if not items[b.path] then
        return true
      end
      return items[a.path] < items[b.path]
    end)
  end)

  state.save(items)
end

function M.select_item()
  local line = vim.api.nvim_get_current_line()
  local path = vim.fn.fnamemodify(line, ":p")
  close_window()
  local bufnr = utils.open_buffer(path)
  vim.api.nvim_set_current_buf(bufnr)
end

function M.toggle_window()
  if utils.is_window_open(WIN_ID) then
    close_window()
    return
  end

  local win_info = create_window()
  WIN_ID = win_info.win_id
  BUF_ID = win_info.bufnr

  local buffers = bufferline.get_elements().elements
  local lines = {}
  for _, buf in ipairs(buffers) do
    local name = vim.fn.fnamemodify(buf.path, ":.")
    table.insert(lines, name)
  end

  vim.api.nvim_win_set_option(WIN_ID, "number", true)
  vim.api.nvim_win_set_option(WIN_ID, "relativenumber", true)
  vim.api.nvim_buf_set_name(BUF_ID, "blui-menu")
  vim.api.nvim_buf_set_lines(BUF_ID, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(BUF_ID, "filetype", "blui")
  vim.api.nvim_buf_set_option(BUF_ID, "swapfile", false)
  vim.api.nvim_buf_set_option(BUF_ID, "buftype", "acwrite")
  vim.api.nvim_buf_set_option(BUF_ID, "bufhidden", "delete")
  vim.api.nvim_buf_set_keymap(
    BUF_ID,
    "n",
    "q",
    ":lua require('blui.ui').toggle_window()<cr>",
    { noremap = true, silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    BUF_ID,
    "n",
    "<esc>",
    ":lua require('blui.ui').toggle_window()<cr>",
    { noremap = true, silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    BUF_ID,
    "n",
    "<cr>",
    ":lua require('blui.ui').select_item()<cr>",
    { noremap = true, silent = true }
  )

  vim.cmd(string.format("autocmd BufWriteCmd <buffer=%s> lua require('blui.ui').on_save()", BUF_ID))
  vim.cmd(string.format("autocmd BufModifiedSet <buffer=%s> set nomodified", BUF_ID))
end

return M
