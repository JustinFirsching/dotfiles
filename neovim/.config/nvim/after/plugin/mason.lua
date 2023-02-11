local has_mason, mason = pcall(require, 'mason')
if not has_mason then
    return
end
mason.setup()

local has_mason_lspconfig, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not has_mason_lspconfig then
    return
end
mason_lspconfig.setup()
