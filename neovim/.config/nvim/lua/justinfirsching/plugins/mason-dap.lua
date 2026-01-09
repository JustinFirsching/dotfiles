return {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
        "mason-org/mason.nvim",
        "mfussenegger/nvim-dap",
    },
    opts = {
        ensure_installed = {
            "python",   -- debugpy
            "delve",    -- Go debugger
            "codelldb", -- C/C++/Rust debugger
        },
        automatic_installation = true,
        handlers = {},
    },
}
