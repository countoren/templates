{ pkgs ? (builtins.getFlake (toString ../.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
, templates ? import ./templates.nix
# Prefix to be appended to all 
, prefix ? "sx"

, nix ? "${pkgs.nix}/bin/nix"
, lib ? pkgs.lib
, writeShellScriptBin ? pkgs.writeShellScriptBin

, git ? "${pkgs.git}/bin/git"
# This string is repesenting the absolute pass of your templates folder
# if use in standalone the path could be brought by this command
# otherwise replace with hardcoded string path (will be used in a shell script)
, templatesFolder ? ''$(${git} rev-parse --show-toplevel)''

, highlight ? "${pkgs.highlight}/bin/highlight"
, fzf ? "${pkgs.fzf}/bin/fzf"
# this command will be fed ($1) with the directory containing snippets should prompt the users for chosing snippet 
, listAndSelectTool? pkgs.writeShellScript "select" ''
  find $1 -type f -not -path './.git/*' | ${fzf} -1 --preview="${highlight} -O ansi {}"       
''
# this command will be fed by a file chosed by the user which contain the snippet
, snipTool ? pkgs.writeShellScript "snipTool" ''cat $1 | ${pkgs.xclip}/bin/xclip -selection c && cat $1''

# Default nix install command for stand alone templates(not with Nixos or HomeManager)
# The command should be fed as a string with references in order to feed it into writeShellScript
# if used in nixos should be replaced with something like nixos-rebuild switch ...
, installCommand ? ''
    ${nix} profile remove $(${nix} profile list | grep '${prefix}$' | cut -d ' ' -f 4)
    ${nix} profile install -f ${templatesFolder}/default.nix
''
# a difftool that will be fed with 2 filepath to compare in case of conflict
# between a target file and a template file
, difftool ? pkgs.writeShellScript "vimdiff" ''
  ${pkgs.vim}/bin/vimdiff $1 $2
''
}:
let commands = lib.fix (self: lib.mapAttrs pkgs.writeShellScript 
  ({
    utils-install-command = installCommand;
    init = ''
      ${nix} flake init -t ${templatesFolder}\#$1
    '';

    snip = ''
     ${snipTool} $(${listAndSelectTool} ${templatesFolder}/$1 )
    '';

    init-with-diff = ''
      conflicts=$(${self.init} $1 2>&1 | grep 'refusing\|merge')
      [[ -z $conflicts ]] || echo $conflicts | awk '{ print $NF }' | xargs -n 2 ${difftool}
    '';

    utils-create-and-copy-template-files = ''
      echo "creating template folder ${templatesFolder}"
      mkdir -p ${templatesFolder}/$2 
      echo "copying templates files..."
      echo "origin: $1"
      echo "target: ${templatesFolder}/$2"
      cp -r $1 ${templatesFolder}/$2 
    '';


    save-basic = ''
      ${self.utils-create-and-copy-template-files} $1 $2 && \

      [[ "$4" == "y" ]] && $EDITOR ${templatesFolder}/$2 && \
      echo 'Waiting, press any key to contine...' && read -n1 K 

      echo "cd into templates and adding folder to git"
      pushd ${templatesFolder}
      ${git} add $2
      echo "cd back to last folder"
      popd

      echo "Inserting $2 into the templates list"
      echo "// { $2 = { description = \"$([[ ! -z $3 ]] || echo 'N/A')\"; path = ./$2; }; }" >> ${templatesFolder}/templates.nix

      ${self.utils-install-command} 
    '';

    create = ''
      read -p "Template Name:" name 
      read -p "Template Desc:" desc 
      echo 'Edit Files?[press y to edit or any key otherwise]'
      read -n1 edit
      ${self.save-basic} . $name $desc $edit
    '';
    
    remove = ''
      if [ -z "\$1" ]
      then
        echo "you must supply template name"
        exit 1
      fi
      echo 'about to run rm -rf ${templatesFolder}/$1'
      echo 'continue?[press y to edit or any key otherwise]'
      read -n1 delete
      [[ "$delete" == "y" ]] && rm -rf ${templatesFolder}/$1 && \
      sed -i'.bak' ',${templatesFolder}/'$1',d' ${templatesFolder}/templates.nix
    '';

    utils-get-flake-desc = "${nix} flake metadata  | grep 'Description' | sed 's/Description.*//' ";
    save = ''
      name=$(basename `pwd`)
      desc=$(${self.utils-get-flake-desc})
      edit="n"
      ${self.save-basic} . $name $desc $edit
    '';
    save-flake = ''
      read -p "Template Name:" name 
      desc=$(${self.utils-get-flake-desc})
      edit="n"
      ${self.save-basic} flake.nix $name $desc $edit
    '';

    save-edit = ''
      name=$(basename `pwd`)
      desc=$(${self.utils-get-flake-desc})
      edit="y"
      ${self.save-basic} . $name $desc $edit
    '';

  } // lib.attrsets.concatMapAttrs (name: { description, path }: {
    "${name}" = "${self.init-with-diff} ${name}";
    "snip-${name}" = ''${self.snip} ${name}'';
    "${name}-edit" = ''$EDITOR $(${listAndSelectTool} ${templatesFolder}/${name}) '';
    "${name}-noDiff" = '' ${self.init} ${name} '';
    "${name}-description" = '' echo "${description}" '';
  }) templates)

);
# nix build -f default.nix --argstr templatesFolder /home/p1n3/nixpkgs/templates 
in lib.fix (self: pkgs.symlinkJoin {
  name = prefix;
  passthru.commands = lib.mapAttrs (name: pkgs.writeShellScriptBin "${prefix}-${name}") commands;
  paths = lib.attrValues self.passthru.commands;
})
