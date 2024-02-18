local ui = require("blui.ui")
local config = require("blui.config")

local M = {
  toggle_window = ui.toggle_window,
}

---@class Options
---@field close_command string | function | nil

---Setup the plugin
---@param opts any
function M.setup(opts)
  config.setup(opts)
end

return M
