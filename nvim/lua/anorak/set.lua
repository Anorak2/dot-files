vim.opt.nu = true
vim.opt.relativenumber = true  -- replaces the objective line # with cursor placement based
-- vim.opt.clipboard = "unnamedplus"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- Sets the leader to the space bar
vim.g.mapleader = " "
vim.opt.whichwrap = "<,>,[,]"

-- Used to make whole words wrap instead of individual letters
vim.o.linebreak = true

-- Used to pull up all LSP warnings in a file
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- used to cyle options on keymap 
vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})
