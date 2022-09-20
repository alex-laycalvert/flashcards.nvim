local subjects = require('flashcards.subjects')
local flashcards = require('flashcards.flashcards')
local utils = require('flashcards.utils')
local home = os.getenv('HOME')

local M = {}

local setup_complete = false

local defaults = {
    flashcards = {
        dir = home .. '/.config/flashcards',
        mappings = {
            l = 'next()',
            h = 'prev()',
            n = 'next()',
            b = 'prev()',
            f = 'flip()',
            q = 'close()',
            a = 'new()',
            e = 'edit()',
            g = 'browse_cards()',
            o = 'browse_subjects()',
            ['<CR>'] = 'flip()',
        }
    },
    subjects = {
        spacing = 2,
        mappings = {
            j = 'next()',
            k = 'prev()',
            q = 'close()',
            e = 'edit()',
            a = 'add()',
            ['<CR>'] = 'select()',
        },
    }
}

M.setup = function (opts)
    if setup_complete then return end
    M.options = vim.tbl_deep_extend('force', {}, defaults, opts or {})
    utils.create_dir(M.options.flashcards.dir)
    utils.create_subjects_file(M.options.flashcards.dir)
    setup_complete = true
end

M.open_flashcards = function (subject)
    flashcards.open(M.options.flashcards.dir, subject, M.options.flashcards)
end

M.browse_subjects = function ()
    if not setup_complete then return end
    subjects.open(M.options.flashcards.dir, M.options.subjects, M.open_flashcards)
end

return M
