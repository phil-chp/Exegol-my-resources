-- Heavily inspired from Vimothée Chalamet's vim12 config video
-- https://www.youtube.com/watch?v=xGkL2N8w0H4

vim.o.number         = true
vim.o.relativenumber = true
vim.o.signcolumn     = "yes"
vim.o.wrap           = false
vim.o.tabstop        = 4
vim.o.shiftwidth     = 4
vim.o.expandtab      = true
vim.o.swapfile       = false
vim.o.smartindent    = true
vim.o.colorcolumn    = "81"
vim.o.winborder      = "rounded"
vim.o.termguicolors  = true
vim.o.undofile       = true

vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR>')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>d', '"+d<CR>')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>s', ":e #<CR>")
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>S', ":sf #<CR>")

vim.keymap.set('n', '<C-w>H', ':leftabove vsplit<CR>')
vim.keymap.set('n', '<C-w>L', ':rightbelow vsplit<CR>')
vim.keymap.set('n', '<C-w>K', ':leftabove split<CR>')
vim.keymap.set('n', '<C-w>J', ':rightbelow split<CR>')


-- ----------------------------------------------------------- Language specific
-- Enable wrap for text
vim.api.nvim_create_autocmd('BufEnter', {
    pattern = { '*.typ', '*.md' },
    group = group,
    command = 'setlocal wrap'
})

-- -------------------------------------------------------------------- Packages
vim.pack.add({
    { src = "https://github.com/ellisonleao/gruvbox.nvim" },
    { src = "https://github.com/stevearc/oil.nvim" },
    -- { src = "https://github.com/echasnovski/mini.pick" },
    -- { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/chomosuke/typst-preview.nvim" },
    { src = "https://github.com/github/copilot.vim" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

-- Navigation stuff
local ignore_exts = { class = true, dylib = true, lib = true, o = true, pyo = true }

-- require("mini.pick").setup({
--     source = {
--         items = vim.fn.readdir('.'),
--         filter = function(name)
--             if name:match("^%.") ~= nil then return true end
--             local m = name:match("%.([^.]+)$")
--             return m and ignore_exts[m:lower()] or false
--         end,
--     }
-- });
-- vim.keymap.set('n', '<leader>e', ":Pick files<CR>")
-- vim.keymap.set('n', '<leader>h', ":Pick help<CR>")

require("oil").setup({
    view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
            -- if name:match("^%.") ~= nil then return true end
            local m = name:match("%.([^.]+)$")
            return m and ignore_exts[m:lower()] or false
        end,
    }
})
vim.keymap.set('n', '<leader>f', ":Oil<CR>")

require("mason").setup()

require("nvim-treesitter.configs").setup({
    ensure_installed = { "lua", "typst", "markdown", "python", "c", "cpp", "json", "powershell", "sql" },
    sync_install = false,
    auto_install = true,
    ignore_install = {},
    modules = {},
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
})


-- LSP configs
vim.lsp.enable({ "lua_ls", "tinymist", "clangd", "basedpyright", "jsonls", "harper_ls" })
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition)
vim.keymap.set('n', '<leader>gr', vim.lsp.buf.incoming_calls)
vim.keymap.set('n', '<leader>rf', vim.lsp.buf.rename)

-- Auto complete on typing (based on language servers)
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then return end
        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})
vim.cmd("set completeopt+=noselect")

-- ----------------------------------------------------------------------- THEME
require("gruvbox").setup({
    contrast = "hard",
    palette_overrides = {
        dark1 = "",
        dark0_hard = ""
    },
})
vim.cmd("colorscheme gruvbox")
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#121212" })
-- vim.api.nvim_set_hl(0, "Normal", { bg = "#181818" })
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "#121212" })
