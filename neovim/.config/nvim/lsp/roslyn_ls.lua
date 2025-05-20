return {
    cmd = {
        vim.fn.stdpath('data') .. "/mason/bin/roslyn"
    },
    handlers = {
        ["razor/provideDynamicFileInfo"] = function(_, _, _)
            -- This is just to mute out the Roslyn vim.notify
            return vim.NIL
        end
    }
}
