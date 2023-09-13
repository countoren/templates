{
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
  let pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.default = pkgs.writeShellScriptBin "run" ''
      nix develop -c -- codium .
    '';
    
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        nodejs
        (pkgs.writeShellScriptBin "run" ''
          ${pkgs.nodejs}/bin/npx elm-pages dev
        '')
        elmPackages.elm
        (pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = with vscode-extensions; [
            bbenoist.nix
            mhutchie.git-graph
            vscodevim.vim
            elmtooling.elm-ls-vscode
            vscode-extensions.bradlc.vscode-tailwindcss

          ] 
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            { name = "vscode-test-explorer"; publisher = "hbenl"; version = "2.21.1"; sha256 = "sha256-fHyePd8fYPt7zPHBGiVmd8fRx+IM3/cSBCyiI/C0VAg="; }
            { name = "test-adapter-converter"; publisher = "ms-vscode"; version = "0.1.8"; sha256 = "sha256-ybb3Wud6MSVWEup9yNN4Y4f5lJRCL3kyrGbxB8SphDs="; }
          ];

        })
      ];
    };
  });
}
