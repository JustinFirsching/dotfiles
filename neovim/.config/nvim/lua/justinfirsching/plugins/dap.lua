return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "mfussenegger/nvim-dap-python",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            local map_key = require("justinfirsching.utils").map_key

            -- Setup dap-ui
            dapui.setup()

            -- Setup virtual text
            require("nvim-dap-virtual-text").setup()

            -- Setup Python debugging with debugpy from Mason
            local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
            require("dap-python").setup(debugpy_path)

            -- Automatically open/close dapui when debugging starts/ends
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end

            -- Breakpoint signs
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
            vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
            vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })

            -- Keybindings
            map_key("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
            map_key("n", "<leader>dB", function()
                dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end, { desc = "Set conditional breakpoint" })
            map_key("n", "<leader>dl", function()
                dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
            end, { desc = "Set log point" })
            map_key("n", "<leader>dc", dap.continue, { desc = "Continue" })
            map_key("n", "<leader>di", dap.step_into, { desc = "Step into" })
            map_key("n", "<leader>do", dap.step_over, { desc = "Step over" })
            map_key("n", "<leader>dO", dap.step_out, { desc = "Step out" })
            map_key("n", "<leader>dr", dap.restart, { desc = "Restart" })
            map_key("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
            map_key("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
            map_key("n", "<leader>de", dapui.eval, { desc = "Evaluate expression" })
            map_key("v", "<leader>de", dapui.eval, { desc = "Evaluate selection" })
            map_key("n", "<leader>dR", dap.repl.open, { desc = "Open REPL" })
        end,
    },
}
