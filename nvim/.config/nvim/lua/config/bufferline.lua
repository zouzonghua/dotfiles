local map = vim.keymap.set

local function close_current_buffer()
  local current_buffer = vim.api.nvim_get_current_buf()

  vim.cmd("BufferLineCycleNext")

  if vim.api.nvim_get_current_buf() == current_buffer then
    vim.cmd("BufferLineCyclePrev")
  end

  vim.cmd("bdelete " .. current_buffer)
end

require("bufferline").setup({
  options = {
    mode = "buffers",
    numbers = "ordinal",
    separator_style = "thick",
    diagnostics = "nvim_lsp",
    buffer_close_icon = "×",
    show_close_icon = false,
    always_show_bufferline = true,
    custom_filter = function(bufnr)
      local name = vim.api.nvim_buf_get_name(bufnr)
      return name ~= "" or vim.bo[bufnr].modified
    end,
    offsets = {
      {
        filetype = "NvimTree",
        text = "",
        text_align = "center",
        highlight = "NvimTreeNormal",
      },
    },
  },
  highlights = {
    fill = {
      bg = {
        attribute = "bg",
        highlight = "StatusLine",
      },
    },
  },
})

-- Bufferline navigation.
map("n", "<C-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
map("n", "<C-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<C-c>", close_current_buffer, { desc = "Close current buffer" })
map("n", "<leader>hh", "<cmd>BufferLineCloseLeft<CR>", { desc = "Close buffers to the left" })
map("n", "<leader>ll", "<cmd>BufferLineCloseRight<CR>", { desc = "Close buffers to the right" })
