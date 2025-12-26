# https://wiki.nixos.org/wiki/Flakes#Output_schema
{ nixpkgs }:

let
  inherit (nixpkgs.lib) mkOption types;
in

{
  global.freeformType = types.attrsOf types.anything;
  global.options = {
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

  perSystem.options = {
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
            meta = mkOption {
              type = types.unspecified;
            };
          };
        }
      );
      default = { };
    };
  };
}
