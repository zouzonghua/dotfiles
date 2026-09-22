-- Keep Normal mode commands independent from the active input method.
if vim.fn.has("mac") ~= 1 then
  return
end

local macism = vim.fn.exepath("macism")

if macism == "" then
  return
end

local normal_ime = "com.apple.keylayout.US"
local insert_ime = vim.fn.system({ macism }):gsub("%s+$", "")
local focused_ime = insert_ime

local function current_ime()
  return vim.fn.system({ macism }):gsub("%s+$", "")
end

local function set_ime(input_source)
  if input_source ~= "" then
    vim.fn.system({ macism, input_source })
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    insert_ime = current_ime()
    focused_ime = insert_ime
    set_ime(normal_ime)
  end,
})

-- Neovim uses US input while focused; restore the previous input source outside.
vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    local input_source = current_ime()
    if input_source ~= normal_ime then
      focused_ime = input_source
    end
    set_ime(normal_ime)
  end,
})

vim.api.nvim_create_autocmd("FocusLost", {
  callback = function()
    local input_source = current_ime()
    if input_source ~= normal_ime then
      focused_ime = input_source
    end
    set_ime(focused_ime)
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    set_ime(insert_ime)
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    insert_ime = current_ime()
    set_ime(normal_ime)
  end,
})

-- Escape is a manual reset for Normal mode.
vim.keymap.set("n", "<Esc>", function()
  set_ime(normal_ime)
end, { desc = "Reset input method" })
