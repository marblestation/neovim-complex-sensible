
--------------------------------------------------------------------------------
-- Spell Checking Setup
-- wget -P /Users/marble/.local/share/nvim/site/spell/ https://ftp.nluug.nl/pub/vim/runtime/spell/en.utf-8.spl
-- wget -P /Users/marble/.local/share/nvim/site/spell/ https://ftp.nluug.nl/pub/vim/runtime/spell/en.utf-8.sug
-- wget -P /Users/marble/.local/share/nvim/site/spell/ https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.spl
-- wget -P /Users/marble/.local/share/nvim/site/spell/ https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.sug
-- wget -P /Users/marble/.local/share/nvim/site/spell/ https://ftp.nluug.nl/pub/vim/runtime/spell/fr.utf-8.spl
-- wget -P /Users/marble/.local/share/nvim/site/spell/ https://ftp.nluug.nl/pub/vim/runtime/spell/fr.utf-8.sug
-- wget -P /Users/marble/.local/share/nvim/site/spell/ https://ftp.nluug.nl/pub/vim/runtime/spell/ca.utf-8.spl
-- wget -P /Users/marble/.local/share/nvim/site/spell/ https://ftp.nluug.nl/pub/vim/runtime/spell/ca.utf-8.sug
vim.keymap.set("n", "<leader>sd", ":lua DownloadSpellFiles()<CR>", { remap = false, silent = true }) -- Download missing spell files
vim.keymap.set("n", "<leader>ss", ":lua CycleSpellLang()<CR>", { remap = false, silent = true }) -- Key mapping to cycle through spell languages including turning it on/off
vim.keymap.set("n", "<leader>sn", "]s", { remap = false }) -- Jump to next misspelled word
vim.keymap.set("n", "<leader>sp", "[s", { remap = false }) -- Jump to previous misspelled word
vim.keymap.set("n", "<leader>sa", "zg", { remap = false }) -- Add word to dictionary
vim.keymap.set("n", "<leader>s?", "z=", { remap = false }) -- Show spelling suggestions

---- Enable spell check automatically for specific file types
--vim.cmd([[
--    autocmd FileType markdown setlocal spell
--    autocmd FileType text setlocal spell
--    autocmd FileType tex setlocal spell
--]])

-- Toggle Between Multiple Spell Checking Languages
vim.opt.spelllang = "en_us" -- Default spell-checking language
vim.g.myLangList = { "en_us", "en_gb", "es_es", "ca", "fr" }
vim.g.myLangListFiles = { "en", "es", "ca", "fr" }

function CycleSpellLang()
    -- Get current spelllang and find its index in the list
    local currentLang = vim.o.spelllang
    local index = nil

    if not vim.o.spell then
        -- If spell checking is off, start the cycle by enabling it with the first language
        vim.o.spell = true
        vim.o.spelllang = vim.g.myLangList[1]
        print("Spell Checking Enabled: " .. vim.o.spelllang)
        return
    end

    -- Find the index in myLangList that matches currentLang.
    for i, lang in ipairs(vim.g.myLangList) do
        if lang == currentLang then
            index = i
            break
        end
    end

    -- Determine next action
    if index == #vim.g.myLangList then
        -- If at the last language, turn spell checking off
        vim.o.spell = false
        vim.o.spelllang = vim.g.myLangList[1]
        print("Spell Checking Disabled")
    else
        -- Otherwise, move to the next language
        local newIndex = (index or 0) + 1
        vim.o.spelllang = vim.g.myLangList[newIndex]
        print("Spell Checking Enabled: " .. vim.o.spelllang)
    end
end

-- Auto-Download Missing Spell Files
function DownloadSpellFiles()
    -- Determine the correct spell directory for Neovim
    local spell_dir = vim.fn.stdpath("data") .. "/site/spell/"
    vim.fn.mkdir(spell_dir, "p")  -- Create the directory if it doesn't exist

    -- Function to check if a command exists
    local function command_exists(cmd)
        return vim.fn.executable(cmd) == 1
    end

    -- Determine available downloader (prefer wget, fallback to curl)
    local downloader = nil
    if command_exists("wget") then
        downloader = "wget"
    elseif command_exists("curl") then
        downloader = "curl"
    else
        print("Error: Neither wget nor curl is installed. Cannot download spell files.")
        return
    end

    -- Iterate through language list and download missing files
    for _, lang in ipairs(vim.g.myLangListFiles or {}) do
        local spl_file = spell_dir .. lang .. ".utf-8.spl"
        local sug_file = spell_dir .. lang .. ".utf-8.sug"

        -- Check if spell files are missing
        if not vim.loop.fs_stat(spl_file) or not vim.loop.fs_stat(sug_file) then
            print("Downloading spell files for: " .. lang)
            local url_spl = "https://ftp.nluug.nl/pub/vim/runtime/spell/" .. lang .. ".utf-8.spl"
            local url_sug = "https://ftp.nluug.nl/pub/vim/runtime/spell/" .. lang .. ".utf-8.sug"

            if downloader == "wget" then
                local cmd_spl = "wget -q -O " .. vim.fn.shellescape(spl_file) .. " " .. vim.fn.shellescape(url_spl)
                local cmd_sug = "wget -q -O " .. vim.fn.shellescape(sug_file) .. " " .. vim.fn.shellescape(url_sug)
                
                print("Executing: " .. cmd_spl)
                vim.fn.system(cmd_spl)
                if vim.v.shell_error ~= 0 then
                    print("Error downloading " .. url_spl)
                end

                print("Executing: " .. cmd_sug)
                vim.fn.system(cmd_sug)
                if vim.v.shell_error ~= 0 then
                    print("Error downloading " .. url_sug)
                end
            elseif downloader == "curl" then
                local cmd_spl = "curl -s -o " .. vim.fn.shellescape(spl_file) .. " " .. vim.fn.shellescape(url_spl)
                local cmd_sug = "curl -s -o " .. vim.fn.shellescape(sug_file) .. " " .. vim.fn.shellescape(url_sug)
                
                print("Executing: " .. cmd_spl)
                vim.fn.system(cmd_spl)
                if vim.v.shell_error ~= 0 then
                    print("Error downloading " .. url_spl)
                end

                print("Executing: " .. cmd_sug)
                vim.fn.system(cmd_sug)
                if vim.v.shell_error ~= 0 then
                    print("Error downloading " .. url_sug)
                end
            end
        end
    end

    print("Spell files are up-to-date!")
end
--------------------------------------------------------------------------------

