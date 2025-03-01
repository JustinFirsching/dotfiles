return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "BurntSushi/ripgrep",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        local Path = require("plenary.path")
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

        telescope.setup {
            defaults = {
                layout_strategy = "vertical",
                mappings = {
                    i = {
                        ["<C-c>"] = false,
                    },
                    n = {
                        ["<C-c>"] = actions.close,
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
                        "node_modules",
                        "--exclude",
                        ".venv"
                    },
                    mappings = {
                        i = {
                            ["<C-e>"] = create_new_file,
                            ["<C-x>"] = delete_file,
                        },
                        n = {
                            ["<C-e>"] = create_new_file,
                            ["<C-x>"] = delete_file,
                        }
                    }
                },
            }
        }

        telescope.load_extension("fzf")

        -- Keybinds
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>rf", builtin.find_files)
        vim.keymap.set("n", "<leader>rb", builtin.buffers)
        vim.keymap.set("n", "<leader>ro", builtin.oldfiles)
        vim.keymap.set("n", "<leader>ps", builtin.live_grep)
        vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols)
        vim.keymap.set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols)
        vim.keymap.set("n", "<leader>gd", builtin.lsp_definitions)
        vim.keymap.set("n", "<leader>rr", builtin.lsp_references)
        vim.keymap.set("n", "<leader>i", builtin.lsp_implementations)
        vim.keymap.set("n", "<leader>wtf", function() print(vim.lsp.get_clients()[1].offset_encoding) end)
    end
}
