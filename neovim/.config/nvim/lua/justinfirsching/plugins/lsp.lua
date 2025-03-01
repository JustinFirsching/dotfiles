return {
    "neovim/nvim-lspconfig",
    dependencies = {
        'mfussenegger/nvim-jdtls',           -- Java LSP
        'seblj/roslyn.nvim',                 -- C# LSP
        'nvim-telescope/telescope.nvim',     -- Searcher
        'hrsh7th/cmp-nvim-lsp',              -- LSP Autocompletion
        'williamboman/mason.nvim',           -- External Tool Installer
        'williamboman/mason-lspconfig.nvim', -- LSP Installer
    },
    config = function()
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities()
        )
        require("mason-lspconfig").setup({
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities,
                    }
                end,
            }
        })

        require("roslyn").setup {
            exe = {
                vim.fn.stdpath('data') .. "/mason/bin/roslyn"
            },
            config = {
                capabilities = capabilities,
                handlers = {
                    ["razor/provideDynamicFileInfo"] = function(_, _, _)
                        -- This is just to mute out the Roslyn vim.notify
                        return vim.NIL
                    end
                }
            }
        }
    end
}
