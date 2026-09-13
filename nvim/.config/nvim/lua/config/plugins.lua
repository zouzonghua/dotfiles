vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(event)
    local data = event.data
    if data.spec.name ~= "markdown-preview.nvim" or (data.kind ~= "install" and data.kind ~= "update") then
      return
    end

    if vim.fn.executable("npx") ~= 1 then
      vim.notify("markdown-preview.nvim requires npx to install dependencies", vim.log.levels.WARN)
      return
    end

    local result = vim.system({ "npx", "--yes", "yarn@1.22.22", "install", "--frozen-lockfile" }, { cwd = data.path .. "/app" }):wait()
    if result.code ~= 0 then
      error("Failed to install markdown-preview.nvim dependencies:\n" .. result.stderr)
    end
  end,
})

vim.pack.add({
  { src = "https://github.com/ellisonleao/gruvbox.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/akinsho/bufferline.nvim" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/nvim-tree/nvim-tree.lua" },
  { src = "https://github.com/iamcco/markdown-preview.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/sindrets/diffview.nvim" },
}, { confirm = false })
