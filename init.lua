-- ============================================================
--  DedRoot Neovim IDE
--  One-file config: beautiful, fast, C-ready
-- ============================================================

-- =====================
-- Leader
-- =====================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw because nvim-tree will replace it
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- =====================
-- Helpers
-- =====================

local map = vim.keymap.set
local opt = vim.opt

local function safe_require(name)
    local ok, module = pcall(require, name)
    if ok then
        return module
    end
    return nil
end

local function is_executable(cmd)
    return vim.fn.executable(cmd) == 1
end

-- =====================
-- Options
-- =====================

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"

opt.termguicolors = true
opt.background = "dark"

opt.mouse = "a"
opt.clipboard = "unnamedplus"

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true

opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.splitright = true
opt.splitbelow = true

opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12

opt.updatetime = 250
opt.timeoutlen = 400

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false

opt.laststatus = 3
opt.showmode = false

opt.fillchars = {
    eob = " ",
    fold = " ",
    foldopen = "",
    foldsep = " ",
    foldclose = "",
}

-- =====================
-- Basic keymaps
-- =====================

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all without saving" })

map("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close buffer" })
map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal split" })

map("n", "<leader>tt", "<cmd>botright split | resize 14 | terminal<CR>", { desc = "Open terminal" })

-- Compile and run current C file
map("n", "<leader>rr", function()
    local file = vim.fn.expand("%:p")
    local ext = vim.fn.expand("%:e")

    if ext ~= "c" then
        vim.notify("This is not a C file", vim.log.levels.WARN)
        return
    end

    vim.cmd("w")

    local out = vim.fn.expand("%:p:r")
    local cmd = "clang "
        .. vim.fn.shellescape(file)
        .. " -Wall -Wextra -std=c11 -o "
        .. vim.fn.shellescape(out)
        .. " && "
        .. vim.fn.shellescape(out)

    vim.cmd("botright split")
    vim.cmd("resize 14")
    vim.cmd("terminal " .. cmd)
end, { desc = "Compile and run C file" })

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 120 })
    end,
})

-- =====================
-- Lazy.nvim bootstrap
-- =====================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

opt.rtp:prepend(lazypath)

-- =====================
-- Plugins
-- =====================

