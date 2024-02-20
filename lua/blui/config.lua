local M = {}

local config = {
  -- FIXME: doesn't delete last buffer
  close_command = "bdelete %d",
  -- TODO: add ui stuff (width, height, etc)
  persist_path = vim.fn.stdpath("data") .. "/blui.json",
  save_on_close = false,
}

function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})
end

function M.get_config()
  return config
end

return M
