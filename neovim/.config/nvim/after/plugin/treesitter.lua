local has_treesitter, treesitter_configs = pcall(require, 'nvim-treesitter.configs')
if not has_treesitter then
    return
end

treesitter_configs.setup {
  ensure_installed = {
      "bash",
      "bibtex",
      "c",
      "cmake",
      "cpp",
      "css",
      "dart",
      "dockerfile",
      "go",
      "html",
      "java",
      "javascript",
      "jsdoc",
      "json",
      "json5",
      "jsonc",
      "kotlin",
      "latex",
      "make",
      "python",
      "r",
      "regex",
      "ruby",
      "rust",
      "scala",
      "scss",
      "svelte",
      "toml",
      "tsx",
      "typescript",
      "yaml",
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
