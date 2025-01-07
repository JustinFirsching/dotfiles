-- Clear trailing whitespace on save
vim.api.nvim_create_autocmd({'BufWritePre'}, {
    pattern = { "*" },
    callback = function(ev)
        if vim.bo.filetype ~= 'markdown' then
            vim.api.nvim_command('%s/\\s\\+$//e')
        else
            -- Only replace trailing whitespace if it isn't exactly two spaces
            -- which is used to force a line break
            vim.api.nvim_command('%s/\\(\\S\\)\\s$/\\1/e')
            vim.api.nvim_command('%s/\\s\\{3,\\}$//e')
        end
    end
})

-- Load updates to Xresources
vim.api.nvim_create_autocmd({'BufWritePost'}, {
    pattern = { ".Xresources" },
    command = "silent !xrdb %"
})

-- Disable diagnostics in popup windows
vim.api.nvim_create_autocmd({'BufEnter'}, {
    pattern = { "*" },
    callback = function()
        if vim.bo.buftype == "nofile" then
            vim.diagnostic.enable(false)
        end
    end
})

-- Enable diagostics when leaving popup windows
vim.api.nvim_create_autocmd({'BufLeave'}, {
    pattern = { "*" },
    callback = function()
        if vim.bo.buftype == "nofile" then
            vim.diagnostic.enable(true)
        end
    end
})
