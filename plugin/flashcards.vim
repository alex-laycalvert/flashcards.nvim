if exists("g:loaded_flashcards_plugin")
    finish
endif
let g:loaded_flashcards_plugin = 1

command! -nargs=0 Flashcards lua require('flashcards').run()
command! -nargs=0 FlipFlashcard lua require('flashcards').flip_card()
command! -nargs=0 NextFlashcard lua require('flashcards').next_card()
command! -nargs=0 SelectFlashcardOption lua require('flashcards').select_option()
