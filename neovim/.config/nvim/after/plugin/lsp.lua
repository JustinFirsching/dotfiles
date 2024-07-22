local has_lsp, lspconfig = pcall(require, 'lspconfig')
if not has_lsp then
    return nil
end

lsp_signature_config = {
    hint_prefix = '',
    -- This is annoying... inline text should be for errors only
    hint_inline = function() return false end,
    handler_opts = {
        border = 'none'
    },
    select_signature_key = '<C-n>',
}

local lsp_opts = { noremap=true, silent=true }
local on_attach = function(_, bufnr)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, lsp_opts)
  vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, lsp_opts)
  vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, lsp_opts)
  vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format{ async = true } end, lsp_opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, lsp_opts)
  vim.keymap.set("n", "<leader>i", vim.lsp.buf.implementation, lsp_opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, lsp_opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, lsp_opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, lsp_opts)
  vim.keymap.set("n", "<leader>rr", vim.lsp.buf.references, lsp_opts)
  vim.keymap.set("n", "<leader>sd", vim.diagnostic.open_float, lsp_opts)
  vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, lsp_opts)

  local has_telescope, builtin = pcall(require, 'telescope.builtin')
  if has_telescope then
    -- Find Document Symbols
    vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, lsp_opts)
    -- Find Project Symbols (This will probably run slow, lsp_opts)
    vim.keymap.set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, lsp_opts)
    -- Find Project Functions and Methods
    vim.keymap.set("n", "<leader>wf", function() builtin.lsp_workspace_symbols{ symbols={"Function", "Method"} } end, lsp_opts)
    -- Find Project Classes, Enums and Structs
    vim.keymap.set("n", "<leader>wc", function() builtin.lsp_workspace_symbols{ symbols={"Class", "Enum", "Struct"} } end, lsp_opts)
  end

  local has_lsp_signature, lsp_signature = pcall(require, 'lsp_signature')
  if has_lsp_signature then
      lsp_signature.on_attach(lsp_signature_config, bufnr)
  end
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
    omnisharp = {
        cmd = {
            "omnisharp"
            -- "dotnet",
            -- os.getenv("HOME") .. "/.local/share/nvim/mason/packages/omnisharp/libexec/OmniSharp.dll"
        },
        on_attach = function(client, bufnr)
            -- Do the default on_attach
            on_attach(client, bufnr)

            -- Then fix the keymaps
            local has_omnisharp, omnisharp_extended = pcall(require, 'omnisharp_extended')
            if has_omnisharp then
                vim.keymap.set("n", "<leader>gd", omnisharp_extended.lsp_definition, lsp_opts)
                vim.keymap.set("n", "<leader>i", omnisharp_extended.lsp_implementation, lsp_opts)
                vim.keymap.set("n", "<leader>rr", omnisharp_extended.lsp_references, lsp_opts)
            end
        end,
    },
    pyright = true,
    rust_analyzer = true,
    sqlls = true,
    lua_ls = true,
    tailwindcss = true,
    texlab = true,
    tsserver = true,
    yamlls = true,
}

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
