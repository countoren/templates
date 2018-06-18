let 
  d = dotfilePath: {stdenv}:
    let dotfileName = baseNameOf dotfilePath;
    in
    stdenv.mkDerivation rec {
      name = dotfileName;

      phases = [ "installPhase" ];

      src = dotfilePath;

      installPhase = ''
        install -dm 755 $out/userHome
        substitute $src $out/userHome/.''+dotfileName;
    };
in
{
# Allow proprietary packages
	allowUnfree = true;

  packageOverrides = pkgs_: with pkgs_; {
    bash-config = import ./bash-config {
        inherit (pkgs) stdenv;
    };



    homeInstall = pkgs.writeShellScriptBin "homeInstall"   (builtins.readFile ./HomeInstall/homeInstallSymLinks);

    dotfiles = with pkgs; buildEnv {
      name = "dotfiles";
      paths = [
        (d ./bash-config/bashrc { inherit (pkgs) stdenv; })
      ];
    };

    ovim = import ./vim { inherit pkgs; };

    macvim = stdenv.mkDerivation {
      name = "macvim-147";
      src = fetchurl {
        url = "https://github.com/macvim-dev/macvim/releases/download/snapshot-147/MacVim.dmg";
        sha256 = "07szhx043ixym8n15n5xn9g5mjf1r8zi28hgdbpyf07vrfymc0zg";
      };
      buildInputs = [ p7zip ];
      buildCommand = ''
        7z x $src
        cd MacVim
        mkdir -p $out/Applications
        cp -rfv MacVim.app $out/Applications
        chmod 755 $out/Applications/MacVim.app/Contents/MacOS/* \
                  $out/Applications/MacVim.app/Contents/bin/*
        mkdir -p $out/bin
        ln -sf $out/Applications/MacVim.app/Contents/bin/mvim $out/bin/mvim
        ln -sf $out/bin/mvim $out/bin/vim
        ln -sf $out/bin/mvim $out/bin/vi
        ln -sf $out/bin/mvim $out/bin/gvim
      '';
    };


  };
}