require("lazy").setup({
    -- Theme
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "night",
                transparent = false,
                terminal_colors = true,
                styles = {
                    comments = { italic = true },
                    keywords = { italic = false },
                    functions = {},
                    variables = {},
                },
            })

            vim.cmd.colorscheme("tokyonight-night")
        end,
    },

    -- Icons
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "tokyonight",
                    globalstatus = true,
                    component_separators = { left = "│", right = "│" },
                    section_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = {
                        {
                            "filename",
                            path = 1,
                            symbols = {
                                modified = " ●",
                                readonly = " ",
                                unnamed = "[No Name]",
                            },
                        },
                    },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -- Beautiful file tabs
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    diagnostics = "nvim_lsp",
                    separator_style = "slant",
                    always_show_bufferline = true,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    color_icons = true,
                    modified_icon = "●",
                    close_icon = "",
                    left_trunc_marker = "",
                    right_trunc_marker = "",
                    offsets = {
                        {
                            filetype = "NvimTree",
                            text = "Files",
                            highlight = "Directory",
                            text_align = "left",
                        },
                    },
                },
            })

            map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
            map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
            map("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
            map("n", "<leader>bc", "<cmd>bd<CR>", { desc = "Close buffer" })
        end,
    },

    -- File tree
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                sort = {
                    sorter = "case_sensitive",
                },
                view = {
                    width = 34,
                    side = "left",
                },
                renderer = {
                    group_empty = true,
                    highlight_git = true,
                    highlight_opened_files = "name",
                    icons = {
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                            git = true,
                        },
                    },
                },
                filters = {
                    dotfiles = false,
                    custom = {
                        ".DS_Store",
                    },
                },
                git = {
                    enable = true,
                    ignore = false,
                },
                update_focused_file = {
                    enable = true,
                    update_root = false,
                },
                actions = {
                    open_file = {
                        quit_on_open = false,
                        resize_window = true,
                    },
                },
            })

            map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
            map("n", "<leader>E", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file tree" })
        end,
    },

    -- Telescope search
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")
            local builtin = require("telescope.builtin")

            telescope.setup({
                defaults = {
                    prompt_prefix = "  ",
                    selection_caret = "❯ ",
                    path_display = { "smart" },
                    sorting_strategy = "ascending",
                    layout_strategy = "horizontal",
                    layout_config = {
                        prompt_position = "top",
                        width = 0.9,
                        height = 0.85,
                        preview_width = 0.55,
                    },
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<Esc>"] = actions.close,
                        },
                    },
                },
            })

            map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
            map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
            map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
            map("n", "<leader>fc", builtin.commands, { desc = "Commands" })
            map("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
        end,
    },

    -- Treesitter syntax
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local treesitter = safe_require("nvim-treesitter.configs")
            if not treesitter then
                return
            end

            treesitter.setup({
                ensure_installed = {
                    "c",
                    "cpp",
                    "lua",
                    "rust",
                    "vim",
                    "vimdoc",
                    "bash",
                    "json",
                    "markdown",
                    "markdown_inline",
                    "make",
                    "cmake",
                },
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true,
                },
            })
        end,
    },

    -- Auto close brackets/quotes
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local autopairs = require("nvim-autopairs")

            autopairs.setup({
                check_ts = true,
                disable_filetype = { "TelescopePrompt" },
                fast_wrap = {},
            })

            local cmp = safe_require("cmp")
            if cmp then
                local cmp_autopairs = safe_require("nvim-autopairs.completion.cmp")
                if cmp_autopairs then
                    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
                end
            end
        end,
    },

    -- Completion engine
    {
        "hrsh7th/nvim-cmp",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
        },
        config = function()
            local cmp = require("cmp")

            local kind_icons = {
                Text = "󰉿",
                Method = "󰆧",
                Function = "󰊕",
                Constructor = "",
                Field = "󰜢",
                Variable = "󰀫",
                Class = "󰠱",
                Interface = "",
                Module = "",
                Property = "󰜢",
                Unit = "󰑭",
                Value = "󰎠",
                Enum = "",
                Keyword = "󰌋",
                Snippet = "",
                Color = "󰏘",
                File = "󰈙",
                Reference = "󰈇",
                Folder = "󰉋",
                EnumMember = "",
                Constant = "󰏿",
                Struct = "󰙅",
                Event = "",
                Operator = "󰆕",
                TypeParameter = "󰅲",
            }

            -- Custom C snippets source for #incl, main, printf, etc.
            local DedRootC = {}

            function DedRootC.new()
                return setmetatable({}, { __index = DedRootC })
            end

            function DedRootC:is_available()
                local ft = vim.bo.filetype
                return ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp"
            end

            function DedRootC:get_debug_name()
                return "dedroot_c"
            end

            function DedRootC:get_keyword_pattern()
                return [[\%(\k\|#\)\+]]
            end

            function DedRootC:complete(request, callback)
                local before = request.context.cursor_before_line or ""
                local word = before:match("([#%w_]+)$") or ""
                local items = {}

                local function snippet(label, insert_text, detail, documentation, sort_text)
                    table.insert(items, {
                        label = label,
                        filterText = label,
                        insertText = insert_text,
                        insertTextFormat = 2,
                        kind = 15,
                        detail = detail,
                        documentation = {
                            kind = "markdown",
                            value = documentation or "",
                        },
                        sortText = sort_text or label,
                    })
                end

                if word:match("^#?incl") or before:match("^%s*#%s*incl") then
                    snippet(
                        "#include <stdio.h>",
                        "#include <${1:stdio.h}>",
                        "C include",
                        "Insert a C header include.",
                        "0001"
                    )

                    snippet(
                        "#include <stdlib.h>",
                        "#include <${1:stdlib.h}>",
                        "C include",
                        "Memory, conversions, exit, rand.",
                        "0002"
                    )

                    snippet(
                        "#include <string.h>",
                        "#include <${1:string.h}>",
                        "C include",
                        "String functions: strlen, strcmp, strcpy, memcpy.",
                        "0003"
                    )

                    snippet(
                        "#include <unistd.h>",
                        "#include <${1:unistd.h}>",
                        "POSIX include",
                        "POSIX API: read, write, close, fork.",
                        "0004"
                    )
                end

                if word:match("^main") then
                    snippet(
                        "main function",
                        "int main(void)\n{\n    ${1:printf(\"Hello, world\\\\n\");}\n    return 0;\n}",
                        "C main",
                        "Create int main(void).",
                        "0010"
                    )
                end

                if word:match("^pr") or word:match("^printf") then
                    snippet(
                        "printf",
                        "printf(\"${1:text}\\\\n\");",
                        "C printf",
                        "Print text with newline.",
                        "0020"
                    )
                end

                if word:match("^fori") then
                    snippet(
                        "fori loop",
                        "for (int ${1:i} = 0; ${1:i} < ${2:n}; ${1:i}++)\n{\n    ${3}\n}",
                        "C for loop",
                        "Classic for loop.",
                        "0030"
                    )
                end

                if word:match("^if") then
                    snippet(
                        "if block",
                        "if (${1:condition})\n{\n    ${2}\n}",
                        "C if",
                        "If statement.",
                        "0040"
                    )
                end

                callback({ items = items, isIncomplete = false })
            end

            cmp.register_source("dedroot_c", DedRootC.new())

            cmp.setup({
                preselect = cmp.PreselectMode.Item,

                snippet = {
                    expand = function(args)
                        if vim.snippet then
                            vim.snippet.expand(args.body)
                        else
                            vim.api.nvim_put({ args.body }, "c", true, true)
                        end
                    end,
                },

                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },

                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)

                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            dedroot_c = "[C]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                            cmdline = "[Cmd]",
                        })[entry.source.name]

                        return vim_item
                    end,
                },

                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),

                    ["<C-n>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            cmp.complete()
                        end
                    end, { "i", "s" }),

                    ["<C-p>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    ["<CR>"] = cmp.mapping.confirm({ select = true }),

                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif vim.snippet and vim.snippet.active({ direction = 1 }) then
                            vim.snippet.jump(1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif vim.snippet and vim.snippet.active({ direction = -1 }) then
                            vim.snippet.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),

                sources = cmp.config.sources({
                    { name = "dedroot_c", priority = 1200 },
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "path", priority = 700 },
                }, {
                    { name = "buffer", priority = 500 },
                }),

                experimental = {
                    ghost_text = true,
                },
            })

            -- Search autocomplete
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })

            -- Command autocomplete
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    { name = "cmdline" },
                }),
            })
        end,
    },

    -- Git signs
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "▎" },
                    change = { text = "▎" },
                    delete = { text = "" },
                    topdelete = { text = "" },
                    changedelete = { text = "▎" },
                    untracked = { text = "▎" },
                },
            })
        end,
    },

    -- Easy comments: gcc / gc
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup({
                indent = {
                    char = "│",
                },
                scope = {
                    enabled = true,
                },
            })
        end,
    },

    -- Which-key popup for shortcuts
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup({
                delay = 300,
            })
        end,
    },

    -- Beautiful dashboard
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                "██████╗ ███████╗██████╗ ██████╗  ██████╗  ██████╗ ████████╗",
                "██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝",
                "██║  ██║█████╗  ██║  ██║██████╔╝██║   ██║██║   ██║   ██║   ",
                "██║  ██║██╔══╝  ██║  ██║██╔══██╗██║   ██║██║   ██║   ██║   ",
                "██████╔╝███████╗██████╔╝██║  ██║╚██████╔╝╚██████╔╝   ██║   ",
                "╚═════╝ ╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ",
                "",
                "          welcome back, hacker",
            }

            dashboard.section.buttons.val = {
                dashboard.button("e", "  New file", "<cmd>ene<CR>"),
                dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
                dashboard.button("g", "󰱼  Find text", "<cmd>Telescope live_grep<CR>"),
                dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
                dashboard.button("t", "  Terminal", "<cmd>ToggleTerm direction=float<CR>"),
                dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
            }

            dashboard.section.footer.val = "DedRoot IDE • C / Rust / Linux / UNIX"
            alpha.setup(dashboard.opts)
        end,
    },

    -- Pretty notifications
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        config = function()
            local notify = require("notify")

            notify.setup({
                background_colour = "#1a1b26",
                fps = 60,
                render = "compact",
                stages = "fade_in_slide_out",
                timeout = 1800,
                top_down = false,
            })

            vim.notify = notify
        end,
    },

    -- Pretty input/select windows
    {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        opts = {
            input = {
                border = "rounded",
            },
            select = {
                backend = { "telescope", "builtin" },
            },
        },
    },

    -- Floating terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = 16,
                open_mapping = [[<C-\>]],
                shade_terminals = true,
                direction = "float",
                float_opts = {
                    border = "curved",
                    width = function()
                        return math.floor(vim.o.columns * 0.82)
                    end,
                    height = function()
                        return math.floor(vim.o.lines * 0.78)
                    end,
                },
            })

            vim.keymap.set({ "n", "t" }, "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Floating terminal" })
            vim.keymap.set({ "n", "t" }, "<leader>tb", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "Bottom terminal" })
        end,
    },

}, {
    install = {
        colorscheme = { "tokyonight" },
        missing = true,
    },
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
    ui = {
        border = "rounded",
    },
})

