local api = vim.api
local json = require('flashcards.json')

local M = {}

M.map = function (tbl, f)
    local t = {}
    for k, v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

M.set_mappings = function (buf, mappings)
    for k, v in pairs(mappings) do
        api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("flashcards").' .. v .. '<CR>', {
            nowait = true, noremap = true, silent = true
        })
    end
end

M.scandir = function (dir)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "' .. dir .. '"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

M.dir_exists = function (dir)
    local f = io.open(dir, 'r')
    if f then f:close() end
    return f ~= nil
end

M.create_dir = function (dir)
    if M.dir_exists(dir) then return end
    local code = os.execute('mkdir ' .. dir)
end

M.read_flashcard_subject = function (dir, filename)
    local flashcard_subject = {
        name = '',
        cards = {},
        num_cards = 0
    }
    local file = io.open(dir .. '/' .. filename, 'r')
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

M.read_flashcard_subjects = function (dir)
    local flashcard_subjects = {}
    local i = 1
    local files = M.scandir(dir)
    for num,file in pairs(files) do
        if file == '.' or file == '..' then
            goto continue__read_flashcards
        end
        local flashcard_subject = M.read_flashcard_subject(dir, file)
        flashcard_subjects[i] = flashcard_subject
        i = i + 1
        ::continue__read_flashcards::
    end
    return flashcard_subjects
end

M.center_line = function (str)
    local width = api.nvim_win_get_width(0)
    local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
    return string.rep(' ', shift) .. str
end

M.center = function (str)
    local t = {}
    local centered_line = M.center_line(str)
    local width = api.nvim_win_get_width(0)
    local height = api.nvim_win_get_height(0)
    local shift = math.floor(height / 2) - 1
    for i = 1, shift do
        t[i] = string.rep(' ', width)
    end
    t[shift + 1] = centered_line
    return t
end

M.space_lines = function (lines, num_lines, spacing)
    local t = {}
    local current_index = 1
    for i = 1, num_lines * spacing + spacing do
        if i % spacing == 0 and current_index <= num_lines then
            t[i] = M.center_line(lines[current_index])
            current_index = current_index + 1
        else
            t[i] = ''
        end
    end
    return t
end

return M
