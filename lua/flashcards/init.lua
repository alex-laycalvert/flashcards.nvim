local strdefi = getmetatable('').__index
getmetatable('').__index = function (str, i)
    if type(i) == 'number' then
        return string.sub(str, i, i)
    else return strdefi[i]
    end
end
local api = vim.api

local json = require('flashcards.json')

local M = {}

local home = os.getenv('HOME')

local defaults = {
    flashcards_dir = home .. '/.config/flashcards'
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

local function scandir (dir)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "' .. dir .. '"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

local function flashcards_dir_exists ()
    local f = io.open(M.options.flashcards_dir, 'r')
    if f then f:close() end
    return f ~= nil
end

local function create_flashcards_dir ()
    if flashcards_dir_exists() then return end
    local code = os.execute('mkdir ' .. M.options.flashcards_dir)
end

local function read_flashcard_group (file)
    local flashcard_group = {}
    local file = io.open(file, 'r')
    local file_json_str = ''
    io.input(file)
    local line = io.read()
    while line ~= nil do
        file_json_str = file_json_str .. line
        line = io.read()
    end
    local file_json = json.decode(file_json_str)
    for key, flashcard in pairs(file_json) do
        flashcard_group[key] = {
            term = flashcard.term,
            def = flashcard.def
        }
    end
    return flashcard_group
end

local function read_flashcard_groups ()
    local flashcard_groups = {}
    local i = 1
    local files = scandir(M.options.flashcards_dir)
    for num,file in pairs(files) do
        if file == '.' or file == '..' then
            goto continue__read_flashcards
        end
        local flashcard_group = read_flashcard_group(M.options.flashcards_dir .. '/' .. file)
        flashcard_groups[i] = flashcard_group
        ::continue__read_flashcards::
    end
    return flashcard_groups
end

local function center_line (str)
    local width = api.nvim_win_get_width(0)
    local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
    return string.rep(' ', shift) .. str
end

local function center (str)
    local t = {}
    local centered_line = center_line(str)
    local width = api.nvim_win_get_width(0)
    local height = api.nvim_win_get_height(0)
    local shift = math.floor(height / 2) - 1
    for i = 1,shift do
        t[i] = string.rep(' ', width)
    end
    t[shift] = centered_line
    return t
end

local function update ()
    if M.current.card > M.current.num_cards then return end
    M.current.showing_term = true
    api.nvim_buf_set_lines(0, 1, -1, false, center(M.current.group[M.current.card].term))
end

M.current = {
    group = {},
    card = 1,
    num_cards = 0,
    showing_term = true
}

M.flip_card = function ()
    if M.current.showing_term then
        M.current.showing_term = false
        api.nvim_buf_set_lines(0, 1, -1, false, center(M.current.group[M.current.card].def))
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

M.run = function ()
    if not setup_complete then
        M.setup({})
    end
    create_flashcards_dir()
    local groups = read_flashcard_groups()
    M.current.group = groups[1]
    local count = 0
    for _ in pairs(M.current.group) do count = count + 1 end
    M.current.num_cards = count
    M.current.card = 1

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

    update()
end

return M
