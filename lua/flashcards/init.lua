local strdefi = getmetatable('').__index
getmetatable('').__index = function (str, i)
    if type(i) == 'number' then
        return string.sub(str, i, i)
    else return strdefi[i]
    end
end

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
        local flashcard_group = read_flashcard_group(file)
        flashcard_groups[i] = flashcard_group
        ::continue__read_flashcards::
    end
    return flashcard_groups
end

M.run = function ()
    if not setup_complete then
        M.setup({})
    end
    create_flashcards_dir()
    local groups = read_flashcard_groups()

    local win_opts = {
        relative = 'editor',
        width = 100,
        height = 100,
        row = 0,
        col = 0,
        style = 'minimal',
        border = 'single',
    }
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, win_opts)
end

return M
