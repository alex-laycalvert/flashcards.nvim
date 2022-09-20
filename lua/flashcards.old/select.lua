local api = vim.api
local utils = require('flashcards.utils')

local M = {}

M.items = {}
M.num_items = 0
M.spacing = 2
M.current_selection = 0

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
    local height = M.num_items * M.spacing + M.spacing - 1
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

    local current_index = 1
    for i = 1, M.num_items * M.spacing + M.spacing do
        if i % M.spacing == 0 and current_index <= M.num_items then
            M.items[current_index].line = i
            current_index = current_index + 1
        end
    end

    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

    local win = api.nvim_open_win(buf, true, win_opts)
    api.nvim_win_set_option(win, 'cursorline', true)

    utils.set_mappings(buf, options.mappings)
    M.current_selection = 1
    M.update_view()
    return win
end

M.choose = function (callback)
    callback(M.current_selection)
end

M.next = function ()
    M.current_selection = M.current_selection + 1
    if M.current_selection > M.num_items then
        M.current_selection = 1
    end
    M.update_view()
end

M.prev = function ()
    M.current_selection = M.current_selection - 1
    if M.current_selection < 1 then
        M.current_selection = M.num_items
    end
    M.update_view()
end

M.update_view = function ()
    api.nvim_buf_set_option(0, 'modifiable', true)
    api.nvim_buf_set_lines(0, 0, -1, false, utils.space_lines(
        utils.map(M.items, function (item) return item.item.name end),
        M.num_items,
        M.spacing
    ))
    api.nvim_win_set_cursor(0, { M.items[M.current_selection].line, 0 })
    api.nvim_buf_set_option(0, 'modifiable', false)
end

return M
