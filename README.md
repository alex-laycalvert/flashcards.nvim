# flashcards.nvim

A Neovim Lua plugin for creating and studying flashcards.

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
- `flashcards = { ... }`: Config for flashcards
  - `show_terms`: Boolean value for whether flashcards should show terms first (default: `true`)
- `subjects = { ... }`: Config for the subjects menu
  - `spacing`: Separation between subject options (default `2`)

## Subjects

Subjects are collections of flashcards and are stored as `json` files in your
flashcards `dir`. When openening `Flashcards`, a browse subjects menu will open
allowing you to create, open, edit, and delete your subjects.

Default Mappings:
- `j`, `k`: Moving up and down respectively.
- `a`: Create a new subject. Window opens for you to type the name.
- `e`: Edit the name of a subject. Window opens to change the name.
- `d`: Delete the selected subject, no confirm window pops up.
- `q`: Close window.
- `enter`: Open the selected subject.

## Flashcards

Flashcards can be viewed by opening a subject and can be
created, edited, flipped, and deleted.

Default Mappings:
- `n`, `l`: Goto next flashcard.
- `b`, `h`: Goto previous flashcard.
- `f`, `enter`, `space`: Flip flashcard.
- `a`: Add a new flashcard. A window will popup for you to enter the term, then
       another to enter the definition.
- `e`: Edit current side of flashcard.
- `d`: Delete the current flashcard.
- `o`: Browse all subjects.
