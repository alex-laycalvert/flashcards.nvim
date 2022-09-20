local api = vim.api

local M = {}

M.cards = {}
M.current_card = 1
M.num_cards = 0
M.

M.open = function (subject)
    M.cards = subject.cards
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
    api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n', 'f', ':FlipFlashcard<CR>', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n', 'n', ':NextFlashcard<CR>', { nowait = true, noremap = true, silent = true })
    return buf
end

M.flip = function ()
end

return M
