{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.styx.url = "github:styx-static/styx";
  # inputs.styx.flake = false;
  # inputs.styx.follows = "nixpkgs";

  # inputs.styx.url = "path:/home/p1n3/Desktop/t2/styx";
  # inputs.styx.flake = false;
  outputs = { self, nixpkgs, flake-utils, styx }:
  #flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
  flake-utils.lib.eachDefaultSystem (system:
  let pkgs = nixpkgs.legacyPackages.${system};

  in {
    packages = {
      site = (import ./site.nix.old {
        mkSite = styx.outputs.lib.x86_64-linux.generation.mkSite;
      }).site;
      default = self.packages.${system}.site;
    } // (import ./commands.nix { inherit pkgs;
      siteFolder = self.packages.${system}.site;
    }).commands;

    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        styx.packages.${system}.default
      ];
      shellHook = ''
        PS1+="site> "
      '';
    };
  });
}
# {
#   inputs.flake-utils.url = "github:numtide/flake-utils";
#   # inputs.styx.url = "path:/home/p1n3/Desktop/t2/styx";
#   # inputs.styx.flake = false;
#   inputs.styx.url = "github:styx-static/styx";
#   inputs.styx.follows = "nixpkgs";
#   outputs = { self, nixpkgs, flake-utils, styx }:
#   flake-utils.lib.eachDefaultSystem (system:
#   let
#     pkgs = nixpkgs.legacyPackages.${system};
#     # overlays = [
#     #   ( _: _: {
#     #     # styx = styx.outputs.packages.${system}.styx;
#     #   })

#   in {
#     # packages.default = import ./site.nix { inherit pkgs; };
#     devShells.default = pkgs.mkShell {
#       buildInputs =  [
#         # (import styx/app/cli.nix { inherit pkgs; })
#         styx.packages.x86_64-linux.styx
#       ];
#       shellHook = ''
#         PS1+="site> "
#       '';
#     };
#   });
# }
