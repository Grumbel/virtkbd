{
  description = "Virtual on-screen keyboard";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";

    tinycmmc.url = "gitlab:grumbel/cmake-modules";
    tinycmmc.inputs.nixpkgs.follows = "nixpkgs";
    tinycmmc.inputs.flake-utils.follows = "flake-utils";

    argparser.url = "gitlab:argparser/argparser/stable";
    argparser.inputs.nixpkgs.follows = "nixpkgs";
    argparser.inputs.flake-utils.follows = "flake-utils";
    argparser.inputs.tinycmmc.follows = "tinycmmc";

    strutcpp.url = "gitlab:grumbel/strutcpp";
    strutcpp.inputs.nixpkgs.follows = "nixpkgs";
    strutcpp.inputs.flake-utils.follows = "flake-utils";
    strutcpp.inputs.tinycmmc.follows = "tinycmmc";

    logmich.url = "gitlab:logmich/logmich";
    logmich.inputs.nixpkgs.follows = "nixpkgs";
    logmich.inputs.flake-utils.follows = "flake-utils";
    logmich.inputs.tinycmmc.follows = "tinycmmc";

    # uinpp.url = "gitlab:Grumbel/uinpp";
    uinpp.url = "git+file:///home/ingo/projects/uinpp/trunk/";
    uinpp.inputs.nixpkgs.follows = "nixpkgs";
    uinpp.inputs.flake-utils.follows = "flake-utils";
    uinpp.inputs.strutcpp.follows = "strutcpp";
    uinpp.inputs.logmich.follows = "logmich";
    uinpp.inputs.tinycmmc.follows = "tinycmmc";
  };

  outputs = { self, nixpkgs, flake-utils, argparser, tinycmmc, strutcpp, logmich, uinpp }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version_file = pkgs.lib.fileContents ./VERSION;
        project_has_version = ((builtins.substring 0 1) version_file) == "v";
        project_version = if !project_has_version
                          then ("0.0.0-${nixpkgs.lib.substring 0 8 self.lastModifiedDate}-${self.shortRev or "dirty"}")
                          else (builtins.substring 1 ((builtins.stringLength version_file) - 2) version_file);
      in rec {
        packages = flake-utils.lib.flattenTree {
          virtkbd = pkgs.stdenv.mkDerivation rec {
            pname = "virtkbd";
            version = project_version;
            src = nixpkgs.lib.cleanSource ./.;
            postPatch = ''
                if ${if project_has_version then "false" else "true"}; then
                  echo "${version}" > VERSION
                fi
            '';
            cmakeFlags = [ "-DWARNINGS=ON" "-DWERROR=ON" ];
            nativeBuildInputs = [
              pkgs.cmake
              pkgs.pkg-config
            ];
            buildInputs = [
              argparser.defaultPackage.${system}
              logmich.defaultPackage.${system}
              strutcpp.defaultPackage.${system}
              uinpp.defaultPackage.${system}
              tinycmmc.defaultPackage.${system}

              pkgs.gtk3

              # indirect dependencies that pkg-config complains about
              pkgs.at-spi2-core
              pkgs.dbus-glib
              pkgs.epoxy
              pkgs.gobject-introspection
              pkgs.libdatrie
              pkgs.libselinux
              pkgs.libsepol
              pkgs.libthai
              pkgs.libxkbcommon
              pkgs.pcre
              pkgs.util-linux
              pkgs.xorg.libXdmcp
              pkgs.xorg.libXtst
            ];
          };
        };
        defaultPackage = packages.virtkbd;
      });
}
