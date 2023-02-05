local has_lsp, lspconfig = pcall(require, 'lspconfig')
if not has_lsp then
    return nil
end

servers = {
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
    pyright = true,
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
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format{ async = true } end, opts)
  vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>i", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<leader>n", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>p", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>rr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>sd", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts)

  local has_telescope, builtin = pcall(require, 'telescope.builtin')
  if has_telescope then
    -- Find Document Symbols
    vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, opts)
    -- Find Project Symbols (This will probably run slow, opts)
    vim.keymap.set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, opts)
    -- Find Project Functions and Methods
    vim.keymap.set("n", "<leader>wf", function() builtin.lsp_workspace_symbols{ symbols={"Function", "Method"} } end, opts)
    -- Find Project Classes, Enums and Structs
    vim.keymap.set("n", "<leader>wc", function() builtin.lsp_workspace_symbols{ symbols={"Class", "Enum", "Struct"} } end, opts)
  end
end

setup_server = function(server, config)
  if not config then
    return
  end

  if type(config) ~= "table" then
    config = {}
  end

  config = vim.tbl_deep_extend("force", {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = on_attach,
  }, config)

  lspconfig[server].setup(config)
end

setup_servers = function()
    for server, config in pairs(servers) do
        setup_server(server, config)
    end
end

setup_servers()
