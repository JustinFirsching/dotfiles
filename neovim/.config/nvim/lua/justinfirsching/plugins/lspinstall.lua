local lspinstall = require('lspinstall')

local languages = {
    'bash',
    'cpp',
    'css',
    'dockerfile',
    'go',
    'html',
    'java',
    'json',
    'kotlin',
    'latex',
    'lua',
    'python',
    'rust',
    'tailwindcss',
    'typescript',
    'yaml',
}

local install_servers = function()
    for _, lang in ipairs(languages) do lspinstall.install_server(lang) end
end

return {install_servers = install_servers}
