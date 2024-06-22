{ buildDotnetGlobalTool, lib, dotnetCorePackages, writeShellScriptBin }:

let fsautocomplete =
  buildDotnetGlobalTool {
    pname = "fsautocomplete";
    version = "0.62.0";

    nugetSha256 = "sha256-p5A8WURcGbI8kgEVpvTYQnbcEGoIExPYA3FAR+bPM90=";

    dotnet-runtime = with dotnetCorePackages; combinePackages [
        sdk_7_0
        sdk_6_0
    ];

    meta = with lib; {
      homepage = "https://github.com/fsharp/FsAutoComplete";
      changelog = "https://github.com/fsharp/FsAutoComplete/releases";
      license = licenses.apsl20;
      platforms = platforms.linux ++ platforms.darwin;
    };
  };
in {
  fsautocomplete-local-or-nix =
      writeShellScriptBin "fsautocomplete" ''
        if command -v dotnet >/dev/null && dotnet tool run fsautocomplete --version >/dev/null 2>/dev/null;
        then
          exec dotnet tool run fsautocomplete "$@"
        else
          exec "${fsautocomplete}/bin/fsautocomplete" "$@"
        fi
    '';
  inherit fsautocomplete;
}
