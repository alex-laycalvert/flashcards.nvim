local strdefi = getmetatable('').__index
getmetatable('').__index = function (str, i)
    if type(i) == 'number' then
        return string.sub(str, i, i)
    else return strdefi[i]
    end
end
local api = vim.api
local home = os.getenv('HOME')
local utils = require('flashcards.utils')
local select = require('flashcards.select')
local flashcard = require('flashcards.flashcard')

local setup_complete = false

local buffers = {
    current = 0,
    flashcard = -1,
    subjects = -1
}

local defaults = {
    flashcards_dir = home .. '/.config/flashcards',
    mappings = {
        j = 'next_selection()',
        k = 'prev_selection()',
        q = 'close_window()',
        n = 'next_selection()',
        b = 'prev_selection()',
        f = 'flip_card()',
        ['<cr>'] = 'select()'
    }
}

local M = {}

M.options = {}

M.setup = function(opts)
    if setup_complete then
        return
    end
    setup_complete = true
    M.options = vim.tbl_deep_extend('force', {}, defaults, opts or {})
    utils.create_dir(M.options.flashcards_dir)
end

M.choose_subject = function ()
    select.open({
        'Select option 1',
        'Select option 2',
        'Select option 3',
    })
end

M.flip_card = function ()
    flashcard.flip()
end

M.next_selection = function ()
    if buffers.current == buffers.flashcard then
        flashcard.next()
    elseif buffers.current == buffers.subjects then
        select.next()
    end
end

M.prev_selection = function ()
    if buffers.current == buffers.flashcard then
        flashcard.prev()
    elseif buffers.current == buffers.subjects then
        select.prev()
    end
end

M.select = function ()
    if buffers.current == buffers.flashcard then
        flashcard.flip()
    elseif buffers.current == buffers.subjects then
        select.choose()
    end
end

M.close_window = function ()
    if buffers.current == buffers.flashcard then
    elseif buffers.current == buffers.subjects then
        buffers.current = buffers.flashcard
    end
    api.nvim_win_close(0, true)
end

M.run = function ()
    if not setup_complete then
        M.setup({})
    end
    local subjects = utils.read_flashcard_subjects(M.options.flashcards_dir)
    buffers.subjects = select.open(subjects, M.options)
    buffers.current = buffers.subjects
    -- buffers.flashcard = flashcard.open(subjects[1], M.options)
    -- buffers.current = buffers.flashcard
end

return M
