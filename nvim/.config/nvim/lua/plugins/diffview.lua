local actions = require("diffview.actions")

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
  keymaps = {
    view = {
      { "n", "q", actions.close, { desc = "Close Git view" } },
    },
    file_panel = {
      { "n", "q", actions.close, { desc = "Close Git view" } },
    },
    file_history_panel = {
      { "n", "q", actions.close, { desc = "Close Git history" } },
    },
  },
})

vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", {
  desc = "Open Git diff",
})

vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<CR>", {
  desc = "Open Git history",
})
