{ pkgs ? (builtins.getFlake (toString ../.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
# Prefix to be appended to all
, siteFolder
, prefix ? "site"
, nix ? "${pkgs.nix}/bin/nix"
, lib ? pkgs.lib
, writeShellScriptBin ? pkgs.writeShellScriptBin
, git ? "${pkgs.git}/bin/git"
, projFolder ? ''$(${git} rev-parse --show-toplevel)''
, server ? "${pkgs.caddy}/bin/caddy"
, buildServerCommands ? "nix build"
, serverHost ? "localhost"
, port ? "1234"
}:
let commands = lib.fix (self: lib.mapAttrs pkgs.writeShellScript
{
  last_timestamp = ''
    find "$1" ! -path '*.git/*' ! -name '*.swp' ! -path 'gh-pages/*' -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f1 -d"."
  '';
  check_styx = ''if
    if [ ! -f "$1/$2" ]; then
      echo "Error: No '$2' in '$1'"
      exit 1
    fi
   '';
  serve-basic = ''
    echo "server listening on http://${serverHost}:${port}"
    echo "press Ctrl+C to stop"
    ${server} file-server --root "$1" --listen "${serverHost}":"${port}"
  '';
  serve = ''${self.serve-basic} ${siteFolder}'';

  serve-impure-build =  ''
    ${buildServerCommands} && ${self.serve-basic} ./result
  '';
  live = ''
    ls site.nix | ${pkgs.entr}/bin/entr -r ${self.serve-impure-build}
  '';
});
# nix build -f default.nix --argstr templatesFolder /home/p1n3/nixpkgs/templates
in lib.fix (self: pkgs.symlinkJoin {
  name = prefix;
  passthru.commands = lib.mapAttrs (name: command: pkgs.runCommand "${prefix}-${name}" {} ''
    mkdir -p $out/bin
    ln -sf ${command} $out/bin/${prefix}-${name}
    '') commands;
  paths = lib.attrValues self.passthru.commands;
})
