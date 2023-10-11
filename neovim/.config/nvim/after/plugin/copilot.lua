local has_copilot, copilot = pcall(require, 'copilot')
if not has_copilot then
    return
end

copilot.setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
})

local has_copilot_cmp, copilot_cmp = pcall(require, 'copilot_cmp')
if not has_copilot_cmp then
    return
end

copilot_cmp.setup()
