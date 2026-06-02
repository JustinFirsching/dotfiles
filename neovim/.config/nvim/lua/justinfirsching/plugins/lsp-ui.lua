return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("justinfirsching.lsp_ui").patch_open_floating_preview()
    end,
}
