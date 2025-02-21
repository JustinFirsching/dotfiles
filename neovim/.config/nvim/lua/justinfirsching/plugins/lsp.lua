return {
    "neovim/nvim-lspconfig",
    dependencies = {
        'mfussenegger/nvim-jdtls',       -- Java LSP
        'seblj/roslyn.nvim',             -- C# LSP
        'nvim-telescope/telescope.nvim', -- File Finder
        'hrsh7th/cmp-nvim-lsp',          -- LSP Autocompletion
    },
    config = function()
        local lspconfig = require('lspconfig')
        local split_to_definition = function(split_cmd)
            vim.cmd(split_cmd)
            vim.cmd("wincmd w")
            vim.lsp.buf.definition()
        end

        local map_opts = { noremap = true, silent = true }
        local on_attach = function(_, bufnr)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, map_opts)
            vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, map_opts)
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, map_opts)
            vim.keymap.set("n", "<leader>gds", function() split_to_definition("split") end, map_opts)
            vim.keymap.set("n", "<leader>gdv", function() split_to_definition("vsplit") end, map_opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, map_opts)
            vim.keymap.set("n", "<leader>i", vim.lsp.buf.implementation, map_opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, map_opts)
            vim.keymap.set("n", "<leader>rr", vim.lsp.buf.references, map_opts)
            vim.keymap.set("n", "<leader>sd", vim.diagnostic.open_float, map_opts)
            vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, map_opts)
            vim.keymap.set({ "n", "i" }, "<M-k>", vim.lsp.buf.signature_help, map_opts)

            local has_telescope, builtin = pcall(require, 'telescope.builtin')
            if has_telescope then
                -- Find Document Symbols
                vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, map_opts)
                -- Find Project Symbols (This will probably run slow, lsp_opts)
                vim.keymap.set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, map_opts)
                -- Find Project Functions and Methods
                vim.keymap.set("n", "<leader>wf",
                    function() builtin.lsp_workspace_symbols { symbols = { "Function", "Method" } } end, map_opts)
                -- Find Project Classes, Enums and Structs
                vim.keymap.set("n", "<leader>wc",
                    function() builtin.lsp_workspace_symbols { symbols = { "Class", "Enum", "Struct" } } end, map_opts)
            end
        end

        local servers = {
            bashls = true,                 -- Bash
            clangd = true,                 -- C/C++
            cmake = true,                  -- CMake
            cssls = true,                  -- CSS
            dockerls = true,               -- Docker
            gopls = true,                  -- Golang
            html = true,                   -- HTML
            jdtls = true,                  -- Java
            jsonls = true,                 -- JSON
            kotlin_language_server = true, -- Kotlin
            pyright = true,                -- Python
            rust_analyzer = true,          -- Rust
            sqlls = true,                  -- SQL
            lua_ls = true,                 -- Lua
            tailwindcss = true,            -- Tailwind (CSS)
            texlab = true,                 -- TeX (LaTeX)
            ts_ls = true,                  -- TypeScript
            yamlls = true,                 -- YAML
        }

        local setup_server = function(server, config)
            if not config then
                return
            end

            if type(config) ~= "table" then
                config = {}
            end

            config = vim.tbl_deep_extend("force", {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                on_attach = on_attach,
            }, config)

            lspconfig[server].setup(config)
        end

        local setup_servers = function()
            for server, config in pairs(servers) do
                setup_server(server, config)
            end
        end

        setup_servers()

        -- Of course C# has to be special...
        local has_roslyn, roslyn = pcall(require, 'roslyn')
        if has_roslyn then
            roslyn.setup {
                exe = {
                    vim.fn.stdpath('data') .. "/mason/bin/roslyn"
                },
                config = {
                    on_attach = on_attach,
                    capabilities = require("cmp_nvim_lsp").default_capabilities(),
                }
            }
        end
    end
}
