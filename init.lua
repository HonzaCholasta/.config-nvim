-- git clone https://github.com/folke/lazy.nvim ~/.local/share/nvim/lazy/lazy.nvim
local data_path = vim.fn.stdpath("data") .. ""
local lazy_path = data_path .. "/lazy/lazy.nvim"

vim.opt.rtp:prepend(lazy_path)
vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.display = "lastline,uhex"
vim.opt.listchars = "space:·,tab:↦ ,nbsp:␣,eol:↵"
vim.opt.signcolumn = "yes"
vim.opt.whichwrap = "b,s,<,>,[,]"
vim.opt.updatetime = 500

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<Leader>c", "<Cmd>bdelete<CR>")
vim.keymap.set("n", "<Leader>h", "<Cmd>nohlsearch<CR>")
vim.keymap.set("n", "ga", vim.lsp.buf.code_action)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gf", vim.lsp.buf.format)
vim.keymap.set("n", "gr", vim.lsp.buf.references)

vim.keymap.set({ "n", "i", "v" }, "<PageUp>", "<Cmd>normal <C-u><C-u><CR>")
vim.keymap.set({ "n", "i", "v" }, "<PageDown>", "<Cmd>normal <C-d><C-d><CR>")

vim.keymap.set("v", "d", "\"_d")

vim.diagnostic.config({
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚",
      [vim.diagnostic.severity.WARN] = "󰀪",
      [vim.diagnostic.severity.INFO] = "󰋽",
      [vim.diagnostic.severity.HINT] = "󰌶",
    },
  },
  severity_sort = true,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
})

