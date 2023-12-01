{
  inputs.vims.url = "github:countoren/vims";
  outputs = { self, nixpkgs, vims }:

  let system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system;};
  in
  {
    packages.${system}.default = pkgs.writeShellScriptBin "run" ''
      nix develop -c -- neovide .
    '';

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        rustc
        graphviz
        rust-analyzer
        evcxr

        (vims.createNvim {
          inherit pkgs;
          pkgsPath = ".";
          additionalVimrc =  ''
          '';
          additionalPlugins = with pkgs.vimPlugins; [
            nvim-lspconfig
            rust-tools-nvim
            plenary-nvim
          ]; 
        })
      ];
    };

  };
}
