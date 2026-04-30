return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
	branch = "master",
    config = function()
        require("nvim-treesitter.configs").setup({
            -- A list of parser names, or "all"
            ensure_installed = {
                "vimdoc", "javascript", "c", "rust",
                "go", "python", "html", "css",
            },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
            auto_install = false,

            indent = { enable = true },

            highlight = {
                -- `false` will disable the whole extension
                enable = true,
				-- Disable treesitter for any file that fails to parse
				disable = function(lang, buf)
                    if lang == "markdown" then return true end
                    local ok, _ = pcall(function()
                        vim.treesitter.get_parser(buf, lang)
                    end)
                    return not ok
                end,

            },
        })

        local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
        treesitter_parser_config.templ = {
            install_info = {
                url = "https://github.com/vrischmann/tree-sitter-templ.git",
                files = {"src/parser.c", "src/scanner.c"},
                branch = "master",
            },
        }

        vim.treesitter.language.register("templ", "templ")
    end
}
