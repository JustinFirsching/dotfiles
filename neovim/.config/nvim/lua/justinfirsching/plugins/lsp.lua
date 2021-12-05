local has_lsp, lspconfig = pcall(require, 'lspconfig')
if not has_lsp then
    return nil
end
local lsp_installer = require('nvim-lsp-installer')
local installer_servers = require('nvim-lsp-installer.servers')

local M = {}

M.servers = {
    'ansiblels',
    'bashls',
    'clangd',
    'cmake',
    'cssls',
    'dockerls',
    'gopls',
    'html',
    'jdtls',
    'jsonls',
    'kotlin_language_server',
    'texlab',
    'sumneko_lua',
    'pylsp',
    'rust_analyzer',
    'sqlls',
    'tailwindcss',
    'tsserver',
    'yamlls',
}

local on_attach = function(_, bufnr)
  local opts = { noremap=true, silent=true }
  local buf_set_keymap = function(key, func) vim.api.nvim_buf_set_keymap(bufnr, 'n', key, func, opts) end
  buf_set_keymap('<leader>vca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
  buf_set_keymap('<leader>vD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
  buf_set_keymap('<leader>vd', '<cmd>lua vim.lsp.buf.definition()<CR>')
  buf_set_keymap('<leader>vf', '<cmd>lua vim.lsp.buf.formatting_sync()<CR>')
  buf_set_keymap('<leader>vh', '<cmd>lua vim.lsp.buf.hover()<CR>')
  buf_set_keymap('<leader>vi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
  buf_set_keymap('<leader>vn', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
  buf_set_keymap('<leader>vp', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
  buf_set_keymap('<leader>vrn', '<cmd>lua vim.lsp.buf.rename()<CR>')
  buf_set_keymap('<leader>vrr', '<cmd>lua vim.lsp.buf.references()<CR>')
  buf_set_keymap('<leader>vsd', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
  buf_set_keymap('<leader>vsh', '<cmd>lua vim.lsp.buf.signature_help()<CR>')

  local has_telescope, _ = pcall(require, 'telescope')
  if has_telescope then
    -- Find Document Symbols
    buf_set_keymap('<leader>vds', '<cmd>Telescope lsp_document_symbols<CR>')
    -- Find Project Symbols (This will probably run slow)
    buf_set_keymap('<leader>vps', '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>')
    -- Find Project Functions and Methods
    buf_set_keymap('<leader>vpf', "<cmd>lua require('telescope.builtin').lsp_workspace_symbols{ symbols={'Function', 'Method'} }<CR>")
    -- Find Project Classes, Enums and Structs
    buf_set_keymap('<leader>vpc', "<cmd>lua require('telescope.builtin').lsp_workspace_symbols{ symbols={'Class', 'Enum', 'Struct'} }<CR>")
  end
end

lsp_installer.on_server_ready(function(server)
  local config = {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = vim.lsp.protocol.make_client_capabilities()
  }
  server:setup(config)
  vim.cmd [[ do User LspAttachBuffers ]]
end)

M.install = function(install_targets)
    local install_servers = install_targets or M.servers
    -- If in headless mode, run blocking
    if #(vim.api.nvim_list_uis()) == 0 then
        lsp_installer.install_sync(install_servers)
    else
        for _, servername in ipairs(install_servers) do
            lsp_installer.install(servername)
        end
    end
end

M.install_missing = function()
    local missing = {}
    for _, server_name in ipairs(M.servers) do
        local ok, server = installer_servers.get_server(server_name)
        if ok and not server:is_installed() then
              table.insert(missing, server.name)
        end
    end
    M.install(missing)
end

return M
