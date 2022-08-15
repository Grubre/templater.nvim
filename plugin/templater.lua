if vim.g.loaded_templator == 1 then
  return
end
vim.g.loaded_templator = 1

vim.api.nvim_create_user_command("Templater", function (args)
    if args.fargs[1]=='sub' then
        require("templater").sub()
    elseif args.fargs[1]=='template' then
        local func_args = {unpack(args.fargs,3)}
        if args.fargs[2]=='add' then
            require("templater").add_template(func_args)
        elseif args.fargs[2]=='use' then
            require("templater").use_template(func_args)
        elseif args.fargs[2]=='remove' then
            require("templater").remove_template(func_args)
        end
    end
end,{nargs = "*"})