-- =====================
-- Diagnostics UI
-- =====================

vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
        spacing = 4,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = true,
    },
})

local diagnostic_signs = {
    Error = " ",
    Warn = " ",
    Hint = "󰌵 ",
    Info = " ",
}

for type, icon in pairs(diagnostic_signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, {
        text = icon,
        texthl = hl,
        numhl = "",
    })
end

-- =====================
-- Native Neovim 0.11 LSP for clangd
-- =====================

local capabilities = vim.lsp.protocol.make_client_capabilities()

local cmp_lsp = safe_require("cmp_nvim_lsp")
if cmp_lsp then
    capabilities = cmp_lsp.default_capabilities(capabilities)
end

local clangd_cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
}

local clangd_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    ".git",
}

if is_executable("clangd") then
    if vim.lsp.config and vim.lsp.enable then
        vim.lsp.config("clangd", {
            cmd = clangd_cmd,
            filetypes = { "c", "cpp", "objc", "objcpp" },
            root_markers = clangd_markers,
            capabilities = capabilities,
        })

        vim.lsp.enable("clangd")
    else
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "c", "cpp", "objc", "objcpp" },
            callback = function(args)
                local root_dir = vim.fs.root(args.buf, clangd_markers)
                    or vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf))

                vim.lsp.start({
                    name = "clangd",
                    cmd = clangd_cmd,
                    root_dir = root_dir,
                    capabilities = capabilities,
                    bufnr = args.buf,
                })
            end,
        })
    end
