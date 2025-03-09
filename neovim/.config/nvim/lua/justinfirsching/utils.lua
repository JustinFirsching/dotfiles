local M = {}

M.map_key = function(modes, lhs, rhs, opts)
    opts = opts or { noremap = true, silent = true }
    vim.keymap.set(modes, lhs, rhs, opts)
end

M.delete_file = function(filepath)
    local Path = require("plenary.path")

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
    delete_up(Path:new(filepath))
end

M.create_file = function(filepath)
    local Path = require("plenary.path")

    local is_directory = function(value)
        return value:sub(-1, -1) == Path.path.sep
    end

    if is_directory(filepath) then
        Path:new(filepath:sub(1, -2)):mkdir { parents = true }
    else
        Path:new(filepath):touch { parents = true }
    end
end

return M
