{
  self,
  nixpkgs,
  systems,
  modules,
  inputs,
}:

let
  inherit (nixpkgs) lib;
  inherit (lib)
    mkOption
    types
    genAttrs
    mapAttrs
    ;

  # https://wiki.nixos.org/wiki/Flakes#Output_schema
  baseModule = {
    options = {
      # nix flake check
      checks = mkOption {
        type = types.attrsOf types.package;
        default = { };
      };
      # nix fmt
      formatter = mkOption {
        type = types.nullOr types.package;
        default = null;
      };
      # nix develop <flake>#<name>
      devShells = mkOption {
        type = types.attrsOf types.package;
        default = { };
      };
      # nix build <flake>#<name>
      packages = mkOption {
        type = types.attrsOf types.package;
        default = { };
      };
      # nix build <flake>#<name>
      legacyPackages = mkOption {
        type = types.attrsOf types.package;
        default = { };
      };
      # nix run <flake>#<name>
      apps = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              type = mkOption {
                type = types.str;
                default = "app";
              };
              program = mkOption {
                type = types.path;
              };
            };
          }
        );
        default = { };
      };
      # nix flake init -t <flake>#<name>
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
      };
      # NixOS modules
      nixosModules = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      # Overlays
      overlays = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
    };
  };

  eval =
    {
      pkgs ? null,
    }:
    (lib.evalModules {
      modules = [ baseModule ] ++ modules;
      specialArgs = inputs // {
        inherit self pkgs;
        lib = lib.extend (self: super: import ./lib.nix { inherit lib; });
      };
    }).config;

  globalConfig = eval { };

  systemConfigs = genAttrs systems (
    system:
    eval {
      pkgs = import nixpkgs { inherit system; };
    }
  );

  removeEmpty = lib.filterAttrs (name: value: value != { } && value != null);
in

removeEmpty {
  inherit (globalConfig) templates nixosModules overlays;
  checks = mapAttrs (sys: cfg: cfg.checks) systemConfigs;
  formatter = mapAttrs (sys: cfg: cfg.formatter) systemConfigs;
  devShells = mapAttrs (sys: cfg: cfg.devShells) systemConfigs;
  packages = mapAttrs (sys: cfg: cfg.packages) systemConfigs;
  legacyPackages = mapAttrs (sys: cfg: cfg.legacyPackages) systemConfigs;
  apps = mapAttrs (sys: cfg: cfg.apps) systemConfigs;
}
