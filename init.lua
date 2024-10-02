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
vim.keymap.set("n", "<Leader>la", vim.lsp.buf.code_action)
vim.keymap.set("n", "<Leader>lf", vim.lsp.buf.format)
vim.keymap.set("n", "<Leader>lr", vim.lsp.buf.rename)

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
      },
      cmd = {
        "LspInstall",
        "LspUninstall",
      },
      config = true,
    },
    {
      "jay-babu/mason-null-ls.nvim",
      dependencies = {
        "williamboman/mason.nvim",
      },
      cmd = {
        "NullLsInstall",
        "NullLsUninstall",
      },
      config = true,
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason-lspconfig.nvim",
      },
      ft = {
        "c",
        "cpp",
        "lua",
        "python",
        "rust",
      },
    },
    {
      "nvimtools/none-ls.nvim",
      dependencies = {
        "jay-babu/mason-null-ls.nvim",
      },
      ft = {
        "python",
      },
      opts = function()
        local sources = {}

        if vim.fn.executable("mypy") then
          table.insert(sources, require("null-ls.builtins.diagnostics.mypy"))
        end

        return {
          default_timeout = 15000,
          sources = sources,
        }
      end,
    },
    {
      "p00f/clangd_extensions.nvim",
      event = "LspAttach",
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
            return vim.bo[bufnr].filetype ~= "qf"
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
        { "gd", "<Cmd>Telescope lsp_definitions<CR>", "n", silent = true },
        { "gr", "<Cmd>Telescope lsp_references<CR>", "n", silent = true },
      },
      opts = {
        defaults = {
          sorting_strategy = "ascending",
        },
      },
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
    else
      vim.opt_local.laststatus = 2
    end
  end,
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      scope = "cursor",
      source = "always",
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      focusable = false,
      border = "rounded",
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
      if vim.fn.executable("clangd") then
        require("lspconfig").clangd.setup({
          capabilities = capabilities,
        })
      end
    elseif vim.bo.filetype == "lua" then
      if vim.fn.executable("lua-language-server") then
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
      end
    elseif vim.bo.filetype == "python" then
      if vim.fn.executable("pyright") then
        require("lspconfig").pyright.setup({
          capabilities = capabilities,
        })
      end
      if vim.fn.executable("ruff-lsp") then
        require("lspconfig").ruff_lsp.setup({
          capabilities = capabilities,
        })
      end
    elseif vim.bo.filetype == "rust" then
      if vim.fn.executable("rust-analyzer") then
        require("lspconfig").rust_analyzer.setup({
          capabilities = capabilities,
        })
      end
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    if client.name == "clangd" then
      require("clangd_extensions")
    end

    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, args.buf)
      vim.opt_local.winbar = [[%!luaeval("require('nvim-navic').get_location()")]]
      vim.api.nvim_input("<C-e>")
    end

    if client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_autocmd("CursorHold", {
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end
  end,
})
