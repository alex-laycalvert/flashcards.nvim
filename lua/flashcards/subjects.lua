local utils = require('flashcards.utils')
local api = vim.api

local M = {
    options = {},
    subjects = {},
    num_subjects = 0,
    current_selection = 0,
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
    utils.set_mappings(buf, 'subjects', M.options.mappings)
end

local function update_view ()
    if win < 0 then open_window() end
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, utils.space_lines(
        utils.map(
            M.subjects,
            function (subject) return subject.name end
        ),
        M.num_subjects,
        M.options.spacing
    ))
    api.nvim_win_set_cursor(0, { M.subjects[M.current_selection].line, 0 })
    api.nvim_buf_set_option(0, 'modifiable', false)
end

M.open = function (dir, options, open_flashcards)
    M.dir = dir
    M.options = options
    M.open_flashcards = open_flashcards
    M.subjects = utils.map(
        utils.get_subjects(M.dir),
        function (subject)
            return {
                name = subject,
                line = -1
            }
        end
    )
    M.num_subjects = utils.length(M.subjects)
    local current_index = 1
    for i = 1, M.num_subjects * M.options.spacing + M.options.spacing do
        if i % M.options.spacing == 0 and current_index <= M.num_subjects then
            M.subjects[current_index].line = i
            current_index = current_index + 1
        end
    end
    M.current_selection = 1
    update_view()
end

M.next = function ()
    M.current_selection = M.current_selection + 1
    if M.current_selection > M.num_subjects then
        M.current_selection = 1
    end
    update_view()
end

M.prev = function ()
    M.current_selection = M.current_selection - 1
    if M.current_selection <= 0 then
        M.current_selection = M.num_subjects
    end
    update_view()
end

M.select = function ()
    M.close()
    M.open_flashcards(M.subjects[M.current_selection].name)
end

M.close = function ()
    api.nvim_win_close(win, true)
    win = -1
    buf = -1
end

return M
