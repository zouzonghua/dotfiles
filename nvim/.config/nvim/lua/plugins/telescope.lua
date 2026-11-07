require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-a>"] = { "<Home>", type = "command" },
        ["<C-e>"] = { "<End>", type = "command" },
        ["<C-b>"] = { "<Left>", type = "command" },
        ["<C-f>"] = { "<Right>", type = "command" },
        ["<C-d>"] = { "<Del>", type = "command" },
        ["<C-k>"] = { "<C-o>D", type = "command" },
      },
    },
  },
})

local builtin = require("telescope.builtin")
local map = vim.keymap.set

map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Search project text" })
