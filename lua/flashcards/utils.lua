local json = require('flashcards.json')
local api = vim.api

local M = {}

M.length = function (tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

M.map = function (tbl, f)
    local t = {}
    for k, v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

M.file_exists = function (file)
    local f = io.open(file, 'r')
    if f then f:close() end
    return f ~= nil
end

M.create_dir = function (dir)
    if M.file_exists(dir) then return end
    local code = os.execute('mkdir ' .. dir)
end

M.create_subjects_file = function (dir)
    local filename = dir .. '/' .. 'SUBJECTS.json'
    if M.file_exists(filename) then return end
    local code = os.execute('touch ' .. filename)
    local file = io.open(filename, 'w')
    io.output(file)
    io.write('[]')
    file:close()
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

M.set_mappings = function (buf, module, mappings)
    local all_chars = {
        'a', 'b', 'c', 'd',
        'e', 'f', 'g', 'h',
        'i', 'j', 'k', 'l',
        'm', 'n', 'o', 'p',
        'q', 'r', 's', 't',
        'u', 'v', 'w', 'x',
        'y', 'z', ' ', '<bs>'
    }
    for k, mapping in pairs(all_chars) do
        api.nvim_buf_set_keymap(buf, 'n', mapping, ':<CR>', {
            nowait = true, noremap = true, silent = true
        })
    end
    for k, mapping in pairs(mappings) do
        api.nvim_buf_set_keymap(
            buf,
            'n',
            k,
            ':lua require("flashcards.' .. module .. '").' .. mapping .. '<CR>', {
            nowait = true, noremap = true, silent = true
        })
    end
end

M.get_subjects = function (dir)
    local subjects = {}
    local filename = dir .. '/SUBJECTS.json'
    local file = io.open(filename, 'r')
    if file == nil then
        -- TODO Error handling
        return {}
    end
    local file_json = ''
    io.input(file)
    local line = io.read()
    while line ~= nil do
        file_json = file_json .. line
        line = io.read()
    end
    file:close()
    local subjects_json = json.decode(file_json)
    for k, subject in pairs(subjects_json) do
        subjects[k] = subject
    end
    return subjects
end

M.get_subject = function (subject_name, dir)
    local subject = {
        name = subject_name,
        cards = {},
        num_cards = 0
    }
    local filename = dir .. '/' .. subject_name .. '.json'
    local file = io.open(filename, 'r')
    local file_json = ''
    io.input(file)
    local line = io.read()
    while line ~= nil do
        file_json = file_json .. line
        line = io.read()
    end
    file:close()
    local subject_json = json.decode(file_json)
    local count = 0
    for k, card in pairs(subject_json) do
        count = count + 1
        subject.cards[k] = card
    end
    subject.num_cards = count
    return subject
end

return M
