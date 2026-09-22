vim.keymap.set("n", "<leader>p", function()
  if vim.bo.filetype == "markdown" then
    vim.fn["mkdp#util#toggle_preview"]()
  end
end, { desc = "Toggle Markdown preview" })
