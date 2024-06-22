{
  inputs.vims.url = "github:countoren/vims";


  inputs.quick-lint-js.url = "github:quick-lint/quick-lint-js";
  outputs = { self, nixpkgs, vims, quick-lint-js }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.permittedInsecurePackages = [
          "python-2.7.18.8"
          "electron-24.8.6"
        ];
      };
      commands = import ./commands.nix { inherit pkgs; };

      src = pkgs.nix-gitignore.gitignoreSource [ ".git" ] ./.;
      package = pkgs.lib.importJSON (src + "/package.json");
      electronZipDir = import ./electronPackages.nix {
        inherit pkgs;
        # version = "30.0.8";
        version = package.devDependencies.electron;
      };


      build = pkgs.mkYarnPackage rec {
        inherit (package) name version;
        src = pkgs.nix-gitignore.gitignoreSource [ ".git" ] ./.;
        electron_zip_dir = electronZipDir;
        ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
        extraBuildInputs = [ pkgs.dpkg pkgs.fakeroot ];
        # buildPhase = ''
        #   mkdir home
        #   touch home/.skip-forge-system-check
        #   rm ./deps/${name}/${name} 
        #   HOME="$(realpath home)" yarn run make
        #   ls
        # '';
        preConfigure = ''
          substituteInPlace package.json --replace "electron-forge make" "yarn exec electron-forge -- make  --platform linux --targets @electron-forge/maker-deb"
        '';
        buildPhase = ''
          mkdir home
          touch home/.skip-forge-system-check
          rm ./deps/${name}/${name} 
          HOME="$(realpath home)" yarn run make
        '';
        # installPhase = "cp -r ./deps/${name}/out/make/deb/${arch} $out";
      };

      buildDeb = arch:
        pkgs.mkYarnPackage rec {
          inherit (package) name version;
          src = pkgs.nix-gitignore.gitignoreSource [ ".git" ] ./.;
          electron_zip_dir = electronZipDir;
          ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
          extraBuildInputs = [ pkgs.dpkg pkgs.fakeroot ];
          # DEBUG = "*"; 
          preConfigure = ''
            substituteInPlace package.json --replace "electron-forge make" "yarn exec electron-forge -- make --arch ${arch} --platform linux --targets @electron-forge/maker-deb"
          '';
          buildPhase = ''
            mkdir home
            touch home/.skip-forge-system-check
            rm ./deps/${name}/${name} 
            HOME="$(realpath home)" yarn run make
          '';
          installPhase = "cp -r ./deps/${name}/out/make/deb/${arch} $out";
          distPhase = "true";
        };

      buildRpm = arch:
        let
          builtRpm = pkgs.vmTools.runInLinuxVM (pkgs.mkYarnPackage rec {
            memSize = 4096; # 4 GiB for the VM
            inherit (package) name version;
            src = pkgs.nix-gitignore.gitignoreSource [ ".git" ] ./.;
            electron_zip_dir = electronZipDir;
            ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
            extraBuildInputs = [ pkgs.rpm ];
            # DEBUG = "*";
            preConfigure = ''
              substituteInPlace package.json --replace "electron-forge make" "yarn exec electron-forge -- make --arch ${arch} --platform linux --targets @electron-forge/maker-rpm"
            '';
            buildPhase = ''
              mkdir home
              touch home/.skip-forge-system-check
              rm ./deps/${name}/${name}
              HOME="$(realpath home)" yarn run make
            '';
            installPhase = "cp -r ./deps/${name}/out/make/rpm/${arch} $out";
            distPhase = "true";
            dontFixup = true;
          });
        in
        pkgs.runCommand builtRpm.name { version = builtRpm.version; } ''
          cp -r ${builtRpm}/* $out
        '';

      buildExe = arch:
        pkgs.mkYarnPackage rec {
          inherit (package) name version;
          src = pkgs.nix-gitignore.gitignoreSource [ ".git" ] ./.;
          electron_zip_dir = electronZipDir;
          ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

          FONTCONFIG_PATH = "${pkgs.lib.getOutput "out" pkgs.fontconfig}/etc/fonts";
          extraBuildInputs =
            [ pkgs.wineWowPackages.full pkgs.mono pkgs.fontconfig pkgs.zip ];
          DEBUG = "*";
          preConfigure = ''
            substituteInPlace package.json --replace "electron-forge make" "yarn exec electron-forge -- make --platform win32 --arch ${arch} --targets @electron-forge/maker-zip"
          '';
          buildPhase = ''
            # electron-forge needs 'home' with a skip check file
            mkdir home
            touch home/.skip-forge-system-check
            HOME="$(realpath home)" yarn run make 
          '';
          installPhase = ''
            ${pkgs.tree}/bin/tree
            cp -r ./deps/blastops/out/make/zip/win32/${arch} $out
          '';
          distPhase = "true";
        };
    in
    {


      packages = {
        linux.x64 = {
          deb = buildDeb "x64";
          rpm = buildRpm "x64";
        };
        windows = { x64 = { exe = buildExe "x64"; }; };
        # macos = {
        #   x64 = { zip = buildZip "x64"; };
        #   arm64 = { zip = buildZip "arm64"; };
        # };
      };

      packages.${system}.default = build; #pkgs.callPackage ./default.nix {};
      # devShells.${system}.default = pkgs.callPackage (import ./default.nix) { electron = pkgs.electron_30; shellHook = "echo 12333333333"; };

      devShells.${system} = {
        fhs = import ./shell.nix {
          inherit pkgs commands vims;
          quick-lint-js = quick-lint-js.packages.${system};
        };

        default = pkgs.mkShell {
          # prevent electron download from electron in package.json
          ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
          # use the electron builds from here
          electron_zip_dir = electronZipDir;
          nativeBuildInputs = with pkgs;
            [
              (import ./devTools.nix { inherit pkgs vims;
              quick-lint-js = quick-lint-js.packages.${system};
              })
              pkg-config
              python3
              yarn
              libiconv
            ] ++ (if system == "aarch64-darwin" then
              with darwin.apple_sdk.frameworks; [
                SystemConfiguration
                Carbon
                WebKit
                cocoapods
              ]
            else
              [ ]) ++ (if system == "x86_64-linux" || system == "aarch64-linux"
            || system == "x86_64-unknown-linux-gnu" then [
              # tauri
              gtk3
              webkitgtk_4_1
              libsoup_3
              glib
              gdk-pixbuf
              pango
              gtk4
              libadwaita
              openssl
              sqlite
              # debian builds
              dpkg
              fakeroot
              # rpm builds
              rpm
              # exe builds
              wineWowPackages.full
              mono
              # zip builds
              zip
              # github releases
              gitAndTools.gh
            ] else
              [ ]);
        };
      };

    };
}
