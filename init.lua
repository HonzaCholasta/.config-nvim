-- git clone https://github.com/folke/lazy.nvim ~/.local/share/nvim/lazy/lazy.nvim
local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.opt.runtimepath:prepend(lazy_path)
vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = -1
vim.opt.cursorline = true
vim.opt.display = "lastline,uhex"
vim.opt.listchars = "space:·,tab:↦ ,nbsp:␣,eol:↵"
vim.opt.signcolumn = "yes"
vim.opt.whichwrap = "b,s,<,>,[,]"
vim.opt.wrap = false
vim.opt.updatetime = 500

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set({ "n", "i", "v" }, [[<PageUp>]], [[<Cmd>normal <C-u><C-u><CR>]])
vim.keymap.set({ "n", "i", "v" }, [[<PageDown>]], [[<Cmd>normal <C-d><C-d><CR>]])
vim.keymap.set("v", [[d]], [["_d]])

vim.keymap.set("v", [[<S-Up>]], [[:move '<-2<CR>gv=gv]], { silent = true })
vim.keymap.set("v", [[<S-Down>]], [[:move '>+1<CR>gv=gv]], { silent = true })

vim.keymap.set("n", [[K]], [[<Cmd>Lspsaga hover_doc<CR>]])
vim.keymap.set("n", [[<Leader>c]], [[<Cmd>bdelete<CR>]])
vim.keymap.set("n", [[<Leader>h]], [[<Cmd>nohlsearch<CR>]])
vim.keymap.set("n", [[<Leader>la]], [[<Cmd>Lspsaga code_action<CR>]])
vim.keymap.set("n", [[<Leader>lf]], vim.lsp.buf.format)
vim.keymap.set("n", [[<Leader>lr]], [[<Cmd>Lspsaga rename<CR>i<End>]])

vim.keymap.set("n", [[<Leader>gr]], [[<Cmd>Gitsigns reset_hunk<CR>]])
vim.keymap.set("n", [[<Leader>gs]], [[<Cmd>Gitsigns stage_hunk<CR>]])
vim.keymap.set("n", [[<Leader>gu]], [[<Cmd>Gitsigns undo_stage_hunk<CR>]])
vim.keymap.set("v", [[<Leader>gr]], [[<Cmd>'<,'>Gitsigns reset_hunk<CR>]])
vim.keymap.set("v", [[<Leader>gs]], [[<Cmd>'<,'>Gitsigns stage_hunk<CR>]])
vim.keymap.set("v", [[<Leader>gu]], [[<Cmd>'<,'>Gitsigns undo_stage_hunk<CR>]])

vim.keymap.set("n", [[<Leader>ff]], [[<Cmd>Telescope find_files<CR>]])
vim.keymap.set("n", [[<Leader>fg]], [[<Cmd>Telescope live_grep<CR>]])
vim.keymap.set(
  "n", [[<Leader>fw]], [[":Telescope live_grep<CR>\\b" . expand("<cword>") . "\\b"]],
  { expr = true, silent = true }
)
vim.keymap.set("n", [[gd]], [[<Cmd>Telescope lsp_definitions<CR>]])
vim.keymap.set("n", [[gr]], [[<Cmd>Telescope lsp_references<CR>]])

vim.keymap.set("n", [[<Leader>e]], [[<Cmd>Neotree toggle<CR>]])

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

require("lazy").setup({
  spec = {
    {
      "folke/tokyonight.nvim",
      priority = 1000,
      config = function()
        require("tokyonight").setup()
        vim.cmd.colorscheme("tokyonight")
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
        "lewis6991/gitsigns.nvim",
      },
      opts = function()
        local builtins = require("null-ls").builtins

        local sources = {}
        table.insert(sources, builtins.code_actions.gitsigns)
        if vim.fn.executable("mypy") ~= 0 then
          table.insert(sources, builtins.diagnostics.mypy)
        end

        return {
          default_timeout = 15000,
          sources = sources,
        }
      end,
    },
    {
      "nvimdev/lspsaga.nvim",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
      },
      cmd = "Lspsaga",
      event = "LspAttach",
      opts = {
        ui = {
          border = "rounded",
          code_action = "",
        },
        code_action = {
          num_shortcut = false,
          show_server_name = true,
          keys = {
            quit = [[<Esc>]],
          },
        },
        lightbulb = {
          virtual_text = false,
          ignore = {
            clients = { "null-ls" },
          },
        },
        rename = {
          in_select = false,
          keys = {
            quit = [[<Esc>]],
          },
        },
        symbol_in_winbar = {
          enable = false,
        },
      },
    },
    {
      "linrongbin16/lsp-progress.nvim",
      opts = {
        series_format = function(title, message, percentage, done)
          if done then
            percentage = 100
          end
          if message and message ~= "" then
            if title and title ~= "" then
              message = title .. " " .. message
            end
          else
            if title and title ~= "" then
              message = title
            else
              return
            end
          end
          if percentage then
            message = string.format("%s (%.0f%%)", message, percentage)
          end
          return message
        end,
        client_format = function(client_name, spinner, series_messages)
          if client_name == "null-ls" then
            series_messages = vim.tbl_filter(function(series_message)
              return not vim.startswith(series_message, "code_action")
            end, series_messages)
          end
          if #series_messages == 0 then
            return
          end
          return spinner .. " " .. series_messages[#series_messages]
        end,
        format = function(client_messages)
          if #client_messages == 0 then
            return ""
          end
          return client_messages[#client_messages]
        end,
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      main = "nvim-treesitter.configs",
      opts = {
        auto_install = vim.fn.executable("tree-sitter") ~= 0,
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
            [ [[<CR>]] ] = cmp.mapping.confirm({ select = true }),
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
      "nmac427/guess-indent.nvim",
      event = { "BufReadPost", "BufNewFile" },
      opts = {
        on_space_options = {
          expandtab = true,
          shiftwidth = "detected",
        },
      },
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
      opts = {
        signs = {
          changedelete = { text = "┃" },
        },
        signs_staged = {
          changedelete = { text = "┃" },
        },
      },
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
        "linrongbin16/lsp-progress.nvim",
      },
      opts = function()
        local providers = {
          function()
            local provider_names = {}

            if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil then
              table.insert(provider_names, "TS")
            end

            local lsp_clients = vim.lsp.get_clients({ bufnr = 0 })
            if #lsp_clients > 0 then
              local has_null_ls = false
              for _, client in ipairs(lsp_clients) do
                if client.name == "null-ls" then
                  has_null_ls = true
                else
                  table.insert(provider_names, client.name)
                end
              end
              if has_null_ls then
                local sources = require("null-ls").get_source({ filetype = vim.bo.filetype })
                for _, source in ipairs(sources) do
                  table.insert(provider_names, source.name)
                end
              end
            end

            return " " .. table.concat(provider_names, " ")
          end,
          cond = function()
            return
              vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil or
              #vim.lsp.get_clients({ bufnr = 0 }) > 0
          end,
        }

        local lsp_progress = require("lsp-progress").progress

        local function indent()
          return (vim.bo.expandtab and "␣" or "↹") .. " " .. vim.fn.shiftwidth()
        end

        local diff = {
          "diff",
          symbols = {
            added = "󰜄 ",
            modified = "󱗝 ",
            removed = "󰛲 ",
          },
        }

        return {
          options = {
            component_separators = "",
            section_separators = " ",
          },
          sections = {
            lualine_b = {},
            lualine_c = { indent, "filetype", providers, lsp_progress },
            lualine_x = { "diagnostics", diff, "branch" },
            lualine_y = {},
          },
          inactive_sections = {
            lualine_c = {},
          },
          extensions = { "neo-tree" },
        }
      end,
    },
    {
      "SmiteshP/nvim-navic",
      event = "LspAttach",
      opts = {
        highlight = true,
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
            GitAdd = { text = "│" },
            GitChange = { text = "│" },
          },
        }
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
      opts = {
        defaults = {
          sorting_strategy = "ascending",
        },
        pickers = {
          find_files = {
            find_command = {
              "fd",
              "--color=never",
              "--type=f",
              "--hidden",
              "--no-ignore-vcs",
              "--exclude=.git",
            },
          },
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
      config = function()
        require("neo-tree").setup({
          source_selector = {
            winbar = true,
            content_layout = "center",
            separator = { left = "", right = "" },
            show_separator_on_edge = true,
          },
          filesystem = {
            filtered_items = {
              visible = true,
              never_show = {
                ".git",
              },
            },
            follow_current_file = { enabled = true },
          },
        })

        local tab_active_hl = vim.api.nvim_get_hl(0, {
          name = "NeoTreeTabActive",
        }) --[[@as vim.api.keyset.highlight]]
        local tab_inactive_hl = vim.api.nvim_get_hl(0, {
          name = "NeoTreeTabInactive",
        }) --[[@as vim.api.keyset.highlight]]
        local separator_active_hl = vim.api.nvim_get_hl(0, {
          name = "NeoTreeTabSeparatorActive",
        }) --[[@as vim.api.keyset.highlight]]
        local separator_inactive_hl = vim.api.nvim_get_hl(0, {
          name = "NeoTreeTabSeparatorInactive",
        }) --[[@as vim.api.keyset.highlight]]

        separator_active_hl.fg = tab_inactive_hl.bg
        separator_inactive_hl.fg = tab_inactive_hl.bg
        separator_inactive_hl.bg = tab_active_hl.bg
        tab_inactive_hl.bg = tab_active_hl.bg

        vim.api.nvim_set_hl(0, "NeoTreeTabInactive", tab_inactive_hl)
        vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorActive", separator_active_hl)
        vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorInactive", separator_inactive_hl)
      end,
    },
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.shiftwidth = 2
  end,
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

vim.api.nvim_create_autocmd("BufRead", {
  callback = function()
    if vim.bo.filetype == "gitcommit" then
      return
    end
    vim.cmd([[silent! normal! g'"]])
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

local function client_capabilities()
  return vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    require("cmp_nvim_lsp").default_capabilities(),
    {
      offsetEncoding = "utf-16",
    }
  )
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  once = true,
  callback = function()
    if vim.fn.executable("lua-language-server") ~= 0 then
      local lua_ls = require("lspconfig").lua_ls
      lua_ls.setup({
        capabilities = client_capabilities(),
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
      lua_ls.launch()
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  once = true,
  callback = function()
    if vim.fn.executable("clangd") ~= 0 then
      local clangd = require("lspconfig").clangd
      clangd.setup({
        capabilities = client_capabilities(),
        cmd = {
          "clangd",
          "--log=error",
          "--completion-style=detailed",
        },
      })
      clangd.launch()
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  once = true,
  callback = function()
    if vim.fn.executable("basedpyright-langserver") ~= 0 then
      local basedpyright = require("lspconfig").basedpyright
      basedpyright.setup({
        capabilities = client_capabilities(),
      })
      basedpyright.launch()
    elseif vim.fn.executable("pyright-langserver") ~= 0 then
      local pyright = require("lspconfig").pyright
      pyright.setup({
        capabilities = client_capabilities(),
      })
      pyright.launch()
    end
    if vim.fn.executable("ruff") ~= 0 then
      local ruff = require("lspconfig").ruff
      ruff.setup({
        capabilities = client_capabilities(),
      })
      ruff.launch()
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  once = true,
  callback = function()
    if vim.fn.executable("rust-analyzer") ~= 0 then
      local rust_analyzer = require("lspconfig").rust_analyzer
      rust_analyzer.setup({
        capabilities = client_capabilities(),
      })
      rust_analyzer.launch()
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, args.buf)
      if vim.opt.winbar == "" then
        vim.api.nvim_input([[<C-e>]])
      end
      vim.opt_local.winbar = [[%!luaeval("require('nvim-navic').get_location()")]]
    end

    if client.server_capabilities.documentHighlightProvider then
      local group = vim.api.nvim_create_augroup("documentHighlight", {
        clear = false,
      })
      vim.api.nvim_clear_autocmds({
        group = group,
        buffer = args.buf,
      })
      vim.api.nvim_create_autocmd("CursorHold", {
        group = group,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end

    if client.server_capabilities.inlayHintProvider then
      local function toggle_inlay_hints()
        vim.lsp.inlay_hint.enable(vim.fn.mode(false) == "n", { bufnr = args.buf })
      end

      local group = vim.api.nvim_create_augroup("inlayHints", {
        clear = false,
      })
      vim.api.nvim_clear_autocmds({
        group = group,
        buffer = args.buf,
      })
      vim.api.nvim_create_autocmd("ModeChanged", {
        group = group,
        buffer = args.buf,
        callback = toggle_inlay_hints,
      })

      toggle_inlay_hints()
    end
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(args)
    vim.api.nvim_clear_autocmds({
      group = "documentHighlight",
      buffer = args.buf,
    })
  end,
})
