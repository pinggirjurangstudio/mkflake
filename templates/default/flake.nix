{
  description = "Default smoothflake template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    smoothflake.url = "sourcehut:~bzm/smoothflake";
  };

  outputs =
    { nixpkgs, smoothflake, ... }@inputs:
    smoothflake.lib.mkFlake {
      inherit nixpkgs inputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [
        # # Uncomment this to modify the pkgs, e.g. to set allowUnfree.
        # {
        #   perSystem =
        #     { pkgs, system, ... }:
        #     {
        #       _module.args.pkgs = import nixpkgs {
        #         inherit system;
        #         config.allowUnfree = true;
        #       };
        #     };
        # }
        { perSystem = import ./.config/shell.nix; }
        { perSystem = import ./.config/treefmt.nix; }
      ];
    };
}
