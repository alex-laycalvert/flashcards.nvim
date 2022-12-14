local config = require('flashcards.config')
local utils = require('flashcards.utils')
local add_card = require('flashcards.windows.add_card')
local edit = require('flashcards.windows.edit')
local subjects = require('flashcards.windows.subjects')
local api = vim.api

local M = {
    subject = {},
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
    if M.subject.num_cards <= 0 then
        current_text = 'No Flashcards Available'
    else
        current_text = showing_term
            and M.subject.cards[M.current_card].term
            or M.subject.cards[M.current_card].def
        if M.subject.cards[M.current_card].known then
            current_text = current_text .. ' ✅'
        end
    end
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, utils.center(current_text))
    api.nvim_win_set_cursor(0, { 1, 0 })
    api.nvim_buf_set_option(0, 'modifiable', false)
end

local function update_cards ()
    M.subject = utils.get_subject(M.subject)
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
    if M.subject.num_cards <= 0 then return end
    M.current_card = M.current_card + 1
    if M.current_card > M.subject.num_cards then
        M.current_card = 1
    end
    showing_term = true
    update_view()
end

M.prev = function ()
    if M.subject.num_cards <= 0 then return end
    M.current_card = M.current_card - 1
    if M.current_card <= 0 then
        M.current_card = M.subject.num_cards
    end
    showing_term = true
    update_view()
end

M.flip = function ()
    if M.subject.num_cards <= 0 then return end
    showing_term = not showing_term
    update_view()
end

M.add = function ()
    add_card.open(function (term, def)
        if utils.trim(term) == '' or utils.trim(def) == '' then return end
        utils.add_card(term, def, M.subject)
        M.reopen()
    end)
end

M.edit = function ()
    local new_card = {
        term = M.subject.cards[M.current_card].term,
        def = M.subject.cards[M.current_card].def
    }
    if showing_term then
        edit.open(M.subject.cards[M.current_card].term, function (new_term)
            if utils.trim(new_term) == '' then return end
            new_card.term = utils.trim(new_term)
            utils.edit_card(M.subject.cards[M.current_card].file, new_card.term, new_card.def)
            M.reopen()
        end)
    else
        edit.open(M.subject.cards[M.current_card].def, function (new_def)
            if utils.trim(new_def) == '' then return end
            new_card.def = utils.trim(new_def)
            utils.edit_card(M.subject.cards[M.current_card].file, new_card.term, new_card.def)
            M.reopen()
        end)
    end
end

M.delete = function ()
    if M.subject.num_cards <= 0 then return end
    utils.delete_card(M.subject.cards[M.current_card].file)
    M.reopen()
end

M.know = function ()
    local card = M.subject.cards[M.current_card]
    card.known = not card.known
    utils.edit_card(card.file, card.term, card.def, card.known)
    M.subject.cards[M.current_card] = card
    update_view()
end

M.browse_subjects = function ()
    subjects.open(function (subject)
        M.close()
        M.open(subject)
    end)
end

M.close = function ()
    api.nvim_win_close(win, true)
    win = -1
    buf = -1
end

return M
