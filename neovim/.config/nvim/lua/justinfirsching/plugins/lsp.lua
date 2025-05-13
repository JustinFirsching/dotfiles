return {
    "neovim/nvim-lspconfig",
    dependencies = {
        'mfussenegger/nvim-jdtls',           -- Java LSP
        'seblj/roslyn.nvim',                 -- C# LSP
        'williamboman/mason.nvim',           -- External Tool Installer
        'williamboman/mason-lspconfig.nvim', -- LSP Installer
        'saghen/blink.cmp',                  -- Completions
    },
    config = function()
        require("mason-lspconfig").setup_handlers {
            function(server_name)
                require("lspconfig")[server_name].setup {
                    capabilities = vim.lsp.protocol.make_client_capabilities(),
                }
            end,
            ["basedpyright"] = function()
                require("lspconfig").basedpyright.setup {
                    capabilities = vim.lsp.protocol.make_client_capabilities(),
                    settings = {
                        basedpyright = {
                            analysis = {
                                typeCheckingMode = "basic" -- Parity with VS Code
                            },
                        },
                    },
                }
            end
        }

        require("roslyn").setup {
            cmd = {
                vim.fn.stdpath('data') .. "/mason/bin/roslyn"
            },
            config = {
                capabilities = vim.lsp.protocol.make_client_capabilities(),
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
