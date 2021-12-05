local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local Path = require('plenary.path')
local os_sep = Path.path.sep

local create_new_file = function(prompt_bufnr)
  local is_dir = function(value)
    return value:sub(-1, -1) == os_sep
  end

  local file = action_state.get_current_line()
  if file == "" then
    print(
      "To create a new file or directory(add "
        .. os_sep
        .. " at the end of file) "
        .. "write the desired new into the prompt and press <C-e>. "
        .. "It works for not existing nested input as well."
        .. "Example: this"
        .. os_sep
        .. "is"
        .. os_sep
        .. "a"
        .. os_sep
        .. "new_file.lua"
    )
    return
  end

  actions.close(prompt_bufnr)
  if not is_dir(file) then
    Path:new(file):touch { parents = true }
    vim.cmd(string.format(":edit %s", file))
  else
    Path:new(file:sub(1, -2)):mkdir { parents = true }
    vim.cmd(string.format(":Explore %s", file))
  end
end

require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-e>"] = create_new_file,
        ["<C-c>"] = false,
      },
      n = {
        ["<C-c>"] = actions.close,
        ["<C-e>"] = create_new_file,
      }
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden"
    }
  },
  pickers = {
    find_files = {
      hidden = true
    },
  }
}
