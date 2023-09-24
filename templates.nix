{ lib }: with lib;
attrsets.genAttrs 
  # Parameter #1 - templates folders
  (builtins.attrNames (filterAttrs (_: v: v == "directory") (builtins.readDir ./.)))
  # Parameter #2 - transform each folder into attr set property the represent this template
  (name: { 
    description = concatMapStrings 
      (v: if v==".sx-description" then (builtins.readFile ./${name}/.sx-description) else "") 
      (builtins.attrNames (builtins.readDir ./${name}));
    path = ./${name}; 
  })
