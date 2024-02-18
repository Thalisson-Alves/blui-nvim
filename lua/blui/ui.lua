local utils = require("blui.utils")
local config = require("blui.config")

local popup = require("plenary.popup")
local bufferline = require("bufferline")
local bufferline_ui = require("bufferline.ui")
local bufferline_utils = require("bufferline.utils")

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
    vim.api.nvim_win_close(WIN_ID, true)
  end

  WIN_ID = nil
  BUF_ID = nil
end

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

function M.on_save()
  local items = get_items()
  bufferline.sort_by(function(a, b)
    if not items[a.path] or not items[b.path] then
      return false
    end
    return items[a.path] < items[b.path]
  end)

  local buf_nums = bufferline_utils.get_valid_buffers()
  for _, buf in ipairs(buf_nums) do
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p")
    if not items[name] then
      utils.apply_command(config.get_config().close_command, buf)
    end
  end

  bufferline_ui.refresh()
end

function M.toggle_window()
  if utils.is_window_open(WIN_ID) then
    close_window()
    return
  end

  local win_info = create_window()
  WIN_ID = win_info.win_id
  BUF_ID = win_info.bufnr

  local buf_nums = bufferline_utils.get_valid_buffers()
  local lines = {}
  for _, buf in ipairs(buf_nums) do
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
    local line = string.format("%s", name)
    table.insert(lines, line)
  end

  vim.api.nvim_win_set_option(WIN_ID, "number", true)
  vim.api.nvim_win_set_option(WIN_ID, "relativenumber", true)
  vim.api.nvim_buf_set_name(BUF_ID, "blui-menu")
  vim.api.nvim_buf_set_lines(BUF_ID, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(BUF_ID, "filetype", "blui")
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

  vim.cmd(string.format("autocmd BufWriteCmd <buffer=%s> lua require('blui.ui').on_save()", BUF_ID))
end

return M
