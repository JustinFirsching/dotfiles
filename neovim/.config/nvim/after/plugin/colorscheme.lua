vim.cmd.colorscheme("gruvbox")
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.g.gruvbox_contrast_dark = "hard"

local hl_opts = { bg = "none", ctermbg = "none" }
vim.api.nvim_set_hl(0, "Normal", hl_opts)
