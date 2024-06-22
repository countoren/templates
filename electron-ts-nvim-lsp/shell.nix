{ pkgs ? import <nixpkgs> { }
, commands ? import ./commands.nix { inherit pkgs; }
, vims
, quick-lint-js
}:
(pkgs.buildFHSUserEnv {
  name = "electron-env";
  targetPkgs = pkgs: (
    (import ./devTools.nix { inherit pkgs vims quick-lint-js; })
     ++ (with pkgs; [
      yarn
      nodejs
      python39

      vscode-langservers-extracted

      # node-gyp deps
      nodePackages.node-gyp
      nodePackages.node-gyp-build
      pkg-config
      gcc11
      glibc
      # binutils
      # libcxx
      # libgcc
      musl.out
      glibc_multi.out

      # Webpack
      nodePackages.webpack
      nodePackages.webpack-cli


      # Electron deps
      electron
      libpng
      zlib
      python
      libcxx
      systemd
      libpulseaudio
      libdrm
      mesa
      stdenv.cc.cc
      alsa-lib
      atk
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libnotify
      libuuid
      nspr
      nss
      pango
      systemd
      libappindicator-gtk3
      libdbusmenu
      libxkbcommon
      factor-lang.out

    ])
  ) ++ (with pkgs.xorg; [
    # Electron deps
    libXScrnSaver
    libXrender
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libX11
    libXcomposite
    libxshmfence
    libXtst
    libxcb
  ]
  );
  profile = ''
    ${commands.set.welcome}
  '';
}).env

