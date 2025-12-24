{
  description = "smoothflake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    import ./.config/modules.nix {
      inherit self nixpkgs inputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      modules = [
        ./.config/checks.nix
        ./.config/formatter.nix
        ./.config/devshells.nix
      ];
    };
}
