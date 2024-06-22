{ pkgs ? import <nixpkgs> { }
, vims
, quick-lint-js
}:
[
      quick-lint-js.quick-lint-js

      # VScode 
      (pkgs.vscode-with-extensions.override {
        vscode = pkgs.vscodium;
        vscodeExtensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          mhutchie.git-graph
          vscodevim.vim
          dbaeumer.vscode-eslint
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        ];

      })

      pkgs.nodePackages.prettier
      pkgs.nodePackages.vscode-langservers-extracted
      pkgs.nodePackages.typescript-language-server
      pkgs.typescript

      # Vim
      (vims.createNvim {
        inherit pkgs;
        pkgsPath = ".";
        additionalVimrc = '' 
            lua << EOF
             require'lspconfig'.tsserver.setup {
                      cmd = { "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server", "--stdio" },
                      capabilities = capabilities,
                    }
            EOF
        '';
        additionalPlugins = with pkgs.vimPlugins; [

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
          nvim-lsp-ts-utils
          trouble-nvim
          {

            plugin = quick-lint-js.vimPlugin;
            # config = ''
            #   let $PATH = $PATH.":${quick-lint-js.quick-lint-js}/bin"
            # '';
          }
        ];
      })
  ]
