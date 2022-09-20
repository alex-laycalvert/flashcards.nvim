if exists("g:loaded_flashcards_plugin")
    finish
endif
let g:loaded_flashcards_plugin = 1

command! -nargs=0 Flashcards lua require('flashcards').run()
