local config = require('flashcards.config')
local scan = require('plenary.scandir')
local json = require('flashcards.json')
local api = vim.api

local M = {}

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

M.filter = function (tbl, f)
    local t = {}
    for k, v in pairs(tbl) do
        if f(v) then t[k] = v end
    end
    return t
end

M.file_exists = function (file)
    local f = io.open(file, 'r')
    if f then f:close() end
    return f ~= nil
end

M.delete_file = function (file)
    return os.execute('rm ' .. file)
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

M.space_lines = function (lines, num_lines, spacing)
    local t = {}
    local current_index = 1
    for i = 1, num_lines * spacing + spacing do
        if i % spacing == 0 and current_index <= num_lines then
            t[i] = lines[current_index]
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
            ':lua require("flashcards.windows.' .. module .. '").' .. mapping .. '<CR>', {
            nowait = true, noremap = true, silent = true
        })
    end
end

M.write_subjects = function (subjects)
    local subjects_file = io.open(config.opts.dir .. '/SUBJECTS.json', 'w')
    local subjects_to_write = {}
    for _, v in pairs(subjects) do
        subjects_to_write[v.name] = v.dir
    end
    io.output(subjects_file)
    io.write(json.encode(subjects_to_write))
    subjects_file:close()
end

M.write_cards = function (cards, filename)
    local file = io.open(filename, 'w')
    io.output(file)
    io.write(json.encode(cards))
    file:close()
end

M.edit_subject = function (subject_name, new_name)
    local subjects = M.get_subjects()
    for name, file in pairs(subjects) do
        if name == subject_name then
            subjects[name] = nil
            subjects[M.trim(new_name)] = file
            break
        end
    end
    M.write_subjects(subjects)
end

M.delete_subject = function (subject_name)
    local subjects = M.get_subjects()
    local file = subjects[subject_name]
    subjects[subject_name] = nil
    M.write_subjects(subjects)
    os.execute('rm ' .. file)
end

M.create_card = function (term, def, subject)
    local subjects = M.get_subjects()
    local filename = subjects[subject]
    if not M.file_exists(filename) then return end
    local cards = M.get_cards(filename)
    cards[term] = def
    M.write_cards(cards, filename)
end

M.edit_card = function (term, new_term, new_def, subject)
    local subjects = M.get_subjects()
    local filename = subjects[subject]
    if not M.file_exists(filename) then return end
    local cards = M.get_cards(filename)
    cards[term] = nil
    cards[new_term] = new_def
    M.write_cards(cards, filename)
end

M.delete_card = function (term, subject)
    local subjects = M.get_subjects()
    local filename = subjects[subject]
    if not M.file_exists(filename) then return end
    local cards = M.get_cards(filename)
    cards[term] = nil
    M.write_cards(cards, filename)
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


return M
