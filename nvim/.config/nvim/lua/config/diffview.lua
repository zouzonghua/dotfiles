require("diffview").setup({
  view = {
    default = {
      layout = "diff2_horizontal",
    },
    file_history = {
      layout = "diff2_horizontal",
    },
  },
  file_panel = {
    win_config = {
      position = "left",
      width = 35,
    },
  },
  file_history_panel = {
    win_config = {
      position = "bottom",
      height = 16,
    },
  },
})

vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", {
  desc = "Open Git diff",
})

vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<CR>", {
  desc = "Open Git history",
})

vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<CR>", {
  desc = "Close Git diff",
})
