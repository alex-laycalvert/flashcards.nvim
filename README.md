# flashcards.nvim

A Neovim plugin for Flashcards written in Lua

*** WORK IN PROGRESS ***

There are a few features that have not been implemented.

## TODO

- [ ] Delete subject from browse menu
- [ ] Delete card from flashcards w/ config
- [ ] Edit subject name from browse menu
- [ ] Edit flashcard term and def while viewing cards
- [ ] Browse all cards in subject
- [ ] Documentation
- [ ] Format text on flashcard so it doesn't wrap mid-word

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

- `dir`: Directory where flashcards are stored (default: `$HOME/.config/flashcards`)

## Flashcards

To choose from the `subjects` menu, use the normal `j` and `k` keys to go
down and up, then `enter` to select a subject. To add a new subject from
the menu, press `a` then type the subject name and `enter`. You can also
use `e` to edit the name of a subject.

To navigate through `flashcards`, you can use `n` and `l` to go to the
next flashcard, and `b` and `h` to go to the previouse one. Use either
`enter`, `space`, or `f` to flip the flashcard. You can use `a` to add
a new flashcard, type the term and hit `enter`, then type the definition
end hit `enter`.
