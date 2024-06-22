{ pkgs ? import <nixpkgs>{}
, version? "30.0.8"
, electronDownloadUrl? "https://github.com/electron/electron/releases/download"
}:
let
  electronBuilds = {
    ${version} = {
      "linux-x64" = pkgs.fetchurl {
        url =
          "${electronDownloadUrl}/v${version}/electron-v${version}-linux-x64.zip";
        sha256 = "sha256-8dGD0Ovne77hShcxGO+GLv+M8Oso7KBiCdsy8NocZt4=";
      };
      "win32-x64" = pkgs.fetchurl {
        url =
          "${electronDownloadUrl}/v${version}/electron-v${version}-win32-x64.zip";
        sha256 = "sha256-x69ozHPUo9XXBvAUFG1kyApZKO2bnmsu4qaDx2J8NUg=";
      };
      "win32-ia32" = pkgs.fetchurl {
        url =
          "${electronDownloadUrl}/v${version}/electron-v${version}-win32-ia32.zip";
        sha256 = "sha256-mPXoSi8tYNAM/9M3+1zOuQvju+AFEnz5ACB+Cielrlw=";
      };
      "darwin-x64" = pkgs.fetchurl {
        url =
          "${electronDownloadUrl}/v${version}/electron-v${version}-darwin-x64.zip";
        sha256 = "sha256-BkBmmHCGNd/ARQA9IJ+xUifT9NM8Mk/W0cZhCWDSTrg=";
      };
      "darwin-arm64" = pkgs.fetchurl {
        url =
          "${electronDownloadUrl}/v${version}/electron-v${version}-darwin-arm64.zip";
        sha256 = "sha256-XEuVb2xJXWeciPpMgAOUpkfKyCGFmUB1uen6glc/XQg=";
      };
    };
  };
  electronBuild = electronBuilds.${version};
in pkgs.linkFarm "electron-zip-dir" [
  {
    name = "${electronBuild.linux-x64.name}";
    path = electronBuild.linux-x64;
  }
  {
    name = "${electronBuild.win32-x64.name}";
    path = electronBuild.win32-x64;
  }
  {
    name = "${electronBuild.win32-ia32.name}";
    path = electronBuild.win32-ia32;
  }
  {
    name = "${electronBuild.darwin-x64.name}";
    path = electronBuild.darwin-x64;
  }
  {
    name = "${electronBuild.darwin-arm64.name}";
    path = electronBuild.darwin-arm64;
  }
]
