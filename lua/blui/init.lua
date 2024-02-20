local config = require("blui.config")
local state = require("blui.state")
local ui = require("blui.ui")

local M = {
  toggle = ui.toggle_window,
  load = function()
    ui.update_state(state.load(), { close_buffers = false })
  end,
}

---@class Options
---@field close_command string | function | nil

---Setup the plugin
---@param opts any
function M.setup(opts)
  config.setup(opts)
  M.load()
end

return M
