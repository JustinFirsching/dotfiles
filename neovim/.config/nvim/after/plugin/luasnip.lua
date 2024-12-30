local has_luasnip, from_vscode = pcall(require, 'luasnip.loaders.from_vscode')
if not has_luasnip then
    return
end
from_vscode.lazy_load()
