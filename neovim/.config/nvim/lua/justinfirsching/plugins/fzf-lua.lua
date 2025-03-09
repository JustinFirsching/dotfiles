return {
    "ibhagwan/fzf-lua",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local fzf_lua = require("fzf-lua")
        local utils = require("justinfirsching.utils")
        fzf_lua.setup({
            files = {
                actions = {
                    ["ctrl-e"] = {
                        fn = function(_, opts)
                            local filepath = opts.last_query

                            if type(filepath) ~= "string" or #filepath == 0 then
                                vim.notify("File name cannot be empty", vim.log.levels.ERROR, {})
                                return
                            end

                            utils.create_file(filepath)
                        end,
                        field_index = "{q}",
                        reload = true,
                    },
                    ["ctrl-x"] = {
                        fn = function(selected)
                            local filepath = selected[1]

                            if type(filepath) ~= "string" or #filepath == 0 then
                                vim.notify("File name cannot be empty", vim.log.levels.ERROR, {})
                                return
                            end

                            utils.delete_file(filepath)
                        end,
                        reload = true,
                    },
                },
                hidden = true,
                no_ignore = false,
            },
            buffers = {
                ignore_current_buffer = true,
                sort_lastused = true,
            },
            grep = {
                rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -g !.git -e",
                hidden = true,
                no_ignore = false,
            },
            oldfiles = {
                cwd_only = false,
                include_current_session = true,
            },
        })

        local map_key = require("justinfirsching.utils").map_key
        map_key("n", "<leader>rf", fzf_lua.files)
        map_key("n", "<leader>rb", fzf_lua.buffers)
        map_key("n", "<leader>ro", fzf_lua.oldfiles)
        map_key("n", "<leader>ps", fzf_lua.live_grep_native)
        map_key("n", "<leader>prs", fzf_lua.live_grep_resume)
        map_key("n", "<leader>ds", fzf_lua.lsp_document_symbols)
        map_key("n", "<leader>ws", fzf_lua.lsp_live_workspace_symbols)
        map_key("n", "<leader>gd", fzf_lua.lsp_definitions)
        map_key("n", "<leader>rr", fzf_lua.lsp_references)
        map_key("n", "<leader>i", fzf_lua.lsp_implementations)
        map_key("n", "<leader>ci", fzf_lua.lsp_incoming_calls)
        map_key("n", "<leader>ci", fzf_lua.lsp_outgoing_calls)
    end
}
