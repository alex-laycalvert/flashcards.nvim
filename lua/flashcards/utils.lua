local api = vim.api

local M = {}

M.map = function (tbl, f)
    local t = {}
    for k, v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

M.set_mappings = function (buf, mappings)
    for k, v in pairs(mappings) do
        api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("flashcards").' .. v .. '<CR>', {
            nowait = true, noremap = true, silent = true
        })
    end
end

M.scandir = function (dir)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "' .. dir .. '"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

M.dir_exists = function (dir)
    local f = io.open(dir, 'r')
    if f then f:close() end
    return f ~= nil
end

M.create_dir = function (dir)
    if dir_exists(dir) then return end
    local code = os.execute('mkdir ' .. dir)
end

M.center_line = function (str)
    local width = api.nvim_win_get_width(0)
    local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
    return string.rep(' ', shift) .. str
end

M.center = function (str)
    local t = {}
    local centered_line = M.center_line(str)
    local width = api.nvim_win_get_width(0)
    local height = api.nvim_win_get_height(0)
    local shift = math.floor(height / 2) - 1
    for i = 1, shift do
        t[i] = string.rep(' ', width)
    end
    t[shift] = centered_line
    return t
end

return M
