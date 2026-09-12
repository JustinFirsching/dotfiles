vim.opt.autoindent = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.colorcolumn = '80'
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.incsearch = true
vim.opt.errorbells = false
vim.opt.swapfile = false
vim.opt.wrap = false
vim.opt.number = true
vim.opt.pumheight = 20
vim.opt.relativenumber = true
vim.opt.scrolloff = 3
vim.opt.shiftwidth = 4
vim.opt.showmatch = true
vim.opt.signcolumn = 'yes'
vim.opt.tabstop = 4
vim.opt.title = true

local function title_path(path)
    path = vim.fn.fnamemodify(path, ':p'):gsub('/$', '')
    local cwd = vim.fn.getcwd():gsub('/$', '')
    local cwd_prefix = cwd .. '/'

    if vim.startswith(path, cwd_prefix) then
        return path:sub(#cwd_prefix + 1)
    end

    return vim.fn.fnamemodify(path, ':~')
end

function _G.nvim_title()
    local fzf_lua = package.loaded["fzf-lua"]
    local fzf_win = fzf_lua and fzf_lua.win and fzf_lua.win.__SELF()

    if fzf_win then
        local query = fzf_lua.get_info().query
        return query and query ~= '' and 'nvim - ' .. query or 'nvim - fzf'
    end

    local path = vim.api.nvim_buf_get_name(0)
    return path == '' and 'nvim' or 'nvim - ' .. title_path(path)
end

vim.opt.titlestring = '%{v:lua.nvim_title()}'
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.updatetime = 50
vim.opt.laststatus = 2
vim.opt.showmode = false
vim.opt.hlsearch = false
vim.opt.completeopt = 'menu,menuone,noselect,noinsert,preview'
vim.opt.mouse = 'a'
vim.opt.winborder = 'rounded'
