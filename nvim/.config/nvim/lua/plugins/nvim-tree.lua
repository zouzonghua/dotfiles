local api = require("nvim-tree.api")

local function on_attach(bufnr)
  api.map.on_attach.default(bufnr)
  vim.keymap.del("n", "<2-LeftMouse>", { buffer = bufnr })
  vim.keymap.set("n", "<leader>e", api.tree.toggle, {
    buffer = bufnr,
    silent = true,
    desc = "Toggle file explorer",
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
    git_ignored = false,
  },
  filesystem_watchers = {
    enable = true,
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

vim.keymap.set("n", "<leader>e", api.tree.toggle, { desc = "Toggle file explorer" })
