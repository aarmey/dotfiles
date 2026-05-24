return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        -- This ensures lazygit uses your nvim colors and opens files back in nvim
        configure = true,
      },
    },
    keys = {
      -- 1. Map <leader>gg to Lazygit (Root)
      {
        "<leader>gg",
        function()
          Snacks.lazygit.open()
        end,
        desc = "Lazygit (Root)",
      },
      -- 2. Map <leader>gG to Lazygit (Current File Dir)
      {
        "<leader>gG",
        function()
          Snacks.lazygit.open({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "Lazygit (cwd)",
      },
      -- 3. Map <leader>gf to File History
      {
        "<leader>gf",
        function()
          Snacks.lazygit.log_file()
        end,
        desc = "Lazygit Current File History",
      },
      -- 4. Map <leader>gl to Log
      {
        "<leader>gl",
        function()
          Snacks.lazygit.log()
        end,
        desc = "Lazygit Log",
      },
    },
  },
}
