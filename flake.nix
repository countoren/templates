{
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {self, nixpkgs, flake-utils }:
  let 
    templates = import templates.nix { lib = nixpkgs.lib; };
  in
  flake-utils.lib.eachDefaultSystem (system:
  {
    packages = (import ./default.nix { 
      inherit templates; 
      pkgs = nixpkgs.legacyPackages.${system};
    }).commands;
  }) //
  { inherit templates; };
}
