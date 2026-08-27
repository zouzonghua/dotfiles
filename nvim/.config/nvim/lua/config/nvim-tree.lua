local M = {}
local api = require("nvim-tree.api")

function M.toggle()
  local tree_window = api.tree.winid()

  if tree_window then
    if vim.api.nvim_get_current_win() == tree_window then
      api.tree.close_in_this_tab()
    else
      vim.api.nvim_set_current_win(tree_window)
    end
    return
  end

  api.tree.open()
end

local function on_attach(bufnr)
  api.map.on_attach.default(bufnr)
  vim.keymap.del("n", "<2-LeftMouse>", { buffer = bufnr })
  vim.keymap.set("n", "<C-e>", M.toggle, {
    buffer = bufnr,
    silent = true,
    desc = "Focus or close file explorer",
  })
end

require("nvim-tree").setup({
  view = {
    side = "left",
    width = 35,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
  update_focused_file = {
    enable = false,
  },
  actions = {
    open_file = {
      quit_on_open = false,
    },
  },
  on_attach = on_attach,
})

vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", {
  link = "NvimTreeNormal",
})

for _, group in ipairs({
  "NvimTreeFolderName",
  "NvimTreeEmptyFolderName",
  "NvimTreeOpenedFolderName",
  "NvimTreeSymlinkFolderName",
}) do
  vim.api.nvim_set_hl(0, group, {
    link = "NvimTreeNormal",
  })
end

vim.keymap.set("n", "<C-e>", M.toggle, { desc = "Focus or close file explorer" })

return M
