
--------------------------------------------------------------------------------
-- Set Leader Key
vim.g.mapleader = ','
vim.g.maplocalleader = ','
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- File Protection and Backup
vim.opt.autoread = true       -- Automatically reload files when changed externally (e.g., by another program)
vim.opt.backup = false        -- Disable file backups (reduces clutter)
vim.opt.writebackup = false   -- Prevent creation of a backup file before overwriting (avoids conflicts)
vim.opt.swapfile = false      -- Disable swap files (reduces disk writes and clutter)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Command History and Undo System
vim.opt.history = 700         -- Number of stored commands and search history entries
vim.opt.undodir = vim.fn.expand("~/.local/state/nvim/undo/") -- Persistent undo history storage directory
vim.opt.undofile = true       -- Enable persistent undo (remembers changes even after closing Neovim)
vim.opt.undolevels = 1000     -- Maximum number of undo levels per buffer
vim.opt.undoreload = 10000    -- Maximum number of lines to save for undo after buffer reload
-- Restore Last Cursor Position
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local row, col = mark[1], mark[2]
        if row > 0 and row <= vim.api.nvim_buf_line_count(0) then
            vim.api.nvim_win_set_cursor(0, { row, col })
        end
    end,
})
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Correct common Vim command typos
vim.api.nvim_create_autocmd("CmdlineEnter", {
    pattern = ":",
    callback = function()
        vim.cmd([[
            cnoreabbrev W w
            cnoreabbrev Q q
            cnoreabbrev WQ wq
            cnoreabbrev Wq wq
            cnoreabbrev wQ wq
            cnoreabbrev Qa qa
            cnoreabbrev QA qa
        ]])
    end
})
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Indentation
vim.opt.breakindent = true    -- Enable indentation when a line wraps to the next line
vim.opt.expandtab = true      -- Convert tab characters to spaces
vim.opt.smarttab = true       -- Insert the correct number of spaces when pressing <Tab> based on shiftwidth
vim.opt.shiftwidth = 4        -- Number of spaces for each auto-indent level
vim.opt.tabstop = 4           -- Number of spaces per tab character (affects file appearance)
vim.opt.autoindent = true     -- Copy indentation from the previous line when starting a new one
vim.opt.textwidth = 0         -- Set the maximum line width before wrapping text
vim.opt.softtabstop = 4       -- Number of spaces used when pressing <Tab> (works with expandtab)
vim.opt.backspace = "indent,eol,start" -- Allow backspacing over indentation, end-of-line, and start of insert mode
vim.keymap.set("v", "<Tab>", ">gv", { remap = false, silent = true })     -- Indent with Tab in visual mode
vim.keymap.set("v", "<S-Tab>", "<gv", { remap = false, silent = true })   -- Unindent with Shift+Tab in visual mode
vim.keymap.set('n', '<Home>', '^', { remap = false, silent = true }) -- Go to first indented character and not first column when pressing <Home>

vim.opt.smartindent = true    -- Automatically insert indentation in structured programming languages
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        -- Disable for Python or it makes visual indentation fail for comments at column 0
        vim.opt_local.smartindent = false
    end,
})
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Wrap
--vim.keymap.set('n', 'j', 'gj', { remap = false, silent = true })
--vim.keymap.set('n', 'k', 'gk', { remap = false, silent = true })
vim.keymap.set('n', '<Up>', 'gk', { remap = false, silent = true })    -- Movement of the cursor respects visual lines (i.e., wrapped lines) rather than logical lines
vim.keymap.set('n', '<Down>', 'gj', { remap = false, silent = true })  -- Movement of the cursor respects visual lines (i.e., wrapped lines) rather than logical lines
vim.opt.whichwrap:append("<,>,h,l") -- Allow moving to the previous/next line with <Left> and <Right> when cursor reaches the beginning or end of a line
vim.keymap.set("n", "<leader>tw", ":set wrap!<CR>", { remap = false, silent = true }) -- Toggle wrap shortcut
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Mouse
vim.opt.mouse = ''            -- Disable mouse support
--vim.opt.mouse = 'a'
--
-- Toggle Mouse Function
function ToggleMouse()
    if vim.o.mouse == "a" then
        vim.o.mouse = ""
        print("Mouse Disabled")
    else
        vim.o.mouse = "a"
        print("Mouse Enabled")
    end
