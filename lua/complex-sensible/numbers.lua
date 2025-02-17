
--------------------------------------------------------------------------------
function CycleLineNumbers()
    -- Current state: No line numbers
    if vim.o.number == false and vim.o.relativenumber == false then
        -- Switch to absolute line numbers
        vim.o.number = true
        vim.o.relativenumber = false
        print("Line Numbers: Absolute")
    
    -- Current state: Absolute line numbers
    elseif vim.o.number == true and vim.o.relativenumber == false then
        -- Switch to relative line numbers (with current line showing absolute)
        vim.o.number = true
        vim.o.relativenumber = true
        print("Line Numbers: Relative")
    
    -- Current state: Relative line numbers
    else
        -- Switch back to no line numbers
        vim.o.number = false
        vim.o.relativenumber = false
        print("Line Numbers: Disabled")
    end
end

vim.keymap.set('n', '<leader>tn', ':lua CycleLineNumbers()<CR>', { silent = true })
--------------------------------------------------------------------------------
