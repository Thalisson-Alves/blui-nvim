local M = {}

local config = {
  -- FIXME: doesn't delete last buffer
  close_command = "bdelete %d",
  open_command = vim.cmd.edit,
  -- TODO: add ui stuff (width, height, etc)
  -- TODO: persist the last menu per project
}

function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})
end

function M.get_config()
  return config
end

return M
