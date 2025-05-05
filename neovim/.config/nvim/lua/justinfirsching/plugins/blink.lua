return {
    {
        'saghen/blink.cmp',
        dependencies = {
            'rafamadriz/friendly-snippets',
            'giuxtaposition/blink-cmp-copilot',
        },

        version = '1.*',

        opts = {
            keymap = {
                -- Enter to accept, but tab to accept the first completion without selection
                preset = 'enter',
                ['<Tab>'] = { 'accept', function(cmp) cmp.accept({ index = 1 }) end, 'fallback' },
            },
            appearance = {
                -- nerd_font_variant = '',
                kind_icons = {
                    Copilot = "", -- Copilot robot icon next to copilot suggestions
                },
            },
            -- (Default) Only show the documentation popup when manually triggered
            completion = {
                -- Show documentation immediately
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 0,
                },
                -- Don't select anything from the completions list by default
                list = {
                    selection = {
                        preselect = false,
                        auto_insert = false,
                    },
                },
                -- Disable auto brackets
                accept = { auto_brackets = { enabled = false } },
                ghost_text = { enabled = false },
                menu = {
                    draw = {
                        columns = {
                            { "label",     "label_description", gap = 1 },
                            { "kind_icon", "kind",              gap = 1 },
                        },
                    },
                },
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
                providers = {
                    copilot = {
                        name = 'copilot',
                        module = 'blink-cmp-copilot',
                        score_offset = 100,
                        async = true,
                    },
                    cmdline = {
                        -- ignores cmdline completions when executing shell commands
                        enabled = function()
                            return vim.fn.getcmdtype() ~= ':' or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
                        end,
                    },
                },
            },
            signature = { enabled = true },
        },
        opts_extend = { "sources.default" },
    }
}
