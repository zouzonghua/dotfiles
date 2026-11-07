local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local lspconfig = require("lspconfig")

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

local servers = {
  ts_ls = {},
  cssls = {},
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },
}

mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers),
  handlers = {
    function(server_name)
      local config = servers[server_name] or {}
      lspconfig[server_name].setup(config)
    end,
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(event)
    local map = vim.keymap.set
    local bufnr = event.buf

    map("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
    map("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
    map("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover documentation" })
    map("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to implementation" })

    local has_telescope, builtin = pcall(require, "telescope.builtin")
    if has_telescope then
      map("n", "gr", builtin.lsp_references, { buffer = bufnr, desc = "Find references" })
    else
      map("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "Find references" })
    end

    map("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code actions" })
    map("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Previous diagnostic" })
    map("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Next diagnostic" })
  end,
})
