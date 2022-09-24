local config = require('flashcards.config')
local utils = require('flashcards.utils')
local add_subject = require('flashcards.windows.add_subject')
local edit = require('flashcards.windows.edit')
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
    local height =
        M.num_subjects *
        config.opts.subjects.spacing +
        config.opts.subjects.spacing - 1 + 8
    local width = 60
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
    utils.set_mappings(buf, 'subjects', config.opts.subjects.mappings)
end

local function update_view ()
    if win < 0 then open_window() end
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, {
        '',
        utils.center_line('flashcards'),
        '',
        '────────────────────────────────────────────────────────────',
        '                                    │            │          ',
        ' Subject                            │ # of Cards │ Progress ',
        '                                    │            │          ',
        '────────────────────────────────────────────────────────────',
        '                                    │            │          ',
    })
    if M.num_subjects <= 0 then
        api.nvim_buf_set_lines(buf, 10, -1, false, utils.center('No Subjects Available'))
    else
        local i = 10
        for k, v in pairs(M.subjects) do
            local percent = v.known_cards / 1.0 / v.num_cards
            if v.num_cards == 0 then percent = 0 end
            api.nvim_buf_set_lines(buf, i, -1, false, {
                ' ' .. utils.pad(v.name, 35) .. '│' ..
                utils.pad('    ' .. v.num_cards, 12) .. '│' ..
                utils.pad('    ' .. tostring(percent) .. ' %', 10),
                utils.pad(' ', 36) .. '│' .. utils.pad(' ', 12) .. '│',
            })
            i = i + 1
        end
        api.nvim_win_set_cursor(0, { M.subjects[M.current_selection].line, 0 })
    end
    api.nvim_buf_set_option(0, 'modifiable', false)
end

local function update_subjects ()
    M.subjects = {}
    M.num_subjects = 0
    local subjects = utils.get_subjects()
    local i = 1
    for _, v in pairs(subjects) do
        M.subjects[i] = {
            name = v.name,
            dir = v.dir,
            cards = v.cards, 
            num_cards = v.num_cards,
            known_cards = v.known_cards,
            line = -1
        }
        i = i + 1
    end
    M.num_subjects = utils.length(M.subjects)
    local current_index = 1
    for i = 1, M.num_subjects * config.opts.subjects.spacing + config.opts.subjects.spacing do
        if i % config.opts.subjects.spacing == 0 and current_index <= M.num_subjects then
            M.subjects[current_index].line = i + 8
            current_index = current_index + 1
        end
    end
    M.current_selection = 1
end

M.open = function (open_flashcards)
    M.open_flashcards = open_flashcards
    update_subjects()
    update_view()
end

M.reopen = function ()
    M.close()
    update_subjects()
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
    M.open_flashcards(M.subjects[M.current_selection])
end

M.add = function ()
    add_subject.open(function (name)
        if utils.trim(name) == '' then return end
        utils.add_subject(name)
        M.reopen()
    end)
end

M.edit = function ()
    edit.open(M.subjects[M.current_selection].name, function (new_name)
        if utils.trim(new_name) == '' then return end
        utils.edit_subject(M.subjects[M.current_selection].name, new_name)
        M.reopen()
    end)
end

M.delete = function ()
    if M.num_subjects <= 0 then return end
    utils.delete_subject(M.subjects[M.current_selection].name)
    M.reopen()
end

M.close = function ()
    api.nvim_win_close(win, true)
    win = -1
    buf = -1
end

return M
