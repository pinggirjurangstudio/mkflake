{
  nixpkgs,
  specialArgs,
  imports ? [ ],
  systems,
  perSystem ? (system: { }),
}:

let
  inherit (nixpkgs) lib;
  removeEmptyAttrs = lib.filterAttrs (name: value: value != { } && value != null);

  outputSchema = import ./output-schema.nix { inherit nixpkgs; };

  globalConfig =
    (lib.evalModules {
      inherit specialArgs;
      modules = [ outputSchema.global ] ++ imports;
    }).config;

  perSystemConfigs = lib.genAttrs systems (
    system:
    let
      sys = perSystem system;
      sysPkgs = sys.pkgs or nixpkgs.legacyPackages.${system};
      sysImports = sys.imports or [ ];
    in
    (lib.evalModules {
      inherit specialArgs;
      modules = [
        outputSchema.perSystem
        { _module.args.pkgs = sysPkgs; }
      ]
      ++ sysImports;
    }).config
  );
in

removeEmptyAttrs (
  {
    checks = lib.mapAttrs (sys: cfg: cfg.checks) perSystemConfigs;
    formatter = lib.mapAttrs (sys: cfg: cfg.formatter) perSystemConfigs;
    devShells = lib.mapAttrs (sys: cfg: cfg.devShells) perSystemConfigs;
    packages = lib.mapAttrs (sys: cfg: cfg.packages) perSystemConfigs;
    legacyPackages = lib.mapAttrs (sys: cfg: cfg.legacyPackages) perSystemConfigs;
    apps = lib.mapAttrs (sys: cfg: cfg.apps) perSystemConfigs;
  }
  // globalConfig
)