else
    vim.schedule(function()
        vim.notify(
            "clangd not found. Run: brew install llvm",
            vim.log.levels.WARN
        )
    end)
end

-- =====================
-- LSP keymaps
-- =====================

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local bufmap = function(keys, func, desc)
            vim.keymap.set("n", keys, func, {
                buffer = event.buf,
                desc = "LSP: " .. desc,
            })
        end

        bufmap("K", vim.lsp.buf.hover, "Hover documentation")
        bufmap("gd", vim.lsp.buf.definition, "Go to definition")
        bufmap("gD", vim.lsp.buf.declaration, "Go to declaration")
        bufmap("gi", vim.lsp.buf.implementation, "Go to implementation")
        bufmap("gr", vim.lsp.buf.references, "Go to references")
        bufmap("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        bufmap("<leader>ca", vim.lsp.buf.code_action, "Code action")

        bufmap("<leader>lf", function()
            vim.lsp.buf.format({ async = true })
        end, "Format file")

        bufmap("<leader>ld", vim.diagnostic.open_float, "Line diagnostics")

        bufmap("[d", function()
            vim.diagnostic.jump({ count = -1, float = true })
        end, "Previous diagnostic")

        bufmap("]d", function()
            vim.diagnostic.jump({ count = 1, float = true })
        end, "Next diagnostic")
    end,
})

-- =====================
-- Filetype tweaks
-- =====================

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function()
        vim.bo.commentstring = "// %s"
        vim.opt_local.colorcolumn = "100"
    end,
})

-- =====================
-- Welcome
-- =====================

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        vim.schedule(function()
            vim.notify("Welcome back, DedRoot.", vim.log.levels.INFO)
        end)
    end,
})


-- =====================
-- Extra UI polish
-- =====================

pcall(function()
    vim.opt.winborder = "rounded"
end)

vim.opt.winbar = "%#WinBar#  󰈙  %f %m%=%l:%c "

local function dedroot_polish_highlights()
    vim.api.nvim_set_hl(0, "WinBar", {
        fg = "#7aa2f7",
        bg = "NONE",
        bold = true,
    })

    vim.api.nvim_set_hl(0, "WinBarNC", {
        fg = "#565f89",
        bg = "NONE",
    })

    vim.api.nvim_set_hl(0, "NormalFloat", {
        bg = "#1a1b26",
    })

    vim.api.nvim_set_hl(0, "FloatBorder", {
        fg = "#7aa2f7",
        bg = "#1a1b26",
    })

    vim.api.nvim_set_hl(0, "Pmenu", {
        bg = "#1a1b26",
    })

    vim.api.nvim_set_hl(0, "PmenuSel", {
        bg = "#33467c",
        bold = true,
    })
end

dedroot_polish_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = dedroot_polish_highlights,
})
