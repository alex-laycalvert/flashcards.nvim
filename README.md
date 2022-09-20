# flashcards.nvim

A Neovim plugin for Flashcards written in Lua

*** WORK IN PROGRESS ***

A very basic implementation of the plugin is working but it
is nowhere near finished.

## TODO

- [ ] Enable creating/deleting flashcards from Neovim
- [ ] Enable creating/deleting subjects from Neovim
- [ ] Refactor functions in code to multiple files
- [ ] Add help menu
- [ ] Implement customizeable keymappings
- [ ] Format `term` and `def` text on buffer to look better
- [ ] Enable editing flashcard `term` and `def` while a flashcard is open
- [ ] Enable editing a flashcard subject name

## Installing

You can install this plugin using `packer.nvim`:

```lua
require('packer').startup(function(use)
    use { 'alex-laycalvert/flashcards.nvim' }
end)
```

After installing the plugin, add this to your `init.lua` file:

```lua
require('flashcards').setup({
    -- ... your configurations
})
```

## Configuration

***TODO***

- `flashcards_dir`: The directory where your flashcards are stored
    - default: `$HOME/.config/flashcards`

## Flashcards

To start going through your flashcards, enter the command `:Flashcards`.
This will open a new window with the first flash card term.

To flip a flashcard, hit `f` or enter the command `:FlipFlashcard`.
To go to the next flash card, hit `n` or enter the command `:NextFlashcard`.
To quit, hit `q`.

Flashcards are stored as `json` in your `flashcards_dir`.

Currently, to make flashcards you need to create a single `json`
file in your `flashcards_dir`. The file should be a `json` array
of objects with the properties `term` and `def` for term and definition
respectively.

Example:

```json
[
    {
        "term": "This is a term",
        "def": "This is a definition"
    },
    {
        "term": "This is another term",
        "def": "This is another definition"
    },
    ...
]
```

## API

`flashcards.nvim` implements several functions that can be accessed and mapped.

You can set `require('flashcards')` to a variable or use `lua require('flashcards').<FUNCTION>`
to call each function.

- `run()`: Entrypoint for the plugin, mapped to the command `:Flashcards`
- `next_selection()`: If flashcards are open, this goes to the next flashcard. If a selection window is open, this goes to the next selection.
- `prev_selection()`: If flashcards are open, this goes to the previous flashcard. If a selection window is open, this goes to the previous selection.
- `flip_card()`: This flips the current flashcard.
- `select()`: If flashcards are open, this is the same as `flip_card()`. If a select window is open, this selections the current option.
- `choose_subject()`: ***TODO*** This opens a select window and allows you to 
- `close_window()`: Closes the current buffer for the plugin
