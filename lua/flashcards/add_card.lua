local utils = require('flashcards.utils')
local api = vim.api

local M = {}

local buf = -1
local win = -1

local card = {
    term = '',
    def = ''
}

local function open_buffer ()
    buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    api.nvim_buf_set_option(buf, 'modifiable', true)
end

local function open_term_window ()
    local gwidth = api.nvim_list_uis()[1].width
    local gheight = api.nvim_list_uis()[1].height
    local height = 1
    local width = 68
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
    api.nvim_buf_set_keymap(
        buf,
        'n',
        'q',
        ':lua require("flashcards.add_card").close()<CR>',
        { nowait = true, noremap = true, silent = true }
    )
    api.nvim_buf_set_keymap(
        buf,
        'n',
        '<CR>',
        ':lua require("flashcards.add_card").submit_term()<CR>',
        { nowait = true, noremap = true, silent = true }
    )
    api.nvim_buf_set_keymap(
        buf,
        'i',
        '<CR>',
        '<cmd>lua require("flashcards.add_card").submit_term()<CR>',
        { nowait = true, noremap = true, silent = true }
    )
    vim.cmd('startinsert')
end

local function open_def_window ()
    local gwidth = api.nvim_list_uis()[1].width
    local gheight = api.nvim_list_uis()[1].height
    local height = 1
    local width = 68
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
    api.nvim_buf_set_keymap(
        buf,
        'n',
        'q',
        ':lua require("flashcards.add_card").close()<CR>',
        { nowait = true, noremap = true, silent = true }
    )
    api.nvim_buf_set_keymap(
        buf,
        'n',
        '<CR>',
        ':lua require("flashcards.add_card").submit()<CR>',
        { nowait = true, noremap = true, silent = true }
    )
    api.nvim_buf_set_keymap(
        buf,
        'i',
        '<CR>',
        '<cmd>lua require("flashcards.add_card").submit()<CR><ESC>',
        { nowait = true, noremap = true, silent = true }
    )
    vim.cmd('startinsert')
end

M.open = function (callback)
    M.callback = callback
    if win < 0 then open_term_window() end
end

M.submit = function ()
    local def_tbl = api.nvim_buf_get_text(buf, 0, 0, -1, -1, {})
    if def_tbl[1] ~= nil and def_tbl[1] ~= '' then
        card.def = def_tbl[1]
        M.callback(card)
    end
    M.close()
end

M.submit_term = function ()
    local term_tbl = api.nvim_buf_get_text(buf, 0, 0, -1, -1, {})
    M.close()
    if term_tbl[1] ~= nil and term_tbl[1] ~= '' then
        card.term = term_tbl[1]
        open_def_window()
    end
end

M.close = function ()
    api.nvim_win_close(win, true)
    win = -1
    buf = -1
end

return M
