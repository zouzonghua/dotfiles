local map = vim.keymap.set

map("n", "<CR>", "<cmd>set hlsearch!<CR>", { desc = "Toggle search highlight" })

-- Emacs-style movement in command-line mode.
map("c", "<C-a>", "<Home>")
map("c", "<C-e>", "<End>")
map("c", "<C-b>", "<Left>")
map("c", "<C-f>", "<Right>")
map("c", "<C-d>", "<Delete>")
map("c", "<C-k>", function()
  local line = vim.fn.getcmdline()
  local position = vim.fn.getcmdpos()
  vim.fn.setcmdline(line:sub(1, position - 1))
end)
map("c", "<M-f>", "<C-Right>")
map("c", "<M-b>", "<C-Left>")
map("c", "<M-d>", "<C-Right><C-w>")
