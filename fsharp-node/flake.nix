{
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
  let pkgs = import nixpkgs {
      inherit system;
      config.permittedInsecurePackages = [
        "nodejs-16.20.1"
      ];
  };
  in {
    packages.install = pkgs.writeShellScriptBin "install" ''
      nix develop -c -- npm install
    '';
    packages.serve = pkgs.writeShellScriptBin "serve" ''
      nix develop -c -- dotnet run
    '';

    packages.default = pkgs.writeShellScriptBin "dev" ''
      nix develop -c -- codium .
    '';

    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        nodejs-16_x
        dotnet-sdk
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
      ];
    };
  });
}