require("lazy").setup({
  spec = {
    {
      "folke/tokyonight.nvim",
      priority = 1000,
      config = function(_, opts)
        require("tokyonight").setup(opts)
        vim.cmd.colorscheme("tokyonight")
      end,
    },
    {
      "williamboman/mason.nvim",
      build = ":MasonUpdate",
      cmd = {
        "Mason",
        "MasonUpdate",
        "MasonInstall",
        "MasonUninstall",
        "MasonUninstallAll",
        "MasonLog",
      },
      config = true,
    },
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = {
        "williamboman/mason.nvim",
        "neovim/nvim-lspconfig",
        "hrsh7th/cmp-nvim-lsp",
      },
      cmd = {
        "LspInstall",
        "LspUninstall",
      },
      ft = {
        "c",
        "cpp",
        "lua",
        "python",
        "rust",
      },
      config = function()
        local exclude = {}
        for lspconfig, exe in pairs({
            clangd = "clangd",
            lua_ls = "lua-language-server",
            pyright = "pyright",
            ruff_lsp = "ruff-lsp",
            rust_analyzer = "rust-analyzer",
        }) do
          local exe_path = vim.fn.exepath(exe)
          if exe_path ~= "" and exe_path:sub(1, data_path:len()) ~= data_path then
            table.insert(exclude, lspconfig)
          end
        end

        require("mason-lspconfig").setup({
          automatic_installation = { exclude = exclude },
        })
      end,
    },
    {
      "jay-babu/mason-null-ls.nvim",
      dependencies = {
        "williamboman/mason.nvim",
        "nvimtools/none-ls.nvim",
      },
      cmd = {
        "NullLsInstall",
        "NullLsUninstall",
      },
      ft = {
        "python",
      },
      config = function()
        require("mason-null-ls").setup({
          automatic_installation = {
            exclude = { "mypy" },
          },
        })

        local sources = {}
        if vim.fn.executable("mypy") then
          table.insert(sources, require("null-ls.builtins.diagnostics.mypy"))
        end

        require("null-ls").setup({
          default_timeout = 15000,
          sources = sources,
        })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      main = "nvim-treesitter.configs",
      opts = {
        auto_install = vim.fn.executable("tree-sitter") and true or false,
        highlight = { enable = true },
        indent = { enable = true },
      },
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {
        indent = { char = "" },
        scope = { show_start = false, show_end = false },
      },
    },
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-nvim-lsp",
        "onsails/lspkind.nvim",
      },
      opts = function()
        local cmp = require("cmp")
        local lspkind = require("lspkind")

        return {
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "buffer" },
          }),
          mapping = cmp.mapping.preset.insert({
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
          }),
          formatting = {
            format = lspkind.cmp_format(),
          },
          window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
          },
        }
      end,
    },
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true,
    },
    {
      "numToStr/Comment.nvim",
      config = true,
    },
    {
      "mg979/vim-visual-multi",
    },
    {
      "lewis6991/gitsigns.nvim",
      cmd = "Gitsigns",
      keys = {
        { "<Leader>gr", "<Cmd>Gitsigns reset_hunk<CR>", "n", silent = true },
        { "<Leader>gs", "<Cmd>Gitsigns stage_hunk<CR>", "n", silent = true },
        { "<Leader>gr", "<Cmd>Gitsigns reset_hunk '<,'><CR>", "v", silent = true },
        { "<Leader>gs", "<Cmd>Gitsigns stage_hunk '<,'><CR>", "v", silent = true },
      },
      config = true,
    },
    {
      "akinsho/bufferline.nvim",
      version = "*",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      opts = {
        options = {
          separator_style = "slant",
          custom_filter = function(bufnr)
            if vim.bo[bufnr].filetype == "qf" then
              return false
            end
            return true
          end,
        },
      },
    },
    {
      "nvim-lualine/lualine.nvim",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
        "SmiteshP/nvim-navic",
      },
      opts = {
        options = {
          disabled_filetypes = {
            statusline = { "neo-tree" },
          },
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
      },
    },
    {
      "SmiteshP/nvim-navic",
      event = "LspAttach",
      opts = {
        highlight = true,
        lsp = {
          auto_attach = true,
        },
      },
    },
    {
      "petertriho/nvim-scrollbar",
      dependencies = {
        "lewis6991/gitsigns.nvim",
        "folke/tokyonight.nvim",
      },
      opts = function()
        local colors = require("tokyonight.colors").setup()
        return {
          handlers = {
            gitsigns = true,
          },
          handle = {
            color = colors.bg_highlight,
          },
          marks = {
            Search = { color = colors.orange },
            Error = { color = colors.error },
            Warn = { color = colors.warning },
            Info = { color = colors.info },
            Hint = { color = colors.hint },
            Misc = { color = colors.purple },
          },
        }
      end,
    },
    {
      "rcarriga/nvim-notify",
      priority = 999,
      config = function()
        vim.notify = require("notify")
      end,
    },
    {
      "nvim-telescope/telescope.nvim",
      branch = "0.1.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
      },
      cmd = "Telescope",
      keys = {
        { "<Leader>ff", "<Cmd>Telescope find_files<CR>", "n", silent = true },
        { "<Leader>fg", "<Cmd>Telescope live_grep<CR>", "n", silent = true },
      },
      config = true,
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
      },
      cmd = "Neotree",
      keys = {
        { "<Leader>e", "<Cmd>Neotree toggle<CR>", "n", silent = true },
      },
      opts = {
        source_selector = {
          winbar = true,
        },
      },
    },
  },
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "CmdWinEnter" }, {
  callback = function()
    if vim.bo.filetype == "qf" then
      vim.opt_local.laststatus = 0
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- winbar
    if client and client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, args.buf)
      vim.opt_local.winbar = [[%!luaeval("require('nvim-navic').get_location()")]]
      vim.api.nvim_input("<C-e>")
    end

    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = args.buf,
      callback = function()
        -- highlight symbol under cursor
        vim.lsp.buf.document_highlight()

        -- show diagnostics float
        vim.diagnostic.open_float(nil, {
          scope = "cursor",
          source = "always",
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          focusable = false,
          border = "rounded",
        })
      end,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = args.buf,
      callback = function()
        -- remove symbol under cursor highlight
        vim.lsp.buf.clear_references()
      end,
    })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    if vim.bo.filetype == "lua" then
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
    end

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
      require("lspconfig").clangd.setup({
        capabilities = capabilities,
      })
    elseif vim.bo.filetype == "lua" then
      require("lspconfig").lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
          },
        },
      })
    elseif vim.bo.filetype == "python" then
      require("lspconfig").pyright.setup({
        capabilities = capabilities,
      })
      require("lspconfig").ruff_lsp.setup({
        capabilities = capabilities,
      })
    elseif vim.bo.filetype == "rust" then
      require("lspconfig").rust_analyzer.setup({
        capabilities = capabilities,
      })
    end
  end,
})
