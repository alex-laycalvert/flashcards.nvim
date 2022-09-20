local api = vim.api
local utils = require('flashcards.utils')

local M = {}

local current_selection = 1

M.items = {}
M.num_items = 0

M.open = function (items, options)
    M.items = utils.map(items, function (item)
        return {
            item = item,
            line = 0
        }
    end)

    local count = 0
    for _ in pairs(items) do count = count + 1 end
    M.num_items = count

    local gwidth = api.nvim_list_uis()[1].width
    local gheight = api.nvim_list_uis()[1].height
    local height = M.num_items * 2 + 1
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

    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

    local win = api.nvim_open_win(buf, true, win_opts)
    api.nvim_win_set_option(win, 'cursorline', true)

    utils.set_mappings(buf, options.mappings)
    current_selection = 1
    M.update_view()
    return buf
end

M.choose = function ()
    print('SELECTION:', current_selection)
end

M.next = function ()
    current_selection = current_selection + 1
    if current_selection > M.num_items then
        current_selection = 1
    end
    M.update_view()
end

M.prev = function ()
    current_selection = current_selection - 1
    if current_selection < 1 then
        current_selection = M.num_items
    end
    M.update_view()
end

M.update_view = function ()
    api.nvim_buf_set_option(0, 'modifiable', true)
    -- api.nvim_buf_set_lines(0, 0, 1, false, {
    --     utils.center_line('Subjects')
    -- })
    api.nvim_buf_set_lines(0, 0, -1, false, utils.space_lines(
        utils.map(M.items, function (item) return item.item.name end),
        M.num_items,
        2
    ))
    api.nvim_buf_set_option(0, 'modifiable', false)
end

return M
