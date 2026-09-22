vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("options")
require("plugins")
require("ime")

require("plugins.colorscheme")
require("plugins.gitsigns")
require("plugins.markdown-preview")
require("plugins.diffview")
require("plugins.bufferline")
require("plugins.lualine")
require("plugins.nvim-tree")

require("keymaps")
