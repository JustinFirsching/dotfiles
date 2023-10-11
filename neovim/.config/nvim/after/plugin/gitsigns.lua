has_gitsigns, gitsigns = pcall(require, 'gitsigns')
if not has_gitsigns then
    return nil
end

gitsigns.setup {
  signs = {
    add          = { text = '+' },
    change       = { text = '!' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '|' },
  },
}
