local subjects = require('flashcards.subjects')
local utils = require('flashcards.utils')
local home = os.getenv('HOME')

local M = {}

local setup_complete = false

local defaults = {
    flashcards = {
        dir = home .. '/.config/flashcards',
        mappings = {
            l = 'next_card()',
            h = 'prev_card()',
            n = 'next_card()',
            b = 'prev_card()',
            f = 'flip_card()',
            q = 'close_cards()',
            a = 'new_card()',
            e = 'edit_card()',
            g = 'browse_cards()',
            o = 'browse_subjects()',
            ['<CR>'] = 'flip_card()',
        }
    },
    subjects = {
        spacing = 2,
        mappings = {
            j = 'next_subject()',
            k = 'prev_subject()',
            q = 'close_subjects()',
            e = 'edit_subjects()',
            a = 'add_subjects()',
            ['<CR>'] = 'select_subject()',
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

M.browse_subjects = function ()
    if not setup_complete then return end
    subjects.open(M.options.flashcards.dir, M.options.subjects)
end

return M
