----------------------------------------------------------------------------------
--- Markdown Links
----------------------------------------------------------------------------------

-- Helper to open (or create) a file.
-- If the filename is relative, it is resolved against the directory of the current file.
local function open_or_create_file(filename)
    local current_dir = vim.fn.expand("%:p:h")
    if not filename:match("^/") then
        filename = current_dir .. "/" .. filename
    end
    vim.cmd("edit " .. vim.fn.fnameescape(filename))
end

-- Helper function to get the precise visual selection.
local function get_visual_selection()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line = start_pos[2]
    local start_col = start_pos[3]
    local end_line = end_pos[2]
    local end_col = end_pos[3]
    local lines = vim.fn.getline(start_line, end_line)
    if #lines == 0 then
        return ""
    end
    if #lines == 1 then
        return string.sub(lines[1], start_col, end_col)
    else
        local selected_text = {}
        selected_text[1] = string.sub(lines[1], start_col)
        for i = 2, #lines - 1 do
            table.insert(selected_text, lines[i])
        end
        table.insert(selected_text, string.sub(lines[#lines], 1, end_col))
        return table.concat(selected_text, "\n")
    end
end

-- Function for visual mode:
-- Convert the visually selected text into a markdown link and open the corresponding file.
function VisualMarkdownLink()
    local text = get_visual_selection()
    text = vim.trim(text)
    if text == "" then
        return
    end

    -- Build the target filename using the selected text.
    local filename = text
    if not filename:match("%.md$") then
        filename = filename .. ".md"
    end

    local link = string.format("[%s](%s)", text, filename)

    -- Replace only the selected text with the markdown link.
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    vim.api.nvim_buf_set_text(0, start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, end_pos[3], { link })

    open_or_create_file(filename)
end

-- Function for normal mode:
-- If the cursor is on a markdown link, open (or create) the target file.
-- But do nothing if the link is external (http(s)://) or if it is an image.
function OpenMarkdownLink()
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local col = cursor[2] + 1    -- adjust to 1-indexed

    -- Pattern captures an optional "!" at the beginning, then the link text and link target.
    local s, e, bang, link_text, link_target = string.find(line, "(!?)%[([^%]]+)%]%(([^%)]+)%)")
    if s and e and col >= s and col <= e then
        -- Check for image extensions (case-insensitive)
        local image_extensions = {
            "png", "jpg", "jpeg", "gif", "bmp", "webp", "svg", "tiff", "ico", "heic"
        }
        
        -- Check if the link is an image by:
        -- 1. Having an image file extension, or
        -- 2. Starts with an exclamation mark, or
        -- 3. Contains an image file extension in the path
        local is_image = bang == "!" or 
                                         string.lower(link_target):match("%.(" .. table.concat(image_extensions, "|") .. ")$") or
                                         vim.tbl_contains(image_extensions, link_target:match("%.([^.]+)$"))
        
        if is_image or link_target:match("^https?://") then
            print("Image or external link: not opening")
            return
        end

        if not link_target:match("%.md$") then
            link_target = link_target .. ".md"
        end
        open_or_create_file(link_target)
    else
        print("No markdown link found under cursor")
    end
end

-- Create autocommands for markdown files.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        -- Map Enter in visual mode to create a markdown link from the selection.
        vim.api.nvim_buf_set_keymap(0, "v", "<CR>", ":lua VisualMarkdownLink()<CR>", { noremap = true, silent = true })
        -- Map Enter in normal mode to follow/open the markdown link.
        vim.api.nvim_buf_set_keymap(0, "n", "<CR>", ":lua OpenMarkdownLink()<CR>", { noremap = true, silent = true })
    end,
})

----------------------------------------------------------------------------------
--- Markdown lists
----------------------------------------------------------------------------------

-- Toggle TODO status function
function ToggleTodoStatus()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    
    if line:match("^%s*-%s*%[[ x]%]") then
        local new_line = line:gsub("%[[ x]%]", function(match)
            return match == "[ ]" and "[x]" or "[ ]"
        end)
        
        vim.api.nvim_set_current_line(new_line)
        vim.api.nvim_win_set_cursor(0, cursor_pos)
    end
end

-- Smart TODO item insert function
function SmartTodoItemInsert(above)
    local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
    local current_line = vim.api.nvim_buf_get_lines(0, current_line_num - 1, current_line_num, false)[1]
    
    -- Check if current line is a TODO item
    if current_line:match("^%s*-%s*%[[ x]%]") then
        -- Find the indentation of the current line
        local indent = current_line:match("^(%s*)")
        
        -- Create a new TODO item with the same indentation
        local new_todo = indent .. "- [ ] "
        
        -- Determine insert position
        local insert_line_num = above and current_line_num - 1 or current_line_num
        
        -- Insert the new TODO item
        vim.api.nvim_buf_set_lines(0, insert_line_num, insert_line_num, false, {new_todo})
        
        -- Enter insert mode at the end of the new line
        vim.api.nvim_win_set_cursor(0, {insert_line_num + 1, #new_todo})
        vim.cmd('startinsert!')
    else
        -- If not on a TODO item, use default o or O behavior
        vim.api.nvim_feedkeys(above and 'O' or 'o', 'n', true)
    end
end

-- Markdown TODO List Autocommand Group
vim.api.nvim_create_augroup('MarkdownTODOList', { clear = true })

-- Autocommand for Markdown files to set up keymappings
vim.api.nvim_create_autocmd('FileType', {
    group = 'MarkdownTODOList',
    pattern = 'markdown',
    callback = function(args)
        -- Toggle TODO status with <Space>
        vim.keymap.set('n', '<Space>', ToggleTodoStatus, { buffer = args.buf, remap = false, silent = true })
        
        -- Smart TODO item insert with o and O
        vim.keymap.set('n', 'o', function() SmartTodoItemInsert(false) end, { buffer = args.buf, remap = false, silent = true })
        vim.keymap.set('n', 'O', function() SmartTodoItemInsert(true) end, { buffer = args.buf, remap = false, silent = true })
    end
})
