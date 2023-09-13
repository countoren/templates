{
  inputs.obs.url = "github:obsidiansystems/obelisk";
  inputs.obs.flake = false;

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, obs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
  let system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system;};
  in
  {
    packages.default = pkgs.writeShellScriptBin "start-shell" ''nix develop --impure'';
    devShells.default = pkgs.mkShell {
      buildInputs = [
        (import obs { inherit system;}).command
        (pkgs.writeShellScriptBin "run" '' ob run'')
      ];
      shellHook = ''
        PS1+="OBS> "
      '';
    };
  });
}
