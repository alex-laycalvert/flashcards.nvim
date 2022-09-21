local api = vim.api

local M = {}

local buf = -1
local win = -1

local function open_buffer ()
    buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    api.nvim_buf_set_option(buf, 'modifiable', true)
end

local function open_window ()
    local gwidth = api.nvim_list_uis()[1].width
    local gheight = api.nvim_list_uis()[1].height
    local height = 1
    local width = 20
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
        ':lua require("flashcards.add_subject").close()<CR>',
        { nowait = true, noremap = true, silent = true }
    )
    api.nvim_buf_set_keymap(
        buf,
        'n',
        '<CR>',
        ':lua require("flashcards.add_subject").submit()<CR>',
        { nowait = true, noremap = true, silent = true }
    )
    api.nvim_buf_set_keymap(
        buf,
        'i',
        '<CR>',
        '<cmd>lua require("flashcards.add_subject").submit()<CR><ESC>',
        { nowait = true, noremap = true, silent = true }
    )
    vim.cmd('startinsert')
end

M.open = function (callback)
    M.callback = callback
    if win < 0 then open_window() end
end

M.submit = function ()
    text_tbl = api.nvim_buf_get_text(buf, 0, 0, -1, -1, {})
    if text_tbl[1] ~= nil and text_tbl[1] ~= '' then
        M.callback(text_tbl[1])
    end
    M.close()
end

M.close = function ()
    api.nvim_win_close(win, true)
    win = -1
    buf = -1
end

return M
