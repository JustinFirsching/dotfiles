return {
    'lewis6991/gitsigns.nvim', -- Git Indicate Line Changes
    opts = {
        signs = {
            add          = { text = '+' },
            change       = { text = '!' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '|' },
        },
    }
}
