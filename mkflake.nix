# Vendoring this file by using the following template:
# nix flake init -t sourcehut:~bzm/smoothflake#lib

{
  nixpkgs,
  inputs,
  systems ? [ ],
  imports ? [ ],
}:

let
  inherit (nixpkgs) lib;
  inherit (lib) mkOption types;

  # https://wiki.nixos.org/wiki/Flakes#Output_schema

  _global = rec {
    schema.options = {
      templates = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      nixosModules = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      nixosConfigurations = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      overlays = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      perSystem = mkOption {
        type = types.deferredModule;
        default = { };
      };
      flakeModules = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      lib = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      flake = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.unspecified;
        };
        default = { };
      };
    };
    config =
      (lib.evalModules {
        specialArgs = inputs;
        modules = [ schema ] ++ imports;
      }).config;
  };

  _perSystem = rec {
    schema.options = {
      checks = mkOption {
        type = types.attrsOf types.package;
        default = { };
      };
      formatter = mkOption {
        type = types.nullOr types.package;
        default = null;
      };
      devShells = mkOption {
        type = types.attrsOf types.package;
        default = { };
      };
      packages = mkOption {
        type = types.attrsOf types.package;
        default = { };
      };
      legacyPackages = mkOption {
        type = types.attrsOf types.package;
        default = { };
      };
      apps = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      treefmt = mkOption {
        type = types.submodule {
          options = {
            excludes = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
            formatter = mkOption {
              type = types.attrsOf (
                types.submodule {
                  options = {
                    command = mkOption {
                      type = types.either types.path types.str;
                    };
                    includes = mkOption {
                      type = types.listOf types.str;
                    };
                    excludes = mkOption {
                      type = types.listOf types.str;
                      default = [ ];
                    };
                    options = mkOption {
                      type = types.listOf types.str;
                      default = [ ];
                    };
                  };
                }
              );
              default = { };
            };
          };
        };
        default = { };
      };
    };
    config = lib.genAttrs systems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        perSystemConfig = _global.config.perSystem;
      in
      (lib.evalModules {
        specialArgs = inputs;
        modules = [
          schema
          {
            _module.args.pkgs = lib.mkDefault pkgs;
            _module.args.system = system;
          }
          perSystemConfig
          (
            {
              config,
              lib,
              pkgs,
              ...
            }:
            let
              # this part code are stripped version of
              # https://github.com/numtide/treefmt-nix/blob/dec15f37015ac2e774c84d0952d57fcdf169b54d/module-options.nix
              treefmtConfig = (pkgs.formats.toml { }).generate "treefmt.toml" config.treefmt;
              treefmtFormatter = pkgs.writeShellScriptBin "treefmt" ''
                set -euo pipefail
                unset PRJ_ROOT
                exec ${pkgs.treefmt}/bin/treefmt \
                  --config-file=${treefmtConfig} \
                  --tree-root-file=flake.nix \
                  "$@"
              '';
              treefmtCheck =
                pkgs.runCommandLocal "treefmt-check"
                  {
                    buildInputs = [
                      pkgs.git
                      pkgs.git-lfs
                      treefmtFormatter
                    ];
                  }
                  ''
                    set -e
                    PRJ=$TMP/project
                    cp -r ${inputs.self} $PRJ
                    chmod -R a+w $PRJ
                    cd $PRJ
                    export HOME=$TMPDIR
                    cat > $HOME/.gitconfig <<EOF
                    [user]
                      name = Nix
                      email = nix@localhost
                    [init]
                      defaultBranch = main
                    EOF
                    git init --quiet
                    git add .
                    git commit -m init --quiet
                    export LANG=${if pkgs.stdenv.isDarwin then "en_US.UTF-8" else "C.UTF-8"}
                    export LC_ALL=${if pkgs.stdenv.isDarwin then "en_US.UTF-8" else "C.UTF-8"}
                    treefmt --version
                    treefmt --no-cache
                    git status --short
                    git --no-pager diff --exit-code
                    touch $out
                  '';
            in
            {
              formatter = lib.mkDefault treefmtFormatter;
              checks.treefmt = lib.mkDefault treefmtCheck;
            }
          )
        ];
      }).config
    );
  };

  removeEmptyAttrs = lib.filterAttrs (_: v: v != { } && v != null);
  mapSystems = attr: removeEmptyAttrs (lib.mapAttrs (_: cfg: cfg.${attr}) _perSystem.config);
in

removeEmptyAttrs {
  inherit (_global.config)
    templates
    nixosModules
    nixosConfigurations
    overlays
    flakeModules
    lib
    ;
  checks = mapSystems "checks";
  formatter = mapSystems "formatter";
  devShells = mapSystems "devShells";
  packages = mapSystems "packages";
  legacyPackages = mapSystems "legacyPackages";
  apps = mapSystems "apps";
}
// _global.config.flake
