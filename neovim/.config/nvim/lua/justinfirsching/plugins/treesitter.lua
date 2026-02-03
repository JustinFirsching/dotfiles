return {
    'nvim-treesitter/nvim-treesitter',
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })()
    end,
    config = function()
        require("nvim-treesitter").setup({
            sync_install = false,
            auto_install = true,
            ensure_installed = {
                "bash",
                "c",
                "c_sharp",
                "cmake",
                "cpp",
                "css",
                "dockerfile",
                "go",
                "html",
                "java",
                "javascript",
                "json",
                "jsonc",
                "kotlin",
                "lua",
                "make",
                "markdown",
                "python",
                "toml",
                "tsx",
                "typescript",
                "yaml",
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        })
    end
}
