return {
    'zbirenbaum/copilot.lua', -- Copilot
    event = "InsertEnter",
    opts = {
        suggestion = { enabled = false },
        panel = { enabled = false },
        filetypes = {
            markdown = true,
            sh = function()
                return string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') == nil
            end
        }
    }
}
