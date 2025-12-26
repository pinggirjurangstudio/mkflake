{
  description = "Unfree smoothflake template with treefmt checks and formatter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    smoothflake.url = "sourcehut:~bzm/smoothflake";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, smoothflake, ... }@inputs:
    smoothflake.lib.mkFlake {
      inherit nixpkgs;
      specialArgs = inputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [
        {
          perSystem =
            { pkgs, system, ... }:
            {
              _module.args.pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
              };
            };
        }
        { perSystem = import ./.config/shell.nix; }
        { perSystem = import ./.config/treefmt.nix; }
      ];
    };
}
