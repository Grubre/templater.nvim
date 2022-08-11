if vim.g.loaded_templator == 1 then
  return
end
vim.g.loaded_templator = 1

vim.api.nvim_create_user_command("Sub", function ()
    require("templator").sub()
end,{nargs = "*"})

