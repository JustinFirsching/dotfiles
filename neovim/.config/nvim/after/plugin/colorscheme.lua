local function set_gruvbox()
    vim.g.gruvbox_contrast_dark = "hard"
    vim.g.gruvbox_transparent_bg = true
    vim.cmd.colorscheme("gruvbox")
end

local has_gruvbox = pcall(set_gruvbox)
if not has_gruvbox then
    vim.cmd.colorscheme("habamax")
end

vim.opt.termguicolors = true
vim.opt.background = "dark"

local hl_opts = { bg = "none", ctermbg = "none" }
vim.api.nvim_set_hl(0, "Normal", hl_opts)
