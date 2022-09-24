local config = require('flashcards.config')
local subjects = require('flashcards.windows.subjects')
local flashcards = require('flashcards.windows.flashcards')
local utils = require('flashcards.utils')

local M = {}

local setup_complete = false

M.setup = function (opts)
    if setup_complete then return end
    config.setup(opts)
    utils.create_dir(config.opts.dir)
    utils.create_subjects_file(config.opts.dir)
    setup_complete = true
end

M.open_flashcards = function (subject)
    flashcards.open(subject)
end

M.browse_subjects = function ()
    if not setup_complete then return end
    subjects.open(M.open_flashcards)
end

return M
