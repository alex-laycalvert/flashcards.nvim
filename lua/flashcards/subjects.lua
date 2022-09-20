local utils = require('flashcards.utils')
local api = vim.api

local M = {
    options = {},
    subjects = {},
    num_subjects = 0,
}
local buf = -1
local win = -1

local function open_buffer ()
    buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
end

local function open_window ()
    local gwidth = api.nvim_list_uis()[1].width
    local gheight = api.nvim_list_uis()[1].height
    local height = M.num_subjects * M.options.spacing + M.options.spacing - 1
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
    open_buffer()
    win = api.nvim_open_win(buf, true, win_opts)
    api.nvim_win_set_option(win, 'cursorline', true)
    utils.set_mappings(buf, M.options.mappings)
end

local function update_view ()
    if win < 0 then open_window() end
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, utils.space_lines(
        M.subjects,
        M.num_subjects,
        M.options.spacing
    ))
    api.nvim_win_set_cursor(0, { M.items[M.current_selection].line, 0 })
    api.nvim_buf_set_option(0, 'modifiable', false)
end

M.open = function (dir, options)
    M.options = options
    M.subjects = utils.get_subjects(dir)
    M.num_subjects = utils.length(M.subjects)
    update_view()
end

return M
