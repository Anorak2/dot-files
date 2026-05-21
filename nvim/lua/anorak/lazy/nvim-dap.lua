-- ~/.config/nvim/lua/plugins/dap.lua

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio", -- required by dap-ui
			"theHamsta/nvim-dap-virtual-text",
			-- Language adapters
			"mfussenegger/nvim-dap-python",
			"leoluz/nvim-dap-go",
		},
		keys = {
			{ "<leader>db", function() require("dap").toggle_breakpoint() end,                                desc = "Toggle Breakpoint" },
			{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,        desc = "Conditional Breakpoint" },
			{ "<leader>dl", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point: ")) end, desc = "Log Point" },
			{ "<leader>dc", function() require("dap").continue() end,                                         desc = "Continue" },
			{ "<leader>dn", function() require("dap").step_over() end,                                        desc = "Step Over" },
			{ "<leader>di", function() require("dap").step_into() end,                                        desc = "Step Into" },
			{ "<leader>do", function() require("dap").step_out() end,                                         desc = "Step Out" },
			{ "<leader>dr", function() require("dap").repl.open() end,                                        desc = "Open REPL" },
			{ "<leader>dR", function() require("dap").run_last() end,                                         desc = "Run Last" },
			{ "<leader>dx", function() require("dap").terminate() end,                                        desc = "Terminate" },
			{ "<leader>du", function() require("dapui").toggle() end,                                         desc = "Toggle UI" },
			{ "<leader>de", function() require("dapui").eval() end,                                           desc = "Eval",  mode = { "n", "v" } },
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- ── UI layout ────────────────────────────────────────────────────────────
			dapui.setup({
				icons = { expanded = "", collapsed = "", current_frame = "" },
				mappings = {
					expand = { "<CR>", "<2-LeftMouse>" },
					open   = "o",
					remove = "d",
					edit   = "e",
					repl   = "r",
					toggle = "t",
				},
				layouts = {
					{
						-- Left sidebar: scopes + watches + breakpoints
						elements = {
							{ id = "scopes",      size = 0.40 },
							{ id = "watches",     size = 0.25 },
							{ id = "breakpoints", size = 0.20 },
							{ id = "stacks",      size = 0.15 },
						},
						size     = 40,
						position = "left",
					},
					{
						-- Bottom panel: REPL + console
						elements = {
							{ id = "repl",    size = 0.5 },
							{ id = "console", size = 0.5 },
						},
						size     = 12,
						position = "bottom",
					},
				},
				controls = {
					enabled  = true,
					element  = "repl",
					icons    = {
						pause        = "",
						play         = "",
						step_into    = "",
						step_over    = "",
						step_out     = "",
						step_back    = "",
						run_last     = "",
						terminate    = "",
						disconnect   = "",
					},
				},
				floating = {
					max_height  = 0.9,
					max_width   = 0.9,
					border      = "rounded",
					mappings    = { close = { "q", "<Esc>" } },
				},
				render = {
					max_type_length = nil,
					max_value_lines = 100,
				},
			})

			-- Auto-open/close UI with dap session
			dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
			dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
			dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

			-- ── Virtual text ─────────────────────────────────────────────────────────
			require("nvim-dap-virtual-text").setup({
				enabled                 = true,
				enabled_commands        = true,
				highlight_changed_variables = true,
				highlight_new_as_changed    = false,
				show_stop_reason        = true,
				commented               = false,
				virt_text_pos           = "eol",
				all_frames              = false,
			})

			-- ── Python ───────────────────────────────────────────────────────────────
			-- Picks up the venv automatically when one is active; falls back to debugpy
			-- on your PATH. For Docker, override host/port per-project (see below).
			require("dap-python").setup(
				vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
			)

			-- Remote/Docker Python config — add to .vscode/launch.json or here:
			dap.configurations.python = vim.list_extend(dap.configurations.python or {}, {
				{
					type    = "python",
					request = "attach",
					name    = "Docker: Attach (5678)",
					connect = { host = "127.0.0.1", port = 5678 },
					-- pathMappings tells the adapter how container paths map to local ones
					pathMappings = {
						{ localRoot = "${workspaceFolder}", remoteRoot = "/app" },
					},
				},
			})

			-- ── Go ───────────────────────────────────────────────────────────────────
			require("dap-go").setup({
				dap_configurations = {
					{
						type    = "go",
						name    = "Docker: Attach (2345)",
						request = "attach",
						mode    = "remote",
						host    = "127.0.0.1",
						port    = 2345,
					},
				},
				delve = {
					-- set to true if your delve lives inside a container and you expose the port
					detached = vim.fn.has("win32") == 0,
				},
			})

			-- ── Signs ────────────────────────────────────────────────────────────────
			vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpoint",          linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointRejected",  { text = "○", texthl = "DapBreakpointRejected",  linehl = "", numhl = "" })
			vim.fn.sign_define("DapLogPoint",            { text = "◉", texthl = "DapLogPoint",            linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped",             linehl = "DapStoppedLine", numhl = "" })
		end,
	},
}

-- ── Docker workflow reminder ──────────────────────────────────────────────────
--
-- Python in container:
--   python -m debugpy --listen 0.0.0.0:5678 --wait-for-client src/main.py
--   docker run -p 5678:5678 ...
--   then <leader>dc with the "Docker: Attach" config
--
-- Go in container:
--   dlv debug --headless --listen=:2345 --api-version=2 ./cmd/server
--   docker run -p 2345:2345 ...
--   then <leader>dc with the "Docker: Attach" config
--
-- If pathMappings don't line up, variables will resolve but source won't jump
-- correctly. Fix by setting remoteRoot to the actual workdir in the container.
