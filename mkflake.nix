{
  nixpkgs,
  specialArgs,
  imports ? [ ],
  systems ? [ ],
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

  mapSystems =
    attrName:
    lib.filterAttrs (sys: val: val != { } && val != null) (
      lib.mapAttrs (sys: cfg: cfg.${attrName}) perSystemConfigs
    );
in

removeEmptyAttrs (
  {
    checks = mapSystems "checks";
    formatter = mapSystems "formatter";
    devShells = mapSystems "devShells";
    packages = mapSystems "packages";
    legacyPackages = mapSystems "legacyPackages";
    apps = mapSystems "apps";
  }
  // globalConfig
)
