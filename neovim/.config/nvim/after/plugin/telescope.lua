local has_telescope, _ = pcall(require, 'telescope')
if not has_telescope then
    return
end

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

local delete_file = function(prompt_bufnr)
    local function delete_up(path)
        if path:is_dir() then
            local dir_was_empty, _ = pcall(function(p)
                Path:new(p):rmdir()
            end, path:absolute())
            -- If the directory wasn't empty, stop recursing
            if not dir_was_empty then return end
        else
            path:rm()
        end

        local parent = path:parent()
        delete_up(parent)
    end

    local picker = action_state.get_current_picker(prompt_bufnr)
    local file = picker:get_selection()
    if file == "" then
        return
    end

    actions.close(prompt_bufnr)
    delete_up(Path:new(file))
end

require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-c>"] = false,
        ["<C-e>"] = create_new_file,
        ["<C-d>"] = delete_file,
      },
      n = {
        ["<C-c>"] = actions.close,
        ["<C-e>"] = create_new_file,
        ["<C-d>"] = delete_file,
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
      "--hidden",
      "-g!.git",
      "-g!.venv"
    }
  },
  pickers = {
    find_files = {
      find_command = {
          "fd",
          "-L",
          "-t",
          "f",
          "--hidden",
          "--exclude",
          ".git",
          "--exclude",
          ".venv"
      }
    },
  }
}

-- Keybinds
vim.keymap.set('n', '<leader>rf', '<cmd>Telescope find_files<CR>')
vim.keymap.set('n', '<leader>rb', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', '<leader>ro', '<cmd>Telescope oldfiles<CR>')
vim.keymap.set('n', '<leader>ps', '<cmd>Telescope live_grep<CR>')
