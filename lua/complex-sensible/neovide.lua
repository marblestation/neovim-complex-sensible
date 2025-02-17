
--------------------------------------------------------------------------------
if vim.g.neovide then
    -- Map Command+A to select all text in Neovide
    vim.keymap.set('n', '<D-a>', 'ggVG', { remap = false, silent = true })  -- Normal mode: Select all
    vim.keymap.set('i', '<D-a>', '<Esc>ggVG', { remap = false, silent = true })  -- Insert mode: Exit insert, then select all
    vim.keymap.set('c', '<D-a>', '<C-c>', { remap = false, silent = true })  -- Command mode: Cancel input (Cmd+A isn't useful here)
    ---- Enable system clipboard shortcuts
    -- Map Command+C to copy to system clipboard
    vim.keymap.set('v', '<D-c>', '"+y', { remap = false, silent = true })
    -- Map Command+X to cut (copy and delete)
    vim.keymap.set('v', '<D-x>', '"+d', { remap = false, silent = true })
    -- Map Command+V to paste from system clipboard
    vim.keymap.set('n', '<D-v>', '"+p', { remap = false, silent = true })
    vim.keymap.set('c', '<D-v>', '<C-r>+', { remap = false, silent = true })
    vim.keymap.set('i', '<D-v>', function()
        -- Enable paste mode to avoid auto-indenting
        vim.cmd('set paste')
        -- Paste the clipboard content
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>+", true, true, true), 'n', false)
        -- Defer turning off paste mode to let the paste complete
        vim.defer_fn(function()
            vim.cmd('set nopaste')
        end, 100)
    end, { remap = false, silent = true })

    -- Enable mouse support
    vim.o.mouse = "a"

    -- Adjust Neovide scaling 
    vim.g.neovide_scale_factor = 1.0

    -- Smooth scrolling
    vim.g.neovide_scroll_animation_length = 0.2

    -- Cursor animation
    vim.g.neovide_cursor_animation_length = 0.05
end
--------------------------------------------------------------------------------

