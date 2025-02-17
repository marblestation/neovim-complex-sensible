--==============================================================================
--==============================================================================
--- PLUGINS
--==============================================================================
--==============================================================================
---
-- [[ Install `lazy.nvim` plugin manager ]]
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
local lazyversion = 'v11.17.1'

-- Use vim.uv if available (nvim > 0.9), otherwise fallback to vim.loop
local uv = vim.uv or vim.loop

-- Helper function to run system commands and handle errors
local function run_cmd(cmd)
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to run command: " .. table.concat(cmd, " ") .. "\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
  return out
end

if not uv.fs_stat(lazypath) then
  run_cmd { 'git', 'clone', '--filter=blob:none', lazyrepo, lazypath }
  run_cmd { 'git', '-C', lazypath, 'checkout', 'tags/' .. lazyversion }
end

vim.opt.runtimepath:prepend(lazypath)


-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  To update plugins you can run
--    :Lazy update
require('lazy').setup(
    {
        --------------------------------------------------------------------------------
        {
            'smoka7/hop.nvim',
            version = "*",
            config = function(_, opts)
            local hop = require('hop')
            local directions = require('hop.hint').HintDirection
            hop.setup(opts)
            vim.keymap.set('', 'f', function()
                    hop.hint_char1({ direction = nil, current_line_only = false })
            end, {remap=true})

            end,
            opts = {
                    keys = 'etovxqpdygfblzhckisuran'
            }
        },
        --------------------------------------------------------------------------------

        --------------------------------------------------------------------------------
        ---- to comment visual regions/lines
        { 
              'numToStr/Comment.nvim', 
              event = "VeryLazy",
              config = function(_, opts)
                  require("Comment").setup(opts)

                  -- Keybindings for commenting
                  vim.keymap.set("n", "<leader>cc", "gcc", { remap = true, silent = true }) -- Toggle comment in normal mode
                  vim.keymap.set("v", "<leader>cc", "gc", { remap = true, silent = true }) -- Toggle comment in visual mode
                  vim.keymap.set("n", "<leader>c<space>", "gcc", { remap = true, silent = true }) -- Toggle comment (alternative)
                  vim.keymap.set("v", "<leader>c<space>", "gc", { remap = true, silent = true }) -- Toggle comment (alternative)
              end,
              opts = {
                  ---Add a space b/w comment and the line
                  padding = false,
                  ---Whether the cursor should stay at its position
                  sticky = true,
                  ---Lines to be ignored while (un)comment
                  ignore = nil,
                  ---LHS of toggle mappings in NORMAL mode
                  toggler = {
                      ---Line-comment toggle keymap
                      line = 'gcc',
                      ---Block-comment toggle keymap
                      block = 'gbc',
                  },
                  ---LHS of operator-pending mappings in NORMAL and VISUAL mode
                  opleader = {
                      ---Line-comment keymap
                      line = 'gc',
                      ---Block-comment keymap
                      block = 'gb',
                  },
                  ---LHS of extra mappings
                  extra = {
                      ---Add comment on the line above
                      above = 'gcO',
                      ---Add comment on the line below
                      below = 'gco',
                      ---Add comment at the end of line
                      eol = 'gcA',
                  },
                  ---Enable keybindings
                  ---NOTE: If given `false` then the plugin won't create any mappings
                  mappings = {
                      ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
                      basic = true,
                      ---Extra mapping; `gco`, `gcO`, `gcA`
                      extra = true,
                  },
                  ---Function to call before (un)comment
                  pre_hook = nil,
                  ---Function to call after (un)comment
                  post_hook = nil,
              }
        },
        --------------------------------------------------------------------------------

        --------------------------------------------------------------------------------
        {
            'akinsho/bufferline.nvim',
            version = "*",
            --dependencies = 'nvim-tree/nvim-web-devicons',
            config = function()
                require("bufferline").setup({
                    options = {
                        mode = "buffers",
                        numbers = "none",
                        indicator = {
                            icon = '▎',
                            style = 'icon', -- | 'underline' | 'none',
                        },
                        buffer_close_icon = 'X',
                        modified_icon = '● ',
                        close_icon = 'X',
                        color_icons = false,
                        diagnostics = false,
                        show_buffer_icons = false,
                        show_buffer_close_icons = false,
                        show_close_icon = false,
                        separator_style = "thin",
                        always_show_bufferline = true,
                    }
                })

                -- Keybindings to switch between buffers
                vim.keymap.set("n", "<C-n>", ":BufferLineCycleNext<CR>", { remap = false, silent = true })
                vim.keymap.set("n", "<C-p>", ":BufferLineCyclePrev<CR>", { remap = false, silent = true })
            end
        },
        --------------------------------------------------------------------------------

        --------------------------------------------------------------------------------
        {
            "windwp/nvim-autopairs",
            event = "InsertEnter", -- Load only when entering insert mode
            config = function()
                require("nvim-autopairs").setup({
                    check_ts = true, -- Enable Treesitter integration (for better handling)
                })
            end
        },
        --------------------------------------------------------------------------------

        --------------------------------------------------------------------------------
        {
            "echasnovski/mini.starter",
            config = function()
                local starter = require("mini.starter")

                starter.setup({
                    items = {
                        -- Bookmarks
                        { name = "ScratchPad", action = "edit ~/Sync/Thing/Notes/pages/ScratchPad.md", section = "Bookmarks" },
                        { name = "Notes", action = "edit ~/Sync/Thing/Notes/pages/Index.md", section = "Bookmarks" },

                        -- Built-in Commands
                        { name = "File Explorer", action = "Lexplore", section = "Builtin actions" },
                        starter.sections.builtin_actions(),

                        -- Recent Files
                        --starter.sections.recent_files(5, true), -- Show last N recent files

                    },
                    header = [[
    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
    ██║╚██╗██║██╔══╝  ██║   ██║ ██║ ██║ ██║██║╚██╔╝██║
    ██║ ╚████║███████╗╚██████╔╝ ██████║ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝     ╚═╝
                    ]],
                })

                -- Keybinding to open the start screen
                vim.keymap.set("n", "<leader>ww", ":lua MiniStarter.open()<CR>", { remap = false, silent = true })
            end
        },
        --------------------------------------------------------------------------------


        --------------------------------------------------------------------------------
        {
            "jake-stewart/multicursor.nvim",
            branch = "1.0",
            config = function()
                local mc = require("multicursor-nvim")

                mc.setup()

                local set = vim.keymap.set

                -- Add or skip adding a new cursor by matching word/selection
                set({"x"}, "<C-n>",
                    function() mc.matchAddCursor(1) end)
                set({"x"}, "<C-x>",
                    function() mc.matchSkipCursor(1) end)
                set({"x"}, "<C-p>",
                    function() mc.matchAddCursor(-1) end)
                set({"x"}, "<C-z>",
                    function() mc.matchSkipCursor(-1) end)

                -- Clear cursors
                set("n", "<esc>", function()
                    if not mc.cursorsEnabled() then
                        mc.enableCursors()
                    elseif mc.hasCursors() then
                        mc.clearCursors()
                    else
                        -- Default <esc> handler.
                    end
                end)

                -- Customize how cursors look.
                local hl = vim.api.nvim_set_hl
                hl(0, "MultiCursorCursor", { link = "Cursor" })
                hl(0, "MultiCursorVisual", { link = "Visual" })
                hl(0, "MultiCursorSign", { link = "SignColumn"})
                hl(0, "MultiCursorMatchPreview", { link = "Search" })
                hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
                hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
                hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
            end
        },
        --------------------------------------------------------------------------------


        --------------------------------------------------------------------------------
        {
            "lervag/vimtex",
            config = function()
                -- Set the compiler to latexmk
                vim.g.vimtex_compiler_method = "latexmk"

                -- Quickfix settings
                vim.g.vimtex_quickfix_mode = 2    -- 0 = off, 1 = show & active, 2 = show only
                vim.g.vimtex_quickfix_open_on_warning = 0 -- Do not open on warnings

                -- Disable automatic viewer
                vim.g.vimtex_view_automatic = 0

                -- Keybindings
                vim.keymap.set("n", "<leader>lp", ":VimtexCompileSS<CR>", { remap = false, silent = true })
                vim.keymap.set("n", "<leader>lc", ":VimtexClean<CR>", { remap = false, silent = true })
                vim.keymap.set("n", "<leader>lt", ":VimtexTocToggle<CR>", { remap = false, silent = true })
                vim.keymap.set("n", "<leader>lo", ":VimtexView<CR>", { remap = false, silent = true })


                -- Ignore warnings (if needed)
                vim.g.vimtex_quickfix_ignore_filters = {
                    "Warning",
                    "warning",
                }
            end
        },
        --------------------------------------------------------------------------------

        --------------------------------------------------------------------------------
        {
            "navarasu/onedark.nvim",
            lazy = false, -- Load immediately
            priority = 1000, -- Ensures it loads first
            config = function()
                require("onedark").setup({
                    style = "darker", -- Choose between "dark", "darker", "cool", "warm", "deep"
                    transparent = true, -- Set to true if you want a transparent background
                    colors = {
                        -- brighter colors than the default ones:
                        fg = "#d0d8e7",
                        grey = "#838995",
                        light_grey = "#aab1c0",
                    },
                })
                require("onedark").load()
            end,
        },
        --------------------------------------------------------------------------------
        ---
        {
            "nvim-lualine/lualine.nvim",
            --dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional: for icons
            config = function()
                require("lualine").setup({
                    options = {
                        icons_enabled = true,
                        theme = 'auto',
                        component_separators = { left = '|', right = '|'},
                        section_separators = { left = '|', right = '|'},
                        disabled_filetypes = {
                          statusline = {},
                          winbar = {},
                        },
                        ignore_focus = {},
                        always_divide_middle = true,
                        always_show_tabline = false,
                        globalstatus = false,
                        refresh = {
                          statusline = 100,
                          tabline = 100,
                          winbar = 100,
                        }
                      },
                      sections = {
                        lualine_a = {'mode'},
                        lualine_b = {
                            {
                                'filename',
                                icons_enabled = false,
                                file_status = true,      -- Displays file status (readonly status, modified status)
                                newfile_status = true,  -- Display new file status (new file means no write after created)
                                path = 1,                -- 0: Just the filename
                                                       -- 1: Relative path
                                                       -- 2: Absolute path
                                                       -- 3: Absolute path, with tilde as the home directory
                                                       -- 4: Filename and parent dir, with tilde as the home directory

                                shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                                                       -- for other components. (terrible name, any suggestions?)
                                symbols = {
                                    modified = '[+]',      -- Text to show when the file is modified.
                                    readonly = '[Read only]',      -- Text to show when the file is non-modifiable or readonly.
                                    unnamed = '[No Name]', -- Text to show for unnamed buffers.
                                    newfile = '[New]',     -- Text to show for newly created file before first write
                                }
                            },
                        },
                        lualine_c = {},
                        lualine_x = {
                            {function() return StatuslineSpell() end},
                            {
                                'fileformat',
                                icons_enabled = false,
                            },
                            {
                                'filetype',
                                icons_enabled = false,
                            },
                        },
                        lualine_y = {'progress'},
                        lualine_z = {'location'}
                      },
                      inactive_sections = {
                        lualine_a = {},
                        lualine_b = {},
                        lualine_c = {'filename'},
                        lualine_x = {'location'},
                        lualine_y = {},
                        lualine_z = {}
                      },
                      tabline = {},
                      winbar = {},
                      inactive_winbar = {},
                      extensions = {},
                })
            end,
        },

        --------------------------------------------------------------------------------
        {
            {
                -- Better highlights
                "nvim-treesitter/nvim-treesitter",
                build = ":TSUpdate",
                config = function () 
                    local configs = require("nvim-treesitter.configs")

                    -- Placing parsers outside nvim-treesitter location allows to copy already compiled parsers
                    -- This is useful for Raspberry Pi, which can freeze with compilation
                    -- Location: $HOME/.local/share/nvim/site/nvim-treesitter
                    local parserpath = vim.fn.stdpath("data") .. "/site/nvim-treesitter"
                    vim.opt.runtimepath:prepend(parserpath)

                    configs.setup({
                        parser_install_dir = parserpath,
                        ensure_installed = {
                            ---- Default
                            "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",

                            ---- Systems and Low-Level Programming
                            "cpp", "rust", "fortran", "arduino",
                            --"ada", "v", "odin", "cuda", "nasm", "llvm",

                            ---- High-Level Programming Languages
                            "java", "c_sharp",

                            ---- Functional and Academic Languages
                            "r",
                            --"haskell", "ocaml", "elixir", "erlang", "clojure", 
                            --"commonlisp", "scala", "julia", "dart",

                            ---- Scripting and Dynamic Languages
                            "python", "ruby", "perl", "php", "bash", 
                            --"fish", "powershell",

                            ---- Domain-Specific and Emerging Languages
                            "go",
                            --"kotlin", "swift",
                            --"solidity", "cairo", "gleam",

                            ---- Specialized and Niche Languages
                            --"gdscript", "zig", "nim",
                            --"racket", "scheme",

                            ---- Web Development
                            "html", "css", "scss", 
                            "javascript", "typescript", "tsx",
                            "jinja", "jinja_inline", "liquid", 
                            --"svelte", "vue", "astro", 
                            --"pug", "slim", 

                            ---- Configuration/Markup Languages, Data/Serialization Formats
                            "csv", "tsv", 
                            "yaml", "toml", "json", "xml",
                            "sql", 
                            --"ini",
                            --"graphql", 
                            --"proto", "textproto",

                            ---- Tools/System Configuration
                            "make", "cmake",
                            "git_rebase", "gitattributes", "git_config", 'gitignore', 'gitcommit',
                            "diff",
                            "dockerfile", "nginx", 
                            "tmux", "ssh_config", 
                            --"readline", "udev",
                            --"terraform", "helm", "nix",
                           
                            ---- Latex
                            "bibtex", 
                            --"latex", -- latex requires node

                            ---- Documentation
                            "comment",
                            --"rst", "doxygen",
                        },
                        sync_install = true, -- Install parsers synchronously
                        auto_install = false, -- Automatically install missing parsers when entering buffer
                        highlight = { 
                            enable = true,
                            -- disable slow treesitter highlight for large files
                            disable = function(lang, buf)
                                local max_filesize = 100 * 1024 -- 100 KB
                                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                                if ok and stats and stats.size > max_filesize then
                                    return true
                                end
                            end,
                        },
                        indent = { enable = true },  
                    })
                end,
            }
        },
        --------------------------------------------------------------------------------
        
    }, {
        -- Lazy Plugin Options
        concurrency = 1,  -- This forces Lazy.nvim to install/update plugins one at a time
        rocks = {
            enabled = false,
        },
        ui = {
            icons = {
                cmd = "[cmd]",
                config = "[conf]",
                debug = "● ",
                event = "[event]",
                favorite = "[fav]",
                ft = "[ft]",
                init = "[init]",
                import = "[import]",
                keys = "[keys]",
                lazy = "[lazy]",
                loaded = "●",
                not_loaded = "○",
                plugin = "[plugin]",
                runtime = "[runtime]",
                require = "[require]",
                source = "[src]",
                start = "[start]",
                task = "✔ ",
                list = {
                    "●",
                    "➜",
                    "★",
                    "‒",
                },
            },
        },
    }
)



