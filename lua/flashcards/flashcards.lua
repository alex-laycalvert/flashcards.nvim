local config = require('flashcards.config')
local utils = require('flashcards.utils')
local add_card = require('flashcards.add_card')
local edit = require('flashcards.edit')
local subjects = require('flashcards.subjects')
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
    local height = 17
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
    utils.set_mappings(buf, 'flashcards', config.opts.flashcards.mappings)
end

local function update_view ()
    if win < 0 then open_window() end
    if M.num_cards <= 0 then
        current_text = 'No Flashcards Available'
    else
        current_text = showing_term and M.cards[M.current_card].term or M.cards[M.current_card].def
    end
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, utils.center(current_text))
    api.nvim_win_set_cursor(0, { 1, 0 })
    api.nvim_buf_set_option(0, 'modifiable', false)
end

local function update_cards ()
    local subject = utils.get_subject(M.subject)
    M.cards = subject.cards
    M.num_cards = subject.num_cards
    M.current_card = 1
    showing_term = config.opts.flashcards.show_terms
end

M.open = function (subject)
    M.subject = subject
    update_cards()
    update_view()
end

M.reopen = function ()
    M.close()
    update_cards()
    update_view()
end

M.next = function ()
    if M.num_cards <= 0 then return end
    M.current_card = M.current_card + 1
    if M.current_card > M.num_cards then
        M.current_card = 1
    end
    showing_term = true
    update_view()
end

M.prev = function ()
    if M.num_cards <= 0 then return end
    M.current_card = M.current_card - 1
    if M.current_card <= 0 then
        M.current_card = M.num_cards
    end
    showing_term = true
    update_view()
end

M.flip = function ()
    if M.num_cards <= 0 then return end
    showing_term = not showing_term
    update_view()
end

M.add = function ()
    add_card.open(function (card)
        if utils.trim(card.term) == '' or utils.trim(card.def) == '' then return end
        utils.create_card(card, M.subject)
        M.reopen()
    end)
end

M.edit = function ()
    local new_card = {
        term = M.cards[M.current_card].term,
        def = M.cards[M.current_card].def
    }
    if showing_term then
        edit.open(M.cards[M.current_card].term, function (new_term)
            if utils.trim(new_term) == '' then return end
            print(new_term)
            new_card.term = new_term
            utils.edit_card(M.cards[M.current_card], new_card, M.subject)
            M.reopen()
        end)
    else
        edit.open(M.cards[M.current_card].def, function (new_def)
            if utils.trim(new_def) == '' then return end
            new_card.def = new_def
            utils.edit_card(M.cards[M.current_card], new_card, M.subject)
            M.reopen()
        end)
    end
end

M.browse_subjects = function ()
    subjects.open(function (subject_info)
        M.close()
        M.open(subject_info)
    end)
end

M.close = function ()
    api.nvim_win_close(win, true)
    win = -1
    buf = -1
end

return M
