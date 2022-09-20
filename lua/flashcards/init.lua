local strdefi = getmetatable('').__index
getmetatable('').__index = function (str, i)
    if type(i) == 'number' then
        return string.sub(str, i, i)
    else return strdefi[i]
    end
end
local api = vim.api

local json = require('flashcards.json')
local utils = require('flashcards.utils')
local select = require('flashcards.select')
local flashcard = require('flashcards.flashcard')

local M = {}

local home = os.getenv('HOME')

local defaults = {
    flashcards_dir = home .. '/.config/flashcards',
    mappings = {
        j = 'next_option()',
        k = 'prev_option()',
        q = 'close_window()',
        n = 'next_flashcard()',
        f = 'flip_flashcard()',
        ['<cr>'] = 'select_option()'
    }
}

M.options = {}

local setup_complete = false

M.setup = function(opts)
    if setup_complete then
        return
    end
    setup_complete = true
    M.options = vim.tbl_deep_extend('force', {}, defaults, opts or {})
end


local function read_flashcard_subject (filename)
    local flashcard_subject = {
        name = '',
        cards = {},
        num_cards = 0
    }
    local file = io.open(M.options.flashcards_dir .. '/' .. filename, 'r')
    local file_json_str = ''
    io.input(file)
    local line = io.read()
    while line ~= nil do
        file_json_str = file_json_str .. line
        line = io.read()
    end
    local file_json = json.decode(file_json_str)
    flashcard_subject.name = filename:match('^(.*).json')
    local count = 0
    for key, flashcard in pairs(file_json) do
        count = count + 1
        flashcard_subject.cards[key] = {
            term = flashcard.term,
            def = flashcard.def
        }
    end
    flashcard_subject.num_cards = count
    return flashcard_subject
end

local function read_flashcard_subjects ()
    local flashcard_subjects = {}
    local i = 1
    local files = utils.scandir(M.options.flashcards_dir)
    for num,file in pairs(files) do
        if file == '.' or file == '..' then
            goto continue__read_flashcards
        end
        local flashcard_subject = read_flashcard_subject(file)
        flashcard_subjects[i] = flashcard_subject
        ::continue__read_flashcards::
    end
    return flashcard_subjects
end

local function update ()
    if M.current.card > M.current.num_cards then return end
    M.current.showing_term = true
    api.nvim_buf_set_lines(0, 1, -1, false, utils.center(M.current.subject[M.current.card].term))
end

local function update_options ()
end

M.current = {
    subject = {},
    card = 1,
    showing_term = true
}

M.flip_card = function ()
    if M.current.showing_term then
        M.current.showing_term = false
        api.nvim_buf_set_lines(0, 1, -1, false, utils.center(M.current.subject[M.current.card].def))
    else
        M.current.showing_term = true
        update()
    end
end

M.next_card = function ()
    M.current.card = M.current.card + 1
    if M.current.card > M.current.num_cards then
        M.current.card = 1
    end
    update()
end

M.choose_subject = function ()
    select.open({
        'Select option 1',
        'Select option 2',
        'Select option 3',
    })
end

M.open_flashcards = function ()
    local flashcard_buf = flashcard.open(M.current.subject.cards)
end

-- M.select_option = function ()
--     local current_line = api.nvim_win_get_cursor(0)[1]
--     print(current_line)
-- end

-- M.next_option = function ()
--     M.current.option = M.current.option + 1
--     if M.current.option > M.current.num_options then
--         M.current.option = 1
--     end
--     update_options()
-- end

-- M.prev_option = function ()
--     M.current.option = M.current.option - 1
--     if M.current.option < 1 then
--         M.current.option = M.current.num_options
--     end
--     update_options()
-- end

-- M.close_window = function ()
--     api.nvim_win_close(0, true)
-- end

M.run = function ()
    if not setup_complete then
        M.setup({})
        utils.create_dir(M.options.flashcards_dir)
    end
    local subjects = read_flashcard_subjects()
end

return M
