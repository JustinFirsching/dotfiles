local has_lsp, lspconfig = pcall(require, 'lspconfig')
if not has_lsp then
    return nil
end

local lsp_signature_config = {
    hint_prefix = '',
    -- This is annoying... inline text should be for errors only
    hint_inline = function() return false end,
    handler_opts = {
        border = 'none'
    },
    select_signature_key = '<C-n>',
}

local split_to_definition = function(split_cmd)
    vim.cmd(split_cmd)
    vim.cmd("wincmd w")
    vim.lsp.buf.definition()
end

local lsp_opts = { noremap=true, silent=true }
local on_attach = function(_, bufnr)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, lsp_opts)
  vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, lsp_opts)
  vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, lsp_opts)
  vim.keymap.set("n", "<leader>gds", function() split_to_definition("split") end, lsp_opts)
  vim.keymap.set("n", "<leader>gdv", function() split_to_definition("vsplit") end, lsp_opts)
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

local servers = {
    bashls = true, -- Bash
    clangd = true, -- C/C++
    cmake = true, -- CMake
    cssls = true, -- CSS
    dockerls = true, -- Docker
    gopls = true, -- Golang
    html = true, -- HTML
    jdtls = true, -- Java
    jsonls = true, -- JSON
    kotlin_language_server = true, -- Kotlin
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
    }, -- C#
    pyright = true, -- Python
    rust_analyzer = true, -- Rust
    sqlls = true, -- SQL
    lua_ls = true, -- Lua
    tailwindcss = true, -- Tailwind (CSS)
    texlab = true, -- TeX (LaTeX)
    ts_ls = true, -- TypeScript
    yamlls = true, -- YAML
}

local setup_server = function(server, config)
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

local setup_servers = function()
    for server, config in pairs(servers) do
        setup_server(server, config)
    end
end

setup_servers()
