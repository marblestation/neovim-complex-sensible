
--------------------------------------------------------------------------------
-- Helper: Center a string within a given width.
local function center(s, width)
    local len = #s
    if len >= width then return s end
    local left = math.floor((width - len) / 2)
    local right = width - len - left
    return string.rep(" ", left) .. s .. string.rep(" ", right)
end

-- Generate a calendar for a given month and year.
-- week_start: "su" (default) or "mo"
-- highlight: if true, the current day (if in the month) is wrapped in []
function generate_calendar(year, month, week_start, highlight)
    week_start = week_start or "su"
    highlight = highlight or false
    local now = os.date("*t")
    local is_current_month = (now.year == year and now.month == month)
    local cell_width = 4    -- each day occupies exactly 4 characters

    -- Build weekday header using fixed-width cells.
    local weekdays = (week_start == "mo") and {"Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"}
                                           or {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"}
    local header_cells = {}
    for _, abbr in ipairs(weekdays) do
        table.insert(header_cells, center(abbr, cell_width))
    end
    local header = table.concat(header_cells, "")

    local lines = {}
    table.insert(lines, header)

    -- Calculate number of days in the month.
    local days_in_month = os.date("*t", os.time{year = year, month = month + 1, day = 0}).day

    -- Determine the weekday index of the first day.
    local first_weekday = tonumber(os.date("%w", os.time{year = year, month = month, day = 1}))
    if week_start == "mo" then
        first_weekday = (first_weekday + 6) % 7
    end

    local line = ""
    local col = 0
    -- Pad the first week with empty cells.
    for i = 1, first_weekday do
        line = line .. string.rep(" ", cell_width)
        col = col + 1
    end

    -- Print each day.
    for day = 1, days_in_month do
        local cell = ""
        if highlight and is_current_month and day == now.day then
            cell = string.format("[%2d]", day)    -- exactly 6 characters
        else
            cell = string.format(" %2d ", day)     -- exactly 6 characters
        end
        line = line .. cell
        col = col + 1
        if col == 7 then
            table.insert(lines, line)
            line = ""
            col = 0
        end
    end
    if line ~= "" then
        for i = col + 1, 7 do
            line = line .. string.rep(" ", cell_width)
        end
        table.insert(lines, line)
    end

    return table.concat(lines, "\n")
end

-- Returns the calendar string with a header showing the month name and year centered.
function get_calendar_str(year, month, week_start, highlight)
    local cell_width = 4
    local block_width = 7 * cell_width
    local monthName = os.date("%B", os.time{year = year, month = month, day = 1})
    local header_str = string.format("%s %d", monthName, year)
    header_str = center(header_str, block_width)
    local cal_body = generate_calendar(year, month, week_start, highlight)
    return header_str .. "\n" .. cal_body
end

-- Helper: Join multiple calendar strings horizontally.
-- Each calendar block is split into lines, padded to equal width, then merged.
function join_calendars_horizontally(cal_strs, sep)
    sep = sep or "     "    -- separator between calendars
    local split_calendars = {}
    local max_lines = 0
    for i, cal in ipairs(cal_strs) do
        local lines = {}
        for line in cal:gmatch("[^\n]+") do
            table.insert(lines, line)
        end
        split_calendars[i] = lines
        if #lines > max_lines then max_lines = #lines end
    end
    for i, lines in ipairs(split_calendars) do
        local width = 0
        for _, line in ipairs(lines) do
            if #line > width then width = #line end
        end
        for j, line in ipairs(lines) do
            if #line < width then
                lines[j] = line .. string.rep(" ", width - #line)
            end
        end
        while #lines < max_lines do
            table.insert(lines, string.rep(" ", width))
        end
    end
    local merged_lines = {}
    for line_idx = 1, max_lines do
        local merged_line = {}
        for i, lines in ipairs(split_calendars) do
            table.insert(merged_line, lines[line_idx])
        end
        table.insert(merged_lines, table.concat(merged_line, sep))
    end
    return table.concat(merged_lines, "\n")
end

-- Main function to insert a calendar grid.
-- month_count: 3 or 12.
-- week_start: "su" or "mo".
-- current_in_middle: For a 3‑month grid, if true the current month appears in the middle.
-- highlight: if true, the current day (in the current month) is highlighted.
function InsertCalendarGrid(month_count, week_start, current_in_middle, highlight)
    week_start = week_start or "su"
    month_count = month_count or 3
    highlight = highlight or false

    if month_count == 1 then
        local now = os.date("*t")
        local year = now.year
        local month = now.month
        local cal_str = get_calendar_str(year, month, week_start, highlight)
        vim.api.nvim_put(vim.split(cal_str, "\n"), "c", false, true)
    
    elseif month_count == 3 then
        local now = os.date("*t")
        local year = now.year
        local month = now.month
        local cal_strs = {}

        if current_in_middle then
            local prev_year, prev_month
            if month == 1 then
                prev_month = 12
                prev_year = year - 1
            else
                prev_month = month - 1
                prev_year = year
            end

            local next_year, next_month
            if month == 12 then
                next_month = 1
                next_year = year + 1
            else
                next_month = month + 1
                next_year = year
            end

            table.insert(cal_strs, get_calendar_str(prev_year, prev_month, week_start, false))
            table.insert(cal_strs, get_calendar_str(year, month, week_start, highlight))
            table.insert(cal_strs, get_calendar_str(next_year, next_month, week_start, false))
        else
            for i = 0, 2 do
                local cal_year = year
                local cal_month = month + i
                if cal_month > 12 then
                    cal_month = cal_month - 12
                    cal_year = cal_year + 1
                end
                table.insert(cal_strs, get_calendar_str(cal_year, cal_month, week_start, (i == 0 and highlight)))
            end
        end
        local merged = join_calendars_horizontally(cal_strs)
        vim.api.nvim_put(vim.split(merged, "\n"), "c", false, true)

    elseif month_count == 12 then
        local now = os.date("*t")
        local year = now.year
        local all_cal = {}

        for m = 1, 12 do
            local hl = (year == now.year and m == now.month) and highlight or false
            table.insert(all_cal, get_calendar_str(year, m, week_start, hl))
        end

        local grid_lines = {}
        for row = 1, 4 do
            local row_cal = {}
            for col = 1, 3 do
                local idx = (row - 1) * 3 + col
                table.insert(row_cal, all_cal[idx])
            end
            table.insert(grid_lines, join_calendars_horizontally(row_cal))
        end

        local merged_full = table.concat(grid_lines, "\n\n")
        vim.api.nvim_put(vim.split(merged_full, "\n"), "c", false, true)
    end
end

-- Insert a 3‑month calendar with the current month in the middle.
-- Weeks start on Monday and the current day is highlighted.
vim.keymap.set("n", "<leader>c3", function() InsertCalendarGrid(3, "mo", true, true) end, { noremap = true, silent = true })

-- Insert a 1‑month calendar
-- The current day in the current month will be highlighted.
vim.keymap.set("n", "<leader>c1", function() InsertCalendarGrid(1, "mo", false, true) end, { noremap = true, silent = true })

-- Insert a full‑year calendar (12 months) with weeks starting on Monday.
-- The current day in the current month will be highlighted.
vim.keymap.set("n", "<leader>cy", function() InsertCalendarGrid(12, "mo", false, true) end, { noremap = true, silent = true })
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Insert DateTime
function InsertDatetime(in_insert)
    local datetime = os.date("%Y-%m-%d %H:%M:%S")  -- Customize the format

    if in_insert then
        -- Insert mode: Insert at the cursor position
        --local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        --vim.api.nvim_buf_set_text(0, line - 1, col, line - 1, col, { datetime })
        vim.api.nvim_put({ datetime }, "c", false, true)
    else
        -- Normal mode: Insert after the cursor position with a leading space
        vim.api.nvim_put({ " " .. datetime }, "c", false, true)
    end
end

-- In insert mode, pass true so no leading space is added.
vim.keymap.set("i", "<leader>dt", function() InsertDatetime(true) end, { remap = false, silent = true })

-- In normal mode, pass false so that a leading space is added.
vim.keymap.set("n", "<leader>dt", function() InsertDatetime(false) end, { remap = false, silent = true })
-- :Datetime
vim.api.nvim_create_user_command('Datetime', function()
    InsertDatetime()
end, {})
--------------------------------------------------------------------------------

