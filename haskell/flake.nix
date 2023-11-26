{
  inputs.vims.url = "github:countoren/vims";
  outputs = { self, nixpkgs, vims }:
  let system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system;};
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        haskell-language-server nodejs ghc ghcid
        (vims.createNvim {
          inherit pkgs; 
          pkgsPath = "." ;
          additionalVimrc =  '' 
          '';
          additionalPlugins = with pkgs.vimPlugins; [

          ];
        })
      ];
    };

  };
}
