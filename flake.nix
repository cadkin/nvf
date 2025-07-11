{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url   = "github:numtide/flake-utils";
    nvf.url     = "github:notashelf/nvf";
  };

  outputs = inputs @ { self, utils, ... }: utils.lib.eachDefaultSystem (system: let
    pkgs = import inputs.nixpkgs {
      allowUnfree = true;
      inherit system;
    };

    neovimConfig = inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [
        {
          config.vim = {
            theme = {
              enable = true;
              name   = "gruvbox";
              style  = "dark";
            };

            options = {
              # Colorschemes and highlighting
              hlsearch = true;
              title    = true;

              # Whitespace visualization
              list      = true;
              listchars = "tab:>─,trail:◇,nbsp:+";

              # Tab options
              tabstop     = 4;
              softtabstop = 4;
              shiftwidth  = 4;
              expandtab   = true;
              smarttab    = true;

              # Numbering
              scrolloff = 5;

              # Mouse
              mousemoveevent = true;

              # Developer options
              autowrite = true;
            };

            keymaps = [
              {
                key    = "<F1>";
                mode   = "n";
                silent = true;
                action = "<Nop>";
              }

              {
                key    = "<C-p>";
                mode   = "n";
                silent = true;
                action = "<Cmd>FzfLua files<cr>";
              }

              {
                key    = "<C-l>";
                mode   = "n";
                silent = true;
                action = "<Cmd>FzfLua live_grep<cr>";
              }

              {
                key    = "<C-x>";
                mode   = "n";
                silent = true;
                action = "<Cmd>BufferLinePickClose<cr>";
              }

              {
                key     = "<leader>g";
                mode    = [ "n" "o" "x" ];
                silent  = false;
                lua     = true;
                # Some weirdness with lazyvim keys options:
                # https://github.com/ggandor/leap.nvim/issues/191
                action  = ''
                  function()
                    require("leap").leap({ target_windows = { vim.api.nvim_get_current_win() } })
                  end
                '';
              }

              # Cmd mode from ;
              {
                key    = ";";
                mode   = "n";
                silent = false;
                action = ":";
              }

              # Quitting should close "tabs" (aka buffers in vim lingo)
              {
                key    = "q";
                mode   = "ca";
                silent = true;
                lua    = true;
                action = ''
                  function()
                    loaded_buffers = {}

                    for buffer in pairs(vim.api.nvim_list_bufs()) do
                      if (vim.api.nvim_buf_is_loaded(buffer)) then
                        table.insert(loaded_buffers, buffer)
                      end
                    end

                    if (#loaded_buffers > 1) then
                      require("bufdelete").bufdelete()
                    else
                      vim.cmd("quitall")
                    end
                  end
                '';
              }

              {
                key    = "wq";
                mode   = "ca";
                silent = true;
                lua    = true;
                action = ''
                  function()
                    vim.cmd("write")
                    loaded_buffers = {}

                    for buffer in pairs(vim.api.nvim_list_bufs()) do
                      if (vim.api.nvim_buf_is_loaded(buffer)) then
                        table.insert(loaded_buffers, buffer)
                      end
                    end

                    if (#loaded_buffers > 1) then
                      require("bufdelete").bufdelete()
                    else
                      vim.cmd("quitall")
                    end
                  end
                '';
              }
            ];

            lineNumberMode = "number";

            autocmds = [
              {
                event   = [ "BufWritePre" ];
                pattern = [ "*" ];
                command = "%s/\\s\\+$//e";
                desc    = "Automatically clean whitespace";
              }
              {
                event   = [ "BufReadPost" ];
                pattern = [ "*.tex" "*.typ" "*.md" ];
                command = "set textwidth=120 | set spell";
                desc    = "Setup options for natural text documents";
              }
              {
                event   = [ "BufReadPost" ];
                pattern = [ "*" ];
                command = "silent! normal! g`\"zv";
                desc    = "Restore previous cursor position";
              }
            ];

            clipboard = {
              enable = true;
              registers = "unnamed";
              providers = {
                xclip.enable = true;
              };
            };

            undoFile = {
              enable = true;
            };

            debugger = {
              nvim-dap = {
                enable = true;
                ui.enable = true;
              };
            };

            statusline = {
              lualine = {
                enable = true;
                theme  = "dracula";
              };
            };

            filetree = {
              neo-tree = {
                enable = true;
                setupOpts = {
                  close_if_last_window = true;
                };
              };
            };

            tabline = {
              nvimBufferline = {
                enable = true;

                mappings = {
                  closeCurrent = "<leader>w";
                  cycleNext = "<S-k>";
                  cyclePrevious = "<S-j>";
                };

                setupOpts.options = {
                  always_show_bufferline = false;
                  diagnostics_indicator = null;
                  numbers = "none";
                  indicator = {
                    icon  = " ";
                    style = "icon";
                  };
                };
              };
            };

            autocomplete = {
              nvim-cmp = {
                enable = true;
              };
            };

            utility.motion = {
              leap = {
                enable = true;
              };
            };

            lsp = {
              enable = true;
              lightbulb.enable = true;
            };

            fzf-lua = {
              enable = true;
            };

            treesitter = {
              enable = true;
              highlight.enable = true;
              indent.enable    = true;
              grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
                bash
                bibtex
                c
                cmake
                cpp
                cuda
                desktop
                diff
                dot
                doxygen
                editorconfig
                gitcommit
                gitignore
                go
                haskell
                html
                javascript
                jq
                json
                kconfig
                latex
                llvm
                lua
                make
                markdown
                matlab
                meson
                nickel
                ninja
                nu
                objdump
                python
                regex
                rust
                slint
                tcl
                textproto
                toml
                typst
                vim
                vimdoc
                yaml
              ];
            };

            languages = {
              clang = {
                enable = true;
                dap.enable = true;
                lsp.enable = true;
              };

              nix = {
                enable = true;
                lsp.enable = true;
              };
            };

            utility = {
              diffview-nvim = {
                enable = true;
              };
            };

            extraPlugins = {
              neogit = {
                package = pkgs.vimPlugins.neogit;
                setup   = "require('neogit').setup {}";
                after   = [ "plenary-nvim" "diffview-nvim" "fzf-lua" ];
              };
            };
          };
        }
      ];
    };
  in {
    packages = rec {
      default = neovim;
      inherit (neovimConfig) neovim;
    };
  });
}
