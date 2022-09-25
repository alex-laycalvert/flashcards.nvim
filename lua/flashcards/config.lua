local home = os.getenv('HOME')

local M = {
    opts = {}
}

local defaults = {
    dir = home .. '/.config/flashcards',
    flashcards = {
        show_terms = true,
        mappings = {
            l = 'next()',
            h = 'prev()',
            n = 'next()',
            b = 'prev()',
            f = 'flip()',
            q = 'close()',
            a = 'add()',
            e = 'edit()',
            d = 'delete()',
            g = 'browse_cards()',
            o = 'browse_subjects()',
            k = 'know()',
            ['<CR>'] = 'flip()',
            [' '] = 'flip()',
        }
    },
    subjects = {
        mappings = {
            j = 'next()',
            k = 'prev()',
            q = 'close()',
            e = 'edit()',
            a = 'add()',
            d = 'delete()',
            r = 'reset()',
            ['<CR>'] = 'select()',
        },
    }
}

M.setup = function (opts)
    M.opts = vim.tbl_deep_extend('force', {}, defaults, opts or {})
end

return M
