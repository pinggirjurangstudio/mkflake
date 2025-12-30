{
  nixpkgs,
  specialArgs ? { },
  systems ? [ ],
  imports ? [ ],
  flakeModules ? { },
}:

let
  inherit (nixpkgs) lib;
  inherit (lib) mkOption types;

  # https://wiki.nixos.org/wiki/Flakes#Output_schema

  global = rec {
    schema.freeformType = types.attrsOf types.anything;
    schema.options = {
      templates = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              type = mkOption { type = types.path; };
              description = mkOption { type = types.str; };
            };
          }
        );
        default = { };
        description = "Usage: nix flake init -t <flake>#<name>";
      };
      nixosModules = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      nixosConfigurations = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
        description = "Usage: nixos-rebuild switch --flake .#<hostname>";
      };
      overlays = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      perSystem = mkOption {
        type = types.deferredModule;
        default = { pkgs, ... }: { };
      };
    };
    config =
      (lib.evalModules {
        inherit specialArgs;
        modules = [
          schema
        ]
        ++ imports;
      }).config;
  };

  perSystem = rec {
    schema.options = {
      checks = mkOption {
        type = types.attrsOf types.package;
        default = { };
        description = "Usage: nix flake check";
      };
      formatter = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Usage: nix fmt";
      };
      devShells = mkOption {
        type = types.attrsOf types.package;
        default = { };
        description = "Usage: nix develop <flake>#<name>";
      };
      packages = mkOption {
        type = types.attrsOf types.package;
        default = { };
        description = "Usage: nix build <flake>#<name>";
      };
      legacyPackages = mkOption {
        type = types.attrsOf types.package;
        default = { };
        description = "Usage: nix build <flake>#<name>";
      };
      apps = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              type = mkOption {
                type = types.enum [ "app" ];
                default = "app";
              };
              program = mkOption {
                type = types.path;
              };
              meta = mkOption {
                type = types.unspecified;
              };
            };
          }
        );
        default = { };
        description = "Usage: nix run <flake>#<name>";
      };
    };
    config = lib.genAttrs systems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        perSystemConfig = global.config.perSystem;
      in
      (lib.evalModules {
        inherit specialArgs;
        modules = [
          schema
          {
            _module.args.pkgs = lib.mkDefault pkgs;
            _module.args.system = system;
          }
          perSystemConfig
        ];
      }).config
    );
  };

  _flakeModules = rec {
    schema.options = {
      flakeModules = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
    };
    config =
      (lib.evalModules {
        modules = [
          schema
          { inherit flakeModules; }
        ];
      }).config;
  };

  removeEmptyAttrs = lib.filterAttrs (_: v: v != { } && v != null);
  mapSystems = attr: removeEmptyAttrs (lib.mapAttrs (_: cfg: cfg.${attr}) perSystem.config);
in

removeEmptyAttrs (
  {
    inherit (_flakeModules.config) flakeModules;
    checks = mapSystems "checks";
    formatter = mapSystems "formatter";
    devShells = mapSystems "devShells";
    packages = mapSystems "packages";
    legacyPackages = mapSystems "legacyPackages";
    apps = mapSystems "apps";
  }
  // builtins.removeAttrs global.config [
    "perSystem"
    "flakeModules"
  ]
)
