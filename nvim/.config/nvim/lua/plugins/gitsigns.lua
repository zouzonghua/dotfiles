require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "▸" },
    topdelete = { text = "▸" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  preview_config = {
    border = "single",
  },
  current_line_blame = true,
  current_line_blame_formatter = " <committer>, <committer_time:%R> • <summary>",
})

vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", {
  link = "GruvboxFg3",
})
