{
  inputs.nixvim.url = "github:mikaelfangel/nixvim-config";
  inputs.vims.url = "github:countoren/vims/6908d20766b2da361d4d1b61ec6e291709c80b79";
  outputs = { self, nixpkgs, vims, nixvim }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

    in
    {
      packages.${system} = {
        inherit (pkgs.callPackage ./fsautocomplete.nix { })
          fsautocomplete-local-or-nix fsautocomplete;

        default = pkgs.writeShellScriptBin "run" ''
          nix develop -c -- neovide .
        '';
      };

      devShells.${system}.default = pkgs.mkShell {

        buildInputs = with pkgs;
        [
          fantomas
            dotnet-sdk_8
            dotnet-runtime_8
            self.packages.${system}.fsautocomplete-local-or-nix


            (pkgs.vscode-with-extensions.override {
              vscode = pkgs.vscodium;
              vscodeExtensions = with vscode-extensions; [
                bbenoist.nix
                mhutchie.git-graph
                vscodevim.vim
                ionide.ionide-fsharp
                ms-dotnettools.csharp
              ]
              ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              ];
            })


            (vims.createNvim {
              inherit pkgs;
              pkgsPath = ".";
              additionalVimrc = '' 

            '';
              additionalPlugins = with pkgs.vimPlugins; [
                # let g:LanguageClient_serverCommands['fsharp'] = ['dotnet', 'fsautocomplete']
                plenary-nvim
                telescope
                cmp-nvim-lsp
                {
                  plugin = nvim-cmp;
                  config = ''
                    lua << EOF
                    local cmp = require'cmp'
                    cmp.setup {
                      sources = {
                        { name = 'nvim_lsp' },
                      },
                      mapping = cmp.mapping.preset.insert({
                        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-f>'] = cmp.mapping.scroll_docs(4),
                        ['<C-Space>'] = cmp.mapping.complete(),
                        ['<C-e>'] = cmp.mapping.abort(),
                        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                      })
                    }

                    local capabilities = require('cmp_nvim_lsp').default_capabilities()
                    EOF
                  '';
                }

                {
                  plugin = Ionide-vim;
                  # Expecting: LanguageClient-neovim

                  # let $DOTNET_ROOT="${pkgs.dotnet-sdk}"
                  # let $PATH = "${pkgs.dotnet-sdk}/bin:".$PATH
                  # let $PATH = "$HOME/.dotnet/tools:".$PATH
                  # let g:fsharp#fsautocomplete_command = ['dotnet','$HOME/.dotnet/tools/fsautocomplete']
                  # let $DOTNET_ROOT="${pkgs.dotnet-sdk}"
                  # let $PATH = "${pkgs.dotnet-sdk}/bin:".$PATH
                  # let $PATH = "$HOME/.dotnet/tools:".$PATH
                  # let g:fsharp#fsautocomplete_command = ['dotnet','$HOME/.dotnet/tools/fsautocomplete','--adaptive-lsp-server-enabled']
                  # command! FSharpFormatThisFile :w | silent exec "!cd %:h && DOTNET_ROOT=$(dirname $(realpath $(which dotnet))) dotnet fantomas %:p" | e
                  # let g:fsharp#backend = "languageclient-neovim"
                  # "F# interactive key bindings
                  # let g:fsharp#fsi_keymap = "custom"
                  # let g:fsharp#fsi_keymap_send   = "<leader>i"
                  # let g:fsharp#fsi_keymap_toggle = "<leader><shift-i>"
                  config = ''
                    let g:deoplete#enable_at_startup = 1
                    lua << EOF


                      local lspconfig = require'lspconfig'

                      -- Configure F# LSP
                      lspconfig.fsautocomplete.setup {
                          cmd = { "${self.packages.${system}.fsautocomplete-local-or-nix}/bin/fsautocomplete", "--adaptive-lsp-server-enabled" },
                          capabilities = capabilities,
                          root_dir = function(filename, _)
                              local root
                              -- in order of preference:
                              -- * directory containing a solution file
                              -- * git repository root
                              -- * directory containing an fsproj file
                              -- * directory with fsx scripts
                              root = lspconfig.util.root_pattern("*.sln")(filename)
                              root = root or lspconfig.util.find_git_ancestor(filename)
                              root = root or lspconfig.util.root_pattern("*.fsproj")(filename)
                              root = root or lspconfig.util.root_pattern("*.fsx")(filename)
                              return root
                            end,
                      }

                    EOF
                  '';
                  # filetypes = [ "fsharp" ];
                }

              ];
            })
          ];
      };

    };
}
