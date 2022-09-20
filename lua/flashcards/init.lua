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

local subjects = {}
local current_subject = 1

local windows = {
    current = 0,
    flashcard = -1,
    subjects = -1
}

local defaults = {
    flashcards_dir = home .. '/.config/flashcards',
    mappings = {
        j = 'next_selection()',
        k = 'prev_selection()',
        l = 'next_selection()',
        h = 'prev_selection()',
        q = 'close_window()',
        n = 'next_selection()',
        b = 'prev_selection()',
        f = 'flip_card()',
        o = 'browse_subjects()',
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
    if windows.current == windows.flashcard then
        flashcard.next()
    elseif windows.current == windows.subjects then
        select.next()
    end
end

M.prev_selection = function ()
    if windows.current == windows.flashcard then
        flashcard.prev()
    elseif windows.current == windows.subjects then
        select.prev()
    end
end

M.select = function ()
    if windows.current == windows.flashcard then
        flashcard.flip()
    elseif windows.current == windows.subjects then
        select.choose(M.open_subject)
    end
end

M.close_window = function ()
    if windows.current == windows.flashcard then
        windows.flashcard = -1
    elseif windows.current == windows.subjects then
        windows.current = windows.flashcard
        windows.subjects = -1
    end
    api.nvim_win_close(0, true)
end

M.open_subject = function (index)
    api.nvim_win_close(windows.subjects, true)
    windows.flashcard = flashcard.open(subjects[index], M.options)
    windows.current = windows.flashcard
    current_subject = index
end

M.browse_subjects = function ()
    if (windows.flashcard > 0) then
        api.nvim_win_close(windows.flashcard, true)
        windows.flashcard = -1
    end
    windows.subjects = select.open(subjects, M.options, current_selection)
    windows.current = windows.subjects
end

M.run = function ()
    if not setup_complete then
        M.setup({})
    end
    subjects = utils.read_flashcard_subjects(M.options.flashcards_dir)
    M.browse_subjects()
end

return M
