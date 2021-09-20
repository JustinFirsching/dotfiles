local has_lsp, lspconfig = pcall(require, 'lspconfig')
if not has_lsp then
    return
end
local lspinstall = require'lspinstall'

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, 'n', ...) end

  local opts = { noremap=true, silent=true }

  -- Code Navigation
  buf_set_keymap('<leader>vd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('<leader>vi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('<leader>vsh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('<leader>vrr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('<leader>vrn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('<leader>vh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('<leader>vca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('<leader>vsd', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('<leader>vn', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
end

local function setup_servers()
  lspinstall.setup()
  local servers = lspinstall.installed_servers()
  for _, server in pairs(servers) do
    require'lspconfig'[server].setup{
      on_attach = on_attach,
      flags = {
        debounce_text_changes = 150,
      },
      capabilities = require('cmp_nvim_lsp').update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )
    }
  end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
lspinstall.post_install_hook = function ()
  setup_servers() -- reload installed servers
  vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end
