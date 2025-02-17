
------------------------------------------------------------------------------
-- Lexplorer Toggle
-- - Open in current file path
-- - Jump to current filename
vim.keymap.set("n", "<leader>nf", function()
    local current_file = vim.fn.expand("%:t")   -- Get file name
    local current_dir = vim.fn.expand("%:p:h")  -- Get the directory of the current file
    local is_netrw_open = false

    -- Check if NetRW is already open
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "netrw" then
            is_netrw_open = true
            vim.api.nvim_win_close(win, true)  -- Close NetRW
            return
        end
    end

    -- If NetRW is not open, open it in the current file’s directory
    if not is_netrw_open then
        vim.cmd("Lexplore " .. vim.fn.fnameescape(current_dir))
        vim.cmd("CloseNoName")
        vim.defer_fn(function()
            local pattern = vim.fn.escape(current_file, "/")
            -- 'n' flag: do not update the last search pattern (and hence the history)
            local pos = vim.fn.searchpos(pattern, "n")
            if pos[1] > 0 then
                -- Move cursor to filename matching current filename
                pos[2] = 0
                vim.api.nvim_win_set_cursor(0, pos)
            end
        end, 100)
    end
end, { remap = false, silent = true })

-- Function to close all unmodified [No Name] buffers
-- * This is useful because Lexplore generates them sometimes for no good reason
function CloseNoNameBuffers()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf) == "" then
            -- Only close the buffer if it's not modified
            if not vim.api.nvim_buf_get_option(buf, "modified") then
                vim.api.nvim_buf_delete(buf, { force = true })
            else
                print("Skipping buffer " .. buf .. " (unsaved changes)")
            end
        end
    end
end

-- Create a command to call it easily
vim.api.nvim_create_user_command("CloseNoName", CloseNoNameBuffers, {})


-- Close NetRW when pressing 'q'
vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true, remap = false, nowait = true })
    end,
})

-- Automatically close NetRW when opening a file
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        -- Check if we are no longer in NetRW
        if vim.bo.filetype ~= "netrw" then
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == "netrw" then
                    vim.api.nvim_win_close(win, true)  -- Close NetRW window
                end
            end
        end
    end,
})
------------------------------------------------------------------------------

