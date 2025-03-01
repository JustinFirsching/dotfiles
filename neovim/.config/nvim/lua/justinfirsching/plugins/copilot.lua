return {
    'zbirenbaum/copilot.lua',     -- Copilot
    dependencies = {
        'zbirenbaum/copilot-cmp', -- Copilot Completions
    },
    event = "InsertEnter",
    opts = {
        suggestion = { enabled = false },
        panel = { enabled = false },
    }
}
