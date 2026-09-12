local opt = vim.opt

opt.number = true
opt.cursorline = true
opt.wrap = false
opt.mouse = "a"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.fillchars = { eob = " " }
opt.colorcolumn = "80"

vim.g.clipboard = "osc52"
opt.clipboard = "unnamedplus"
opt.undofile = true

opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
