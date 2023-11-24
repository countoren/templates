{
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {self, nixpkgs, flake-utils }:
  let 
    templates = import ./templates.nix { lib = nixpkgs.lib; };
  in
  flake-utils.lib.eachDefaultSystem (system:
  let  pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages = (import ./default.nix { 
      inherit pkgs templates; 
    }).commands;
  }) //
  { inherit templates; };
}
