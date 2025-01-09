return {
    'williamboman/mason.nvim',               -- External Tool Installer
    dependencies = {
        'williamboman/mason-lspconfig.nvim', -- LSP Installer
    },
    opts = {
        registries = {
            "github:mason-org/mason-registry",
            "github:Crashdummyy/mason-registry",
        },
        ensure_installed = {
            -- LSP
            "gopls",               -- Go LSP
            "pyright",             -- Python LSP
            "lua-language-server", -- Lua
            -- Lint
            "golangci-lint",
            "markdownlint",
            "jsonlint",
            "yamllint",
        },
    },
}
