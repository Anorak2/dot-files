return {
    "mfussenegger/nvim-lint",
    dependencies = {
        -- auto-installs linters via Mason
        "rshkarin/mason-nvim-lint",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")
		-- pylint:
        --   C0301 = line too long
        --   C0411/C0412/C0413 = import ordering (isort's job, not pylint's)
        --   E0401 = unable to import (can't see your venv/paths)
        --   W0611 = imported but unused (noisy during active development)
        lint.linters.pylint = vim.tbl_deep_extend("force", lint.linters.pylint, {
            args = {
				"--disable=C,R,W, C0301,C0411,C0412,C0413,E0401,W0611",
                "--output-format=json",
				"--score=no", -- suppress score line that "pollutes" output
                "--from-stdin", -- avoid file path issues 
				function() return vim.api.nvim_buf_get_name(0) end,
            },
        })

        -- eslint_d: disable import resolution and line-length via a base config.
		-- added a flags so that there's no warning for unresolved plugins
		-- rule  "curly" throws an error when there is code such as if(cond) return, it must have broken
		--     out curly braces
        lint.linters.eslint_d = vim.tbl_deep_extend("force", lint.linters.eslint_d, {
            args = {
                "--no-ignore",               -- don't silently skip files
                "--rule", '{"max-len": 0}',  -- line length: off
                "--rule", '{"import/no-unresolved": 0}',  -- import resolution: off
                "--format", "json",
                "--stdin", -- used for reliability
                "--stdin-filename", function() return vim.api.nvim_buf_get_name(0) end, -- used for reliability
				"--rule", '{"curly": ["error", "all"]}',
            },
        })

        -- clangtidy: trailing return allows for int func() instead of auto func() -> int
		-- readability-braces prevents if statements like if(condition) return;
        lint.linters.clangtidy = vim.tbl_deep_extend("force", lint.linters.clangtidy, {
            args = {
				"--checks=-modernize-use-trailing-return-type,-llvm-header-guard,+readability-braces-around-statements"
            },
        })

        -- markdownlint: MD013 = line length, MD033 = inline HTML (often intentional)
        lint.linters.markdownlint = vim.tbl_deep_extend("force", lint.linters.markdownlint, {
            args = {
                "--disable", "MD013", "MD033", "--",
            },
        })
		-- proselint: disable curly/smart quote suggestions
		lint.linters.proselint = vim.tbl_deep_extend("force", lint.linters.proselint, {
            args = { "-" },
        })
		local proselintrc = vim.fn.expand("~/.proselintrc")
        if vim.fn.filereadable(proselintrc) == 0 then
            local config = vim.fn.json_encode({
                checks = {
                    ["typography.symbols.curly_quotes"] = false,
                },
            })
            vim.fn.writefile({ config }, proselintrc)
        end


        -- Add new filetypes here as needed. Keys must match Neovim's
        -- canonical filetype names (check with :set ft? inside a buffer).
        lint.linters_by_ft = {
            -- Web
            javascript       = { "eslint_d" },
            typescript       = { "eslint_d" },
            javascriptreact  = { "eslint_d" },
            typescriptreact  = { "eslint_d" },

            -- Scripting / data
            python           = { "pylint" },
            sh               = { "shellcheck" },
            bash             = { "shellcheck" },

            -- Prose
            markdown         = { "markdownlint", "proselint" },
            text             = { "proselint" },

            -- Infrastructure
            dockerfile       = { "hadolint" },
            yaml             = { "yamllint" },
        }

        require("mason-nvim-lint").setup({
			ensure_installed = {
				"pylint",
                "eslint_d",
                "markdownlint",
                "proselint",
                "hadolint",
                "yamllint",
                "shellcheck",
			}
        })

		-- Spellcheck for md and txt files
		vim.api.nvim_create_autocmd("FileType", {
            pattern  = { "markdown", "text" },
            callback = function()
                vim.opt_local.spell     = true
                vim.opt_local.spelllang = "en"
                -- Only flag clear misspellings (SpellBad), not rare/foreign words.
                -- Clears the noisier SpellCap (capitalisation) and SpellLocal highlights.
                vim.cmd("hi SpellCap   NONE")
                vim.cmd("hi SpellLocal NONE")
                vim.cmd("hi SpellRare  NONE")
            end,
        })


		-- Runs the linter when:
        -- BufWritePost  → on save (fast feedback)
        -- BufReadPost   → when opening an existing file
        -- InsertLeave   → after leaving insert mode (Could remove later) 
        local lint_augroup = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost"}, {
            group    = lint_augroup,
            callback = function()
                -- Only lint if a linter is configured for this filetype
                local ft = vim.bo.filetype
                if lint.linters_by_ft[ft] then
                    lint.try_lint()
                end
            end,
        })

        -- Optional: keybind to manually trigger linting
        vim.keymap.set("n", "<leader>cl", function()
            lint.try_lint()
        end, { desc = "Trigger linter for current file" })
    end,
}