end
vim.keymap.set("n", "<leader>tm", ":lua ToggleMouse()<CR>", { remap = false, silent = true }) -- Toggle mouse shortcut
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- User Interface
vim.opt.background = "dark"   -- Use colors suited for dark backgrounds
vim.opt.scrolloff = 7         -- Keep at least N lines visible above and below the cursor 
vim.opt.sidescrolloff = 7     -- Columns of context
vim.opt.wildmenu = true       -- Enable enhanced command-line tab completion menu
vim.opt.wildignore = "*.o,*~,*.pyc" -- Ignore compiled and temporary files when completing filenames
vim.opt.ruler = true          -- Show the cursor position in the status line
vim.opt.cmdheight = 2         -- Set command-line height to 2 lines for better visibility
vim.opt.hidden = true         -- Allow switching buffers without saving (keeps unsaved buffers open)
vim.opt.errorbells = false     -- Disable beeping sound on errors
vim.opt.visualbell = false     -- Disable visual bell on errors
vim.opt.number = false        -- Disable absolute line numbers
vim.opt.relativenumber = false -- Disable relative line numbers (useful for jumping to lines efficiently)
vim.opt.showmode = true       -- Show the current mode (NORMAL, INSERT, etc.) at the bottom (redundant if displayed in status line)
vim.opt.signcolumn = 'no'     -- Do not display the sign column by default (used for Git signs, LSP diagnostics, etc.)
vim.opt.list = false          -- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.cursorline = true     -- Show which line your cursor is on
vim.opt.termguicolors = true  -- Your terminal emulator will display 24-bit RGB colors (millions of colors) instead of the limited 256-color palette
vim.opt.updatetime = 300      -- How long Neovim waits after you stop typing before triggering "CursorHold" (default to 4000 ms)
vim.opt.timeoutlen = 500      -- If you start typing a key mapping (like your leader key), this is how long Neovim waits for the next keystroke before deciding you're done (default to 1000 ms)
vim.opt.splitbelow = true     -- new splits appear below your current window and not above your current window
vim.opt.splitright = true     -- new vertical splits appear to the right of your current window and not to the left 

-- Status Line Configuration
function StatuslineSpell()
    if vim.o.spell then
        return "[SPELL: " .. vim.o.spelllang .. "]"
    else
        return ""
    end
end

vim.opt.laststatus = 2  -- Always show the status line (1 = only in multi-window mode, 2 = always)
vim.opt.statusline = table.concat({
    --"%F%m%r%h %w",                 -- File path, modified, read-only, help, preview
    "%f%m%r%h %w",                 -- File name, modified, read-only, help, preview
    "Line: %l/%L (%P) Col: %c",    -- Line number, percentage and column position
    "[%Y]",                        -- File Type
    "[%{&fileencoding?&fileencoding:&encoding}][%{&fileformat}]", -- Encoding and Format
    "%{v:lua.StatuslineSpell()}",  -- Spell check status
    "CWD: %{getcwd()}",            -- Current working directory
}, " | ")
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Search Behavior
vim.opt.ignorecase = true     -- Ignore case in searches unless uppercase is used
vim.opt.smartcase = true      -- Override 'ignorecase' if search pattern contains uppercase letters
vim.opt.hlsearch = true       -- Highlight search results
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR>', { silent = true }) -- Clear highlights on pressing <Esc><Esc> in normal mode
vim.opt.incsearch = true      -- Incremental search: highlight matches as you type
vim.opt.inccommand = 'split' -- Preview substitutions live, as you type!
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Clipboard Behavior
vim.opt.clipboard = "" -- Prevents Neovim from using the system clipboard

-- Toggle Clipboard Function
function ToggleClipboard()
    if vim.o.clipboard == "unnamedplus" then
        vim.o.clipboard = ""
        print("System Clipboard Disabled")
    else
        vim.o.clipboard = "unnamedplus"
        print("System Clipboard Enabled")
    end
end

-- Set keybinding to <leader>tc
vim.keymap.set("n", "<leader>tc", ":lua ToggleClipboard()<CR>", { remap = false, silent = true })

-- Yank to system clipboard
vim.keymap.set("n", "<leader>y", '"+y', { remap = false, silent = true })
vim.keymap.set("v", "<leader>y", '"+y', { remap = false, silent = true })
vim.keymap.set("n", "<leader>Y", '"+Y', { remap = false, silent = true }) -- Yank entire line

-- Paste from system clipboard
vim.keymap.set("n", "<leader>p", '"+p', { remap = false, silent = true })
vim.keymap.set("n", "<leader>P", '"+P', { remap = false, silent = true })
vim.keymap.set("v", "<leader>p", '"+p', { remap = false, silent = true })
vim.keymap.set("v", "<leader>P", '"+P', { remap = false, silent = true })
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Performance and Behavior
vim.opt.lazyredraw = true     -- Improve performance by not redrawing during macros and fast scrolling
vim.opt.magic = true          -- Enable extended regex features in search patterns
vim.opt.showmatch = true      -- Highlight matching parenthesis, bracket, or brace
vim.opt.mat = 2               -- Briefly jump to matching bracket before returning cursor
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Encoding
vim.opt.encoding = "utf8"     -- Use UTF-8 encoding
vim.opt.fileformats = { "unix", "dos", "mac" } -- Support multiple file formats for compatibility
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Remove Trailing Whitespace on Save for Python files
vim.cmd([[
function! DeleteTrailingWS()
    let save_cursor = getpos(".")
    silent! %s/\s\+$//e
    call setpos(".", save_cursor)
endfunction
autocmd BufWritePre *.py,*.pyx call DeleteTrailingWS()
]])
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Buffer Close
vim.keymap.set("n", "<leader>bc", ":bdelete<CR>", { remap = false, silent = true })
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- User command: Create missing directories without writing the file.
vim.api.nvim_create_user_command("CreateDir", function()
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.fnamemodify(file, ":p:h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
    print("Created directory: " .. dir)
  else
    print("Directory already exists: " .. dir)
  end
end, {})
--------------------------------------------------------------------------------


