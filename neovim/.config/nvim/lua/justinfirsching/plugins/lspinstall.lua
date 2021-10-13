local lsp_servers = require('nvim-lsp-installer.servers')

local language_servers = {
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

local install_servers = function()
    done_installing = 0
    for _, lang in ipairs(language_servers) do
        local ok, server = lsp_servers.get_server(lang)
        if ok then
            if not server:is_installed() then
                server:install_attached({
                        stdio_sink = {
                            stdout = function(chunk) io.write(chunk) end,
                            stderr = function(chunk) io.stderr:write(chunk) end,
                        },
                    }, function(success)
                        done_installing = done_installing + 1
                    end)
            else
                done_installing = done_installing + 1
            end
        end
    end
    while not done_installing == #(language_servers) do
        -- Wait until the last server is done installing
    end
end

return {install_servers = install_servers}
