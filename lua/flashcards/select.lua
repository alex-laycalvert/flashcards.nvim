local api = vim.api
local utils = require('flashcards.utils')

local M = {}

M.open = function (items)
    local gwidth = api.nvim_list_uis()[1].width
    local gheight = api.nvim_list_uis()[1].height
    local height = 25
    local width = 40
    local win_opts = {
        relative = 'editor',
        style = 'minimal',
        border = 'single',
        height = height,
        width = width,
        row = (gheight - height) * 0.5,
        col = (gwidth - width) * 0.5
    }
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    local win = api.nvim_open_win(buf, true, win_opts)
    api.nvim_buf_set_lines(buf, 1, -1, false, utils.map(
        items,
        function (item) return utils.center_line(item) end
    ))
    api.nvim_buf_set_option(buf, 'modifiable', false)
    return buf
end

M.choose = function ()
end

M.next = function ()
end

M.prev = function ()
end

return M
