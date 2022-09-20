local api = vim.api
local utils = require('flashcards.utils')

local M = {}

local current_text = ''
local showing_term = true

M.name = ''
M.cards = {}
M.current_card = 1
M.num_cards = 0

M.open = function (subject, options)
    M.name = subject.name
    M.cards = subject.cards
    local count = 0
    for _ in pairs(M.cards) do count = count + 1 end
    M.num_cards = count
    local gwidth = api.nvim_list_uis()[1].width
    local gheight = api.nvim_list_uis()[1].height
    local height = 15
    local width = 75
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
    utils.set_mappings(buf, options.mappings)
    M.update_card()
    return buf
end

M.flip = function ()
    showing_term = not showing_term
    M.update_card()
end

M.next = function ()
    M.current_card = M.current_card + 1
    if M.current_card > M.num_cards then
        M.current_card = 1
    end
    showing_term = true
    M.update_card()
end

M.prev = function ()
    M.current_card = M.current_card - 1
    if M.current_card < 1 then
        M.current_card = M.num_cards
    end
    showing_term = true
    M.update_card()
end

M.update_card = function ()
    api.nvim_buf_set_option(0, 'modifiable', true)
    if showing_term then
        current_text = M.cards[M.current_card].term
    else
        current_text = M.cards[M.current_card].def
    end
    api.nvim_buf_set_lines(0, 0, -1, false, utils.center(current_text))
    api.nvim_buf_set_lines(0, 0, 1, false, { utils.center_line(M.name) })
    api.nvim_buf_set_option(0, 'modifiable', false)
end

return M
