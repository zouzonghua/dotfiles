-- Keep Normal mode commands independent from the active input method.
local macism = vim.fn.exepath("macism")

if macism == "" then
  return
end

local normal_ime = "com.apple.keylayout.US"
local insert_ime = vim.fn.system({ macism }):gsub("%s+$", "")

local function set_ime(input_source)
  if input_source ~= "" then
    vim.fn.system({ macism, input_source })
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    insert_ime = vim.fn.system({ macism }):gsub("%s+$", "")
    set_ime(normal_ime)
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    set_ime(insert_ime)
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    insert_ime = vim.fn.system({ macism }):gsub("%s+$", "")
    set_ime(normal_ime)
  end,
})
