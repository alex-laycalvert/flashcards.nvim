local utils = require('flashcards.utils')
local api = vim.api

local M = {
    subject = '',
    cards = {},
    num_cards = 0,
    current_card = 0
}
local buf = -1
local win = -1
local current_text = ''
local showing_term = true

local function open_buffer ()
    buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
end

local function open_window ()
    local gwidth = api.nvim_list_uis()[1].width
    local gheight = api.nvim_list_uis()[1].height
    local height = 25
    local width = 70
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
    api.nvim_win_set_option(win, 'cursorline', false)
    utils.set_mappings(buf, 'flashcards', M.options.mappings)
end

local function update_view ()
    if win < 0 then open_window() end
    if showing_term then
        current_text = M.cards[M.current_card].term
    else
        current_text = M.cards[M.current_card].def
    end
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, utils.center(current_text))
    api.nvim_win_set_cursor(0, { 1, 0 })
    api.nvim_buf_set_option(0, 'modifiable', false)
end

M.open = function (dir, subject_name, options)
    local subject = utils.get_subject(subject_name, dir)
    M.options = options
    M.subject = subject.name
    M.cards = subject.cards
    M.num_cards = subject.num_cards
    M.current_card = 1
    update_view()
end

M.next = function ()
    M.current_card = M.current_card + 1
    if M.current_card > M.num_cards then
        M.current_card = 1
    end
    showing_term = true
    update_view()
end

M.prev = function ()
    M.current_card = M.current_card - 1
    if M.current_card <= 0 then
        M.current_card = M.num_cards
    end
    showing_term = true
    update_view()
end

M.flip = function ()
    showing_term = not showing_term
    update_view()
end

M.close = function ()
    api.nvim_win_close(win, true)
    win = -1
    buf = -1
end

return M
