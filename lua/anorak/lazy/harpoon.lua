return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local telescope = require("telescope")
        local harpoon = require("harpoon")
        harpoon:setup({
			settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
            },
		})
		telescope.load_extension("harpoon")

		vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: add file" })
        vim.keymap.set("n", "<C-e>", telescope.extensions.harpoon.marks, { desc = "Harpoon: fuzzy find" })
		-- open no telescope
        --vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        vim.keymap.set("n", "<C-u>", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<C-i>", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<C-o>", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<C-p>", function() harpoon:list():select(4) end)

		-- navigate inside of the menu
        vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
        vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
		vim.keymap.set("n", "<C-r>", function() harpoon:list():remove() end, { desc = "Harpoon: remove file" })

    end,
}
