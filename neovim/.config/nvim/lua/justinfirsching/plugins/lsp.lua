local has_lsp, lspconfig = pcall(require, 'lspconfig')
if not has_lsp then
    return nil
end

local M = {}

M.servers = {
    bashls = true,
    clangd = true,
    cmake = true,
    cssls = true,
    dockerls = true,
    gopls = true,
    html = true,
    jdtls = true,
    jsonls = true,
    kotlin_language_server = true,
    pylsp = true,
    rust_analyzer = true,
    sqlls = true,
    sumneko_lua = false,
    tailwindcss = true,
    texlab = true,
    tsserver = true,
    yamlls = true,
}

local on_attach = function(_, bufnr)
  local opts = { noremap=true, silent=true }
  local buf_set_keymap = function(key, func) vim.api.nvim_buf_set_keymap(bufnr, 'n', key, func, opts) end
  buf_set_keymap('<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
  buf_set_keymap('<leader>D', '<cmd>lua vim.lsp.buf.declaration()<CR>')
  buf_set_keymap('<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>')
  buf_set_keymap('<leader>f', '<cmd>lua vim.lsp.buf.format{ async = true }<CR>')
  buf_set_keymap('<leader>h', '<cmd>lua vim.lsp.buf.hover()<CR>')
  buf_set_keymap('<leader>i', '<cmd>lua vim.lsp.buf.implementation()<CR>')
  buf_set_keymap('<leader>n', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
  buf_set_keymap('<leader>p', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
  buf_set_keymap('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
  buf_set_keymap('<leader>rr', '<cmd>lua vim.lsp.buf.references()<CR>')
  buf_set_keymap('<leader>sd', '<cmd>lua vim.diagnostic.open_float()<CR>')
  buf_set_keymap('<leader>sh', '<cmd>lua vim.lsp.buf.signature_help()<CR>')

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

M.setup_server = function(server, config)
  if not config then
    return
  end

  if type(config) ~= "table" then
    config = {}
  end

  config = vim.tbl_deep_extend("force", {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
  }, config)

  lspconfig[server].setup(config)
end

M.setup_servers = function()
    for server, config in pairs(M.servers) do
        M.setup_server(server, config)
    end
end

return M
