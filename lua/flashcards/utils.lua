local config = require('flashcards.config')
local scan = require('plenary.scandir')
local json = require('flashcards.json')
local api = vim.api

local M = {}

math.randomseed(os.time())

-- https://github.com/james2doyle/lit-slugify
M.slugify = function (string, replacement)
    if replacement == nil then
      replacement = '-'
    end
    local result = ''
    for word in string.gmatch(string, "(%w+)") do
      result = result .. word .. replacement
    end
    result = string.gsub(result, replacement .. "$", '')
    return result:lower()
end

M.trim = function (s)
    return s:gsub('^%s*(.-)%s*$', '%1')
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

M.create_subjects_file = function ()
    local filename = config.opts.dir .. '/SUBJECTS.json'
    if M.file_exists(filename) then return end
    local code = os.execute('touch ' .. filename)
    local file = io.open(filename, 'w')
    io.output(file)
    io.write('{}')
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

M.pad = function (str, len)
    return str .. string.rep(' ', len - string.len(str))
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
            ':lua require("flashcards.windows.' .. module .. '").' .. mapping .. '<CR>', {
            nowait = true, noremap = true, silent = true
        })
    end
end

M.read_json = function (filename)
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
    return json.decode(file_json)
end

M.write_json = function (tbl, filename)
    local file = io.open(filename, 'w')
    if file == nil then
        local code = os.execute('touch ' .. filename)
        file = io.open(filename)
    end
    io.output(file)
    io.write(json.encode(tbl))
    file:close()
end

M.get_subject_names = function ()
    local filename = config.opts.dir .. '/SUBJECTS.json'
    return M.read_json(filename)
end

M.get_subjects = function ()
    local subjects = {}
    local filename = config.opts.dir .. '/SUBJECTS.json'
    local subject_info = {}
    for k, v in pairs(M.read_json(filename)) do
        local subject = M.get_subject({ name = k, dir = v })
        table.insert(subjects, subject)
    end
    return subjects
end

M.get_subject = function (subject_info)
    local subject = {
        name = subject_info.name,
        dir = subject_info.dir,
        cards = {},
        num_cards = 0,
        known_cards = 0,
    }
    local card_files = scan.scan_dir(subject.dir, { hidden = true, depth = 2 })
    local card_count = 0
    local known_count = 0
    for _, card_file in pairs(card_files) do
        local card = M.read_json(card_file)
        card.file = card_file
        table.insert(subject.cards, card)
        card_count = card_count + 1
        if card.known then
            known_count = known_count + 1
        end
    end
    subject.num_cards = card_count
    subject.known_cards = known_count
    return subject
end

M.add_subject = function (subject_name)
    local dirname = config.opts.dir .. '/' .. M.slugify(M.trim(subject_name), '_')
    if not M.file_exists(dirname) then
        local code = os.execute('mkdir ' .. dirname)
        -- TODO error handling
        local subjects = M.get_subjects()
        table.insert(subjects, {
            name = subject_name,
            dir = dirname,
            cards = {},
            num_cards = 0,
            known_cards = 0
        })
        M.write_subjects(subjects)
    end
end

M.edit_subject = function (subject, new_name)
    local new_dir = config.opts.dir .. '/' .. M.slugify(new_name)
    local subject_names = M.get_subject_names()
    subject_names[subject.name] = nil
    subject_names[new_name] = new_dir
    local code = os.execute('mv ' .. subject.dir .. ' ' .. new_dir)
    M.write_json(subject_names, config.opts.dir .. '/SUBJECTS.json')
end

M.delete_subject = function (subject)
    local subject_names = M.get_subject_names()
    subject_names[subject.name] = nil
    M.write_json(subject_names, config.opts.dir .. '/SUBJECTS.json')
end

M.reset_subject_progress = function (subject)
    for _, card in pairs(subject.cards) do
        M.edit_card(card.file, card.term, card.def, false)
    end
end

M.add_card = function (term, def, subject)
    local template = 'TERM_DEF_xxxx'
    local filename = string.gsub(template, 'TERM', M.slugify(term))
    filename = string.gsub(filename, 'DEF', M.slugify(def))
    filename = string.gsub(filename, 'x', function () return math.random(0, 0xf) end)
    M.write_json({
        term = term,
        def = def,
        known = false
    }, subject.dir .. '/' .. filename)
end

M.edit_card = function (card_file, new_term, new_def, known)
    M.write_json({
        term = new_term,
        def = new_def,
        known = known
    }, card_file)
end

M.delete_card = function(card_file)
    local code = os.execute('rm ' .. card_file)
end

return M
