{ pkgs ? import <nixpkgs> {}
, prefix ? "blast"
}:
let 

  commands = pkgs.lib.fix (self: pkgs.lib.mapAttrs pkgs.writeShellScript
  {
    welcome = ''
      ${pkgs.figlet}/bin/figlet 'BlastOps dev shell'
      echo 'press ${prefix}-<TAB><TAB> to see all the commands'
    '';
    start = ''
      ${pkgs.electron_30}/bin/electron .  
    '';
    convert-node-gyp-shabang = ''
      sed -i -e "s|#!/usr/bin/env node|#! ${pkgs.nodejs}/bin/node|" node_modules/node-gyp-build/bin.js
    '';
  });
in pkgs.symlinkJoin rec {
  name = prefix;
  passthru.set = commands;
  passthru.bin = pkgs.lib.mapAttrs (name: command: pkgs.runCommand "${prefix}-${name}" {} '' 
    mkdir -p $out/bin
    ln -sf ${command} $out/bin/${
        if name == "default" then prefix else prefix+"-"+name
    }
  '') commands;
  paths = pkgs.lib.attrValues passthru.bin;
}
