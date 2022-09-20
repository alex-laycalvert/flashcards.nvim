local json = require('flashcards.json')

local M = {}

M.length = function (tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
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

M.create_subjects_file = function (dir)
    local filename = dir .. '/' .. 'SUBJECTS.json'
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

    local file = io.open(dir .. '/SUBJECTS.json', 'r')
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

M.get_subject = function (subject, dir)
    local subject = {}
    return subject
end

return M
