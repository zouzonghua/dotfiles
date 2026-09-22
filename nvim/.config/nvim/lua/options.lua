-- Leader and core editor behavior.
vim.g.mapleader = ","

local opt = vim.opt

opt.number = true
opt.cursorline = true
opt.wrap = false
opt.mouse = "a"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.fillchars = { eob = " " }
opt.colorcolumn = "80"

-- Keep editing state useful across sessions.
vim.g.clipboard = "osc52"
opt.clipboard = "unnamedplus"
opt.undofile = true

-- Two spaces, no tabs.
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

-- Search without making case-sensitive work noisy.
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
