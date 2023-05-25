{
  description = "Virtual on-screen keyboard";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";

    tinycmmc.url = "github:grumbel/tinycmmc";
    tinycmmc.inputs.nixpkgs.follows = "nixpkgs";
    tinycmmc.inputs.flake-utils.follows = "flake-utils";

    argpp.url = "github:grumbel/argpp?ref=stable";
    argpp.inputs.nixpkgs.follows = "nixpkgs";
    argpp.inputs.flake-utils.follows = "flake-utils";
    argpp.inputs.tinycmmc.follows = "tinycmmc";

    strutcpp.url = "github:grumbel/strutcpp";
    strutcpp.inputs.nixpkgs.follows = "nixpkgs";
    strutcpp.inputs.tinycmmc.follows = "tinycmmc";

    logmich.url = "github:logmich/logmich";
    logmich.inputs.nixpkgs.follows = "nixpkgs";
    logmich.inputs.tinycmmc.follows = "tinycmmc";

    uinpp.url = "github:Grumbel/uinpp";
    uinpp.inputs.nixpkgs.follows = "nixpkgs";
    uinpp.inputs.flake-utils.follows = "flake-utils";
    uinpp.inputs.strutcpp.follows = "strutcpp";
    uinpp.inputs.logmich.follows = "logmich";
    uinpp.inputs.tinycmmc.follows = "tinycmmc";
  };

  outputs = { self, nixpkgs, flake-utils, argpp, tinycmmc, strutcpp, logmich, uinpp }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version_file = pkgs.lib.fileContents ./VERSION;
        project_has_version = ((builtins.substring 0 1) version_file) == "v";
        project_version = if !project_has_version
                          then ("0.0.0-${nixpkgs.lib.substring 0 8 self.lastModifiedDate}-${self.shortRev or "dirty"}")
                          else (builtins.substring 1 ((builtins.stringLength version_file) - 2) version_file);
      in {
        packages = rec {
          default = virtkbd;

          virtkbd = pkgs.stdenv.mkDerivation rec {
            pname = "virtkbd";
            version = project_version;

            src = ./.;

            postPatch = ''
                if ${if project_has_version then "false" else "true"}; then
                  echo "${version}" > VERSION
                fi
            '';

            cmakeFlags = [ "-DWARNINGS=ON" "-DWERROR=ON" ];

            nativeBuildInputs = with pkgs; [
              cmake
              pkg-config
            ];

            buildInputs = with pkgs; [
              gtk3

              # indirect dependencies that pkg-config complains about
              at-spi2-core
              dbus-glib
              epoxy
              gobject-introspection
              libdatrie
              libselinux
              libsepol
              libthai
              libxkbcommon
              pcre
              util-linux
              xorg.libXdmcp
              xorg.libXtst
            ] ++ [
              argpp.packages.${system}.default
              logmich.packages.${system}.default
              strutcpp.packages.${system}.default
              uinpp.packages.${system}.default
              tinycmmc.packages.${system}.default
            ];
          };
        };
      }
    );
}
