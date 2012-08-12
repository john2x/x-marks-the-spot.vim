X Marks The Spot
================
Vim marks for pirates. Arr!

Basic usage
-----------
Default mappings:

- `<leader>x`: Add mark `x` in the current cursor location, where `x` is the next
available mark.
- `<leader>X`: Delete all marks at the current line.
- `<BS>`: Go to the previous closest mark (mode 1) or the previously
assigned mark (mode 2).
- `<S-BS>`: Go to next closest mark (mode 1) or the next assigned mark
(mode 2).

Options
-------

To set options, set their values in your vimrc.

### X_MARKS_NAVIGATION_MODE

Switch between two mark navigation modes. 

- `let g:X_MARKS_NAVIGATION_MODE = 1` - (default) Move through marks based on position.
Basically just calls `['` and `]'` for moving backward and forward, respectively.

- `let g:X_MARKS_NAVIGATION_MODE = 2` - Move through marks based on the order of
their assignment, regardless of their positions.

### X_MARKS_RESET_MARKS_ON_BUF_READ

- `let g:X_MARKS_RESET_MARKS_ON_BUF_READ = 0` - (default) Don't clear all buffer
marks when initializing X Marks The Spot for the current buffer.

- `let g:X_MARKS_RESET_MARKS_ON_BUF_READ = 1` - Clear all buffer
marks when initializing X Marks The Spot for the current buffer.

License
-------

Copyright (c) John Louis Del Rosario. Distributed under the same terms as Vim
itself. See `:help license`.
