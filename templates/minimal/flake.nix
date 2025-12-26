{
  description = "Minimal smoothflake template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    smoothflake.url = "sourcehut:~bzm/smoothflake";
  };

  outputs =
    { nixpkgs, smoothflake, ... }@inputs:
    smoothflake.lib.mkFlake {
      inherit nixpkgs;
      specialArgs = inputs;
      imports = [
        # Modules for system-agnostic:
        # - templates
        # - nixosModules
        # - overlays
        # - other arbitrary attributes
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = system: {
        pkgs = import nixpkgs { inherit system; };
        imports = [
          # Modules for system-specific:
          # - checks
          # - formatter
          # - devShells
          # - packages
          # - legacyPackages
          # - apps
          ./.config/shell.nix
        ];
      };
    };
}
